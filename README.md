<p align="center">
  <img src="logo.jpg" alt="Laporan Generator" width="180"/>
</p>

<h1 align="center">Laporan Generator</h1>

<p align="center">
  <b>Universal Academic Document & Thesis Engine for AI Agents and Engineers</b><br/>
  Otomatisasi dokumen akademik dan teknis dari Markdown ke PDF berstandar publikasi dan Microsoft Word (DOCX) dalam hitungan detik.<br/>
  Mendukung pedoman resmi format penulisan kampus Indonesia (UI, ITB, UGM, ITS, UNPAD) dan standar internasional.
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/laporan-generator"><img src="https://img.shields.io/npm/v/laporan-generator?style=for-the-badge&color=cb3837&logo=npm" alt="npm version"></a>
  <a href="#dukungan-model-context-protocol-mcp"><img src="https://img.shields.io/badge/MCP-Native%20Server-8A2BE2?style=for-the-badge&logo=anthropic" alt="MCP Server"></a>
  <a href="https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml"><img src="https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml/badge.svg" alt="Status Build"></a>
  <a href="#"><img src="https://img.shields.io/badge/Typst-0.13+-239DAD?style=for-the-badge&logo=typst&logoColor=white" alt="Typst"></a>
  <a href="#"><img src="https://img.shields.io/badge/Pandoc-3.0+-blue?style=for-the-badge&logo=markdown" alt="Pandoc"></a>
  <a href="#"><img src="https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python"></a>
  <a href="#"><img src="https://img.shields.io/badge/Tests-101%20Passed-success?style=for-the-badge" alt="Pengujian Lulus"></a>
  <a href="#"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="Lisensi"></a>
</p>

<p align="center">
  <a href="GETTING-STARTED.md">Panduan Cepat</a> &bull;
  <a href="docs/campus-guide.md">Panduan Preset Kampus</a> &bull;
  <a href="docs/syntax-cheatsheet.md">Cheatsheet Sintaks</a> &bull;
  <a href="docs/metadata-schema.md">Skema Metadata</a> &bull;
  <a href="docs/troubleshooting.md">Penyelesaian Masalah</a> &bull;
  <a href="CHANGELOG.md">Catatan Perubahan</a>
</p>

---

## Ikhtisar

Laporan Generator adalah kompilator otomatisasi dokumen akademik berevolusi ganda (*dual-engine*) sekaligus kapabilitas terpadu untuk agen kecerdasan buatan (*AI Agent Skill*). Alat ini dirancang untuk menjembatani alur kerja rekayasa perangkat lunak modern dengan standar ketat format penulisan karya ilmiah perguruan tinggi.

Penyusunan makalah, laporan magang/praktik kerja lapangan (PKL), laporan proyek, hingga skripsi dan tesis kerap menguras waktu akibat proses penataan format manual di pengolah kata seperti Microsoft Word. Laporan Generator menuntaskan permasalahan ini secara menyeluruh langsung dari berkas sumber Markdown modular, yang dapat dikompilasi secara paralel menjadi:
1. **PDF Kualitas Publikasi**: Tipografi presisi tinggi berbasis mesin typesetting modern Typst.
2. **Microsoft Word Standar (.docx)**: Dokumen murni berbasis OpenXML dengan penataan hierarki heading yang rapi, bidang dinamis Daftar Isi (*TOC Field Codes*), serta penomoran halaman ganda (Romawi kecil untuk bagian awal dan angka Arab untuk batang tubuh bab).

Proyek ini juga memuat paket **AI Agent Skill** yang kompatibel dengan 10+ platform agen AI, memungkinkan agen cerdas menyusun draf, mengaudit sitasi, memindai pedoman kampus, dan membangun dokumen secara otonom.

---

## Sorotan Arsitektur

### Alur Kerja Pipeline Dual-Engine

