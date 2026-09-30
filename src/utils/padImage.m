function P = padImage(ch, pr, pc, mode)
%PADIMAGE Padding tepi satu kanal citra (pengganti padarray).
%   P = PADIMAGE(ch, pr, pc, mode) menambah pr baris di atas & bawah dan
%   pc kolom di kiri & kanan. mode: 'replicate' (default), 'symmetric',
%   atau 'zero'. Padding dibutuhkan agar operasi mask (konvolusi, median)
%   tetap terdefinisi pada piksel tepi.

    if nargin < 4, mode = 'replicate'; end
    [H, W] = size(ch);

    if strcmpi(mode, 'zero')
        P = zeros(H + 2*pr, W + 2*pc, 'like', ch);
        P(pr+1:pr+H, pc+1:pc+W) = ch;
        return;
    end

    r = (1 - pr):(H + pr);              % indeks baris "virtual"
    c = (1 - pc):(W + pc);              % indeks kolom "virtual"

    switch lower(mode)
        case 'replicate'
            % Indeks di luar citra di-clamp ke piksel tepi terdekat.
            r = min(max(r, 1), H);
            c = min(max(c, 1), W);
        case 'symmetric'
            % Pantulan cermin: ... 3 2 1 | 1 2 3 ... H | H H-1 ...
            r = mirrorIndex(r, H);
            c = mirrorIndex(c, W);
        otherwise
            error('padImage:mode', 'Mode padding tidak dikenal: %s', mode);
    end

    P = ch(r, c);
end

function idx = mirrorIndex(idx, n)
    period = 2 * n;
    idx = mod(idx - 1, period);         % 0..2n-1
    over = idx >= n;
    idx(over) = period - 1 - idx(over); % pantulkan paruh kedua
    idx = idx + 1;
end
