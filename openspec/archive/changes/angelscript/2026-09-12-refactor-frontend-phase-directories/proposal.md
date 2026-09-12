## Why

Reconstructed language sources are 107 colocated files under `angelscript/frontend/`. Specs are already phased; Clang phases the same pipeline by directory. The remaining navigation cost is the flat bag plus leftover `as_frontend_*` implementation names that do not match their headers.

C++ names and language behavior stay. This Change only normalizes source layout and include strings.

## What Changes

- Split `frontend/` into six colocated folders: `Basic/`, `Lexer/`, `Parser/`, `AST/`, `Sema/`, `Compile/`.
- Rename implementation files to match header stems (`as_parser.cpp`, `as_sema.cpp`, …). Keep `as_frontend_options.h` as the filename and move it into `Lexer/`.
- Rename SDK-root `as_builder_frontend.cpp` to `as_builder.cpp`. Leave `as_builder.h` and bytecode emit at the SDK root.
- Rewrite live `#include "frontend/as_*.h"` to `#include "frontend/<Phase>/as_*.h"`.
- Retarget the ast/core directory sentence and live knowledge that cite the flat path.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/language/ast/core`: reconstructed language headers live under `frontend/<Phase>/`. The folder name `frontend` is still not a C++ namespace.

## Impact

`Plugins/Angelscript` submodule: `AngelscriptRuntime` frontend sources and every live include of those headers (Runtime, Core, AngelscriptTest, and any live Editor include). Parent-repo OpenSpec records for this Change and the ast/core path sentence.

No public C API change. No `asC*` rename. No new UBT include root.

## Boundaries

- No Clang `include/` vs `lib/` split.
- No nested `frontend/Frontend/`.
- No product lex/parse/sema behavior change.
- No move of `as_builder.h` or bytecode emit into `frontend/`.
- No new `language/frontend/parsing` spec.
- Do not start the file moves while `angelscript/test-lexer-isolated-coverage` or `angelscript/refactor-bindings-two-stage-pipeline` still mutate the same files, unless the user sequences this after them.

## Acceptance

After this Change:

1. `frontend/` contains only `Basic/`, `Lexer/`, `Parser/`, `AST/`, `Sema/`, and `Compile/`.
2. Live includes use `#include "frontend/<Phase>/as_*.h"`. Flat `#include "frontend/as_*.h"` is gone from the live build.
3. `as_builder.cpp` exists at the SDK root; `as_builder_frontend.cpp` does not.
4. `frontend/Lexer/as_frontend_options.h` exists; `as_lex_options.h` does not.
5. `ue.build` of the selected workspace succeeds.
