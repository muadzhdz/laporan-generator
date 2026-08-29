#set document(
  title: "$title$",
  author: ($for(author)$"$author.name$"$sep$,$endfor$),
)

$if(margin_top)$
#let doc-margin = (
  top: $margin_top$,
  bottom: $margin_bottom$,
  left: $margin_left$,
  right: $margin_right$,
)
$else$
#let doc-margin = if "$margin_preset$" == "skripsi-4433" or "$margin_preset$" == "4-4-3-3" {
  (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm)
} else {
  (top: 2cm, bottom: 3cm, left: 2.5cm, right: 2.5cm)
}
$endif$

#set page(
  paper: "a4",
  margin: doc-margin,
  numbering: none,
)

$if(font_family)$
#set text(font: "$font_family$", size: $if(font_size)$$font_size$$else$12pt$endif$)
$else$
#set text(font: "Libertinus Serif", size: 12pt)
$endif$

$if(line_spacing)$
#set par(justify: true, leading: $line_spacing$, first-line-indent: $if(first_line_indent)$$first_line_indent$$else$1.25cm$endif$)
$else$
#set par(justify: true, leading: 0.75em, first-line-indent: 1.25cm)
$endif$
#show bibliography: set par(hanging-indent: $if(first_line_indent)$$first_line_indent$$else$1.25cm$endif$, first-line-indent: 0cm)

#set heading(numbering: (..ns) => {
  if ns.len() == 1 {
    "$if(heading_chapter_prefix)$$heading_chapter_prefix$$else$BAB $endif$" + numbering("I", ns.at(0))
  } else if ns.len() == 2 {
    numbering("$if(heading_sub_dot)$1.1.$else$1.1$endif$", ..ns)
  } else {
    numbering("$if(heading_subsub_dot)$1.1.1.$else$1.1.1$endif$", ..ns)
  }
})

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  align(center)[
    #block(inset: (top: 0.5em, bottom: 1.8em))[
      #text(size: 14pt, weight: "bold")[
        #if it.numbering != none [
          #("BAB " + numbering("I", counter(heading).get().at(0)))
          #linebreak()
          #upper(it.body.text)
        ] else [
          #it.body
        ]
      ]
    ]
  ]
}

#show heading.where(level: 2): it => {
  block(above: 1.0em, below: 0.5em)[
    #text(size: 12pt, weight: "bold")[#it]
  ]
  par(leading: 0.75em)[]
}

#show heading.where(level: 3): it => {
  block(above: 0.8em, below: 0.4em)[
    #text(size: 12pt, weight: "bold")[#it]
  ]
  par(leading: 0.75em)[]
}

#show figure: it => it + par[]
#show list: it => it + par[]
#show enum: it => it + par[]
#show quote: it => it + par[]
#show table: it => it + par[]
#show raw.where(block: true): it => it + par[]

#show outline.entry.where(level: 1): set text(weight: "bold")
#set par(leading: 0.75em)

#let balance-split(title, k) = {
  let words = title.split(" ")
  let n = words.len()
  if n <= 1 {
    return (title,)
  }
  if n <= k {
    return words
  }
  let single-count = lines => lines.map(l => if l.split(" ").len() <= 1 { 1 } else { 0 }).sum()
  let candidates = ()
  if k == 2 {
    for c in range(1, n) {
      let line1 = words.slice(0, c).join(" ")
      let line2 = words.slice(c, n).join(" ")
      let mx = calc.max(line1.len(), line2.len())
      candidates = candidates + (
        (mx + 100 * single-count((line1, line2)), (line1, line2)),
      )
    }
  } else if k == 3 {
    for c1 in range(1, n - 1) {
      for c2 in range(c1 + 1, n) {
        let line1 = words.slice(0, c1).join(" ")
        let line2 = words.slice(c1, c2).join(" ")
        let line3 = words.slice(c2, n).join(" ")
        let mx = calc.max(line1.len(), line2.len(), line3.len())
        candidates = candidates + (
          (mx + 100 * single-count((line1, line2, line3)), (line1, line2, line3)),
        )
      }
    }
  }
  let best = candidates.at(0)
  for cand in candidates {
    if cand.at(0) < best.at(0) {
      best = cand
    }
  }
  best.at(1)
}

#let title-lines = layout(size => {
  let t = upper("$title$".replace("\n", " ").replace("\r", " "))
  let lines = if measure(text(t, size: 14pt, weight: "bold")).width <= size.width {
    (t,)
  } else {
    let two = balance-split(t, 2)
    let w-two = two.map(l => measure(text(l, size: 14pt, weight: "bold")).width)
      .fold(0pt, calc.max)
    let orphan = two.any(l => l.split(" ").len() <= 1)
    if (not orphan) and w-two <= size.width {
      two
    } else {
      balance-split(t, 3)
    }
  }
  let out = ()
  for i in range(lines.len()) {
    if i > 0 {
      out.push(linebreak())
    }
    out.push(lines.at(i))
  }
  out.join()
})

#set table(stroke: 0.5pt + luma(140), inset: 4pt)
#show table.header: set text(weight: "bold")
#set figure.caption(position: bottom)
#show raw.where(block: true): set text(font: "DejaVu Sans Mono", size: 9pt)

