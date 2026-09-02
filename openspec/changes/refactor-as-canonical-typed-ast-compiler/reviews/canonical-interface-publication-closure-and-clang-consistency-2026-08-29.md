# Canonical interface publication closure and Clang consistency review — 2026-08-29

## Review result

The independent follow-up findings CTA-IF-09, CTA-IF-10 and CTA-IF-11 are now
closed in the reviewed implementation slice. The causal RED for CTA-IF-09 also
exposed and closed an earlier missing semantic-authority layer, recorded here
as CTA-IF-09A: imported script types were not copied into Canonical Sema's
pointer-free registered-type fact set.

Plugin implementation commit: `5f61164`
(`[CanonicalAST] Fix: authenticate prepared Runtime generations`).

The corrected prepared-module route now has four distinct authorities:

```text
Parser / retained native syntax tree
        |
        | typed Parser-to-Sema actions plus copied declaration facts
        v
sealed Canonical AST stable type/declaration identity
        |
        | resolve against this build's exact Runtime generation view
        v
current module + flattened imported-module transient Runtime authority
        |
        | exact shell authentication, relocation, checked transaction
        v
atomic Bytecode / Runtime publication
```

The sealed AST still stores no `asCTypeInfo*`, Engine pointer, numeric TypeId,
FunctionId, virtual slot or interface offset as durable identity. Runtime
pointers are read only while building or consuming the current compilation
generation's transient authority view. Numeric TypeIds remain a late current-
Engine projection.

This closes the interface-publication follow-up blockers. It does **not** close
the whole OpenSpec, make CANONICAL the default, delete AngelScript's native
Parser/`asCScriptNode`/Builder/Compiler, reintroduce HIR, or authorize a
production `dual`/silent-fallback mode. Standalone remains deferred by explicit
user direction.

## How subagents were used

Three read-only subagents were used as bounded reviewers. They did not edit
files, run builds, commit, or own the implementation sequence.

| Reviewer | Static review scope | Result used by the main thread |
| --- | --- | --- |
| `verifier_relation_audit` | Prepared interface/type relation authentication and transaction boundaries | Found the incomplete imported dependency authority, missing exact sealed-type pointer authentication, unchecked transient `PushLast`, and pure-constant mutation before rollback-state registration. These became CTA-IF-09/10/11 RED tests. |
| `clang_lifetime_review` | Remaining native-tree reads and Clang-style ownership/lifetime comparison | Confirmed Canonical expression/statement Sema and Bytecode CodeGen no longer replay native body structure. Remaining Canonical-reachable replay is in late Builder Runtime-shell construction. Recommended the AccessSpecifier Runtime DTO projection as the next bounded slice. |
| `openspec_clang_consistency` | Proposal/design/spec consistency with Clang-inspired lifetime and current implementation | Confirmed the durable layering should remain Sema facts + snapshot-owned protocol + transient derived view + backend-local lowering. Flagged historical HIR/default wording for classification and reinforced that no dump, persisted CFG or renamed HIR may become compiler input. |

The main thread reproduced each actionable issue, rejected fixtures that did
not isolate the claimed cause, implemented the fixes under TDD, ran all
verification and owns both plugin and parent commits.

## CTA-IF-10 — exact sealed type-to-shell authentication

### Original defect

`PreparePreparedCanonicalObjectBindings()` selected a Stage 2
`sClassDeclaration` by stable declaration key, then accepted its `typeInfo`
using module ownership, simple name and class/interface traits. Namespace-
distinct records with the same simple name could therefore have only their
`typeInfo` pointers swapped and still pass those checks.

### Repair

The prepared binding step now:

1. resolves the sealed record's exact `record->type` through the current
   Runtime type bridge;
2. requires that resolved `asCObjectType*` to equal the selected Stage 2
   `typeInfo` pointer;
3. resolves and requires the exact namespace pointer as a separate diagnostic
   guard; and
4. fails before body/global/source/publication mutation on any mismatch.

No name fallback or Stage 2 graph repair was added.

### TDD evidence

- RED build:
  `Saved/Build/cta-if10-namespace-type-shell-red-build/20260829_221955_070_4624c96e/`
