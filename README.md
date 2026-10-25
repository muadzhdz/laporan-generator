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
  <a href="#"><img src="https://img.shields.io/badge/Tests-119%20Passed-success?style=flat-square" alt="Tests"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License"></a>
</p>

---

## Memulai Cepat (30 Detik)

Inisialisasi workspace dokumen skripsi dan kompilasi langsung:

```bash
# 1. Inisialisasi proyek dengan preset kampus (misal: Universitas Indonesia)
npx laporan-generator init --preset ui-skripsi

# 2. Kompilasi langsung menjadi PDF dan DOCX
./laporan build
```

> **Catatan:** Anda juga dapat menjalankannya via **Nix Flake** tanpa instalasi manual di sistem:  
> `nix develop --command ./laporan build`

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
| **12+ Preset Kampus Resmi** | Konfigurasi bawaan margin (4-4-3-3), tipografi, dan aturan bab untuk UI, ITB, UGM, ITS, UNDIP, UNAIR, UB, UNPAD, IPB, Telkom, dll. |
| **Pipeline Ingesti Dokumen** | Ekstraksi dan konversi materi `.docx`, `.pdf`, `.pptx`, dan `.xlsx` menjadi bab Markdown bersih via `laporan import`. |
| **Server Native MCP 2.0** | AI Agent dapat memeriksa pedoman kampus, mencari DOI sitasi, mengaudit kesehatan berkas, dan mengompilasi dokumen secara otonom. |

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
* [Direktori Preset Kampus](docs/campus-guide.md) — Spesifikasi format resmi perguruan tinggi.
* [Skema Konfigurasi Metadata](docs/metadata-schema.md) — Dokumentasi lengkap opsi `metadata.yml`.
* [Lembar Contekan Sintaks](docs/syntax-cheatsheet.md) — Panduan penulisan rumus, gambar, tabel, dan sitasi.
* [Pemecahan Masalah](docs/troubleshooting.md) — Panduan instalasi dan resolusi kendala lingkungan kerja.
* [Catatan Rilis](CHANGELOG.md) — Riwayat perubahan dan versi SemVer.

---

## Lisensi

MIT © [Mu'adz Hudzaifah](https://github.com/muadzhdz).
