# Spec synchronization

Change `angelscript/feature-frontend-diagnostics-and-tooling` merged its durable deltas into current specs on 2026-09-15 before completed archive. Preserved unspecified scenarios were not reformatted.

## Created

| Capability | Result |
|---|---|
| `angelscript/language/frontend/tooling` | Created via `openspec.spec create`; current spec strict-valid |

## Merged into existing current specs

| Capability | Delta | Current strict result | Notes |
|---|---|---|---|
| `angelscript/language/frontend/lexing` | MODIFIED interning + ADDED file-local lexical facts | Passed | New concurrent-spelling scenario appended; existing cards preserved |
| `angelscript/language/frontend/source-diagnostics` | MODIFIED structured diagnostics + ADDED catalog/policy/presentation/coordinates/fixes/Diag | Failed 23 | Baseline four-space indent on preserved coordinate/provenance cards; same class of errors as pre-sync |
| `angelscript/language/ast/core` | MODIFIED AST authority + ADDED partial read-only results | Failed 77 | Baseline indent on preserved cards; same class as pre-sync |
| `angelscript/language/frontend/builder` | ADDED root diagnostics, queued Lex/PP, single PP consume | Failed 2 | Only preserved `Analyze supported source through the replacement` indent; same 2 errors as pre-sync |
| `angelscript/language/frontend/declarations` | ADDED specific declaration failure explanations | Failed 68 | Baseline indent on preserved cards; same class as pre-sync |
| `angelscript/language/frontend/bodies` | ADDED non-cascading body diagnostics | Failed 64 | Baseline indent on preserved cards; same class as pre-sync |

Affected-target pre-sync: lexing Passed; the five Failed IDs above already failed four-space indentation before this merge. Those baseline failures are not treated as delta defects and were not silently migrated.

## Validation

`openspec.validate --type spec --strict` after merge: tooling and lexing Passed. The other five Failed IDs retain only pre-existing preserved-card indentation issues. Change `openspec.validate --type change --strict` and `openspec.doctor` Succeeded.
