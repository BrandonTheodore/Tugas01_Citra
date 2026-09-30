function [out, lut] = histMatching(ch, target)
%HISTMATCHING Histogram specification/matching (implementasi sendiri).
%   out = HISTMATCHING(ch, target) mengubah distribusi intensitas kanal
%   ch agar histogramnya menyerupai histogram target.
%   target dapat berupa:
%     - citra/kanal referensi (matriks 2-D), atau
%     - vektor histogram target 256 elemen (mis. bentuk Gaussian).
%
%   Langkah (Gonzalez & Woods):
%     1. s = T(r) = CDF citra masukan           (equalization masukan)
%     2. v = G(z) = CDF histogram target        (equalization target)
%     3. z = G^-1(s): untuk setiap r cari z terkecil dengan G(z) >= T(r)

    if isvector(target) && numel(target) == 256
        hRef = double(target(:));       % histogram target langsung
    else
        hRef = computeHistogram(target);% histogram citra referensi
    end

    hSrc = computeHistogram(ch);

    cdfSrc = cumsum(hSrc) / sum(hSrc);
    cdfRef = cumsum(hRef) / sum(hRef);

    % Bangun LUT r -> z dengan pencarian invers CDF.
    lut = zeros(256, 1);
    for k = 1:256
        z = find(cdfRef >= cdfSrc(k) - 1e-12, 1, 'first');
        if isempty(z), z = 256; end
        lut(k) = z - 1;                 % kembali ke skala 0..255
    end

    idx = min(max(round(double(ch)), 0), 255) + 1;
    out = lut(idx);
end
