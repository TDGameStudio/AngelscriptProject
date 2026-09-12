# No include/lib split and no nested Frontend folder

## Context

Clang splits public headers under `include/clang/` from implementations under `lib/`, and names the CompilerInstance layer `Frontend/`. This Change phases `angelscript/frontend/` without copying those two shapes.

## Evidence

- Reconstructed language sources are 107 colocated files. UE modules keep headers beside cpp.
- The top folder is already `frontend/`. A nested `frontend/Frontend/` collides with that name.
- ast/core already forbids an extra frontend/V2 C++ namespace. Directory layout is independent of that scope.

## Options

| Option | Result |
| --- | --- |
| A. Phase folders, headers beside cpp | Matches UE and the spec tree |
| B. Rename files only | Cheaper, leaves the flat bag |
| C. Full Clang include/lib | Doubles the tree for no include-root gain |

## Settled Decision

Option A. Do not add `include/` vs `lib/`. Do not create `frontend/Frontend/`.

## Consequences and Flip Condition

Includes stay `#include "frontend/<Phase>/as_*.h"`. If the SDK later publishes a separate public-header tree outside the UE module, revisit include/lib. If the top folder is renamed away from `frontend/`, a `Frontend/` phase name becomes available.

## Sources

- `attachments/drafts/findings/frontend-layout.md`
- `attachments/drafts/design.md`
- Draft `log.md` Round 1 Q1 (original wording stays in the draft)
