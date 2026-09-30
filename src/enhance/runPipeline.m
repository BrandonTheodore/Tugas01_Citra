function [out, logLines] = runPipeline(img, steps, ref, useBuiltin)
%RUNPIPELINE Menjalankan kombinasi beberapa langkah enhancement berurutan.
%   steps adalah array struct (id, params, colorMode). Keluaran setiap
%   langkah menjadi masukan langkah berikutnya, misalnya
%   median filter -> contrast stretching -> unsharp masking.
%   logLines berisi deskripsi tiap langkah (metode + parameter).

    if nargin < 3, ref = []; end
    if nargin < 4, useBuiltin = false; end

    out = img;
    logLines = cell(numel(steps), 1);
    for i = 1:numel(steps)
        [out, info] = applyStep(out, steps(i), ref, useBuiltin);
        logLines{i} = sprintf('%d. %s', i, info);
    end
end
