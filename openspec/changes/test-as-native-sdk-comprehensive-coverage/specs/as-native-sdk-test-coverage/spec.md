## REMOVED Requirements

### Requirement: Native SDK 4 layers SHALL each have themed white-box unit test coverage
**Reason**: Four frontend/compiler layers and file-count minimums are not a complete native SDK or core-language boundary.
**Migration**: Use the nine native domains, explicit language catalogs, implementation/API inventories, and source-derived combination closure in this change.

### Requirement: Native SDK tests SHALL register under the existing AngelscriptNative group without configuration changes
**Reason**: The stable root remains useful, but the old four-layer naming and frozen configuration statement no longer describe the reorganized suite.
**Migration**: Keep `Angelscript.TestModule.AngelScriptSDK` stable and use domain/theme/micro-contract prefixes defined by the new architecture.

### Requirement: Existing native SDK tests SHALL remain green after each phase
**Reason**: The frozen 17-test baseline and per-phase build loop are obsolete and conflict with the requested low-frequency batch workflow.
**Migration**: Preserve meaningful existing behavior through reconciliation, then build after coherent implementation stages and execute focused/final prefixes after the final code batch.

### Requirement: Native SDK tests SHALL share helpers via AngelscriptNativeTestSupport.h
**Reason**: The helper surface was already reorganized and a single umbrella name is not a completeness requirement.
**Migration**: Keep narrow shared support ownership, stable documented compatibility includes, and scenario logic visible in CQTest owners.

### Requirement: Native SDK tests SHALL respect project test conventions and inline AS formatting rules
**Reason**: The archived requirement contains the obsolete column-zero rule and does not cover the current preserve-lines exception/audit contract.
**Migration**: Use the updated formatting and CQTest requirement below.

### Requirement: Native SDK test coverage SHALL document its current scale in the test catalog
**Reason**: Fixed 151-new and 301/301 snapshots are historical and can falsely imply completeness.
**Migration**: Generate fresh source/test/domain/combination/pass totals while keeping semantic closure authoritative.

### Requirement: SDK namespace consolidation SHALL stay separate from SDK behavior coverage expansion
**Reason**: Namespace cleanup is complete; this change directly addresses the behavior deficit discovered after the structural refactor.
**Migration**: Preserve the historical changes and use this change for comprehensive behavior closure.

### Requirement: Native SDK behavior coverage SHALL respect the bare-engine boundary
**Reason**: The boundary remains valid but must include native debug and explicit add-on/UE integration exclusions.
**Migration**: Use the strengthened raw-boundary requirement below.

### Requirement: Native SDK tests SHALL use SDK naming and explicit behavior boundaries
**Reason**: SDK naming is established; the remaining need is concrete subject naming, classification, and combination evidence.
**Migration**: Use descriptive domain/theme/micro-contract ownership and the new current-fork/2.38 classification contract.

## ADDED Requirements

### Requirement: Native SDK completeness SHALL be proven from source-controlled coverage IDs
The suite SHALL reconcile every language combination, public API family, vendored implementation unit, internal class, native domain scenario, inherited predecessor scenario, formatting item, and cross-theme chain to an implemented/verified test or explicit approved disposition.

#### Scenario: Complete audit runs
- **WHEN** the source-derived complete audit is executed
- **THEN** expected and implemented coverage IDs SHALL match exactly after approved exclusions, API-deferred rows, and Disabled selected-2.38 rows
- **AND** missing, duplicate, unknown, owner-mismatched, or evidence-incomplete IDs SHALL fail the audit

#### Scenario: Counts are high but a row is missing
- **WHEN** source lines or test definitions reach any reported scale while a required ID remains open
- **THEN** the change SHALL remain incomplete

### Requirement: The predecessor depth deficit SHALL be closed without rewriting history
All 197 missing exact scenarios identified from `refactor-as-native-sdk-regression-suite` SHALL be implemented, superseded by stronger named combinations, or assigned a concrete corrected disposition. The predecessor directory SHALL remain unchanged as the historical record.

#### Scenario: An inherited scenario name is absent
- **WHEN** a predecessor scenario does not exist under its exact old method name
- **THEN** the new reconciliation record SHALL identify one or more final coverage IDs that supersede it or a precise reason it was invalid
- **AND** an unreferenced deletion or silent rename SHALL fail completion

### Requirement: All nine native domains SHALL have behavior-depth catalogs and evidence
Engine, Frontend, Compiler, Runtime, Module, TypeSystem, Language, Embedding, and Conformance SHALL cover public contracts, internal implementation behavior, valid/boundary/invalid inputs, runtime results, lifecycle/cleanup, interactions, isolation, and fork/upstream classification as applicable.

