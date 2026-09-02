# CTA-S83 exact Canonical global-dependency relation gate — 2026-08-30

## Status

This non-Standalone slice closes the reviewed Runtime name reconstruction for
folded/global semantic dependencies consumed by TypedASTJIT.

The machine relation is now:

```text
sealed global VarDecl.stableKey
    == asCGlobalProperty::canonicalASTStableDeclKey
    == FAngelscriptStaticJITGenerationGlobal::CanonicalASTDeclKey
    == FAngelscriptStaticJITGenerationSemanticDependency::CanonicalASTDeclKey
    == FAngelscriptStaticJITCompiledGlobalView::CanonicalASTDeclKey
    == FAngelscriptStaticJITSemanticDependencyView::CanonicalASTDeclKey
    == FAngelscriptTypedASTJITGlobalDependency::CanonicalASTDeclKey
```

Runtime namespace/name spelling is structural authentication and diagnostic
material only. It is no longer used by TypedASTJIT to rediscover the sealed
declaration. Engine-local global-property ID, stable artifact reference and
content/ABI hashes remain separate coordinates with separate responsibilities.

Formal OpenSpec progress remains **102/136 = 75.0%** because 7.2, 7.4 and 7.5
are umbrella tasks with other call, argument, global/import, receiver and
lifetime families still open. The product default remains LEGACY. The original
native AngelScript parser AST remains available. HIR remains physically absent.
Standalone was neither changed nor run.

## Problem

Canonical Sema had already sealed the exact global `VarDecl`, and Cache/generation
already carried a stable global artifact reference plus a current-Engine numeric
property ID. TypedASTJIT nevertheless rebuilt the Canonical declaration key from
the live Runtime property namespace and name:

```text
live Runtime namespace + "::" + live Runtime property name
    -> guessed Canonical global declaration key
```

That mixed four different identity domains:

- the immutable Canonical declaration selected during this source compile;
- the artifact-stable global reference used for dependency matching;
- the dynamically assigned current-Engine global-property ID used for execution;
- human-readable Runtime spelling.

The numeric ID cannot be a durable relation because it is assigned per Engine
generation. The display name cannot be the relation because it may change or
collide independently of the Sema-selected declaration. Stable artifact hashes
prove provider dependency compatibility, but they do not by themselves identify
the exact declaration node inside the leased sealed AST. A producer-carried
Canonical key was therefore required across the Runtime and generation
boundaries.

## Frozen contract

### Canonical producer authority

Canonical global Sema/CodeGen publishes the exact non-empty `VarDecl.stableKey`
onto the current `asCGlobalProperty` shell. An existing different key is a
conflict; it is never overwritten by a name lookup.

The property key is deliberately nonserialized current-generation state. Cache
or detached artifacts retain their own stable references and ABI/content hashes;
they do not persist a Runtime pointer or numeric property ID as identity.

### Runtime structural authentication

`asCRuntimeTypeBridge::BindGlobalDeclaration()` accepts the producer relation
only when all of the following are true:

- the Canonical Context is publishable and belongs to the same current Engine;
- the Runtime property belongs to the same current module and occupies the
  claimed current-Engine global-property slot;
- the producer key is non-empty and resolves to exactly one Canonical `VAR` Decl;
- the declaration belongs to the expected translation unit and namespace;
- exact name, namespace and type structure agree with the Runtime property.

The bridge uses Runtime spelling to authenticate the producer relation once. It
does not synthesize a key from that spelling and does not perform short-name
fallback.

### Generation snapshot and graph views

Verified Canonical generation capture fails closed if a current script global
cannot be bound to its exact sealed declaration. The authenticated key is copied
to the generation-global row and then to every matching semantic-dependency row.
BytecodeJIT, test graph construction and call-closure copies preserve the key in
their immutable task-local views.

This is generation-task metadata, not a public persistent Provider ABI change.
`FStringView` graph fields view snapshot-owned strings during the generation
task; no AST or Runtime pointer is persisted into a Provider artifact.

### TypedASTJIT consumption

