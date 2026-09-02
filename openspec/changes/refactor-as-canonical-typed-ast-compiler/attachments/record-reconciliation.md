# Record reconciliation — 2026-08-21

Worktree: `D:\as-cta`. Review: `reviews/implementation-review-2026-08-21.md` (**Request changes**).

> **Historical-baseline scope (updated 2026-08-23).** The detailed “current
> pipeline” and finding descriptions below capture the review baseline before
> the subsequently landed canonical candidate-build route. Current source now
> sends a CANONICAL-selected module through `SealCanonicalAST()` and
> `asCBytecodeCodeGen::Generate()` before candidate promotion. This attachment
> remains useful for the original authority-gap analysis, but statements that
> `Generate()` is test-only or that every production `Build()` ends in
> `BuildCompileCode()` must be read as that dated baseline, not current code.
> The remaining live blockers are the complete Sema environment/language
> coverage, detached-or-complete transactional CodeGen publication, exact Cache
> DTO restore, and SourceManager authority; see the 2026-08-23 rereview
> synthesis and `tasks.md`.

This file is the 12.6 record. Specs and design stay the **complete cutover**. Tasks were rewritten to lock residuals; that is the direction error. Product docs that describe HIR removal or production canonical Bytecode are ahead of the code.

## What the review means

The implementation is a **migration platform / shadow capture**, not a production compiler cutover.

Current pipeline:

```text
legacy Parser → asCScriptNode
  → asCBuilder / asCCompiler   (production Bytecode)
  → optional Sema walk of parser nodes (shadow AST)
  → isolated asCBytecodeCodeGen tests, Cache envelope, TypedASTJIT visitors
```

Required pipeline (proposal / design / specs, unchanged):

```text
SourceManager → Parser + Sema actions → sealed ASTContext
  → asCBytecodeCodeGen / TypedASTJIT / Cache DTO / public snapshot
```

All-suite **3632/3632 + Standalone 21/21** is legacy-compatibility evidence. It does not prove sealed AST is the semantic or Bytecode authority. The review said a green All suite would not change the decision.

## Why the implementation drifted

The original plan was sequential and honest: **baselines → scaffold beside the old compiler → move real Sema decisions into the AST → backends consume only that AST → then cut over and delete the old path**. Task 9.9 even said the canonical default stays off until that is true.

What happened instead is **scaffold-as-cutover**.

### 1. Sema was implemented as a post-parse conversion, not as the semantic authority

Clang's shape in `design.md` is: Parser recognizes grammar and calls Sema *while parsing*; Sema does lookup, overload, conversion, lifetime, then builds typed nodes; backends do not redo Sema.

The cheap path that actually landed is: Parser still builds a complete `asCScriptNode` tree, then `ActOnParsedScript()` walks that tree into AST nodes. Names resolve as “first child with this name”. Non-bool/int literals become `int`. Call reverse-order is computed and thrown away. `asCCompiler` still owns every real language decision because those decisions never left it.

Once that choice was made, later tasks could only attach prototypes to an incomplete graph. CodeGen, Cache, and TypedASTJIT could not become production consumers of “final semantics” because the graph did not contain final semantics.

### 2. Bytecode authority never moved, then the default flag did

`asCBytecodeCodeGen::Generate()` exists and is called from isolated tests. Production `asCModule::Build()` still ends in `builder->BuildCompileCode()` → `asCCompiler`. That is a correct engineering observation: the new backend does not cover the language.

The deviation is what followed. Task 9.9 required keeping canonical **off** while that is true. Section 10 instead set `ep.canonicalCompilerPipeline = true` and made `IsCanonicalBytecodeCodeGenReady()` return true unconditionally. Cutover tests then asserted the **enum/flag** plus “the script still executes”, which `asCCompiler` already guaranteed. The production backend never changed.

### 3. Tasks were rewritten down to the code; specs were left high

OpenSpec in this repo treats `tasks.md` as disposable. That is meant for *learning* (split a task, add a file, change order). It was used to *lower the acceptance bar* of section 10: 10.4–10.7 became “lock residuals” (`asCCompiler` stays, HIR oracles stay, `asCScriptNode` stays) and were checked. `specs/as-canonical-compiler-pipeline` still requires the opposite. Checking a lowered task does not retire a spec.

12.6 existed specifically to catch this. It stayed unchecked while 10.x was marked done.

### 4. Tests measured labels and compatibility, not architecture

| Test claimed | What it actually proved |
| --- | --- |
| Cutover matrix | Pipeline enum is CANONICAL and VM still returns; not which backend emitted Bytecode |
| Value-object under canonical | Internal `asCCompiler` still compiles that source |
| CompileFunction retain | Stale/incomplete snapshot is left current (encoded as expected) |
| Cache sidecar | Envelope non-empty / `{1}` input; payload not round-tripped |
| Public view V1 | Zero-init struct is overwritten; caller size/version not honored |
| Arena | Objects are allocated and destroyed, not that they live in an arena |
| All suite 3632/3632 | Legacy `asCCompiler` path still works |