#### Scenario: A domain has files and passing tests but missing dimensions
- **WHEN** one applicable depth dimension lacks a coverage ID, test owner, or specific non-applicability reason
- **THEN** the domain SHALL remain incomplete regardless of its pass count

#### Scenario: Internal behavior has a public observation
- **WHEN** a compiler/runtime internal operation produces bytecode, metadata, diagnostics, execution, or lifecycle effects
- **THEN** direct internal assertions SHALL be correlated with at least one public/raw-engine observation

### Requirement: Native tests SHALL obey current CQTest and inline-AS rules
All added or modified native SDK tests SHALL follow `Documents/UnitTest/UnitTest.md` and `Documents/Rules/ASInlineFormattingRule.md`, including registration gates, class/method structure, matcher assertions, raw ownership, exact lookup, and formatted `ASTEST_AS_ANSI` fixtures.

#### Scenario: An ordinary inline script is inspected
- **WHEN** a native test embeds buildable/executable AngelScript
- **THEN** it SHALL use a named, visually indented `ASTEST_AS_ANSI(R"AS(...)AS")` source with Allman braces and required blank lines
- **AND** neither content nor closing delimiter SHALL begin at column zero
- **AND** escaped newline concatenation SHALL not be used

#### Scenario: A line-sensitive fixture is inspected
- **WHEN** token offsets, diagnostics, debug markers, or row/column conversion require exact layout
- **THEN** the fixture SHALL use an approved preserve-lines wrapper or explicit exact-fragment form
- **AND** an adjacent reason and expected position evidence SHALL appear in the test

### Requirement: Native SDK tests SHALL use descriptive, localizable ownership
Files, classes, methods, and automation prefixes SHALL name the concrete subject and expected contract. Large products SHALL be split by semantic ownership, and batched cells SHALL remain independently identifiable.

#### Scenario: A repetitive product is batched
- **WHEN** one `TEST_METHOD` executes multiple tightly related cells
- **THEN** every cell SHALL report a stable coverage ID, expected/actual evidence, and exact declaration
- **AND** the method SHALL not report only an aggregate count

#### Scenario: A source becomes too broad to review
- **WHEN** unrelated semantic contracts or multiple failure domains accumulate in one translation unit
- **THEN** the source SHALL be split into descriptive owners before completion

### Requirement: The raw native boundary SHALL exclude add-ons and UE debugger integration
The suite SHALL test core AngelScript and fork-native APIs with minimal local registrations. It SHALL NOT use SDK add-ons, `FAngelscriptEngine`, Worlds, Actors, UE reflection fixtures, DebugServer/DAP, editor debugging, or VS Code integration as evidence for raw SDK behavior.

#### Scenario: A core scenario needs an iterable or object fixture
- **WHEN** core syntax needs host behavior to execute
- **THEN** the test SHALL register the smallest case-owned native fixture required by the raw SDK contract
- **AND** it SHALL NOT register an add-on package

#### Scenario: A UE-dependent scenario is found
- **WHEN** the behavior requires a UE wrapper or debugger integration
- **THEN** it SHALL be mapped to the owning non-SDK test layer and excluded from native completion totals

### Requirement: Current fork and selected 2.38 expectations SHALL remain singular and separate
Enabled tests SHALL assert one authoritative current-fork outcome. Expressible but unsupported selected-2.38 targets SHALL be real compiled Disabled tests tagged `#as-v238-backport`; targets with absent public APIs SHALL be recorded as API-deferred.

#### Scenario: Current and future behaviors conflict
- **WHEN** the fork rejects or differs from a selected 2.38 behavior
- **THEN** one enabled test SHALL assert the current result
- **AND** a separate Disabled/tagged test MAY assert the desired target
- **AND** no test SHALL accept either outcome

### Requirement: Scale SHALL inform decomposition but SHALL NOT be a quota
The plan SHALL accommodate thousands of independently identifiable combinations without imposing a physical test-source line target; completion remains determined by semantic reconciliation and verification.

#### Scenario: Implementation is below or above the scale premise
- **WHEN** all required IDs and evidence pass
- **THEN** physical line count SHALL NOT block completion
- **AND** code SHALL NOT be duplicated merely to reach a target line count

### Requirement: Validation SHALL use low-frequency coherent stages
Implementation SHALL complete a large coherent stage before building, complete all planned code before the final integration build, batch related fixes, and then run static audits, focused domain/theme prefixes, the full SDK prefix, `NativeCore`, and the full suite in the documented order.

#### Scenario: A single test file is written
- **WHEN** its larger coherent stage is still incomplete
- **THEN** a build SHALL NOT be triggered solely for that file unless a blocking compile-risk characterization is documented

#### Scenario: Final verification starts
- **WHEN** all planned implementation and static reconciliation are complete
- **THEN** the final integration build SHALL run before automation tests
- **AND** failures SHALL be diagnosed and fixed in batches before rebuilding/retesting
