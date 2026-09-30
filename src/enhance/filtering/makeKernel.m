function K = makeKernel(type, varargin)
%MAKEKERNEL Membuat mask filter spasial (pengganti fspecial).
%   K = MAKEKERNEL('mean', n)             rata-rata n x n
%   K = MAKEKERNEL('gaussian', n, sigma)  Gaussian n x n ternormalisasi
%   K = MAKEKERNEL('laplacian', nb)       Laplacian 4- atau 8-tetangga
%   K = MAKEKERNEL('highboost', n, A)     mask high-boost n x n (A >= 1)

    switch lower(type)
        case 'mean'
            n = oddSize(varargin{1});
            K = ones(n) / n^2;

        case 'gaussian'
            n = oddSize(varargin{1});
            sigma = varargin{2};
            r = (n - 1) / 2;
            [x, y] = meshgrid(-r:r, -r:r);
            K = exp(-(x.^2 + y.^2) / (2 * sigma^2));
            K = K / sum(K(:));          % jumlah bobot = 1 (kecerahan tetap)

        case 'laplacian'
            nb = 4;
            if ~isempty(varargin), nb = varargin{1}; end
            if nb == 8
                K = [1 1 1; 1 -8 1; 1 1 1];
            else
                K = [0 1 0; 1 -4 1; 0 1 0];
            end

        case 'highboost'
            n = oddSize(varargin{1});
            A = varargin{2};
            % A*delta - mean = (A-1)*delta + (delta - mean)
            K = -ones(n) / n^2;
            c = (n + 1) / 2;
            K(c, c) = K(c, c) + A;

        otherwise
            error('makeKernel:type', 'Tipe kernel tidak dikenal: %s', type);
    end
end

function n = oddSize(n)
    n = max(1, round(n));
    if mod(n, 2) == 0, n = n + 1; end
end
