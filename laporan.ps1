# ==============================================================================
# Laporan Generator CLI Helper for Windows PowerShell (.\laporan.ps1)
# ==============================================================================
param (
    [Parameter(Position=0)]
    [string]$Command = "help",
    [Parameter(Position=1)]
    [string]$SubCommand = "",
    [Parameter(Position=2)]
    [string]$Arg1 = "",
    [Parameter(Position=3)]
    [string]$Arg2 = ""
)

$ErrorActionPreference = "Stop"

function Show-Banner {
    Write-Host "  ========================================================" -ForegroundColor Cyan
    Write-Host "                 LAPORAN GENERATOR CLI v2.4.0             " -ForegroundColor Cyan
    Write-Host "     Otomatisasi Dokumen Akademik (Typst + DOCX Engine)   " -ForegroundColor Cyan
    Write-Host "  ========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Help {
    Show-Banner
    Write-Host "Penggunaan: .\laporan.ps1 <perintah>" -ForegroundColor White
    Write-Host ""
    Write-Host "Perintah yang Tersedia:" -ForegroundColor White
    Write-Host "  build        Kompilasi PDF dan DOCX sekaligus" -ForegroundColor Green
    Write-Host "  pdf          Kompilasi dokumen PDF (via Typst)" -ForegroundColor Green
    Write-Host "  docx         Kompilasi dokumen Microsoft Word (.docx)" -ForegroundColor Green
    Write-Host "  init         Wizard interaktif untuk konfigurasi awal metadata" -ForegroundColor Green
    Write-Host "  preset       Kelola preset format kampus (list/show/apply/validate/diff/scan)" -ForegroundColor Green
    Write-Host "  stats        Analisis statistik kata, halaman, gambar, dan durasi baca" -ForegroundColor Green
    Write-Host "  doctor       Audit kesehatan proyek (broken images, sitasi hilang, dll.)" -ForegroundColor Green
    Write-Host "  bundle       Kemas seluruh laporan (PDF, DOCX, MD) menjadi arsip zip" -ForegroundColor Green
    Write-Host "  check        Audit dependensi sistem dan struktur proyek" -ForegroundColor Green
    Write-Host "  test         Jalankan suite pengujian otomatis" -ForegroundColor Green
    Write-Host "  view         Buka dokumen Laporan.pdf di PDF viewer" -ForegroundColor Green
    Write-Host "  clean        Bersihkan berkas output dan direktori sementara" -ForegroundColor Green
    Write-Host "  help         Tampilkan panduan bantuan ini" -ForegroundColor Green
    Write-Host ""
    Write-Host "Contoh:" -ForegroundColor Yellow
    Write-Host "  .\laporan.ps1 build"
    Write-Host "  .\laporan.ps1 stats"
    Write-Host "  .\laporan.ps1 preset list"
    Write-Host "  .\laporan.ps1 preset apply itb-ta"
}

function Cmd-Check {
    Show-Banner
    Write-Host "[1/2] Memeriksa Dependensi Sistem..." -ForegroundColor Blue

    $pyFound = Get-Command "python" -ErrorAction SilentlyContinue
    if (-not $pyFound) { $pyFound = Get-Command "python3" -ErrorAction SilentlyContinue }

    $imFound = Get-Command "magick" -ErrorAction SilentlyContinue
    if (-not $imFound) { $imFound = Get-Command "convert" -ErrorAction SilentlyContinue }

    $deps = @(
        @{ Name="Pandoc"; Cmd="pandoc"; Found=(Get-Command "pandoc" -ErrorAction SilentlyContinue); Req=$true },
        @{ Name="Typst"; Cmd="typst"; Found=(Get-Command "typst" -ErrorAction SilentlyContinue); Req=$true },
        @{ Name="ImageMagick"; Cmd="magick/convert"; Found=$imFound; Req=$false },
        @{ Name="Python 3"; Cmd="python/python3"; Found=$pyFound; Req=$true },
        @{ Name="LibreOffice"; Cmd="soffice"; Found=(Get-Command "soffice" -ErrorAction SilentlyContinue); Req=$false }
    )

    $allOk = $true
    foreach ($d in $deps) {
        if ($d.Found) {
            Write-Host "  [OK] $($d.Name) ($($d.Cmd)) terpasang: $($d.Found.Source)" -ForegroundColor Green
        } else {
            if ($d.Req) {
                Write-Host "  [FAIL] $($d.Name) ($($d.Cmd)) TIDAK DITEMUKAN (Wajib)" -ForegroundColor Red
                $allOk = $false
            } else {
                Write-Host "  [INFO] $($d.Name) ($($d.Cmd)) tidak ditemukan (Opsional)" -ForegroundColor Yellow
            }
        }
    }

    Write-Host ""
    Write-Host "[2/2] Memeriksa Berkas Proyek..." -ForegroundColor Blue
    $files = @("metadata.yml", "cover.md", "template.typ", "reference.docx", "references.bib", "docx.lua")
    foreach ($f in $files) {
        if (Test-Path $f) {
            Write-Host "  [OK] Berkas $f ditemukan" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] Berkas $f tidak ditemukan" -ForegroundColor Red
            $allOk = $false
        }
    }

    $dirs = @("presets", "chapters")
    foreach ($d in $dirs) {
        if (Test-Path $d) {
            Write-Host "  [OK] Direktori $d ditemukan" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] Direktori $d tidak ditemukan" -ForegroundColor Red
            $allOk = $false
        }
    }

    Write-Host ""
    if ($allOk) {
        Write-Host "Semua dependensi dan berkas proyek lengkap dan siap digunakan!" -ForegroundColor Green
    } else {
        Write-Host "Ada beberapa komponen yang kurang. Gunakan Docker jika ingin bebas instalasi lokal." -ForegroundColor Yellow
    }
}

