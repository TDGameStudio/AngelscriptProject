## ADDED Requirements

### Requirement: Source versions retain one shared UTF-8 body

The common FAngelscriptSource SHALL retain host provenance fields and one FUtf8String body, support preparation-time moves without body copying, and expose its logical path and source text without copying. SDK ingestion MUST retain a prepared shared-const source version rather than allocate another complete body.

#### Scenario: Move an already encoded body

- **GIVEN** an already prepared FUtf8String body and a logical path
- **WHEN** the host moves the body into FAngelscriptSource and submits shared-const references
- **THEN** compiler byte views use the retained body's address and explicit length without another encoding or body allocation
- **AND** host AbsoluteFilename, ModuleName, RelativeFilename, SourceKind, VirtualPath, and readiness fields remain available
- **BUT** moving UTF-8 storage does not imply that FString-to-UTF-8 conversion requires no allocation

#### Scenario: Prepare and publish separate versions

- **GIVEN** default construction creates an unprepared Source
- **WHEN** the host fills its body, marks it ready, and publishes a shared-const reference
- **THEN** the host no longer modifies that version and updates use a new Source object while old consumers retain the old one
- **BUT** shared constness does not automatically freeze another mutable alias

#### Scenario: Preserve raw byte offsets

- **WHEN** input contains BOM, CRLF, multibyte UTF-8, invalid UTF-8, or embedded NUL
- **THEN** offsets and slices refer to the original bytes using explicit length
- **AND** malformed UTF-8 and NUL receive locatable diagnostics rather than silent replacement or strlen truncation

## MODIFIED Requirements

### Requirement: Frontend source coordinates are snapshot-bound UTF-8 byte ranges

The frontend SHALL represent source locations as a compilation-input-local file identity plus a UTF-8 byte offset and ordinary ranges as explicit half-open intervals. A retained shared-source input identity preserves the existing snapshot-bound coordinate semantics without requiring a caller-built snapshot or a second source-body store.

#### Scenario: A valid range selects original bytes

- **GIVEN** a retained compilation input containing one or more immutable shared Source versions

    Each Source owns exact UTF-8 bytes and a logical source key; display text is not indexed storage. Input identity and FileID are index metadata, not copied source content.

- **WHEN** a consumer queries a valid range [begin, end) within one file and input identity
- **THEN** the source manager returns the bytes beginning at begin and ending before end as a view of the original body

    Multibyte UTF-8 characters do not change the meaning of stored byte offsets.

- **AND** line and column can be derived without changing stored locations

    Repeated queries yield the same coordinates and source slice.

#### Scenario: Snapshot identities cannot be mixed

- **GIVEN** two retained compilation inputs with equal local FileID values, even if both retain the same Source object
- **WHEN** a range combines endpoints or provenance from their different input identities
- **THEN** the query fails explicitly instead of selecting bytes under the wrong identity

    Existing SnapshotID fields may keep their spelling; local FileID numeric equality is not ownership equality.

#### Scenario: Escaped results retain source queries

- **GIVEN** AST or compilation output escapes its Builder
- **WHEN** Builder and caller arrays are destroyed while the result remains alive
- **THEN** its required original Source versions, coordinate queries, lazy presentation data, and internal provenance remain valid
- **BUT** per-node provenance pointers or a caller-supplied Origins array are not required

### Requirement: Source provenance is a shared queryable graph

The frontend SHALL keep spelled, transformed, and synthetic source origins in an internally owned, input-scoped graph queryable from source ranges without attaching provenance objects to every AST node or requiring the host to supply that graph.

#### Scenario: A node range is traced to its source origin

- **GIVEN** an AST node stores only its source range
- **WHEN** a tooling or diagnostic consumer asks how that range was produced
- **THEN** the source manager resolves overlapping origin records and returns the ordered origin chain

    Directly spelled source terminates at its owning Source bytes. Transformed or synthetic source identifies its producer and parent range.

- **BUT** the node does not own a preprocessing-record pointer or a per-node source smart pointer

    The root AST or compilation result retains the source/index lifetime once. Existing snapshot-coordinate identity checks remain effective.
