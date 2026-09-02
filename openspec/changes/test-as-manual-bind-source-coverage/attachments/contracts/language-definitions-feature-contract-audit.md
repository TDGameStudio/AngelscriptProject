# Language / Definitions / Feature Contract V2 audit

Date: 2026-08-24  
Scope: read-only review of `TestSource/Language/**`, `TestSource/Definitions/**`, and `TestSource/Feature/**`  
Exhaustive mapping: `language-definitions-feature-contract-audit.json`  
JSON SHA-256: `62f433fcc9432db913346c762abbbcf8de613e7e6ff2daf8ee5b79fa5d1d32ad`

## Outcome

- All **1528** `.as` files map one-to-one to an authoritative OpenSpec CaseId: Language 642, Definitions 519, Feature 367.
- The audit maps **6248** callable declarations. Every row has old symbol/declaration, CaseId/subcaseId, semantic successor name/declaration, immediate English comment facts, inputs, raw return/writebacks, exceptions, fixture, cleanup, runner status, and required-name reason.
- Hard renames: **3009** legacy declarations and **266** generic declarations. Forwarding aliases are forbidden.
- **1037** compound boolean observers are split into independently visible outputs. **10** current declarations with `Expected*` inputs have proposals without them.
- **1959** declarations retain language/reflection/lifecycle/FName/import identities with a non-empty reason.
- **591** files are compiler/diagnostic fixtures; **321** are source-layout sensitive.
- **20** Critical/High files incorporate the existing high-risk audit rather than mechanically retaining false-positive observers.

## Theme totals

| Theme | Files | Callables | Legacy renames | Negative | Line-sensitive | High-risk additions |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `Definitions/Meta` | 52 | 238 | 164 | 13 | 0 | 0 |
| `Definitions/UClass` | 122 | 393 | 283 | 52 | 0 | 6 |
| `Definitions/UEnum` | 16 | 68 | 54 | 3 | 0 | 0 |
| `Definitions/UFunction` | 128 | 625 | 330 | 52 | 25 | 0 |
| `Definitions/UInterface` | 24 | 79 | 22 | 13 | 12 | 0 |
| `Definitions/UProperty` | 80 | 175 | 140 | 27 | 27 | 0 |
| `Definitions/UStruct` | 97 | 499 | 201 | 34 | 3 | 0 |
| `Feature/Access` | 26 | 57 | 26 | 16 | 0 | 0 |
| `Feature/Asset` | 11 | 40 | 30 | 8 | 1 | 0 |
| `Feature/Attach` | 18 | 45 | 37 | 5 | 0 | 0 |
| `Feature/Default` | 34 | 106 | 77 | 16 | 0 | 0 |
| `Feature/DefaultComponent` | 49 | 90 | 76 | 25 | 0 | 0 |
| `Feature/Delegates` | 127 | 1089 | 301 | 29 | 18 | 0 |
| `Feature/Inheritance` | 51 | 327 | 196 | 6 | 0 | 11 |
| `Feature/Mixin` | 29 | 120 | 72 | 11 | 0 | 0 |
| `Feature/PropertyAccess` | 22 | 71 | 41 | 11 | 0 | 0 |
| `Language/Access` | 1 | 4 | 3 | 0 | 0 | 0 |
| `Language/Casting` | 54 | 140 | 62 | 36 | 1 | 0 |
| `Language/Const` | 3 | 3 | 0 | 3 | 3 | 0 |
| `Language/ControlFlow` | 69 | 263 | 91 | 40 | 40 | 0 |
| `Language/Literals` | 73 | 363 | 141 | 25 | 25 | 0 |
| `Language/Namespace` | 15 | 71 | 23 | 7 | 7 | 0 |
| `Language/Operators` | 81 | 210 | 57 | 60 | 60 | 0 |
| `Language/Preprocessor` | 72 | 176 | 107 | 19 | 19 | 0 |
| `Language/Syntax` | 274 | 996 | 475 | 80 | 80 | 36 |

## Applied contract rules

