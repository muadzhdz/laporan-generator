# Panduan Berkontribusi (CONTRIBUTING)

Terima kasih telah tertarik untuk berkontribusi pada **Laporan Generator**! Project ini bersifat open-source dan sangat menyambut kontribusi dari komunitas, baik berupa perbaikan bug, penambahan fitur, penyempurnaan dokumentasi, maupun pembuatan template kampus baru.

---

## Alur Kontribusi Cepat

1. **Fork Repositori** ini ke akun GitHub Anda.
2. **Clone** hasil fork ke komputer lokal Anda:
   ```bash
   git clone https://github.com/username-anda/laporan-generator.git
   cd laporan-generator/
   ```
3. **Buat Branch Baru** untuk fitur atau perbaikan Anda:
   ```bash
   git checkout -b feature/nama-fitur-anda
   ```
4. **Setup Environment & Git Hooks**:
   ```bash
   make init
   ```
5. **Lakukan Perubahan** dan pastikan seluruh test suite lulus:
   ```bash
   make test
   ```
6. **Commit & Push** ke repositori fork Anda:
   ```bash
   git commit -m "feat: tambahkan fitur X"
   git push origin feature/nama-fitur-anda
   ```
7. **Buat Pull Request (PR)** melalui interface GitHub.

---

## Jenis Kontribusi yang Kami Terima

### 1. Preset Kampus / Institusi Baru
Kami menyambut baik penambahan variasi preset format kampus resmi universitas/sekolah di Indonesia. Anda dapat menambahkan berkas preset baru di direktori `presets/<preset-id>.yml` (lihat spesifikasi di `docs/preset-schema.md`).

### 2. Perbaikan Skrip & Automation
Memperbaiki efisiensi `build.sh`, meningkatkan penanganan kesalahan, atau menambah pengujian baru pada `test.sh`.

### 3. Penyempurnaan AI Prompt
Meningkatkan instruksi pada `prompt.md` agar AI Agent dapat menghasilkan laporan yang lebih presisi dan kaya akan analisis.

---

## Standar Pengujian Sebelum Submit PR

Sebelum membuat Pull Request, Anda **wajib** memastikan pengujian lokal lulus 100%:

```bash
make test
```

`test.sh` akan memverifikasi 20 kategori tes (80+ assertions), termasuk:
- Ketersediaan sintaks dan file wajib
- Validasi metadata dan BibTeX
- Penomoran heading dan multi-engine Typst/DOCX
- Pengujian kompilasi PDF dan ekstraksi teks (`pdftotext`)
- Pengecekan kebersihan dari karakter ilegal (box-drawing)
- Validasi skema preset kampus dan scanner PDF

---

## Pedoman Kode (Coding Standards)

- **Bash Script**: Ikuti praktik terbaik ShellCheck. Gunakan pengurutan variabel bertanda kutip dan penanganan error `set -e`.
- **Typst Template & Lua Filter**: Ikuti kaidah sintaks Typst modern (kompatibel Typst 0.15+) dan pandoc Lua filter standards.
- **Markdown Document**: Gunakan heading standar (`#`, `##`, `###`) dan sintaks sitasi Pandoc `[@citekey]`.
