function exportComparisonFigure(imgIn, imgOut, outFile, titleStr, methodStr)
%EXPORTCOMPARISONFIGURE Figur sebelum/sesudah + histogram untuk laporan.
%   Baris 1: citra masukan & hasil. Baris 2..: histogram (per kanal R,G,B
%   untuk citra berwarna). Figur disimpan sebagai PNG ke outFile.

    if nargin < 5, methodStr = ''; end
    isColor = ndims(imgIn) == 3;
    nH = 1 + 2 * isColor;               % jumlah baris histogram

    f = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1100 420 + 170 * nH]);
    t = tiledlayout(f, 1 + nH, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, titleStr, 'Interpreter', 'none', 'FontWeight', 'bold');
    if ~isempty(methodStr)
        subtitle(t, methodStr, 'Interpreter', 'none', 'FontSize', 9);
    end

    imgs = {imgIn, imgOut};
    caps = {'Sebelum', 'Sesudah'};
    for j = 1:2
        ax = nexttile(t, j);
        showImage(ax, imgs{j}, caps{j});
    end

    cols  = [0.85 0.15 0.15; 0.15 0.65 0.15; 0.15 0.3 0.85];
    names = {'R', 'G', 'B'};
    for r = 1:nH
        for j = 1:2
            ax = nexttile(t, 2 * r + j);
            if isColor
                h = computeHistogram(imgs{j}(:, :, r));
                c = cols(r, :);
                lbl = sprintf('Histogram %s - kanal %s', caps{j}, names{r});
            else
                h = computeHistogram(imgs{j});
                c = [0.3 0.3 0.3];
                lbl = sprintf('Histogram %s', caps{j});
            end
            bar(ax, 0:255, h, 1, 'FaceColor', c, 'EdgeColor', 'none');
            xlim(ax, [-1 256]);
            title(ax, lbl, 'FontWeight', 'normal', 'FontSize', 9);
        end
    end

    exportgraphics(f, outFile, 'Resolution', 110);
    close(f);
end
