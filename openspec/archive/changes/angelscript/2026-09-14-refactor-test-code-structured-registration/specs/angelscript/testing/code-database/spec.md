## MODIFIED Requirements

### Requirement: Checked material construction

The database SHALL return checked construction results with no partial successful payload when material structure is invalid, while allowing source that would fail language compilation.

#### Scenario: Reject an invalid structured Source descriptor

- **GIVEN** a generated version with valid FileMeta and VersionMeta but a Source descriptor whose Point lies beyond clean source and whose origin spans do not cover the clean bytes

    The clean body is `ab`, so valid byte positions are `0..2`. The descriptor declares Point `p` at `3`, one span covering only clean byte `0`, and an `AuthoredEnd` for clean offset `2`.

- **WHEN** the generated factory adds the version and finalizes its `FAngelscriptTestCodeBuilder`

- **THEN** construction fails with the independently reliable annotation-offset and origin-coverage reasons and exposes no admissible Cases from that registration

- **BUT** source text `int X=Missing;` with valid fixture metadata and descriptor still builds successfully

    Builder validates test-material structure; it does not compile or semantically analyze AngelScript.

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

## ADDED Requirements

### Requirement: Conforming independent fixture protocol parsers

The Python generated-source parser and retained C++ `FAngelscriptTestSourceParser` SHALL implement equivalent v1 fixture metadata, version, annotation, clean-byte and authored-origin semantics without requiring generated translation units to invoke the C++ parser.

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
