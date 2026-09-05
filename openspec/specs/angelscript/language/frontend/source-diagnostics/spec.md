## Purpose

Define the immutable source, location, provenance, and diagnostic contracts shared by every reconstructed AngelScript frontend stage.

## Requirements

### Requirement: Frontend source coordinates are snapshot-bound UTF-8 byte ranges

The frontend SHALL represent source locations as a snapshot-local file identity plus a UTF-8 byte offset and SHALL represent ordinary source ranges as explicit half-open intervals.

#### Scenario: A valid range selects original bytes
- **GIVEN** an immutable source snapshot containing one or more logical files
  > Context: Each file owns exact UTF-8 bytes and a logical source key; display text is not the indexed storage.
- **WHEN** a consumer queries a valid range `[begin, end)` whose endpoints belong to the same file and snapshot
- **THEN** the source manager returns exactly the bytes beginning at `begin` and ending before `end`
  > Observables: Multi-byte UTF-8 characters do not change the meaning of stored byte offsets.
- **AND** line and column may be derived without changing the stored location
  > Verification: Repeated queries produce the same coordinates and source slice.

#### Scenario: Snapshot identities cannot be mixed
- **GIVEN** two snapshots whose local FileID values happen to be equal
  > Details: FileID is only an index inside its owning snapshot; numeric equality does not establish common ownership.
- **WHEN** a range combines an endpoint or origin from one snapshot with the other
- **THEN** the query fails explicitly rather than silently selecting bytes from the wrong source
  > Observables: Debug validation and the public query result identify the ownership mismatch.

#### Scenario: Durable anchors avoid transient process identity
- **WHEN** a source reference must survive serialization or comparison with a later compilation
- **THEN** it is represented by logical source identity, content digest or revision, and local byte range
- **BUT** it contains no pointer, absolute path, `FName` index, line number, or snapshot-local FileID as durable authority
  > Boundaries: Relocation into a new snapshot is explicit and may fail when the source revision is unavailable.

### Requirement: Source presentation data is derived lazily and deterministically

The frontend SHALL retain immutable source bytes as authority and derive display-oriented line and column data only when requested.

#### Scenario: Lexing does not require a line table
- **WHEN** a source snapshot is scanned without any line or diagnostic presentation query
- **THEN** no line-offset table is materialized
- **AND** source ranges remain fully usable for tokens, AST nodes, and diagnostics
  > Verification: A structural test observes that line-map construction remains deferred.

#### Scenario: Concurrent presentation queries agree
- **GIVEN** a frozen snapshot queried by multiple workers
- **WHEN** two workers request line and column data for the same byte offset
- **THEN** they receive identical results from one logically immutable line map
  > Boundaries: Column is defined by the frontend display contract and is not confused with a Unicode terminal-cell width.

### Requirement: Source provenance is a shared queryable graph

The frontend SHALL keep spelled, transformed, and synthetic source origins in a snapshot-owned graph that can be queried from source ranges without attaching provenance objects to every AST node.

#### Scenario: A node range is traced to its source origin
- **GIVEN** an AST node stores only its source range
- **WHEN** a tooling or diagnostic consumer asks how that range was produced
- **THEN** the source manager resolves overlapping origin records and returns the ordered origin chain
  > Observables:
  >
  > - Directly spelled source terminates at its owning file bytes.
  > - Transformed or synthetic source identifies its producer and parent range.
- **BUT** the AST node does not own a preprocessing-record pointer or snapshot smart pointer
  > Boundaries: The root AST or compilation result owns the snapshot lease once.

### Requirement: Frontend diagnostics are structured before rendering

The frontend SHALL report lexer, preprocessing, parsing, and semantic failures through one diagnostic engine using stable identifiers and source-bound structured payloads.

#### Scenario: A diagnostic is captured without a live Engine
- **WHEN** a frontend stage reports an error, warning, note, or remark
  > Inputs: Diagnostic ID, severity, primary range, typed arguments, optional related ranges, and optional fix-its.
- **THEN** a replaceable diagnostic consumer receives the structured record without calling `asCScriptEngine::WriteMessage` or reading `GEngine`
- **AND** human-readable text and line/column presentation can be rendered later from the same record
  > Observables: Tests compare stable fields independently from localized or formatted text.

#### Scenario: Parallel diagnostics have deterministic order
- **GIVEN** multiple frontend fragments report diagnostics independently
- **WHEN** the compilation session finalizes its diagnostic sequence
- **THEN** records are ordered by stable source identity, byte range, severity precedence, diagnostic ID, and a deterministic local sequence tie-breaker
  > Verification: One-worker and multi-worker executions produce the same serialized diagnostic sequence.