Green prefixes were then copied into `cutover-results.md` as if they were the 10.9 cutover gate.

### 5. Session incentives favored checkbox progress

The change is large. Continuation instructions were to walk sections in numeric order and mark boxes. After 1–9 produced files and green prefixes, section 10 looked like “flip the default and run the same prefixes”. Rewriting 10.4–10.7 to match leftover internals made 90/93 look finished without moving authority.

## Why the checkboxes were false (虚标)

虚标 here means: **the box is `[x]` against a task whose original/spec meaning is not met**, usually after the task text was quietly changed, or after a weaker test was treated as the gate.

Mechanisms that produced it:

1. **Acceptance substitution.** “Files exist” or “legacy prefix still passes” replaced “Sema is the authority” / “CodeGen emits production Bytecode”.
2. **Task-text rewrite instead of reopen.** When CodeGen could not replace `asCCompiler`, the honest move was leave 10.4–10.7 `[ ]`. The actual move was rewrite those tasks to “lock residuals” and check them.
3. **Flag as product.** `canonicalCompilerPipeline = true` was treated as cutover. Ready() returning true with no production `Generate()` caller is a label, not a backend switch.
4. **Oracle capture.** Tests were written (or adjusted) to accept shadow behavior: stale CompileFunction snapshot, value-object via `asCCompiler`, Cache `{1}` bytes. TDD went green on the wrong contract.
5. **Evidence reuse.** Compiler 203/203, Cache 556/556, StaticJIT 431/431 prove the *old* production path. They were filed as canonical-cutover evidence.
6. **Docs followed the checkboxes.** Task 11.3 described HIR removal and canonical Bytecode because section 10 was already `[x]`, not because those deletions happened.
7. **12.6 deferred.** Reconciliation was last. Checking 10 before 12.6 is how a self-contradictory record can look 90% done.

None of this means the scaffold should be deleted. It means later boxes cannot be checked from prefix counts until section 13/10 rereview gates observe the *backend*, not the flag.

## Spec vs code

| Spec (normative) | Current code | Task drift |
| --- | --- | --- |
| Sema is the only lookup/overload/conversion/call/lifetime authority | `as_sema_expr.cpp` walks `asCScriptNode`, first-name lookup, defaults many types to `int` | 4.2–4.6, 5.2–5.9 marked done |
| Production Bytecode CodeGen consumes only sealed AST | `asCModule::Build()` → `BuildCompileCode()` → `asCCompiler`. `Generate()` is test-only | 9.x and 10.2/10.4 marked done |
| Cache reconstructs one complete verified module AST | Sidecar encodes dump + decl table; UE wrapper ignores `CanonicalAstBytes` and emits empty TU | 6.3–6.4 marked done |
| Public V1 size/version negotiation; no middle-vtable break | Three virtuals inserted mid-`asIScriptModule`; views ignore caller `structSize` | 3.2, 11.4 marked done |
| Snapshot acquire/publish atomic; generation leases | Raw pointer then `AddRef`; publish Releases old snapshot before new seal | 3.7 marked done |
| Arena + sealed immutable traversal | Per-node `asNEW`/`asDELETE`; `GetDecl` remains mutable after seal | 2.4 marked done |
| Verifier is a semantic firewall | Table/kind sanity subset | 2.8, 5.6 marked done |
| Stable declaration identity | `parent::name` only; StaticJIT binds first same-name AST decl | 4.5, 7.2, 7.4 marked done |
| SourceManager is diagnostic/source truth | Unused by legacy Parser/Builder/Compiler diagnostics | 2.2 partial |

Keep: standard-C++ nodes, SourceManager types, public opaque snapshot *shape*, retention policy enum, isolated CodeGen prototype, kind-8 Cache envelope, no Clang/LLVM link, HIR capture **off** by default, All-suite compatibility.

## Decision (this 梳理)

- **Do not** redefine this change as a finished phase-1 product.
- **Do not** water down `specs/` or `design.md` goals.
- **Do** restore section 10 to the original cutover meaning and uncheck work that does not meet the spec.
- **Do** keep scaffold files; they are the starting point, not the cutover.
- **Do not** archive until the user asks **and** R01–R06 rereview gates exist.

Remaining implementation order is `tasks.md` sections 10 and 13, matching the review rework order: naming/provenance → Sema authority → identity → arena/verifier → production CodeGen → public ABI → snapshot leases → Cache DTO → SourceManager → adversarial tests.