1. CaseId is stable data, separate from the semantic AS name; subcaseId identifies a vector or lifecycle phase.
2. `Observe_*`, `SurfaceNNN`, and `_Nominal` are hard-renamed; `legacySymbol` is evidence only and cannot remain as an alias.
3. Inputs are typed runner values. `Expected*` inputs are removed. Results are raw returns or explicit typed `&out`/`&inout` writebacks; aggregate booleans are split.
4. Put `immediateEnglishKnowledgeComment` immediately above every callable. It states CaseId/subcase, role, fixture/owner, phase, inputs, outputs/side effects, boundary, cleanup, and required-name reason.
5. Engine lifecycle, ProcessEvent, RepNotify, timer, and delegate callbacks are engine/runner dispatched; state readers do not call the callback they claim to test.
6. UObject vectors include nullability, identity, class, Outer/owner, name, flags, world, registration, attachment, and destruction state where applicable. CDO/BP CDO/spawned/existing/fresh are distinct fixtures.
7. Negative compiler/parser files keep diagnostic phase/category/text and recovery. `lineSensitive=true` forbids silent line/newline/directive shifts.

## Critical/high corrections

### Native ProcessEvent

`TS-FEAT-0177` keeps reflection-fixed `OnPickedUp(int CollectorHash)` and removes direct dispatch observers. Its observation API is:

```angelscript
void ReadProcessEventDispatchState(
    ATestInhHealthPickup3 Actor,
    int&out ParentCallCount,
    int&out ChildCallCount,
    int&out ChildCollectorHash)
```

The runner invokes native ProcessEvent with 777 or 0 on fresh actors and then observes `(0,1,777)` or `(0,1,0)`.

### GC/NewObject

Nine GC stories are decomposed into prepare, release, optional request, and later observation calls. No collection proof occurs while an AS local strong reference remains on the same stack. The exact phase declarations, object identity/Outer/class/name/flag outputs, and rooted-object abort cleanup are in each file's `plannedContractAdditions`.

### UClass/CDO/Blueprint inheritance

- Actor/component lifecycle retains engine-fixed callbacks and adds raw state readers after real world dispatch.
- `ReadClassDefaults(...)` distinguishes script CDO, spawned instance, and two-instance isolation.
- `ReadPlainDataDefaults(...)` observes CDO versus fresh UObject without mutating the CDO.
- Component inheritance replaces null-handle pseudo-defaults with exact spawned/CDO component accessors.
- Native UFunction and Blueprint event cases retain reflected names; runner/native dispatch precedes state snapshots.

### Required names and parser negatives

Constructors/destructors, `op*`, `get_*`/`set_*`, reflected UFUNCTIONs, lifecycle/RepNotify callbacks, callable types/events, imports/externals, and FName-bound callbacks remain exact. Generic negative `void Test()` functions are not registry identities and receive file-semantic compile names. The JSON records source line and layout sensitivity for every callable.

## Deterministic disjoint implementation batches

1. Language Syntax EdgeCases Critical GC, then UObject flag/Outer identity.
2. Feature Inheritance ProcessEvent/native/reflected lifecycle, component identity, then CDO/default inheritance.
3. Definitions UClass lifecycle and CDO/instance identity, then remaining UClass.
4. Language Access/Casting/Const/Namespace/non-line-sensitive Literals.
5. Language ControlFlow/Operators with raw operand/result writebacks and protocol-name preservation.
6. Language Preprocessor and line-sensitive Syntax grouped by diagnostic family.
7. Definitions Meta/UEnum/UFunction/UInterface/UProperty/UStruct, negatives before runtime reflection within each leaf.
8. Feature Access/Default/Mixin/PropertyAccess, isolating compiler negatives.
9. Feature Asset/Attach/DefaultComponent/Delegates with exact world identity, real broadcast, unbind and teardown.
10. Full map-to-source reconciliation and strict no-legacy/no-alias audit.

## Validation

| Check | Result |
| --- | --- |
| Files mapped | `1528/1528` |
| Callable mappings | `6248`, missing `0` |
| Forbidden replacement names | `0` |
| Proposed `Expected*` parameters | `0` |
| Missing immediate comments | `0` |
| Duplicate exact proposals | `0` |
| Audit validator | `PASS` |

This is the pre-edit contract map. It does not claim UE execution; implementation still needs narrow runner verification per batch.
