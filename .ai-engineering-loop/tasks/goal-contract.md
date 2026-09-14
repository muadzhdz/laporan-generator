# Goal Contract: Windows Parity, Encoding Hardening, and CLI Robustness

## 1. Objective
Menyempurnakan kompatibilitas ekosistem `laporan-generator` di platform Windows dengan menyelesaikan 4 celah teknis:
1. Menghilangkan ketergantungan hardcoded `python3` pada `bin/laporan-generator.js` yang memicu crash App Execution Alias Microsoft Store di Windows 10/11.
2. Memperbaiki fungsi `Cmd-Test` di `laporan.ps1` agar mengecek keberadaan `test.sh` sebelum memanggil bash, serta menyediakan fallback otomatis ke unit test Python (`scripts/test_scripts.py`) dan validator preset (`scripts/validate-preset.py`).
3. Memastikan output terminal `scripts/report-stats.py` aman dari `UnicodeEncodeError` pada codepage Windows non-UTF8 (misalnya `cp1252`).
4. Memperluas automated unit testing di `scripts/test_scripts.py` untuk menguji fungsionalitas parser statistik dan modul pendukung tanpa regresi.

## 2. Business Outcome & User Lifecycle Impact
- Pengguna Windows dapat menjalankan seluruh perintah CLI (`npx laporan-generator doctor`, `.\laporan.ps1 test`, `.\laporan.ps1 stats`) tanpa crash atau kegagalan eksekusi.
- Pengalaman instalasi dan audit proyek menjadi 100% konsisten antara Linux, macOS, dan Windows.
- Menjamin stabilitas jangka panjang melalui penambahan unit testing otomatis.

## 3. Acceptance Criteria (AC) - Failure Table

| AC | Input / Skenario | Expected at Seam | Must Fail If Missing |
|---|---|---|---|
| **AC-1** | Windows CLI Doctor: `npx laporan-generator doctor` di Windows | Memanggil `python` jika `python3` tidak dapat dieksekusi, menghasilkan output audit kesehatan 100/100 tanpa error Microsoft Store | Masih memanggil `python3` secara kaku dan melempar error "Python was not found" |
| **AC-2** | PowerShell Test Fallback: `.\laporan.ps1 test` di direktori proyek tanpa `test.sh` | Mengecek `Test-Path "test.sh"`; jika tidak ada, fallback mengeksekusi `scripts/validate-preset.py --all` dan `scripts/test_scripts.py` | Melempar error `/bin/bash: test.sh: No such file or directory` |
| **AC-3** | Windows Terminal Encoding: `.\laporan.ps1 stats` pada codepage cp1252 | Stream stdout/stderr direkonfigurasi ke UTF-8 dengan penggantian error aman; grafik batang `■` tercetak normal | Melempar `UnicodeEncodeError: 'charmap'` |
| **AC-4** | Unit Test Expansion & Zero Regression | `python3 scripts/test_scripts.py` mencakup tes baru dan lulus 100% (semua assertions hijau) | Ada test case yang gagal atau regresi pada tes yang sudah ada |

## 4. Technical Constraints
- Menggunakan library bawaan Python (`sys`, `unittest`, `re`, `os`).
- Menggunakan standar Node.js bawaan tanpa dependensi npm eksternal baru di `bin/laporan-generator.js`.
- Pertahankan kompatibilitas penuh dengan Linux dan macOS.

## 5. Out of Scope
- Mengubah core Typst template (`template.typ`).
- Mengubah skema metadata akademik `metadata.yml`.

## 6. Ubiquitous Language
- **App Execution Alias**: Fitur Windows 10/11 yang mengarahkan perintah `python3` ke Microsoft Store jika belum dipetakan secara manual.
- **Console Codepage**: Pengaturan encoding default terminal Windows (misal CP-1252 / Western European).
- **Test Seam Fallback**: Mekanisme degradasi elegan saat lingkungan pengembangan (development tools) tidak tersedia di lingkungan pengguna akhir.

## 7. Test Seams
- CLI Doctor Seam: `node bin/laporan-generator.js doctor`
- PowerShell Test Seam: `powershell -ExecutionPolicy Bypass -File .\laporan.ps1 test`
- Stats Encoding Seam: `powershell -ExecutionPolicy Bypass -File .\laporan.ps1 stats`
- Unit Test Seam: `python scripts/test_scripts.py`

## 8. Definition of Done (DoD)
- [x] AC-1 sampai AC-4 tervalidasi dengan kode hijau.
- [x] Verifikasi `test_scripts.py` lulus 100%.
- [x] Dokumentasi `claimed-vs-reality.md` diperbarui dengan bukti eksekusi nyata.
- [x] Seluruh perubahan ter-push ke branch PR #7 di GitHub.
