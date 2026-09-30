function out = gammaTransform(ch, gamma, c)
%GAMMATRANSFORM Transformasi power-law s = c * r^gamma (r ternormalisasi).
%   gamma < 1 -> mencerahkan citra gelap (area gelap diregangkan)
%   gamma > 1 -> menggelapkan citra terlalu terang / pudar
%   c adalah faktor skala (default 1).

    if nargin < 3 || isempty(c), c = 1; end
    if gamma <= 0
        error('gammaTransform:gamma', 'Gamma harus > 0.');
    end

    r = double(ch) / 255;               % normalisasi ke [0,1]
    s = c * r .^ gamma;                 % power-law
    out = s * 255;                      % kembali ke skala [0,255]
end
