# Embedding client Canonical AST migration notes closure

Date: 2026-08-28  
Change: `refactor-as-canonical-typed-ast-compiler`  
Closed task: `11.4`

## Scope

Task 11.4 requires one current embedding-client note covering product/header
version, Public AST V1 negotiation, retention timing, null acquisition,
snapshot lease/current-generation rules, `CompileFunction`, Cache/
`SaveByteCode`, and the no-concrete-node-ABI boundary.

The public notes now live in:

- `Documents/Guides/AngelscriptCanonicalAST_ZH.md` (Chinese-first);
- `Documents/Guides/AngelscriptCanonicalAST.md` (English).

## Issues found and resolved

### CTA-DOC-01 — the guide contradicted the current CANONICAL publisher

The previous guide first stated that explicit CANONICAL `Build()` publishes
through `asCBytecodeCodeGen::Generate()`, then later stated that production
`Build()` still publishes through `asCCompiler`. Current `as_module.cpp`
selects the backend explicitly: CANONICAL uses the sealed AST CodeGen route;
LEGACY independently retains the compiler. The guide now states that exact
split and the no-silent-fallback/no-dual rule.

### CTA-DOC-02 — the guide claimed HIR remained

HIR source and public production reads have been physically removed; only a
Standalone architecture negative asserts that the former files stay absent.
The guide now says HIR is deleted, while native `asCScriptNode`, Parser,
Builder and Compiler remain for syntax/recovery/LEGACY/reference/rollback.

### CTA-DOC-03 — `CompileFunction` snapshot behavior was underspecified

The old table said only that `CompileFunction` must not replace a retained
module snapshot. The implemented protocol is more precise:

- CANONICAL uses an ephemeral sealed AST complete for one function closure;
- detached success preserves the complete module snapshot;
- successful `asCOMP_ADD_TO_MODULE` changes the module declaration inventory,
  so it retires the old snapshot and publishes no incomplete replacement;
- failure preserves the prior executable/snapshot generation;
- only a later complete retained `Build()` can republish the module snapshot.

Both language guides now state these routes and the null-acquisition
consequence.

### CTA-DOC-04 — version/capacity and foreign-ID rules needed a migration checklist

The new checklist requires the current product header (`Unreal AngelScript
1.0.0`, numeric `10000`), real `structSize`, V1/zero convenience negotiation,
append-only field access, foreign-snapshot ID rejection, lease-scoped view
strings/IDs, stable pointer-free persisted identity, and exact `Release()`
balance. It also records that a separately distributed incomplete V1 vtable
layout requires rebuilding; no compatibility claim is made for an unreleased
broken header.

### CTA-DOC-05 — Cache/SaveByteCode and dump boundaries were easy to conflate

The notes now distinguish:

- VM `SaveByteCode()` / `FunctionBody`: executable Bytecode only;
- optional Cache V2 `ASTBodySidecar`: pointer-free snapshot DTO, separately
  validated and published only under retain policy;
- dump/diagnostics: read-only observers, never compiler or AOT transport.

## Verification contract

The maintained Module Snapshot tests own the executable assertions for policy
freeze, retain/discard/null, API version and caller capacity, foreign IDs,
lease lifetime, current-generation replacement/failure, concurrency and
`CompileFunction(asCOMP_ADD_TO_MODULE)` invalidation. A fresh run is recorded
after the documentation change. OpenSpec strict validation and diff checks are
also required before task closure.

| Gate | Result | Evidence |
|---|---:|---|
| Module CanonicalAST Snapshot | **10/10 PASS**, zero fail/skip | `Saved/Tests/cta-114-migration-notes/20260828_110610_758_37e879ce/RunMetadata.json` |
| OpenSpec task count | **88/125 (70.4%)** | `openspec list --json` after Task 11.4 closure |
| OpenSpec strict | PASS | `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict` |
| Parent/plugin diff check | PASS; existing line-ending warnings only | parent and `Plugins/Angelscript` `git diff --check` |

This documentation task does not change the product default: it remains
LEGACY. It does not close default cutover, full-language CodeGen, final
publisher audit, or physical removal of the retained native AST/compiler.
