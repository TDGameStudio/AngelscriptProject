# Candidate Knowledge: Analyze bodies as frozen-input deterministic fragments

## Status

Promoted to `openspec/specs/angelscript/language/frontend/bodies/knowledges/deterministic-body-fragments.md` after the Bodies implementation proved semantic equivalence for one-worker and four-worker requests, reversed input, and recovery across multiple functions.

## Rule

After declarations are frozen, treat each eligible function body as an isolated semantic work item. Give it read-only declaration/source services and local Parser, Sema, AST storage, diagnostics, and lifetime facts. Merge completed body fragments by stable semantic order, never by completion order.

## Why it matters

Function bodies usually have high parallel potential, but sharing mutable lookup tables, AST arenas, diagnostic sinks, or runtime registries turns scheduling into observable behavior. Freezing declarations first makes ordinary call/type lookup read-only. Fragment isolation then confines recovery and allocation while deterministic merge restores one coherent compilation result.

## Reusable shape

1. Create a deferred body descriptor from a valid canonical function declaration and immutable source range.
2. Parse and type the body against the frozen declaration environment.
3. Represent conversions, value categories, control targets, and cleanup obligations explicitly in the concrete typed AST.
4. Return a fragment with local identities and structured diagnostics.
5. Attach and remap fragments by stable function key, source range, and local ordinal.
6. Mark error-bearing bodies inspectable but non-executable.

## Recovery invariant

Every failed parse consumes a token or exits the current construct. Typed recovery nodes retain source structure, but they never acquire a valid executable meaning. A failed body cannot suppress independent diagnostics from later bodies.

## Anti-patterns

- Resolving a call by asking the live Engine for a runtime function ID.
- Letting body workers add declarations or mutate overload sets.
- Using one shared Sema or arena with locks around every node creation.
- Encoding cleanup only as bytecode emitted during parsing.
- Sorting results by thread ID, allocation address, atomic sequence, or future completion order.

## Evidence

- `as_parser.cpp:4234-4251` shows current per-script parsing immediately triggers deferred semantic checks, before a new whole-session phase boundary exists.
- `as_compiler.h:245-257` and `as_compiler.cpp:86-126` show executable compilation tied to Builder and Engine.
- [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 2315-2317 records the user's request to separate Builder/Engine work and batch output later.

## Applicability boundary

This pattern applies when body semantics depend only on a frozen declaration universe plus immutable source/configuration. Whole-program optimizations, runtime publication, backend lowering, and VM execution may need different graph boundaries and must not be smuggled into body fragments.
