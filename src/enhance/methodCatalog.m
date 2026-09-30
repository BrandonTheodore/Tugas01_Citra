function M = methodCatalog()
%METHODCATALOG Daftar metode enhancement yang tersedia di program.
%   Hanya metode dasar/umum dari keempat kelompok teknik yang diizinkan.
%   Setiap entri berisi:
%     id        : kunci internal metode
%     label     : nama yang ditampilkan di GUI
%     group     : kelompok teknik
%     params    : nama parameter (maks. 4) yang dapat diubah di GUI
%     defaults  : nilai default parameter
%     colorMode : mode warna default bila pengguna memilih 'auto'
%     needsRef  : true jika metode dapat memakai citra referensi

    IT = 'Intensity Transformation';
    HE = 'Histogram Equalization';
    HM = 'Histogram Specification/Matching';
    FL = 'Image Filtering (Masking)';

    M = [ ...
      entry('negative',  'Negatif (inverse)',               IT, {},                                              [],           'ratio', false)
      entry('log',       'Log transform',                   IT, {'c (0 = otomatis)'},                            0,            'ratio', false)
      entry('gamma',     'Power-law (gamma)',               IT, {'gamma', 'c'},                                  [0.6 1],      'ratio', false)
      entry('stretch',   'Contrast stretching',             IT, {'persentil bawah (%)', 'persentil atas (%)', 'output min', 'output max'}, [1 99 0 255], 'ratio', false)
      entry('histeq',    'Histogram equalization',          HE, {},                                              [],           'ratio', false)
      entry('histmatch', 'Histogram matching',              HM, {'target mean (tanpa ref)', 'target sigma (tanpa ref)'}, [128 55], 'ratio', true)
      entry('mean',      'Mean filter',                     FL, {'ukuran mask'},                                 3,            'rgb',   false)
      entry('gaussian',  'Gaussian filter',                 FL, {'ukuran mask', 'sigma'},                        [5 1],        'rgb',   false)
      entry('median',    'Median filter',                   FL, {'ukuran jendela'},                              3,            'rgb',   false)
      entry('laplacian', 'Laplacian sharpening',            FL, {'alpha', 'tetangga (4/8)'},                     [1 4],        'ycc',   false)
      entry('unsharp',   'Unsharp masking / high-boost',    FL, {'ukuran mask', 'sigma', 'k (>1 = high-boost)'}, [5 1 1],      'ycc',   false)
    ];
end

function e = entry(id, label, group, params, defaults, colorMode, needsRef)
    e = struct('id', id, 'label', label, 'group', group, ...
        'params', {params}, 'defaults', defaults, ...
        'colorMode', colorMode, 'needsRef', needsRef);
end
