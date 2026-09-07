# Project Verification Commands

## Discovered Verification Commands
- **test_unit**: `npm test`
- **typecheck**: `npx tsc --noEmit`
- **lint**: `npx eslint --fix`
- **build**: `npm run build`


## Verification Protocol
- 100% deterministic checks must pass before Devil's Advocate review.
- Unit tests must cover boundary cases, null safety, and error paths.
