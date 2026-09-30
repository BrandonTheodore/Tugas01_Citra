function [Y, Cb, Cr] = rgbToYcc(img)
%RGBTOYCC Konversi RGB uint8 ke YCbCr (ITU-R BT.601, full range, double).
%   Kanal Y (luminansi) dipakai untuk memproses kecerahan/kontras tanpa
%   menggeser warna (hue) citra. Cb dan Cr disimpan untuk rekonstruksi.

    R = double(img(:, :, 1));
    G = double(img(:, :, 2));
    B = double(img(:, :, 3));

    Y  =       0.299    * R + 0.587    * G + 0.114    * B;
    Cb = 128 - 0.168736 * R - 0.331264 * G + 0.5      * B;
    Cr = 128 + 0.5      * R - 0.418688 * G - 0.081312 * B;
end
