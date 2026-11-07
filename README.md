<p align="center">
  <img src="templates/default/logo.jpg" alt="Laporan Generator" width="140"/>
</p>

<h1 align="center">Laporan Generator</h1>

<p align="center">
  <b>Engine Dokumen Akademik & Skripsi Universal untuk AI Agent dan Engineer</b><br/>
  Kompilasi Markdown modular menjadi PDF berstandar publikasi (Typst) dan Microsoft Word (DOCX) dalam hitungan detik.<br/>
  Dikonfigurasi sesuai pedoman resmi perguruan tinggi Indonesia (UI, ITB, UGM, ITS, UNDIP, UNAIR, UB, UNPAD, IPB, Telkom).
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/laporan-generator"><img src="https://img.shields.io/npm/v/laporan-generator?style=flat-square&color=cb3837&logo=npm" alt="npm version"></a>
  <a href="https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml"><img src="https://img.shields.io/github/actions/workflow/status/muadzhdz/laporan-generator/build.yml?style=flat-square&logo=github" alt="Build Status"></a>
  <a href="#server-native-mcp-20"><img src="https://img.shields.io/badge/MCP-Native%202.0-8A2BE2?style=flat-square&logo=anthropic" alt="MCP Server"></a>
  <a href="#"><img src="https://img.shields.io/badge/Typst-0.15+-239DAD?style=flat-square&logo=typst&logoColor=white" alt="Typst"></a>
  <a href="#"><img src="https://img.shields.io/badge/Tests-137%20Passed-success?style=flat-square" alt="Tests"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License"></a>
</p>

---

## Instalasi & Memulai Cepat (60 Detik)

### 1. Pasang CLI Secara Global (Direkomendasikan)
```bash
npm install -g laporan-generator
```
*(Atau gunakan langsung tanpa instalasi melalui `npx laporan-generator <perintah>`)*

### 2. Inisialisasi Proyek Dokumen Baru
Buat folder dan template dokumen otomatis sesuai kebutuhan Anda:

```bash
# Opsi A: Inisialisasi Skripsi / Tugas Akhir (Format UI, ITB, UGM, ITS, Tel-U, dll.)
laporan init skripsi-ku --preset ui-skripsi

# Opsi B: Inisialisasi Artikel Jurnal Ilmiah (Format IMRaD, IEEE CSL, UAJY JBI)
laporan init paper-jurnal --preset jurnal-uajy

# Masuk ke direktori dokumen
cd skripsi-ku/
```

### 3. Kompilasi Dokumen ke PDF & Word (DOCX)
```bash
# Kompilasi langsung menghasilkan Laporan.pdf dan Laporan.docx secara sinkron
laporan build

# Buka berkas PDF di viewer bawaan
laporan view
```

---

## Dua Paradigma Dokumen: Skripsi vs Jurnal Ilmiah

Laporan Generator mendukung dua mode dokumen secara terpadu melalui atribut `doc_type`:

| Parameter | Mode Skripsi (`doc_type: "thesis"`) | Mode Jurnal (`doc_type: "journal"`) |
| :--- | :--- | :--- |
| **Halaman Depan** | Sampul formal, Kata Pengantar, Daftar Isi (TOC) | Single-Header di Halaman 1 (Judul, Penulis, Afiliasi, Abstrak) |
| **Penomoran** | Dua tingkat: Romawi (*i, ii, iii*) & Arab (*1, 2, 3*) | Nomor seksi standar (`1. PENDAHULUAN`, `2. METODE...`) |
| **Struktur Bab** | BAB I s.d. BAB V modular | Format IMRaD (Pendahuluan, Metode, Hasil, Kesimpulan) |
| **Standar Sitasi** | APA 7th Edition (`apa.csl`) | IEEE Numeric Style (`ieee.csl`, sitasi `[1]`, `[2]`) |
| **Preset Kampus** | `ui-skripsi`, `itb-ta`, `ugm-skripsi`, `its-skripsi`, dst. | `jurnal-uajy` (JBI UAJY), `jurnal-standar` (SINTA) |

