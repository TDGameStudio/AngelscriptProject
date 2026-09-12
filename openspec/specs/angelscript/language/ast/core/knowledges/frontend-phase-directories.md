# Frontend phase directories and include shape

## Reusable Insight

Reconstructed language sources live under `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/<Phase>/`, headers beside cpp. Phases are `Basic`, `Lexer`, `Parser`, `AST`, `Sema`, and `Compile`. Includes stay on the `angelscript/` root: `#include "frontend/<Phase>/as_*.h"`. Do not add a phase folder as a UBT include root.

```text
angelscript/
├─ as_builder.h / as_builder.cpp      // SDK compile entry; not inside frontend/
├─ as_bytecode_emitter.*              // not frontend CodeGen
└─ frontend/
   ├─ Basic/                          // source, diagnostics, identifiers, surface, stable key
   ├─ Lexer/                          // tokens + preprocessor + as_frontend_options.h
   ├─ Parser/                         // as_parser* + as_type_syntax*
   ├─ AST/                            // nodes, context, codec, as_type_context
   ├─ Sema/                           // ActOn*, fragments, as_type_identity
   └─ Compile/                        // session, stages, host trio
```

Preprocessor files belong in `Lexer/`. `as_type_syntax*` belongs in `Parser/`. `as_stable_key` belongs in `Basic/` because Engine/TypeInfo include it.

## Evidence

- Include root is `AngelscriptRuntime/angelscript` (`AngelscriptRuntime.Build.cs`).
- ast/core: directory organization is independent of `BEGIN_AS_NAMESPACE`; `frontend/` is not a C++ namespace.
- Editor Development build RunId `196f9e5ffcc74c4fa21bfb1e0c2495e1` succeeded after the phased move.

## Boundaries

- Does not change C++ type names or add a frontend namespace.
- Does not move `as_builder.h` or bytecode emit into `frontend/`.
- Spec capability ids (`lexing`, `declarations`, `bodies`) are not folder names.

## Application

When adding a reconstructed language file, put it in the matching phase folder and include it as `"frontend/<Phase>/as_name.h"`. When citing a header in a live spec or knowledge, use the phased path.

## Sources

- `openspec/changes/angelscript/refactor-frontend-phase-directories/attachments/knowledges/frontend-phase-directories.md`
- `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`
