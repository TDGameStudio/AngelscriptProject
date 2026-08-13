## ADDED Requirements

### Requirement: The native Language Service owns resident shared state
The Standalone Language Service SHALL initialize and retain one validated AngelScript engine, registration surface, adapter registry, selected profile index, and document table for its lifetime. Updating a document SHALL NOT recreate the global engine or replay the complete registration surface.

#### Scenario: Multiple edits are analyzed
- **WHEN** one document is opened and updated repeatedly
- **THEN** the service SHALL reuse its initialized engine and profile index
- **AND** it SHALL rebuild only document/module state invalidated by the update

#### Scenario: Service is disposed
- **WHEN** the owner calls `dispose`
- **THEN** all documents, modules, observers, engine state, and profile resources owned by the service SHALL be released exactly once

### Requirement: Documents are URI- and version-controlled
The service SHALL identify each document by URI and caller-supplied monotonically increasing version. V1 updates SHALL replace the complete document text. Analysis, completion, and outline results SHALL echo the requested version, and stale work SHALL never replace a newer result.

#### Scenario: New version supersedes pending analysis
- **WHEN** version 4 is submitted while analysis of version 3 is pending
- **THEN** a version-3 result MAY finish but SHALL be marked stale or discarded
- **AND** it SHALL not become the current result for the document

#### Scenario: Non-increasing update is submitted
- **WHEN** an update version is equal to or lower than the current document version
- **THEN** the service SHALL reject it with a structured version error
- **AND** it SHALL preserve the current document state

#### Scenario: Closed document receives a request
- **WHEN** analysis, completion, or outline is requested after `closeDocument`
- **THEN** the service SHALL return a structured missing-document error and no stale payload

### Requirement: Analysis combines compiler and shared static diagnostics
`analyze` SHALL compile/analyze the current document against the selected profile and return profile identity, document version, compiler diagnostics, shared static diagnostics, rule-set identity, completeness, and deterministic class information. Compiler and static diagnostic fatality SHALL remain distinct.

#### Scenario: Valid example is analyzed
- **WHEN** a valid document uses only supported profile declarations
- **THEN** analysis SHALL return the matching version and profile identity
- **AND** compiler diagnostics SHALL be empty while applicable shared diagnostics and class information remain available

#### Scenario: Compile error prevents dependent lint
- **WHEN** compilation cannot produce the facts required by a static rule
- **THEN** analysis SHALL return the compiler error
- **AND** it SHALL apply the shared cascade-suppression contract

### Requirement: Lightweight completion is bounded to the active example and profile
`complete` SHALL return AngelScript keywords/specifiers, declarations visible in the current document, and visible types/members/functions from the selected profile. It SHALL use the cursor context and SHALL NOT claim project-wide indexing, automatic imports, rename, or cross-project source knowledge.

#### Scenario: Member completion is requested
- **WHEN** the receiver type before `.` or `::` is resolved in the current document or profile
- **THEN** completion SHALL return only visible compatible members with stable label, kind, signature, and source identity

#### Scenario: Receiver type is unknown in a partial profile
- **WHEN** the service cannot resolve the receiver under the selected partial profile
- **THEN** it SHALL return no fabricated member list
- **AND** the response SHALL retain the partial-profile identity

#### Scenario: Completion result exceeds the configured limit
- **WHEN** candidate count exceeds the service limit
- **THEN** the service SHALL return a deterministically ranked bounded prefix and an explicit incomplete flag

### Requirement: Class outline is a static semantic description
`getClassOutline` SHALL return declared class name, base declarations, properties, functions, declaration flags, source ranges, and related diagnostics for the current version. It SHALL identify the output as static analysis and SHALL NOT claim or create a UE UClass.

#### Scenario: Actor-like class is outlined
- **WHEN** a document declares an Actor-derived script class with properties and functions
- **THEN** the outline SHALL preserve the declared base, members, flags, and source ranges
- **AND** it SHALL contain no UObject pointer, property offset, CDO, generated-class address, or runtime instance

#### Scenario: Declaration is incomplete
- **WHEN** a compiler error prevents a complete class model
- **THEN** the outline SHALL either return the proven partial declarations with completeness metadata or no outline
- **AND** it SHALL not fabricate missing members

### Requirement: Existing Standalone CLI behavior remains compatible
Existing `as-standalone` native-runtime and ue-validation commands SHALL call the shared service/compiler implementation without changing established profile selection, complete-bundle replacement, exit codes, deterministic artifacts, execution limits, or safety boundaries unless an explicit new language-service command is selected.

#### Scenario: Existing UE validation command runs
- **WHEN** a current supported CLI invocation is executed after the refactor
- **THEN** its normalized outcome, selected bundle identity, exit code, and deterministic artifacts SHALL match the pre-service contract

#### Scenario: Existing native runtime command runs
- **WHEN** the bounded native-runtime profile is selected
- **THEN** its existing execution allowlist and resource limits SHALL remain unchanged
- **AND** browser Language Service code SHALL not be involved

### Requirement: The Language Service never executes UE-validation documents
Analysis, completion, and outline operations SHALL be compile/analyze-only. They SHALL NOT execute script functions, invoke registration traps, expose bytecode for execution, call filesystem/network/process APIs, or simulate Unreal runtime state.

#### Scenario: Source contains an executable entry function
- **WHEN** the function compiles during a Language Service request
- **THEN** no script context SHALL execute it
- **AND** the response SHALL contain only analysis-oriented results

#### Scenario: Registered UE callable is referenced
- **WHEN** analysis resolves a callable represented by a non-executable offline declaration
- **THEN** the service MAY use its signature for checking and completion
- **AND** it SHALL never invoke its trap or fabricate a runtime return value

### Requirement: Service errors and limits are structured
The service SHALL apply configured bounds to document bytes, open-document count, diagnostics, completion candidates, analysis time, and memory-relevant inputs. Limit, profile, version, and lifecycle failures SHALL use stable structured error codes and SHALL leave other documents usable.

#### Scenario: Oversized document is opened
- **WHEN** source bytes exceed the configured document limit
- **THEN** the operation SHALL fail before compilation with a stable limit error
- **AND** existing documents SHALL remain valid

#### Scenario: One document analysis fails internally
- **WHEN** an internal analysis error is contained to one document
- **THEN** the service SHALL clear invalid transient state for that document
- **AND** it SHALL remain able to analyze another valid document or report that the service itself is unusable

### Requirement: Native results use editor-neutral UTF-16 positions
All public document positions and ranges SHALL be zero-based UTF-16. A shared tested mapper SHALL convert maintained-fork and frontend UTF-8/row/column observations without splitting surrogate pairs or misreading CRLF.

#### Scenario: Mixed newline and Unicode source is analyzed
- **WHEN** source contains CRLF, LF, BMP characters, and non-BMP characters before a diagnostic or completion position
- **THEN** analysis and completion SHALL identify the same source span expected by LSP and CodeMirror clients
