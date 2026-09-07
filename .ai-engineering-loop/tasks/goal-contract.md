# Goal Contract: Upgrade laporan-generator to 10/10 Enterprise Quality

## 1. Objective
Meningkatkan seluruh 7 dimensi kualitas `laporan-generator` menjadi skor sempurna 10/10 melalui perbaikan kualitas skrip shell (ShellCheck zero-warning), penguatan sanitasi & parsing YAML, penambahan subprocess timeout & graceful handling pada pemrosesan DOCX, paritas fitur file watcher native di Windows PowerShell, panduan sintaks Markdown akademik, serta perluasan automated unit testing untuk utilitas Python tanpa regresi pada 91 assertion yang sudah ada.

## 2. Business Outcome & User Lifecycle Impact
- Mahasiswa, peneliti, dan insinyur mendapatkan pengalaman build yang 100% andal, kebal crash input, serta memiliki paritas fungsional penuh di Linux, macOS, maupun Windows native.
- Tidak ada lagi peringatan linter statis pada skrip pipeline.
- Pengembang mendapatkan automated unit test untuk skrip Python pembantu dan panduan sintaks terpusat.

## 3. Acceptance Criteria (AC) - Failure Table

| AC | Input / Skenario | Expected at Seam | Must Fail If Missing |
|---|---|---|---|
| **AC-1** | Happy Path: Kualitas Kode & ShellCheck Zero-Warning | `shellcheck build.sh laporan test.sh` lulus dengan exit code 0 tanpa error/warning (SC2064, SC2086, SC2016 teratasi) | Masih ada warning SC2064 atau SC2086 pada `build.sh` atau `test.sh` |
| **AC-2** | Empty / Omit / Robustness Path: Sanitasi YAML & Robust Parser | Input wizard `cmd_init` di `laporan` dan `laporan.ps1` disanitasi dari tanda kutip ganda dan karakter pemecah YAML; `scripts/validate-preset.py` menangani inline comments dan whitespace dengan aman | Input nama/judul dengan tanda kutip ganda merusak `metadata.yml` |
| **AC-3** | Boundary / Reliability Path: Timeout Subprocess & Graceful LibreOffice Notice | Eksekusi `soffice` dan `pdftotext` pada `scripts/docx-pagenum.py` memiliki timeout batas (30 detik) dan memberikan peringatan informatif ramah jika LibreOffice tidak tersedia | `docx-pagenum.py` berisiko hang tanpa batas waktu |
| **AC-4** | Sibling / Parity Path: Native PowerShell Watcher & Cheatsheet | `laporan.ps1` mendukung perintah `watch` native via `FileSystemWatcher`; berkas `docs/syntax-cheatsheet.md` tersedia dan mencakup sintaks sitasi, gambar, dan tabel | `laporan.ps1 watch` tidak tersedia; panduan cheatsheet hilang |
| **AC-5** | Error / Regression Protection: Python Unit Tests & 100% Suite Pass | Disediakan automated unit test untuk skrip Python (`scripts/test_scripts.py`) dan seluruh 91+ assertions di `test.sh` lulus tanpa regresi | Ada tes di `test.sh` yang gagal atau skrip python tidak memiliki unit testing |

## 4. Technical Constraints
- Tidak menambahkan dependensi eksternal berat (gunakan Python standard library).
- Pertahankan kompatibilitas mundur: template Typst, preset kampus, dan CLI arguments tidak boleh berubah perilakunya bagi pengguna yang sudah ada.
- Zero regression pada dokumen output PDF dan DOCX.

## 5. Out of Scope
- Mengubah arsitektur dasar Pandoc + Typst.
- Mengubah skema metadata inti yang sudah dipakai pengguna.

## 6. Ubiquitous Language
- **ShellCheck**: Tool analisa statis untuk script shell POSIX/Bash.
- **FileSystemWatcher**: Komponen .NET/PowerShell untuk memantau perubahan berkas secara reaktif.
- **PAGEREF Injection**: Proses penyuntikan nomor halaman nyata ke tabel konten Word via LibreOffice headless.

## 7. Test Seams
- Linter Seam: `nix develop --command shellcheck build.sh laporan test.sh`
- Python Test Seam: `python3 scripts/test_scripts.py`
- Integration Test Seam: `nix develop --command ./test.sh`

## 8. Verification Requirements
- Linter: ShellCheck 0 warnings, 0 errors.
- Unit Testing: Test suite Python baru lulus 100%.
- Full Regression Test: `./test.sh` lulus 100%.

## 9. Definition of Done (DoD)
- [ ] AC-1 sampai AC-5 tervalidasi dengan kode hijau.
- [ ] Diff terisolasi dan terdokumentasi dalam `diff.patch`.
- [ ] Devil's Advocate adversarial review selesai dengan 0 temuan SEV-1/SEV-2.
- [ ] Judge Agent menerbitkan putusan PASS.
