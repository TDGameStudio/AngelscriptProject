# Legacy native AST retention scope revision — 2026-08-27

## Decision

`refactor-as-canonical-typed-ast-compiler` SHALL still complete the Canonical
Parser-to-Sema, sealed AST, Bytecode CodeGen, TypedASTJIT, snapshot/publication,
and default-selection work. It SHALL also still physically remove the added
function-owned TypedSemantic HIR after every consumer has migrated.

This change SHALL NOT physically remove AngelScript's native syntax/compiler
implementation:

- `asCScriptNode` and its Parser-owned syntax tree;
- `asCBuilder` and its syntax/registration support;
- `asCCompiler` and the explicitly selected LEGACY compile path;
- native Parser/Builder/compiler tests that protect syntax and compatibility.

Those remain available for syntax-coverage reference, isolated differential
comparison, explicit rollback, and compatibility while CANONICAL matures. Any
later deletion requires a separately reviewed OpenSpec. The recommended future
change name is `retire-as-legacy-native-compiler-pipeline`; this record does not
create or implement it.

## Terminology that must not be conflated

| Structure | Role | Disposition in this change |
| --- | --- | --- |
| Native `asCScriptNode` tree | Parser syntax/recovery tree and LEGACY compiler input | Retain |
| Native `asCBuilder` / `asCCompiler` | Explicit LEGACY compilation, reference and rollback | Retain |
| Canonical Decl/Type/Stmt/Expr AST | Sealed semantic authority for CANONICAL Bytecode, TypedASTJIT and public inspection | Complete and make default-ready |
| `asCTypedSemanticFunction` HIR | Added duplicate function-owned semantic sidecar | Migrate every consumer, then delete |

The desired post-change architecture therefore has two deliberately separate
source paths, not three semantic representations:

```text
explicit LEGACY
  native Parser -> asCScriptNode -> asCBuilder/asCCompiler -> VM Bytecode

default CANONICAL (after final gate)
  native Parser syntax + typed actions -> Canonical Sema -> sealed AST
      -> detached Bytecode CodeGen
      -> TypedASTJIT

TypedSemantic HIR: absent
```

Retaining both explicit pipelines is not a `dual` compiler. A single Engine
build selects exactly one publisher. CANONICAL must never:

- silently invoke LEGACY for an unsupported form;
- merge Builder/Compiler facts into a partially constructed Canonical graph;
- reconstruct semantics by a post-parse whole-tree replay;
- use HIR or Bytecode to recover source meaning;
- label LEGACY Bytecode as Canonical CodeGen output.

## Canonical completion requirements that remain unchanged

The scope revision does not narrow Canonical correctness. Before CANONICAL may
become the product default, it still requires:

1. typed Parser-to-Sema action coverage for every accepted declaration, type,
   expression, statement, control, and lifetime fact;
2. a sealed verified graph that contains every backend decision;
3. detached Bytecode coverage and resolve-before-publication for every active
   source fixture;
4. TypedASTJIT eligibility, closure, cleanup, dependency, and emission visitors
   that consume only Canonical AST plus Runtime/native-linkage views;
5. physical HIR builder/storage/accessor/type and HIR-only consumer deletion;
6. Build, CompileFunction, Hot Reload, generation, commandlet, and Standalone
   provenance/publication gates;
7. explicit `LEGACY` and `CANONICAL` values only, with unknown/`dual` rejection;
8. final focused, Standalone Debug/Release, and All-suite evidence.

The retained native syntax tree may still be built in CANONICAL parsing for
grammar structure, recovery, locations, and native parser coverage. It cannot
be the semantic body contract passed to Canonical Sema or either Canonical
backend. Named transitional node adapters therefore remain valid migration
targets even though the underlying node classes and LEGACY users are retained.

## HIR deletion remains in scope

The following requirements are intentionally **not** deferred:

- Task 7.8 removes TypedASTJIT production reads of
  `GetTypedSemanticFunction()` after its Canonical visitors are complete.
- Task 10.5 removes HIR capture/builders/storage/accessors and HIR-only
  production/test consumers after migrated Canonical oracles are green.
- `as-typed-semantic-ir` continues to specify coordinated HIR removal.
- `static-jit-diagnostics` continues to replace HIR-only production names and
  inputs with Canonical AST terminology.
- HIR dump files and sidecars never become Canonical compiler, Cache, or
  Provider inputs.

## CTA-S22 compatibility

CTA-S22 removed an inactive duplicate replay chain inside the new Canonical
Parser/Sema integration:

```text
NotifySema -> ActOnParsedScript -> ActOnParsedDeclaration -> WalkOne/WalkDecls
```

It did not delete `asCScriptNode`, the native Parser grammar tree,
`asCBuilder`, `asCCompiler`, or the explicit LEGACY Build path. The removal
therefore remains aligned with this revision: CANONICAL no longer has a hidden
whole-tree fallback, while the native LEGACY implementation stays intact.

## Problems found while reconciling the record

### CTA-SCOPE-01 — “legacy AST” and “HIR” were treated as one deletion target

The proposal, design, compiler-pipeline spec, tasks, execution plan, and latest
progress snapshot used phrases such as “old AST/HIR removal”, “sole production
compiler”, and “LEGACY semantic retirement”. Those phrases hid two independent
structures and could cause the native AngelScript syntax implementation to be
deleted merely because HIR consumers had migrated.

**Correction:** authoritative documents now distinguish native AST retention
from HIR deletion. Historical Gate attachments remain unchanged evidence for
what was implemented at their dates; this attachment supersedes their future
scope language wherever it conflicts.

### CTA-SCOPE-02 — proposal status contradicted the current implementation

The proposal status said source-module `Build()` already defaulted to
CANONICAL. Current source and the final progress record prove the migration
default is LEGACY. The status paragraph is corrected; the final default switch
remains an unchecked gate.

## Non-claims

- This revision does not mark any implementation checkbox complete.
- It does not change the compiler default; LEGACY remains current default.
- It does not restore the deleted CTA-S22 Canonical replay fallback.
- It does not make legacy output acceptable evidence for a CANONICAL task.
- It does not defer HIR deletion.
- It does not create the later native-compiler retirement OpenSpec.
- It changes OpenSpec scope/acceptance only; no production or test source is
  changed by this decision record.
