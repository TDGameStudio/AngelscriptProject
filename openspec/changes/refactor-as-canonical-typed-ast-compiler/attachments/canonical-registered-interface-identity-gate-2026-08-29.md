# Canonical registered-interface identity gate (CTA-S68)

Date: 2026-08-29

## Scope

This gate advances Tasks 4.3, 4.5 and 13.2 after CTA-S67. It gives an
application-registered or published script interface an explicit declaration
identity before Canonical Sema snapshots the Runtime registry. It also carries
that identity through the maintained module-bytecode Save/Restore lifecycle so
one generation cannot change from interface to class after persistence.

Standalone remains deferred by user direction and is not changed or run. The
product default remains `LEGACY`; the native Parser AST, Builder and Compiler
remain available for syntax/recovery, explicit LEGACY, differential/reference
and rollback use. HIR remains physically absent. No production `dual` or
silent LEGACY fallback is introduced.

## Evidence-backed defect

`asCScriptEngine::CopyCanonicalRegisteredTypeDeclarations()` currently fills
`asSCanonicalRegisteredTypeDeclarationFact::isInterface` from
`asCObjectType::IsInterface()`. In this maintained fork `IsInterface()` is an
unconditional `false`; its former `(asOBJ_SCRIPT_OBJECT && size == 0)` test is
commented out. Consequently every application interface registered through
`RegisterInterface()` and every script interface published by Builder is
projected into a later Canonical translation unit as a class-shaped
`canonical-native-type-view` declaration.

Restoring the size heuristic is not valid. `asCBuilder::LayoutClass()` permits
an empty script class to retain size zero, so layout cannot distinguish an
interface from a valid empty class. Canonical CodeGen currently forces its
published class shell to at least one byte, but LEGACY-published classes and
application object registrations may still be zero-sized. Declaration kind is
a source/registration fact, not a layout inference.

`IsInterface()` also controls the phase-two/phase-three ordering and payload
shape in `asCWriter` / `asCReader`. A Sema-only flag would therefore repair one
live snapshot while losing the identity after Save/Restore. Conversely,
changing `IsInterface()` without changing the stream would reinterpret old
zero-size class bytes as interfaces. The Runtime identity and persistence
boundary must move together.

## Locked authority and persistence boundary

1. `asCObjectType` owns one fork-internal explicit declaration fact,
   `isInterfaceDeclaration`, defaulting to false. It contains no pointer,
   numeric TypeId, layout inference, Parser node or snapshot-local AST ID.
2. Exact interface creation sites set it to true: the application
   `RegisterInterface()` API and `asCBuilder::RegisterInterface()`. Ordinary
   `RegisterObjectType()` and class creation leave it false even when size is
   zero. A system/shadow type copy preserves the source fact.
3. `asCObjectType::IsInterface()` returns only that fact. It does not inspect
   size, flags, methods, behaviours or naming conventions.
4. `CopyCanonicalRegisteredTypeDeclarations()` copies the result by value at
   Sema construction. Canonical base projection continues to consume only the
   translation-unit-local registered-declaration fact and never retains the
   Runtime object pointer.
5. Full module bytecode advances to stream V4. Phase-one type metadata writes
   one validated declaration-kind byte independently of size. The reader sets
   the object fact before shared-type matching and the interface/class phase
   loops. V3 is rejected by the already strict version contract rather than
   guessing whether a zero-size object was an interface or an empty class.
6. The detached function-artifact envelope is independent and is not widened.
   Public `asITypeInfo`, public object flags and numeric TypeId behavior remain
   unchanged.
7. Future Canonical interface Runtime publication must set the same fact; it
   must not introduce a second Canonical-only interface truth. That production
   CodeGen work remains part of Tasks 9.5/13.6 and is not falsely claimed by
   this registered-identity gate.

## AST-first gate card

Owning suite:

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

### `RegisteredInterfaceIdentityIsExplicitNotZeroSizeHeuristic`

The test registers one application interface and one ordinary reference
object whose byte size is exactly zero, then constructs a fresh Canonical Sema
generation. It attaches each registered type as a base to a separate lexical
class and requires the mutable AST, before seal, to contain:

- one `canonical-native-type-view` declaration of kind `INTERFACE` for the
  exact registered interface stable key;
- one distinct `canonical-native-type-view` declaration of kind `CLASS` for
  the zero-size ordinary object stable key;
- exact base edges and stable dependencies from the two lexical classes;
- no Runtime pointer, layout-derived identity or numeric TypeId in the
  asserted facts.