TypedASTJIT copies `CanonicalASTDeclKey` directly from the frozen semantic
dependency. Folded-global analysis and emission select exactly one dependency
whose key equals the referenced sealed `VarDecl.stableKey`, then authenticate
the selected row's current property ID, dependency kind, stable artifact
reference, expected ABI and expected value/content hash.

The old live `namespace::name` reconstruction has been deleted. Changing only
the Runtime property's diagnostic name after graph capture cannot redirect or
invalidate a correct dependency relation.

## Dynamic identity separation

| Coordinate | Lifetime and purpose | Not allowed to do |
| --- | --- | --- |
| `CanonicalASTDeclKey` | Same-compilation sealed-declaration relation | act as a persisted Runtime slot or public TypeId |
| `Reference.StableKey` / `GlobalKey.Hash` | Artifact/provider stable global identity | select a sealed Decl without the exact Canonical relation |
| `EngineLocalGlobalPropertyId` | Current Engine generation execution slot | survive/reidentify another Engine generation |
| `ExpectedAbi` | Dependency ABI compatibility | replace declaration or execution-slot identity |
| `ExpectedContentOrValue` | Folded-value/content compatibility | replace declaration, ABI or slot identity |
| Runtime namespace/name | Structural authentication and diagnostics | reconstruct executable identity in a later consumer |

This separation is the same answer used for dynamic AngelScript TypeId: durable
identity is stable and pointer-free; current numeric coordinates are resolved
inside one generation and never promoted to cross-generation identity.

## Fail-closed matrix

| Condition | Result |
| --- | --- |
| Producer property has no Canonical key | verified generation capture rejects the binding |
| Producer property carries a conflicting key | producer/bridge conflict; no silent overwrite |
| Key resolves to no global Decl or multiple Decls | Runtime bridge rejects binding |
| Key matches but module/TU/namespace/name/type structure differs | Runtime bridge rejects binding |
| Graph semantic dependency omits the key | per-function `SemanticDependencyMismatch`; no native emission |
| Graph semantic dependency carries a wrong unique key | per-function `SemanticDependencyMismatch`; no spelling fallback |
| Two rows claim the exact same Canonical global key | per-function `SemanticDependencyMismatch`; no ambiguous selection |
| Current property ID is missing, negative or non-unique | folded-global dependency validation rejects the row |
| Stable reference, kind, expected ABI or expected value/content is invalid | folded-global dependency validation rejects the row |
| Only the live Runtime diagnostic name changes after capture | exact key route remains eligible and emits the expected constant |

## RED and diagnostic evidence

The production test was expanded before the relation fields existed. The RED
build failed on the intended missing producer/snapshot/view members:

- `FAngelscriptStaticJITGenerationGlobal::CanonicalASTDeclKey`;
- `asCGlobalProperty::canonicalASTStableDeclKey`;
- `FAngelscriptStaticJITGenerationSemanticDependency::CanonicalASTDeclKey`;
- `FAngelscriptStaticJITSemanticDependencyView::CanonicalASTDeclKey`.

Evidence:

- RED build:
  `Saved/Build/cta-s83-global-decl-relation-red-build/20260830_091649_830_67c8caa8`.

After producer publication, Runtime binding, snapshot propagation and consumer
replacement were implemented, the production build passed all **172/172**
actions and the exact correct-path test passed **1/1**:

- producer build:
  `Saved/Build/cta-s83-global-decl-relation-producer-build/20260830_091828_702_74b6ee34`;
- correct producer/consumer path:
  `Saved/Tests/cta-s83-global-decl-relation-producer-green/20260830_092131_592_5f2d1950`.

The first wrong/missing/duplicate-key run exposed a test-fixture defect before
backend execution: the duplicate fixture called `TArray::Add()` with a reference
to an element in that same potentially reallocating array. UE correctly asserted
that the source element could be invalidated. This was not a compiler failure.
The fixture now copies the row to an independent local value before insertion.

- negative-matrix build before fixture correction:
  `Saved/Build/cta-s83-global-decl-relation-negative-build/20260830_092418_635_1f126ce2`;
- fixture assertion run, retained as diagnostic evidence only:
  `Saved/Tests/cta-s83-global-decl-relation-negative-green/20260830_092437_947_cb39e93c`;
