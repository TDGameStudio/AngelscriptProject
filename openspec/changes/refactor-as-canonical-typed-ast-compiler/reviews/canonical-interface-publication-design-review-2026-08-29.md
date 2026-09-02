# Canonical interface publication design review (2026-08-29)

## Review target

- `design.md` interface-dispatch revision, Decision 4A, CodeGen publication
  rule, risks, migration and open-question reconciliation;
- `specs/as-canonical-typed-ast/spec.md` exact method-edge scenarios;
- `specs/as-canonical-compiler-pipeline/spec.md` detached interface publication
  and rollback scenarios;
- `attachments/canonical-interface-publication-transaction-design-2026-08-29.md`.

The approved architecture is Approach A: Sema owns exact class/base/interface
method relationships, final verification authenticates them, CodeGen derives
only generation-local Runtime dispatch/layout state, and candidate `Commit()`
is the sole publication boundary.

## Self-review result

### 1. Semantic-authority consistency — pass

The revision is consistent with the parent design's `Parser -> Sema -> sealed
AST -> read-only backends` rule. It explicitly forbids CodeGen name/signature
selection and reuse of native Builder semantic metadata. The Runtime layout
projection is described as mechanical consumption of authenticated declaration
edges, not a new source-level IR or Sema pass.

### 2. Runtime identity consistency — pass

The design keeps Runtime function/type pointers, function IDs, numeric TypeIds,
`vfTableIdx`, method-table positions and interface offsets inside the candidate
generation. Canonical identity remains declaration/type identity. This matches
the approved dynamic TypeId and Runtime-install boundary and does not imply
stable numeric TypeIds.

### 3. Transaction and lifetime consistency — pass

The design reuses the existing detached artifact plus module-candidate
`Commit()`/`Abandon()` protocol. It requires complete interface dispatch-plan
validation before publication and preserves the last-good generation on every
failure. It does not add a post-promotion patch phase or conflict with snapshot
leases.

### 4. AngelScript Runtime invariant consistency — pass

Authored interface methods are specified as declaration-only
`asFUNC_INTERFACE` methods with declaration-order `vfTableIdx`, no executable
body and no `scriptData`. Class method tables, interface closure,
`interfaceVFTOffsets` and dispatch chunks are treated as a consistent Runtime
projection. Existing `asBC_CALLINTF` consumption remains the execution path;
no new VM opcode is claimed.

### 5. Scope consistency — pass

The revision does not flip the default, delete the native AST/Builder/Compiler,
recreate HIR, widen Public AST V1, redesign Cache V2, redesign public TypeId, or
claim full-language cutover. Standalone is explicitly deferred for this slice.
The affected tasks remain open until their full sentences and focused gates are
satisfied.

### 6. Testability — pass

The attachment defines an AST-first RED/GREEN gate before production lowering,
then execution and pre-commit failure injection. It covers interface
inheritance, inherited implementation, overload identity, malformed edges,
function kind/body ownership, rollback and deterministic dumps. This is enough
to write a concrete implementation plan without choosing new architecture
during coding.

### 7. Placeholder and ambiguity scan — pass

The new design contains no unresolved placeholder marker. Internal C++
type/container names remain deliberately unspecified, but their ownership,
inputs, validation and publication boundaries are fixed.

## Code evidence alignment

The review checked the current maintained-fork implementation around:

- `as_bytecode_codegen.cpp::RegisterCanonicalScriptTypes`;
- `FillFunctionSourceMetadata` and `FillFunctionSignature`;
- `AttachCanonicalObjectFunction`;
- `FinalizeCanonicalObjectInheritance`;
- Canonical `asBC_CALLINTF` emission;
- LEGACY `asCBuilder::CompileInterfaces` and `LayoutClass` as Runtime-invariant
  references only;
- `asCObjectType::methodTable` and `interfaceVFTOffsets`.

The evidence supports the recorded gaps: current Canonical registration and
inheritance finalization do not yet implement the complete Sema-owned lexical
interface contract, while the VM has an interface-call consumer.

## Remaining review gate

This self-review does not authorize implementation. The written Approach A
revision requires user review/approval. After approval, invoke the repository's
planning workflow, produce the AST-first implementation plan, and only then
start test-first code changes.
