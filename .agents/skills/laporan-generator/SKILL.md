---
name: laporan-generator
description: >-
  Universal Academic Report & Thesis Generator with native MCP Tools for AI Agents.
  Use when the user wants to scaffold, draft, write, format, audit, or compile academic documents:
  skripsi, tesis, tugas akhir (TA), laporan PKL / magang, makalah kuliah, scientific papers,
  research proposals, or graduation reports adhering to Indonesian university standards
  (UI, ITB, UGM, ITS, Unpad, standard 4-4-3-3).
---

# Laporan Generator: World-Class Academic Document Engine for AI Agents

This skill empowers AI agents (Antigravity, Claude Code, Cursor, OpenCode, Kiro) to autonomously scaffold, author, audit, and compile publication-grade academic documents and theses using the bundled **Typst (PDF)** and **Pandoc + OpenXML (Word DOCX)** dual engines with **Native Model Context Protocol (MCP)** tools.

> [!CRITICAL]
> **MODULAR MARKDOWN ARCHITECTURE MANDATE**:
> - **DO NOT write raw Typst code from scratch (e.g. `laporan.typ` or importing `@preview/ieee`).**
> - **DO NOT create monolithic single-file documents.**
> The engine is strictly designed around clean modular components:
> 1. `metadata.yml`: Academic metadata (title, author, institution, faculty, year, campus preset).
> 2. `cover.md`: Cover page text, approval sheet, preface (kata pengantar), and abstract.
> 3. `chapters/`: Modular chapter files in standard Markdown (`bab1-pendahuluan.md`, `bab2-tinjauan-pustaka.md`, etc.).
> 4. `references.bib`: Standard BibTeX citation database.
> 5. `template.typ` & `docx.lua`: Bundled dual compilation engines.

--------------------------------------------------------------------------------

## 1. Native MCP Tools & CLI Commands

When available in your environment, **always prefer calling the native MCP tools** for structured, deterministic execution:

| Action | Native MCP Tool | CLI Fallback |
| :--- | :--- | :--- |
| **Initialize Project** | `laporan_init({ preset, title, author_name, institution })` | `npx laporan-generator init` |
| **Audit & Health Check** | `laporan_doctor({ target_dir })` | `./laporan doctor` or `npx laporan-generator doctor --json` |
| **Document Stats & Metrics** | `laporan_stats({ target_dir })` | `./laporan stats` or `npx laporan-generator stats --json` |
| **Inspect Campus Presets** | `laporan_presets({ action: "list" \| "get", preset_name })` | `./laporan preset list` |
| **Search & Add Citations** | `laporan_citations({ action: "search_doi" \| "add_citation", query, doi })` | Manual edit `references.bib` |
| **Compile PDF & DOCX** | `laporan_build({ format: "all" \| "pdf" \| "docx" })` | `./laporan build` or `bash build.sh && make docx` |

--------------------------------------------------------------------------------

## 2. Multi-Stage Interactive Protocol (The 5-Stage Academic Production Protocol)

Always guide the user through these 5 structured stages:

### Stage 1: Context Discovery & Genre Selection
Identify the document type and target university:
1. **Tugas Akhir / Skripsi / Tesis**: Formal 5-chapter structure (BAB I - BAB V), bilingual abstract, approval sheet, standard university margins.
2. **Laporan Magang / PKL / KKN**: Company profile, department scope, implemented system/project, troubleshooting analysis, recommendations.
3. **Makalah Kuliah / Paper Ilmiah**: Focus on research problem, methodology, findings, and discussion. (In Indonesia, course papers use standard Roman Bab headings: `BAB I`, `BAB II`, etc.).
4. **Target University Preset**:
   - `skripsi-4433`: National Standard (Top 4cm, Left 4cm, Bottom 3cm, Right 3cm).
   - `ui-skripsi`: Universitas Indonesia (Buku Panduan UI).
   - `itb-ta`: Institut Teknologi Bandung (Pedoman TA ITB).
   - `ugm-skripsi`: Universitas Gadjah Mada (Format Skripsi UGM).
   - `its-skripsi`: Institut Teknologi Sepuluh Nopember.
   - `unpad-skripsi`: Universitas Padjadjaran.
   - `standard`: General University (2.5cm / 2cm).

### Stage 2: Document Structure Confirmation & Scaffolding
1. **Confirm Document Structure**:
   - The universal default structure is minimal: **Cover -> Kata Pengantar -> Daftar Isi -> Batang Tubuh (BAB I..n) -> Daftar Pustaka**.
   - **MANDATORY INQUIRY**: Ask the user before scaffolding if they want to activate optional components:
     - Abstrak / Abstract (`abstract_id` / `abstract_en`)
     - Lembar Pengesahan (`approval`)
     - Daftar Gambar (`daftar_gambar: true`)
     - Daftar Tabel (`daftar_tabel: true`)
     - Lampiran
