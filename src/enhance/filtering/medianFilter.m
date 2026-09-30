function out = medianFilter(ch, n)
%MEDIANFILTER Median filter n x n (filter non-linear, implementasi sendiri).
%   Setiap piksel diganti median dari n x n tetangganya. Efektif untuk
%   noise impuls (salt-and-pepper) karena nilai ekstrem 0/255 tidak
%   pernah menjadi median selama jumlahnya < setengah jendela, sementara
%   tepi objek lebih terjaga dibanding mean filter.

    if nargin < 2 || isempty(n), n = 3; end
    out = localOrderStats(ch, n);
end
