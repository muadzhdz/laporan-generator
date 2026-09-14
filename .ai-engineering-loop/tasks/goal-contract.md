# Goal Contract: Windows Parity, Encoding Hardening, and Universal Pandoc Compatibility

## 1. Objective
Menyempurnakan kompatibilitas ekosistem `laporan-generator` di platform Windows dan CI/CD multi-versi dengan menyelesaikan 5 celah teknis:
1. Menghilangkan ketergantungan hardcoded `python3` pada `bin/laporan-generator.js` yang memicu crash App Execution Alias Microsoft Store di Windows 10/11.
2. Memperbaiki fungsi `Cmd-Test` di `laporan.ps1` agar mengecek keberadaan `test.sh` sebelum memanggil bash, serta menyediakan fallback otomatis ke unit test Python (`scripts/test_scripts.py`) dan validator preset (`scripts/validate-preset.py`).
3. Memastikan output terminal `scripts/report-stats.py` aman dari `UnicodeEncodeError` pada codepage Windows non-UTF8 (misalnya `cp1252`).
4. Menstandarisasi opsi syntax highlighting Pandoc dari `--syntax-highlighting=none` (yang tidak dikenali Pandoc < 3.8 pada CI) menjadi opsi universal `--no-highlight` di `build.sh` dan `laporan.ps1`.
5. Memperluas automated unit testing di `scripts/test_scripts.py` untuk menguji fungsionalitas parser statistik dan modul pendukung tanpa regresi.

## 2. Business Outcome & User Lifecycle Impact
- Pengguna Windows dapat menjalankan seluruh perintah CLI (`npx laporan-generator doctor`, `.\laporan.ps1 test`, `.\laporan.ps1 stats`) tanpa crash atau kegagalan eksekusi.
- CI GitHub Actions dan pengguna berbagai versi Pandoc (Pandoc 2.x/3.x) dapat mengompilasi dokumen PDF tanpa error `Unknown option --syntax-highlighting`.
- Test suite integrasi lulus 100% (101/101 assertions).

## 3. Acceptance Criteria (AC) - Failure Table

| AC | Input / Skenario | Expected at Seam | Must Fail If Missing |
|---|---|---|---|
| **AC-1** | Windows CLI Doctor: `npx laporan-generator doctor` di Windows | Memanggil `python` jika `python3` tidak dapat dieksekusi, menghasilkan output audit kesehatan 100/100 tanpa error Microsoft Store | Masih memanggil `python3` secara kaku dan melempar error "Python was not found" |
| **AC-2** | PowerShell Test Fallback: `.\laporan.ps1 test` di direktori proyek tanpa `test.sh` | Mengecek `Test-Path "test.sh"`; jika tidak ada, fallback mengeksekusi `scripts/validate-preset.py --all` dan `scripts/test_scripts.py` | Melempar error `/bin/bash: test.sh: No such file or directory` |
| **AC-3** | Windows Terminal Encoding: `.\laporan.ps1 stats` pada codepage cp1252 | Stream stdout/stderr direkonfigurasi ke UTF-8 dengan penggantian error aman; grafik batang `■` tercetak normal | Melempar `UnicodeEncodeError: 'charmap'` |
| **AC-4** | Universal Pandoc Compatibility: Eksekusi `build.sh` pada Pandoc 3.7 di GitHub Actions | Menggunakan `--no-highlight` sehingga seluruh test kompilasi PDF lulus 100% | Error `Unknown option --syntax-highlighting` pada Pandoc < 3.8 |
| **AC-5** | Unit Test Expansion & Zero Regression | `python3 scripts/test_scripts.py` mencakup tes baru dan seluruh test suite lulus 100% (101/101 assertions hijau di CI) | Ada test case yang gagal atau regresi pada tes yang sudah ada |

## 4. Technical Constraints
- Menggunakan library bawaan Python (`sys`, `unittest`, `re`, `os`).
- Menggunakan standar Node.js bawaan tanpa dependensi npm eksternal baru di `bin/laporan-generator.js`.
- Opsi Pandoc harus backwards dan forwards compatible.

## 5. Definition of Done (DoD)
- [x] AC-1 sampai AC-5 tervalidasi dengan kode hijau.
- [x] GitHub Actions CI build lulus 100% (101 passed, 0 failed).
- [x] Verifikasi `test_scripts.py` lulus 100% (16/16 passed).
- [x] Dokumentasi `claimed-vs-reality.md` diperbarui dengan bukti eksekusi nyata.
- [x] Seluruh perubahan ter-push ke branch PR #7 di GitHub.
