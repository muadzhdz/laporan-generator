<p align="center">
  <img src="logo.jpg" alt="Laporan Generator" width="200"/>
</p>

<h1 align="center">Laporan Generator</h1>

<p align="center">
   Pipeline otomatisasi dokumen akademik dan teknis (Makalah, Laporan Proyek, Magang, Skripsi, Artikel Ilmiah) dari Markdown ke PDF dan Word (DOCX) dalam satu perintah.
   Format APA, Typst engine, cover profesional, support Docker dan Nix. Didukung AI Agent prompt interaktif untuk pembuatan konten otomatis.
</p>

<p align="center">
  <a href="https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml"><img src="https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml/badge.svg" alt="Build Status"></a>
  <a href="#"><img src="https://img.shields.io/badge/Pandoc-3.0+-blue?style=for-the-badge&logo=markdown"></a>
  <a href="#"><img src="https://img.shields.io/badge/Typst-0.15+-239DAD?style=for-the-badge"></a>
  <a href="#"><img src="https://img.shields.io/badge/ImageMagick-7.0+-orange?style=for-the-badge"></a>
  <a href="#"><img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white"></a>
  <a href="#"><img src="https://img.shields.io/badge/Nix-5277C3?style=for-the-badge&logo=nixos&logoColor=white"></a>
  <a href="#"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/muadzhdz/laporan-generator?style=flat-square&label=Stars" alt="Stars">
  <img src="https://img.shields.io/github/forks/muadzhdz/laporan-generator?style=flat-square&label=Forks" alt="Forks">
  <img src="https://img.shields.io/github/issues/muadzhdz/laporan-generator?style=flat-square&label=Issues" alt="Issues">
  <img src="https://img.shields.io/github/last-commit/muadzhdz/laporan-generator?style=flat-square&label=Last%20Commit" alt="Last Commit">
</p>

<p align="center">
  <b><a href="GETTING-STARTED.md">Panduan Pemula (Zero to PDF)</a></b> •
  <b><a href="CONTRIBUTING.md">Kontribusi</a></b> •
  <b><a href="CHANGELOG.md">Changelog</a></b> •
  <b><a href="docs/troubleshooting.md">Troubleshooting</a></b> •
  <b><a href="examples/Laporan-Akademik-Example.pdf">Contoh PDF</a></b>
</p>

---

## Daftar Isi

