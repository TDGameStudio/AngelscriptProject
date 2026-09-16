# One readable source dump per generator

## Context

The user clarified that individual-case files are too numerous and requested all cases in one .as file per generator, with careful generator-owned code formatting. This supersedes the preceding per-case export decision while retaining its run-local ownership and one-test-per-generator arrangement.

## Evidence

There are 122 products and 36,686 declared cells. Exporting by cell would create tens of thousands of files. BuildAllSource already provides a non-reject aggregate, while negative cases need independent module boundaries to preserve their intended rejection semantics.

## Options

Per-case files conflict with the clarified request. An aggregate-only file loses rejected cases. A full inspection dump with a normal/fault aggregate and clearly separated negative modules retains every case in one readable product file.

## Settled Decision

Add BuildDumpSource to every generator. It owns all formatting, inline metadata and full case composition. The sole product test writes one GeneratedCases/<ClassWithoutF>.as beside the actual run log, with no product subfolder or JSON sidecar. ListCases and BuildCaseSource remain the actual consumer interfaces. Dumps containing rejects explicitly state that they are not one compilable module.

## Consequences

One full run produces 122 product .as artifacts instead of 36,686 case files. Shared aggregate helpers appear once; reject modules remain self-contained. Tests compare complete case membership and independently reviewed layout samples, write the dump before aborting assertions, and preserve it on later failure. Runtime artifacts are not checked-in gold or implementation files.

## Flip Condition

A complete product dump cannot represent a required source unit without ambiguity. Resolve the source boundary with evidence; do not silently omit cases or return to per-case files without a changed user requirement.

## Sources

[Current design](../../design.md), [task plan](../../tasks.md), [inventory](../data/product-inventory.md), and the user's latest single-file and formatting clarification.