Expected causal RED before production changes: both registered types project
as `CLASS` because `IsInterface()` returns false. A size-heuristic patch would
make both project as `INTERFACE`, so it cannot satisfy the retained gate.

## Lifecycle gate card

Owning suite:

`Angelscript.TestModule.AngelScriptSDK.Module.SaveLoad`

### `RoundTripPreservesExplicitInterfaceAndEmptyClassIdentity`

The LEGACY compatibility source builds one interface, one implementing class
and one unrelated empty class, saves the complete module, discards it, and
restores into the same Engine. Before and after restore it requires:

- the interface Runtime type reports explicit interface identity;
- both classes report class identity, including the empty class;
- the implementation retains the exact interface relationship and method;
- the current stream header advertises V4 and the restored module remains
  independently owned.

Expected causal RED before production changes: the source interface reports
class identity and SaveByteCode cannot use the interface-specific phase.

## Required evidence

- test-only Runtime/Editor build and exact causal RED for both gate methods;
- exact AST-first and lifecycle GREEN;
- complete `CanonicalAST.SemaAuthority`;
- Module SaveLoad/RestorePrimitive and Conformance Interfaces regressions;
- ProductionCodeGen, Module Snapshot and TypedASTJIT cross-surface regression;
- final Runtime/Editor build;
- static scan proving `IsInterface()` reads only the explicit fact and the
  registered Sema fact remains pointer-free;
- strict OpenSpec validation and plugin/parent `git diff --check`;
- plugin commit before the parent gitlink/OpenSpec commit.

## Encountered risks and non-claims

- Full module stream V4 intentionally rejects V1-V3. The maintained reader is
  already exact-version-only, and V3 has no unambiguous interface/zero-size
  class declaration bit. This is fail-closed compatibility, not a migrator.
- This gate repairs exact Runtime interface identity for current application,
  Builder and module-restore producers. It does not make Canonical CodeGen
  publish lexical interface declarations; that backend still requires its own
  AST-first type/method/inheritance transaction gate.
- The maintained lexer intentionally does not tokenize raw `@` handle syntax.
  Existing parser coverage locks that behavior, so this slice does not claim a
  source-level interface-handle dispatch test. Interface identity, implemented
  relationship, method lookup and persistence are covered; executable handle
  dispatch remains a separate syntax/runtime-compatibility closure.
- This gate does not close all interface inheritance diagnostics, native
  methods, complete expression/statement authority, default cutover, or Tasks
  4.3, 4.5 and 13.2 as whole-task requirements.
- It does not remove the native AngelScript AST, Builder or Compiler.

## Evidence log

### Causal RED

- Test-only Runtime/Editor build passed with `5` actions and exit code `0`:
  `Saved/Build/cta-s68-interface-identity-red-build/20260829_151828_584_80d645c6`.
- Exact AST-first gate discovery found exactly `1` test and failed `0/1` as
  required before production changes:
  `Saved/Tests/cta-s68-interface-sema-causal-red/20260829_151851_660_32758814`.
  The registered interface projected as `CLASS`, proving the copied registry
  fact was false rather than an AST lookup/order issue.
- Exact lifecycle gate discovery found exactly `1` test and crashed during
  source Build before persistence:
  `Saved/Tests/cta-s68-interface-restore-causal-red/20260829_151926_641_db398774`.
  The access violation wrote through a null virtual-table slot at
  `asCBuilder::LayoutClass()` (`as_builder.cpp:4914`), reached from
  `BuildLayoutClasses()` and `asCModule::Build()`. Because `IsInterface()` was
  false, Builder routed the interface through class layout. This is causal
  evidence that the explicit fact must be owned by the Runtime object and set
  by Builder, not patched only in Canonical Sema.
- The first post-identity GREEN attempt reproduced the same crash after a
  successful `167`-action build:
  `Saved/Tests/cta-s68-interface-restore-green/20260829_152613_958_82c8a8c9`.
  Backward tracing showed the remaining source: `DetermineTypeRelations()`
  had no interface branch and placed every script-object base in
  `derivedFrom`, so `LayoutClass()` indexed the interface method's
  `vfTableIdx` into an empty class virtual table. The official AngelScript
  control flow separates class inheritance from interface implementation by
  object size; this fork cannot reuse that heuristic because valid empty
  classes may also reach size zero. The maintained repair therefore routes
  only explicit `IsInterface()` identity through `AddInterfaceToClass()`.