---

## 14 Preset Format Kampus & Jurnal Bawaan

Pilih preset melalui perintah `laporan preset apply <id>` atau konfigurasi `metadata.yml`:

| ID Preset | Institusi / Publikasi | Margin (Atas - Kiri - Bawah - Kanan) | Karakteristik Khusus |
| :--- | :--- | :--- | :--- |
| `standard` | Standar Akademik Umum | 2.0 cm - 2.5 cm - 3.0 cm - 2.5 cm | Format modern serbaguna |
| `skripsi-4433`| Standar Nasional | 4.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Hardcover jilid skripsi tradisional |
| `ui-skripsi` | Universitas Indonesia (UI) | 3.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Pedoman Teknis Tugas Akhir UI |
| `itb-ta` | Institut Teknologi Bandung (ITB) | 4.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Sampul minimalis sesuai panduan ITB |
| `ugm-skripsi`| Universitas Gadjah Mada (UGM) | 4.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Pedoman resmi skripsi UGM |
| `its-skripsi`| Institut Teknologi Sepuluh Nopember | 3.0 cm - 3.0 cm - 2.5 cm - 2.0 cm | Standar buku pedoman TA ITS |
| `unpad-skripsi`| Universitas Padjadjaran (UNPAD) | 4.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Pedoman skripsi UNPAD |
| `ub-skripsi` | Universitas Brawijaya (UB) | 4.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Pedoman penulisan skripsi UB |
| `undip-skripsi`| Universitas Diponegoro (UNDIP) | 4.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Pedoman karya ilmiah UNDIP |
| `unair-skripsi`| Universitas Airlangga (UNAIR) | 4.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Standar skripsi UNAIR |
| `ipb-ppki` | IPB University | 3.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Pedoman PPKI IPB (Indent 1cm, sub-bab bersih) |
| `telkom-ta` | Telkom University (Tel-U) | 3.0 cm - 4.0 cm - 3.0 cm - 3.0 cm | Buku Pedoman TA Telkom University |
| `jurnal-uajy` | Univ. Atma Jaya Yogyakarta | 3.0 cm - 3.0 cm - 3.0 cm - 3.0 cm | Jurnal Berita Informatika (JBI), 11pt, IEEE |
| `jurnal-standar`| Jurnal Nasional / SINTA | 3.0 cm - 3.0 cm - 3.0 cm - 3.0 cm | Format IMRaD publikasi ilmiah nasional |

---

## Perintah Baris Perintah (CLI) Terpadu

```text
1. KOMPILASI & PRATINJAU:
  laporan build               Kompilasi PDF dan Word DOCX sekaligus
  laporan pdf                 Kompilasi hanya dokumen PDF via Typst (sub-detik)
  laporan docx                Kompilasi hanya dokumen Microsoft Word DOCX
  laporan view                Buka Laporan.pdf di viewer sistem
  laporan watch               Pantau perubahan markdown dan auto-rebuild live
  laporan clean               Bersihkan berkas keluaran dan file sementara

2. DIAGNOSTIK & KUALITAS AKADEMIK:
  laporan doctor              Audit kesehatan dokumen (gambar, sitasi, heading, box-drawing)
  laporan audit --strict      Audit forensik stylometri naskah dan deteksi anti-AI-slop
  laporan citations verify    Verifikasi keabsahan tautan DOI secara real-time via CrossRef
  laporan stats               Hitung statistik komprehensif dokumen (kata, bab, estimasi halaman)

3. MANAJEMEN PROYEK & FORMAT:
  laporan init <nama-folder>  Inisialisasi workspace dokumen baru di folder tertentu
  laporan import <berkas>     Konversi DOCX, PDF, PPTX, XLSX menjadi bab Markdown
  laporan preset list         Tampilkan seluruh 14 preset kampus & jurnal
  laporan preset apply <id>   Terapkan konfigurasi preset ke metadata.yml
  laporan bundle              Kemas seluruh hasil kompilasi menjadi arsip zip rilis
```

