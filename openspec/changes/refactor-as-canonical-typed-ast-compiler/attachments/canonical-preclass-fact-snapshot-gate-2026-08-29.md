# Canonical PreClass fact snapshot gate (CTA-S67)

Date: 2026-08-29

## Scope

This gate advances Tasks 4.3 and 13.2 after CTA-S66. It removes the final two
`PreClassData::ShadowType` reads from Canonical declaration/layout Sema:

1. projecting the native/embedding base erased from preprocessed Parser text;
2. selecting the minimum alignment for the script class layout.

Standalone remains deferred by user direction and is not changed or run. The
product default remains `LEGACY`; the native Parser AST, Builder and Compiler
remain available for syntax/recovery, explicit LEGACY, differential/reference
and rollback use. HIR remains physically absent. No production `dual` or
silent LEGACY fallback is introduced.

## Evidence-backed defect

`asCModule::PrepareCanonicalBuildCandidate()` copies `PreClassData` by value,
but that value still contains a live `asITypeInfo* ShadowType`. Canonical Sema
currently dereferences it in `as_sema_decl.cpp` to obtain the type name, flags,
Canonical type projection and alignment. Candidate ownership therefore does
not make those semantic inputs immutable: a Runtime type revision or late
mutation can change the meaning/layout observed by a Sema generation.

The final AST contains no pointer, but deriving its base edge and layout from a
live pointer during Sema violates the translation-unit-local authority and
generation isolation already used for registered declarations, enum literals
and template facts.

## Locked authority boundary

1. Public `asPreClassData` and its ABI remain unchanged. Its `ShadowType`
   pointer stays available to the explicit LEGACY/Builder registration shell
   and Canonical CodeGen's Runtime install/ABI validation boundary.
2. `asCModule::AddPreClassData()` additionally captures one fork-internal,
   pointer-free fact keyed by the exact script class name. It owns only:
   `PropertyOffset`, the complete namespace-qualified shadow type stable key,
   the exact alignment at registration, and whether a shadow type was present.
3. `PrepareCanonicalBuildCandidate()` copies those immutable facts together
   with the Runtime shell. Canonical Sema reads only the fact copy; it never
   reads `asPreClassData`, `asITypeInfo`, Runtime numeric TypeId or user data.
4. Native erased-base projection resolves the captured complete stable key
   through Sema's translation-unit-local registered-declaration snapshot. A
   missing, wrong-kind or ambiguous key fails closed with a deterministic Sema
   diagnostic; it never queries the live Engine or falls back to LEGACY.
5. Class layout uses the captured property prefix and alignment. Offset
   overflow remains a Sema error. The sealed class owns the resulting prefix,
   extent and alignment.
6. Canonical CodeGen continues to validate the sealed layout against the
   current Runtime `PreClassData` before installation and only then attaches
   `shadowType`/user data. The immutable Sema fact is not a Runtime pointer
   binding and does not bypass the generation-local binding/install contract.

## AST-first gate card

Owning suite:

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

### `PreClassFactsAreCapturedBeforeMutableRuntimeShellChanges`

The test registers two distinct native host types, assigns the first type and
its alignment through `AddPreClassData`, then deliberately perturbs the
module's retained Runtime shell to point at the second type with a different
alignment before direct Parser/Sema execution. It does not run CodeGen. It
requires the mutable AST to contain, before sealing:

- a `canonical-native-type-view` declaration for the first captured complete
  stable key;
- no native base edge to the later Runtime shell type;
- the derived class base edge targeting the captured native declaration;
- the captured alignment rather than the later live alignment;
- no Runtime pointer or numeric TypeId in the asserted type/base identity.

Expected causal RED before production changes: current Sema follows the
perturbed `PreClassData::ShadowType`, projects the second native type and seals
the later alignment.

Existing `PreClassNativeBaseIsVisibleBeforeDerivedBodySema` and
`PreClassPropertyOffsetIsAnExactSealedLayoutFact` remain required source-build
and CodeGen parity evidence.

## Required evidence

- test-only Runtime/Editor build and exact causal RED;
- exact lifecycle GREEN plus the two existing PreClass SemaAuthority gates;
- complete SemaAuthority;
- ProductionCodeGen, Module Snapshot and TypedASTJIT cross-surface regression;
- final Runtime/Editor build;
- static scan proving `as_sema_decl.cpp` contains no `ShadowType`,
  `ProjectRuntimeBaseTypeInfo` or `PreClassData.Find` read;
