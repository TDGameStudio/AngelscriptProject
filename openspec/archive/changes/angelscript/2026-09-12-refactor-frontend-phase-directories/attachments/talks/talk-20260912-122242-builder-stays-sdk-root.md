# Builder stays at the SDK root

## Context

`asCCompilationSession` and `as_builder_stages.h` move into `frontend/Compile/`. `asCBuilder` is the public compile entry and also emits bytecode.

## Evidence

- `asEBuilderStage` includes `ByteCodeEmitted`. `asCBuilder::RunThrough` is wider than the language frontend.
- Callers include `as_builder.h` from the `angelscript/` include root, next to the engine.
- Bytecode emit already lives at the SDK root, not under `frontend/`.

## Options

| Option | Result |
| --- | --- |
| A. Move `as_builder.h` and its cpp into `Compile/` | Session and Builder share a folder; public include becomes `frontend/Compile/as_builder.h` |
| B. Keep both at the SDK root | Public compile API stays beside the engine |
| C. Keep the header at the root; move the cpp into `Compile/` | Facade short include; impl joins the session |

## Settled Decision

Option B. `as_builder.h` and its implementation stay at `angelscript/`. Only session, stages, and the host trio live in `Compile/`. The cpp is renamed to `as_builder.cpp`.

## Consequences and Flip Condition

`#include "as_builder.h"` does not change. If Builder is later treated as a Clang `CompilerInstance` that must live with the session, move the cpp into `Compile/` and keep the header at the root (option C).

## Sources

- `attachments/drafts/findings/frontend-layout.md`
- `attachments/drafts/design.md`
- Draft `log.md` Round 2 Q3 (original wording stays in the draft)
