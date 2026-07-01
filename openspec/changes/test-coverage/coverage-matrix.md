# AngelScript Coverage Test Matrix, Main Index

> This file is the **main index** for `AngelscriptTest/Coverage/` coverage records and replaces all scattered documents under `Documents/Coverage/`.
> **Expanded capability matrices** live in 18 files under `matrices/`, split by **AS type / feature area**. Each row is a verifiable scenario with status and the corresponding `TEST_METHOD`, and can guide test implementation. This index keeps only the unified legend, column definitions, domain index, and global summary.
>
> - **Authoritative source**: actual test code in `Plugins/Angelscript/Source/AngelscriptTest/Coverage/*.cpp`, not historical planning documents.
> - **Scan baseline date**: 2026-06-30.
> - **Scale**: 89 test files, 90 Automation themes, and **1010** `TEST_METHOD`s, mechanically counted from leading `TEST_METHOD(...)` lines. After adding G1/G2/G5/G6/G8/G10 on 2026-07-01, AnimInstance +1, SaveGame +1, TArrayAdvanced +1, TMapAdvanced +1, UClass +1, ClassLifecycle +1, plus a backfilled Comment +1 that the previous main index missed.
> - **Test shape**: CQTest `TEST_CLASS_WITH_FLAGS` + `TEST_METHOD`, with Automation prefixes standardized as `Angelscript.TestModule.Coverage.<Theme>`.
> - **Pending coverage items and fork-unsupported boundaries**: tracked in `coverage-gaps.md`.

## Legend

| Marker | Meaning |
|------|------|
| ✅ | Covered, with a corresponding `TEST_METHOD` asserting the scenario |
| 🟡 | Partially covered, with known enhancement items listed in `coverage-gaps.md` |
| ⬜ | Pending implementation, with no corresponding test yet |
| 🚫 | Current fork unsupported / not applicable, guarded by negative compile assertions or excluded from plan |

## Column Definitions

| Column | Meaning |
|----|------|
| Scenario | A concrete verifiable capability or usage pattern, the smallest matrix row unit |
| Status | See the legend above |
| Coverage Test Method | The `TEST_METHOD` name that asserts the scenario, using `File::Method` for cross-file references |
| Notes / Pending Work | Coverage notes; ⬜ rows describe the implementation to add |

> Domain matrices also list coverage test files, method counts, and Automation prefixes so the matrix maps directly to test files.

---

## Domain Matrix Index

### Types And Language Structures

| Matrix File | Scope | Files | Methods |
|---------|------|-------|-------|
| [01-basic-types.md](matrices/01-basic-types.md) | int / float / bool / FString: properties, expressions, functions, methods | 13 | 151 |
| [02-math-structs.md](matrices/02-math-structs.md) | FVector / FRotator / FQuat / FTransform / FLinearColor / FVector2D plus Math namespace / geometry structs | 20 | 142 |
| [03-containers.md](matrices/03-containers.md) | TArray / TMap / TSet and container parameters / nesting | 6 | 60 |
| [04-object-references.md](matrices/04-object-references.md) | handles / weak references / soft references / TSubclassOf / TObjectPtr / GC | 5 | 57 |
| [05-uclass.md](matrices/05-uclass.md) | UCLASS / class system / lifecycle / class features / default components / property references | 5 | 83 |
| [06-ustruct.md](matrices/06-ustruct.md) | USTRUCT and members | 2 | 47 |
| [07-macros-enum-function-interface.md](matrices/07-macros-enum-function-interface.md) | UENUM / UFUNCTION / UINTERFACE / aggregate macros / meta specifiers | 5 | 101 |
| [08-delegates-events.md](matrices/08-delegates-events.md) | single-cast, multicast, dynamic delegates plus events | 4 | 52 |
| [09-control-flow-language.md](matrices/09-control-flow-language.md) | control flow / namespaces / preprocessor / type conversion / mixin / const / operator overloads | 11 | 63 |
| [10-components.md](matrices/10-components.md) | Component / Scene / Primitive / specialized components | 4 | 55 |

### Feature Systems

| Matrix File | Scope | Files | Methods |
|---------|------|-------|-------|
| [11-timer-async.md](matrices/11-timer-async.md) | timers / delayed execution / Latent boundaries | 1 | 31 |
| [12-input.md](matrices/12-input.md) | legacy input plus Enhanced Input | 1 | 21 |
| [13-physics-collision.md](matrices/13-physics-collision.md) | physics / collision / traces / constraints / character movement | 1 | 25 |
| [14-widget-ui.md](matrices/14-widget-ui.md) | Widget / UMG, including the Widget.RuntimeApi prefix | 1 | 24 |
| [15-networking.md](matrices/15-networking.md) | replication / RPC / network roles | 1 | 28 |

### Support And Miscellaneous

| Matrix File | Scope | Files | Methods |
|---------|------|-------|-------|
| [16-assets-and-save.md](matrices/16-assets-and-save.md) | asset loading / literal assets / materials / SaveGame | 4 | 20 |
| [17-debug-logging.md](matrices/17-debug-logging.md) | debug / logging / error handling | 3 | 36 |
| [18-misc-systems.md](matrices/18-misc-systems.md) | CVar / AnimInstance | 2 | 14 |

---

## Global Summary

| Dimension | Value |
|------|------|
| Domain matrix files | 18 |
| Test `.cpp` files | 89 |
| Automation themes | 90, with Widget including the second `Widget.RuntimeApi` prefix |
| Total `TEST_METHOD`s | 1010 |
| Current ⬜/🟡 candidates | 21, with G1/G2/G5/G6/G8/G10 already added among G1-G29; see `coverage-gaps.md §1`. All are optional enhancements and non-blocking |

> Check: file counts across the 18 domain matrices sum to 89; method counts sum to 1010.
> Maintenance rule: when adding or removing Coverage tests, update the scenario rows and method count in the relevant `matrices/<domain>.md` first, then backfill this table.
