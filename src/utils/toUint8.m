function out = toUint8(img)
%TOUINT8 Konversi citra ke uint8 [0,255] tanpa Image Processing Toolbox.
%   - uint8           : dikembalikan apa adanya
%   - uint16/int      : diskalakan dari rentang tipe asalnya
%   - logical         : 0 -> 0, 1 -> 255
%   - double/single   : jika maks <= 1 dianggap rentang [0,1],
%                       selain itu dianggap sudah di rentang [0,255]

    if isa(img, 'uint8')
        out = img;
    elseif islogical(img)
        out = uint8(img) * 255;
    elseif isinteger(img)
        lo = double(intmin(class(img)));
        hi = double(intmax(class(img)));
        out = uint8(round((double(img) - lo) / (hi - lo) * 255));
    else
        x = double(img);
        if max(x(:)) <= 1
            x = x * 255;
        end
        out = uint8(min(max(round(x), 0), 255));
    end
end