```text
[ Berkas Sumber Markdown ]
├── cover.md (Kata Pengantar & Lembar Depan)
├── chapters/bab*.md (BAB I s.d. BAB V)
├── metadata.yml (Preset Kampus, Penulis, Dosen, Lembar Pengesahan)
└── references.bib (Basis Data Sitasi BibTeX)
          │
          ├──> [ Pipeline Mesin Typst ]
          │     ├── template.typ (Tata letak tipografi & margin dinamis)
          │     ├── ImageMagick (Normalisasi kanal alfa citra)
          │     └── typst compile ──> [ Laporan.pdf ]
          │
          └──> [ Pipeline Mesin Word/DOCX ]
                ├── Pandoc + docx.lua (Transformasi AST untuk heading BAB)
                ├── reference.docx (Gaya tipografi dasar TNR 12pt A4)
                ├── scripts/finalize-docx.py (Injeksi kode bidang TOC dinamis)
                └── scripts/docx-pagenum.py (Manipulasi OpenXML penomoran ganda) ──> [ Laporan.docx ]
```

### Fitur Rekayasa Unggulan

* **Penomoran Halaman Ganda Otomatis**:
  * Bagian Awal (Kata Pengantar, Daftar Isi, Daftar Gambar/Tabel, Abstrak): Penomoran angka Romawi kecil di tengah bawah (`i, ii, iii...`), dengan nomor pada halaman cover disembunyikan secara otomatis.
  * Bagian Utama (BAB I hingga Penutup dan Daftar Pustaka): Penomoran angka Arab (`1, 2, 3...`) yang diatur ulang dimulai dari halaman 1.
* **Daftar Isi Dinamis Microsoft Word Asli**:
  * Menggunakan kode bidang murni OpenXML (`w:fldSimple` / `w:instrText TOC \o "1-3" \h \z \u`).
  * Hierarki judul bab (`BAB I`, `1.1`, `1.1.1`) terdaftar dengan sempurna pada panel navigasi Word tanpa tumpang tindih teks atau kesalahan indentasi.
  * Kompatibel penuh dengan Microsoft Office 365, Word 2016-2021, LibreOffice Writer, dan WPS Office.
* **Penomoran Otomatis Bab, Gambar, dan Tabel**:
  * Penomoran gambar, tabel, dan persamaan matematika secara otomatis mengikat pada indeks bab aktif (contoh: `Gambar 1.1`, `Tabel 2.3`, `Persamaan (3.1)`).
  * Variabel counter di-reset secara otomatis pada setiap batas pergantian bab.
* **Keterampilan Agen AI Lintas Platform (Multi-Host AI Skill)**:
  * Terstruktur sesuai spesifikasi *Agent Skill Standard* lengkap dengan protokol wawancara interaktif 3 tahap di `SKILL.md`.
  * Dapat dideteksi dan dieksekusi langsung oleh Antigravity CLI, Claude Code, Grok, Codex/OpenAI, GitHub Copilot, Cursor, Roo-Code/Cline, OpenCode, dan Kiro-CLI.
* **Peralatan Audit & Penjaminan Mutu**:
  * `doctor`: Audit integritas dokumen untuk mendeteksi sitasi rusak/yatim, gambar yang tidak ditemukan di disk, struktur heading yang salah, dan kesalahan skema metadata.
  * `stats`: Analisis komprehensif jumlah kata, karakter, perkiraan durasi membaca, estimasi total halaman, dan inventaris media.
  * `bundle`: Pengemasan arsip rilis zip yang bersih dari berkas sementara untuk pengumpulan ke institusi.
  * `preset scan`: Pemindai otomatis dokumen PDF pedoman kampus untuk mengekstrak margin dan gaya heading ke konfigurasi YAML baru.

---

## Dukungan Host AI Agent

Laporan Generator mendistribusikan *skill* agen ke direktori global maupun lokal repositori:

| Host AI Agent | Direktori Konfigurasi / Skill | Protokol Pemanggilan |
|---|---|---|
| **Antigravity CLI** | `~/.gemini/antigravity-cli/skills/laporan-generator` | Prompt interaktif / Slash command |
| **Claude Code** | `~/.claude/skills/laporan-generator` | Slash command / Natural language |
| **Grok** | `~/.grok/skills/laporan-generator` | Deteksi skill agen global |
| **OpenCode** | `~/.config/opencode/skills/laporan-generator` | Tooling native agen |
| **Kiro-CLI** | `~/.kiro/agents/laporan-generator.json` | Sub-agen kustom |
| **Universal Agents** | `~/.agents/skills/laporan-generator` | Standar direktori `.agents/` |
| **Cursor / Copilot** | `.github/copilot-instructions.md`, `.cursor/rules` | Konfigurasi aturan repo |

Untuk menyinkronkan seluruh skill ke seluruh host yang terpasang di sistem dalam satu perintah:
```bash
npx laporan-generator sync-hosts
```

---

## Dukungan Model Context Protocol (MCP)

Laporan Generator v2.8.0 dilengkapi dengan **Native MCP Server** resmi yang berjalan melalui `stdio` berbasis protokol JSON-RPC 2.0 (spesifikasi 2024-11-05). Server ini memungkinkan AI Agent otonom (seperti Google Antigravity, Claude Desktop, Claude Code, dan OpenCode) untuk berinteraksi langsung dengan dokumen akademik melalui tools deterministik.

### Konfigurasi Otomatis (Direkomendasikan)
Cukup jalankan satu perintah berikut untuk mendaftarkan skill sekaligus konfigurasi MCP Server ke seluruh agent di mesin Anda:
```bash
npx laporan-generator sync-hosts
```

Perintah di atas secara aman mendaftarkan server `laporan` tanpa merusak konfigurasi server lain yang sudah ada:
* **Antigravity CLI**: `~/.gemini/config/mcp_config.json`
* **Claude Desktop**: `~/.config/Claude/claude_desktop_config.json`
* **Claude Code**: `~/.claude.json`
* **OpenCode**: `~/.config/opencode/opencode.jsonc`

### Konfigurasi Manual
Jika ingin mendaftarkan server secara manual pada klien MCP apa pun:
```json
{
  "mcpServers": {
    "laporan": {
      "command": "npx",
      "args": ["-y", "laporan-generator", "mcp"]
    }
  }
}
```

### 6 Native Tools MCP yang Disediakan

| Tool Name | Deskripsi Fungsi | Parameter Utama |
|---|---|---|
| `laporan_init` | Menginisialisasi dokumen baru (skripsi/makalah) secara terprogram | `target_dir`, `title`, `author`, `nim`, `institution`, `preset` |
| `laporan_doctor` | Mengaudit integritas dependensi, berkas wajib, sitasi, dan broken media | `target_dir`, `fix` (opsional) |
| `laporan_stats` | Menghitung statistik kata, bab, karakter, dan estimasi halaman | `target_dir` |
| `laporan_presets` | Memeriksa daftar dan detail konfigurasi preset kampus resmi | `action` (`list` / `get`), `preset_id` |
| `laporan_citations` | Memvalidasi integritas BibTeX dan pencarian sitasi langsung ke Crossref API | `action` (`validate` / `search`), `query`, `bib_path` |
| `laporan_build` | Mengompilasi dokumen ke PDF (Typst) dan/atau DOCX (Word) | `format` (`all` / `pdf` / `docx`), `preset` |

---

## Alur Penggunaan Cepat

### Opsi A: Alur Otonom AI Agent via NPX (Direkomendasikan)

Anda dapat membuat atau menginisialisasi dokumen baru di folder mana pun tanpa perlu melakukan kloning repositori:

```bash
# 1. Daftarkan kapabilitas Laporan Generator ke seluruh agen AI Anda
npx laporan-generator sync-hosts

# 2. Pasang dependensi sistem yang diperlukan (Typst, Pandoc, ImageMagick)
npx laporan-generator setup

# 3. Inisialisasi struktur dokumen akademik lengkap di direktori saat ini
npx laporan-generator init
```

