# HIR dump — consume the held snapshot lease

> Historical evidence only. CTA-HIR-03 physically deleted the HIR dump
> command/Commandlet and migrated the retained containment/snapshot assertions
> to direct Canonical ProjectSourceGraph/public-lease tests. See
> `hir-editor-dump-retirement-gate-2026-08-27.md`.

Worktree: `D:\as-cta` (junction to
`.worktrees\refactor-as-canonical-typed-ast-compiler`)

Change: `refactor-as-canonical-typed-ast-compiler`
Date: 2026-08-23

## Finding

`FAngelscriptHIRDumpCommand::ExecuteMatchingProfile()` acquired a public
`asIASTSnapshot` lease and retained it for the module iteration, but it then
read the AST through `asCModule::GetCanonicalASTContext()`. That raw lookup
was unnecessary and bypassed the lifetime guarantee established by the held
lease. A concurrent replacement could make the raw module accessor refer to a
different or retired context than the snapshot represented by the result.

This was a real consumer bug, not a request to remove the internal helper from
all compiler tests in one sweep. Most `GetCanonicalASTContext()` uses are
single-threaded white-box test/dump inspection. The matching-profile editor
command is different: it explicitly advertises a primary retained-AST lease.

## Repair

The command now includes `source/as_ast_public_view.h`, narrows the already
held public lease to its maintained-fork implementation type
`asCASTSnapshot`, and obtains the context with `GetContext()`:

```text
AcquireASTSnapshot(V1)
    -> asCASTSnapshot lease held
       -> GetContext()
          -> dump sealed graph
    -> Release()
```

`GetContext()` is used only while that lease remains held. The command still
freezes hot-reload application for the duration of matching-profile work; this
change does not extend that freeze or alter dump output, selection, provider
emission rules, or target-profile behavior.

## Test-first oracle and validation

`Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp` now examines
the body of `ExecuteMatchingProfile()` and requires all of the following:

1. no `GetCanonicalASTContext` call in that lease-owning method;
2. use of the concrete `asCASTSnapshot` adapter; and
3. context access through `GetContext()`.

The source assertion is intentionally deterministic: a normal threaded test
cannot reliably force the exact raw-pointer race window.

| Stage | Result |
| --- | --- |
| Architecture RED | `cta-hirdump-lease-red_01_Standalone` — **20/21 passed**; only `AngelscriptStandalone.Architecture` failed with `matching-profile HIR dump must read context through its held AST snapshot lease`. |
| Standalone GREEN | `cta-hirdump-lease-green_01_Standalone` — **21/21 passed**, including Architecture and CanonicalAST. |
| UE Editor build | `Saved/Build/build/20260823_042459_175_fe831e11` — **4/4 actions**, UBT `Result: Succeeded`, runner ExitCode `0`. |
| Runtime StaticJIT regression | `Saved/Tests/cta-hirdump-lease-runtime/20260823_042603_372_df0e45b9` — `Angelscript.TestModule.StaticJIT.PrimaryCanonicalASTGenerate` **9/9 passed**, 0 failed, 0 skipped, 0 timed out. It covers matching-profile dump, retained-snapshot requirement, hot-reload freeze while leases are held, and no-sibling-engine generation behavior. |

The test process emits the environment's transient Google connectivity timeout
warning during some engine startups; the automation report has no associated
test failure or warning summary.

## Remaining boundary

This removes one externally meaningful raw-context consumer. It does **not**
make `GetCanonicalASTContext()` itself thread-safe or deprecate its existing
single-threaded compiler/test callers. In particular, the StaticJIT generation
snapshot still stores raw `SealedAST` pointers for TypedASTJIT and needs a
separate ownership design that preserves an `asIASTSnapshot` lease for the
generation snapshot's entire lifetime. That work must also choose how a
TypedSemanticIR-capture module obtains a retainable snapshot without changing
the production default pipeline.

Do not check broad public-ABI, snapshot-protocol, TypedASTJIT, Cache V2, or
compiler-cutover tasks from this focused consumer repair.
