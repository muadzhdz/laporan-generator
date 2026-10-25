# HASIL DAN PEMBAHASAN

## Struktur Berkas dan Implementasi Sistem

Implementasi pipeline **Laporan Generator** menghasilkan struktur direktori yang modular dan terorganisasi secara sistematis:

```
laporan-generator/
|-- laporan                  # CLI Helper terpadu (build, init, preset, check, test)
|-- build.sh                 # Skrip build utama PDF (Typst engine)
|-- Makefile                 # Target otomasi (build, docx, html, watch, view, clean)
|-- template.typ             # Template visual Typst (font, margin, heading)
|-- docx.lua                 # Filter Lua penomoran bab & sampul DOCX
|-- reference.docx           # Template gaya Microsoft Word (A4, TNR 12pt)
|-- metadata.yml             # Konfigurasi judul, penulis, dosen, institusi, preset
|-- references.bib           # Basis data daftar pustaka (format BibTeX)
|-- apa.csl                  # Aturan sitasi standar APA Edisi ke-7
|-- cover.md                 # Kata pengantar & outline front matter
|-- chapters/                # Konten laporan modular (BAB I s/d BAB V)
|-- presets/                 # Konfigurasi format kampus (UI, ITB, UGM, ITS, Standard)
|-- scripts/                 # Utilitas Python (scan-preset, validate, docx-pagenum)
|-- flake.nix / flake.lock   # Lingkungan hermetik Nix Flake
|-- Dockerfile               # Kontainer build multi-arsitektur (amd64 / arm64)
|-- docker-compose.yml       # Orkestrasi kontainer Docker dengan pemetaan user
|-- prompt.md                # Panduan instruksi agen AI (OpenCode, Claude, Antigravity)
\-- test.sh                  # Suite pengujian otomatis (78 assertions)
```

## Evaluasi Hasil Keluaran Dokumen PDF (Typst Engine)

Kompilasi dokumen PDF menggunakan Typst menghasilkan dokumen akademik dengan kualitas tipografi tingkat tinggi. Beberapa pencapaian visual utama meliputi:

1. **Struktur Penomoran Bab Dua Baris** --- Sesuai dengan pedoman penulisan karya ilmiah di Indonesia, judul bab level 1 dirender dalam dua baris simetris: baris pertama berisi prefix angka Romawi tebal (contoh: `BAB I`), dan baris kedua berisi nama judul bab dalam huruf kapital tebal 14pt (contoh: `PENDAHULUAN`).
2. **Kerapian Spasi dan Indentasi Paragraf** --- Teks isi menggunakan font Libertinus Serif 12pt dengan spasi baris 1.5 (`leading: 0.75em`) dan perataan rata kanan-kiri (*justified*). Baris pertama setiap alinea diindentasi secara presisi sebesar 1.25 cm.
3. **Penyusunan Tabel dan Gambar yang Bersih** --- Seluruh gambar diposisikan di tengah halaman dengan keterangan caption di bagian bawah. Tabel akademik bergaris tipis 0.5pt abu-abu tanpa border vertikal berlebih.
4. **Sitasi Otomatis Format APA** --- Seluruh pengutipan dalam teks seperti `(Mädje & Haug, 2024)` secara otomatis ditautkan ke bagian DAFTAR PUSTAKA di akhir dokumen dengan penataan *hanging indent* 1.25 cm.

## Evaluasi Hasil Keluaran Dokumen Word (DOCX Multi-Pass)

Dokumen Microsoft Word (`Laporan.docx`) yang dihasilkan melalui proses multi-pass berhasil memenuhi persyaratan format formal:

