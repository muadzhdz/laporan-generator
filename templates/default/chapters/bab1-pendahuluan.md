# PENDAHULUAN

## Latar Belakang

Penulisan laporan akademik merupakan kegiatan fundamental dalam ekosistem pendidikan tinggi dan penelitian. Mahasiswa, dosen, dan peneliti secara berkala menyusun dokumen formal seperti laporan praktikum, laporan proyek rekayasa perangkat lunak, tugas akhir, skripsi, tesis, hingga makalah ilmiah [@apa2020manual]. Standarisasi laporan akademik menuntut tingkat konsistensi visual yang ketat, meliputi pengaturan geometri halaman (margin), tipografi, spasi baris, penomoran berjenjang, penataan tabel dan gambar, hingga keakuratan sitasi daftar pustaka.

Metode konvensional dalam penyusunan laporan akademik di Indonesia umumnya masih mengandalkan pengolah kata berbasis Graphical User Interface (GUI) seperti Microsoft Word. Meskipun populer dan mudah diakses, pendekatan ini memiliki sejumlah tantangan teknis:

1. **Inkonsistensi Pemformatan dan Pergeseran Tata Letak** --- Penataan gaya (styles), margin, dan spasi yang dilakukan secara manual sering kali menghasilkan dokumen yang tidak seragam. Perubahan kecil pada paragraf awal kerap mengakibatkan pergeseran posisi gambar dan tabel pada halaman-halaman berikutnya (*layout drift*).

2. **Kompleksitas Penomoran Ganda** --- Pedoman penulisan karya ilmiah di perguruan tinggi Indonesia mewajibkan struktur penomoran halaman ganda (*dual pagination*), yaitu angka Romawi kecil (*i, ii, iii*) untuk bagian pengantar (*front matter*) dan angka Arab (*1, 2, 3*) yang dimulai ulang (*restart*) dari angka 1 pada BAB I (*main body*). Pengaturan *section break* manual pada pengolah kata konvensional sering membingungkan dan rentan rusak saat dokumen disunting berulang kali [@iso2021openxml].

3. **Ketiadaan Dukungan Version Control yang Efektif** --- Berkas dokumen biner atau XML terkompresi tidak dapat di-*diff* dan di-*merge* secara bersih menggunakan sistem kontrol versi seperti Git. Hal ini menyulitkan pelacakan riwayat revisi dan kolaborasi tim secara terdistribusi.

4. **Ketergantungan dan Bobot Sistem Typesetting Tradisional** --- Penggunaan sistem typesetting klasik seperti LaTeX [@lamport1994latex; @knuth1984texbook] memberikan kualitas tipografi tinggi, namun memiliki kurva belajar yang curam serta ukuran instalasi distribusi TeX Live yang sangat besar (mencapai 4--5 GB) sehingga lambat dalam lingkungan CI/CD container.

Untuk mengatasi permasalahan tersebut, paradigma pemisahan konten dari penyajian (*separation of concerns*) diimplementasikan melalui pipeline otomatisasi dokumen modern. Konten ditulis menggunakan format teks ringan **Markdown** [@gruber2004markdown; @commonmark2021], kemudian dikonversi secara terpadu oleh **Pandoc** [@pandoc2024] ke dalam dua engine keluaran:

1. **Typst Engine** [@typst2024] sebagai sistem typesetting mutakhir yang cepat dan ringan untuk menghasilkan dokumen PDF berkualitas percetakan.
2. **Multi-Pass DOCX Engine** dengan filter Lua kustom [@krewinkel2020pandoc] untuk menghasilkan dokumen Microsoft Word resmi yang memenuhi aturan penomoran halaman akademik.

Pipeline ini diorkestrasi secara otomatis melalui antarmuka CLI terpadu dan skrip otomatisasi Bash [@gnu2024bash], serta didukung oleh lingkungan terisolasi yang dapat direproduksi (*reproducible*) menggunakan Nix Flakes [@dolstra2004nix] dan Docker [@merkel2014docker].

## Rumusan Masalah

Berdasarkan latar belakang di atas, rumusan masalah dalam penelitian dan pengembangan pipeline ini adalah:

1. Bagaimana merancang arsitektur pipeline otomatisasi konversi dokumen akademik dari format Markdown menjadi PDF dan Microsoft Word (DOCX)?
2. Bagaimana mengintegrasikan engine typesetting Typst dan filter Pandoc Lua untuk menghasilkan format laporan yang mematuhi standar penomoran akademik Indonesia?
3. Bagaimana mekanisme penanganan penomoran halaman ganda (Romawi kecil pada *front matter* dan Arab pada isi bab) secara otomatis pada berkas DOCX dan PDF?
4. Bagaimana merancang sistem preset deklaratif yang fleksibel untuk memfasilitasi keberagaman aturan format di berbagai perguruan tinggi?
5. Bagaimana membangun lingkungan pengembangan dan build yang sepenuhnya terisolasi dan *reproducible* menggunakan Nix Flakes dan Docker container?

## Tujuan

Tujuan dari penyusunan laporan dan pengembangan sistem ini adalah:

1. Menganalisis dan mengimplementasikan pipeline otomatisasi dokumen berbasis teks menggunakan Markdown, Pandoc, Typst, dan Lua Filters.
2. Membangun template visual Typst (`template.typ`) dan template gaya Word (`reference.docx`) yang mematuhi standar tipografi akademik Indonesia (A4, margin standar/skripsi, Times New Roman/Libertinus Serif, spasi 1.5).
3. Mengembangkan sistem injeksi OpenXML dan skrip dua tahap (*two-pass page numbering*) untuk menyinkronkan penomoran halaman aktual pada Daftar Isi dokumen DOCX.
4. Mengembangkan sistem preset format kampus deklaratif (`presets/*.yml`) beserta modul linter dan pemindai otomatis (*PDF Guideline Scanner*).
5. Mengintegrasikan test suite otomatis berorientasi assertions untuk memverifikasi keandalan struktur dan konten dokumen yang dihasilkan.

## Manfaat

Manfaat yang diharapkan dari proyek dan laporan ini meliputi:

1. **Efisiensi Waktu dan Produktivitas** --- Penulis dan mahasiswa dapat berfokus penuh pada substansi konten tanpa terbebani oleh pengaturan tata letak manual yang berulang.
2. **Standardisasi dan Kualitas Dokumen** --- Menghasilkan keluaran dokumen PDF dan DOCX yang konsisten, rapi, dan mematuhi kaidah penulisan ilmiah serta gaya sitasi APA Edisi ke-7 [@apa2020manual].
3. **Kemudahan Kolaborasi dan Version Control** --- Memungkinkan pelacakan perubahan baris per baris (*line-by-line diff*) pada repositori Git.
4. **Portabilitas Tinggi** --- Dokumentasi dapat dibangun secara instan di berbagai sistem operasi (Linux, macOS, Windows) dengan dependensi ringan.

## Batasan Masalah

Batasan masalah dalam implementasi sistem ini adalah:

1. Format dokumen masukan menggunakan varian Pandoc Markdown dengan metadata berbasis YAML.
2. Format keluaran utama mencakup dokumen PDF (dikompilasi melalui Typst) dan dokumen Microsoft Word (.docx).
3. Standar sitasi dan daftar pustaka default mengacu pada Citation Style Language (CSL) APA Style Edisi ke-7.
4. Pengujian otomatis dijalankan pada lingkungan sistem operasi berbasis Linux dan Nix/Docker container.
