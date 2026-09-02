# Canonical interface publication follow-up rereview — 2026-08-29

> Superseded later on 2026-08-29 by
> `canonical-interface-publication-closure-and-clang-consistency-2026-08-29.md`.
> CTA-IF-09/09A/10/11 now have implementation and RED/GREEN closure; this file
> remains the pre-fix finding record.

## Current verdict

The committed Approach A interface-publication slice is **not yet closed for
merge** after the independent follow-up static audit. The existing source-build
and focused regression evidence remains valid, but it does not exercise three
adversarial states found by inspection:

1. a prepared consumer whose current dependency generation coexists with an
   older published provider generation;
2. two namespace-distinct records with the same simple type name whose Stage 2
   `typeInfo` pointers are swapped; and
3. allocation failure while registering the transient Runtime type authority
   or prepared-global rollback state.

These findings reopen only the prepared Runtime-install transaction slice.
They do not invalidate the sealed exact interface `methodRelations`, Sidecar
V8 transport, lifetime protocol, HIR retirement, or the stable-key plus
generation-local Runtime projection model.

## Blocking finding CTA-IF-09 — dependency-generation transient authority

Severity: **High**.

`asCBytecodeCodeGen::GeneratePreparedModule()` currently populates
`preparedRuntimeTypes` from the current module's own class, enum, typedef and
funcdef inventories. It does not include the candidate module's flattened
`importedModules` dependency closure. `asCModule::ImportModule()` deliberately
flattens transitive imports, and prepared/hot-reload candidate construction
retains that list.

When an old and a current provider generation coexist, a consumer type
relocation that is absent from `preparedRuntimeTypes` falls back to global
Engine module enumeration. Stable identity then either becomes ambiguous or
binds to the wrong generation. A durable stable key is still the correct
identity; the defect is that the generation-local authority view is
incomplete.

Required RED/GREEN closure:

- build a provider/consumer pair;
- retain the old provider while preparing a current provider generation;
- make the consumer import/use the current provider;
- prove the old/current same-key Runtime types coexist;
- require the consumer to bind only through the current imported dependency
  closure;
- require duplicate same-key pointers inside that current closure to fail
  closed rather than select first match;
- preserve retryability and the last-good executable after rejection.

The implementation must build one pointer-deduplicated authority view from the
prepared module plus its exact imported dependency closure. Every append must
be checked; failure must return `asOUT_OF_MEMORY` before Runtime mutation.

## Blocking finding CTA-IF-10 — exact sealed type-to-shell authentication

Severity: **High**.

`PreparePreparedCanonicalObjectBindings()` selects a producer
`sClassDeclaration` through `canonicalASTStableDeclKey`, then trusts that
declaration's `typeInfo` after checking module ownership, simple name and
interface flags. The selected sealed record's exact `record->type` is not
resolved through the current generation authority and compared with that
`typeInfo` pointer.

Two declarations such as `A::Same` and `B::Same` can therefore have their
Stage 2 `typeInfo` pointers swapped while keeping the producer stable keys in
place. Their simple names and class/interface traits still match, so the
current validation can authenticate the wrong shell.

Required RED/GREEN closure:

- source-build namespace-distinct same-name classes or interfaces;
- swap only their prepared `typeInfo` pointers after Stage 2/layout and before
  prepared Canonical publication;
- require rejection before body/source/global/publication mutation;
- restore the pointers and prove the same Builder can retry successfully;
- resolve the sealed `record->type` through the current transient authority and
  require exact `asCTypeInfo*` equality with the prepared shell;
- retain namespace and critical kind/trait checks as explicit diagnostics;
- do not add name fallback, Engine-global first-match selection, or a repair of
  the Stage 2 graph.

## Blocking finding CTA-IF-11 — allocation-safe transaction registration

Severity: **Medium**, merge-blocking because it affects rollback correctness.

`asCArray::PushLast()` can silently return when allocation fails. The current
transient type-view population does not check the resulting length. Prepared
global code also mutates pure-constant flags before the corresponding
`asSPreparedGlobalState` has been reliably registered. If that state append
fails, rollback cannot discover and restore the mutation.

Required RED/GREEN closure:

- reserve or append each transient authority entry with a checked length/capacity
  contract and fail before any Runtime mutation;
- register prepared-global rollback state successfully before publishing
  `isPureConstant` flags;
- add a deterministic failure seam or existing allocator-failure fixture at
  the exact registration boundary;
- prove flags, global storage, initializer ownership, function bodies,
  publisher/digest/snapshot and Runtime bindings remain unchanged;
- restore normal allocation and prove the same Builder can retry.

## Independent Canonical semantic-authority audit

The same rereview also reclassified the remaining native-tree dependency more
precisely. Canonical expression/statement Sema and
`asCBytecodeCodeGen` no longer traverse `asCScriptNode` for body semantics.
The remaining Canonical-reachable semantic replay is concentrated in the UE
staged `asCBuilder` Runtime-shell assembly that runs before the AST is sealed:

- namespace and type shell registration (`RegisterTypesFromScript`,
  `RegisterClass`, `RegisterInterface`, `RegisterEnum`, `RegisterTypedef`,
  `RegisterFuncDef` / `CompleteFuncDef`);
- function ABI, traits, parameters and default arguments
  (`GetParsedFunctionDetails` and its registration callers);
- global and import shells (`RegisterGlobalVar`,
  `RegisterImportedFunction`);
- bases/interfaces, fields, mixin properties and access-specifier Runtime DTOs
  (`DetermineTypeRelations`, `CompileClass`,
  `IncludePropertiesFromMixins`, `RegisterAccessSpecifier`); and
- layout derived from those replay-produced Runtime shells.

The generic maintained-fork `asCModule::Build()` Canonical branch is already
parse → seal → Canonical CodeGen. The UE production lifecycle is different:
parse/typed actions → Builder type/function/layout shell stages → seal
Canonical AST → prepared Canonical CodeGen/authentication → atomic publication.
That lifecycle is why declaration-shell semantic independence remains open
under Tasks 4.3–4.5 and 13.2 even though body CodeGen is AST-first.

The recommended next independent semantic-authority slice after CTA-IF-09/10/11
is the AccessSpecifier Runtime DTO projection. Its typed facts and ordered
permission children are already present before the late seal/layout boundary,
its Runtime ownership is small, and it can be changed without type resolution
or default-argument lifetime work. It must start with a focused AST-first RED
and an exact parse-declaration identity bridge; native-node spelling must not
remain a fallback in the Canonical branch. LEGACY keeps the current native AST
path.

## Progress and verification interpretation

Formal OpenSpec progress remains `101/136` (`74.3%`). No task is checked by this
rereview because the findings belong to already-open umbrella tasks 0.2, 4.3,
4.5, 9.1, 9.5, 13.2 and 13.6.

The latest committed green evidence remains useful as a non-adversarial
baseline:

- Runtime/Editor build: PASS;
- ProductionCodeGen: `135/135`;
- Compiler CanonicalAST: `614/614`;
- Frontend CanonicalAST: `175/175`;
- StaticJIT PrimaryCanonicalASTGenerate: `12/12`;
- Module CanonicalAST Snapshot: `10/10`;
- Hot Reload Canonical snapshot: `12/12`;
- focused interface Sema: `6/6`;
- focused interface Runtime dispatch: `9/9`;
- Cache ASTBodySidecar V8: `23/23`.

Those results must be rerun after all three findings are closed. Until then the
current interface implementation is a strong baseline, not a final merge
candidate, and CANONICAL must remain non-default. Standalone remains deferred
by explicit user direction.
