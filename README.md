# Tugas 1 IF4073 - Image Enhancement

Program GUI MATLAB untuk perbaikan kualitas citra. Program menampilkan citra masukan dan hasil beserta histogramnya (per kanal R, G, B untuk citra berwarna) dan statistik sederhana (min, max, mean, std, entropy).

Metode yang tersedia:
- Intensity Transformation: negatif, log, gamma, contrast stretching
- Histogram Equalization
- Histogram Matching (dengan citra referensi, atau target Gaussian jika tidak ada referensi)
- Filtering: mean, Gaussian, median, Laplacian sharpening, unsharp masking

Fungsi histogram (`computeHistogram`) dan semua metode di atas dibuat sendiri. Fungsi bawaan seperti `imhist` hanya dipakai untuk pembanding.

## Dependensi

- MATLAB R2021a atau lebih baru
- Image Processing Toolbox (opsional, hanya untuk pembanding)

## Cara Menjalankan

```matlab
main
```

1. Klik **Pilih Citra...** dan pilih citra dari folder `dataset`.
2. Pilih metode, mode warna, dan parameter.
3. Klik **Proses**. Untuk kombinasi metode, pilih metode berikutnya lalu klik **Proses lagi (pada hasil)**.
4. Untuk histogram matching, pilih citra referensi terlebih dahulu.
5. **Simpan** menyimpan citra hasil, **Cek Hist.** membandingkan histogram buatan sendiri dengan `imhist`/`histcounts`.

Memproses seluruh dataset sekaligus (hasil ke folder `results`):

```matlab
addpath scripts
runAllDataset
```

## Metode per Citra

| Citra | Metode |
|---|---|
| Kasus 1 / 01 | HE |
| Kasus 1 / 02 | HE |
| Kasus 1 / 03 | HE (RGB) |
| Kasus 1 / 04 | HE |
| Kasus 2 / 01 | contrast stretching |
| Kasus 2 / 02 | contrast stretching |
| Kasus 2 / 03 | histogram matching ke Kasus 1/03 |
| Kasus 2 / 04 | histogram matching ke Gaussian (120, 60) |
| Kasus 3 / 01 | contrast stretching |
| Kasus 3 / 02 | contrast stretching |
| Kasus 3 / 03 | contrast stretching + gamma 1.3 |
| Kasus 3 / 04 | contrast stretching + gamma 0.8 |
| Kasus 4 / 01 | median 3x3 |
| Kasus 4 / 02 | median 3x3 per kanal RGB |
| Kasus 4 / 03 | median 3x3 + Gaussian 5x5 + contrast stretching |
| Kasus 4 / 04 | unsharp masking + contrast stretching |

## Anggota Kelompok

| NIM | Nama |
|---|---|
| 18223132 | Muhammad Rafly Fauzan     |
| 18223020 | Brandon Theodore Ferrinov |