- RED group: **135/136**, with only
  `PreparedNamespaceSameNameTypeShellSwapFailsExactAuthentication` failing:
  `Saved/Tests/cta-if10-namespace-type-shell-red-group/20260829_222049_365_cc33caea/`
- GREEN build:
  `Saved/Build/cta-if10-exact-type-shell-green-build/20260829_222205_511_e12d6d9a/`
- focused GREEN: **1/1**:
  `Saved/Tests/cta-if10-exact-type-shell-green/20260829_222217_906_f979dd27/`

The permanent test swaps only `PreparedLeft::Same` and
`PreparedRight::Same`'s `sClassDeclaration::typeInfo` pointers, requires
fail-closed exact authentication, restores them, and proves the same Builder
can retry.

## CTA-IF-09A — imported script types in Canonical Sema facts

### Causal discovery

The first seemingly valid imported-generation fixtures failed earlier than
the Runtime authority boundary. `asCSema::ResolveType()` could resolve lexical
Canonical declarations and copied Engine-registered types, but
`CopyCanonicalRegisteredTypeDeclarations()` enumerated only
`allRegisteredTypes`. Script types owned by imported modules are not in that
Engine registration table.

As a result, an imported script class or enum could be resolved by Stage 2 to
the correct Runtime shell while Canonical Sema independently defaulted the
nominal type to the wrong kind. The sealed stable key looked plausible, but
its semantic kind was not the Parser/Builder result. This was an earlier
semantic-authority bug, not a CodeGen relocation bug.

### Repair

`asCScriptEngine::CopyCanonicalRegisteredTypeDeclarations()` now accepts the
current build module as an optional imported-type authority. It copies the
flattened `importedModules` class, enum, typedef and funcdef inventories through
the same stable fact conversion used for Engine-registered types.

Only pointer-free semantic facts cross into Sema:

- complete stable key;
- Canonical type kind;
- semantic flags; and
- enum values where applicable.

Runtime pointers are inspected only while constructing the fact copy and are
not stored in the AST. Existing deterministic key order and semantic-conflict
ambiguity behavior remain in force. Historical live modules are not candidates
unless the current build imports them.

### Evidence

- full header-triggered build: **164/164 PASS**:
  `Saved/Build/cta-if09-imported-sema-facts-green-build/20260829_224701_681_11cd496f/`
- the cross-layer test then passed its new
  `asAST_TYPE_REFERENCE_OBJECT` and exact-current-shell local resolution
  assertions before reaching the deliberately still-missing CodeGen import
  authority. That separated CTA-IF-09A from CTA-IF-09.

## CTA-IF-09 — exact current dependency-generation transient authority

### Original defect

`GeneratePreparedModule()` built `preparedRuntimeTypes` from only the consumer
module's own class, enum, typedef and funcdef inventories. A type owned by a
current imported provider therefore fell through to Engine-global lookup. If
an older same-key provider generation remained alive behind a Hot Reload or
snapshot lease, global lookup was ambiguous even though the consumer imported
one exact current provider.

### Repair

The prepared transaction now builds one pointer-deduplicated transient view
from:

```text
prepared consumer module
  + every entry in consumer.importedModules
```

`asCModule::ImportModule()` already maintains the flattened dependency list,
so CodeGen does not recursively scan Engine state or infer dependencies by
name. The Runtime bridge receives this transient array for the duration of the
single `GeneratePreparedModule()` call. A same-key old generation that is live
but not imported is not an authority candidate. Duplicate same-key distinct
pointers inside the selected authority still fail closed through the exact
resolver; pointer deduplication only removes the same pointer repeated in the
flattened view.

### Valid RED and GREEN

The final fixture publishes a current `PreparedDependency::Payload`, stages a
distinct older same-nominal shell without republishing it, and imports only the
current provider into the consumer. It proves:

- old and current Runtime pointers coexist and differ;
- Stage 2 uses the current pointer;
- Canonical Sema seals the imported class as a reference-object fact;
- a local binding table containing only the current pointer resolves exactly;
- CodeGen without imported transient authority fails as
  `expected-Runtime='<invalid>'`; and
