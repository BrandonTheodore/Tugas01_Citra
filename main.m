function main(datasetDir)
%MAIN Titik masuk program Tugas 1 IF4073 - Analisis & Perbaikan Kualitas Citra.
%   main            -> membuka GUI dengan dataset di ./dataset
%   main(folder)    -> membuka GUI dengan folder dataset lain

    root = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(root, 'src')));

    if nargin < 1 || isempty(datasetDir)
        datasetDir = fullfile(root, 'dataset');
    end
    EnhancementApp(datasetDir);
end
