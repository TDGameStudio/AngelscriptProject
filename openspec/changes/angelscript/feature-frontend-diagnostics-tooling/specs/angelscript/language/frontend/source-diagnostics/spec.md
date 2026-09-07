## MODIFIED Requirements

### Requirement: Frontend diagnostics are structured before rendering

The frontend SHALL report every current lexer, preprocessing, parsing, semantic, compilation-session and Builder failure through one catalogued diagnostic authority before rendering, with stable cause identifiers, semantic arguments and explicit optional source ownership.

#### Scenario: A diagnostic is captured without a live Engine

- **WHEN** a frontend stage reports an error, warning, note, remark or fatal failure
  > Inputs: A catalogued cause, default/effective severity, an optional primary range, typed arguments, highlights, attached notes and optional alternative fixes.
- **THEN** a replaceable consumer receives the structured diagnostic group without calling `asCScriptEngine::WriteMessage` or reading `GEngine`
  > Observables: The owning result retains enough immutable source and semantic display data for deferred consumption.
- **AND** human-readable text and line/column presentation can be rendered later from that same group
  > Boundaries: No consumer parses formatted message text to recover type identity, note association or source ranges.

#### Scenario: Parallel diagnostics have deterministic order

- **GIVEN** multiple frontend fragments report groups independently
  > Context: Notes belong to a specific primary diagnostic, including notes in a different source file.
- **WHEN** the compilation session finalizes its diagnostic sequence
- **THEN** complete groups are ordered by stable primary source identity, byte range, severity precedence, diagnostic ID and deterministic fragment/local tie-breakers
  > Observables: One-worker and multi-worker runs serialize identically; attached notes retain deterministic semantic order inside their group.
- **BUT** cross-file notes are not independently sorted away from their primary diagnostic
  > Boundaries: Nonlocated groups use a documented stable category/fragment ordering, never a fabricated source range or worker arrival time.

## ADDED Requirements

### Requirement: Diagnostic causes and arguments are machine-readable

The frontend SHALL distinguish each currently supported diagnostic cause through a centralized catalog with stable identifiers, names, categories, default severity, warning group where applicable, message templates and typed argument contracts.

#### Scenario: Distinguish semantic failures without parsing messages

- **WHEN** analysis finds an unresolved name, incompatible type or failed overload selection
- **THEN** the result identifies the concrete cause and carries the applicable names, types or callable signatures as typed data
  > Observables:
  >
  > - Type mismatches expose expected and actual types with use-site qualifications.
  > - Overload failures expose relevant candidates and parameter-specific rejection reasons.
  > - Display text may evolve without changing the identity of an unchanged cause.
- **BUT** a generic parser or body error ID plus an arbitrary reason string is not the complete public contract

#### Scenario: Report a failure without a source location

- **WHEN** invalid inputs, unavailable dependencies or a driver invariant fails before a source-bearing construct exists
- **THEN** the result retains a catalogued nonlocated diagnostic with the relevant stage and failure details
  > Example: An invalid Builder request with no tokens still produces a visible failure.
- **BUT** no first-token range, line zero or unrelated file is invented to satisfy location validation

### Requirement: Diagnostic policy preserves failure facts

Diagnostic policy SHALL distinguish emission policy from language validity, analysis completeness and build/publication outcome, and SHALL apply warning configuration and diagnostic limits to complete groups.

#### Scenario: Suppress display without suppressing failure

- **GIVEN** source contains a language error and its output is hidden or exceeds the configured report limit
- **WHEN** the caller inspects the analysis and build outcome
- **THEN** the error fact remains present and the result is not publishable
  > Boundaries: Missing displayed errors is not evidence that all requested stages were analyzed successfully.

#### Scenario: Promote a warning to a build failure

- **WHEN** a warning is emitted under a warning-as-error policy
- **THEN** it retains its catalogued warning identity and records the effective policy-driven build failure
- **BUT** the policy does not introduce invalid syntax, an error type or a recovery node into an otherwise valid AST

#### Scenario: Limit or terminate diagnostics at a group boundary