- static shape check proving the new fact contains no Runtime pointer, numeric
  TypeId, Parser node, user-data pointer or snapshot-local AST ID;
- strict OpenSpec validation and plugin/parent `git diff --check`;
- plugin commit before the parent gitlink/OpenSpec commit.

## Encountered risks and non-claims

- The retained Runtime shell is intentionally mutable internal registration
  state; the test perturbation proves Sema isolation, not a supported public
  mutation API. CodeGen must still reject a real shell/sealed-layout mismatch
  before publication.
- This gate does not remove `ShadowType` from `asPreClassData`, Builder or
  CodeGen and does not delete the native AngelScript AST.
- This gate does not close Engine-wide native function/property projection,
  complete expression/statement authority, default cutover, or Tasks 4.3 and
  13.2 as whole-task requirements.
- Interface classification and other remaining live Runtime symbol/binding
  reads must be audited independently; this fact snapshot is not counted as
  their closure.

## Evidence log

1. Test-only Runtime/Editor build passed before the causal run:
   `Saved/Build/cta-s67-preclass-fact-red-build/20260829_144849_683_a38c0dd5`
   (`ExitCode=0`).
2. The first exact-test attempt omitted the CQTest fixture component and
   matched zero tests. It is retained only as an invalid invocation record,
   not used as RED evidence:
   `Saved/Tests/cta-s67-preclass-fact-red/20260829_144917_648_f5518a79`.
3. Corrected causal RED used the complete method path and failed `0/1` for
   the intended reason:
   `Saved/Tests/cta-s67-preclass-fact-causal-red/20260829_145005_099_2a37c762`.
   The mutable AST projected `LateRuntimeHostBase`, attached that declaration
   as the derived base/dependency and sealed alignment `32`, proving that Sema
   followed the perturbed live `ShadowType` rather than the registration-time
   fact.
4. Production implementation captures `asSCanonicalPreClassFact` in
   `asCModule::AddPreClassData()`, copies it to the Canonical build candidate,
   resolves its complete stable key through the registered-declaration
   snapshot, and consumes its captured property offset/alignment during class
   layout. Public `asPreClassData` is unchanged.
5. Post-implementation Runtime/Editor build passed:
   `Saved/Build/cta-s67-preclass-fact-green-build/20260829_145258_024_728b5db3`
   (`ExitCode=0`, 167 actions).
6. Exact lifecycle GREEN passed `1/1`, with zero failures/skips:
   `Saved/Tests/cta-s67-preclass-fact-green/20260829_145518_778_cba9248f`.
7. The new gate plus both existing PreClass Sema/CodeGen gates passed `3/3`,
   with zero failures/skips:
   `Saved/Tests/cta-s67-preclass-fact-matrix/20260829_145715_732_e1fb0d66`.
8. Complete `CanonicalAST.SemaAuthority` passed `427/427`, with zero
   failures/skips:
   `Saved/Tests/cta-s67-sema-authority-full/20260829_145751_805_801f6b2c`.
9. Parser declarations, Canonical type, ProductionCodeGen, Module Snapshot
   and TypedASTJIT passed `224/224`, with zero failures/skips:
   `Saved/Tests/cta-s67-cross-surface/20260829_145844_168_8cfbfe36`.
10. Static scans prove `as_sema_decl.cpp` has no `ShadowType`,
    `ProjectRuntimeBaseTypeInfo` or `PreClassData.Find`. The internal fact
    contains only `size_t`, `asCString`, `int` and `bool`; it contains no
    Runtime pointer, numeric TypeId, Parser node, user-data pointer or
    snapshot-local AST ID. Intentional `ShadowType` reads remain at the
    registration snapshot boundary, LEGACY Builder registration and Canonical
    CodeGen Runtime validation/install boundary.
11. Plugin and parent `git diff --check` passed (Git emitted only the existing
    LF-to-CRLF worktree notices for plugin files). Strict OpenSpec validation
    passed: `Change 'refactor-as-canonical-typed-ast-compiler' is valid`.
12. Plugin-first implementation commit:
    `58a06d3 [CanonicalAST] Refactor: snapshot pre-class Sema facts`.

## Accounting

CTA-S67 is a bounded slice of Tasks 4.3 and 13.2. The formal task ledger stays
`101/136 = 74.3%` until a whole task requirement is proven and checked.
