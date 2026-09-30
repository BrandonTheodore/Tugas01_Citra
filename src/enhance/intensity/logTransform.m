function out = logTransform(ch, c)
%LOGTRANSFORM Transformasi logaritmik s = c * log(1 + r).
%   Memperlebar rentang intensitas gelap dan memampatkan intensitas
%   terang. Jika c <= 0, c dipilih otomatis = 255 / log(1 + max(r))
%   sehingga piksel paling terang dipetakan ke 255.

    r = double(ch);
    if nargin < 2 || isempty(c) || c <= 0
        c = 255 / log(1 + max(max(r(:)), 1));
    end
    out = c * log(1 + r);
end
