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

The database SHALL identify files by root-relative slash-normalized Tag without .as and versions by an explicit per-file Tag, storing complete source without parent-based reconstruction. Zero or more versions MAY omit Parent. A VersionTag spelled `root` SHALL have no privilege.

#### Scenario: Read a sibling directly

- **GIVEN** Language/Counter has full bodies first=`int X=0;`, left=`int X=1;` and right=`int X=2;` and none of those versions names a Parent
- **WHEN** right is requested after left
- **THEN** right returns `int X=2;` without changing left

    File Version=v1 describes metadata format, not a source node. Parent and topic metadata do not schedule execution.

#### Scenario: Admit two parentless versions

- **GIVEN** a v1 container whose cases open with `@begin alpha` and `@begin beta` and neither header has `@parent`
- **WHEN** the file is parsed and built
- **THEN** both VersionTags are retrievable and neither is required to be named `root`

    > Observables: `Get(FileTag, "alpha")` and `Get(FileTag, "beta")` succeed.

    > Boundaries: a cycle or a Parent that names a missing VersionTag still fails construction.

### Requirement: Checked material construction

The database SHALL return checked construction results with no partial successful payload when material structure is invalid, while allowing source that would fail language compilation.

#### Scenario: Accumulate independent errors

- **GIVEN** a duplicate version Tag x and an independently empty Summary
- **WHEN** Build finalizes the input
- **THEN** construction fails with both reliably established reasons and no admissible payload

    Source text int X=Missing; with valid metadata instead builds successfully without compiling AS.

#### Scenario: Reject an invalid structured Source descriptor

- **GIVEN** a generated version with valid FileMeta and VersionMeta but a Source descriptor whose Point lies beyond clean source and whose origin spans do not cover the clean bytes

    The clean body is `ab`, so valid byte positions are `0..2`. The descriptor declares Point `p` at `3`, one span covering only clean byte `0`, and an `AuthoredEnd` for clean offset `2`.

- **WHEN** the generated factory adds the version and finalizes its `FAngelscriptTestCodeBuilder`

- **THEN** construction fails with the independently reliable annotation-offset and origin-coverage reasons and exposes no admissible Cases from that registration

- **BUT** source text `int X=Missing;` with valid fixture metadata and descriptor still builds successfully

    Builder validates test-material structure; it does not compile or semantically analyze AngelScript.

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

The database SHALL obtain authored test materials from deterministic checked-in structured C++ projections, with one mirrored projection per `.as` file, without runtime author-file fallback, Windows resource identifiers, activation-time parsing of generated containers, or implicit generation during ordinary builds.

#### Scenario: Observe a synchronized inventory

- **GIVEN** the author root contains `Language/Counter.as`, the tool subtree may contain test-only `.as` fixtures, and the generated root contains the last synchronized projections

    `CodeGenTool/**` is reserved implementation and test data. It never contributes public FileTags or production generated translation units. The authored Counter contains complete `root` and `add-step` versions plus fixture annotations.

- **WHEN** an author runs read-only `check`, edits a source, and then explicitly runs `generate`

    The public commands remain `python AngelscriptTestCode/CodeGenTool/codegen.py check` and `python AngelscriptTestCode/CodeGenTool/codegen.py generate`. They resolve repository paths from the tool location rather than the caller's current directory.

- **THEN** the generated root contains exactly one signed, mirrored, readable `.generated.cpp` for each authored `.as`, carrying the authored path/length/hash, real FileMeta and VersionMeta, complete clean `AS_TEST_SOURCE` bodies, typed Points/Breakpoints/Ranges and compact origin spans plus the clean-end authored offset

    `Language/Counter.as` becomes `TestCode/Generated/Language/Counter.generated.cpp`, registers FileTag `Language/Counter`, and declares a namespace-scope static symbol derived deterministically from that Tag. Equal projection content is not rewritten.

- **AND** each checked-in translation unit records one deferred captureless factory that supplies structured Source descriptors to `FAngelscriptTestCodeBuilder` during central activation

    Generated code does not include or call `FAngelscriptTestSourceParser`. Handwritten C++ providers continue to use the same `FAngelscriptTestCodeRegistration`. Registration and admitted Cases share the same FileMeta truth.

- **BUT** missing, changed, stale, malformed, colliding or unsafe output state is never reported as synchronized

    `check` returns failure without mutation. `generate` parses, validates and renders the complete expected set before writing, atomically replaces changed files, and deletes only stale signed `.generated.cpp` files beneath the dedicated generated root after all writes succeed. Ordinary UBT never invokes Python or scans the author root.

#### Scenario: Generate an intentionally invalid AngelScript version

- **GIVEN** a version body `int Value = Missing;` with valid required metadata, explicit `/** @end */`, valid annotations and a valid parent topology

- **WHEN** the Python CodeGenTool parses and renders the authored file

- **THEN** generation succeeds and the version is retrievable as an immutable Case with those exact clean bytes

- **BUT** an invalid fixture directive, missing required metadata, malformed annotation or invalid version topology fails generation before any existing projection is changed

    Negative language behavior is asserted by a later consuming test. Fixture admission never treats generation failure as a successful negative-language result.

### Requirement: Conforming independent fixture protocol parsers

The Python generated-source parser and retained C++ `FAngelscriptTestSourceParser` SHALL implement equivalent fixture metadata, version, annotation, clean-byte and authored-origin semantics without requiring generated translation units to invoke the C++ parser. Case identity SHALL be `@begin <tag>` for author files in this Change's grammar. Several versions MAY omit Parent.

#### Scenario: Compare positive parser products

- **GIVEN** shared v1 fixtures covering BOM, LF/CRLF/CR, Unicode, complete root/child source, escaped annotations, nested ranges and a trailing clean LF

- **WHEN** the Python parser and C++ parser process the same fixture bytes independently

- **THEN** they produce equal FileMeta, VersionMeta and version ordering, clean bytes, Points, Breakpoints, half-open Ranges and original-byte mappings for every clean offset including clean `Num()`

#### Scenario: Compare protocol failures

- **GIVEN** shared fixtures with an unknown directive, missing Summary, duplicate Version Tag, missing Parent, cycle, duplicate annotation name, unmatched range and crossing range

- **WHEN** both parsers process each invalid fixture

- **THEN** both reject it with the same stable primary error code and authored source location

- **AND** message wording and the order of independently recoverable secondary errors may differ

    Conformance protects protocol semantics, not implementation-specific prose or recovery scheduling.

#### Scenario: Compare parentless begin blocks

- **GIVEN** a shared fixture with two `@begin` cases, no `@parent`, one `@function` header, and one `@range-begin` / `@range-end` pair
- **WHEN** the Python parser and C++ parser process the same fixture bytes independently
- **THEN** they produce equal FileMeta, VersionMeta (including empty Parent), version ordering, clean bytes, Points, Breakpoints, half-open Ranges and original-byte mappings

    > Boundaries: compile-fail cases may omit `@function`. Unknown `@topic` words remain legal nonempty labels.
