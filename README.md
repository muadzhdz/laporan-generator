# Laporan Generator

[![npm](https://img.shields.io/npm/v/laporan-generator)](https://www.npmjs.com/package/laporan-generator)
[![Build](https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml/badge.svg)](https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

CLI untuk menyusun laporan akademik dari Markdown menjadi PDF (Typst) dan DOCX. Tersedia preset format, pemeriksaan dokumen, ekspor materi, dan integrasi MCP untuk AI agent.

## Mulai cepat

Pasang [Node.js 18+](https://nodejs.org/), Pandoc, Typst, dan ImageMagick. Di Linux, dependensi juga tersedia melalui Nix flake proyek ini.

```sh
npm install -g laporan-generator
laporan init skripsi-saya --preset standard
cd skripsi-saya
laporan build
```

`laporan build` menghasilkan `Laporan.pdf` dan `Laporan.docx`. Untuk menjalankan tanpa instalasi global, gunakan `npx laporan-generator`.

## Perintah utama

| Perintah | Fungsi |
| --- | --- |
| `laporan init <folder>` | Buat proyek dokumen |
| `laporan build` | Buat PDF dan DOCX |
| `laporan preset list` | Lihat preset yang tersedia |
| `laporan doctor` | Periksa struktur, gambar, dan sitasi |
| `laporan import <file>` | Ekstrak materi dokumen ke Markdown |
| `laporan help` | Lihat seluruh perintah |

Gunakan `laporan init skripsi-saya --preset ui-skripsi` untuk memilih preset saat membuat proyek. Preset kampus adalah konfigurasi awal; cocokkan hasilnya dengan pedoman fakultas atau program studi terbaru.

## Nix

```sh
nix develop
./laporan build templates/default
```

## Integrasi MCP

Tambahkan server berikut ke konfigurasi MCP host yang digunakan:

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

## Dokumentasi

- [Panduan memulai](GETTING-STARTED.md)
- [Panduan preset dan sumbernya](docs/campus-guide.md) · [cakupan dan status verifikasi](docs/preset-sources.md)
- [Skema metadata](docs/metadata-schema.md) · [panduan template](docs/template-guide.md)
- [Panduan prompt AI](docs/prompt.md) · [Matriks pengujian](docs/testing-matrix.md)
- [Pemecahan masalah](docs/troubleshooting.md) · [catatan rilis](CHANGELOG.md)
- [Rilis ke npm](docs/npm-publishing.md)
- [Kontribusi](CONTRIBUTING.md)

Perubahan JSON audit pada v4.0.0 dijelaskan di [panduan migrasi](docs/migrations/v4.0.0.md). Skor audit adalah heuristik pola tulisan, bukan probabilitas penggunaan AI atau bukti kepengarangan.

## Lisensi

[MIT](LICENSE) © Mu'adz Hudzaifah
