# Talk: Frontend reconstruction sequencing

## Purpose

Record the approved cross-Change dependency graph for the first reconstruction batch and prevent later publication or VM work from leaking into the nine frontend Changes.

## Authoritative nine-Change DAG

The capability graph has two early branches and two late branches. A Change may begin only after its named durable inputs exist, even when research or disjoint preparation can happen earlier:

```text
1 -> 2
2 -> 3, 5
3 -> 4, 7
4 -> 7, 9
5 -> 6, 7, 9
6 -> 7
7 -> 8, 9
```

In exact terms, Change 7 waits for Changes 3, 4, 5, and 6; Change 8 waits for Change 7; Change 9 waits for Changes 4, 5, and 7 and may proceed in parallel with Change 8. Change 5 follows Source/Diagnostics and deliberately does not wait for the directive preprocessor or AST. Change 6 consumes Change 5 rather than attempting to derive stable identity afterward.

Cross-Change prerequisites belong in proposal/design/task Context prose. Each `tasks.md` graph contains only that Change's local `X.Y` IDs.

| Change | Required durable output for downstream consumers |
|---|---|
| 1 | Replacement CQTest support and the `Angelscript.UnitTest.NativeEngine.<Area>` convention. |
| 2 | Immutable source snapshots, source ranges, provenance, and structured diagnostics. |
| 3 | Engine-independent pull tokens, identifiers, lexical options, and deterministic recovery. |
| 4 | Replayable directive records, typed `#restrict usage allow/disallow`, active-token routing, and source backquery without a C macro/include or new import model. |
| 5 | Stable semantic type identity independent of runtime IDs, pointers, and registration order. |
| 6 | Real concrete `Decl`/`DeclContext`, `Stmt -> ValueStmt -> Expr`, canonical `Type`/non-node `QualType`, `TypeLoc`, and `Attr` structures plus AST context, casting, visitors, verification, and the new versioned codec. |
| 7 | Whole-source declaration barrier, canonical lookup, resolved signatures, and deferred bodies. |
| 8 | Typed body semantics, recovery, control/lifetime facts, and deterministic body fragments. |
| 9 | Concrete resolved `FAngelscript*Desc` output and automatic declaration dependencies derived from the declaration-complete frontend result, with a separate optional body-invalidation sink. |

[Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 1-1400 contains an early assembly-oriented analogy that is not authoritative for this sequence; the correction beginning around line 1401 and the dedicated AST material under `Temp/ast/` establish the actual lexer/Parser/Sema/typed-AST direction.

## Unified production cutover

The nine Changes build and verify an isolated replacement frontend; none adds a production selector. After all nine are implemented, synchronized, and verified, a separately approved cutover Change SHALL move the production consumer as one coherent transition. It must not leave a long-lived per-file, per-module, CVar, or build-configuration choice between old and new semantic authorities.

A cutover proposal is ready only when:

1. All nine exact NativeEngine prefixes and strict OpenSpec records pass from current content.
2. The frozen frontend result contains every declaration, body, diagnostic, stable identity, reflection annotation, and dependency fact required by production.
3. Compatibility differences are enumerated as deliberate language decisions or resolved defects; silent fallback to old semantics is not an acceptance mechanism.
4. A rollback is a source-control/integration action, not a runtime dual-pipeline switch.

## Entry criteria for the next architecture batch

The following are future Change candidates, not tasks here.

| Future boundary | Entry criteria | Explicitly not started by Changes 1-9 |
|---|---|---|
| Builder separation | The complete frozen frontend result is queryable without live Engine/Builder state, and all production-required facts have a typed owner. | Renaming Builder, wrapping Engine in an interface, or moving existing mutations behind callbacks. |
| Candidate graph | Declaration/body/reflection facts can be projected into immutable candidate runtime types, functions, layouts, and dependencies keyed only by stable semantic identities. | Constructing `asCObjectType` during parse/Sema or storing candidate state on AST nodes. |
| Transactional publication | Candidate verification defines all-or-nothing commit, conflict detection, generation ownership, rollback before commit, and deterministic Engine ID allocation. | Incremental writes to Engine/module registries while analysis is incomplete. |
| VM decoupling | Publication owns a stable executable/runtime contract; bytecode and call metadata dependencies on Engine/Builder have been inventoried and tested independently. | Changing opcode semantics, interpreter/JIT behavior, or runtime ABI during frontend reconstruction. |

## Scope guard

Builder retirement, candidate construction, transactional publication, unified production cutover, bytecode generation, and VM decoupling require their own proposals and evidence. They must not be added to the task DAGs of the current nine Changes merely because the frontend is designed to enable them.
