function img = yccToRgb(Y, Cb, Cr)
%YCCTORGB Konversi balik YCbCr (BT.601 full range) ke RGB uint8.

    R = Y + 1.402    * (Cr - 128);
    G = Y - 0.344136 * (Cb - 128) - 0.714136 * (Cr - 128);
    B = Y + 1.772    * (Cb - 128);

    img = uint8(min(max(round(cat(3, R, G, B)), 0), 255));
end
