function [out, info] = applyStep(img, step, ref, useBuiltin)
%APPLYSTEP Menerapkan satu langkah enhancement pada citra uint8.
%   [out, info] = APPLYSTEP(img, step, ref, useBuiltin)
%     img        : citra uint8 (grayscale HxW atau RGB HxWx3)
%     step       : struct dengan field id, params (vektor), colorMode
%     ref        : citra referensi uint8 (untuk histogram matching), boleh []
%     useBuiltin : true -> gunakan fungsi bawaan MATLAB/IPT (HANYA untuk
%                  pembanding), false (default) -> implementasi sendiri
%   info berisi deskripsi teks langkah (metode, mode warna, parameter).

    if nargin < 3, ref = []; end
    if nargin < 4, useBuiltin = false; end

    cat_ = methodCatalog();
    m = cat_(strcmp({cat_.id}, step.id));
    if isempty(m)
        error('applyStep:method', 'Metode tidak dikenal: %s', step.id);
    end

    % Lengkapi parameter yang kosong dengan nilai default.
    p = m.defaults;
    if isfield(step, 'params') && ~isempty(step.params)
        n = min(numel(step.params), numel(p));
        p(1:n) = step.params(1:n);
    end

    mode = 'auto';
    if isfield(step, 'colorMode') && ~isempty(step.colorMode)
        mode = step.colorMode;
    end
    isColor = ndims(img) == 3;
    if strcmp(mode, 'auto')
        mode = m.colorMode;
        % Matching dengan referensi berwarna: cocokkan tiap kanal RGB.
        if strcmp(m.id, 'histmatch') && isColor && ~isempty(ref) && ndims(ref) == 3
            mode = 'rgb';
        end
    end
    if ~isColor, mode = 'gray'; end

    % Fungsi operasi satu kanal (double [0,255] -> double).
    op = @(ch, refCh) channelOp(m.id, ch, p, refCh, useBuiltin);

    switch mode
        case 'gray'
            out = clip8(op(double(img), refChannel(ref, 'gray')));

        case 'rgb'
            out = zeros(size(img), 'uint8');
            for c = 1:3
                out(:, :, c) = clip8(op(double(img(:, :, c)), refChannel(ref, 'rgb', c)));
            end

        case 'ycc'
            [Y, Cb, Cr] = rgbToYcc(img);
            Y2 = min(max(op(Y, refChannel(ref, 'y')), 0), 255);
            out = yccToRgb(Y2, Cb, Cr);

        case 'ratio'
            % Proses luminansi lalu skalakan R,G,B dengan faktor yang sama
            % (Y'/Y) sehingga perbandingan antar kanal (hue & saturasi)
            % tetap. Piksel yang melewati 255 di-clip.
            Y  = rgbToYcc(img);
            Y2 = min(max(op(Y, refChannel(ref, 'y')), 0), 255);
            gain = Y2 ./ max(Y, 1);             % HxW
            rgb  = double(img) .* gain;         % implicit expansion ke HxWx3
            black = Y < 1;                      % piksel hitam murni: rasio tak
            if any(black(:))                    % terdefinisi -> jadikan abu Y'
                for c = 1:3
                    t = rgb(:, :, c);
                    t(black) = Y2(black);
                    rgb(:, :, c) = t;
                end
            end
            out = clip8(rgb);

        case 'hsv'
            hsv = rgb2hsv(double(img) / 255);
            V2  = min(max(op(hsv(:, :, 3) * 255, refChannel(ref, 'v')), 0), 255);
            hsv(:, :, 3) = V2 / 255;
            out = clip8(hsv2rgb(hsv) * 255);

        otherwise
            error('applyStep:mode', 'Mode warna tidak dikenal: %s', mode);
    end

    info = describeStep(m, p, mode, ref, useBuiltin);
end

% -------------------------------------------------------------------------
function y = channelOp(id, f, p, refCh, useBuiltin)
    if useBuiltin
        y = builtinOp(id, f, p, refCh);
        return;
    end
    switch id
        case 'negative',    y = negativeTransform(f);
        case 'log',         y = logTransform(f, p(1));
        case 'gamma',       y = gammaTransform(f, p(1), p(2));
        case 'stretch',     y = contrastStretch(f, p(1), p(2), p(3), p(4));
        case 'histeq',      y = histEqualization(f);
        case 'histmatch'
            if isempty(refCh)
                y = histMatching(f, gaussianTargetHistogram(p(1), p(2)));
            else
                y = histMatching(f, refCh);
            end
        case 'mean',        y = convolve2d(f, makeKernel('mean', p(1)));
        case 'gaussian',    y = convolve2d(f, makeKernel('gaussian', p(1), p(2)));
        case 'median',      y = medianFilter(f, p(1));
        case 'laplacian',   y = laplacianSharpen(f, p(1), p(2));
        case 'unsharp',     y = unsharpMask(f, p(1), p(2), p(3));
    end
end

% -------------------------------------------------------------------------
function y = builtinOp(id, f, p, refCh)
%BUILTINOP Versi fungsi bawaan MATLAB/IPT. HANYA untuk pembanding hasil.
    u = uint8(min(max(round(f), 0), 255));
    switch id
        case 'negative',  y = double(imcomplement(u));
        case 'log',       y = logTransform(f, p(1));   % tidak ada padanan langsung
        case 'gamma',     y = p(2) * double(imadjust(u, [0 1], [0 1], p(1)));
        case 'stretch'
            lim = stretchlim(u, [p(1) p(2)] / 100);
            y = double(imadjust(u, lim, [p(3) p(4)] / 255));
        case 'histeq',    y = double(histeq(u, 256));
        case 'histmatch'
            if isempty(refCh)
                y = double(histeq(u, gaussianTargetHistogram(p(1), p(2))));
            else
                y = double(imhistmatch(u, uint8(refCh), 256));
            end
        case 'mean',      y = double(imfilter(f, makeKernel('mean', p(1)), 'replicate', 'conv'));
        case 'gaussian',  y = double(imfilter(f, makeKernel('gaussian', p(1), p(2)), 'replicate', 'conv'));
        case 'median'
            y = double(medfilt2(u, [p(1) p(1)], 'symmetric'));
        case 'laplacian'
            y = f - p(1) * imfilter(f, makeKernel('laplacian', p(2)), 'replicate', 'conv');
        case 'unsharp'
            y = f + p(3) * (f - imfilter(f, fspecial('gaussian', p(1), p(2)), 'replicate', 'conv'));
    end
end

% -------------------------------------------------------------------------
function r = refChannel(ref, kind, c)
    r = [];
    if isempty(ref), return; end
    isColorRef = ndims(ref) == 3;
    switch kind
        case 'rgb'
            if isColorRef, r = double(ref(:, :, c)); else, r = double(ref); end
        otherwise   % 'gray', 'y', 'v'
            if ~isColorRef
                r = double(ref);
            elseif strcmp(kind, 'v')
                r = double(max(ref, [], 3));        % V = max(R,G,B)
            else
                r = rgbToYcc(ref);                  % luminansi Y
            end
    end
end

function u = clip8(x)
    u = uint8(min(max(round(x), 0), 255));
end

function s = describeStep(m, p, mode, ref, useBuiltin)
    parts = cell(1, numel(m.params));
    for i = 1:numel(m.params)
        parts{i} = sprintf('%s=%g', m.params{i}, p(i));
    end
    if strcmp(m.id, 'histmatch') && ~isempty(ref)
        parts = {'target=histogram citra referensi'};
    end
    s = sprintf('%s [%s] (mode warna: %s)', m.label, m.group, mode);
    if ~isempty(parts)
        s = sprintf('%s; %s', s, strjoin(parts, ', '));
    end
    if useBuiltin
        s = [s ' <BUILT-IN>'];
    end
end
