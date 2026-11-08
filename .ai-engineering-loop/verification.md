# Project Verification Commands

## Discovered Verification Commands
- **primary_suite**: `./test.sh`
- **python_unit**: `python3 scripts/test_scripts.py`
- **mcp_integration**: `node tests/test_mcp.js`
- **examples**: `./examples/build_examples.sh`
- **nix_suite**: `nix develop --command bash -lc './test.sh'`
- **pdf_build**: `./build.sh templates/default`
- **docx_build**: `./build-docx.sh templates/default`
- **windows_cli**: `pwsh -File ./laporan.ps1 preset validate`



## Verification Protocol
- For code changes, run the targeted check first, then the relevant full suite and build command.
- Before a release, require Linux, Nix, Windows, and macOS CI jobs; run Python and MCP suites plus examples on supported runners.
- Do not run autofix commands unless explicitly defined and requested; this project has no TypeScript check or `npm run build` script.
- Check platform parity with native PowerShell on Windows and Bash on Linux/macOS.
