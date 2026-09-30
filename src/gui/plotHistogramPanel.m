function plotHistogramPanel(axs, grid, img, titleStr)
%PLOTHISTOGRAMPANEL Menampilkan histogram citra pada 3 axes vertikal.
%   Citra grayscale -> 1 histogram (axes lain disembunyikan).
%   Citra RGB       -> histogram terpisah untuk kanal R, G, dan B.
%   Histogram dihitung dengan computeHistogram (implementasi sendiri).

    for k = 1:3
        cla(axs(k));
    end
    if isempty(img)
        grid.RowHeight = {'1x', 0, 0};
        title(axs(1), titleStr);
        return;
    end

    if ndims(img) == 3
        grid.RowHeight = {'1x', '1x', '1x'};
        cols  = [0.85 0.15 0.15; 0.15 0.65 0.15; 0.15 0.3 0.85];
        names = {'R', 'G', 'B'};
        for k = 1:3
            h = computeHistogram(img(:, :, k));
            drawBars(axs(k), h, cols(k, :));
            title(axs(k), sprintf('%s - kanal %s', titleStr, names{k}), 'FontWeight', 'normal');
        end
    else
        grid.RowHeight = {'1x', 0, 0};
        h = computeHistogram(img);
        drawBars(axs(1), h, [0.3 0.3 0.3]);
        title(axs(1), sprintf('%s - grayscale', titleStr), 'FontWeight', 'normal');
    end
end

function drawBars(ax, h, col)
    bar(ax, 0:255, h, 1, 'FaceColor', col, 'EdgeColor', 'none');
    xlim(ax, [-1 256]);
    ylim(ax, [0 max(max(h) * 1.05, 1)]);
    ax.XTick = 0:32:256;
    ax.FontSize = 8;
    ax.YAxis.Exponent = 0;
    grid(ax, 'on');
end