Setelah inisialisasi selesai, buka antarmuka obrolan AI Agent Anda (Antigravity CLI, Claude Code, atau OpenCode), lalu berikan instruksi:
> *"Tolong buatkan draf Skripsi lengkap BAB 1 sampai BAB 3 dengan format ITB (preset itb-ta) berdasarkan topik sistem deteksi intrusi jaringan menggunakan eBPF."*

Agen AI akan membaca `SKILL.md`, menjalankan protokol wawancara interaktif 3 tahap, menerapkan preset kampus, menyusun konten bab, memvalidasi sitasi pada `references.bib`, menjalankan audit kesehatan `doctor`, dan membangun dokumen PDF serta Word secara otomatis.

---

### Opsi B: Alur Baris Perintah (CLI) Mandiri / Manual

Jika Anda ingin menulis dokumen secara manual dan mengompilasinya langsung via terminal:

#### Linux / macOS:
```bash
# Kloning repositori
git clone https://github.com/muadzhdz/laporan-generator.git tugas-akhir
cd tugas-akhir

# Periksa kelengkapan dependensi dan integritas berkas
./laporan check

# Bangun dokumen PDF dan DOCX
./laporan build

# Buka dokumen PDF hasil kompilasi
./laporan view
```

#### Windows (Native PowerShell 5.1+ / 7+ tanpa WSL):
```powershell
# Kloning repositori
git clone https://github.com/muadzhdz/laporan-generator.git tugas-akhir
cd tugas-akhir

# Periksa kelengkapan dependensi dan integritas berkas
.\laporan.ps1 check

# Bangun dokumen PDF dan DOCX
.\laporan.ps1 build

# Buka dokumen PDF hasil kompilasi
.\laporan.ps1 view
```

#### Lingkungan Nix Flake (Hermetik & Reproducible):
```bash
# Masuk ke isolated devShell dengan versi toolchain identik
nix develop

# Kompilasi dokumen di dalam lingkungan devShell
./laporan build
```

#### Lingkungan Docker (Tanpa Dependensi Sistem Host):
```bash
docker compose run --rm laporan-generator
```

---

## Matriks Perintah CLI

Seluruh perintah didukung secara konsisten di NPX, Linux/macOS Bash (`./laporan`), dan Windows PowerShell (`.\laporan.ps1`):

| Perintah | NPX (`npx laporan-generator`) | Bash (`./laporan`) | PowerShell (`.\laporan.ps1`) | Keterangan Fungsi |
|---|---|---|---|---|
| `mcp` | Didukung | Didukung | Didukung | Menjalankan Model Context Protocol (MCP) Server untuk AI Agent |
| `init` | Didukung | Didukung | Didukung | Menyalin template berkas, metadata, dan draf bab awal |
| `sync-hosts` | Didukung | Didukung | Didukung | Memasang skill ke seluruh direktori agen AI yang terdeteksi |
| `setup` | Didukung | Didukung | Didukung | Memasang paket sistem Typst, Pandoc, ImageMagick, dan Python |
| `check` | Didukung | Didukung | Didukung | Memeriksa ketersediaan toolchain dan kelengkapan berkas |
| `build` | Didukung | Didukung | Didukung | Mengompilasi berkas sumber menjadi `Laporan.pdf` dan `Laporan.docx` |
| `stats` | Didukung | Didukung | Didukung | Menghitung jumlah kata, karakter, estimasi halaman, dan gambar |
| `doctor` | Didukung | Didukung | Didukung | Melakukan audit integritas sitasi, gambar hilang, dan format heading |
| `bundle` | Didukung | Didukung | Didukung | Mengemas proyek menjadi arsip ZIP rilis yang bersih |
| `preset list` | Didukung | Didukung | Didukung | Menampilkan daftar seluruh preset format kampus resmi |
| `preset apply <id>`| Didukung | Didukung | Didukung | Menerapkan konfigurasi preset kampus tertentu ke `metadata.yml` |
| `preset scan <pdf>`| Didukung | Didukung | Didukung | Memindai berkas PDF pedoman kampus menjadi file preset YAML baru |
| `view` | - | Didukung | Didukung | Membuka berkas `Laporan.pdf` pada PDF viewer bawaan sistem |
| `watch` | - | Didukung | Didukung | Melakukan kompilasi ulang otomatis saat berkas sumber disimpan |
| `clean` | - | Didukung | Didukung | Membersihkan berkas hasil build dan folder sementara |
| `uninstall` | Didukung | Didukung | Didukung | Menghapus seluruh instalasi skill dari seluruh host agen AI |

