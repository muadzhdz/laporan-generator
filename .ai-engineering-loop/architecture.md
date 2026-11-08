# Project Architecture

## System Overview
Architecture for laporan-generator, an npm-distributed academic document generator CLI.

## Main Components
- `bin/` and `lib/`: Node.js CLI routing and MCP/server functionality.
- `templates/default/` and `presets/`: Document templates and configurable academic formats.
- `build.sh`, `build-docx.sh`, `laporan`, `laporan.ps1`: PDF/DOCX build pipeline and platform helpers.
- `scripts/`: Python utilities for validation, import, and document analysis.
- `docs/`, `examples/`, and `.agents/skills/`: User guidance, buildable samples, and synchronized agent resources.

## Document Flow
Markdown chapters and `metadata.yml` are processed by Pandoc. PDF output uses Typst; DOCX output uses Pandoc/OpenXML filters. Optional CLI commands use Python utilities and the MCP server.

## Discovered Top-Level Directories
- `bin/`
- `completions/`
- `docs/`
- `examples/`
- `lib/`
- `presets/`
- `scripts/`
- `templates/`
- `tests/`

## Boundary Invariants
- Keep the npm CLI, document templates, platform helpers, Python scripts, and MCP integration loosely coupled.
- Keep generated/synchronized `.agents/` resources in sync with canonical root files through the package prepack process.
- Preserve supported command paths on Linux, macOS, and Windows.
- Keep PDF and DOCX build pipelines independently diagnosable.

## Evidence & Confidence
- Observed from: Directory scan, package manifests
- Confidence: HIGH