- corrected fixture build:
  `Saved/Build/cta-s83-global-decl-relation-negative-fixture-fix-build/20260830_092521_527_9c6aec5a`;
- correct path plus wrong/missing/duplicate fail-closed matrix:
  **1/1 PASS** —
  `Saved/Tests/cta-s83-global-decl-relation-negative-green-2/20260830_092543_628_9dec8a9a`.

The single CQTest method intentionally exercises all four relation cases so it
reuses one expensive generation fixture while still producing independent
backend instances for every malformed graph.

## Resolution map

| Boundary | Implementation |
| --- | --- |
| Runtime property carrier | `ThirdParty/angelscript/source/as_property.h` |
| Producer publication | `ThirdParty/angelscript/source/as_builder.cpp`, `as_bytecode_codegen.cpp` |
| Structural authentication | `ThirdParty/angelscript/source/as_runtime_type_bridge.{h,cpp}` |
| Snapshot/global/dependency capture | `StaticJIT/AngelscriptStaticJITGenerationSnapshot.{h,cpp}` |
| Backend-neutral immutable graph | `StaticJIT/Backends/AngelscriptStaticJITBackend.h` |
| BytecodeJIT graph copy | `StaticJIT/BytecodeJIT/AngelscriptBytecodeJIT.cpp` |
| TypedASTJIT direct consumption | `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITBackend.cpp` |
| Closure propagation | `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITCallClosure.cpp` |
| Production and malformed-graph gate | `AngelscriptTest/StaticJIT/AngelscriptStaticJITGenerationEngineTests.cpp` |

## Verification evidence

| Gate | Result |
| --- | --- |
| RED relation-field build | expected compile failure — `Saved/Build/cta-s83-global-decl-relation-red-build/20260830_091649_830_67c8caa8` |
| Producer implementation build | PASS, **172/172 actions** — `Saved/Build/cta-s83-global-decl-relation-producer-build/20260830_091828_702_74b6ee34` |
| Exact correct path | **1/1 PASS** — `Saved/Tests/cta-s83-global-decl-relation-producer-green/20260830_092131_592_5f2d1950` |
| Final malformed-graph fixture build | PASS — `Saved/Build/cta-s83-global-decl-relation-negative-fixture-fix-build/20260830_092521_527_9c6aec5a` |
| Correct + wrong/missing/duplicate relation matrix | **1/1 PASS** — `Saved/Tests/cta-s83-global-decl-relation-negative-green-2/20260830_092543_628_9dec8a9a` |
| Complete ProjectGeneration Engine class | **37/37 PASS** — `Saved/Tests/cta-s83-projectgeneration-engine-full-green/20260830_092621_857_a530ab69` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **703/703 PASS**, zero failures/skips — `Saved/Tests/cta-s83-compiler-typedjit-nativebridge-full-green/20260830_092944_210_9a7ba323` |

## Remaining work and non-claims

CTA-S83 closes the known folded-global name reconstruction. It does not close
7.2, 7.4 or 7.5:

- TypedASTJIT call emission still reconstructs formal argument placement from
  reverse child position instead of consuming verifier-authenticated
  `Expr.callArguments[].formalIndex`; same-typed reordered formals can therefore
  be silently swapped. CTA-S84 is the next required exact-relation gate.
- Typed root entry binding still associates the nth `DECL_PARAM` child with the
  nth Runtime slot. A future explicit sealed formal-ordinal relation is required
  before same-typed parameter-child reordering can be considered harmless.
- mutable globals and import slots still require lifecycle routes or explicit
  fallback; this slice proves the currently supported folded hard-value global
  route only;
- receiver lowering and import/mixin/property/constructor/delegate/lambda and
  cross-TU families remain incomplete or explicit fallback;
- native object-frame cleanup and other provider dependency families remain
  open behind typed per-function fallback;
- no dump, HIR adapter, declaration-name lookup, public Provider ABI revision or
  Standalone branch was added.

This slice does not switch the default to CANONICAL, run the final All suite,
archive the change, remove explicit LEGACY, or authorize removal of the
original native AngelScript parser AST.
