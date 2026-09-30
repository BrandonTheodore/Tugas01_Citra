function h = gaussianTargetHistogram(mu, sigma)
%GAUSSIANTARGETHISTOGRAM Histogram target berbentuk Gaussian (256 bin).
%   Dipakai pada histogram matching bila pengguna tidak memberikan citra
%   referensi. Distribusi Gaussian di sekitar mu memberi tampilan yang
%   lebih natural dibanding histogram datar hasil equalization.

    z = (0:255)';
    h = exp(-((z - mu) .^ 2) / (2 * sigma ^ 2));
    h = h / sum(h);
end