- [AI Agent Flow (Cara Cepat)](#ai-agent-flow-cara-cepat)
- [Manual Flow (Edit Sendiri)](#manual-flow-edit-sendiri)
- [Build PDF -- Pilih 1 dari 4 Cara](#build-pdf--pilih-1-dari-4-cara)
- [Pusat Dokumentasi (Docs)](#pusat-dokumentasi-docs)
- [Struktur File](#struktur-file)
- [Alur Pipeline](#alur-pipeline)
- [Lisensi](#lisensi)

---

## AI Agent Flow (Cara Cepat)

Flow utama: Clone repo -> Jalankan AI Agent -> Langsung Build.

```bash
1. Clone repo ke folder project kamu:
     git clone https://github.com/muadzhdz/laporan-generator.git project-kamu
     cd project-kamu/

2. Ganti logo.jpg dengan logo kampus atau sekolah kamu
   (nama file TETAP logo.jpg -- biar ditemukan template)

3. Jalankan AI Agent (OpenCode, Claude Code, Antigravity CLI, dll):
     "Baca prompt.md dan generate laporan untuk project ini"

4. AI akan:
   - Scan folder project kamu (tentukan jenis project: Web/ML/IoT/dll)
   - Tanya kamu pertanyaan satu per satu (judul, anggota, dosen, matkul, dll)
   - Overwrite file-file berikut dengan konten sesuai project kamu:
     + chapters/bab*.md      (isi laporan per bab - tanpa manual numbering)
     + metadata.yml           (judul, penulis, dosen, matkul, institusi)
     + references.bib         (daftar pustaka format APA)
     + cover.md               (kata pengantar)

5. Build PDF (lihat cara build di bawah)
```

---

## Manual Flow (Edit Sendiri)

Jika Anda ingin menulis konten laporan secara manual tanpa AI:

```bash
1. Clone repo:
     git clone https://github.com/muadzhdz/laporan-generator.git project-kamu
     cd project-kamu/

2. Ganti logo.jpg dengan logo kampus/sekolah kamu (nama file TETAP logo.jpg)

3. Edit isi laporan di chapters/bab*.md (BAB I s/d BAB V)

4. Atur metadata di metadata.yml (judul, penulis, dosen, matkul, institusi)

5. Isi daftar pustaka di references.bib (format BibTeX) dan gunakan sitasi [@citekey] di Markdown

6. Build PDF (lihat cara build di bawah)
```

---

## Build PDF -- Pilih 1 dari 4 Cara

### Opsi 1: CLI Helper Terpadu (Paling Mudah)

**Linux / macOS (Bash):**
```bash
./laporan init                   # Wizard interaktif setup metadata dan jenis dokumen
./laporan preset list            # Tampilkan daftar preset format kampus yang tersedia
./laporan preset scan <file.pdf> # Pindai otomatis pedoman penulisan PDF kampus baru
./laporan preset apply <id>      # Terapkan preset kampus ke metadata.yml
./laporan build                  # Build PDF dan DOCX sekaligus
./laporan stats                  # Analisis statistik kata, halaman, gambar, durasi baca
./laporan doctor                 # Audit integritas proyek (sitasi rusak, broken images)
./laporan bundle                 # Kemas seluruh laporan ke dalam arsip zip rilis
./laporan check                  # Cek kelengkapan dependensi dan berkas proyek
```

**Windows (PowerShell):**
```powershell
.\laporan.ps1 check              # Cek kelengkapan dependensi sistem & berkas
.\laporan.ps1 build              # Build PDF dan DOCX laporan sekaligus
.\laporan.ps1 stats              # Analisis statistik kata, halaman, durasi baca
.\laporan.ps1 doctor             # Audit kesehatan proyek
.\laporan.ps1 bundle             # Kemas seluruh dokumen ke arsip zip
.\laporan.ps1 preset list        # Tampilkan daftar preset kampus yang tersedia
.\laporan.ps1 preset apply itb-ta # Terapkan preset kampus ke metadata.yml
.\laporan.ps1 view               # Buka dokumen Laporan.pdf di viewer
```

### Opsi 2: Docker (Zero Dependencies)
```bash
docker compose run --rm laporan-generator
```

### Opsi 3: Manual Install (Linux)
```bash
# Ubuntu / Debian
sudo apt install pandoc imagemagick xz-utils
wget -q https://github.com/typst/typst/releases/download/v0.15.1/typst-x86_64-unknown-linux-musl.tar.xz -O /tmp/typst.tar.xz
tar -xJf /tmp/typst.tar.xz -C /tmp
sudo mv /tmp/typst-x86_64-unknown-linux-musl/typst /usr/local/bin/

# Build
./build.sh
```

### Opsi 4: Makefile Helpers
```bash
make init         # Aktifkan git pre-commit hook otomatis
make build        # Build PDF (sama kaya ./build.sh)
make view         # Buka file Laporan.pdf di PDF viewer
make watch        # Auto-build saat file berubah (butuh inotify-tools)
make docx         # Export ke Microsoft Word (.docx)
make reference-docx # Regenerasi reference.docx dari reference bawaan pandoc
make html         # Export ke HTML
make test         # Jalankan test suite (22 kategori tes / 91 assertions)
make clean        # Hapus Laporan.pdf dan folder tmp/
```

### Opsi 5: Nix Flake (Reproducible - Zero Manual Install)

Environment development lengkap (Pandoc 3.x, Typst, ImageMagick, ShellCheck, dan tooling lainnya) dalam satu perintah. Cocok untuk pengguna NixOS, pengguna dengan Nix terinstall, atau siapa saja yang ingin environment identik di semua perangkat tanpa install manual.

```bash
# Masuk ke environment development
nix develop

# Build PDF / test di dalam shell:
./laporan build       # Build PDF + DOCX
make test             # 91 assertions passed
```

Dengan `flake.lock` yang di-commit, environment akan selalu identik di semua perangkat (Linux/macOS) -- tidak perlu install Pandoc, Typst, atau ImageMagick secara manual.

---

## Pusat Dokumentasi (Docs)

Untuk informasi teknis lebih mendalam, silakan baca dokumentasi terpisah kami:

- **[GETTING-STARTED.md](GETTING-STARTED.md)**: Panduan langkah-demi-langkah dari nol hingga jadi PDF, glosarium istilah, dan FAQ.
- **[docs/syntax-cheatsheet.md](docs/syntax-cheatsheet.md)**: Cheatsheet sintaks Markdown akademik lengkap (sitasi, rumus matematika, gambar, tabel).
- **[docs/campus-guide.md](docs/campus-guide.md)**: Panduan preset kampus (UI, ITB, UGM, ITS, UNPAD), margin, dan pemindaian PDF pedoman.
- **[docs/preset-schema.md](docs/preset-schema.md)**: Spesifikasi skema konfigurasi preset format kampus (`presets/*.yml`).
- **[docs/metadata-schema.md](docs/metadata-schema.md)**: Panduan lengkap skema konfigurasi `metadata.yml` (Single & Multi-Author).
- **[docs/template-guide.md](docs/template-guide.md)**: Penjelasan arsitektur `template.typ`, font Libertinus Serif, margin, dan penomoran bab otomatis Typst.
- **[docs/troubleshooting.md](docs/troubleshooting.md)**: Solusi lengkap masalah ImageMagick policy, font Typst, dan izin Docker.
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Pedoman berkontribusi, menambah template kampus baru, dan standar testing.
- **[CHANGELOG.md](CHANGELOG.md)**: Catatan riwayat versi dan perubahan fitur.

---

## Struktur File

```
laporan-generator/
├── laporan                  # CLI Helper interaktif Bash (Linux/macOS)
├── laporan.ps1              # CLI Helper native PowerShell (Windows)
├── GETTING-STARTED.md       # Panduan pemula (Zero to PDF)
├── CONTRIBUTING.md          # Panduan kontribusi open-source
├── CHANGELOG.md             # Catatan rilis versi
├── docs/                    # Dokumentasi teknis terpisah
│   ├── campus-guide.md      # Panduan preset kampus & PDF scanner
│   ├── preset-schema.md     # Spesifikasi skema preset YAML
│   ├── metadata-schema.md   # Skema metadata.yml
│   ├── template-guide.md    # Arsitektur template Typst
│   └── troubleshooting.md   # Solusi error lengkap
├── presets/                 # Preset format kampus resmi (UI, ITB, UGM, ITS, UNPAD)
├── examples/                # Contoh PDF laporan & mock pedoman kampus
├── .github/                 # Workflows CI/CD, Issue & PR templates
├── apa.csl                  # Citation Style Language (APA)
├── build.sh                 # Skrip build utama
├── template.typ             # Template Typst (font, margin preset, format)
├── metadata.yml             # Judul, penulis, dosen, matkul, preset
├── references.bib           # Daftar pustaka (BibTeX)
├── chapters/                # Konten laporan per bab (bab1-5)
├── cover.md                 # Kata pengantar
├── gambar/                  # Direktori gambar/screenshot laporan
├── logo.jpg                 # Logo kampus/sekolah (WAJIB ganti)
├── Makefile                 # Target build, watch, test, docker, init, view, docx
├── test.sh                  # Test suite (22 kategori tes / 91 assertions)
├── reference.docx           # Template gaya Word (A4, TNR 12pt, Heading 14pt)
├── docx.lua                 # Filter penomoran BAB/1.1./1.1.1 + cover DOCX
├── scripts/                 # Skrip bantu (report-stats.py, report-doctor.py, bundle.py, scan-preset.py, validate-preset.py, docx-pagenum.py)
├── flake.nix                # Nix devShell (pandoc, typst, ImageMagick, python3, tooling)
├── flake.lock               # Lockfile untuk environment reproducible
├── Dockerfile               # Container build (Ubuntu 22.04 + Pandoc + Typst + Python 3)
├── docker-compose.yml       # Docker orchestration (UID/GID user mapping)
└── prompt.md                # Protokol AI Agent interaktif untuk pembuatan berbagai karya ilmiah
```

---

## Alur Pipeline

```
chapters/bab*.md ---+                      
cover.md -----------+                      
metadata.yml -------+-- Pandoc --citeproc --+-- Typst ------ Laporan.pdf
references.bib -----+  --csl=apa.csl        |
template.typ -------+                       +-- Typst ------ Laporan.pdf
logo.jpg -----------+                       |
gambar/ ------------+                       +-- ImageMagick (alpha off)
apa.csl ------------+                       +-- Bash (tmpdir + trap)
                                            +-- container user (no root)

-- Opsi export Word (.docx) --
cover.md + chapters/bab*.md + metadata.yml -- Pandoc --reference-doc
    = reference.docx (A4, TNR, heading) + --lua-filter=docx.lua
    = Laporan.docx (cover page + field DAFTAR ISI otomatis Word)
```

---

## Lisensi

MIT License. Lihat [LICENSE](LICENSE) untuk detail.
