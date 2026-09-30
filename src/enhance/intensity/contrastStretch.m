function [out, rMin, rMax] = contrastStretch(ch, lowPct, highPct, outLow, outHigh)
%CONTRASTSTRETCH Peregangan kontras linear berbasis persentil histogram.
%   Batas bawah rMin dan batas atas rMax dicari dari histogram kumulatif
%   (fungsi computeHistogram buatan sendiri) sehingga lowPct% piksel
%   tergelap dan (100-highPct)% piksel terterang diabaikan (menghindari
%   pengaruh outlier/noise). Rentang [rMin,rMax] lalu dipetakan linear ke
%   [outLow,outHigh]:  s = (r - rMin) / (rMax - rMin) * (outHigh - outLow) + outLow

    if nargin < 2 || isempty(lowPct),  lowPct  = 1;   end
    if nargin < 3 || isempty(highPct), highPct = 99;  end
    if nargin < 4 || isempty(outLow),  outLow  = 0;   end
    if nargin < 5 || isempty(outHigh), outHigh = 255; end

    h   = computeHistogram(ch);
    cdf = cumsum(h) / sum(h);           % CDF ternormalisasi (0..1)

    % Level pertama yang CDF-nya mencapai persentil yang diminta.
    rMin = find(cdf >= lowPct  / 100, 1, 'first') - 1;
    rMax = find(cdf >= highPct / 100, 1, 'first') - 1;
    if isempty(rMin), rMin = 0;   end
    if isempty(rMax), rMax = 255; end

    if rMax <= rMin
        % Citra hampir konstan: tidak ada yang bisa diregangkan.
        out = double(ch);
        return;
    end

    r = double(ch);
    out = (r - rMin) / (rMax - rMin) * (outHigh - outLow) + outLow;
    out = min(max(out, min(outLow, outHigh)), max(outLow, outHigh));  % clip
end
