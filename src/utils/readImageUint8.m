function img = readImageUint8(path)
%READIMAGEUINT8 Membaca file citra dan menormalkannya ke uint8.
%   Citra terindeks dikonversi ke RGB, kanal alpha dibuang, dan citra
%   RGB yang ketiga kanalnya identik disederhanakan menjadi grayscale.

    [img, map] = imread(path);

    if ~isempty(map)
        % Citra terindeks -> RGB (ind2rgb adalah fungsi dasar MATLAB)
        img = ind2rgb(img, map);
    end

    if ndims(img) == 3 && size(img, 3) > 3
        img = img(:, :, 1:3);           % buang alpha / kanal tambahan
    end

    img = toUint8(img);

    if ndims(img) == 3 && size(img, 3) == 3
        r = img(:, :, 1); g = img(:, :, 2); b = img(:, :, 3);
        if isequal(r, g) && isequal(g, b)
            img = r;                    % RGB "palsu" -> grayscale
        end
    end
end
