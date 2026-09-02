# Canonical temporary receiver and object-return ABI gate (2026-08-24)

This attachment records the AST-first gate for compound mutation through a
temporary script-class receiver and the object-return ABI defect exposed by
that gate. It is a focused slice of Tasks `4.3`, `5.3`, `5.4`, `9.5`, `13.2`,
and `13.6`; it does not close their broader language or lifecycle surface.

### Gate card: compound mutation evaluates a temporary receiver once

- **OpenSpec task(s):** `4.3`, `5.3`, `5.4`, `9.5`, `13.2`, `13.6`.
- **Source shapes:** `Make().Value += 1` and `Make()[0] += 1`, where `Make()`
  returns a script `class T` and the fixture records the `Make`, getter/index,
  and setter/write phases.
- **Canonical fact:** after `Parser -> Sema -> Seal`, the body-owned opaque
  sequence evaluates `Make()` once, captures its result in one `OpaqueValue`,
  and uses that exact node as the receiver of every read and write phase. A
  lexical script `class` is a `REFERENCE_OBJECT`; only a lexical script
  `struct` is a `VALUE_OBJECT`.
- **Permanent AST tests:**
  `PropertyCompoundAssignEvaluatesReceiverOnceOnCompileSealPath` and
  `IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath` in
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`. The property test
  requires the body-owned four-part opaque sequence
  `[OpaqueValue, Get Call, Binary, Set Call]` and proves that getter and setter
  carry the same explicit receiver ID. The index test proves that the
  `opIndex` base is the captured `OpaqueValue`.
- **AST-red:** the first precise property gate failed because lexical
  `class T` was classified as `VALUE_OBJECT`, and property getter calls did
  not retain explicit receiver metadata. Focused evidence: `0/1`,
  `Saved/Tests/cta-property-class-kind-ast-red/20260824_115148_729_25c7167f/RunMetadata.json`.
- **AST-green:** `ActOnQualType` now distinguishes lexical `class` and
  `interface` declarations from lexical `struct` declarations, and property
  getter/setter rewrites retain their receiver with `SetExprReceiver`.
  Focused evidence: `1/1`,
  `Saved/Tests/cta-property-class-kind-receiver-ast-green/20260824_115328_541_dcdd5c9f/RunMetadata.json`.
- **Known AST-arena boundary:** the sealed arena still retains orphan
  Parser/Sema residual expressions outside the selected function body. Task
  `4.2` therefore remains open; this gate deliberately follows body ownership
  instead of mistaking arena-wide node counts for executable AST structure.
- **Production RED:** the sealed AST is correct, but both execution fixtures
  receive null `this` in the getter/index call. Bytecode inspection shows that
  a script-class-returning `Make()` copies its return slot into the generic
  value register (`CpyVtoR8`), while its caller consumes the VM object register
  (`STOREOBJ`). Evidence: `0/1`,
  `Saved/Tests/cta-property-compound-exec-after-ast-green/20260824_115414_063_7d8e1dbb/RunMetadata.json`.
- **Required ABI invariant:** reference-object and funcdef returns transfer the
  owning pointer from the function return slot into the VM object register and
  clear the source slot with `LOADOBJ`. This matches the maintained LEGACY
  compiler contract and the caller's existing `STOREOBJ` protocol. POD/value
  register returns and caller-owned return-on-stack value objects remain on
  their separate paths.
- **Production green:** the Canonical epilogue now emits `LOADOBJ` for
  object-handle and funcdef returns while preserving the caller-owned
  return-on-stack and primitive value-register paths. Property focused `1/1`:
  `Saved/Tests/cta-property-compound-loadobj-green/20260824_115835_499_2bb4d8cd/RunMetadata.json`;
  index focused `1/1`:
  `Saved/Tests/cta-index-compound-loadobj-green/20260824_115919_646_84d27391/RunMetadata.json`;
  Semantics `12/12`:
  `Saved/Tests/cta-semantics-loadobj-green/20260824_120000_542_e9a99443/RunMetadata.json`.
- **Type-identity regression exposed by the complete gate:** correcting lexical
  script `class`/`struct` kinds revealed that a range-less class declaration
  imported for a host VALUE type did not retain `asOBJ_VALUE`. The same
  `FProdTriple` was therefore interned once as `VALUE_OBJECT` for a function
  parameter and once as `REFERENCE_OBJECT` after constructor/property import,
  making an exact by-value call unresolved. Permanent AST test
  `NativeValueTypeKeepsOneCanonicalKindAfterCallableInterning` records the
  failure and requires one VALUE kind plus a resolved call. AST RED `0/1`:
  `Saved/Tests/cta-native-value-identity-ast-red2/20260824_120954_671_4733a05b/RunMetadata.json`;
  AST green `1/1`:
  `Saved/Tests/cta-native-value-identity-ast-green/20260824_121249_458_1ee77f67/RunMetadata.json`.
  Native property/method/behaviour import now synchronizes the host VALUE fact
  onto its canonical class symbol. The twelve-byte POD by-value regression is
  `1/1` at
  `Saved/Tests/cta-pod-triple-byvalue-green/20260824_121334_948_e7a56027/RunMetadata.json`.
- **Qualified script-value regression exposed by the complete gate:** a
  namespaced script struct used the exact stable key
  `Tools::Utilities::FValue`, but the transient runtime candidate bridge
  compared only the short candidate name `FValue`. Runtime type matching now
  accepts the exact namespace-qualified candidate identity without weakening
  the existing unqualified host-type route. Focused production result `1/1`:
  `Saved/Tests/cta-namespace-value-object-green/20260824_121416_493_10d50e33/RunMetadata.json`.
- **Complete regression:** SemaAuthority `264/264` at
  `Saved/Tests/cta-sema-authority-type-identity-green/20260824_121458_378_a1420c99/RunMetadata.json`;
  ProductionCodeGen `73/73` at
  `Saved/Tests/cta-production-codegen-object-return-final-green/20260824_121549_538_24631235/RunMetadata.json`;
  complete CanonicalAST `365/365` at
  `Saved/Tests/cta-canonical-ast-object-return-final-green/20260824_121636_240_ff854b17/RunMetadata.json`.
