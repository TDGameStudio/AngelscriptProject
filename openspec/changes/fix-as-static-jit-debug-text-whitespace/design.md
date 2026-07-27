## Context

The formatter builds an opcode label plus a separator before appending
operand-dependent text. Operand-bearing instructions consume the separator;
no-operand instructions do not. P019 applies `Out.TrimEndInline()` once after
all rendering branches, so only trailing horizontal whitespace is removed.

The comprehensive coverage change records `JIT-004`, a completed AOT sequence
with 10/10 automation and a literal scan that found no trailing-whitespace
lines. That evidence predates this linked record and is retained as historical
support, not represented as fresh final verification for this change.

## Goals / Non-Goals

**Goals:**

- Make instruction debug strings deterministic for operand and no-operand
  instructions.
- Assign P019 to one exact root-cause owner.
- Preserve a focused generated-output regression and a literal artifact scan.
- Define an indivisible source/regression rollback boundary.

**Non-Goals:**

- Change bytecode execution, encoding, or optimizer behavior.
- Redesign StaticJIT diagnostics, log routing, or command interfaces.
- Reformat unrelated generated C++ or AOT fixture content.

## Decisions

1. Normalize once at formatter return. This covers every opcode path without
   duplicating per-opcode conditions. A branch-specific special case was
   rejected because future no-operand opcodes could repeat the defect.
2. Own only P019. Nearby StaticJIT reference-copy and lifecycle hunks have
   different semantic owners.
3. Treat `GeneratedOutputVerify` plus a literal generated-file scan as the
   regression contract. A successful compile alone cannot prove absence of
   trailing whitespace.
4. Retain historical `JIT-004` evidence but require a fresh linked run before
   this change's final verification can close.

## Risks / Trade-offs

- **[Over-normalization]** A future operand intentionally ending in whitespace
  would also be trimmed. → Instruction debug text has no contract for
  significant terminal whitespace; assert exact representative strings.
- **[Stale generated artifact]** A scan can pass without regeneration. → Pair
  the scan with the documented AOT generation/build/automation workflow.
- **[False behavioral scope]** Formatting repair may be mistaken for VM
  semantics. → Keep P019 isolated and exclude opcode/runtime hunks.

## Migration Plan

1. Preserve the existing P019 source line and regression owner.
2. Run the focused StaticJIT AOT workflow and literal artifact scan.
3. Record report paths, generated-file identity, exit codes, and scan count in
   `verification.md`.
4. Run strict OpenSpec and scoped whitespace checks.

Rollback P019 and the exact formatting assertion together. Regenerated fixture
updates caused solely by this normalization belong to the same rollback.

## Open Questions

None. The remaining work is fresh verification, not design discovery.
