function S = imageStats(img)
%IMAGESTATS Statistik sederhana citra: min, max, mean, std, entropy.
%   Untuk citra RGB dihitung dari luminansi Y. Semua dihitung dari
%   histogram (computeHistogram).

    if ndims(img) == 3
        f = rgbToYcc(img);
    else
        f = double(img);
    end

    h = computeHistogram(f);
    p = h / sum(h);
    r = (0:255)';

    S.min  = find(h > 0, 1, 'first') - 1;
    S.max  = find(h > 0, 1, 'last') - 1;
    S.mean = sum(r .* p);
    S.std  = sqrt(sum((r - S.mean) .^ 2 .* p));
    nz = p(p > 0);
    S.entropy = -sum(nz .* log2(nz));
end