1. **Pemisahan Seksi dan Penomoran Halaman** --- Sampul depan tampil bersih tanpa nomor halaman. Bagian KATA PENGANTAR dan DAFTAR ISI memiliki penomoran angka Romawi kecil (*i, ii*). Pada awal BAB I, penomoran halaman berhasil dimulai ulang (*restart*) dari angka Arab 1 (*1, 2, 3...*).
2. **Daftar Isi Otomatis Terhubung (Hyperlinked TOC)** --- Entri Daftar Isi dihubungkan dengan *hyperlink internal* dan menampilkan nomor halaman aktual secara presisi berkat proses injeksi nilai cache oleh `docx-pagenum.py`.
3. **Konsistensi Gaya dan Font** --- Dokumen Word menggunakan font Times New Roman berukuran 12pt pada teks normal dan 14pt tebal pada Heading 1, memastikan paritas visual yang identik dengan dokumen PDF.

## Analisis Komparasi Kinerja dan Efisiensi

Tabel berikut menyajikan perbandingan komprehensif antara pipeline **Laporan Generator (Typst Engine)**, pipeline berbasis **LaTeX Tradisional**, dan penyusunan manual menggunakan **Microsoft Word**:

| Parameter Evaluasi | Laporan Generator (Typst) | LaTeX Tradisional | Microsoft Word Manual |
|:---|:---|:---|:---|
| **Waktu Kompilasi Dokumen** | **< 1.0 detik** | 10 -- 30 detik | Tidak ada (Manual) |
| **Ukuran Toolchain / Instalasi** | **~25 MB** (Binary Typst) | ~4.5 GB (TeX Live) | ~2.5 GB (MS Office) |
| **Dukungan Version Control (Git)** | **Sangat Baik** (Plain Text) | Sangat Baik (Plain Text)| Sangat Buruk (Binary DOCX)|
| **Keluaran Format Ganda** | **PDF & DOCX Sinkron** | Hanya PDF | Hanya DOCX |
| **Penanganan Layout Drift** | **Deterministik & Otomatis** | Deterministik | Sering Bergeser Manual |
| **Konfigurasi Format Kampus** | **1 Baris YAML Preset** | Modifikasi .cls/macro | Setting Style GUI Manual |
| **Integrasi AI Agent** | **Terpadu (`prompt.md`)** | Kustom / Manual | Terbatas |

## Hasil Pengujian Otomatis (Automated Test Suite)

Pengujian menyeluruh menggunakan skrip `test.sh` dilakukan untuk memverifikasi fungsionalitas seluruh komponen. Hasil eksekusi pengujian pada lingkungan terisolasi menghasilkan status lulus 100%:

```
=== Test Suite: Laporan Generator ===

[T1] Dependency check                               [OK] 3/3 tools
[T2] File structure check                           [OK] 8/8 files
[T3] Metadata check                                 [OK] 2/2 checks
[T4] Template check                                 [OK] 3/3 checks
[T5] .gitignore check                               [OK] 2/2 checks
[T6] Docker check                                   [OK] 2/2 checks
[T7] Build PDF (Typst Engine)                       [OK] PDF Valid (458 KB)
[T8] No box-drawing characters                      [OK] Clean text
[T9] No manual numbering in headings                [OK] Valid AST
[T10] Metadata fields check                         [OK] 2/2 fields
[T11] References check (BibTeX structure)           [OK] Valid BibTeX
[T12] Makefile targets check                        [OK] Valid targets
[T13] Recursive image processing check              [OK] Recursive find
[T14] PDF content readability check                 [OK] Readable text
[T15] Typst engine check                            [OK] Verified
[T16] DOCX export check (Styles, XML, Sect, Pages)  [OK] 21/21 assertions
[T17] CLI Helper and Preset Guide check             [OK] 4/4 checks
[T18] Preset Architecture & University Presets      [OK] 10/10 checks
[T19] PDF Preset Scanner & Extractor check          [OK] 5/5 checks
[T20] Preset Linter, Validator & Diff CLI check     [OK] 4/4 checks

========================================================================
Hasil Akhir: 78 assertions passed, 0 failed (100% Success Rate)
========================================================================
```

Seluruh 78 pengujian terotomatisasi berhasil dieksekusi tanpa galat, membuktikan bahwa pipeline memiliki stabilitas tinggi, kompatibilitas lintas platform yang solid, dan siap digunakan dalam produksi.
