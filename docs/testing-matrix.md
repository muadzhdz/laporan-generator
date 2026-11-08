# Matriks Verifikasi Lintas Platform

Sebelum menyatakan rilis siap, jalankan suite Linux, verifikasi PowerShell native di Windows, dan pastikan job macOS hosted runner lulus di GitHub Actions. Catat OS, versi Node.js/Python/Pandoc/Typst, perintah, hasil, dan log kegagalan.

## Linux dengan Nix

```bash
nix develop --command bash -lc './test.sh'
python3 scripts/test_scripts.py
node tests/test_mcp.js
```

## Windows PowerShell

Jalankan dari root checkout pada PowerShell 7 atau Windows PowerShell 5.1. Jika dependensi belum ada, installer memakai winget atau binary portable dan memerlukan akses unduh.

```powershell
.\scripts\setup-deps.ps1 -Force
node --check bin/laporan-generator.js
node --check lib/mcp.js
node --check tests/test_mcp.js
python scripts/test_scripts.py
.\laporan.ps1 preset validate
node tests/test_mcp.js
$project = Join-Path $env:TEMP ("laporan-smoke-" + [guid]::NewGuid())
node bin/laporan-generator.js init $project --preset standard
if ($LASTEXITCODE -ne 0) { throw "Project initialization failed: $LASTEXITCODE" }
Push-Location $project
try {
  .\laporan.ps1 build
  if ($LASTEXITCODE -ne 0) { throw "PDF/DOCX build failed: $LASTEXITCODE" }
  if (-not (Test-Path Laporan.pdf) -or -not (Test-Path Laporan.docx)) { throw "Build outputs are missing" }
} finally {
  Pop-Location
}
```

Pastikan folder `chapters` pada proyek uji tidak berisi perubahan yang perlu disimpan; `build` menulis `Laporan.pdf` dan `Laporan.docx` ke direktori proyek.

## macOS

GitHub Actions menjalankan verifikasi pada runner macOS hosted. Untuk menjalankan lokal:

```bash
brew install pandoc typst imagemagick poppler lua
./test.sh
python3 scripts/test_scripts.py
node tests/test_mcp.js
./examples/build_examples.sh
```

## Kriteria Lulus

- Suite Linux lengkap lulus dan seluruh contoh dapat dibangun.
- PowerShell dapat menjalankan validasi preset dan MCP integration test dengan build PDF/DOCX sukses.
- Job macOS hosted runner lulus; ini menutup ketiadaan Mac lokal.
- Tidak ada versi API/kontrak yang berbeda antara paket, CLI, dokumentasi, dan tes.
- Kegagalan eksternal (unduhan, registry, atau layanan DOI) dicatat terpisah dan tidak dianggap lulus.
