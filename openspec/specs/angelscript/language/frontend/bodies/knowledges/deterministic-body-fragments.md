# Analyze bodies as frozen-input deterministic fragments

## Status

Accepted. The body capability proves equal semantic projections for one-worker and four-worker requests, reversed source inputs, and recovery across multiple functions.

## Rule

After declarations are frozen, treat each eligible function body as an isolated semantic work item. Give it read-only declaration/source services and bounded Parser, Sema, AST, diagnostic, and lifetime state. Merge completed body fragments by stable semantic order, never by completion order.

## Why it matters

Function bodies have high parallel potential, but sharing mutable lookup tables, AST identity, diagnostic sinks, or runtime registries makes scheduling observable. Freezing declarations first makes ordinary call/type lookup read-only. Fragment isolation confines recovery while deterministic attachment restores one coherent compilation result.

## Reusable shape

1. Create a deferred body descriptor from a valid canonical function declaration and immutable source range.
2. Parse and type the body against the frozen declaration environment.
3. Represent conversions, value categories, control targets, and cleanup obligations explicitly in the concrete typed AST.
4. Return a fragment with diagnostics and source-language lifetime facts.
5. Attach fragments by stable function key and source order.
6. Mark error-bearing bodies inspectable but non-executable.

## Recovery invariant

Every failed parse consumes a token or exits the current construct. Typed recovery nodes retain source structure but never acquire valid executable meaning. A failed body cannot suppress independent diagnostics from later bodies.

## Anti-patterns

- Resolving a call through a live Engine runtime function ID.
- Letting body workers add declarations or mutate overload sets.
- Encoding cleanup only as bytecode emitted during parsing.
- Sorting results by thread ID, address, atomic sequence, or completion order.

## Verification

- Final corrective build 1549860d7e2c416fb4d046654069125c compiled the body semantic/lifetime units and compact shared AST representation.
- Focused run c5586e74431142fc83eeb7c8b6fce687 passed 13/13 Bodies tests with zero warnings, errors, failures, or skips.
- Adjacent shared-AST run 297960d708b54c50913f6d77af8d7ed9 passed 30/30 tests with zero warnings, errors, failures, or skips.

## Applicability boundary

This pattern applies when body semantics depend only on a frozen declaration universe plus immutable source/configuration. Whole-program optimization, runtime publication, backend lowering, bytecode, JIT, and VM execution remain separate graph boundaries.
