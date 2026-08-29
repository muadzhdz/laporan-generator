-- docx.lua: penomoran heading dan cover page untuk output DOCX.
--  - Heading 1: "BAB I PENDAHULUAN" (huruf kapital, angka romawi)
--  - Heading 2: "1.1. Sub Bab" (titik di akhir nomor)
--  - Heading 3: "1.1.1 Sub Sub Bab"
--  - Heading dengan atribut {-} (unnumbered) dilewati tanpa penomoran.
--  - Cover page dibangun dari metadata (logo, judul, penulis, institusi)
--    meniru cover PDF, menggantikan title block bawaan pandoc.
--
-- Dipakai lewat `pandoc ... --lua-filter=docx.lua --reference-doc=reference.docx`.

local bab = 0
local sub = 0
local subsub = 0
local toc_entries = {}

local function is_unnumbered(el)
  for _, cls in ipairs(el.attr.classes or {}) do
    if cls == "unnumbered" then
      return true
    end
  end
  return false
end

local function roman(n)
  local map = {
    {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
    {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
    {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"},
  }
  local out = ""
  for _, pair in ipairs(map) do
    while n >= pair[1] do
      out = out .. pair[2]
      n = n - pair[1]
    end
  end
  return out
end

local function balance_title(text)
  local words = {}
  for w in text:gmatch("%S+") do
    words[#words + 1] = w
  end
  local n = #words
  if n <= 1 or #text <= 55 then
    return { text }
  end
  local function count_words(s)
    local c = 0
    for _ in s:gmatch("%S+") do
      c = c + 1
    end
    return c
  end
  local function best_for(k)
    local best, best_cost = nil, math.huge
    local function rec(i, kk, cur, mx, single)
      if kk == 1 then
        local line = table.concat(words, " ", i, n)
        local lines = {}
        for _, l in ipairs(cur) do
          lines[#lines + 1] = l
        end
        lines[#lines + 1] = line
        local m = math.max(mx, #line)
        local s = single + (count_words(line) <= 1 and 1 or 0)
        local cost = m + 100 * s
        if cost < best_cost then
          best, best_cost = lines, cost
        end
        return
      end
      for j = i, n - kk + 1 do
        local line = table.concat(words, " ", i, j)
        local nxt = {}
        for _, l in ipairs(cur) do
          nxt[#nxt + 1] = l
        end
        nxt[#nxt + 1] = line
        rec(
          j + 1,
          kk - 1,
          nxt,
          math.max(mx, #line),
          single + (count_words(line) <= 1 and 1 or 0)
        )
      end
    end
    rec(1, k, {}, 0, 0)
    return best
  end
  local function mx_of(lines)
    local m = 0
    for _, l in ipairs(lines) do
      m = math.max(m, #l)
    end
    return m
  end
  local function orphan(lines)
    for _, l in ipairs(lines) do
      if count_words(l) <= 1 then
        return true
      end
    end
    return false
  end
  local two = best_for(2)
  if not orphan(two) and mx_of(two) <= 50 then
    return two
  end
  return best_for(3)
end

local function para(content, style)
  return pandoc.Div(
    { pandoc.Para(content) },
    pandoc.Attr("", {}, { ["custom-style"] = style })
  )
end

local function pagebreak()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function spacer(before)
  return pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:spacing w:before="' .. before .. '"/></w:pPr></w:p>'
  )
end

local function meta_str(meta, key)
  local v = meta[key]
  if v == nil then
    return ""
  end
  return pandoc.utils.stringify(v)
end

function Header(el)
  if FORMAT ~= "docx" then
    return nil
  end
  local title = pandoc.utils.stringify(el.content)
  if is_unnumbered(el) then
    if el.level == 1 then
      toc_entries[#toc_entries + 1] = {
        level = 1,
        id = el.identifier,
        text = string.upper(title),
      }
    end
    return nil
  end
  if el.level == 1 then
    bab = bab + 1
    sub = 0
    subsub = 0
    toc_entries[#toc_entries + 1] = {
      level = 1,
      id = el.identifier,
      text = "BAB " .. roman(bab) .. " " .. string.upper(title),
    }
    el.content = pandoc.List{
      pandoc.Str("BAB " .. roman(bab)),
      pandoc.LineBreak(),
      pandoc.Str(string.upper(title)),
    }
  elseif el.level == 2 then
    sub = sub + 1
    subsub = 0
    toc_entries[#toc_entries + 1] = {
      level = 2,
      id = el.identifier,
      text = bab .. "." .. sub .. ". " .. title,
    }
    el.content = pandoc.Str(bab .. "." .. sub .. ". " .. title)
  elseif el.level == 3 then
    subsub = subsub + 1
    toc_entries[#toc_entries + 1] = {
      level = 3,
      id = el.identifier,
      text = bab .. "." .. sub .. "." .. subsub .. " " .. title,
    }
    el.content = pandoc.Str(bab .. "." .. sub .. "." .. subsub .. " " .. title)
  end
  return el
end

local function toc_entry(e)
  local style, ind, bold = "TOC1", 0, "<w:rPr><w:b/></w:rPr>"
  if e.level == 2 then
    style, ind, bold = "TOC2", 720, ""
  elseif e.level == 3 then
    style, ind, bold = "TOC3", 1440, ""
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' ..
    '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9072"/></w:tabs>' ..
    '<w:ind w:left="' .. ind .. '"/></w:pPr>' ..
    '<w:hyperlink w:anchor="' .. e.id .. '" w:history="1">' ..
    '<w:r>' .. bold .. '<w:t xml:space="preserve">' .. e.text .. '</w:t></w:r>' ..
    '</w:hyperlink>' ..
    '<w:r><w:tab/></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> PAGEREF ' .. e.id .. ' \\h </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:t>0</w:t></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="end"/></w:r>' ..
    '</w:p>'
end

local function daftar_isi()
  local out = pandoc.List{}
  out[#out + 1] = pagebreak()
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="Heading1"/><w:outlineLvl w:val="-1"/></w:pPr>' ..
      '<w:r><w:t>DAFTAR ISI</w:t></w:r></w:p>'
  )
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
      '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="separate"/></w:r></w:p>'
  )
  for _, e in ipairs(toc_entries) do
    out[#out + 1] = pandoc.RawBlock("openxml", toc_entry(e))
  end
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
      '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  )
  return out
end

function Pandoc(doc)
  if FORMAT ~= "docx" then
    return doc
  end
  local meta = doc.meta
  local title = meta_str(meta, "title")
  local subtitle = meta_str(meta, "subtitle")
  local course = meta_str(meta, "course")
  local lecturer = meta_str(meta, "lecturer")
  local faculty = meta_str(meta, "faculty")
  local institution = meta_str(meta, "institution")
  local year = meta_str(meta, "year")

  local blocks = pandoc.List{}

  if title ~= "" then
    local tlines = balance_title(string.upper(title))
    local content = {}
    for i, l in ipairs(tlines) do
      if i > 1 then
        content[#content + 1] = pandoc.LineBreak()
      end
      content[#content + 1] = pandoc.Str(l)
    end
    blocks[#blocks + 1] = para(content, "CoverTitle")
    if subtitle ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Str(string.upper(subtitle)) }, "CoverSubtitle")
    end
    if course ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(course)) }, "CoverCourse")
    end
    local hide_lecturer = meta_str(meta, "cover_hide_lecturer") == "true" or meta_str(meta, "cover_show_lecturer") == "false"
    if lecturer ~= "" and not hide_lecturer then
      blocks[#blocks + 1] = para(
        { pandoc.Str("Dosen Pengampu: "), pandoc.Strong(pandoc.Str(lecturer)) },
        "CoverLecturer"
      )
    end
    local logo_width = meta_str(meta, "cover_logo_width")
    if logo_width == "" then
      logo_width = "4cm"
    end
    blocks[#blocks + 1] = spacer(640)
    blocks[#blocks + 1] = pandoc.Div(
      { pandoc.Para({ pandoc.Image({}, "logo.jpg", "", pandoc.Attr("", {}, { width = logo_width })) }) },
      pandoc.Attr("", {}, { ["custom-style"] = "CoverImage" })
    )
    blocks[#blocks + 1] = spacer(640)
  end

  local author_list = {}
  local authors = meta["author"]
  if authors ~= nil then
    if authors[1] ~= nil then
      for _, a in ipairs(authors) do
        author_list[#author_list + 1] = a
      end
    else
      author_list[#author_list + 1] = authors
    end
    if #author_list > 0 then
      blocks[#blocks + 1] = para({ pandoc.Str("Disusun oleh:") }, "CoverLine")
      for _, a in ipairs(author_list) do
        local name = pandoc.utils.stringify(a["name"] or a)
        local nim = pandoc.utils.stringify(a["nim"] or "")
        blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(name)) }, "CoverName")
        if nim ~= "" then
          blocks[#blocks + 1] = para({ pandoc.Str(nim) }, "CoverLine")
        end
      end
    end
  end

  if faculty ~= "" or institution ~= "" or year ~= "" then
    blocks[#blocks + 1] = spacer(640)
    if faculty ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Str(string.upper(faculty)) }, "CoverInstitution")
    end
    if institution ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Str(string.upper(institution)) }, "CoverInstitution")
    end
    if year ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Str(string.upper(year)) }, "CoverInstitution")
    end
  end

  local function build_approval_blocks()
    local app = meta["approval"]
    if app == nil then
      return pandoc.List{}
    end
    local enable = app["enable"]
    if enable ~= nil and pandoc.utils.stringify(enable) == "false" then
      return pandoc.List{}
    end

    local app_title = meta_str(app, "title")
    if app_title == "" then
      app_title = "LEMBAR PENGESAHAN"
    end

    local blks = pandoc.List{}
    blks[#blks + 1] = pagebreak()

    local app_id = "lembar-pengesahan"
    table.insert(toc_entries, 1, {
      level = 1,
      id = app_id,
      text = string.upper(app_title),
    })

    blks[#blks + 1] = pandoc.Header(1, pandoc.Str(string.upper(app_title)), pandoc.Attr(app_id, { "unnumbered" }, {}))
    blks[#blks + 1] = spacer(200)

    if title ~= "" then
      blks[#blks + 1] = para({ pandoc.Strong(pandoc.Str(string.upper(title))) }, "CoverTitle")
      blks[#blks + 1] = spacer(200)
    end

    if #author_list > 0 then
      blks[#blks + 1] = para({ pandoc.Str("Disusun oleh:") }, "CoverLine")
      for _, a in ipairs(author_list) do
        local name = pandoc.utils.stringify(a["name"] or a)
        local nim = pandoc.utils.stringify(a["nim"] or "")
        local line = name
        if nim ~= "" then
          line = line .. " (NIM. " .. nim .. ")"
        end
        blks[#blks + 1] = para({ pandoc.Strong(pandoc.Str(line)) }, "CoverName")
      end
      blks[#blks + 1] = spacer(200)
    end

    local degree = meta_str(app, "degree")
    local city = meta_str(app, "city")
    local date = meta_str(app, "date")
    local stmt = "Disetujui dan disahkan sebagai salah satu syarat kelulusan"
    if degree ~= "" then
      stmt = stmt .. " " .. degree
    else
      stmt = stmt .. " laporan tugas akhir/skripsi"
    end
    if city ~= "" then
      stmt = stmt .. " di " .. city
      if date ~= "" then
        stmt = stmt .. ", pada tanggal " .. date .. "."
      else
        stmt = stmt .. "."
      end
    end
    blks[#blks + 1] = para({ pandoc.Str(stmt) }, "Normal")
    blks[#blks + 1] = spacer(400)

    local advisors = app["advisors"]
    if advisors ~= nil then
      local adv_list = {}
      if advisors[1] ~= nil then
        for _, v in ipairs(advisors) do
          adv_list[#adv_list + 1] = v
        end
      else
        adv_list[#adv_list + 1] = advisors
      end
      for _, adv in ipairs(adv_list) do
        local r = meta_str(adv, "role")
        local n = meta_str(adv, "name")
        local nip = meta_str(adv, "nip")
        if r == "" then r = "Dosen Pembimbing" end
        blks[#blks + 1] = para({ pandoc.Str(r .. ":") }, "Normal")
        blks[#blks + 1] = spacer(600)
        local n_inlines = { pandoc.Strong(pandoc.Underline(pandoc.Str(n))) }
        if nip ~= "" then
          n_inlines[#n_inlines + 1] = pandoc.LineBreak()
          n_inlines[#n_inlines + 1] = pandoc.Str("NIP. " .. nip)
        end
        blks[#blks + 1] = para(n_inlines, "Normal")
        blks[#blks + 1] = spacer(200)
      end
    end

    local hod = app["head_of_department"]
    if hod ~= nil then
      local r = meta_str(hod, "role")
      local n = meta_str(hod, "name")
      local nip = meta_str(hod, "nip")
      if r == "" then r = "Ketua Program Studi" end
      blks[#blks + 1] = para({ pandoc.Str("Mengetahui,"), pandoc.LineBreak(), pandoc.Str(r) }, "Normal")
      blks[#blks + 1] = spacer(600)
      local n_inlines = { pandoc.Strong(pandoc.Underline(pandoc.Str(n))) }
      if nip ~= "" then
        n_inlines[#n_inlines + 1] = pandoc.LineBreak()
        n_inlines[#n_inlines + 1] = pandoc.Str("NIP. " .. nip)
      end
      blks[#blks + 1] = para(n_inlines, "Normal")
    end

    return blks
  end

  local function build_abstract_blocks()
    local blks = pandoc.List{}

    local abs_id = meta["abstrak"] or meta["abstract"]
    if abs_id ~= nil then
      local abs_text = pandoc.utils.stringify(abs_id)
      if abs_text ~= "" then
        blks[#blks + 1] = pagebreak()
        local idx = #toc_entries >= 1 and 2 or 1
        table.insert(toc_entries, idx, {
          level = 1,
          id = "abstrak",
          text = "ABSTRAK",
        })
        blks[#blks + 1] = pandoc.Header(1, pandoc.Str("ABSTRAK"), pandoc.Attr("abstrak", { "unnumbered" }, {}))
        blks[#blks + 1] = spacer(200)
        blks[#blks + 1] = para({ pandoc.Str(abs_text) }, "Normal")

        local kw = meta["kata_kunci"]
        if kw ~= nil then
          local kw_str = ""
          if type(kw) == "table" and kw[1] ~= nil then
            local items = {}
            for _, k in ipairs(kw) do
              items[#items + 1] = pandoc.utils.stringify(k)
            end
            kw_str = table.concat(items, ", ")
          else
            kw_str = pandoc.utils.stringify(kw)
          end
          if kw_str ~= "" then
            blks[#blks + 1] = spacer(200)
            blks[#blks + 1] = para({ pandoc.Strong(pandoc.Str("Kata Kunci: ")), pandoc.Str(kw_str) }, "Normal")
          end
        end
      end
    end

    local abs_en = meta["abstract_en"]
    if abs_en ~= nil then
      local abs_en_text = pandoc.utils.stringify(abs_en)
      if abs_en_text ~= "" then
        blks[#blks + 1] = pagebreak()
        local idx = #toc_entries >= 2 and 3 or (#toc_entries >= 1 and 2 or 1)
        table.insert(toc_entries, idx, {
          level = 1,
          id = "abstract-en",
          text = "ABSTRACT",
        })
        blks[#blks + 1] = pandoc.Header(1, pandoc.Str("ABSTRACT"), pandoc.Attr("abstract-en", { "unnumbered" }, {}))
        blks[#blks + 1] = spacer(200)
        blks[#blks + 1] = para({ pandoc.Emph(pandoc.Str(abs_en_text)) }, "Normal")

        local kw_en = meta["keywords_en"]
        if kw_en ~= nil then
          local kw_en_str = ""
          if type(kw_en) == "table" and kw_en[1] ~= nil then
            local items = {}
            for _, k in ipairs(kw_en) do
              items[#items + 1] = pandoc.utils.stringify(k)
            end
            kw_en_str = table.concat(items, ", ")
          else
            kw_en_str = pandoc.utils.stringify(kw_en)
          end
          if kw_en_str ~= "" then
            blks[#blks + 1] = spacer(200)
            blks[#blks + 1] = para({ pandoc.Strong(pandoc.Emph(pandoc.Str("Keywords: "))), pandoc.Emph(pandoc.Str(kw_en_str)) }, "Normal")
          end
        end
      end
    end

    return blks
  end

  local app_blocks = build_approval_blocks()
  local abs_blocks = build_abstract_blocks()

  meta.title = nil
  meta.subtitle = nil
  meta.date = nil
  meta.author = nil
  meta.abstract = nil
  meta["abstract-title"] = nil
  meta.abstrak = nil
  meta.abstract_en = nil
  meta.approval = nil

  local body = pandoc.List{}
  local inserted = false
  for _, blk in ipairs(doc.blocks) do
    if
      not inserted
      and blk.tag == "Header"
      and blk.level == 1
      and not is_unnumbered(blk)
    then
      for _, b in ipairs(daftar_isi()) do
        body[#body + 1] = b
      end
      inserted = true
    end
    body[#body + 1] = blk
  end

  doc.blocks = blocks .. app_blocks .. abs_blocks .. body
  return doc
end