# Consumers that must replan old SDK paths

This Change does not rewrite other Task DAGs. Active Changes whose Files still name `ThirdParty/angelscript` must replan those nodes to `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/` (frontend leaves under `frontend/`; VM/engine leaves at the SDK root).

Scanned 2026-09-11 against `openspec/changes/**/tasks.md`.

| Change | Why it must replan |
|---|---|
| `angelscript/feature-frontend-diagnostics-tooling` | Files `ThirdParty/angelscript/source/frontend/**` and `source/as_builder*.cpp` |
| `angelscript/refactor-sdk-drop-native-gc` | Files `ThirdParty/angelscript/source/as_gc.*` and sibling engine sources; also still Files `Plugins/Angelscript/Standalone/` |
| `angelscript/refactor-bindings-two-stage-pipeline` | Files `ThirdParty/angelscript/source/as_metadata_image.*`, `as_memory.*`, `as_native_bindings.cpp`, `frontend/as_binding_*` |
| `angelscript/feature-delegates-ue-interop` | Files `ThirdParty/angelscript/source/frontend/as_*` and `source/as_callable*` / `as_bytecode*` / `as_multicast*` |

Not listed: `angelscript/refactor-standalone-lsp-layout` (owns host CMake, not these Files), `angelscript/refactor-testing-unified-framework` (TestCode/TestFramework), Changes whose only ThirdParty hits are attachments rather than Files.

If a listed Change is abandoned instead of replanned, drop it from this table in that Change's closure, not here.
