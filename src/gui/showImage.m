function showImage(ax, img, titleStr)
%SHOWIMAGE Menampilkan citra uint8 (gray/RGB) pada axes tanpa imshow.
    cla(ax);
    if isempty(img)
        title(ax, titleStr);
        return;
    end
    if ndims(img) == 2
        img = repmat(img, 1, 1, 3);     % tampilkan grayscale sebagai truecolor
    end
    image(ax, img);
    axis(ax, 'image');
    ax.XTick = [];
    ax.YTick = [];
    title(ax, titleStr, 'Interpreter', 'none');
end
