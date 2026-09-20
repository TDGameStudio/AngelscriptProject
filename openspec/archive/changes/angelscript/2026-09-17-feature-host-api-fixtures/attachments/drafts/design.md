# Accepted: host API leftovers plus Pending containers

Status: designed (R29). Source draft: `openspec/drafts/angelscript/language-fixture-quality/designs/container-home/design.md` (Chinese original; approval R29).

Names: [glossary.md](glossary.md). Evidence: [bindings-intake.md](findings/bindings-intake.md), [host-destinations.md](findings/host-destinations.md), [two-changes.md](findings/two-changes.md).

## Problem

The Bindings holding tree has 580 type folders and about 2420 `Observe_*` entries still using privileged `root` stars. `Pending/Containers` (240) is a second authoring contract with Fail files, thicken, and pointer types. Taking only one pile drops cases. The admitted directory name `Bindings` is rejected. The already-created Unreal Change first batch excludes these 580 files.

## Accepted direction

- Q32: value-container home is `AngelscriptTestCode/Containers`.
- Q33: absorb the entire 580-type Bindings wave.
- Q34: this is a third Change, not folded into `feature-unreal-fixture-root`.
- Q35=A: split roots in this Change. T* / SoftObjectPath / `Pending/Containers` (including pointer types and Fail) go to `Containers/`. The remaining ~93 Bindings folders go to `Unreal/<Type>`, deduped against the Unreal first-batch theme pockets. No `Library/` root.
- Authoring follows the accepted pocket contract: `@begin`, Fail siblings, `@function`. Bindings axis files are the positive skeleton. TSet files that say they are not TSet API move out of the container home; they are not deleted.
- `Pending/Math` (111) overlaps Bindings FVector/FMath and merges into the same `Unreal/` math pockets.
- Q36: Change ID is `angelscript/feature-host-api-fixtures`.
- Q37: create now.

## Three Changes

```
feature-language-second-wave-fixtures
└─ Language/ six host-free themes

feature-unreal-fixture-root
└─ Unreal/ first batch: 124 UClass + 124 World theme pockets
   (its handoff still parks the 580 Bindings leftovers)

feature-host-api-fixtures
├─ Containers/  TArray TMap TSet TOptional TSoft* TWeak TSubclass TObjectPtr SoftObjectPath
└─ Unreal/      FMath FString AActor Json … by type folder; merge when colliding
                with Unreal/Strings, Input, World/Actor
```

## Pocket grain left to Ensure plan

Whether Bindings `Behavior` / `Queries` axes become `@begin` groups or extra FileTags is derived in planning from Q26 (one positive pocket plus Fail per type).