- After relation routing was repaired, the lifecycle gate reached SaveByteCode
  and exposed a second access violation in the writer because the maintained
  split `CompileClass()` / `LayoutClass()` path never constructed the interface
  vtable chunks required by `interfaceVFTOffsets`. Evidence:
  `Saved/Tests/cta-s68-interface-relation-hypothesis/20260829_153044_938_a0368994`.
  The [official AngelScript `as_builder.cpp`](https://raw.githubusercontent.com/anjo76/angelscript/master/sdk/angelscript/source/as_builder.cpp)
  was used only as an architecture reference: it explicitly separates
  interface relations and materializes per-interface virtual-table chunks.
  The maintained implementation mirrors those invariants at its own final
  `LayoutClass()` boundary and continues to use explicit identity rather than
  importing the upstream size heuristic.
- The next exact lifecycle run restored the module but failed post-load method
  lookup because the reader rebuilt `asCObjectType::methods` without rebuilding
  its maintained name-indexed `methodTable`. Evidence:
  `Saved/Tests/cta-s68-interface-vft-chunk-green-rerun/20260829_153625_030_8189a077`.
  The reader now restores both views; this is required for interface and class
  declarations generally, not a test-only workaround.
- Attempts to extend the lifecycle gate to execute a source-level `I@` handle
  dispatch were rejected by the maintained parser. Raw `@` failed in local and
  parameter forms, while removing it produced the correct by-value reference
  diagnostic. Evidence:
  `Saved/Tests/cta-s68-interface-dispatch-diagnostic/20260829_154031_541_33f93ca7`,
  `Saved/Tests/cta-s68-interface-param-dispatch-exact/20260829_154213_039_48cb7f49`,
  and
  `Saved/Tests/cta-s68-interface-implicit-ref-dispatch-exact/20260829_154309_340_a2aaaedd`.
  Existing `Frontend.Parser.Declarations` coverage already records raw `@` as
  intentionally disabled, so CTA-S68 retains identity/persistence coverage and
  records executable handle dispatch as a non-claim instead of broadening the
  task into a tokenizer migration.

### GREEN and regression evidence

- Exact AST-first GREEN passed `1/1`:
  `Saved/Tests/cta-s68-interface-sema-green/20260829_152535_005_06d407b4`.
- Exact final lifecycle GREEN passed `1/1` after relationship, vtable-chunk and
  method-table restoration fixes:
  `Saved/Tests/cta-s68-interface-final-exact-green/20260829_154437_075_94e09ca0`.
- The final gate build before the broad matrix passed `4` actions:
  `Saved/Build/cta-s68-interface-final-gate-build/20260829_154422_122_21f7f580`.
- The required nine-prefix regression matrix passed `667/667`, with `0`
  failures and `0` skips:
  `Saved/Tests/cta-s68-interface-regression-matrix/20260829_154549_455_4f046ab2`.
  It covers Canonical SemaAuthority, Module SaveLoad/RestorePrimitives,
  Conformance Interfaces, Parser Declarations, Canonical Type,
  ProductionCodeGen, Module CanonicalAST Snapshot and TypedASTJIT.
- Final Runtime/Editor UBT validation succeeded with the target up to date and
  exit code `0`:
  `Saved/Build/cta-s68-interface-final-build/20260829_155033_207_44ad16f5`.
  The earlier production build compiled `167` actions, while the final gate
  build compiled the last `4` changed actions; this final invocation confirms
  the resulting target graph is current.
- Static scans prove `asCObjectType::IsInterface()` returns only
  `isInterfaceDeclaration`; exact true producers are application registration,
  Builder registration, system-type copy and validated V4 restore. The copied
  `asSCanonicalRegisteredTypeDeclarationFact` owns only stable strings, enum/
  flag values, booleans and copied enumerator arrays—no Runtime pointer, Parser
  node or numeric TypeId.
- `openspec validate refactor-as-canonical-typed-ast-compiler --strict` passed.
- Parent and plugin `git diff --check` passed. Line-ending conversion warnings
  are repository working-tree policy messages rather than whitespace errors.
- Plugin implementation commit:
  `36dd4e7 [CanonicalAST] Refactor: preserve explicit interface identity`.

## Accounting

CTA-S68 is a bounded slice of Tasks 4.3, 4.5 and 13.2. The formal task ledger
stays `101/136 = 74.3%` until a whole task requirement is proven and checked.