---

## Preset Kampus Resmi

Konfigurasi tata letak bawaan yang disesuaikan dengan pedoman penulisan universitas di Indonesia:

| ID Preset | Institusi / Standar | Batas Margin (A-B-K-Kn) | Tipografi | Gaya Judul Bab | Keterangan Khusus |
|---|---|---|---|---|---|
| `standard` | Standar Akademik Umum | 2.5cm - 2.5cm - 3.0cm - 2.5cm | Times New Roman, 12pt | `BAB I` (Tengah) | Format standar makalah, proyek, dan magang |
| `skripsi-4433` | Standar Skripsi Nasional | 4.0cm - 3.0cm - 4.0cm - 3.0cm | Times New Roman, 12pt | `BAB I` (Tengah) | Standar jilid hardcover dengan margin kiri 4cm |
| `ui-skripsi` | Universitas Indonesia | 2.5cm - 2.5cm - 2.5cm - 2.5cm | Times New Roman, 12pt | `BAB 1` (Angka Arab) | Format resmi Buku Pedoman Teknis UI |
| `itb-ta` | Institut Teknologi Bandung | 4.0cm - 3.0cm - 4.0cm - 3.0cm | Times New Roman, 12pt | `BAB I` (Tengah) | Cover minimalis tanpa dosen pembimbing luar |
| `ugm-skripsi` | Universitas Gadjah Mada | 4.0cm - 3.0cm - 4.0cm - 3.0cm | Times New Roman, 12pt | `BAB I` (Tengah) | Format resmi pedoman tugas akhir & tesis UGM |
| `its-skripsi` | Institut Teknologi Sepuluh Nopember | 4.0cm - 3.0cm - 4.0cm - 3.0cm | Times New Roman, 12pt | `BAB 1` (Angka Arab) | Format baku buku Tugas Akhir ITS |
| `unpad-skripsi` | Universitas Padjadjaran | 4.0cm - 3.0cm - 4.0cm - 3.0cm | Times New Roman, 12pt | `BAB I` (Tengah) | Format penulisan skripsi & karya ilmiah UNPAD |

### Cara Mengaktifkan Preset
```bash
./laporan preset apply itb-ta
# atau
npx laporan-generator preset apply itb-ta
```

### Memindai Pedoman PDF Kampus Lain
Apabila universitas Anda belum terdaftar di atas, jalankan pemindai dokumen:
```bash
./laporan preset scan /path/ke/pedoman-skripsi.pdf
```
Pemindai akan menganalisis parameter margin, ukuran font, dan penomoran bab dari teks dokumen pedoman, lalu menghasilkan berkas preset berekstensi `.yml` yang siap digunakan di direktori `presets/`.

---

## Konfigurasi Dokumen (`metadata.yml`)

Seluruh struktur dokumen, judul, informasi kepenulisan, tanda tangan lembar pengesahan, dan abstrak bilingual dikendalikan terpusat melalui `metadata.yml`:

```yaml
title: "Analisis dan Implementasi Sistem Deteksi Intrusi Jaringan Berbasis eBPF"
document_type: "Skripsi"
margin_preset: "itb-ta"

# Kontrol Struktur Halaman Depan (Opt-In)
# Default struktur bersih: Cover -> Kata Pengantar -> Daftar Isi -> Batang Tubuh -> Daftar Pustaka
daftar_gambar: false   # Ubah true jika dokumen memuat gambar dan membutuhkan DAFTAR GAMBAR
daftar_tabel: false    # Ubah true jika dokumen memuat tabel dan membutuhkan DAFTAR TABEL

author:
  - name: "Mu'adz Hudzaifah"
    nim: "13522001"

institution: "Institut Teknologi Bandung"
faculty: "Sekolah Teknik Elektro dan Informatika"
department: "Teknik Informatika"
city: "Bandung"
year: "2026"
date: "14 September 2026"

course: "Tugas Akhir II"
lecturer: "Dr. Ir. Pembimbing Utama, M.T."

# Lembar Pengesahan
approval:
  city: "Bandung"
  date: "14 September 2026"
  supervisors:
    - name: "Dr. Ir. Pembimbing Utama, M.T."
      nip: "197501012000031001"
      role: "Pembimbing I"
    - name: "Dr. Eng. Pembimbing Pendamping, S.T."
      nip: "198002022005011002"
      role: "Pembimbing II"
  dean:
    name: "Prof. Dr. Dekan Fakultas, M.Sc."
    nip: "196803031992031003"
    role: "Dekan STEI"

# Abstrak Bahasa Indonesia
abstract_id: >
  Deteksi intrusi jaringan konvensional seringkali menimbulkan overhead performa yang signifikan...
keywords_id: ["eBPF", "Deteksi Intrusi", "Linux Kernel", "Keamanan Jaringan"]

# Abstrak Bahasa Inggris
abstract_en: >
  Conventional network intrusion detection systems frequently introduce notable performance overhead...
keywords_en: ["eBPF", "Intrusion Detection", "Linux Kernel", "Network Security"]
```

---

## Struktur Direktori

```text
laporan-generator/
├── bin/
│   └── laporan-generator.js       # Router CLI global untuk Node.js / NPX
├── lib/
│   ├── init.js                    # Modul inisialisasi dokumen baru
│   ├── setup.js                   # Wrapper instalasi dependensi sistem
│   ├── sync-hosts.js              # Distributor skill agen AI multi-host
│   └── uninstall.js               # Pembersih skill agen AI dari sistem
├── .agents/
│   ├── skills/laporan-generator/  # Standar Universal Agent Skill
│   │   ├── SKILL.md               # Instruksi dan protokol wawancara agen AI
│   │   ├── agents/                # Skema konfigurasi spesifik agen
│   │   ├── references/            # Rujukan skema YAML dan panduan teknis
│   │   ├── resources/             # Salinan berkas template dan utilitas
│   │   └── scripts/               # Skrip bantu audit dan kalkulasi dokumen
│   └── workflows/
│       └── laporan-generator.md   # Definisi perintah alur kerja slash command
├── chapters/
│   ├── bab1-pendahuluan.md        # Latar belakang, rumusan masalah, dan tujuan
│   ├── bab2-tinjauan-pustaka.md   # Landasan teori dan kajian literatur
│   ├── bab3-metodologi.md         # Desain arsitektur dan metodologi riset
│   ├── bab4-hasil-dan-pembahasan.md # Implementasi, pengujian, dan pembahasan
│   └── bab5-penutup.md            # Kesimpulan dan saran pengembangan
├── docs/                          # Dokumentasi teknis terperinci
├── presets/                       # Koleksi preset format resmi universitas
├── scripts/
│   ├── finalize-docx.py           # Injeksi kode bidang TOC murni pada Word
│   ├── docx-pagenum.py            # Penerapan sistem nomor halaman ganda Word
│   ├── make-reference-docx.py     # Pembangun berkas gaya reference.docx
│   ├── report-doctor.py           # Pemeriksa kesehatan & integritas berkas
│   ├── report-stats.py            # Kalkulator statistik kata dan halaman
│   ├── bundle.py                  # Utilitas pengemasan berkas rilis
│   ├── scan-preset.py             # Pemindai otomatis PDF pedoman kampus
│   ├── validate-preset.py         # Validator skema berkas preset YAML
│   ├── setup-deps.sh              # Skrip instalasi dependensi Unix
│   └── setup-deps.ps1             # Skrip instalasi dependensi PowerShell Windows
├── apa.csl                        # Format sitasi dan daftar pustaka standar APA 7th
├── build.sh                       # Skrip kompilasi utama Linux/macOS
├── build-docx.sh                  # Skrip kompilasi khusus dokumen Word
├── cover.md                       # Kata Pengantar dan halaman depan
├── docx.lua                       # Filter Pandoc Lua untuk transformasi AST Word
├── flake.nix                      # Konfigurasi lingkungan kerja Nix reproducible
├── laporan                        # Wrapper CLI interaktif Bash
├── laporan.ps1                    # Wrapper CLI native PowerShell Windows
├── Makefile                       # Target otomatisasi pengembang
├── metadata.yml                   # Konfigurasi aktif berkas dokumen
├── reference.docx                 # Dokumen template acuan gaya Microsoft Word
├── references.bib                 # Basis data pustaka format BibTeX
├── template.typ                   # Mesin typesetting dan tata letak Typst
└── test.sh                        # Rangkaian pengujian otomatis (101 assertions)
```