---

## Gambaran Arsitektur

```text
[ Berkas Sumber ]                  [ Engine Kompilasi ]                 [ Hasil Akhir ]
cover.md         ──┐
chapters/bab*.md ──┼──> [ Pipeline Typst Asli ] ────────────────> Laporan.pdf (Sub-detik)
metadata.yml     ──┼──> [ Single-Pass OpenXML Engine ] ─────────> Laporan.docx (Dua tingkat nomor)
references.bib   ──┘
```

---

## Kemampuan Utama

| Fitur | Deskripsi |
| :--- | :--- |
| **Kompilasi Cepat Typst** | Tipografi presisi tinggi selesai dalam waktu kurang dari 1 detik. Bebas beban ketergantungan LaTeX. |
| **Dual-Engine DOCX Asli** | Dokumen Microsoft Word asli dengan penomoran dua tingkat otomatis (*i, ii, iii* dan *1, 2, 3*) serta Daftar Isi interaktif. |
| **14 Preset Kampus & Jurnal** | Konfigurasi bawaan skripsi UI, ITB, UGM, ITS, UNDIP, UNAIR, UB, UNPAD, IPB, Telkom, serta artikel jurnal ilmiah (UAJY JBI & IEEE). |
| **Forensik Stylometry & Anti-Slop** | Audit ritme kalimat, Moving-Average Type-Token Ratio (MATTR), deteksi klise AI / RLHF, dan pencegahan degradasi mutu via `laporan audit`. |
| **Verifikasi Sitasi CrossRef** | Pengecekan keabsahan DOI secara real-time via CrossRef API dengan caching lokal via `laporan citations verify`. |
| **Pipeline Ingesti Dokumen** | Ekstraksi dan konversi materi `.docx`, `.pdf`, `.pptx`, dan `.xlsx` menjadi bab Markdown bersih via `laporan import`. |
| **Server Native MCP 2.0** | AI Agent dapat menginisialisasi dokumen, mencari DOI sitasi, mengaudit kesehatan berkas, dan mengompilasi secara otonom. |

---

## Server Native MCP 2.0 (Untuk AI Agent)

Laporan Generator menyertakan server **Model Context Protocol (MCP)** bawaan yang kompatibel dengan Antigravity, Claude Code, Cursor, dan OpenCode.

Sinkronisasi skill secara otomatis ke host AI lokal Anda:

```bash
npx laporan-generator sync-hosts
```

Konfigurasi manual (`claude_desktop_config.json` atau `mcp_config.json`):

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

---

## Indeks Dokumentasi

* [Panduan Memulai & Alur Kerja](GETTING-STARTED.md) — Panduan praktis 5 menit dari inisialisasi hingga kompilasi.
* [Prompt AI Academic Engineering](docs/prompt.md) — Panduan instruksi sistem untuk AI Agent (Antigravity, Claude, OpenCode).
* [Direktori Preset Kampus](docs/campus-guide.md) — Spesifikasi format resmi perguruan tinggi.
* [Skema Konfigurasi Metadata](docs/metadata-schema.md) — Dokumentasi lengkap opsi `metadata.yml`.
* [Skema Spesifikasi Preset](docs/preset-schema.md) — Panduan struktur konfigurasi berkas `presets/*.yml`.
* [Lembar Contekan Sintaks](docs/syntax-cheatsheet.md) — Panduan penulisan rumus, gambar, tabel, dan sitasi.
* [Pemecahan Masalah](docs/troubleshooting.md) — Panduan instalasi dan resolusi kendala lingkungan kerja.
* [Catatan Rilis](CHANGELOG.md) — Riwayat perubahan dan versi SemVer.

---

## Lisensi

MIT © [Mu'adz Hudzaifah](https://github.com/muadzhdz).