function Cmd-Build-PDF {
    Show-Banner
    Write-Host "Membangun Dokumen PDF (Typst Engine)..." -ForegroundColor Blue

    $inputFiles = @("cover.md") + (Get-ChildItem -Path "chapters" -Filter "bab*.md" | Sort-Object Name | ForEach-Object { $_.FullName })
    $presetOpt = ""
    if (Test-Path "metadata.yml") {
        $content = Get-Content "metadata.yml" -Raw
        if ($content -match "(?:preset|margin_preset)\s*:\s*[`"']?([a-zA-Z0-9_-]+)[`"']?") {
            $presetName = $matches[1]
            if (Test-Path "presets\$presetName.yml") {
                $presetOpt = "--metadata-file=presets\$presetName.yml"
            }
        }
    }

    $pandocArgs = @(
        $inputFiles,
        "--template=template.typ",
        $presetOpt,
        "--metadata-file=metadata.yml",
        "--citeproc",
        "--bibliography=references.bib",
        "--csl=apa.csl",
        "--metadata=reference-section-title=DAFTAR PUSTAKA",
        "--top-level-division=chapter",
        "--pdf-engine=typst",
        "--no-highlight",
        "-o", "Laporan.pdf"
    ) | Where-Object { $_ -ne "" }

    & pandoc $pandocArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=== PDF BERHASIL DIBUAT ===" -ForegroundColor Green
        Write-Host "Lokasi: $(Get-Location)\Laporan.pdf" -ForegroundColor Cyan
    } else {
        Write-Host "[ERROR] Kompilasi PDF gagal." -ForegroundColor Red
    }
}

