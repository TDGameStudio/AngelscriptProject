# Canonical interface publication transaction design (2026-08-29)

## Decision status

Approved approach: **A — Sema-owned exact method edges with a mechanical
CodeGen Runtime projection**.

This attachment refines the remaining declaration/dispatch work in Tasks 0.2,
4.3, 4.5, 9.1, 9.5, 13.2 and 13.6. It does not close those umbrella tasks by
itself. The formal task ledger remains authoritative.

The slice is deliberately bounded:

- lexical interface declarations;
- interface inheritance and class implementation closure;
- exact class/base/interface method relationships;
- Runtime interface function kind and slots;
- candidate-owned method tables, interface offsets and dispatch chunks;
- validation and atomic publication/rollback.

Standalone adaptation is deferred by explicit product direction and is not a
gate for this slice. The product default remains LEGACY. The native
`asCScriptNode`/Parser/Builder/Compiler pipeline remains available for explicit
LEGACY, syntax/recovery, reference, differential and rollback use. HIR remains
physically absent.

## Why this slice is needed

The current Canonical declaration path has crossed the first Runtime boundary,
but lexical interfaces are not yet represented as a complete candidate-owned
dispatch transaction:

1. `RegisterCanonicalScriptTypes` currently registers lexical class shells but
   does not create the corresponding lexical interface Runtime shells.
2. `FillFunctionSourceMetadata` assumes `scriptData`, while an authored
   interface method is declaration-only and must be `asFUNC_INTERFACE` without
   a body or `scriptData`.
3. `FillFunctionSignature` and the detached function creation loop are shaped
   around script functions/class ownership; a bodyless interface declaration
   can therefore be skipped or assigned the wrong Runtime function kind.
4. `AttachCanonicalObjectFunction` attaches ordinary class functions and the
   method table but does not complete interface-specific slot/layout state.
5. `FinalizeCanonicalObjectInheritance` currently locates class overrides by
   Runtime method name/signature. That is a second semantic selection in
   CodeGen, not a mechanical projection of sealed Sema facts.
6. `asCObjectType::methodTable`, `interfaces`, `interfaceVFTOffsets` and the
   Runtime interface-vtable chunks are consumers that must agree as one
   generation. Publishing any of them before the complete plan validates would
   permit a partial candidate.

The VM side already recognizes interface dispatch: Canonical emission selects
`asBC_CALLINTF` when the resolved Runtime callee is `asFUNC_INTERFACE` or the
sealed call shape requires virtual dispatch. The missing boundary is therefore
not a new VM instruction; it is authoritative semantic identity and complete
Runtime publication.

## Reference model

The relevant Clang separation is useful but not copied literally:

- `clang::CXXMethodDecl` records exact overridden method relationships as AST/
  semantic facts;
- Clang's VTableBuilder consumes those relationships and constructs target-ABI
  slots and layout.

Primary references:

- <https://clang.llvm.org/doxygen/classclang_1_1CXXMethodDecl.html>
- <https://clang.llvm.org/doxygen/VTableBuilder_8cpp.html>

AngelScript has different interface semantics and Runtime structures, so the
portable lesson is ownership: semantic relationships precede backend ABI/
Runtime layout. Runtime slot numbers are not source identity.

## Architecture

```text
Parser lexical declarations
          |
          v
Canonical Sema
  - resolve class/interface ancestry
  - resolve exact override/implementation method edge
  - canonicalize exact signature/qualifiers
  - prove required interface coverage
          |
          v
Seal + final verifier
  - owner/kind/ancestry/signature checks
  - uniqueness/completeness checks
  - snapshot-local edge integrity
          |
          v
Detached Canonical CodeGen candidate
  - interface Runtime shells
  - declaration-only asFUNC_INTERFACE methods
  - declaration-order interface vfTableIdx
  - class method slots
  - transitive interface closure and offsets
  - interface dispatch chunks
          |
          v
validate complete dispatch/install plan
          |
      Commit or Abandon
          |
          v
atomic module-candidate promotion
```

