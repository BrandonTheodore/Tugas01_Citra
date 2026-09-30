function out = unsharpMask(ch, n, sigma, k)
%UNSHARPMASK Unsharp masking / high-boost filtering.
%   1. f_blur = f * Gaussian(n, sigma)       (low-pass dengan konvolusi)
%   2. g_mask = f - f_blur                   (komponen detail/tepi)
%   3. g      = f + k * g_mask
%   k = 1 -> unsharp masking, k > 1 -> high-boost filtering.
%   Menajamkan citra blur tanpa terlalu menguatkan noise seperti
%   Laplacian murni karena detail diambil dari selisih terhadap versi
%   yang sudah dihaluskan.

    if nargin < 2 || isempty(n),     n = 5;     end
    if nargin < 3 || isempty(sigma), sigma = 1; end
    if nargin < 4 || isempty(k),     k = 1;     end

    f     = double(ch);
    fBlur = convolve2d(f, makeKernel('gaussian', n, sigma));
    out   = f + k * (f - fBlur);
end
