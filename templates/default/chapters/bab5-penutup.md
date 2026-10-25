# PENUTUP

## Kesimpulan

Berdasarkan perancangan, implementasi, dan serangkaian pengujian yang telah dilakukan pada proyek **Laporan Generator**, dapat ditarik beberapa kesimpulan utama:

1. **Efektivitas Paradigma Pemisahan Konten dan Penyajian** --- Penerapan format teks ringan Markdown sebagai lapisan penulisan konten yang dipisahkan dari lapisan tata letak (*layout*) terbukti secara signifikan meningkatkan fokus penulis, mengeliminasi masalah pergeseran tata letak (*layout drift*), serta memudahkan kolaborasi tim melalui sistem kontrol versi Git.

2. **Keunggulan Engine Typesetting Typst** --- Penggunaan Typst sebagai mesin kompilasi PDF utama berhasil memangkas ukuran dependensi sistem dari ~4.5 GB (distribusi TeX Live) menjadi hanya ~25 MB (binary mandiri Typst) dengan kecepatan kompilasi sub-detik, sembari tetap mempertahankan standar tipografi akademik profesional dan tata letak yang presisi.

3. **Keberhasilan Solusi Multi-Pass DOCX** --- Pendekatan multi-pass yang menggabungkan filter Pandoc Lua (`docx.lua`), manipulasi struktur OpenXML (`finalize-docx.py`), dan sinkronisasi nomor halaman via LibreOffice headless (`docx-pagenum.py`) berhasil mewujudkan dokumen Microsoft Word resmi dengan pemisahan seksi yang tepat (sampul tanpa nomor, *front matter* bernomor Romawi *i, ii*, dan isi bab yang dimulai ulang dari angka Arab 1).

4. **Fleksibilitas Sistem Preset Kampus dan Alat Bantu Otomasi** --- Kehadiran sistem preset deklaratif (`presets/*.yml`), didukung oleh pemindai pedoman PDF otomatis (`scan-preset.py`), linter validasi skema (`validate-preset.py`), serta antarmuka baris perintah terpadu (`./laporan`), memberikan kemudahan bagi sivitas akademika di berbagai universitas di Indonesia untuk menyesuaikan format laporan secara instan.

5. **Keandalan dan Keterulangan Sistem (*Reproducibility*)** --- Dukungan konfigurasi Nix Flakes (`flake.nix`) dan kontainer Docker menjamin bahwa pipeline dapat dijalankan secara identik di seluruh sistem operasi pengembang (Linux, macOS, Windows) dengan tingkat kelulusan pengujian 100% pada 78 *test assertions*.

## Saran

Beberapa peluang pengembangan lanjutan yang direkomendasikan untuk meningkatkan fungsionalitas dan adopsi proyek ini di masa depan antara lain:

1. **Pengembangan Antarmuka Web (Web-Based Interactive Generator)** --- Membangun antarmuka berbasis web atau aplikasi WebAssembly (Wasm) agar pengguna tanpa akses terminal atau baris perintah dapat menyunting dan mengunduh laporan langsung melalui peramban.

2. **Ekspansi Basis Data Preset Perguruan Tinggi** --- Menambahkan koleksi preset resmi untuk universitas-universitas besar lainnya di Indonesia, seperti Universitas Diponegoro (UNDIP), Universitas Airlangga (UNAIR), Universitas Brawijaya (UB), Universitas Telkom (Tel-U), dan BINUS University.

3. **Penyediaan Wrapper Baris Perintah PowerShell (`laporan.ps1`)** --- Mengembangkan skrip pembungkus PowerShell native guna menyempurnakan pengalaman pengembang (*developer experience*) bagi pengguna sistem operasi Windows murni tanpa ketergantungan pada WSL atau Git Bash.

4. **Integrasi Ekstensi Editor (VS Code / Antigravity IDE Plugin)** --- Menyediakan plugin editor yang menyertakan fitur cuplikan kode (*snippets*), validasi sitasi BibTeX otomatis, dan pratinjau dokumen (*live preview*) langsung di dalam lingkungan pengembangan terintegrasi.
