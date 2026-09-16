## Purpose

Provide reusable deterministic Language source generators independently of runtime execution.

## ADDED Requirements

### Requirement: Complete Language generator inventory

The generator library SHALL provide every accepted Language product as a directly constructible specialized C++ generator with deterministic source for every declared cell.

#### Scenario: Complete initial catalog

- **WHEN** the complete accepted catalog is enumerated through its source APIs
- **THEN** all 122 products and 36,686 distinct product cells are represented
- **AND** the existing 24-cell ForLoop product is included once

### Requirement: Separate source dispositions

The generator library SHALL keep compile-rejection sources separate from its non-reject aggregate modules and distinguish normal-return observations from runtime faults.

#### Scenario: Transfer validity partition

- **WHEN** the transfer-validity product generates its aggregate and reject sources
- **THEN** the aggregate contains exactly SWITCH-BREAK, LOOP-BREAK and LOOP-CONTINUE with observations 3, 3 and 5
- **AND** FUNCTION-BREAK, FUNCTION-CONTINUE, BRANCH-BREAK, BRANCH-CONTINUE and SWITCH-CONTINUE each have a separate reject module

#### Scenario: Rejection-only product

- **WHEN** the registered-funcdef product is enumerated
- **THEN** the aggregate is empty with count zero and all six declared cases are available as individual reject sources

### Requirement: Deterministic owned source

The generator library SHALL return owned source strings with stable CaseIds, entry names, ordering and formatting, with no mutable cross-call state.

#### Scenario: Repeat generation

- **GIVEN** the same product and typed parameters
- **WHEN** generation is repeated after another case was generated
- **THEN** bytes, IDs and counts match the original output
- **AND** single-case entry names default to Entry while aggregate entry names derive deterministically from CaseId

#### Scenario: Invalid new-product request

- **WHEN** a new generator receives an unknown CaseId, an invalid axis value or a reject combination through its positive-only source builder
- **THEN** it returns empty source without a partial successful module

### Requirement: Explicit observation limits

The generator library SHALL retain each product's documented observation domain, host dependencies and lifecycle-source boundaries without presenting generator-only checks as runtime proof.

#### Scenario: ABI observation

- **WHEN** ConvAbi source and its int32 expected observation are requested
- **THEN** the source retains the required native declarations and the integer observation retains its direction-marker meaning
- **BUT** that marker alone does not establish the native ExpectedBits observation

#### Scenario: Lifecycle source variant

- **WHEN** a property-rebuild second-version source variant is generated
- **THEN** its declared identity and second-version source are available
- **BUT** generation does not execute rebuild, save/load or old-handle cleanup


### Requirement: Consumer-addressable case descriptors

Every generator SHALL expose an owned ordered descriptor for each canonical cell with CaseId, callable entry declaration where applicable, expected outcome and execution support, together with source generation by CaseId.

#### Scenario: Enumerate and locate every LoopDepth entry

- **WHEN** a consumer calls ListCases on LoopDepth
- **THEN** it receives all 48 canonical case descriptors in axis order
- **AND** the FOR-ONE-BREAK row names int EntryLangCfLoopDepthForOneBreak(), declares ReturnValue, and has ExpectedReturn set to 110
- **AND** that declaration identifies the same case in both aggregate and canonical single-case source

#### Scenario: Distinguish valid zero from absent case

- **WHEN** a consumer enumerates a normal-return case whose expected observation is zero and requests source for UNKNOWN-CASE
- **THEN** the real case carries a populated zero expectation and the unknown source request returns empty
- **BUT** zero from the legacy GetExpected fallback cannot establish membership

#### Scenario: Enumerate rejection-only output

- **WHEN** a consumer lists RegisteredFuncdef cases
- **THEN** it receives all six CompileReject descriptors with empty callable declarations and no integer or exception expectation
- **AND** each listed ID produces independent nonempty reject source although the aggregate has zero entries

#### Scenario: Classify execution support before dispatch

- **WHEN** a consumer reads an ABI case, a lifecycle-only source variant and a standalone divide-by-zero case
- **THEN** the ABI row declares RequiresHostSetup, the lifecycle row declares SourceOnly, and the fault row has RuntimeException with exact Divide by zero text and no integer expectation
- **AND** non-standalone or limited observations explain their requirements in ExecutionNotes
- **BUT** a generic consumer cannot count unsupported or skipped cases as passed

#### Scenario: Own descriptors independently

- **WHEN** a caller retains or changes a returned descriptor list and then enumerates again
- **THEN** retained source and generator-produced identities, ordering and expected observations remain independent


### Requirement: Readable canonical entry names

Generators SHALL retain stable CaseIds while deriving canonical function names by prefixing Entry to the PascalCase conversion of every hyphen/underscore-separated CaseId token, retaining digits and emitting no underscores.

#### Scenario: Name a multiword loop case

- **WHEN** LANG-CF-LOOP-DEPTH-DO_WHILE-ZERO-BREAK is generated
- **THEN** its callable entry is int EntryLangCfLoopDepthDoWhileZeroBreak() in both its descriptor and source
- **AND** its original CaseId remains unchanged

#### Scenario: Detect name collision

- **WHEN** distinct canonical IDs would map to the same canonical entry name
- **THEN** the product contract check fails before the ambiguous identity is accepted

### Requirement: Complete generator test exports

Each generator SHALL have one unit test entry that verifies and writes all of its canonical cases in exactly one readable .as dump beside the current test log, with the generator owning source composition and formatting.

#### Scenario: Inspect all loop sources in one file

- **WHEN** LoopDepth's GeneratesAndExportsAllCases test runs under Harness
- **THEN** the directory containing that run's Unreal.log has GeneratedCases/LoopDepthGenerator.as with all 48 labeled case sections and aggregate helpers emitted once
- **AND** its bytes equal BuildDumpSource encoded as UTF-8 without BOM with LF line endings
- **BUT** the test creates no per-case source files or JSON sidecar

#### Scenario: Inspect mixed and rejected source units

- **WHEN** TransferValidity and RegisteredFuncdef generator tests export their dumps
- **THEN** TransferValidityGenerator.as contains 3 non-reject entries and 5 independently delimited reject modules, and the registered-funcdef dump contains all 6 reject modules
- **AND** each mixed or reject-only dump explicitly states that it is an inspection file rather than one compilable module

#### Scenario: Retain inspection output after verification failure

- **WHEN** an assertion fails after a generator dump was written
- **THEN** the test reports failure and retains that product's dump with its path in the log
- **BUT** another product or run's output is not deleted

### Requirement: Generator-owned source formatting

All generator source APIs SHALL produce stable readable AS with tab indentation, Allman braces, one statement per line, LF line endings, a final newline, no trailing whitespace and one blank line between adjacent top-level declarations/functions.

#### Scenario: Repeat a nested source dump

- **WHEN** a nested-loop generator dump is requested twice with unchanged inputs
- **THEN** bytes match, nested blocks use consistent tab indentation, braces are on their own lines and each case starts with a separate CaseId comment
- **AND** the file exporter writes those bytes without reformatting the source
