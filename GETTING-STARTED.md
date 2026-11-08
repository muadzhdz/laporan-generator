# Panduan Memulai: Zero to Document (Laporan Generator v4.0.0)

Selamat datang di **Laporan Generator v4.0.0** — engine kompilasi dokumen akademik universal berbasis **Typst (PDF)** dan **Pandoc + OpenXML (Word DOCX)** untuk AI Agent, mahasiswa, dan software engineer.

---

## 1. Pilihan Alur Kerja (Workflow)

Pilih jalur yang paling sesuai dengan kebutuhan Anda:

| Jalur | Prasyarat | Skenario Penggunaan |
| :--- | :--- | :--- |
| **[A. npx / Global CLI](#opsi-a-npx--global-cli-direkomendasikan)** | Node.js v18+ | Membuat dokumen skripsi/jurnal baru di folder mana saja tanpa clone git |
| **[B. Native MCP Server](#opsi-b-native-mcp-server-untuk-ai-agent)** | Antigravity / Claude Code / Cursor | AI Agent mengelola pembuatan, audit, sitasi, dan kompilasi secara otonom |
| **[C. Nix Flake](#opsi-c-nix-flake-bebas-konflik-sistem)** | Nix (`nix develop`) | Lingkungan terisolasi otomatis dengan Pandoc, Typst, Python, dan CSL |
| **[D. Docker Container](#opsi-d-docker-container)** | Docker Desktop | Kompilasi tanpa menginstall dependensi lokal di sistem operasi |

---

## Opsi A: npx / Global CLI (Direkomendasikan)

Anda tidak perlu meng-clone repositori ini ke project skripsi Anda. Gunakan perintah `npx` langsung:

### 1. Inisialisasi Proyek Baru
```bash
# Inisialisasi dokumen skripsi dengan preset kampus (misal: UI, ITB, UGM, ITS, Telkom)
npx laporan-generator init skripsi-saya --preset ui-skripsi

# Atau inisialisasi artikel jurnal ilmiah (format IMRaD, IEEE CSL, UAJY JBI)
npx laporan-generator init paper-jurnal --preset jurnal-uajy

cd skripsi-saya/
```

### 2. Struktur Proyek yang Dihasilkan
```text
skripsi-saya/
├── metadata.yml       # Konfigurasi judul, penulis, institusi, preset, dan flag opt-in
├── cover.md           # Halaman pengantar dan kata pengantar (dilewati pada mode jurnal)
├── chapters/          # Bab-bab dokumen dalam format Markdown modular
│   ├── bab1-pendahuluan.md
│   ├── bab2-tinjauan-pustaka.md
│   ├── bab3-metodologi.md
│   ├── bab4-hasil-pembahasan.md
│   └── bab5-penutup.md
├── references.bib     # Database sitasi BibTeX
├── logo.jpg           # Logo resmi institusi
├── build.sh           # Runner kompilasi Typst PDF lokal
├── build-docx.sh      # Runner kompilasi Word OpenXML DOCX lokal
├── laporan            # CLI helper Bash (Linux / macOS)
└── laporan.ps1        # CLI helper PowerShell (Windows native)
```

### 3. Audit Pra-Kompilasi (Health & Writing Patterns)
Sebelum kompilasi, verifikasi integritas dokumen dan tinjau pola tulisan:

```bash
# 1. Audit kesehatan dokumen (cek sitasi hilang, gambar rusak, heading manual, box-drawing)
./laporan doctor

# 2. Periksa resolusi DOI dan metadata sitasi via Crossref
./laporan citations verify

# 3. Tinjau pola tulisan (heuristik; bukan detektor AI atau pemeriksa orisinalitas)
./laporan audit
```

### 4. Kompilasi PDF & Word DOCX
```bash
# Kompilasi langsung menjadi Laporan.pdf dan Laporan.docx
./laporan build

# Atau buat hanya DOCX
./laporan docx

# Buka PDF di penampil dokumen bawaan
./laporan view
```

---

## Opsi B: Native MCP Server (Untuk AI Agent)

Jika Anda menggunakan AI Assistant seperti **Antigravity**, **Claude Code**, **OpenCode**, atau **Cursor**:

### 1. Daftarkan Server MCP
Jalankan sinkronisasi otomatis ke host lokal:
```bash
npx laporan-generator sync-hosts
```

Atau tambahkan ke konfigurasi MCP client Anda (`claude_desktop_config.json` / `antigravity.json`):
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

### 2. Tool MCP yang Siap Digunakan AI
- `laporan_init`: Inisialisasi workspace dokumen dengan parameter preset kampus.
- `laporan_presets`: Membaca konfigurasi awal margin dan aturan bab dari 14 preset kampus/jurnal.
- `laporan_citations`: Pencarian DOI nyata di CrossRef dan penambahan BibTeX ke `references.bib`.
- `laporan_verify_citations`: Audit keabsahan tautan DOI secara daring atau luring.
- `laporan_doctor`: Audit diagnostik kelengkapan berkas dan sintaks.
- `laporan_audit`: Tinjauan heuristik variasi kalimat dan pola tulisan; bukan detektor AI.
- `laporan_stats`: Menghitung statistik kata, bab, dan estimasi tebal halaman.
- `laporan_import`: Ekstraksi berkas `.docx`, `.pdf`, `.pptx`, `.xlsx` menjadi bab Markdown.
- `laporan_build`: Kompilasi otonom menjadi `Laporan.pdf` dan `Laporan.docx`.

---

## Opsi C: Nix Flake (Bebas Konflik Sistem)

Jika Anda menggunakan Linux atau macOS dengan Nix:

```bash
# Masuk ke shell dengan dependensi lengkap (Pandoc 3.7+, Typst 0.15+, Python 3.14, ImageMagick)
nix develop

# Jalankan perintah kompilasi di dalam shell terisolasi
./laporan build
```

---

## Opsi D: Docker Container

Kompilasi dokumen tanpa menginstal package apa pun di OS host:

```bash
# Build PDF di dalam container
docker compose run --rm laporan-generator

# Mode auto-rebuild saat berkas Markdown disimpan
docker compose run --rm watch
```

---

## 2. Mode Dokumen: Skripsi vs Artikel Jurnal

Laporan Generator mendukung dua paradigma dokumen:

### A. Mode Skripsi / Tugas Akhir / Tesis (`doc_type: "thesis"`)
- **Struktur**: Sampul Depan $\to$ Lembar Pengesahan (opt-in) $\to$ Kata Pengantar $\to$ Daftar Isi $\to$ Batang Tubuh (BAB I s.d. BAB V) $\to$ Daftar Pustaka.
- **Penomoran**: Angka Romawi kecil (`i, ii, iii`) pada bagian depan dan Angka Arab (`1, 2, 3`) pada bab utama.
- **Heading**: Awalan otomatis `BAB I PENDAHULUAN`, `1.1 Latar Belakang`.
- **Gaya Sitasi Default**: APA 7th Edition (`apa.csl`).

### B. Mode Artikel Jurnal Ilmiah (`doc_type: "journal"`)
- **Preset Rekomendasi**: `jurnal-uajy` (JBI UAJY) atau `jurnal-standar` (IEEE/SINTA).
- **Struktur**: Halaman 1 langsung memuat Judul Jurnal, Blok Penulis & Afiliasi, Email, Abstrak Indonesia & Inggris, Kata Kunci, dilanjutkan langsung Bab 1 (IMRaD).
- **Heading**: Tanpa prefix kata "BAB", menggunakan nomor seksi `1. PENDAHULUAN`, `2. METODE PENELITIAN`.
- **Gaya Sitasi Default**: IEEE Style (`ieee.csl`, sitasi numerik `[1]`, `[2]`).

---

## 3. Aturan Penulisan Sintaks Markdown

1. **Heading**:
   - Level 1: `# PENDAHULUAN` (Jangan tulis `# BAB I PENDAHULUAN`).
   - Level 2: `## Latar Belakang` (Jangan tulis `## 1.1 Latar Belakang`).
2. **Sitasi**:
   - Format APA: `[@knuth1984]` $\to$ *(Knuth, 1984)*.
   - Format IEEE: `[@knuth1984]` $\to$ *[1]*.
3. **Gambar**:
   - Letakkan di folder `gambar/` dan panggil via `![Keterangan Gambar](gambar/arsitektur.png)`.
4. **Tabel**:
   - Gunakan Pipe Table standar Markdown. Hindari karakter box-drawing Unicode (`┌`, `─`, `│`).
5. **Rumus Matematika**:
   - Inline: `$f(x) = wx + b$`.
   - Display: `$$MSE = \frac{1}{n}\sum_{i=1}^n (y_i - \hat{y}_i)^2$$`.

---

## 4. Indeks Dokumentasi Lanjutan

- [Direktori Preset Kampus](docs/campus-guide.md) — Panduan spesifikasi 14 format perguruan tinggi dan jurnal.
- [Skema Metadata](docs/metadata-schema.md) — Konfigurasi lengkap atribut `metadata.yml`.
- [Skema Preset](docs/preset-schema.md) — Cara membuat atau memodifikasi file konfigurasi preset `presets/*.yml`.
- [Prompt AI Engineering](docs/prompt.md) — Panduan instruksi sistem untuk AI Agent.
- [Lembar Contekan Sintaks](docs/syntax-cheatsheet.md) — Format tabel, gambar, rumus, dan sitasi.
- [Pemecahan Masalah](docs/troubleshooting.md) — Solusi kesalahan dependensi, font, dan kompilasi.
