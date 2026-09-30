function out = negativeTransform(ch)
%NEGATIVETRANSFORM Transformasi negatif s = (L-1) - r, L = 256.
%   Berguna untuk menonjolkan detail terang pada area gelap yang dominan.
    out = 255 - double(ch);
end
