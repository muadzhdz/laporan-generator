# TINJAUAN PUSTAKA

## Markdown dan Standardisasi Dokumen Teks

### Sejarah dan Filosofi Markdown

Markdown pertama kali diciptakan oleh John Gruber pada tahun 2004 sebagai format penulisan berbasis teks polos (*plain text*) yang dirancang agar mudah dibaca dan ditulis oleh manusia tanpa perlu proses kompilasi visual [@gruber2004markdown]. Filosofi dasar Markdown menempatkan keterbacaan (*human-readability*) sebagai prioritas tertinggi, di mana markup struktural tidak boleh mengaburkan arti teks substantif.

Seiring meluasnya penggunaan Markdown dalam ekosistem rekayasa perangkat lunak, inisiatif standardisasi melahirkan spesifikasi formal CommonMark [@commonmark2021]. Varian Pandoc Markdown memperluas spesifikasi ini dengan mendukung sintaks akademik tingkat lanjut seperti tabel bergaya *pipe*, blok kode beranotasi, catatan kaki (*footnotes*), persamaan matematika LaTeX inline maupun display, metadata berbasis YAML front matter, dan sitasi bibliografi terintegrasi [@pandoc2024].

### Sintaks Penulisan Akademik dalam Markdown

Tabel berikut merangkum pemetaan sintaks Markdown yang digunakan dalam pipeline penyusunan laporan akademik:

| Elemen Struktur | Sintaks Markdown | Contoh Penulisan | Representasi Keluaran |
|:---|:---|:---|:---|
| Judul Bab (Level 1) | `# Judul` | `# PENDAHULUAN` | BAB I PENDAHULUAN |
| Sub-Bab (Level 2) | `## Sub Judul` | `## Latar Belakang` | 1.1. Latar Belakang |
| Sub-Sub-Bab (Level 3) | `### Rincian` | `### Identifikasi Masalah` | 1.1.1 Rincian Masalah |
| Sitasi Bibliografi | `[@citekey]` | `[@typst2024]` | (Mädje & Haug, 2024) |
| Tabel Akademik | Pipe & Header Syntax | `| Kolom 1 | Kolom 2 |` | Tabel formal bergaris 0.5pt |
| Gambar / Diagram | `![Keterangan](path)` | `![Arsitektur](gambar/flow.png)` | Gambar terpusat ber-caption |
| Persamaan Matematika | `$...$` / `$$...$$` | `$E = m c^2$` | Notasi rumus terformat presisi |

## Sistem Typesetting Modern: Typst

### Arsitektur dan Prinsip Kerja Typst

Typst adalah sistem typesetting berbasis markup yang dapat diprogram (*programmable markup-based typesetting system*) yang dikembangkan oleh Laurenz Mädje dan Martin Haug [@typst2024]. Typst dirancang sebagai respons terhadap keterbatasan sistem typesetting klasik seperti TeX dan LaTeX [@knuth1984texbook; @lamport1994latex] yang memiliki waktu kompilasi lambat, pesan galat yang sulit diurai, serta sintaks makro yang kompleks.

Typst mengadopsi model kompilasi inkremental modern berbasis bahasa pemrograman Rust. Karakteristik utama Typst mencakup:

1. **Kecepatan Kompilasi Tinggi** --- Typst mampu mengompilasi puluhan halaman dokumen dalam hitungan milidetik, memungkinkan pengalaman pratinjau langsung (*live reload*) yang sangat responsif.
2. **Binary Ringan dan Mandiri** --- Ukuran binary Typst hanya berkisar 25 MB dan tidak membutuhkan dependensi eksternal dari repositori paket yang besar.
3. **Tipografi Bawaan yang Portabel** --- Typst menyertakan font berkualitas tinggi seperti Libertinus Serif dan DejaVu Sans Mono langsung di dalam binary, sehingga menjamin konsistensi render di semua platform tanpa isu font hilang (*missing fonts*).
4. **Model Tata Letak Deklaratif** --- Pengaturan margin halaman, penomoran heading bertingkat, dan aturan jeda halaman (*pagebreak*) dikonfigurasi melalui fungsi bawaan yang elegan seperti `#set page()`, `#set heading()`, dan `#show heading()`.

## Pandoc dan Pemrosesan Dokumen Abstrak

### Universal Document Converter

Pandoc adalah perangkat lunak konversi dokumen universal yang dikembangkan oleh John MacFarlane [@pandoc2024]. Pandoc bekerja dengan membaca format masukan (seperti Markdown), mengonversinya ke dalam struktur pohon sintaks abstrak internal yang disebut *Abstract Syntax Tree* (AST), lalu mengekspor AST tersebut ke berbagai format target, termasuk Typst, HTML, EPUB, dan Microsoft Word (DOCX).

