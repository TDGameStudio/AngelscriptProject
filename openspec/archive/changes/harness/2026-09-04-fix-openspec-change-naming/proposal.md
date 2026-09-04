## Why

The project previously required semantic Change leaves in `<type>-<scope>-<outcome>` form, but the rule was removed during the Harness documentation rewrite without being transferred to a current authority. The portable CLI still enforces lowercase portable syntax, so syntactically valid but semantically ambiguous Changes can now be created through the normal Harness route.

## What Changes

- Restore the project Change naming contract with the allowed `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, and `chore` type prefixes.
- Reject nonconforming targets before normal Harness `openspec.change create` and `change move --to` operations reach the portable CLI.
- Audit active Change identities while leaving every historical archive path and manifest immutable.
- Keep the portable OpenSpec CLI generic; this project policy remains in Harness, project Skills, and the durable Harness specification.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: Restore deterministic project-level naming for new and active OpenSpec Changes without rewriting archives.

## Impact

The parent repository changes `.agents/skills/harness`, `.agents/skills/openspec`, their PowerShell tests, and the Harness core specification. No plugin or `Tools/openspec` submodule source changes, package release, executable rebuild, or historical archive rewrite is included.