- adding the exact flattened imports makes publication and execution succeed.

Evidence:

- authority RED: **0/1**, expected invalid Runtime binding:
  `Saved/Tests/cta-if09-imported-sema-facts-green/20260829_225918_844_6e656ca0/`
  (the label reflects the already-green Sema layer; this is the intentional
  CodeGen authority RED);
- GREEN incremental build: **4/4 PASS**:
  `Saved/Build/cta-if09-imported-authority-green-build/20260829_230009_936_b245aba4/`;
- focused GREEN: **1/1 PASS** and entry execution returns `42`:
  `Saved/Tests/cta-if09-imported-authority-green/20260829_230023_429_16b1b557/`.

## Rejected CTA-IF-09 fixtures and what they taught us

The following attempts are recorded because they exposed real boundaries but
did not isolate the claimed imported-generation defect. None was treated as
the causal RED.

| Evidence | Why it was rejected | Durable conclusion |
| --- | --- | --- |
| `Saved/Tests/cta-if09-imported-generation-red/20260829_222505_510_1cf36379/` | Building two complete same-key providers made the second provider itself fail before the consumer existed. | A consumer-generation test must not republish its historical provider over the current one. |
| `Saved/Tests/cta-if09-staged-import-generation-red/20260829_222638_807_12718d27/` | The consumer AST directly referenced a provider snapshot DeclId and correctly failed `DANGLING_ID`. | Snapshot-local DeclIds cannot cross provider/consumer snapshots; imported semantics require stable type/declaration facts, not foreign IDs. |
| `Saved/Tests/cta-if09-imported-handle-red/20260829_223031_196_ad95e2c2/` | Explicit `Payload@` plus `is null` failed in the current Canonical parser subset. | A relocation fixture must not depend on an independently unsupported source form. |
| `Saved/Tests/cta-if09-imported-ref-red/20260829_223154_030_0aa74200/` | `const Payload&in` reached CodeGen but exposed a separate reference-object qualifier/handle normalization mismatch. | Imported reference-form normalization remains a distinct semantic/ABI audit; it cannot prove imported-generation selection. |
| `Saved/Tests/cta-if09-resolve-detail/20260829_223914_081_28bbfd86/` | Imported enum reached a sealed kind mismatch before the intended authority edge. | This was evidence for CTA-IF-09A, not CTA-IF-09. |
| `Saved/Tests/cta-if09-class-value-red/20260829_224034_424_51637a7d/` | Imported by-value class also sealed the wrong kind even with only the current Runtime shell supplied locally. | This confirmed that the missing imported Sema fact was independent from global ambiguity. |
| `Saved/Tests/cta-if09-published-generations-red/20260829_224308_217_740f6f85/` | Removing an old module from one Engine inventory did not remove every availability route. | Tests and production must use positive exact authority, not assume one global container is the complete liveness model. |
| `Saved/Tests/cta-if09-current-published-old-staged-red/20260829_224449_929_29731661/` | The improved current-published/old-staged fixture still failed the local one-pointer bridge due to sealed kind mismatch. | This conclusively identified CTA-IF-09A before the valid authority RED was attempted. |

Two newly exposed but non-blocking follow-ups remain explicitly separate:

1. imported script object reference qualifiers can still exercise a handle/
   reference normalization mismatch; and
2. Engine module inventory removal is not a complete availability/lifetime
   authority model.

Neither is hidden by this closure and neither justifies persisting Runtime
pointers in Canonical AST.

## CTA-IF-11 — allocation-safe transaction registration

### Original defects

`asCArray::PushLast()` returns `void` and silently leaves the length unchanged
on OOM. The prepared transient Runtime type view ignored that result.

The prepared-global path also set `description->property->isPureConstant` and
`description->isPureConstant` before appending its
`asSPreparedGlobalState`. If the state append failed, rollback had no record
from which to restore those already-visible mutations.

### Repair

- Every unique transient type append records the length before `PushLast` and
  requires exactly one new entry afterward. No-growth returns
  `asOUT_OF_MEMORY` before the Runtime bridge or publication sees the view.
