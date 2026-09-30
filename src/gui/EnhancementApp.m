function fig = EnhancementApp(datasetDir)
%ENHANCEMENTAPP GUI perbaikan kualitas citra (Tugas 1 IF4073).
%   1. Pilih citra (dan citra referensi untuk histogram matching).
%   2. Pilih metode dan parameter, klik "Proses".
%   3. "Proses lagi" menerapkan metode berikutnya pada citra hasil
%      (untuk kombinasi beberapa metode). "Reset" kembali ke citra awal.

    if nargin < 1 || isempty(datasetDir)
        datasetDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'dataset');
    end

    catalog = methodCatalog();
    img = [];        % citra masukan
    ref = [];        % citra referensi
    result = [];     % citra hasil
    usedSteps = {};  % daftar metode yang sudah diterapkan
    lastDir = datasetDir;

    fig = uifigure('Name', 'Tugas 1 IF4073 - Image Enhancement', 'Position', [60 60 1200 720]);
    g = uigridlayout(fig, [1 2]);
    g.ColumnWidth = {250, '1x'};

    % ---------------- panel kiri: kontrol ----------------
    left = uigridlayout(g, [19 1]);
    left.RowHeight = {26, 18, 26, 18, 10, 18, 22, 18, 22, 18, 22, 18, 22, 18, 22, 26, 26, 26, '1x'};
    left.RowSpacing = 4;
    left.Padding = [4 4 4 4];

    uibutton(left, 'Text', 'Pilih Citra...', 'ButtonPushedFcn', @(~, ~) onOpen());
    lblImg = uilabel(left, 'Text', '-');
    uibutton(left, 'Text', 'Pilih Citra Referensi...', 'ButtonPushedFcn', @(~, ~) onOpenRef());
    lblRef = uilabel(left, 'Text', 'Referensi: -');
    uilabel(left, 'Text', '');

    uilabel(left, 'Text', 'Metode:');
    ddMethod = uidropdown(left, 'Items', {catalog.label}, 'ItemsData', {catalog.id}, ...
        'ValueChangedFcn', @(~, ~) onMethodChanged());
    uilabel(left, 'Text', 'Mode warna:');
    ddColor = uidropdown(left, 'Items', {'Auto', 'Luminansi', 'Per kanal RGB'}, ...
        'ItemsData', {'auto', 'ratio', 'rgb'});

    paramLbl = gobjects(3, 1);
    paramFld = gobjects(3, 1);
    for k = 1:3
        paramLbl(k) = uilabel(left, 'Text', '');
        paramFld(k) = uieditfield(left, 'numeric');
    end

    uibutton(left, 'Text', 'Proses', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~, ~) onProcess(false));
    uibutton(left, 'Text', 'Proses lagi (pada hasil)', 'ButtonPushedFcn', @(~, ~) onProcess(true));
    gb = uigridlayout(left, [1 3]);
    gb.Padding = [0 0 0 0];
    gb.ColumnSpacing = 4;
    uibutton(gb, 'Text', 'Reset', 'ButtonPushedFcn', @(~, ~) onReset());
    uibutton(gb, 'Text', 'Simpan', 'ButtonPushedFcn', @(~, ~) onSave());
    uibutton(gb, 'Text', 'Cek Hist.', 'Tooltip', 'Bandingkan histogram buatan sendiri dengan imhist/histcounts', ...
        'ButtonPushedFcn', @(~, ~) onCheckHist());
    txtSteps = uitextarea(left, 'Editable', 'off', 'Value', {'Metode yang dipakai:'});

    % ---------------- panel kanan: tampilan ----------------
    right = uigridlayout(g, [3 2]);
    right.RowHeight = {'1.3x', '1x', 110};
    axIn  = uiaxes(right);
    axOut = uiaxes(right);
    [axHIn, gHIn]   = histPanel(right, 'Histogram Sebelum');
    [axHOut, gHOut] = histPanel(right, 'Histogram Sesudah');
    tbl = uitable(right, 'ColumnName', {'', 'Min', 'Max', 'Mean', 'Std', 'Entropy'}, 'RowName', {});
    tbl.Layout.Column = [1 2];

    showImage(axIn, [], 'Citra Masukan');
    showImage(axOut, [], 'Citra Hasil');
    plotHistogramPanel(axHIn, gHIn, [], '');
    plotHistogramPanel(axHOut, gHOut, [], '');
    onMethodChanged();

    % ======================= callback =======================
    function onOpen()
        [f, p] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Citra'}, 'Pilih citra', lastDir);
        figure(fig);
        if isequal(f, 0), return; end
        lastDir = p;
        img = readImageUint8(fullfile(p, f));
        lblImg.Text = f;
        showImage(axIn, img, 'Citra Masukan');
        plotHistogramPanel(axHIn, gHIn, img, 'Sebelum');
        onReset();
    end

    function onOpenRef()
        [f, p] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Citra'}, 'Pilih citra referensi', lastDir);
        figure(fig);
        if isequal(f, 0), return; end
        ref = readImageUint8(fullfile(p, f));
        lblRef.Text = ['Referensi: ' f];
    end

    function onMethodChanged()
        m = catalog(strcmp({catalog.id}, ddMethod.Value));
        for i = 1:3
            if i <= numel(m.params)
                paramLbl(i).Text = m.params{i};
                paramFld(i).Value = m.defaults(i);
                paramLbl(i).Visible = 'on';
                paramFld(i).Visible = 'on';
            else
                paramLbl(i).Visible = 'off';
                paramFld(i).Visible = 'off';
            end
        end
    end

    function onProcess(chain)
        if isempty(img)
            uialert(fig, 'Pilih citra terlebih dahulu.', 'Info');
            return;
        end
        m = catalog(strcmp({catalog.id}, ddMethod.Value));
        params = m.defaults;
        for i = 1:min(3, numel(params))
            params(i) = paramFld(i).Value;
        end
        step = makeStep(m.id, params, ddColor.Value);

        src = img;
        if chain && ~isempty(result)
            src = result;
        else
            usedSteps = {};
        end

        try
            [out, info] = applyStep(src, step, ref);
        catch err
            uialert(fig, err.message, 'Error');
            return;
        end
        result = out;
        usedSteps{end+1} = sprintf('%d. %s', numel(usedSteps) + 1, info);

        showImage(axOut, result, 'Citra Hasil');
        plotHistogramPanel(axHOut, gHOut, result, 'Sesudah');
        txtSteps.Value = [{'Metode yang dipakai:'}, usedSteps];
        updateTable();
    end

    function onReset()
        result = [];
        usedSteps = {};
        showImage(axOut, [], 'Citra Hasil');
        plotHistogramPanel(axHOut, gHOut, [], '');
        txtSteps.Value = {'Metode yang dipakai:'};
        updateTable();
    end

    function onSave()
        if isempty(result), return; end
        [f, p] = uiputfile('*.png', 'Simpan hasil', 'hasil.png');
        figure(fig);
        if isequal(f, 0), return; end
        imwrite(result, fullfile(p, f));
    end

    function onCheckHist()
        if isempty(img), return; end
        [lines, hOwn, hRef, method] = validateHistogram(img);
        showHistValidation(lblImg.Text, hOwn, hRef, method, lines);
    end

    function updateTable()
        data = {};
        if ~isempty(img)
            data = [data; statRow('Sebelum', imageStats(img))];
        end
        if ~isempty(result)
            data = [data; statRow('Sesudah', imageStats(result))];
        end
        tbl.Data = data;
    end
