# First-party SDK root

disposition: promoted

## Reusable Insight

The reconstructed AngelScript SDK is first-party Runtime source at `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/`. It is not a ThirdParty drop. Headers sit beside `frontend/`; there is no nested `source/` directory. The public C API header remains `Source/AngelscriptRuntime/Core/angelscript.h`. Include `"frontend/…"` against the `angelscript/` include root.

## Evidence

- Submodule working tree: `ThirdParty/angelscript` gone; `angelscript/as_*.h` and `angelscript/frontend/` present.
- `AngelscriptRuntime.Build.cs` historically added `ThirdParty/angelscript/source` as the include root.

## Boundaries

- Does not change `BEGIN_AS_NAMESPACE` or public C API location.
- Immutable archives may still cite the old path historically.
- Host CMake fork root is owned by `angelscript/refactor-standalone-lsp-layout`.

## Application

Use this path in current specs, UBT includes, and new tasks. Do not reintroduce `ThirdParty/angelscript` as a live instruction.

## Sources

- `attachments/drafts/findings/directory-moves.md`
- `attachments/drafts/design.md`