### 1. Sema is the only method-selection authority

For every authored method that overrides a base method or implements an
interface requirement, Sema records an exact snapshot-local declaration edge.
The relationship is not represented only by name, display signature, numeric
function ID, `asCScriptFunction*`, or method-table position.

The semantic record must carry or make directly queryable:

- source method declaration ID;
- target base/interface method declaration ID;
- source and target declaring type declaration IDs;
- relationship role (base override or interface implementation);
- exact canonical return/parameter/qualifier facts already owned by the method
  declarations;
- stable declaration identity only where a relationship crosses a snapshot or
  installation boundary.

Sema also resolves transitive declared interface ancestry and proves that each
non-interface class has exactly one applicable implementation for every
required interface method. Inherited class implementations may satisfy a
requirement, but the selected declaration remains explicit.

CodeGen must not call a name/signature matcher to choose or replace this edge.
It may index exact keys/IDs for binding, but equality is verified against the
complete declaration identity.

### 2. Final verification authenticates the sealed contract

Before either Bytecode or Runtime installation sees the graph, verification
must reject an edge when any of these conditions holds:

- source or target declaration ID is dangling or foreign to the snapshot;
- either declaration has the wrong node kind or owner kind;
- the target owner is not in the legal class/interface ancestry closure;
- return type, parameters, direction/handle/reference qualifiers, const-method
  state, or required calling contract is incompatible;
- more than one edge claims the same required slot;
- a concrete class leaves a required interface method unresolved;
- an interface method owns an executable body or backend state;
- a cycle, an interface-to-class base edge, or a duplicate authored direct
  interface base makes the closure invalid; a shared transitive interface in a
  legal diamond is deduplicated by exact declaration identity.

Diagnostics use stable categories, source locations and structural paths.
Verification failure prevents artifact publication. It is not interpreted as
“no interface dispatch” and does not trigger LEGACY fallback.

### 3. CodeGen derives a generation-local Runtime projection

After verification, CodeGen creates a transient dispatch plan owned by the
candidate generation.

For lexical interfaces it:

1. creates an `asCObjectType` interface shell with explicit interface identity;
2. creates each authored method as `asFUNC_INTERFACE`;
3. does not allocate or populate a script body/`scriptData` for that method;
4. assigns the interface method's own `vfTableIdx` in deterministic declaration
   order;
5. builds the interface `methodTable` and transitive interface closure;
6. binds every verified implementation edge to the exact candidate Runtime
   function;
7. computes class interface offsets and interface-vtable chunks;
8. validates table lengths, slot ownership, exact bindings and closure
   consistency.

The following are installation results and remain generation-local:

- `asCScriptFunction*` and `asCObjectType*`;
- Runtime function IDs and public numeric type IDs;
- `vfTableIdx` and class method-table indexes;
- `interfaceVFTOffsets` and interface chunk offsets;
- patched bytecode operands and executable addresses.

They must not enter Canonical stable identity, Public AST V1, diagnostic dumps,
Cache DTO identity, Provider identity or cross-generation comparison. Active
execution may use them under the owning generation lease.

### 4. Publication is validate-all, commit-all

The implementation reuses the existing detached artifact and module-candidate
transaction. It does not introduce a second publication mechanism.

Before `Commit()` the candidate must contain and validate the complete set of:

- interface/class Runtime shells;
- interface and implementation functions;
- exact Canonical-to-Runtime function bindings;
- method tables and virtual slots;
- interface closure, offsets and dispatch chunks;
- relocations and immutable Runtime binding-view entries;
- executable Bytecode and the sealed snapshot selected for publication.

Only after all validation succeeds may `Commit()` expose Engine/module entries,
and only after successful commit may module-candidate promotion replace the
active generation. Failure at any stage invokes `Abandon()` and preserves the
entire last-good generation. No active table or pointer is repaired after
promotion.

This ordering extends the transaction coverage already proved for candidate
types, functions, globals and imports; it does not claim full Task 9.1/13.6
closure until every remaining declaration category and failure boundary is
covered.

