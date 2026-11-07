# KATA PENGANTAR {-}

Puji syukur ke hadirat Tuhan Yang Maha Esa atas rahmat dan karunia-Nya sehingga makalah yang berjudul **"Analisis Perbandingan Protokol Keamanan Jaringan pada Lingkungan Cloud"** dapat diselesaikan dengan baik.

Makalah ini disusun untuk memenuhi tugas mata kuliah Keamanan Jaringan dan Cloud Computing pada Program Studi Teknik Informatika, Sekolah Teknik Elektro dan Informatika, Institut Teknologi Bandung. Penulis menyampaikan terima kasih kepada Dosen Pengampu atas arahan yang diberikan selama perkuliahan.

```{=typst}
#v(0.8cm)
#align(right)[
  Bandung, Oktober 2026

  #v(1cm)
  Penulis
]
#pagebreak()
#outline(
  title: [#align(center)[#text(size: 14pt, weight: "bold")[DAFTAR ISI]]],
  depth: 3,
)
#context {
  if opt-daftar-gambar {
    let imgs = query(figure.where(kind: image))
    if imgs.len() > 0 {
      pagebreak()
      outline(
        title: align(center)[#text(size: 14pt, weight: "bold")[DAFTAR GAMBAR]],
        target: figure.where(kind: image),
      )
    }
  }
  if opt-daftar-tabel {
    let tbls = query(figure.where(kind: table))
    if tbls.len() > 0 {
      pagebreak()
      outline(
        title: align(center)[#text(size: 14pt, weight: "bold")[DAFTAR TABEL]],
        target: figure.where(kind: table),
      )
    }
  }
}
#pagebreak()
#set page(numbering: "1")
#counter(page).update(1)
```

```{=openxml}
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="454"/></w:pPr><w:r><w:t>Bandung, Oktober 2026</w:t></w:r></w:p>
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="567"/></w:pPr><w:r><w:t>Penulis</w:t></w:r></w:p>
```