function Cmd-Build-DOCX {
    Show-Banner
    Write-Host "Membangun Dokumen Microsoft Word (DOCX Multi-Pass)..." -ForegroundColor Blue

    if (-not (Test-Path "chapters")) {
        Write-Host "[ERROR] Direktori chapters/ tidak ditemukan." -ForegroundColor Red
        return
    }

    $pyCmd = if (Get-Command "python3" -ErrorAction SilentlyContinue) { "python3" } elseif (Get-Command "python" -ErrorAction SilentlyContinue) { "python" } else { "" }
    if (-not $pyCmd) {
        Write-Host "[ERROR] Python 3 dibutuhkan untuk memproses DOCX." -ForegroundColor Red
        return
    }

    $inputFiles = @("cover.md") + (Get-ChildItem -Path "chapters" -Filter "bab*.md" | Sort-Object Name | ForEach-Object { $_.FullName })
    $presetOpt = ""
    if (Test-Path "metadata.yml") {
        $content = Get-Content "metadata.yml" -Raw
        if ($content -match "(?:preset|margin_preset)\s*:\s*[`"']?([a-zA-Z0-9_-]+)[`"']?") {
            $presetName = $matches[1]
            if (Test-Path "presets\$presetName.yml") {
                $presetOpt = "--metadata-file=presets\$presetName.yml"
            }
        }
    }

    $tmpDocx = [System.IO.Path]::GetTempFileName() + ".docx"
    $sectDocx = [System.IO.Path]::GetTempFileName() + ".docx"

    try {
        $pandocArgs = @(
            $inputFiles,
            $presetOpt,
            "--metadata-file=metadata.yml",
            "--citeproc",
            "--bibliography=references.bib",
            "--csl=apa.csl",
            "--metadata=reference-section-title=DAFTAR PUSTAKA",
            "--top-level-division=chapter",
            "--reference-doc=reference.docx",
            "--lua-filter=docx.lua",
            "-o", $tmpDocx
        ) | Where-Object { $_ -ne "" }

        & pandoc $pandocArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Kompilasi Pandoc ke DOCX gagal." -ForegroundColor Red
            return
        }

        & $pyCmd scripts/finalize-docx.py $tmpDocx $sectDocx
        & $pyCmd scripts/docx-pagenum.py $sectDocx Laporan.docx

        if (Test-Path "Laporan.docx") {
            Write-Host ""
            Write-Host "=== DOCX BERHASIL DIBUAT ===" -ForegroundColor Green
            Write-Host "Lokasi: $(Get-Location)\Laporan.docx" -ForegroundColor Cyan
        }
    } finally {
        Remove-Item -Force -ErrorAction SilentlyContinue $tmpDocx, $sectDocx
    }
}

function Cmd-Build {
    Show-Banner
    Write-Host "[1/2] Membangun Dokumen PDF (Typst Engine)..." -ForegroundColor Blue
    Cmd-Build-PDF
    Write-Host ""
    Write-Host "[2/2] Membangun Dokumen Microsoft Word (DOCX Multi-Pass)..." -ForegroundColor Blue
    Cmd-Build-DOCX
    Write-Host ""
    Write-Host "Dokumen PDF dan DOCX berhasil diproses!" -ForegroundColor Green
}

function Cmd-Init {
    Show-Banner
    Write-Host "Wizard Konfigurasi Laporan Akademik (PowerShell)" -ForegroundColor Cyan
    Write-Host "Isi data di bawah ini (tekan Enter untuk memakai nilai default):"
    Write-Host ""

    $in_title = Read-Host "Judul Laporan [LAPORAN PROYEK AKADEMIK]"
    if (-not $in_title) { $in_title = "LAPORAN PROYEK AKADEMIK" }

    $in_subtitle = Read-Host "Subjudul [DOKUMENTASI DAN ANALISIS IMPLEMENTASI]"
    if (-not $in_subtitle) { $in_subtitle = "DOKUMENTASI DAN ANALISIS IMPLEMENTASI" }

    $in_course = Read-Host "Mata Kuliah [Proyek Perangkat Lunak]"
    if (-not $in_course) { $in_course = "Proyek Perangkat Lunak" }

    $in_lecturer = Read-Host "Dosen Pengampu [Dr. Nama Dosen, M.Kom.]"
    if (-not $in_lecturer) { $in_lecturer = "Dr. Nama Dosen, M.Kom." }

    $in_author = Read-Host "Nama Penulis 1 [Nama Mahasiswa]"
    if (-not $in_author) { $in_author = "Nama Mahasiswa" }

    $in_nim = Read-Host "NIM Penulis 1 [12345678]"
    if (-not $in_nim) { $in_nim = "12345678" }

    $in_institution = Read-Host "Institusi/Universitas [UNIVERSITAS TEKNOLOGI]"
    if (-not $in_institution) { $in_institution = "UNIVERSITAS TEKNOLOGI" }

    $in_faculty = Read-Host "Fakultas [FAKULTAS ILMU KOMPUTER]"
    if (-not $in_faculty) { $in_faculty = "FAKULTAS ILMU KOMPUTER" }

    $in_year = Read-Host "Tahun Akademik [2026/2027]"
    if (-not $in_year) { $in_year = "2026/2027" }

    Write-Host ""
    Write-Host "Pilihan Preset Format Kampus:" -ForegroundColor Blue
    Write-Host "  standard / skripsi-4433 / ui-skripsi / itb-ta / ugm-skripsi / its-skripsi / unpad-skripsi"
    $in_preset = Read-Host "Preset Format [standard]"
    if (-not $in_preset) { $in_preset = "standard" }

    $curDate = (Get-Date -Format "MMMM yyyy")

    $yamlContent = @"
title: "$in_title"
subtitle: "$in_subtitle"
course: "$in_course"
lecturer: "$in_lecturer"
author:
  - name: "$in_author"
    nim: "$in_nim"
institution: "$in_institution"
faculty: "$in_faculty"
year: "$in_year"
date: "$curDate"
preset: "$in_preset"
"@

    Set-Content -Path "metadata.yml" -Value $yamlContent
    Write-Host ""
    Write-Host "metadata.yml berhasil diperbarui!" -ForegroundColor Green
    Write-Host "Jalankan '.\laporan.ps1 build' untuk mulai menghasilkan laporan." -ForegroundColor Cyan
}

