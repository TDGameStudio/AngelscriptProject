# Expose cases to execution consumers

## Context

BuildAllSource returned only source and count. Consumers could not discover normal/fault IDs without duplicating enumeration or inspecting source. GetExpected returned zero for an unknown ID, making a scalar lookup insufficient to establish validity. The user explicitly requested correcting this gap after discussing how to run generated entries.

## Evidence

Inspected Framework/Generate/AngelscriptTestForLoopGenerator.h exposes GetProductId, BuildAllSource, BuildForSource and GetExpected; no case enumeration exists. The accepted task plan replicated that gap across all 122 products. Current source generation includes rejects, faults, ABI dependencies and lifecycle-source variants, so a list of names alone is insufficient for correct dispatch.

## Options

- Parse source or duplicate axis tables in execution callers: fragile and lacks typed outcome/support information.
- Return only CaseIds: improves discovery but still forces callers to reconstruct declarations, expectations and failure classes.
- Return owned case descriptors and support canonical single-case generation: selected; it supplies consumer data without a registry, common virtual base or runtime executor.

## Settled Decision

ListCases supplies identity, exact callable declaration, typed outcome, optional integer or exception expectation and explicit execution support. BuildCaseSource maps canonical IDs to isolated source. Data types are shared; enumeration and generation remain in product subclasses. The existing aggregate, typed builders and compatibility methods remain.

## Consequences

ForLoop task 1.1 establishes the shared header with a real producer; other products depend on it. The final corpus proof consumes descriptors rather than reconstructing actual enumeration. Independent expected tables remain essential for tests. Metadata describes execution intent but does not run the language engine.

## Flip Condition

A real execution consumer demonstrates that the descriptor cannot identify or classify an accepted generated case. Record evidence and revise the contract without silently removing products or introducing runtime work into source-generation verification.

## Sources

[Current design](../../design.md), [task plan](../../tasks.md), and the user case-enumeration correction in the current session. The original handoff remains source-generation-only.