end

% ======================= fungsi bantu =======================
function [axs, g] = histPanel(parent, titleStr)
    p = uipanel(parent, 'Title', titleStr);
    g = uigridlayout(p, [3 1]);
    g.Padding = [2 2 2 2];
    g.RowSpacing = 2;
    axs = gobjects(3, 1);
    for k = 1:3
        axs(k) = uiaxes(g);
    end
end

function showHistValidation(name, hOwn, hRef, method, lines)
% Jendela validasi: histogram buatan sendiri (kiri) vs pembanding (kanan)
% untuk setiap kanal, ditambah ringkasan hasil perbandingan di bawah.
    nC = size(hOwn, 2);
    if nC == 3
        names = {'R', 'G', 'B'};
        cols = [0.85 0.15 0.15; 0.15 0.65 0.15; 0.15 0.3 0.85];
    else
        names = {'Gray'};
        cols = [0.3 0.3 0.3];
    end

    f = uifigure('Name', ['Validasi Histogram - ' name], 'Position', [120 80 900 150 + 200 * nC]);
    g = uigridlayout(f, [nC + 1, 2]);
    g.RowHeight = [repmat({'1x'}, 1, nC), {90}];

    for c = 1:nC
        ax1 = uiaxes(g);
        bar(ax1, 0:255, hOwn(:, c), 1, 'FaceColor', cols(c, :), 'EdgeColor', 'none');
        xlim(ax1, [-1 256]);
        title(ax1, ['computeHistogram - kanal ' names{c}]);

        ax2 = uiaxes(g);
        bar(ax2, 0:255, hRef(:, c), 1, 'FaceColor', cols(c, :), 'EdgeColor', 'none');
        xlim(ax2, [-1 256]);
        title(ax2, [method ' - kanal ' names{c}]);
    end

    txt = uitextarea(g, 'Editable', 'off', 'FontName', 'Consolas', 'Value', lines);
    txt.Layout.Column = [1 2];
end

function row = statRow(name, S)
    row = {name, S.min, S.max, round(S.mean, 2), round(S.std, 2), round(S.entropy, 3)};
end
