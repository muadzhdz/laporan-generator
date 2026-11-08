# Panduan Penanganan Masalah (Troubleshooting)

Dokumen ini berisi daftar masalah umum, kode kesalahan, dan solusi langkah-demi-langkah saat menjalankan **Laporan Generator**.

---

## 1. ImageMagick Security Policy Error

### Gejala Error:
```text
convert-im6.q16: attempt to perform an operation not allowed by the security policy 'PDF'
```

### Penyebab:
Kebijakan keamanan default ImageMagick pada beberapa distribusi Linux (seperti Ubuntu/Debian) membatasi pemrosesan berkas PDF/PNG untuk mencegah kerentanan keamanan.

### Solusi:
1. Buka file kebijakan ImageMagick dengan hak akses sudo:
   ```bash
   sudo nano /etc/ImageMagick-6/policy.xml
   # atau untuk ImageMagick 7:
   sudo nano /etc/ImageMagick-7/policy.xml
   ```
2. Cari baris berikut:
   ```xml
   <policy domain="coder" rights="none" pattern="PDF" />
   ```
3. Ubah `rights="none"` menjadi `rights="read|write"`:
   ```xml
   <policy domain="coder" rights="read|write" pattern="PDF" />
   ```
4. Simpan file (`Ctrl+O`, `Enter`) lalu keluar (`Ctrl+X`).

---

## 2. Font Tidak Ditemukan (Missing Font)

### Gejala Error:
```text
warning: font 'Nimbus Serif' not found, falling back to default
warning: failed to resolve font 'Times New Roman'
```

### Penyebab:
Font yang disebutkan di dalam `template.typ` tidak tersedia. Typst hanya memakai font yang dibundel di binary-nya (termasuk Libertinus Serif dan DejaVu Sans Mono) plus font yang terinstall di sistem.

### Solusi:
1. Gunakan font bawaan Typst: `Libertinus Serif`, `DejaVu Sans Mono`, atau `New Computer Modern`.
2. Jika ingin font sistem lain, pastikan font tersebut sudah terinstall di OS/container.
3. Cek daftar font yang tersedia:
   ```bash
   typst fonts
   ```

---

## 3. Syntax Error Raw Typst di cover.md

### Gejala Error:
```text
error: expected `)`, found `]`
  ┌─ cover.md:5:1
```

### Penyebab:
Blok raw Typst di dalam `cover.md` (diapit ``` ```typst ```) memiliki kesalahan sintaks. Contoh yang sering terjadi: `block(align: center)` (tidak valid di Typst, gunakan `align(center)[block(...)]`) atau `ns.first()` (dihapus sejak Typst 0.13, gunakan `ns.at(0)`).

### Solusi:
Periksa pesan error Typst yang menyebutkan posisi baris, lalu perbaiki blok raw di `cover.md` atau konstruksi template di `template.typ`.

---

## 4. Citasi "Undefined Reference"

### Gejala Error:
```text
[WARNING] Citeproc: citation 'he2016deep' not found
```

### Penyebab:
Di dalam Markdown, sintaks sitasi tidak dikenali atau citekey tidak ada di `references.bib`.

### Solusi:
Gunakan sintaks sitasi Pandoc `[@citekey]` atau `@citekey` di file Markdown:
- **Salah**: `Menurut \cite{he2016deep}...`
- **Benar**: `Menurut [@he2016deep]...`

---

## 5. Permission Denied pada Laporan.pdf (Docker Volume)

### Gejala Error:
```text
cannot create Laporan.pdf: Permission denied
```

### Penyebab:
Container Docker dijalankan sebagai user `root` sehingga menghalangi user lokal untuk mengubah atau menghapus file output.

### Solusi:
Gunakan perintah `docker compose` yang sudah dikonfigurasi dengan variabel `UID/GID` lokal:
```bash
docker compose run --rm laporan-generator
```
*(File `docker-compose.yml` pada project ini secara otomatis memetakan `user: "${UID:-1000}:${GID:-1000}"`)*.

---

## 6. Skor Heuristik Pola Tulisan Melebihi Ambang

### Gejala Error:
```text
GAGAL: Skor pola tulisan (32) melebihi ambang 15
```

### Penyebab:
Heuristik menemukan variasi panjang kalimat yang rendah, keragaman kosakata terbatas, atau frasa yang berulang. Skor ini bukan probabilitas penggunaan AI dan tidak dapat menentukan siapa yang menulis teks.

### Solusi:
1. Jalankan `laporan audit` untuk melihat metrik pola tulisan per bab dan frasa berulang yang terdeteksi.
2. Variasikan ritme kalimat: gabungkan kalimat pendek dan kalimat majemuk bertingkat secara alami.
3. Hilangkan seluruh frasa pembuka klise; ganti dengan fakta empiris, data kuantitatif, atau observasi teknis langsung.

---

## 7. Verifikasi DOI CrossRef Timeout atau Gagal

### Gejala Error:
```text
[WARN] DOI tidak valid atau server tidak merespons (HTTP 404 / Timeout)
```

### Penyebab:
Koneksi internet bermasalah atau format DOI pada berkas `references.bib` salah (misalnya terdapat URL lengkap `https://doi.org/...` di dalam field `doi = { ... }`).

### Solusi:
1. Pastikan field `doi` hanya berisi identitas murni, contoh: `doi = {10.1109/CVPR.2016.90}` (tanpa prefix `https://doi.org/`).
2. Untuk pengujian luring tanpa koneksi internet, gunakan flag `--offline`:
   ```bash
   ./laporan citations verify --offline
   ```
