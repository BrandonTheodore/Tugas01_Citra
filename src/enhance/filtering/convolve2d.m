function out = convolve2d(ch, K, padMode)
%CONVOLVE2D Konvolusi 2-D dengan mask K (implementasi sendiri).
%   out = CONVOLVE2D(ch, K, padMode) menghitung
%       g(x,y) = sum_s sum_t K(s,t) * f(x - s, y - t)
%   dengan ukuran keluaran sama seperti masukan ('same'). Tepi citra
%   di-padding (default 'replicate') agar tidak muncul bingkai gelap.
%   Tidak memakai imfilter/conv2/filter2.
%
%   Implementasi tervektorisasi: alih-alih menggeser mask ke setiap
%   piksel, setiap koefisien mask dikalikan dengan "salinan tergeser"
%   dari seluruh citra lalu dijumlahkan. Hasilnya identik dengan definisi
%   namun cukup kh*kw iterasi.

    if nargin < 3 || isempty(padMode), padMode = 'replicate'; end

    f = double(ch);
    [H, W]   = size(f);
    [kh, kw] = size(K);
    if mod(kh, 2) == 0 || mod(kw, 2) == 0
        error('convolve2d:kernel', 'Ukuran mask harus ganjil.');
    end
    ph = (kh - 1) / 2;
    pw = (kw - 1) / 2;

    % Konvolusi = korelasi dengan mask yang diputar 180 derajat.
    Kr = rot90(double(K), 2);

    P   = padImage(f, ph, pw, padMode);
    out = zeros(H, W);
    for u = 1:kh
        for v = 1:kw
            w = Kr(u, v);
            if w ~= 0
                % Blok P(u:u+H-1, v:v+W-1) = tetangga pada offset (u,v)
                out = out + w * P(u:u+H-1, v:v+W-1);
            end
        end
    end
end
