# Public AST V1 — append-only module ABI repair

Worktree: `D:\as-cta` (junction to
`.worktrees\refactor-as-canonical-typed-ast-compiler`)

Change: `refactor-as-canonical-typed-ast-compiler`
Date: 2026-08-23

## Problem

The three public AST entry points had been inserted into `asIScriptModule`
between `CompileFunction()` and `SetAccessMask()`:

```text
old product 1.0.0 consumers
    CompileFunction -> SetAccessMask -> ... -> ClearImports

broken worktree layout
    CompileFunction -> SetASTRetentionPolicy -> GetASTRetentionPolicy
                    -> AcquireASTSnapshot -> SetAccessMask -> ...
```

That shifts every pre-existing virtual slot after `CompileFunction`. An
embedding client compiled against the original interface could therefore
dispatch an old method into a new, unrelated method. This is a binary ABI
failure, not a source-level warning.

## Decision

The mid-vtable declarations have been removed and the same three virtual
methods are now appended immediately after `ClearImports()`, before the
protected destructor:

```text
product 1.0.0-compatible prefix
    CompileFunction -> SetAccessMask -> ... -> ClearImports

appended Canonical AST V1 extension
    SetASTRetentionPolicy -> GetASTRetentionPolicy -> AcquireASTSnapshot
```

`asCModule` keeps the same overrides and implementation. No caller spelling,
retention behavior, snapshot ownership, compiler selection, or product version
changed. The unsafe middle layout has not been treated as a shipped compatible
1.0.0 ABI; therefore restoring the original prefix does not require claiming a
new product ABI version for this worktree.

## Regression oracle

`Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp` now reads the
maintained public header and asserts that:

1. the actual `asIScriptModule` **definition** contains all six layout
   markers;
2. `CompileFunction` precedes `SetAccessMask`, preserving the old prefix; and
3. `ClearImports` precedes all AST methods, which stay ordered and within the
   module definition.

This is intentionally a source-layout regression test. C++ has no portable
standard facility to introspect a virtual table slot number; locking the
public declaration order is the portable way to prevent a future source edit
from recreating this ABI break. The full UE build independently validates that
all real `asCModule` overrides compile under the append-only layout.

## Test-first and validation evidence

| Stage | Result |
| --- | --- |
| Layout RED | `Saved/Tests/cta-public-ast-vtable-red_01_Standalone` — **20/21 PASS**; only `AngelscriptStandalone.Architecture` failed with `asIScriptModule AST methods must be trailing append-only slots after ClearImports` |
| UE public-header build | `Saved/Build/build/20260823_035412_434_97de1a99` — **196/196 actions succeeded**; baseline fixture/deprecation warnings only |
| First post-move Standalone run | diagnostic only: `cta-public-ast-vtable-green_01_Standalone` still failed the new architecture assertion. Investigation showed the test selected the early `class asIScriptModule;` forward declaration rather than the later definition. CMake was confirmed to use `D:/as-cta/Plugins/Angelscript`; this was a test locator defect, not an ABI-layout failure. |
| Final Standalone GREEN | `cta-public-ast-vtable-green-v2_01_Standalone` — **21/21 PASS** including Architecture and CanonicalAST |
| Snapshot API GREEN | `Saved/Tests/cta-public-ast-vtable-snapshot/20260823_040055_634_d28c7c85` — **4/4 PASS** |
| Hot Reload Snapshot GREEN | `Saved/Tests/cta-public-ast-vtable-hotreload/20260823_040131_561_dd2d03f0` — **5/5 PASS** |

The Snapshot/Hot Reload prefixes demonstrate that moving the interface slots
did not alter retention selection, immutable views, old-generation leases,
failed-reload retention, reader-thread use, sidecar replacement, or the
existing TypedASTJIT generation lease fixture.

## Relationship to the V1 view-size repair

This follows `public-ast-v1-view-size-contract.md`. That attachment made
caller-provided `structSize` a fail-closed capacity contract; this one restores
the older module-vtable prefix. They are complementary small repairs:

```text
public call dispatch       -> trailing module slots (this attachment)
public caller output bytes -> checked V1 view capacity (previous attachment)
```

Neither repair turns the public AST API into a complete, versioned snapshot
protocol.

## Deliberate non-claims

Do **not** mark OpenSpec 13.7 or 13.8 complete from this change.

- V1 has not yet supplied explicit binary compatibility migration guidance for
  any external consumer compiled against the transient middle-insertion tree.
  Such clients must rebuild; no code-level reorder can make both incompatible
  layouts use the same slots.
- Snapshot IDs are still raw snapshot-local indices and can alias numerically
  across generations. Foreign-snapshot use needs a generation-aware opaque-ID
  design and negative test, not just append-only module methods.
- `AcquireASTSnapshot()` versus publication still lacks the required atomic
  exchange-and-retain lifetime protocol. The present reader-thread test is a
  regression fixture, not proof of data-race freedom.
- `apiVersion` negotiation, richer V1 views, Cache V2 DTO fidelity,
  `CompileFunction` completeness, StaticJIT leasing, Sema authority, and
  default CANONICAL CodeGen all remain separate work.

The next public snapshot increment must address those protocol properties as a
single design, with explicit foreign-ID and acquire-versus-publish stress
tests.