---

## Penjaminan Mutu & Pengujian

Laporan Generator dilengkapi rangkaian pengujian otomatis (*automated test suite*) yang memvalidasi pipeline Unix dan Windows, filter Lua, skrip manipulasi OpenXML, validasi preset, serta fungsionalitas CLI:

```bash
# Menjalankan pengujian
./test.sh
# atau
npm test
```

### Cakupan Pengujian (24 Test Suite / 101 Assertions)
* **Integritas Berkas**: Memverifikasi keberadaan seluruh template utama, skrip, dan skema acuan.
* **Pipeline Typst**: Memvalidasi rendering ukuran font, margin dinamis, logika penomoran bab, dan reset counter gambar/tabel.
* **Pipeline DOCX**: Memvalidasi transformasi AST Pandoc, filter Lua, field codes TOC OpenXML, dan nomor halaman ganda.
* **Validasi Preset**: Menguji seluruh preset bawaan terhadap skema spesifikasi YAML.
* **Perintah CLI**: Memverifikasi alur eksekusi `init`, `check`, `build`, `stats`, `doctor`, `bundle`, `preset`, dan `uninstall`.
* **Kebersihan & Keamanan**: Memastikan tidak ada berkas sampah biner, cache Python (`.pyc`), atau berkas temporer yang tertinggal.

---

## Pusat Dokumentasi

* **[Panduan Pemula (Zero to PDF)](GETTING-STARTED.md)**: Panduan langkah demi langkah dari instalasi hingga kompilasi pertama.
* **[Panduan Preset Kampus](docs/campus-guide.md)**: Rincian margin, tipografi, dan format penulisan antar universitas.
* **[Cheatsheet Sintaks Markdown](docs/syntax-cheatsheet.md)**: Panduan lengkap penulisan sitasi, rumus matematika, tabel, dan gambar.
* **[Skema Metadata](docs/metadata-schema.md)**: Referensi lengkap seluruh parameter pada `metadata.yml`.
* **[Skema Preset](docs/preset-schema.md)**: Spesifikasi format untuk membuat preset kampus baru.
* **[Panduan Template Typst](docs/template-guide.md)**: Arsitektur tipografi, font Libertinus Serif, dan aturan halaman.
* **[Penyelesaian Masalah (Troubleshooting)](docs/troubleshooting.md)**: Panduan penanganan kendala umum dependensi, font, dan izin sistem.
* **[Panduan Kontribusi](CONTRIBUTING.md)**: Pedoman pengembangan fitur baru dan penambahan preset.
* **[Catatan Perubahan (Changelog)](CHANGELOG.md)**: Riwayat pembaruan dan rilis versi.

---

## Lisensi

Didistribusikan di bawah lisensi MIT. Silakan baca berkas [LICENSE](LICENSE) untuk informasi lebih lanjut.
