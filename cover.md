# KATA PENGANTAR {-}

Puji syukur kehadirat Tuhan Yang Maha Esa atas segala rahmat dan karunia-Nya sehingga laporan yang berjudul **"Otomatisasi Pembuatan Dokumen Laporan Akademik menggunakan Pandoc, Typst, dan Markdown"** dapat diselesaikan dengan baik.

Laporan ini disusun sebagai dokumentasi pipeline otomatisasi dokumen akademik yang dibangun menggunakan kombinasi teknologi Markdown, Pandoc, Typst, ImageMagick, dan Bash. Pipeline ini memungkinkan penulisan konten laporan dalam format Markdown yang sederhana, yang kemudian dikonversi menjadi PDF dengan format profesional melalui Pandoc dan Typst.

Penulis menyadari bahwa laporan ini tidak dapat terselesaikan tanpa bantuan dari berbagai pihak. Oleh karena itu, penulis mengucapkan terima kasih kepada semua pihak yang telah memberikan dukungan dalam penyelesaian laporan ini.

Penulis menyadari bahwa laporan ini masih jauh dari sempurna. Oleh karena itu, kritik dan saran yang membangun sangat diharapkan untuk perbaikan di masa mendatang. Semoga laporan ini dapat memberikan manfaat bagi pembaca dalam memahami konsep otomatisasi dokumen akademik.

```{=typst}
#v(0.8cm)
#align(right)[
  Agustus 2026

  #v(1cm)
  Tim Penyusun
]
#pagebreak()
#outline(
  title: [#align(center)[#text(size: 14pt, weight: "bold")[DAFTAR ISI]]],
  depth: 3,
)
#context {
  let imgs = query(figure.where(kind: image))
  if imgs.len() > 0 {
    pagebreak()
    outline(
      title: align(center)[#text(size: 14pt, weight: "bold")[DAFTAR GAMBAR]],
      target: figure.where(kind: image),
    )
  }
  let tbls = query(figure.where(kind: table))
  if tbls.len() > 0 {
    pagebreak()
    outline(
      title: align(center)[#text(size: 14pt, weight: "bold")[DAFTAR TABEL]],
      target: figure.where(kind: table),
    )
  }
}
#pagebreak()
#set page(numbering: "1")
#counter(page).update(1)
```

```{=openxml}
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="454"/></w:pPr><w:r><w:t>Agustus 2026</w:t></w:r></w:p>
<w:p><w:pPr><w:jc w:val="right"/><w:spacing w:before="567"/></w:pPr><w:r><w:t>Tim Penyusun</w:t></w:r></w:p>
```