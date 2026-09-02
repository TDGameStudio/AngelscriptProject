# CTA-S82 exact Canonical native-target relation gate — 2026-08-30

## Status

This non-Standalone slice closes the reviewed declaration-string identity
reconstruction between Canonical Sema, the frozen StaticJIT generation
snapshot and TypedASTJIT call-closure planning.

The machine relation is now:

```text
resolved Canonical call Decl.stableKey
    == producer-published asCScriptFunction::canonicalASTStableDeclKey
    == frozen FAngelscriptStaticJITNativeCallTarget::CanonicalTargetDeclKey
```

`CanonicalDeclaration` and Canonical `origin` remain human-readable diagnostic
material only. Engine-local FunctionId remains a current-generation execution
coordinate only. Neither spelling nor the numeric FunctionId is a durable
identity.

Formal OpenSpec progress remains **102/136 = 75.0%** because 7.2, 7.4 and 7.5
are umbrella tasks with other call, dependency, receiver and lifetime families
still open. The product default remains LEGACY. The original native
AngelScript parser AST remains available. HIR remains physically absent.
Standalone was neither changed nor run.

## Problem

Canonical Sema already resolved a call expression to one exact Canonical Decl,
but the native target relation was discarded at the Runtime boundary.
Generation capture later scanned system functions and compared
`GetDeclaration()` plus owner/name/namespace text against the Canonical
declaration's `origin`. TypedASTJIT closure repeated the second half of the
same reconstruction:

```cpp
Candidate.CanonicalDeclaration == Target->origin
```

That made a presentation string part of executable identity. Formatting,
qualification, typedef/alias rendering or declaration-printer changes could
make one real function look different. Conversely, two candidates with the
same spelling could appear equivalent even though only one was the
Sema-resolved declaration. The Engine-local FunctionId could not repair this
because it is assigned dynamically and is valid only in the current Engine
generation.

The defect was therefore not missing native metadata. It was a broken exact
relation across three ownership boundaries:

```text
Canonical producer -> current Runtime system function -> frozen generation row
```

## Frozen contract

### Producer authority

Canonical Sema is the only producer allowed to associate a projected native
function declaration with a current `asCScriptFunction`. After the exact
declaration is finished, it publishes that declaration's non-empty stable key
to `canonicalASTStableDeclKey`.

An existing conflicting key is a Sema error. A generic template-base method is
not falsely stamped as a concrete instance: method publication occurs only
when the selected Runtime method belongs to the exact projected object type.

### Runtime authentication

`asCRuntimeTypeBridge::BindSystemFunctionDeclaration()` accepts a producer key
only when all of the following are true:

- the Context is publishable and belongs to the same current Engine;
- the Runtime function is an `asFUNC_SYSTEM` function with no script Module;
- the producer-carried key resolves to exactly one function-like Canonical
  declaration;
- owner, namespace, return type, parameter types, passing modes and const
  qualification structurally match the Canonical declaration;
- the declaration is an external native projection rather than an authored
  script body.

The bridge returns a precise failure category. It never falls back to a short
name or declaration spelling.

### Frozen snapshot and closure consumption

`FAngelscriptStaticJITNativeCallTarget` now carries
`CanonicalTargetDeclKey`. Snapshot capture scans only current-Engine system
functions whose producer key exactly equals the resolved call target key, then
authenticates the candidate through the Runtime bridge. Zero or multiple exact
matches publish no native target row.

Closure input requires every native row to have one non-empty unique
`CanonicalTargetDeclKey`. Canonical calls then look up only
`Target->stableKey`; no declaration/owner spelling recovery exists. The
frozen Runtime FunctionId is copied to the call plan only after the exact
stable relation selects the row.

### Diagnostic-only strings

`CanonicalDeclaration`, `origin` and registered display names remain useful in
errors, reports and generated comments. They may be empty or reformatted
without changing target selection. They are not equality keys and cannot
rescue a missing or wrong stable key.

## Fail-closed matrix

| Condition | Result |
| --- | --- |
| Sema selects an invalid/foreign/non-system Runtime function | no producer relation; Sema diagnostic |
| Runtime function already carries a different Canonical key | producer conflict; no silent overwrite |
| Key resolves to no declaration or multiple declarations | Runtime bridge rejects binding |
| Key matches but owner/namespace/return/parameter/passing/const structure differs | Runtime bridge rejects binding |
| Snapshot sees zero exact authenticated system functions | no native target row |
| Snapshot sees more than one exact authenticated system function | ambiguous; no native target row |
| Closure native row has no key | malformed input: `TypedASTJITCallGraphInvalidNativeCallTarget` |
| Two closure rows claim one key | malformed input: `TypedASTJITCallGraphDuplicateNativeCanonicalTarget` |
| Closure row contains a wrong but unique key | no exact native route; typed `UnsupportedCall` fallback |
| Only `CanonicalDeclaration` spelling changes | exact stable-key route remains eligible |

## RED evidence

The first two behavior tests were introduced before the producer/consumer
implementation:

1. `NativeCallProjectionPublishesExactCanonicalTargetIdentity` requires the
   resolved call Decl, frozen native row and selected Runtime system function
   to carry one exact key.
2. `NativeCallClosureIgnoresDiagnosticDeclarationSpelling` mutates only the
   human-readable declaration and requires closure eligibility to remain
   unchanged.

The RED build passed and the pair was **0/2** for the intended reasons:

- build:
  `Saved/Build/cta-s82-native-target-stable-relation-red-build/20260830_084415_435_337a06fb`;
