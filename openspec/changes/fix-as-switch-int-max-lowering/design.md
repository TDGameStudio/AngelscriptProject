## Context

The current switch compiler groups nearby labels and may emit a dense jump
table. Before P066-P069, it evaluated `previous + 5`, `maxRange + 5`, and the
dense-table loop in signed `int`. At the upper boundary, addition or increment
could overflow before the comparison decided which lowering path to emit.

The recorded red case used selector/case `2147483643`: overflow excluded the
matching case and emitted an unconditional default path. The current focused
owner additionally executes `INT_MAX - 5`, `INT_MAX - 4`, and a dense set ending
at `INT_MAX`.

## Goals / Non-Goals

**Goals:**

- Prevent signed overflow in range grouping and dense-table emission.
- Preserve correct execution for upper-bound and ordinary switch cases.
- Assign all four mutually dependent compiler hunks to one owner.
- Make rollback and verification evidence indivisible.

**Non-Goals:**

- Widen the AngelScript switch selector or case-label language type.
- Change duplicate-case diagnostics, fallthrough, break, or nesting semantics.
- Refactor general compiler integer arithmetic.

## Decisions

1. Widen only lowering intermediates to `asINT64`. This avoids overflow without
   changing script-visible type rules or bytecode operand width.
2. Keep P066-P069 together. P066/P067 protect the range heuristics; P068/P069
   protect dense iteration and its comparison. Removing any subset reopens an
   upper-bound path.
3. Require runtime execution, not compile-only evidence. The original defect
   successfully compiled but selected the wrong path.
4. Retain lower and middle controls alongside the high-end cells so the
   widening cannot silently change ordinary lowering.

## Risks / Trade-offs

- **[Incomplete widening]** One remaining narrowed intermediate could overflow.
  → Reconcile every arithmetic expression from range grouping through dense
  emission and preserve all four hunks.
- **[Performance-path drift]** Widened heuristics could choose a different
  table shape. → Assert exact runtime selection across sparse and dense
  controls; inspect emitted bytecode when a focused result changes.
- **[False aggregate confidence]** A full SDK pass may not identify the exact
  boundary source. → Require the named focused owner and printed generated
  sources before aggregate evidence.

## Migration Plan

1. Preserve the present four-hunk compiler batch and named regression.
2. Run one coherent editor build.
3. Run the exact Switch owner, the ControlFlow parent, and the complete SDK
   prefix.
4. Record reports, generated-source visibility, termination, exit codes, and
   shutdown state.

Rollback P066-P069 and the high-end boundary controls together. Do not retain a
partial widening.

## Open Questions

None. Fresh final execution is pending.
