# Cheatsheet Sintaks Markdown Akademik

Panduan referensi cepat sintaks Markdown yang kompatibel dan teruji untuk pipeline **Laporan Generator** (Typst PDF dan Microsoft Word DOCX).

---

## 1. Sitasi & Bibliografi (BibTeX APA)

Daftar pustaka dikelola melalui `references.bib` dan format APA melalui `apa.csl`.

| Sintaks Markdown | Hasil Tipografi | Keterangan |
|---|---|---|
| `[@knuth1984texbook]` | (Knuth, 1984) | Sitasi tanda kurung standar |
| `@knuth1984texbook menyatakan bahwa...` | Knuth (1984) menyatakan bahwa... | Sitasi naratif dalam kalimat |
| `[-@knuth1984texbook]` | (1984) | Hanya tahun penerbitan |
| `[@apa2020manual, hal. 45]` | (American Psychological Association, 2020, hal. 45) | Sitasi dengan nomor halaman |
| `[@apa2020manual; @pandoc2024]` | (American Psychological Association, 2020; Pandoc, 2024) | Multi-sitasi sekaligus |

---

## 2. Struktur Heading & Penomoran Bab

Gunakan heading Markdown tanpa menyisipkan angka manual. Engine Typst dan Lua filter DOCX akan menomori sub-bab secara otomatis:

```markdown
# PENDAHULUAN
Heading Level 1 akan menjadi "BAB I PENDAHULUAN" secara otomatis.

## Latar Belakang
Heading Level 2 akan menjadi "1.1 Latar Belakang".

### Identifikasi Masalah
Heading Level 3 akan menjadi "1.1.1 Identifikasi Masalah".

# KATA PENGANTAR {-}
Gunakan atribut `{-}` atau `{.unnumbered}` untuk bagian front-matter tanpa nomor bab.
```

---

## 3. Gambar & Diagram

Letakkan berkas gambar di dalam folder `gambar/`:

```markdown
![Arsitektur Sistem Multi-Engine](gambar/arsitektur.png){#fig:arsitektur width=80%}
```

* **Penomoran Otomatis**: Menjadi `Gambar 1.1: Arsitektur Sistem Multi-Engine` (indeks bab otomatis).
* **Format yang Didukung**: `.png`, `.jpg`, `.jpeg`, `.webp`.
* **Transparansi Alpha**: Script `build.sh` otomatis menormalkan saluran alpha PNG agar optimal di Typst.

---

## 4. Tabel Formal Akademik

Gunakan format Pipe Table standar Pandoc:

```markdown
: Ringkasan Pengujian Kompatibilitas {#tbl:pengujian}

| Platform | Versi Minimum | Status Dukungan |
|:---|:---:|:---|
| Linux (Ubuntu/Debian) | 20.04 LTS | Didukung Penuh (Nix / Native) |
| macOS | Monterey 12+ | Didukung Penuh (Apple Silicon & Intel) |
| Windows | 10 / 11 | Didukung Penuh (PowerShell native) |
```

* Judul tabel diletakkan di atas dengan awalan titik dua `:`.
* Menjadi `Tabel 1.1: Ringkasan Pengujian Kompatibilitas` secara otomatis.

---

## 5. Persamaan Matematika (LaTeX Math)

* **Persamaan Inline**:
  ```markdown
  Nilai fungsi aktivasi dihitung dengan formula $f(x) = \frac{1}{1 + e^{-x}}$.
  ```
* **Persamaan Blok (Display Math)**:
  ```markdown
  $$
  MSE = \frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2
  $$
  ```
  Persamaan blok secara otomatis diberi nomor indeks bab, misalnya `(1.1)`.

---

## 6. Blok Kode & Listing

```markdown
```python
def hitung_akurasi(y_true, y_pred):
    return sum(t == p for t, p in zip(y_true, y_pred)) / len(y_true)
```
```

Typst akan membungkus blok kode dalam background abu-abu terang dengan font `DejaVu Sans Mono`.

---

## 7. Catatan Kaki & Kutipan Langsung

* **Kutipan Blok (Blockquote)**:
  ```markdown
  > "Rekayasa perangkat lunak bukan sekadar menulis kode, melainkan membangun sistem yang dapat diandalkan dan dipelihara dalam jangka panjang."
  ```
* **Catatan Kaki (*Footnotes*)**:
  ```markdown
  Laporan ini menggunakan Pandoc[^pandoc_note] sebagai compiler dokumen universal.

  [^pandoc_note]: Pandoc dikembangkan oleh John MacFarlane dan mendukung lebih dari 40 format dokumen.
  ```

---

## 8. Tips Kompatibilitas Lintas Engine

1. **Hindari Karakter Box-Drawing**: Jangan menggunakan karakter seperti `├──`, `└──`, atau `│` di dalam teks biasa; gunakan list Markdown (`-` atau `*`) atau blok kode monospace.
2. **Jangan Mengetik Angka Bab Manual**: Jangan menulis `## 1.1 Latar Belakang` karena akan menghasilkan penomoran ganda `1.1 1.1 Latar Belakang`.
3. **Nama File Gambar Tanpa Spasi**: Gunakan tanda hubung (`diagram-alur.png`) alih-alih spasi (`diagram alur.png`).
