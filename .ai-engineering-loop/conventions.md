# Project Conventions

## Code Standards
- File naming: kebab-case or established repository convention.
- JavaScript: Preserve Node.js 18+ compatibility and follow the module conventions already used by each file.
- Python: Keep scripts compatible with CI/Nix versions; account for Windows paths and terminal encodings.
- Shells: Preserve Bash and PowerShell parity for commands exposed by both helpers.
- Error handling: Return a non-zero status with an actionable message when builds or subprocesses fail; avoid silently swallowing errors.
- Generated resources: Edit canonical root files, then synchronize `.agents/` copies through the established package process.

## Forbidden Anti-Patterns
- Zero speculative TODOs or orphan dead code in production pull requests.
- Never commit private secrets, passwords, or API keys.
- Do not make unsolicited renovations outside the active Goal Contract scope.
