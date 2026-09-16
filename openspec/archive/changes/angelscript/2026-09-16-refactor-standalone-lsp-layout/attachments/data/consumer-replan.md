# Consumers that must replan Standalone paths

This Change does not rewrite other Task DAGs. Active Changes whose Files still name `Plugins/Angelscript/Standalone/` must replan those nodes to `Plugins/Angelscript/AngelscriptLSP/`.

Scanned 2026-09-11 against `openspec/changes/**/tasks.md`.

| Change | Why it must replan |
|---|---|
| `angelscript/refactor-sdk-drop-native-gc` | Files `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp` and `Standalone/Source/Registration/AngelscriptRegistrationLoader.cpp` |

No other active Change Files `Plugins/Angelscript/Standalone/` in `tasks.md`. Sibling `angelscript/refactor-runtime-owned-sdk-layout` owns Runtime include roots, not this host tree.

If drop-native-gc drops the host inventory instead of moving it, remove it from this table in that Change's closure, not here.
