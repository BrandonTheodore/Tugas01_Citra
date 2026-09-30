function [out, lut] = histEqualization(ch)
%HISTEQUALIZATION Histogram equalization global (implementasi sendiri).
%   Transformasi s_k = T(r_k) = (L-1) * sum_{j=0..k} p_r(r_j), yaitu CDF
%   histogram yang diskalakan ke [0,255]. Di sini dipakai bentuk yang
%   dinormalisasi terhadap CDF minimum agar level tergelap yang muncul
%   dipetakan ke 0 dan histogram hasil menyebar ke seluruh rentang:
%       s_k = round( (cdf(k) - cdf_min) / (1 - cdf_min) * 255 )
%
%   lut (256x1) adalah fungsi pemetaan r -> s (berguna untuk laporan).

    h   = computeHistogram(ch);         % histogram buatan sendiri
    N   = sum(h);                       % jumlah piksel
    cdf = cumsum(h) / N;                % CDF ternormalisasi (0..1)

    % CDF minimum = CDF pada level intensitas pertama yang muncul.
    cdfMin = cdf(find(h > 0, 1, 'first'));

    if cdfMin >= 1
        % Semua piksel bernilai sama -> tidak ada yang bisa diratakan.
        out = double(ch);
        lut = (0:255)';
        return;
    end

    lut = round((cdf - cdfMin) / (1 - cdfMin) * 255);
    lut = min(max(lut, 0), 255);

    % Terapkan LUT: setiap piksel bernilai r diganti lut(r+1).
    idx = min(max(round(double(ch)), 0), 255) + 1;
    out = lut(idx);
end
