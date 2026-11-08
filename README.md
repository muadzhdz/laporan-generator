<p align="center">
  <img src="templates/default/logo.jpg" alt="Laporan Generator" width="140" />
</p>

<h1 align="center">Laporan Generator</h1>

<p align="center">
  <a href="https://www.npmjs.com/package/laporan-generator"><img src="https://img.shields.io/npm/v/laporan-generator?style=flat-square&color=cb3837&logo=npm" alt="Versi npm" /></a>
  <a href="https://github.com/muadzhdz/laporan-generator/actions/workflows/build.yml?query=branch%3Amain"><img src="https://img.shields.io/github/actions/workflow/status/muadzhdz/laporan-generator/build.yml?branch=main&style=flat-square&logo=github&label=Build%20(main)" alt="Build branch main" /></a>
  <a href="https://www.npmjs.com/package/laporan-generator"><img src="https://img.shields.io/npm/dw/laporan-generator?style=flat-square&label=unduhan%2Fminggu" alt="Unduhan npm per minggu" /></a>
  <a href="https://github.com/muadzhdz/laporan-generator/releases"><img src="https://img.shields.io/github/v/release/muadzhdz/laporan-generator?style=flat-square&label=rilis" alt="Rilis GitHub terbaru" /></a>
  <a href="https://github.com/muadzhdz/laporan-generator"><img src="https://img.shields.io/github/stars/muadzhdz/laporan-generator?style=flat-square" alt="GitHub stars" /></a>
  <a href="#integrasi-mcp"><img src="https://img.shields.io/badge/MCP-Native%202.0-8A2BE2?style=flat-square&logo=anthropic" alt="MCP server" /></a>
  <a href="https://typst.app/"><img src="https://img.shields.io/badge/Typst-0.15%2B-239DAD?style=flat-square&logo=typst&logoColor=white" alt="Typst 0.15+" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/muadzhdz/laporan-generator?style=flat-square" alt="Lisensi MIT" /></a>
</p>

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

## Lisensi

[MIT](LICENSE) © Mu'adz Hudzaifah