### Filter Lua dan Ekstensibilitas AST

Sejak versi 2.0, Pandoc menyediakan mesin scripting tertanam berbasis bahasa pemrograman Lua yang memungkinkan manipulasi AST sebelum proses penulisan dokumen akhir dilakukan [@krewinkel2020pandoc]. Dalam proyek ini, berkas `docx.lua` berperan penting dalam:

1. Mendeteksi elemen heading level 1, 2, dan 3 untuk menambahkan penomoran otomatis berformat Romawi (`BAB I`) dan Arab (`1.1.`, `1.1.1`).
2. Menghasilkan struktur XML untuk halaman sampul formal dan Daftar Isi yang terhubung dengan tautan hiperteks internal (*hyperlink anchor*).
3. Mencegah penomoran ganda pada bagian khusus seperti KATA PENGANTAR dan DAFTAR PUSTAKA.

## Arsitektur Dokumen Office Open XML (DOCX)

Standar internasional ISO/IEC 29500 mendefinisikan Office Open XML (OpenXML) sebagai representasi berkas dokumen teks berbasis arsip ZIP yang berisi serangkaian berkas XML dan relasi strukturalnya [@iso2021openxml]. Berkas utama `word/document.xml` menyimpan seluruh elemen paragraf (`<w:p>`), teks (`<w:t>`), dan properti seksi (`<w:sectPr>`).

Pengaturan *section break* (`<w:sectPr>`) menentukan perilaku penomoran halaman pada setiap bagian dokumen. Agar mematuhi kaidah akademik Indonesia, dokumen DOCX dibagi menjadi tiga seksi:
1. **Seksi Sampul**: Referensi footer dihapus sehingga halaman pertama bersih tanpa nomor.
2. **Seksi Front Matter**: Properti penomoran diset ke format Romawi kecil (`w:fmt="lowerRoman"` dan `w:start="1"`).
3. **Seksi Main Body (BAB I)**: Properti penomoran di-reset menjadi format angka Arab (`w:fmt="decimal"` dan `w:start="1"`).

## Pemrosesan Citra Digital dengan ImageMagick

ImageMagick adalah rangkaian perangkat lunak untuk manipulasi citra digital via baris perintah [@imagemagick2024]. Pada pipeline dokumen ilmiah, diagram dan tangkapan layar sering kali berformat PNG dengan saluran transparansi (*alpha channel*). Saluran alfa yang tidak diatur dapat menimbulkan artefak visual seperti latar belakang hitam atau distorsi warna pada saat citra dirender ke dalam dokumen PDF. Pipeline menggunakan perintah normalisasi:

```bash
convert input.png -alpha off output.png
```

Perintah ini secara rekursif menonaktifkan transparansi dan menggantinya dengan latar belakang putih pekat, menjamin gambar tampil bersih pada media cetak.

## Reproducibility dan Lingkungan Terisolasi

### Manajemen Dependensi Berbasis Nix Flakes

Nix adalah manajer paket murni fungsional yang menjamin *reproducible builds* dengan menyimpan setiap dependensi dalam direktori unik berbasis *cryptographic hash* di `/nix/store` [@dolstra2004nix]. Melalui berkas konfigurasi `flake.nix` dan berkas pengunci `flake.lock`, seluruh dependensi toolchain (Pandoc, Typst, ImageMagick, poppler-utils, dan LibreOffice) dapat diinisialisasi secara deterministik di berbagai mesin pengembang tanpa konflik dependensi sistem operasi.

### Kontainerisasi Menggunakan Docker

Docker menyediakan isolasi tingkat sistem operasi menggunakan teknologi Linux *cgroups* dan *namespaces* [@merkel2014docker; @love2010kernel]. Melalui `Dockerfile` multi-arsitektur (amd64 dan arm64), lingkungan kompilasi dokumen dapat dijalankan langsung pada platform apapun yang mendukung runtime container tanpa perlu instalasi perangkat lunak lokal.

## Standar Sitasi Akademik APA Edisi ke-7

Karya ilmiah dan laporan akademik mengadopsi standar pengutipan dan penulisan daftar pustaka berdasarkan *Publication Manual of the American Psychological Association* (APA) Edisi ke-7 [@apa2020manual]. Standar APA menerapkan sistem pengutipan Nama Penulis dan Tahun Penerbitan (*Author-Date System*), misalnya `(MacFarlane, 2024)` untuk sitasi dalam kurung (*parenthetical*) atau `MacFarlane (2024)` untuk sitasi naratif. Pemrosesan sitasi pada pipeline dijalankan secara otomatis oleh mesin `pandoc-citeproc` menggunakan berkas definisi gaya `apa.csl` dan basis data pustaka BibTeX `references.bib`.