#v(1cm)
#align(center)[
  #text(size: 14pt, weight: "bold")[#title-lines]
]
$if(subtitle)$
#v(0.3cm)
#align(center)[
  #text(size: 14pt, weight: "bold")[#upper("$subtitle$".replace("\n", " "))]
]
$endif$
$if(course)$
#v(0.8cm)
#align(center)[
  #text(size: 12pt, weight: "bold")[$course$]
]
$endif$
$if(lecturer)$
$if(cover_hide_lecturer)$
$else$
#v(0.4cm)
#align(center)[
  #text(size: 11pt)[Dosen Pengampu:]
  #text(size: 12pt, weight: "bold")[$lecturer$]
]
$endif$
$endif$

#v(1fr)
#align(center)[
  #image("logo.jpg", width: $if(cover_logo_width)$$cover_logo_width$$else$4cm$endif$)
]
#v(1fr)

#align(center)[
  #text(size: 12pt)[Disusun oleh:]
]
$for(author)$
#v(0.3cm)
#align(center)[
  #text(size: 12pt, weight: "bold")[$author.name$] \
  #text(size: 11pt)[$author.nim$]
]
$endfor$

#v(1fr)
#align(center)[
  #text(size: 14pt, weight: "bold")[#upper("$faculty$".replace("\n", " "))]
  #linebreak()
  #text(size: 14pt, weight: "bold")[#upper("$institution$".replace("\n", " "))]
  #linebreak()
  #text(size: 14pt, weight: "bold")[#upper("$year$".replace("\n", " "))]
]
#v(1cm)

#pagebreak()
#set page(numbering: "i")
#counter(page).update(1)

$if(approval)$
$if(approval.enable)$
#align(center)[
  #text(size: 14pt, weight: "bold")[#upper("$if(approval.title)$$approval.title$$else$LEMBAR PENGESAHAN$endif$")]
]
#v(0.6cm)

#align(center)[
  #text(size: 12pt, weight: "bold")[#title-lines]
]
#v(0.4cm)

#align(center)[
  #text(size: 11pt)[Disusun oleh:] \
  $for(author)$
  #text(size: 11pt, weight: "bold")[$author.name$] (NIM. $author.nim$)$sep$, $endfor$
]
#v(0.3cm)

#align(center)[
  #text(size: 11pt)[
    $if(approval.degree)$
    Disetujui dan disahkan sebagai salah satu syarat kelulusan $approval.degree$
    $else$
    Disetujui dan disahkan sebagai laporan tugas akhir/skripsi
    $endif$
    $if(approval.city)$
    di $approval.city$$if(approval.date)$, pada tanggal $approval.date$$endif$.
    $endif$
  ]
]
#v(0.6cm)

$if(approval.advisors)$
#grid(
  columns: ($for(approval.advisors)$1fr$sep$, $endfor$),
  column-gutter: 1.5cm,
  row-gutter: 1cm,
  $for(approval.advisors)$
  align(center)[
    #text(size: 10pt)[$it.role$:]
    #v(2cm)
    #text(size: 10pt, weight: "bold")[#underline[$it.name$]] \
    #text(size: 9pt)[NIP. $it.nip$]
  ]$sep$,$endfor$
)
#v(0.6cm)
$endif$

$if(approval.head_of_department)$
#align(center)[
  #text(size: 10pt)[Mengetahui,] \
  #text(size: 10pt)[$approval.head_of_department.role$]
  #v(2cm)
  #text(size: 10pt, weight: "bold")[#underline[$approval.head_of_department.name$]] \
  #text(size: 9pt)[NIP. $approval.head_of_department.nip$]
]
$endif$

#pagebreak()
$endif$
$endif$

$if(abstrak)$
#align(center)[
  #text(size: 14pt, weight: "bold")[ABSTRAK]
]
#v(0.6cm)

#set par(justify: true, leading: 0.55em, first-line-indent: 1.25cm)
$abstrak$

$if(kata_kunci)$
#v(0.4cm)
#set par(first-line-indent: 0cm)
#text(weight: "bold")[Kata Kunci: ] $for(kata_kunci)$$kata_kunci$$sep$, $endfor$
$endif$

#pagebreak()
$else$
$if(abstract)$
#align(center)[
  #text(size: 14pt, weight: "bold")[ABSTRAK]
]
#v(0.6cm)

#set par(justify: true, leading: 0.55em, first-line-indent: 1.25cm)
$abstract$

$if(kata_kunci)$
#v(0.4cm)
#set par(first-line-indent: 0cm)
#text(weight: "bold")[Kata Kunci: ] $for(kata_kunci)$$kata_kunci$$sep$, $endfor$
$endif$

#pagebreak()
$endif$
$endif$

$if(abstract_en)$
#align(center)[
  #text(size: 14pt, weight: "bold")[ABSTRACT]
]
#v(0.6cm)

#set par(justify: true, leading: 0.55em, first-line-indent: 1.25cm)
#emph[$abstract_en$]

$if(keywords_en)$
#v(0.4cm)
#set par(first-line-indent: 0cm)
#text(weight: "bold")[#emph[Keywords: ]] #emph[$for(keywords_en)$$keywords_en$$sep$, $endfor$]
$endif$

#pagebreak()
$endif$

$body$