function Cmd-Test {
    Show-Banner
    Write-Host "Menjalankan Test Suite..." -ForegroundColor Blue
    $bashCmd = Get-Command "bash" -ErrorAction SilentlyContinue
    if ($bashCmd) {
        & bash test.sh
    } else {
        $pyCmd = if (Get-Command "python3" -ErrorAction SilentlyContinue) { "python3" } elseif (Get-Command "python" -ErrorAction SilentlyContinue) { "python" } else { "" }
        if ($pyCmd) {
            Write-Host "Menjalankan validasi skema preset..." -ForegroundColor Blue
            & $pyCmd scripts/validate-preset.py --all
        } else {
            Write-Host "Test suite membutuhkan bash atau python3." -ForegroundColor Yellow
        }
    }
}

function Cmd-Preset {
    param ($Sub, $P1, $P2)
    $pyCmd = if (Get-Command "python3" -ErrorAction SilentlyContinue) { "python3" } elseif (Get-Command "python" -ErrorAction SilentlyContinue) { "python" } else { "" }

    switch ($Sub) {
        "list" {
            Show-Banner
            Write-Host "Daftar Preset Format Kampus Tersedia:" -ForegroundColor Blue
            Write-Host ""
            Get-ChildItem -Path "presets" -Filter "*.yml" | ForEach-Object {
                $pid = $_.BaseName
                $name = (Select-String -Path $_.FullName -Pattern "^\s*name:\s*`"?(.*?)`"?\s*$" | Select-Object -First 1).Matches.Groups[1].Value
                $desc = (Select-String -Path $_.FullName -Pattern "^\s*description:\s*`"?(.*?)`"?\s*$" | Select-Object -First 1).Matches.Groups[1].Value
                Write-Host "  * $pid - $name" -ForegroundColor Green
                if ($desc) { Write-Host "    $desc" -ForegroundColor Gray }
                Write-Host ""
            }
        }
        "show" {
            if (-not $P1) { Write-Host "Error: Sebutkan ID preset. Contoh: .\laporan.ps1 preset show itb-ta" -ForegroundColor Red; return }
            $file = "presets\$P1.yml"
            if (Test-Path $file) {
                Show-Banner
                Write-Host "Konfigurasi Preset: $P1" -ForegroundColor Cyan
                Write-Host "--------------------------------------------------------"
                Get-Content $file
                Write-Host "--------------------------------------------------------"
            } else {
                Write-Host "Preset '$P1' tidak ditemukan." -ForegroundColor Red
            }
        }
        "apply" {
            if (-not $P1) { Write-Host "Error: Sebutkan ID preset. Contoh: .\laporan.ps1 preset apply itb-ta" -ForegroundColor Red; return }
            $file = "presets\$P1.yml"
            if (-not (Test-Path $file)) { Write-Host "Preset '$P1' tidak ditemukan." -ForegroundColor Red; return }
            if (-not (Test-Path "metadata.yml")) { Write-Host "metadata.yml tidak ditemukan." -ForegroundColor Red; return }

            $content = Get-Content "metadata.yml" -Raw
            if ($content -match "preset\s*:") {
                $content = $content -replace "preset\s*:.*", "preset: `"$P1`""
            } else {
                $content += "`npreset: `"$P1`""
            }
            Set-Content -Path "metadata.yml" -Value $content -NoNewline
            Write-Host "[OK] Preset '$P1' berhasil diterapkan ke metadata.yml!" -ForegroundColor Green
        }
        "validate" {
            if (-not $pyCmd) { Write-Host "Error: Python 3 tidak ditemukan." -ForegroundColor Red; return }
            if ($P1) {
                $tgt = $P1
                if (Test-Path "presets\$tgt.yml") { $tgt = "presets\$tgt.yml" }
                & $pyCmd scripts/validate-preset.py $tgt
            } else {
                & $pyCmd scripts/validate-preset.py --all
            }
        }
        "diff" {
            if (-not $P1) { Write-Host "Error: Sebutkan setidaknya 1 preset untuk dibandingkan." -ForegroundColor Red; return }
            $f1 = "presets\$P1.yml"
            if (-not (Test-Path $f1)) { Write-Host "Preset '$P1' tidak ditemukan." -ForegroundColor Red; return }
            if ($P2) {
                $f2 = "presets\$P2.yml"
                if (-not (Test-Path $f2)) { Write-Host "Preset '$P2' tidak ditemukan." -ForegroundColor Red; return }
                Compare-Object (Get-Content $f1) (Get-Content $f2)
            } else {
                $curr = "standard"
                if (Test-Path "metadata.yml") {
                    $content = Get-Content "metadata.yml" -Raw
                    if ($content -match "(?:preset|margin_preset)\s*:\s*[`"']?([a-zA-Z0-9_-]+)[`"']?") {
                        $curr = $matches[1]
                    }
                }
                $f2 = "presets\$curr.yml"
                Compare-Object (Get-Content $f2) (Get-Content $f1)
            }
        }
        "scan" {
            if (-not $pyCmd) { Write-Host "Error: Python 3 tidak ditemukan." -ForegroundColor Red; return }
            if (-not $P1) { Write-Host "Error: Masukkan path file PDF pedoman kampus." -ForegroundColor Red; return }
            & $pyCmd scripts/scan-preset.py $P1 $P2
        }
        default {
            Write-Host "Gunakan: .\laporan.ps1 preset [list | show <id> | apply <id> | validate | diff <id> | scan <file>]" -ForegroundColor Yellow
        }
    }
}

