# First-party SDK root

## Reusable Insight

The reconstructed AngelScript SDK is first-party Runtime source at `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/`. It is not a ThirdParty drop. Language headers live under `frontend/<Phase>/` (`Basic`, `Lexer`, `Parser`, `AST`, `Sema`, `Compile`); there is no nested `source/` directory. The public C API header remains `Source/AngelscriptRuntime/Core/angelscript.h`. Include `"frontend/<Phase>/as_*.h"` against the `angelscript/` include root. Live Runtime/Editor consumers include SDK headers as `"as_*.h"` or `"frontend/<Phase>/as_*.h"`, not `"source/as_*.h"` and not a flat `"frontend/as_*.h"`.

## Evidence

- `AngelscriptRuntime.Build.cs` public include root is `ModuleDirectory/angelscript`.
- Frontend leaves such as `AST/as_decl.h` / `Parser/as_parser.h` live under `angelscript/frontend/<Phase>/`; VM/engine leaves such as `as_scriptengine.h` live at the SDK root. `as_builder.h` stays at the SDK root.
- Editor Development build RunId `f0fb5e1625a24ed88dc39b916347bd05` succeeded after that include root and the `source/` include retarget.

## Boundaries

- Does not change `BEGIN_AS_NAMESPACE` or the public C API location.
- Immutable archives may still cite `ThirdParty/angelscript` historically.
- Host CMake fork root is owned by `angelscript/refactor-standalone-lsp-layout`.
- Dormant Legacy tests may still name deleted headers; they are not a live include contract.

## Application

Use this path in current specs, UBT includes, and new tasks. Do not reintroduce `ThirdParty/angelscript`, `#include "source/as_*.h"`, or a flat `#include "frontend/as_*.h"` as a live instruction.

## Sources

- `openspec/changes/angelscript/refactor-runtime-owned-sdk-layout/attachments/knowledges/first-party-sdk-root.md`
- `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`
