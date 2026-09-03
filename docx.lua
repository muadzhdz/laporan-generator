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
local chapter_prefix = "BAB "
local chapter_num_fmt = "roman"

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

local function format_chapter_number(n)
  if chapter_num_fmt == "arabic" then
    return tostring(n)
  else
    return roman(n)
  end
end

local function Meta(meta)
  if meta["heading_chapter_prefix"] ~= nil then
    local pfx = meta_str(meta, "heading_chapter_prefix")
    if pfx == "" then
      chapter_prefix = ""
    else
      if not pfx:match("%s$") then
        pfx = pfx .. " "
      end
      chapter_prefix = pfx
    end
  end
  local fmt = meta_str(meta, "heading_chapter_num_format")
  if fmt ~= "" then
    chapter_num_fmt = fmt
  end
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
    local bnum = format_chapter_number(bab)
    local full_bab = chapter_prefix .. bnum
    if chapter_prefix == "" then
      full_bab = bnum .. "."
      toc_entries[#toc_entries + 1] = {
        level = 1,
        id = el.identifier,
        text = full_bab .. " " .. string.upper(title),
      }
      el.content = pandoc.List{
        pandoc.Str(full_bab .. " " .. string.upper(title)),
      }
    else
      toc_entries[#toc_entries + 1] = {
        level = 1,
        id = el.identifier,
        text = full_bab .. " " .. string.upper(title),
      }
      el.content = pandoc.List{
        pandoc.Str(full_bab),
        pandoc.LineBreak(),
        pandoc.Str(string.upper(title)),
      }
    end
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
      local lecturer_lbl = meta_str(meta, "lecturer_label")
      if lecturer_lbl == "" then
        lecturer_lbl = "Dosen Pengampu: "
      else
        if not lecturer_lbl:match(":%s*$") then
          lecturer_lbl = lecturer_lbl .. ": "
        elseif not lecturer_lbl:match("%s$") then
          lecturer_lbl = lecturer_lbl .. " "
        end
      end
      blocks[#blocks + 1] = para(
        { pandoc.Str(lecturer_lbl), pandoc.Strong(pandoc.Str(lecturer)) },
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

  local authors = meta["author"]
  if authors ~= nil then
    local author_list = {}
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

  meta.title = nil
  meta.subtitle = nil
  meta.date = nil
  meta.author = nil
  meta.abstract = nil
  meta["abstract-title"] = nil

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

  doc.blocks = blocks .. body
  return doc
end

return {
  { Meta = Meta },
  { Header = Header, Pandoc = Pandoc }
}