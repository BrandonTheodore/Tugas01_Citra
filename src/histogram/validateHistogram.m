function [lines, hOwn, hRef, method, allOk] = validateHistogram(img)
%VALIDATEHISTOGRAM Membandingkan computeHistogram dengan fungsi pembanding.
%   Pembanding: imhist (Image Processing Toolbox) jika tersedia, jika
%   tidak memakai histcounts dengan tepi bin -0.5 .. 255.5. Fungsi
%   pembanding HANYA dipakai di sini untuk validasi.
%
%   hOwn, hRef : 256 x C (C = 1 untuk grayscale, 3 untuk RGB)
%   lines      : ringkasan hasil validasi per kanal
%   allOk      : true jika semua kanal identik

    useImhist = exist('imhist', 'file') == 2;
    if useImhist
        method = 'imhist';
    else
        method = 'histcounts';
    end

    C = size(img, 3);
    names = {'Gray'};
    if C == 3, names = {'R', 'G', 'B'}; end

    hOwn = zeros(256, C);
    hRef = zeros(256, C);
    lines = cell(1, C);
    allOk = true;
    for c = 1:C
        ch = img(:, :, c);
        hOwn(:, c) = computeHistogram(ch);
        if useImhist
            hRef(:, c) = imhist(uint8(ch), 256);
        else
            hRef(:, c) = histcounts(double(ch(:)), -0.5:1:255.5)';
        end
        d = max(abs(hOwn(:, c) - hRef(:, c)));
        ok = d == 0 && sum(hOwn(:, c)) == numel(ch);
        allOk = allOk && ok;
        lines{c} = sprintf(['  Kanal %-4s: jumlah piksel %d (=%d), selisih maks %d, ' ...
            'bin terbanyak = %d (%d piksel) -> %s'], names{c}, sum(hOwn(:, c)), numel(ch), ...
            d, find(hOwn(:, c) == max(hOwn(:, c)), 1) - 1, max(hOwn(:, c)), ...
            ternary(ok, 'IDENTIK', 'BERBEDA'));
    end
    lines{end+1} = sprintf('  Pembanding: %s', method);
end

function v = ternary(c, a, b)
    if c, v = a; else, v = b; end
end