## AST-first TDD gate for implementation

Implementation starts only after a focused RED records the missing semantic
fact. The gate card for this slice must name:

- test source and exact test method;
- lexical class/interface fixture;
- expected sealed method-edge owner, target and canonical signature;
- RED baseline showing the relationship is absent or backend-selected;
- GREEN `SemaAuthority`/Frontend result after Sema and verifier work;
- downstream ProductionCodeGen execution result;
- injected pre-commit failure result proving the previous generation remains
  current and executable.

Minimum scenarios:

1. one interface, one implementing class, one interface call;
2. interface inheritance with deterministic declaration-order slots;
3. class inheritance where an inherited implementation satisfies an interface;
4. overloaded same-name methods proving exact declaration identity;
5. missing, ambiguous, wrong-signature, foreign-owner and duplicate-edge
   verifier failures;
6. interface method has `asFUNC_INTERFACE`, no body and no `scriptData`;
7. injected failure after shell/function/table/chunk preparation but before
   commit preserves the complete previous generation;
8. repeated builds produce deterministic sealed dumps independent of Runtime
   numeric IDs and addresses.

The focused gate advances the umbrella tasks but does not check them unless the
rest of each task sentence is also satisfied.

## Expected implementation surface

Exact internal names may change during TDD, but the expected source surface is:

- Canonical declaration/Sema model for exact method relationship edges;
- Canonical sealing/verifier/deterministic internal dump and typed query helper;
- `as_bytecode_codegen.cpp` candidate type/function creation, exact binding,
  inheritance finalization and dispatch-plan validation;
- detached artifact/Runtime binding structures only if existing candidate-owned
  containers cannot represent the plan without premature publication;
- focused Canonical SemaAuthority/Frontend and ProductionCodeGen transaction
  tests.

Public AST V1 is intentionally not widened in this slice. A later public schema
revision requires an explicit compatibility need and versioning decision.

## Alternatives rejected

### B. CodeGen repeats name/signature matching

Rejected because it creates a second semantic authority, obscures ambiguous or
inherited choices, and can disagree with the sealed graph.

### C. Reuse native `asCBuilder` interface metadata

Rejected because CANONICAL would depend on native-tree semantic work, violate
Task 13.2, and weaken isolation between a candidate and the active generation.
The LEGACY implementation remains a differential/reference oracle only.

### D. Publish shells and patch interface tables afterward

Rejected because an allocation, binding or validation failure could expose a
partially updated generation. It also contradicts the established
`Commit()`/`Abandon()` and module-candidate promotion boundary.

### Put Runtime slots into Canonical AST

Rejected because function/type IDs, indexes, offsets and pointers vary by
Engine and Hot Reload generation. They are ABI/installation projections, not
source-semantic identity.

## Non-claims and follow-up boundaries

This design does not:

- flip the default from LEGACY to CANONICAL;
- remove the native AngelScript AST, Builder or Compiler;
- recreate HIR;
- adapt or validate Standalone;
- widen Public AST V1;
- finish full-language Canonical Bytecode coverage;
- redesign public/durable numeric TypeId behavior;
- complete Cache V2 or make it a cutover gate;
- claim Tasks 0.2, 4.3, 4.5, 9.1, 9.5, 13.2 or 13.6 complete.

## Source evidence reviewed

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`
  - `RegisterCanonicalScriptTypes`
  - `FillFunctionSourceMetadata`
  - `FillFunctionSignature`
  - `AttachCanonicalObjectFunction`
  - `FinalizeCanonicalObjectInheritance`
  - Canonical call emission using `asBC_CALLINTF`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp`
  - `CompileInterfaces`
  - `LayoutClass`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_objecttype.h`
  - `methodTable`
  - `interfaces`
  - `interfaceVFTOffsets`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp`
  - current interface-call instruction consumers

These locations establish the current gap and Runtime invariants. They do not
authorize CANONICAL to reuse Builder's semantic matching.