function Cmd-Clean {
    Remove-Item -Force -ErrorAction SilentlyContinue Laporan.pdf, Laporan.docx, Laporan.html
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue tmp, dist
    Write-Host "[OK] Berkas output berhasil dibersihkan." -ForegroundColor Green
}

function Cmd-Stats {
    $pyCmd = if (Get-Command "python3" -ErrorAction SilentlyContinue) { "python3" } elseif (Get-Command "python" -ErrorAction SilentlyContinue) { "python" } else { "" }
    if ($pyCmd) {
        & $pyCmd scripts/report-stats.py
    } else {
        Write-Host "Error: Python 3 tidak ditemukan." -ForegroundColor Red
    }
}

function Cmd-Doctor {
    $pyCmd = if (Get-Command "python3" -ErrorAction SilentlyContinue) { "python3" } elseif (Get-Command "python" -ErrorAction SilentlyContinue) { "python" } else { "" }
    if ($pyCmd) {
        & $pyCmd scripts/report-doctor.py
    } else {
        Write-Host "Error: Python 3 tidak ditemukan." -ForegroundColor Red
    }
}

function Cmd-Bundle {
    $pyCmd = if (Get-Command "python3" -ErrorAction SilentlyContinue) { "python3" } elseif (Get-Command "python" -ErrorAction SilentlyContinue) { "python" } else { "" }
    if ($pyCmd) {
        & $pyCmd scripts/bundle.py
    } else {
        Write-Host "Error: Python 3 tidak ditemukan." -ForegroundColor Red
    }
}

function Cmd-View {
    if (Test-Path "Laporan.pdf") {
        Start-Process "Laporan.pdf"
    } else {
        Write-Host "Laporan.pdf belum dibuat. Jalankan '.\laporan.ps1 build' terlebih dahulu." -ForegroundColor Red
    }
}

switch ($Command.ToLower()) {
    "build"  { Cmd-Build }
    "pdf"    { Cmd-Build-PDF }
    "docx"   { Cmd-Build-DOCX }
    "init"   { Cmd-Init }
    "stats"  { Cmd-Stats }
    "doctor" { Cmd-Doctor }
    "bundle" { Cmd-Bundle }
    "check"  { Cmd-Check }
    "clean"  { Cmd-Clean }
    "view"   { Cmd-View }
    "test"   { Cmd-Test }
    "preset" { Cmd-Preset $SubCommand $Arg1 $Arg2 }
    "help"   { Show-Help }
    default  { Show-Help }
}