- Prepared global state append uses the same length-growth contract.
- A pure-constant state sets its visible flags only **after** its rollback
  record was successfully registered. Later body emission can still observe
  the flags as required by dependency capture; any later failure can now find
  and restore them.
- Test-only deterministic seams simulate the exact no-growth boundaries and
  share the production failure/rollback path. They are compiled only under
  `WITH_ANGELSCRIPT_UNITTESTS`.

### TDD evidence

- compile RED, missing seam APIs as expected:
  `Saved/Build/cta-if11-transaction-oom-red-build/20260829_230220_031_d5b2f962/`;
- GREEN build: **13/13 PASS**:
  `Saved/Build/cta-if11-transaction-oom-green-build/20260829_230332_970_c9e7f616/`;
- transient type OOM/retry: **1/1 PASS**:
  `Saved/Tests/cta-if11-runtime-type-append-green/20260829_230401_903_07bd110f/`;
- global-state OOM, later body failure rollback, and retry: **1/1 PASS**:
  `Saved/Tests/cta-if11-global-state-registration-green/20260829_230433_962_1e36d99b/`.

The assertions cover unchanged function bytecode, global storage and
initializer ownership, pure-constant/compiled flags, current imported module
identity, publisher and retry behavior.

## Broad verification after all repairs

| Gate | Result | Evidence |
| --- | ---: | --- |
| Runtime/Editor build after imported Sema facts | PASS, 164/164 actions | `Saved/Build/cta-if09-imported-sema-facts-green-build/20260829_224701_681_11cd496f/` |
| Runtime/Editor incremental build after imported authority | PASS, 4/4 actions | `Saved/Build/cta-if09-imported-authority-green-build/20260829_230009_936_b245aba4/` |
| Runtime/Editor build after OOM transactions | PASS, 13/13 actions | `Saved/Build/cta-if11-transaction-oom-green-build/20260829_230332_970_c9e7f616/` |
| ProductionCodeGen class | **123/123 PASS** | `Saved/Tests/cta-if09-if10-if11-production-codegen-group/20260829_230523_472_4ad8bc62/` |
| Compiler.CanonicalAST | **616/616 PASS** | `Saved/Tests/cta-if09-if10-if11-compiler-canonicalast/20260829_230608_926_bccaf85c/` |
| Frontend.CanonicalAST | **175/175 PASS** | `Saved/Tests/cta-if09-imported-sema-frontend-canonicalast/20260829_230702_239_58d60d76/` |
| Final current-tree Runtime/Editor build | PASS, 4/4 actions | `Saved/Build/cta-if09-if10-if11-final-verification-build/20260829_231038_548_a27cd768/` |
| Final current-tree Compiler.CanonicalAST | **616/616 PASS** | `Saved/Tests/cta-if09-if10-if11-final-compiler-canonicalast/20260829_231050_967_66ce7b02/` |
| Final current-tree Frontend.CanonicalAST | **175/175 PASS** | `Saved/Tests/cta-if09-if10-if11-final-frontend-canonicalast/20260829_231143_141_9312c8c8/` |
| Plugin `git diff --check` | PASS | No whitespace error; existing LF/CRLF conversion warnings only. |

Standalone was not run and is not claimed.

## Clang comparison after the repairs

### Reference points retained

The current direction matches the useful parts of Clang's architecture:

1. the parser can own short-lived syntax/recovery machinery without becoming
   backend semantic authority;
2. Sema publishes normalized declarations, types, conversions, resolved calls,
   control/lifetime facts and exact relationships into an arena/context-owned
   graph;
3. consumers use stable AST identities while the snapshot is alive rather than
   replaying token spelling or parser nodes; and
4. target/runtime lowering owns ephemeral ABI, slot, offset, frame and code-
   image state outside the source-semantic AST.

CTA-IF-09A is specifically a Clang-style correction: imported declarations
must participate in Sema's semantic environment before the type is sealed.
CTA-IF-09/10 are target-lowering corrections: the sealed identity is rebound
to one exact current Runtime generation and authenticated against the Stage 2
shell rather than made equal to a process-local pointer.

### Project-specific difference that remains

