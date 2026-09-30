function out = laplacianSharpen(ch, alpha, neighbors)
%LAPLACIANSHARPEN Penajaman dengan Laplacian: g = f - alpha * lap(f).
%   Mask Laplacian memiliki koefisien pusat negatif, sehingga detail
%   (tepi) ditambahkan dengan mengurangkan hasil Laplacian dari citra.
%   alpha mengatur kekuatan penajaman; neighbors = 4 atau 8.

    if nargin < 2 || isempty(alpha),     alpha = 1;     end
    if nargin < 3 || isempty(neighbors), neighbors = 4; end

    f   = double(ch);
    lap = convolve2d(f, makeKernel('laplacian', neighbors));
    out = f - alpha * lap;
end
