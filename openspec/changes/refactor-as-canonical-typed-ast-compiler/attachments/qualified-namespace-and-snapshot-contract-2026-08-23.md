# Qualified namespace semantics and snapshot completeness — 2026-08-23

Worktree: `D:\as-cta` (the
`refactor-as-canonical-typed-ast-compiler` worktree).

## Scope

This note records two contract corrections made while advancing the Canonical
AST compiler. They make existing boundaries explicit; neither represents a
default-pipeline cutover or complete namespace CodeGen implementation.

1. Parser/Sema now preserves all segments of a source-level qualified
   namespace (`namespace A::B::C { ... }`) in the Canonical declaration tree.
2. `CompileFunction(asCOMP_ADD_TO_MODULE)` test coverage now describes the
   actual safe snapshot protocol: an incomplete retained generation is
   retired, not re-advertised as current.

## 1. Qualified namespaces must be a declaration path, not a flat parser name

### Defect

`asCParser::ParseNamespace()` notified Sema immediately after the first
identifier. For `namespace A::B::C`, that pushed only `A` as the body context.
`WalkOne(snNamespace)` likewise selected only the first `snIdentifier` and
then visited all children under it. The Canonical AST therefore contained:

```text
Namespace A
Function  A::F(int)
```

instead of `A -> B -> C -> F`. The legacy parser tree still contained the
extra identifiers, which made this an authority-boundary loss rather than a
syntax error.

### Repair

- `as_parser.cpp` first reads the complete `A::B::C` path and validates `{`.
  It then calls `NotifySema()` and scopes the namespace body to Sema's final
  acted declaration.
- `as_sema_decl.cpp` iterates namespace-node identifier children, calls
  `ActOnStartNamespaceDecl()` once per segment, and visits only the body
  `snScript` under the final segment.
- Existing duplicate interning is retained: the later successful-parse
  `NotifySema()` sees and reuses the same `A -> B -> C` declarations.

The one pushed parser scope is deliberately the final namespace (`C`), not a
stack of transient `A/B/C` scopes. Its destruction restores the enclosing
context exactly once, while the Canonical declaration ownership remains the
full nested path.

### Test-first evidence

The new real-engine regression test is:

```text
ParserActOnQualifiedNamespacePreservesEverySegment
```

It requires `Namespace A`, `Namespace B`, `Namespace C`, the stable key
`A::B::C::F(int)`, and absence of the erroneous `A::F(int)`.

| Phase | Evidence | Result |
| --- | --- | --- |
| RED build | `Saved/Build/cta-qualified-namespace-red-build/20260823_065651_411_0b82abc1` | succeeded |
| RED behavior | `Saved/Tests/cta-qualified-namespace-red/20260823_065708_268_0d5edb45` | **0/1**; dump contained only `A::F(int)` |
| GREEN build | `Saved/Build/cta-qualified-namespace-green-build/20260823_065817_566_1ad754d5` | succeeded |
| GREEN focused test | `Saved/Tests/cta-qualified-namespace-green/20260823_065829_248_dff01a16` | **1/1** |
| Sema regression theme | `Saved/Tests/cta-qualified-namespace-sema-green/20260823_070132_804_eaf2f21c` | **251/251**, 0 failures/skips |

`NamespaceOverloadSelectsScopedFunctionNotGlobal` originally invoked a full
Canonical `Module::Build()`. That test's contract is scoped name resolution,
whereas the bounded CodeGen backend deliberately rejects namespace runtime
publication. It now drives `Parser -> Sema -> Seal` directly and continues to
prove that `Game::F(3)` resolves to `Game::F(int)`, not global `F(int)`.

## 2. A retained snapshot cannot remain current after legacy single-function append

`CompileFunction(..., asCOMP_ADD_TO_MODULE, ...)` currently invokes the
legacy single-function compiler and does not merge its added declaration into
the sealed Canonical module graph. Keeping the prior module snapshot current
would make public AST consumers believe they had a complete description of a
module that now contains another executable function.

The safe V1 protocol already implemented in `as_module.cpp` is:

```text
complete Build, retain snapshot A
        |
CompileFunction(ADD_TO_MODULE) adds executable function B
        |
retire module-owned A
        |-- existing lease A: still immutable/readable, IsCurrentGeneration=false
        `-- new AcquireASTSnapshot: null

next complete Build -> publish a new complete generation
```

The old Cutover test asserted the unsafe historical behavior (fresh acquire
returns A and A remains current). It is now named
`CompileFunctionAddToModuleRetiresIncompleteSnapshot` and proves:

1. the added `Extra()` function executes;
2. the lease acquired before the append is no longer current but remains
   readable with the same generation key; and
3. a fresh acquire is null.

The Chinese Canonical AST knowledge page now describes the same contract.

| Evidence | Result |
| --- | --- |
| Build | `Saved/Build/cta-compilefunction-snapshot-contract-build/20260823_070343_695_b9f59b20` — succeeded |
| Focused Cutover test | `Saved/Tests/cta-compilefunction-snapshot-contract/20260823_070400_345_dc3f0505` — **1/1** |

## Full-theme observation and remaining boundary

The first broad CanonicalAST run after the namespace repair was **329/330**:
the only failure was the outdated Cutover expectation above, not a production
failure. After the test correction, the same full CanonicalAST theme is
**330/330**, 0 failures/skips:

```text
Saved/Tests/cta-qualified-namespace-canonical-green/
  20260823_070543_375_5549fbb0
```

These changes do **not** claim the following:

- Canonical CodeGen still has no namespace-aware `asSNameSpace` publication
  mapping. Any source module with a namespace must fail before provisional
  runtime declarations become visible; the dedicated ProductionCodeGen test
  owns that fail-closed contract.
- `CompileFunction` is still a LEGACY compiler path. Retiring its incomplete
  AST is a safety boundary, not completion of tasks 10.1, 10.3, or 10.4.
- The production default remains `LEGACY`; no readiness/default-cutover task
  is closed by these local repairs.