- **WHEN** an error limit or fatal condition prevents further diagnostic reporting
- **THEN** the accepted primary group retains all of its notes and fix alternatives, and the result explicitly identifies truncation or incomplete analysis
  > Observables: Worker completion order cannot select a different retained group prefix.
- **BUT** the consumer never receives an orphan note or a partially delivered fix alternative

### Requirement: Diagnostic presentation preserves structured meaning

The frontend SHALL provide deterministic source-aware text and lossless structured diagnostic output derived from the same owned result.

#### Scenario: Render and export a source diagnostic

- **WHEN** a consumer renders a diagnostic with highlights, cross-file notes and fixes
- **THEN** text identifies the cause, source snippet and caret/range, while structured JSON preserves all semantic fields and associations
  > Observables: Related ranges, replacement bytes, revision preconditions, typed arguments and severity policy are not omitted from JSON.
- **AND** stable keys and 64-bit revisions survive export without floating-point conversion
  > Boundaries: Pointer values, local FileID and process-global counters are not durable identities.

#### Scenario: Render a suggestion note with a caret

- **GIVEN** a diagnostic group has an unresolved-name primary and a unique viable spelling note with an applicable fix
- **WHEN** a consumer formats that owned group against its retained source revision
- **THEN** the text names the invalid identifier, shows a caret under that use, and the note names the suggested identifier with its own caret or range
  > Example: For `int F(){ int Count=1; return Cout; }` the formatted error identifies `Cout` and the note identifies `Count` without requiring the consumer to parse the English sentence.
  >
  > Observables: The formatted text is derived from catalog identity, typed arguments and source ranges. Tests compare it to an independently authored expected string.
- **BUT** formatting never writes files or changes the compiler's interpretation of the original source

### Requirement: Presentation coordinates have explicit encoding

Source presentation SHALL convert immutable UTF-8 byte locations to and from explicitly selected zero-based UTF-8 or UTF-16 line/character coordinates without changing the internal byte-range authority.

#### Scenario: Convert multibyte source positions

- **WHEN** a caller converts valid boundary positions in source containing ASCII, Chinese text, non-BMP characters, CRLF and EOF
- **THEN** a round trip selects the same original bytes under the chosen encoding
  > Examples: A non-BMP character occupies four UTF-8 bytes and two UTF-16 code units; line endings do not count as ordinary line content.
- **BUT** a position inside a code unit sequence, outside a line or in another snapshot is not silently rounded to a different token
  > Boundaries: Invalid UTF-8 remains diagnosable in native byte space even when presentation conversion is unavailable.

### Requirement: Fix alternatives are source-safe atomic proposals

The frontend SHALL represent each alternative fix as an atomic edit set bound to exact logical source revisions and SHALL offer an applicable edit only where spelling provenance and semantic confidence justify it.

#### Scenario: Apply a safe correction in memory

- **GIVEN** a uniquely viable name correction or unambiguous missing delimiter has an applicable fix
- **WHEN** the caller applies the selected alternative to the exact input revision and analyzes the new in-memory source
- **THEN** every edit in that alternative is applied and the targeted diagnostic disappears
  > Observables: UTF-8 half-open replacement ranges and zero-length insertion points select the intended original text.
- **BUT** merely reporting a diagnostic never writes user files or changes the compiler's interpretation of the original source

#### Scenario: Reject a stale or conflicting edit set

- **WHEN** any edit has a stale revision, overlapping range or unresolvable source provenance
- **THEN** application rejects the entire alternative and leaves all supplied buffers unchanged
  > Boundaries: Equal content-hash values are not a security guarantee; application validates the expected original bytes as well as source identity and revision.

#### Scenario: Keep ambiguous corrections advisory

- **GIVEN** multiple equally plausible visible names or a synthetic/inactive source context without a proven safe spelling edit
- **WHEN** diagnostics explain the failure
- **THEN** useful suggestions may be shown as notes without an automatically applicable edit
  > Example: Equally viable `Count` and `Court` candidates for `Cout` do not select one by incidental iteration order.