Clang CodeGen generally consumes completed semantic AST declarations. The UE
AngelScript production route still needs Builder Stage 1/2 to materialize
mutable Runtime type/function/global shells before prepared CodeGen can attach
Bytecode and publish them:

```text
parse and typed actions
  -> Builder Runtime shell registration/layout
  -> seal/verify Canonical AST
  -> authenticate exact prepared shells
  -> Canonical Bytecode CodeGen
  -> atomic publication
```

Expression and statement meaning is already Canonical-AST-first. The remaining
native-tree semantic replay is declaration-shell assembly: type registration,
function ABI/defaults, globals/imports, bases/interfaces, fields/mixins/access
DTOs, and layout derived from those shells. This is why Tasks 4.3–4.5 and 13.2
remain open even though the CodeGen body path no longer reads
`asCScriptNode`.

### Boundaries not copied from Clang

- no Clang/LLVM link or Clang AST ABI dependency;
- no persisted Clang CFG analogue in the public snapshot;
- no dump/JSON/DOT text as compiler, Cache or AOT input;
- no Runtime pointer/numeric TypeId as durable AST identity; and
- no independently mutable daScript-style resolved Runtime pointer embedded
  in a public/persisted semantic graph.

The approved lifetime shape remains:

```text
sealed Sema facts and snapshot-owned lifetime protocol
  -> verifier-authenticated transient derived view
  -> backend-local cleanup/EH/slot/frame lowering
```

That derived view must remain deterministic, non-persisted, non-published and
free of independent semantic selection so it cannot become a renamed HIR.

## HIR, dump, native AST and default-pipeline consistency

The active `proposal.md`, `design.md`, delta specs and `tasks.md` are consistent
with the current decision:

- function-owned TypedSemantic HIR is physically removed and remains absent;
- `ASTBodySidecar` is a default-off Cache V2 prototype, not HIR;
- no AST-to-HIR compatibility lowering is allowed;
- AST/AOT consumes the verified Canonical AST directly and does not require a
  semantic dump;
- AngelScript's native Parser/`asCScriptNode`/Builder/Compiler is retained for
  explicit LEGACY, syntax/recovery, differential and reference use;
- CANONICAL must eliminate semantic dependency on that native tree but this
  change does not delete the native implementation; and
- the product default remains LEGACY until the final section 10/12 gates.

Older dated attachments that describe live HIR consumers, incomplete HIR
removal, or a contemporaneous default transition are historical RED/plan
evidence. They must not be read as the current normative state and should not
be rewritten because doing so would corrupt the recorded implementation
history.

## Remaining architecture work and next slice

The next bounded declaration-shell independence slice should be the late
Builder AccessSpecifier Runtime DTO projection, not another body-semantics
rewrite. Parser/Sema already publishes typed access-specifier facts and ordered
permission children; the remaining work is to make the CANONICAL Builder path
consume those exact declarations without replaying native-node spelling.

Acceptance for that slice:

1. add an AST-first RED that mutates or removes only the native access node
   after the canonical action has published its facts;
2. require the CANONICAL Runtime DTO to be unchanged and derived from the exact
   canonical declaration identity;
3. fail closed when that identity is missing, foreign or ambiguous;
4. keep the current native-node path untouched for explicit LEGACY; and
5. rerun focused access, SemaAuthority, ProductionCodeGen and both broad
   CanonicalAST prefixes.

Function signatures/default arguments, bases/interfaces, fields/mixins and
layout follow later because each has a larger Runtime lifetime or ABI surface.

## Progress interpretation

Mechanical OpenSpec progress remains **101/136 = 74.3%**, with **35** open
rows. No checkbox changes in this closure because CTA-IF-09/09A/10/11 are
sub-findings inside already-open umbrella Tasks 0.2, 4.3–4.5, 9.1, 9.5, 13.2
and 13.6.

The implementation is materially safer than the superseded follow-up verdict:
prepared interface/type publication now has exact current-generation identity,
imported semantic facts and allocation-safe rollback. The main remaining
critical path is still declaration-shell semantic independence, remaining
language/lifetime and TypedASTJIT consumer breadth, production entry/default
cutover, and final verification. Therefore this repair does not justify a
default-CANONICAL switch or archive claim by itself.
