function runAllDataset(datasetDir, outDir)
%RUNALLDATASET Memproses seluruh citra dataset dengan metode terpilih.
%   Hasil disimpan ke ./results/<folder>/:
%     <nama>_enhanced.png  citra hasil
%     <nama>_report.png    citra & histogram sebelum/sesudah
%   Folder "Histogram Citra" hanya divalidasi histogramnya.

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(root, 'src')));
    if nargin < 1 || isempty(datasetDir), datasetDir = fullfile(root, 'dataset'); end
    if nargin < 2 || isempty(outDir),     outDir     = fullfile(root, 'results'); end
    if ~isfolder(outDir), mkdir(outDir); end

    % validasi histogram
    hd = dir(fullfile(datasetDir, '*Histogram*'));
    if ~isempty(hd)
        folder = fullfile(datasetDir, hd(1).name);
        files = dir(fullfile(folder, '*.png'));
        for i = 1:numel(files)
            im = readImageUint8(fullfile(folder, files(i).name));
            lines = validateHistogram(im);
            fprintf('%s\n', files(i).name);
            fprintf('%s\n', lines{:});
        end
    end

    % enhancement
    P = datasetPresets();
    for i = 1:numel(P)
        inPath = fullfile(datasetDir, P(i).folder, P(i).file);
        if ~isfile(inPath), continue; end
        sub = fullfile(outDir, P(i).folder);
        if ~isfolder(sub), mkdir(sub); end
        [~, n] = fileparts(P(i).file);

        im = readImageUint8(inPath);
        ref = [];
        if ~isempty(P(i).ref)
            ref = readImageUint8(fullfile(datasetDir, P(i).ref));
        end
        [out, logLines] = runPipeline(im, P(i).steps, ref);

        imwrite(out, fullfile(sub, [n '_enhanced.png']));
        exportComparisonFigure(im, out, fullfile(sub, [n '_report.png']), ...
            [P(i).folder ' / ' P(i).file], strjoin(logLines, newline));

        a = imageStats(im);
        b = imageStats(out);
        fprintf('%s/%s: mean %.1f -> %.1f, std %.1f -> %.1f, entropy %.2f -> %.2f\n', ...
            P(i).folder, P(i).file, a.mean, b.mean, a.std, b.std, a.entropy, b.entropy);
    end
    fprintf('Selesai, hasil di %s\n', outDir);
end