- RED pair:
  `Saved/Tests/cta-s82-native-target-stable-relation-red/20260830_084436_960_f1cdfe94`.

After producer publication, Runtime authentication and snapshot capture were
implemented, the staged pair was intentionally **1/2**: producer identity was
green while closure still depended on declaration spelling:

- producer build:
  `Saved/Build/cta-s82-native-target-producer-green-build/20260830_084852_859_3a876390`;
- producer-green/consumer-red pair:
  `Saved/Tests/cta-s82-native-target-producer-green-consumer-red/20260830_085225_446_9d9802ff`.

`NativeCallClosureRejectsWrongCanonicalTargetKey` then preserved the correct
diagnostic declaration while corrupting only the stable key. The old closure
incorrectly remained eligible, producing the expected **0/1 RED**:

- RED test build:
  `Saved/Build/cta-s82-wrong-key-red-build/20260830_085509_044_8a49adf9`;
- wrong-key RED:
  `Saved/Tests/cta-s82-wrong-key-red/20260830_085527_284_6f076e95`.

That sequence proves the change is an identity-semantic replacement, not an
unused metadata-field addition.

## Resolution

### Canonical Sema producer

`as_sema_expr.cpp` now publishes exact native global/method declaration
identity after `FinishDecl()`. Existing native projections are selected with
complete return/parameter type and qualifier checks before publication.

### Runtime type bridge

`as_runtime_type_bridge.{h,cpp}` now exposes the system-function binding route
and shares the structural matcher with script-function binding while retaining
the two different Runtime ownership/ABI rules. System functions require direct
Canonical parameter ABI; script functions retain their existing normalized
script ABI handling.

### Generation snapshot

`AngelscriptStaticJITGenerationSnapshot.cpp` no longer scans declaration text
or calls an owner-spelling disambiguator for native call targets. It consumes
the resolved Canonical stable key, requires exact producer-key equality,
authenticates through the bridge and freezes the same key beside the
generation-local FunctionId.

### TypedASTJIT closure

`AngelscriptTypedASTJITCallClosure.cpp` validates a unique native-target key
index and resolves a Canonical call through `Target->stableKey` only. `origin`
is retained solely in `CanonicalTargetRouteUnavailable` diagnostics. A valid
key can no longer be invalidated by display spelling, and display spelling can
no longer rescue an invalid key.

The final invalid-input test also directly verifies missing and duplicate key
rejection in addition to wrong-key route fallback.

## Verification evidence

| Gate | Result |
| --- | --- |
| Initial RED build | PASS — `Saved/Build/cta-s82-native-target-stable-relation-red-build/20260830_084415_435_337a06fb` |
| Initial producer/string pair | **0/2 expected failures** — `Saved/Tests/cta-s82-native-target-stable-relation-red/20260830_084436_960_f1cdfe94` |
| Producer implementation build | PASS, **172/172 actions** — `Saved/Build/cta-s82-native-target-producer-green-build/20260830_084852_859_3a876390` |
| Producer-green/consumer-red pair | **1/2 expected staged result** — `Saved/Tests/cta-s82-native-target-producer-green-consumer-red/20260830_085225_446_9d9802ff` |
| Wrong-key RED build | PASS — `Saved/Build/cta-s82-wrong-key-red-build/20260830_085509_044_8a49adf9` |
| Wrong-key RED | **0/1 expected failure** — `Saved/Tests/cta-s82-wrong-key-red/20260830_085527_284_6f076e95` |
| Final relation build | PASS — `Saved/Build/cta-s82-native-target-stable-relation-green-build/20260830_085738_186_60b939e5` |
| Exact producer/string/wrong-key GREEN | **3/3 PASS** — `Saved/Tests/cta-s82-native-target-stable-relation-green/20260830_085755_887_ed533e7a` |
| Complete ProjectGeneration Engine class | **37/37 PASS** — `Saved/Tests/cta-s82-projectgeneration-engine-full-green/20260830_085837_795_bf902d14` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **703/703 PASS**, zero failures/skips — `Saved/Tests/cta-s82-compiler-typedjit-nativebridge-full-green/20260830_090200_384_a2a0be62` |
| Missing/duplicate-input incremental build | PASS — `Saved/Build/cta-s82-native-target-invalid-inputs-build/20260830_090435_651_2db7f43c` |
| Wrong/missing/duplicate input contract | **1/1 PASS** — `Saved/Tests/cta-s82-native-target-invalid-inputs-green/20260830_090454_055_e7d25cb9` |

The broad **703/703** rerun is the current aggregate regression evidence for
this slice. The later one-test invalid-input refinement changed only test code,
so it does not invalidate that production-code matrix.

## Remaining work and non-claims

CTA-S82 closes the known declaration-string native-target relation. It does
not close 7.2, 7.4 or 7.5:

- complete receiver evaluation/ABI lowering remains optional coverage behind
  the existing safe `UnsupportedReceiver` fallback;
- import, mixin, property, constructor, delegate/funcdef/lambda and cross-TU
  call/dependency families remain incomplete or explicit fallback;
- native object-frame cleanup, mutable-global/import lifecycle and remaining
  provider dependency families are not claimed;
- Engine-local FunctionId and public TypeId remain dynamic current-generation
  coordinates; replacing those public APIs is a later dedicated OpenSpec;
- no dump, HIR adapter, bytecode body analysis or Standalone branch was added.

This slice does not switch the default to CANONICAL, run the final All suite,
archive the change, remove explicit LEGACY, or authorize removal of the
original native AngelScript parser AST.