2. **Initialize the workspace**:
   - Call MCP tool `laporan_init` (e.g. `laporan_init({ preset, title, daftar_gambar, daftar_tabel })`) or run `npx laporan-generator init`.
3. **Configure `metadata.yml`**:
   - `title`: Clear, concise, capitalized (rendered as inverted pyramid).
   - `author`: Author array with `name` and `nim` (Student ID).
   - `preset`: Selected university preset (e.g. `skripsi-4433`, `itb-ta`).
   - `daftar_gambar: false`, `daftar_tabel: false` (set to `true` only if opted-in).
   - `abstract_id`: Kept empty or commented out unless user requested Abstrak.
   - `institution`, `faculty`, `department`, `year`.
4. **Configure `cover.md`**: Set formal title, institutional affiliations, and kata pengantar.

### Stage 3: Rigorous Academic Writing Standard
When authoring content into `chapters/bab*.md`, strictly enforce **Indonesian Standard Academic Tone**:
- **Objective & Impersonal**: Use passive constructions (*"Penelitian ini merancang sistem..."* instead of *"Saya merancang sistem..."*; *"Data diperoleh melalui pengujian..."* instead of *"Kami mengambil data..."*).
- **Zero AI Buzzwords / Clichés**:
  - ❌ NEVER use: *"Dalam era globalisasi dan revolusi industri 4.0 yang serba cepat...", "Hal ini tentu sangat penting dan krusial...", "Tak dapat dipungkiri bahwa..."*
  - ✔ INSTEAD: State facts, empirical evidence, concrete problem statements, and causal relationships immediately.
- **Heading Hygiene**:
  - `# Judul Bab` for chapter level (e.g. `# Pendahuluan`, `# Tinjauan Pustaka`).
  - `## Sub-bab` for section level (e.g. `## Latar Belakang Masalah`).
  - ❌ NEVER write manual numbers in headings (e.g. NEVER `## 1.1 Latar Belakang` or `### 2.1.3 Analisis`). The engine automatically computes chapter and sub-chapter numbering based on the active university preset!

### Stage 4: Citation Hygiene & Anti-Hallucination
- **NO FAKE CITATIONS**: Never invent fake paper titles, authors, or DOIs.
- Use MCP tool `laporan_citations` with `action: "search_doi"` to search real papers on Crossref.
- Add verified BibTeX to `references.bib` via `laporan_citations` (`action: "add_citation"`).
- Reference citations in markdown body using Pandoc syntax:
  - Single citation: `[@citekey]`
  - Narrative citation: `@citekey menyatakan bahwa...`
  - Multiple citations: `[@citekey1; @citekey2]`

### Stage 5: Pre-Flight Audit & Dual-Compilation
1. Run pre-flight health audit:
   - Call MCP tool `laporan_doctor` or run `./laporan doctor`.
   - Ensure `missing_keys` is 0 and `broken_images` is 0.
2. Compile both outputs:
   - Call MCP tool `laporan_build` or run `./laporan build`.
   - Produces:
     - `Laporan.pdf`: Pixel-perfect publication PDF rendered by Typst.
     - `Laporan.docx`: Fully formatted Word document with dual page numbering (Roman `i, ii, iii` for front-matter, Arabic `1, 2, 3` for chapters) and native Word Table of Contents.

--------------------------------------------------------------------------------

## 3. Formatting Rules & Syntax Guardrails

| Element | Correct Syntax | Common Pitfall to Avoid |
| :--- | :--- | :--- |
| **Currencies & Special Symbols** | `\$100` or `100 USD` | Unescaped `$100` triggers math mode parsing failure |
| **Mathematical Formulas** | Inline: `$E = m c^2$`<br/>Block: `$$\\sum_{i=1}^n x_i$$` | Multiple unescaped `$` on the same page |
| **Images & Figures** | `![Diagram Arsitektur](gambar/arsitektur.png)` | Referencing non-existent files or absolute paths |
| **Tables** | Standard Markdown pipe tables with headers | Box-drawing characters (┌, ─, └, │) in markdown |
| **Code Blocks** | Standard triple backticks with language specifier | Monolithic raw typst code |

--------------------------------------------------------------------------------

## 4. Troubleshooting & Self-Correction Runbook

- **Missing Pandoc or Typst**:
  - Run `npx laporan-generator setup` to automatically install dependencies for Ubuntu/Debian, Arch Linux, macOS, Nix, or Windows.
- **Citation "@key" not found**:
  - Call `laporan_citations({ action: "validate" })` to check all existing keys in `references.bib`.
- **Word DOCX Table of Contents alignment**:
  - Built-in `finalize-docx.py` automatically computes page width and right-aligns tab leader dots for Heading 1, Heading 2, and Heading 3.
