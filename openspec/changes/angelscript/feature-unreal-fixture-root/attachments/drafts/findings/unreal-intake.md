# What CodeGen does once Unreal is admitted

Date: 2026-09-17. Q23 = create admitted `AngelscriptTestCode/Unreal/` now. Source draft finding (Chinese original; approval R27).

`discover_sources` takes every `.as` under the author root except `CodeGenTool/` and `Pending/`. Files placed in `Unreal/` must parse as current `@begin` containers and emit `.generated.cpp`. Old Pending `@version root` stars cannot be dropped in unchanged.

The 124 Language UClass files are not one concern:

```
Pending/Language/**/UClass  124
├─ Casting/UClass           2
├─ EdgeCases/UClass         89
├─ Preprocessor/UClass      12
└─ other scatter            21
```

Plus `Pending/World` 124. The 580 Bindings leftovers are a later wave.
