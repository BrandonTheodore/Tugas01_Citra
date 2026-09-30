function h = computeHistogram(channel)
%COMPUTEHISTOGRAM Histogram 256 tingkat keabuan (implementasi sendiri).
%   h = COMPUTEHISTOGRAM(channel) menghitung jumlah piksel untuk setiap
%   tingkat intensitas 0..255 dari satu kanal citra. Keluaran berupa
%   vektor kolom 256x1, dengan h(k+1) = banyaknya piksel bernilai k.
%
%   Fungsi ini TIDAK memakai imhist/hist/histcounts. Seluruh bagian
%   program yang membutuhkan histogram (analisis, equalization,
%   matching, contrast stretching, entropy) memanggil fungsi ini.
%
%   Masukan boleh bertipe uint8, integer lain, logical, maupun double.
%   Nilai non-integer dibulatkan dan nilai di luar [0,255] di-clamp.

    if ndims(channel) > 2 %#ok<ISMAT>
        error('computeHistogram:notSingleChannel', ...
            'Masukan harus satu kanal (2-D). Untuk RGB panggil per kanal.');
    end

    % Ubah ke double lalu bulatkan agar setiap piksel tepat jatuh ke
    % salah satu dari 256 bin.
    v = round(double(channel(:)));

    % Clamp ke rentang valid sehingga indeks bin selalu 1..256.
    v(v < 0)   = 0;
    v(v > 255) = 255;

    % Indeks bin MATLAB dimulai dari 1, sehingga intensitas k -> bin k+1.
    idx = v + 1;

    % Penghitungan frekuensi: accumarray menambahkan nilai 1 ke bin
    % idx(i) untuk setiap piksel i. Ini setara dengan loop
    %   for i = 1:numel(idx), h(idx(i)) = h(idx(i)) + 1; end
    % tetapi jauh lebih cepat karena tervektorisasi.
    h = accumarray(idx, 1, [256 1]);
end
