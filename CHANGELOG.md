# Catatan Perubahan (CHANGELOG)

Semua perubahan penting pada project **Laporan Generator** akan didokumentasikan dalam file ini.

Format dokumen ini mengacu pada [Keep a Changelog](https://keepachangelog.com/id/1.0.0/) dan mematuhi [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.8.0] - 2026-09-29

### Added
- **Kontrol Opt-in Front-Matter (`daftar_gambar` & `daftar_tabel`)**: Penambahan opsi eksplisit pada `metadata.yml` untuk mengendalikan pembentukan halaman DAFTAR GAMBAR dan DAFTAR TABEL. Halaman ini kini tidak dimunculkan secara otomatis kecuali diaktifkan secara eksplisit (`daftar_gambar: true`, `daftar_tabel: true`).
- **Skema Parameter MCP `laporan_init`**: Penambahan parameter opsional `daftar_gambar` dan `daftar_tabel` bertipe boolean pada tool MCP `laporan_init`.
- **Protokol Wawancara Struktur Interaktif AI Agent (`prompt.md` & `SKILL.md`)**: Tahap 2 mewajibkan agen AI melakukan konfirmasi struktur dokumen (menanyakan kebutuhan Abstrak, Lembar Pengesahan, Daftar Gambar, Daftar Tabel, Lampiran) kepada pengguna sebelum membuat berkas.
- **Suite Pengujian Dinamis (`scripts/test_scripts.py`)**: Penambahan unit test `TestFrontMatterOptIn` yang memverifikasi penanganan tipe skalar boolean YAML pada Lua filter dan koersi boolean string pada Node.js `lib/init.js`.
- **Arsitektur Keputusan ADR 001**: Dokumentasi formal keputusan perampingan struktur default di `.ai-engineering-loop/adrs/001-minimal-default-structure-and-opt-in-front-matter.md`.

### Changed
- **Struktur Default Dokumen Minimal**: Struktur dokumen bawaan kini diperamping menjadi 5 elemen baku: Cover -> Kata Pengantar -> Daftar Isi -> Batang Tubuh (BAB I..n) -> Daftar Pustaka.
- **Placeholder Abstrak Bawaan**: Entri `abstract_id` dan `abstract_en` di `metadata.yml` kini dikomentari secara default guna mencegah kemunculan halaman dummy abstrak tanpa persetujuan pengguna.
- **Sinkronisasi Versi Seluruh CLI**: Memperbarui seluruh banner CLI (Node.js, Bash, PowerShell) dan server MCP menjadi versi `v2.8.0`.

### Fixed
- **Type Safety Skalar Boolean Lua Filter (`docx.lua`)**: Memperbaiki fungsi `meta_str` dan menambahkan fungsi `meta_bool` agar aman terhadap nilai skalar native boolean YAML pada Pandoc, mencegah error tipe data atau evaluasi string kosong saat kompilasi DOCX.
- **Koersi String Truthy JavaScript (`lib/init.js`)**: Mengganti evaluasi ternary langsung dengan fungsi `isTruthy` agar string `'false'` dari antarmuka CLI tidak dievaluasi menjadi nilai boolean `true`.
- **Penghapusan Empty Catch Blocks (`lib/init.js`)**: Mengganti blok `catch (_) {}` dengan pencatatan peringatan terstruktur (`console.warn`) sesuai standar repository conventions.

---

## [2.7.0] - 2026-09-20

### Added
- **Native Model Context Protocol (MCP) Server (`bin/mcp-server.js` & `lib/mcp.js`)**: Server MCP resmi berbasis protokol JSON-RPC 2.0 (stdio) yang mengekspos 6 tools otonom untuk AI Agent:
  - `laporan_init`: Inisialisasi struktur dokumen akademik (skripsi/makalah) secara terprogram.
  - `laporan_doctor`: Audit kesehatan lingkungan, dependensi, broken images, dan sitasi hilang dalam format JSON.
  - `laporan_stats`: Analisis komprehensif statistik kata, bab, dan estimasi halaman dokumen.
  - `laporan_presets`: Daftar dan inspeksi preset resmi kampus (UI, ITB, UGM, ITS, Unpad, standard 4-4-3-3).
  - `laporan_citations`: Validasi entri BibTeX dan live query pencarian sitasi langsung ke Crossref API.
  - `laporan_build`: Kompilasi dokumen PDF/DOCX langsung dari panggilan tool agen AI.
- **Dukungan Output JSON Utilitas Python**: Penambahan flag `--json` dan argumen direktori target dinamis pada `scripts/report-doctor.py`, `scripts/report-stats.py`, dan `scripts/bundle.py`.
- **Ekspor Programmatic Initialization (`lib/init.js`)**: Mengekspor fungsi `initProject(options)` untuk scaffolding dokumen tanpa interaksi terminal mentah.
- **Integrasi Multi-Host MCP Otomatis (`lib/sync-hosts.js`)**: Perintah `npx laporan-generator sync-hosts` kini otomatis mendaftarkan MCP server `laporan` ke Antigravity (`mcp_config.json`), Claude Desktop/Code (`claude.json`), dan OpenCode (`opencode.jsonc`).
- **Suite Pengujian Integrasi MCP (`tests/test_mcp.js`)**: 6 pengujian integrasi otomatis untuk memvalidasi inisialisasi stdio, schema list, dan eksekusi tools.

### Fixed
- **Resolusi Jalur Eksekusi MCP CLI Lintas Proyek (`laporan`)**: Penambahan fallback `npx -y laporan-generator mcp` pada skrip Bash ketika `bin/mcp-server.js` tidak berada di direktori lokal proyek pengguna.
- **Splatting Parameter Posisi PowerShell (`laporan.ps1`)**: Penambahan akumulator `$extraArgs` yang menyatukan `$SubCommand`, `$Arg1`, `$Arg2`, dan `$RemainingArgs` sehingga flag `--json` diteruskan dengan sempurna ke `Cmd-Doctor` dan `Cmd-Stats`.
- **Terminal Encoding Guard Windows (`scripts/report-doctor.py`)**: Rekonfigurasi stream UTF-8 dengan mode `errors="replace"` pada Windows guna mencegah `UnicodeEncodeError`.
- **Sinkronisasi Versi Seluruh CLI**: Memperbarui seluruh banner CLI (Node.js, Bash, PowerShell) menjadi versi `v2.7.0`.

---

## [2.6.2] - 2026-09-14

### Fixed
- **Deteksi Python Lintas Platform di CLI (`bin/laporan-generator.js`)**: Menambahkan fungsi `getPythonCommand()` yang memeriksa `python` terlebih dahulu pada platform Windows (`win32`) sebelum `python3` guna mencegah bentrok dengan App Execution Alias stub Microsoft Store.
- **Dukungan Terminal Encoding Windows (`scripts/report-stats.py`)**: Merekonfigurasi `sys.stdout` dan `sys.stderr` ke UTF-8 dengan mode `errors="replace"` pada Windows agar karakter visualisasi grafik batang (`■`) tidak memicu `UnicodeEncodeError: 'charmap'`.
- **Ketahanan Fallback Test Suite PowerShell (`laporan.ps1`)**: Memeriksa ketersediaan `test.sh` sebelum memanggil Bash, dan secara cerdas mengalihkan eksekusi ke `validate-preset.py` serta unit test Python `test_scripts.py` saat berkas `test.sh` tidak ada di proyek pengguna.
- **Kompatibilitas Universal Opsi Pandoc (`build.sh` & `laporan.ps1`)**: Mengganti opsi `--syntax-highlighting=none` dengan `--no-highlight` yang didukung secara universal oleh seluruh versi Pandoc (Pandoc 2.x/3.x) dan seluruh runner CI/CD.

### Added
- **Perluasan Unit Test Suite (`scripts/test_scripts.py`)**: Menambahkan kelas uji `TestReportStats` untuk memvalidasi parser statistik dokumen Markdown, meningkatkan total pengujian unit menjadi 16/16 lulus 100%.

---

## [2.6.1] - 2026-09-14

### Fixed
- **Daftar Isi Dinamis DOCX (Word Native TOC Field)**: Perbaikan pembuatan Daftar Isi pada dokumen Microsoft Word (.docx) menggunakan kode bidang OpenXML asli (`w:fldSimple` / `w:instrText TOC \o "1-3" \h \z \u`) sehingga hierarki bab terdaftar rapi pada panel navigasi tanpa teks tumpang tindih.
- **Penomoran Halaman Ganda DOCX**: Perbaikan pemisahan section break OpenXML pada dokumen Word, di mana nomor halaman pada cover disembunyikan otomatis, bagian awal (Kata Pengantar, Daftar Isi, Abstrak) menggunakan angka Romawi kecil (`i, ii, iii...`), dan bab utama (BAB I s.d. BAB V) menggunakan angka Arab (`1, 2, 3...`).
- **Inisialisasi Proyek (`laporan init`)**: Penambahan direktori `scripts/` pada daftar penyalinan berkas agar proyek baru selalu memiliki utilitas `finalize-docx.py`, `docx-pagenum.py`, `report-stats.py`, dan `report-doctor.py`.
- **Distribusi Paket NPM**: Pembaruan array `files` pada `package.json` dan sanitasi `.npmignore` guna memastikan seluruh 109 berkas template dan utilitas terdistribusi secara utuh tanpa berkas cache biner `.pyc`.

### Changed
- **Pembaruan Dokumentasi README**: Penyusunan ulang `README.md` berstandar industri dengan bahasa Indonesia baku, matriks perbandingan perintah CLI lintas platform, dan kepatuhan penuh terhadap zero-emoji policy.

---

## [2.6.0] - 2026-09-13

### Added
- **Multi-Host AI Agent Skills Engine (`.agents/skills/laporan-generator`)**: Memaketkan seluruh engine pembuatan karya ilmiah ke format AI Agent Skill mandiri yang kompatibel dengan Antigravity CLI, Claude Code, dan Grok.
- **Distribusi Instan via `npx` (`bin/laporan-generator.js`)**: Pengguna dapat langsung menjalankan `npx laporan-generator sync-hosts`, `setup`, `init`, `doctor`, dan `build` di direktori mana pun tanpa instalasi manual.
- **Universal Multi-OS Dependency Setup (`scripts/setup-deps.sh` & `setup-deps.ps1`)**:
  - Windows: Pemasangan hening (*silent non-interactive*) untuk Typst, Pandoc, dan ImageMagick via Winget dengan auto PATH refresh serta fallback portable zip tanpa hak administrator.
  - Linux: Deteksi otomatis package manager (`apt`, `pacman`, `dnf`), dukungan Nix Flake (`nix develop`), dan kontainer Docker terisolasi.
  - macOS: Dukungan Homebrew resmi.
- **Perintah Baru pada CLI Bawaan**: Penambahan sub-command `setup` dan `sync-skills` pada `./laporan` (Bash) dan `.\laporan.ps1` (PowerShell).
- **Kategori Uji [T24] pada Test Suite**: Menambah verifikasi integritas paket npm, file eksekutabel bin, `SKILL.md`, dan script installer multi-OS sehingga total pengujian mencapai 101 assertions lulus 100%.

---

## [2.5.0] - 2026-09-07

### Added
- **Native PowerShell Auto-Rebuild Watcher (`laporan.ps1 watch`)**: Kapabilitas live watching untuk pengguna Windows via .NET `System.IO.FileSystemWatcher` yang mendeteksi perubahan bab dan kompilasi otomatis tanpa dependensi eksternal.
- **Panduan Sintaks Akademik Lengkap (`docs/syntax-cheatsheet.md`)**: Cheatsheet komprehensif penulisan sitasi APA, formula matematika Typst/Pandoc, pembuatan tabel multi-kolom, penyisipan gambar ber-caption, dan format catatan kaki.
- **Unit Test Suite Python (`scripts/test_scripts.py`)**: 8 pengujian otomatis terisolasi untuk memvalidasi parser YAML preset dan ekstraksi nomor halaman TOC DOCX.
- **Suite Pengujian [T23] pada `test.sh`**: Peningkatan cakupan uji regresi menjadi 23 test suites dan 96 assertions validasi otomatis lulus 100%.

### Fixed
- **Sanitasi String YAML (`laporan` & `laporan.ps1`)**: Implementasi `yaml_escape` dan `Escape-Yaml` pada wizard interaktif `init` untuk mencegah malformasi struktur file `metadata.yml`.
- **Ekspansi Array Bash (`build.sh`)**: Perbaikan peringatan ShellCheck SC2064 dan SC2086 menggunakan array `INPUT_FILES[@]` dan `PRESET_OPTS[@]` untuk memastikan jalur direktori berspasi ditangani secara aman.
- **Defensive Timeout Subproses DOCX (`scripts/docx-pagenum.py`)**: Penambahan batas waktu eksekusi (15 detik untuk `pdfinfo`/`pdftotext`, 45 detik untuk `soffice`) guna mencegah proses kompilasi macet (*hang*).
- **Hardening Parser Preset YAML (`scripts/validate-preset.py`)**: Integrasi pustaka PyYAML dengan fallback string parser dan penanganan exception yang terisolasi.

---

## [2.4.0] - 2026-09-03

### Added
- **Generalisasi Universal Karya Ilmiah (`prompt.md` & `template.typ`)**: Dukungan resmi untuk Makalah Akademik, Laporan Proyek, Laporan Magang / PKL, Tugas Akhir / Skripsi, dan Artikel Jurnal IMRAD.
- **Protokol Wawancara Interaktif 3 Tahap (`prompt.md`)**: Panduan dialog wajib AI Agent untuk menanyakan jenis karya tulis dan mengonfirmasi susunan halaman (Cover, Pengesahan, Abstrak, Kata Pengantar, Daftar Isi, Gambar/Tabel, Lampiran) sebelum berkas dibuat.
- **CLI Analytics & Health Audit Tooling (`./laporan` & `laporan.ps1`)**:
  - `stats`: Analisis komprehensif jumlah kata, halaman, bab, tabel, gambar, persamaan matematika, sitasi, durasi membaca, dan grafik distribusi kata.
  - `doctor`: Audit otomatis broken image links, sitasi rusak di `.bib`, heading numbering anti-patterns, dan box-drawing characters (Skor Kesehatan 100/100).
  - `bundle`: Pengemasan laporan PDF, DOCX, dan sumber Markdown ke dalam berkas zip rilis (`dist/Laporan-Akademik-Lengkap.zip`).
- **Dukungan Halaman Abstrak Dwibahasa & Lembar Pengesahan**: Halaman khusus terpisah unnumbered untuk Abstrak (Bahasa Indonesia) + Kata Kunci dan Abstract (Bahasa Inggris) + Keywords, serta rendering otomatis lembar tanda tangan pengesahan.
- **Daftar Gambar & Daftar Tabel Otomatis**: Query dinamis berbasis `#context` Typst yang otomatis menyisipkan DAFTAR GAMBAR dan DAFTAR TABEL jika dokumen memuat media/tabel.
- **Kategori Uji [T21] & [T22] pada Test Suite**: Ekspansi suite pengujian otomatis menjadi 22 kategori dan 91 assertions lulus 100%.

### Fixed
- **Perbaikan Kritis Spasi Awalan Bab (`template.typ` & `docx.lua`)**: Menambahkan smart guard string prefix pada template Typst dan filter Lua DOCX sehingga teks tidak lagi rapat (`BABI PENDAHULUAN` diperbaiki menjadi `BAB I PENDAHULUAN`).
- **Dukungan Awalan Bab Kosong**: Menjamin format artikel ilmiah/makalah tanpa awalan "BAB" (`heading_chapter_prefix: ""`) tidak menghasilkan spasi kosong di awal nomor bab.
- **Perbaikan Git Hook Pre-Commit**: Menghapus dependensi usang pdflatex dan template.latex lama, menyelaraskannya dengan Typst, reference.docx, dan docx.lua.
- **Deteksi Bab Dinamis `sort -V` (`build.sh`)**: Mengganti globbing statis dengan natural sort dinamis tanpa batas bab.
- **Pembersihan Residu Era LaTeX**: Menghapus sisa komentar dan dead code LaTeX pada `cover.md`, `CONTRIBUTING.md`, dan `docs/metadata-schema.md`.

---

## [2.3.0] - 2026-08-27

### Added
- **Windows Native PowerShell CLI Helper (`laporan.ps1`)**: Memungkinkan pengguna Windows tanpa WSL/Git Bash untuk menjalankan perintah `.\laporan.ps1 build`, `init`, `preset list/show/apply`, `check`, dan `view` langsung dari PowerShell.
- **Standarisasi Referensi Akademik Valid (`references.bib`)**: Pembaruan menyeluruh basis data pustaka dengan sumber ilmiah dan standar internasional terverifikasi (Typst, Pandoc, Pandoc Lua Filters, CommonMark, ImageMagick, GNU Bash, Nix Flakes, Docker Containers, APA 7th Edition, ISO/IEC OpenXML, The TeXbook, dan LaTeX).
- **Pengujian PowerShell Helper pada Test Suite**: Penambahan verifikasi ketersediaan `laporan.ps1` pada test suite otomatis (`test.sh`).

### Changed
- **Sinkronisasi Total Konten Dokumen Bawaan (`chapters/bab1-5.md`)**:
  - Memodernisasi seluruh bab 1 s/d 5 agar mencerminkan arsitektur terkini (Typst engine, Lua AST filters, multi-pass OpenXML partitioning, Nix hermetic builds).
  - Menghapus artefak sintaks lama dari era LaTeX v1.0.
  - Memastikan seluruh sitasi terhubung ke entri BibTeX valid format APA Edisi ke-7.
- **Pembaruan `metadata.yml`**: Judul dan abstrak disesuaikan dengan arsitektur multi-engine modern.

---

## [2.2.0] - 2026-08-21

### Added
- **CLI Helper Terpadu (`./laporan`)**: Script CLI ramah pemula dengan perintah `./laporan init` (wizard konfigurasi interaktif), `./laporan build` (kompilasi PDF + DOCX sekaligus), `./laporan check` (audit dependensi & berkas), dan `./laporan test`.
- **Dukungan Preset Margin Fleksibel (`docs/campus-guide.md`)**: Dukungan konfigurasi preset margin `standard` (2.5/2.5/2/3 cm) dan `skripsi-4433` (4/4/3/3 cm) di `template.typ` dan `metadata.yml`.
- **Auto-injeksi nomor halaman Daftar Isi DOCX (`scripts/docx-pagenum.py`)**: Skrip dua tahap yang merender DOCX di background dan menyuntikkan nomor halaman aktual ke entri `PAGEREF` TOC sehingga tidak perlu update field manual di Word.
- **Multi-section document partitioning (`scripts/finalize-docx.py`)**: Pengaturan 3 `sectPr` Word terpisah (Cover tanpa nomor, Front Matter bernomor romawi `i`, `ii`, dan BAB I restart otomatis ke angka Arab `1`, `2`, `3`).
- **Peningkatan Test Suite ke 58 Assertions**: 17 kategori pengujian mendalam mencakup validasi footer, penomoran romawi, decimal restart, spasi BAB 2 baris, preset margin, dan CLI helper.

### Changed
- **Standarisasi Tipografi & Paritas Visual**:
  - Judul BAB: 14pt Bold, spasi setelah judul 2 baris penuh (`w:after="720"` / `bottom: 1.8em`).
  - Sub-bab & Sub-sub-bab: 12pt Bold, jarak vertikal ke paragraf dibuat rapat dan proporsional.
  - Isi Teks & Paragraf: 12pt Regular, 1.5 line spacing (`line="360"` / `leading: 0.75em`), 1.25 cm first-line indent.
  - Tabel: Style `Compact` 12pt, padding sel bersih, tanpa indentasi pertama, border 0.5pt abu-abu.
  - Blok Kode: Style `SourceCode` 9pt `DejaVu Sans Mono`, rata kiri.
  - Daftar Isi: Panjang terkontrol presisi 1 halaman penuh.
  - Daftar Pustaka: Auto hanging-indent 1.25 cm di PDF & DOCX.

---

## [2.1.0] - 2026-08-20

### Added
- **Export DOCX profesional**: `make docx` kini memakai `reference.docx` (template gaya Word) dan `docx.lua` (filter Lua). Hasil: halaman A4, margin 2/3/2.5/2.5 cm, Times New Roman 12pt justify spasi 1.5, Heading 1 (judul BAB) 14pt bold rata tengah, Heading 2/3 12pt bold rata kiri, penomoran `BAB I`/`1.1.`/`1.1.1` otomatis, field DAFTAR ISI Word (`TOC \o "1-3"`), dan KATA PENGANTAR tanpa nomor.
- **Cover DOCX meniru cover PDF**: logo, judul seimbang (tanpa kata sendirian, `balance_title` DP), subjudul, mata kuliah, dosen pengampu, daftar penulis (nama + NIM), dan institusi (fakultas/kampus/tahun) memakai style khusus `CoverImage`, `CoverTitle`, `CoverSubtitle`, `CoverLine`, `CoverInstitution`; title block bawaan pandoc dinonaktifkan.
- **`scripts/make-reference-docx.py`**: Skrip untuk meregenerasi `reference.docx` dari reference bawaan pandoc (`make reference-docx`).
- **Test T16**: Validasi DOCX export (penomoran BAB, KATA PENGANTAR tanpa nomor, field TOC, Times New Roman, ukuran A4, Heading 14pt, cover logo + style cover + title block hilang) -- total 43 assertions.
- Dependensi `unzip` di flake.nix, Dockerfile, dan CI untuk inspeksi DOCX.

### Changed
- **Format heading PDF mengikuti pedoman kampus**: Judul BAB kini dua baris (`BAB II` di baris pertama, judul kapital di baris kedua), 14pt bold, rata tengah; sub-bab `1.1.` (titik di akhir) 12pt bold bernomor di body; DAFTAR ISI terstruktur (judul bold 14pt, dot leaders, indent sub-bab & sub-sub-bab, spasi antar bab) tetap satu baris.
- **Judul sampul seimbang tanpa kata sendirian**: `balance-lines` (dynamic programming) membagi judul menjadi maksimal 4 baris berbentuk piramida, contoh: `SISTEM INFORMASI PEMESANAN / KANTIN SEKOLAH BERBASIS WEB / MENGGUNAKAN REACT DAN / NODE.JS`.
- **Judul sampul & info institusi 14pt kapital penuh** (`LAPORAN DOKUMENTASI PIPELINE`), fakultas/kampus/tahun di-uppercase otomatis.
- `make docx` kini menyertakan `cover.md` (KATA PENGANTAR + field DAFTAR ISI Word).

---

## [2.0.0] - 2026-08-20

### Changed
- **Engine PDF berpindah dari LaTeX ke Typst**: Pipeline utama kini memakai `--pdf-engine=typst` dengan template baru `template.typ`, menggantikan `template.latex` (disimpan sebagai arsip legacy dan tidak lagi dipakai pipeline utama).
- **Penomoran bab otomatis** (`BAB I`, `BAB II`, dst; sub-bab `1.1`, `1.1.1`) kini ditangani sepenuhnya oleh Typst via `set heading(numbering: ...)`.
- **Dependensi jauh lebih ringan**: Hapus seluruh paket TeX Live (~3.5 GB) dari Dockerfile, flake.nix, dan CI. Sekarang cukup binary Typst (~25 MB) + Pandoc + ImageMagick.
- **Dokumentasi di-update**: `README.md`, `docs/template-guide.md` (arsitektur `template.typ`), dan `docs/troubleshooting.md` (isu font Typst & sintaks raw).

### Removed
- `fmtutil-sys --all` dari Dockerfile dan CI workflows (khusus TeX Live).
- Tes `template.latex` (documentclass, pmboxdraw, \sloppy, \pandocbounded) diganti dengan pemeriksaan spesifik Typst.

---

## [1.2.0] - 2026-07-25

### Added
- **Release Automation Workflow**: Tambahan `.github/workflows/release.yml` untuk automated release ketika ada git tag push
- **Remove All Emojis**: Menghapus semua emoji dari dokumentasi untuk tone yang lebih profesional dan akademik-appropriate
- **Structured Case Study Examples**: Reorganisasi `examples/` menjadi 3 folder terstruktur:
  - `01-Web-App/` — Laporan aplikasi React + Node.js
  - `02-Machine-Learning/` — Laporan CNN image classification dengan PyTorch
  - `03-IoT-Project/` — Laporan smart home monitoring dengan ESP32
- **Standardized Test Output**: Update `test.sh` untuk menggunakan indicator output bersih ([OK] / [FAIL] / [ERROR])
- **GitHub Discussions**: Enable Discussions untuk community Q&A, showcase, dan feature requests
- **GitHub Stats Badges**: Tambah badges untuk Stars, Forks, Issues, dan Last Commit di README

### Improved
- Documentation consistency across all files (no emojis, professional tone)
- Release automation dengan auto-build example PDF on tag push
- Test output clarity dan debugging experience
- README header dengan stats badges untuk professional appearance

---

## [1.1.0] - 2026-07-25

### Added
- **Peningkatan Dokumen Modular**: Menambahkan `GETTING-STARTED.md`, `CONTRIBUTING.md`, dan folder `docs/` (`metadata-schema.md`, `template-guide.md`, `troubleshooting.md`).
- **Deep PDF Testing (T14 & T15)**: Pengujian ekstraksi teks PDF (`pdftotext`) dan penanganan makro Pandoc 3.x di `test.sh`.
- **Target Makefile Baru**: Target `make init` untuk setup Git pre-commit hook otomatis dan `make view` untuk membuka PDF di viewer.
- **Support Macro `\pandocbounded`**: Penanganan kompatibilitas gambar otomatis untuk Pandoc 3.x pada `template.latex`.
- **Informative Error Messages**: Peningkatan penanganan dan konteks kesalahan pada `build.sh`.
- **GitHub Issue & PR Templates**: Menambahkan `.github/ISSUE_TEMPLATE/` dan `.github/PULL_REQUEST_TEMPLATE.md`.
- **Automated Examples Script**: Menambahkan `examples/generate_examples.sh` untuk membuat sampel PDF bagi studi kasus Web, ML, dan IoT.

### Fixed
- Memperbaiki pengolahan gambar PNG agar mendukung pemrosesan *alpha channel* secara rekursif hingga *subfolder* gambar.
- Memperbaiki target `make clean` di `Makefile` agar menghapus artifact `.docx` dan `.html`.

---

## [1.0.0] - 2026-07-24

### Added
- Rilis perdana Laporan Generator akademik berbasis Pandoc, LaTeX, dan Docker.
- Dukungan 3 metode kompilasi (AI Agent, Manual CLI, Docker Compose).
- Integrasi APA Citation Style (`apa.csl`) & BibTeX (`references.bib`).
- Pengujian otomatis 25 assertions (`test.sh`).
- Workflow CI/CD GitHub Actions dan Git Pre-commit Hooks.
