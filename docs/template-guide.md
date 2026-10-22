# Panduan Arsitektur Template Typst (template.typ)

File `template.typ` merupakan jantung dari pemformatan visual PDF pada **Laporan Generator**. Template ini dirancang untuk memenuhi standar penyusunan laporan akademik resmi di Indonesia, dan dikompilasi dengan **Typst** sebagai engine typesetting.

> **Catatan**: Pipeline utama sepenuhnya menggunakan **Typst** (`template.typ`). Template LaTeX lama diarsipkan pada branch `legacy/latex-engine`.

---

## Desain Arsitektur & Pemilihan Font

### 1. Pemilihan Font (Libertinus Serif)
* Standardisasi karya ilmiah di Indonesia mewajibkan penggunaan font tipe *Times New Roman* 12pt.
* Untuk menjamin portabilitas kompilasi cross-platform tanpa dependensi font eksternal, template menggunakan **Libertinus Serif** (`Libertinus Serif`) yang sudah dibundel langsung di dalam binary Typst.
* Blok kode menggunakan **DejaVu Sans Mono** (juga font bawaan Typst).

### 2. Pengaturan Margin & Spacing
```typst
#set page(
  paper: "a4",
  margin: doc-margin,
  numbering: none,
)
#set text(font: "Libertinus Serif", size: 12pt)
#set par(justify: true, leading: 0.75em, first-line-indent: 1.25cm)
```
* Margin Default (`standard`): Atas 2.0 cm, Bawah 3.0 cm, Kiri 2.5 cm, Kanan 2.5 cm (atau mengikuti `presets/*.yml` aktif).
* Spasi Antar Baris: `0.75em` (setara 1.5 spasi di Typst).
* Paragraf rata kanan-kiri (*justify*) dengan indentasi baris pertama `1.25cm`.

---

## Penomoran Bab dan Halaman

### 1. Format Bab & Heading
```typst
#set heading(numbering: (..ns) => {
  if ns.len() == 1 {
    if chapter-prefix != "" {
      chapter-prefix + format-chapter-num(ns.at(0))
    } else {
      format-chapter-num(ns.at(0))
    }
  } else if ns.len() == 2 {
    numbering("1.1.", ..ns)
  } else {
    numbering("1.1.1", ..ns)
  }
})
```
* **Bab**: Diformat dengan Angka Romawi (`BAB I`, `BAB II`, `BAB III`, dst) atau Angka Arab sesuai preset (`heading_chapter_num_format`). Nomor bab dan judul dipisahkan oleh *line break* pada `#show heading.where(level: 1)`.
* **Sub-bab**: Diformat dengan Angka Arab (`1.1.`, `1.2.`, `2.1.`) sesuai flag `heading_sub_dot`.
* **Sub-sub-bab**: Diformat dengan Angka Arab 3 tingkat (`1.1.1`, `1.1.2`).
* **Heading tanpa nomor** (Kata Pengantar, Daftar Isi, Daftar Pustaka): menggunakan `{-}` di Markdown yang diterjemahkan Pandoc menjadi `#heading(level: 1, numbering: none)`.

> **Catatan**: Jangan menulis pola `"BAB I"` langsung sebagai format string `numbering(...)`. Typst menginterpretasikan rangkaian huruf `BAB` sebagai pola huruf dan memotong angka Romawinya. Selalu concat literal secara manual: `"BAB " + numbering("I", n)`.

### 2. Penomoran Halaman (frontmatter vs mainmatter)
* **Bagian Depan** (Lembar Pengesahan, Abstrak, Kata Pengantar, Daftar Isi): Menggunakan penomoran Romawi kecil (`i`, `ii`, `iii`) di bagian tengah bawah. Diatur di `template.typ` tepat setelah sampul depan:
  ```typst
  #pagebreak()
  #set page(numbering: "i")
  #counter(page).update(1)
  ```
* **Bagian Utama** (BAB I hingga BAB V & Daftar Pustaka): Menggunakan penomoran Angka Arab (`1`, `2`, `3`) berurutan, di-reset ulang di akhir `cover.md`:
  ```typst
  #pagebreak()
  #set page(numbering: "1")
  #counter(page).update(1)
  ```

---

## Halaman Sampul (Cover)

Bagian sampul dirender dari metadata `metadata.yml` dengan variabel: `title`, `subtitle`, `course`, `lecturer`, `authors`, `institution`, `logo`, `year`.

```typst
#block(
  width: 100%,
  align(center)[
    #image(logo, width: 4cm)
    ...
  ]
)
```

---

## Pemrosesan Elemen Konten

### 1. Tabel
```typst
#show table: set stroke(0.75pt)
#show table.header: set text(weight: "bold")
```
* Header tabel dicetak tebal, garis tabel 0.75pt.

### 2. Gambar
* Caption gambar dirender di bawah gambar (`#show figure: set figure.caption(position: bottom)`).
* Gambar diproses oleh ImageMagick di `build.sh` (alpha channel dihapus) sebelum dikompilasi.

### 3. Blok Kode
```typst
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)
```
* Blok kode menggunakan font monospaced 9pt dengan latar abu-abu muda (`#show raw: set block(fill: luma(240))`).