# One corpus dump and independent comparison

## Context

The user asked whether the handwritten library could be verified by dumping everything and comparing generated .as with original source, and explicitly did not want many unit tests.

## Decision

Use one new C++ dump method for all 47 containers/all versions and one independent Python source-byte comparison. Expected comes from migrated authored clean_source; actual comes from compiled database GetBytes. Retain existing Counter-dependent test coverage through minimal adaptation. Do not add a C++ test per container.

## Oracle and artifacts

Read the current design's Aggregate source round-trip verification contract. Keep Expected.as, Actual.as and Comparison.json beside the actual run log. Whole-library aggregates use identity/byte-length framing and preserve exact source bytes. Legacy rewriting provenance is a separate source record, not byte equality with 624 old wrappers.

## Consequences

Task 7.3 changes its proving command and deliverables while all task IDs and dependency edges remain unchanged. The round-trip helper must reject missing/extra identities and corrupted bytes. No language execution is added. Existing parser tests remain the basis of the clean-source contract.

## Evidence and references

- Current user request in this conversation: reduce tests to whole-library dump/compare.
- Inspected Framework/Catalog/AngelscriptTestCode.h: FindFiles/FindCases enumerate actual registrations.
- Inspected Framework/Source/AngelscriptTestSource.h: GetBytes exposes exact source bytes.
- Existing Python container_parser and ParsedVersion.clean_source supply authored expectations without rendering C++.
- [Current design](../../design.md) and [task 7.3](../../tasks.md).
