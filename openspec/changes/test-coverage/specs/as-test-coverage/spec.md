## ADDED Requirements

### Requirement: Coverage Test Coverage Is Recorded In OpenSpec Through Unified Matrices

AngelScript `AngelscriptTest/Coverage/` test coverage SHALL be recorded in OpenSpec through unified matrices, using actual test code as the single authoritative source. `Documents/Coverage/` SHALL no longer be the source of truth for coverage records.

#### Scenario: Matrix Uses Code As The Authoritative Source

- **GIVEN** `AngelscriptCoverage*Tests.cpp` test files exist under the Coverage directory
- **WHEN** a coverage status is recorded for a topic
- **THEN** the status is based on actual `TEST_METHOD`s and Automation prefixes present in the test file
- **AND** it is not based on optimistic or outdated historical planning documents

#### Scenario: Coverage Status Uses Explicit State Categories

- **GIVEN** a Coverage topic
- **WHEN** its status is marked in the matrix
- **THEN** it MUST be one of covered (✅), partially covered (🟡), pending (⬜), or fork unsupported / not applicable (🚫)
- **AND** fork-unsupported items need to document the replacement pattern or boundary test location

#### Scenario: Matrix Format Is Unified

- **GIVEN** a coverage entry under any category
- **WHEN** it is presented as a table
- **THEN** the column structure is unified as `Topic | Test File | Method Count | Status | Notes`
- **AND** the same legend markers are used throughout the record

#### Scenario: Matrices Are Split By Domain And Aggregated By Main Index

- **GIVEN** coverage records span multiple AS types and feature systems
- **WHEN** matrix files are organized
- **THEN** detailed matrices SHALL be split by AS type / feature area into multiple files under `matrices/`, with each file corresponding to a group of test files and large feature systems documented independently
- **AND** `coverage-matrix.md` SHALL serve as the main index, maintaining the unified legend, column definitions, domain index, and global summary
- **AND** per-domain matrix file counts and method counts SHALL sum to the global summary

#### Scenario: Domain Matrix Rows Are Scenario-Level And Guide Implementation

- **GIVEN** a domain matrix file
- **WHEN** coverage for that domain is recorded
- **THEN** matrix rows SHALL be **specific verifiable scenarios** or usage patterns rather than only listing test files
- **AND** each ✅ scenario row SHALL identify the `TEST_METHOD` that asserts it, using `File::Method` when the method is in another file
- **AND** uncovered scenarios SHALL be explicitly listed as ⬜ rows, serving as pending implementation work items
- **AND** fork-unsupported patterns SHALL be recorded as 🚫 rows with their negative boundary test location
