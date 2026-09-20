# Accepted: admitted Unreal root

Status: designed (R27). Source draft: `openspec/drafts/angelscript/language-fixture-quality/designs/unreal-home/design.md` (Chinese original; approval R27).

Names: [glossary.md](glossary.md). Evidence: [unreal-home.md](findings/unreal-home.md), [unreal-all-intake.md](findings/unreal-all-intake.md), [two-changes.md](findings/two-changes.md).

## Problem

UClass / SpawnActor / WorldStory are UE features, not core language, and must not enter `Language/`. The directory name `Bindings` is rejected. The corpus needs an admitted root `AngelscriptTestCode/Unreal/`.

## Accepted direction

- Q22: the home is `Unreal`.
- Q23: admit the root now; do not park under Pending first.
- Q25/Q29: first batch = 124 Language UClass files plus 124 Pending/World files. The 580 Bindings leftovers stay out.
- Q26 spirit: merge by theme; do not copy 248 files as-is.
- Q27/Q28: this Change is `angelscript/feature-unreal-fixture-root`.

## Contract

CodeGen already discovers `.as` files outside `Pending/` and `CodeGenTool/`. Unreal files must use the current `@begin` pocket grammar.

```
Unreal/Casting
Unreal/Strings
Unreal/GarbageCollection
Unreal/Input
Unreal/Events
Unreal/Reflection
Unreal/ActorClass
Unreal/Hooks
Unreal/World/Actor
Unreal/World/Component
Unreal/World/Blueprint
Unreal/World/Streaming
Unreal/World/Subsystem
```

Add `*CompileFail` / `*RuntimeFail` when the theme has that polarity.

## Verification

FileTags such as `Unreal/Casting` register. `codegen.py check` passes. The Language corpus does not treat these Tags as core language. This Change does not prove World execution.
