# Current coverage gaps (2026-09-15)

English export. Source identity: angelscript/newversion-retirement findings/coverage-gaps.md. Observations, not a fill list.

## Already thick

- VM: 327 methods (opcodes, admission, dispatch, object lifetime, GC, cross-Engine cache).
- Bodies + Declarations: large semantic scenario sets.
- Definitions: engine-free type/function factories.
- Lexer (durable home): 31 methods.
- Bindings: 314 methods on the UE interop surface, not the language frontend.

## Thin or empty

| Gap | Evidence | Note |
|---|---|---|
| No Parser unit tree | No Parser directory under NewVersion/NativeEngine | Production has `frontend/Parser/` |
| LanguageSurface is not a language matrix | Syntax has 12 methods, mostly retired-feature rejection | No operator×type or `+=` product matrix |
| Source-to-VM is thinner than VM | Compiler 112 methods vs VM 327 | Missing script globals, `N::F()`, struct runtime, inherited dispatch |
| foreach | Mostly rejection | Positive execution only if the product supports it |
| Diagnostics / Tooling / ModuleGraph | Representative cases | Not matrices |

Filling TestCode `.as` files does not close these holes: corpus bytes are not execution evidence until they pass Builder and the VM.

Relocating tests is directory and identity work. Completing coverage is per-layer scenario work. This Change owns both, in that order.
