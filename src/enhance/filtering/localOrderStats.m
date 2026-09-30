function [zMed, zMin, zMax] = localOrderStats(ch, n)
%LOCALORDERSTATS Median, minimum, dan maksimum lokal pada jendela n x n.
%   Dasar untuk median filter (filter non-linear / order-statistic) dan
%   deteksi noise impuls. Tidak memakai medfilt2/ordfilt2.
%
%   Untuk setiap piksel, n^2 tetangganya disusun menjadi "tumpukan" pada
%   dimensi ke-3, lalu median/min/max diambil sepanjang dimensi tersebut.
%   Pemrosesan dilakukan per blok baris agar kebutuhan memori terkendali
%   untuk citra besar.

    if mod(n, 2) == 0, n = n + 1; end
    f = single(ch);
    [H, W] = size(f);
    r = (n - 1) / 2;
    P = padImage(f, r, r, 'symmetric');

    zMed = zeros(H, W, 'single');
    wantMinMax = nargout > 1;
    if wantMinMax
        zMin = zeros(H, W, 'single');
        zMax = zeros(H, W, 'single');
    end

    % Jumlah baris per blok: batasi ukuran tumpukan ~ 2e7 elemen.
    blockRows = max(1, floor(2e7 / (W * n * n)));

    for r0 = 1:blockRows:H
        r1 = min(r0 + blockRows - 1, H);
        nb = r1 - r0 + 1;
        stack = zeros(nb, W, n * n, 'single');
        k = 0;
        for u = 1:n
            for v = 1:n
                k = k + 1;
                % Tetangga pada offset (u - r - 1, v - r - 1)
                stack(:, :, k) = P(r0 + u - 1 : r1 + u - 1, v : v + W - 1);
            end
        end
        zMed(r0:r1, :) = median(stack, 3);
        if wantMinMax
            zMin(r0:r1, :) = min(stack, [], 3);
            zMax(r0:r1, :) = max(stack, [], 3);
        end
    end

    zMed = double(zMed);
    if wantMinMax
        zMin = double(zMin);
        zMax = double(zMax);
    end
end
