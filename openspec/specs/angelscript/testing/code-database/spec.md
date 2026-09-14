# Code database

## Purpose

Provide reusable owned source materials to test modules independently of script execution and consumer protocols.

## Requirements

### Requirement: Owned source materials

The database SHALL expose immutable length-aware source values whose copies own bytes, annotations and origin mappings independently of temporary inputs, Results and database entries.

#### Scenario: Retain exact bytes

- **GIVEN** an owned Source constructed from temporary bytes 61 00 FF
- **WHEN** the input, original Case and Result are released
- **THEN** a retained Source still contains exactly those three bytes

    Invalid UTF-8 and NUL are valid exact-byte source payloads, not container metadata.

### Requirement: Path identity and complete versions

The database SHALL identify files by root-relative slash-normalized Tag without .as and versions by an explicit per-file Tag, storing complete source without parent-based reconstruction.

#### Scenario: Read a sibling directly

- **GIVEN** Language/Counter has full bodies root=int X=0;, left=int X=1; and right=int X=2;
- **WHEN** right is requested after left
- **THEN** right returns int X=2; without changing left

    File Version=v1 describes metadata format, not a source node. Parent and topic metadata do not schedule execution.

### Requirement: Checked material construction

The database SHALL return checked construction results with no partial successful payload when material structure is invalid, while allowing source that would fail language compilation.

#### Scenario: Accumulate independent errors

- **GIVEN** a duplicate version Tag x and an independently empty Summary
- **WHEN** Build finalizes the input
- **THEN** construction fails with both reliably established reasons and no admissible payload

    Source text int X=Missing; with valid metadata instead builds successfully without compiling AS.

### Requirement: Version-aware positional data

The database SHALL store generic positions and half-open ranges in selected clean-source UTF-8 byte coordinates, with author-origin mappings and no consumer execution semantics.

#### Scenario: Remove a point marker

- **GIVEN** source text a/** @point p */b
- **WHEN** generic annotations are parsed
- **THEN** clean source is ab and p has byte offset 1

    The corresponding author position is retained; /** @@point p */ instead emits literal /** @point p */ with no p marker.

### Requirement: Deferred cross-module activation

The database SHALL record static factories without running them and activate the startup provider snapshot through one shared owner after startup module loading completes.

#### Scenario: Execute factories once

- **GIVEN** two loaded provider modules have recorded callbacks
- **WHEN** central activation runs and is subsequently repeated
- **THEN** each factory runs exactly once and repeat activation exposes retained status

    Get before activation fails. A framework loaded after the completion barrier activates immediately rather than waiting for a past event.

### Requirement: Atomic and deterministic batch admission

The database SHALL publish whole registration batches or reject them, retain errors without aborting host startup, and reject conflicting file identities without order-dependent winners.

#### Scenario: Reject both conflicting batches

- **GIVEN** batches A and B both claim Language/Counter while C is valid and unrelated
- **WHEN** activation checks all detached batch identities in either order
- **THEN** A and B are entirely rejected and C remains retrievable

    Malformed batches expose no partial material. Activation complete is distinguishable from a globally error-free catalog.

### Requirement: Reliable exact and filtered queries

The database SHALL distinguish successful precise retrieval and complete enumerations from unknown identities and incomplete global inventories.

#### Scenario: Reject incomplete topic results

- **GIVEN** an unreadable batch prevents knowing its topics while Language/Other is admitted
- **WHEN** a global topic query is made
- **THEN** it fails instead of returning a partial successful list

    Get and within-file enumeration of Language/Other still succeed. In an entirely healthy catalog, zero topic matches is successful empty, while an unknown exact identity is an error.

### Requirement: Checked-in generated original file delivery

The database SHALL obtain authored source containers from deterministic checked-in C++ projections, with one mirrored projection per `.as` file, without runtime author-file fallback, Windows resource identifiers, or implicit generation during ordinary builds.

#### Scenario: Observe a synchronized inventory

- **GIVEN** the author root contains `Language/Counter.as`, the tool subtree may contain test-only `.as` files, and the generated root contains the last synchronized projections

    `CodeGenTool/**` is reserved implementation and test data. It never contributes public FileTags or generated translation units.

- **WHEN** an author runs read-only `check`, edits a source, and then explicitly runs `generate`

    The public commands are `python AngelscriptTestCode/CodeGenTool/codegen.py check` and `python AngelscriptTestCode/CodeGenTool/codegen.py generate`. They resolve repository paths from the tool location rather than the caller's current directory.

- **THEN** the generated root contains exactly one signed, mirrored `.generated.cpp` for each authored `.as`, preserving the authored bytes and extensionless root-relative FileTag

    `Language/Counter.as` becomes `TestCode/Generated/Language/Counter.generated.cpp` and registers `Language/Counter`. Equal projection content is not rewritten.

- **AND** the checked-in translation units register deferred factories through the shared database and parse their bytes only during central activation

    Handwritten C++ providers use the same `FAngelscriptTestCodeRegistration` and remain supported. Query consumers observe the same file/version identities, source bytes, annotations, and authored origin positions regardless of provider style.

- **BUT** missing, changed, stale, colliding, or unsafe output state is never reported as synchronized

    `check` returns failure without mutation. `generate` validates and renders the expected set before writing and deletes only stale signed `.generated.cpp` files beneath the dedicated generated root; other extra files are preserved and reported. Ordinary UBT never invokes Python or scans the author root.
