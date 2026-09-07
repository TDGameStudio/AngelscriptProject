# Native Frontend Tooling

## Purpose

Provide authoritative, engine-independent semantic queries over complete or recoverable AngelScript source, with explicit input identity, owned results, an in-process SDK language-service facade for compile-time diagnostic formatting and suggestion query, and safe boundaries for future editor protocol adapters.

## ADDED Requirements

### Requirement: Owned engine-independent analysis results

The frontend SHALL provide an owning `asCAnalysisResult` that retains the source snapshots, semantic AST, compilation/type context and frozen host-definition leases needed by its returned data. Analysis and tooling queries SHALL require no ambient `asCScriptEngine`. A readable partial result SHALL be distinct from a verified compilable AST and SHALL NOT authorize definition freezing or Engine publication.

#### Scenario: Result survives release of the caller's compilation inputs

- **GIVEN** an analysis result refers to script declarations and explicit frozen host definitions
- **WHEN** the caller releases its Builder, input snapshot references and host-definition image references
- **THEN** the retained result still supports valid semantic queries and diagnostic presentation

  - Type and declaration information remains valid through result ownership.
  - Source excerpts and declaration locations refer to the retained input revision.
  - No query consults an ambient Engine or a replacement global registry.

#### Scenario: Recoverable source remains inspectable without becoming publishable

- **GIVEN** a source contains an invalid expression followed by an independently analyzable declaration
- **WHEN** analysis returns a read-only partial result
- **THEN** tooling can inspect the valid declaration and observe which analysis phases completed
  > Recovery nodes and language-error facts remain present; their inspectability does not satisfy the normal valid-AST, definition-freeze or publication gates.
- **BUT** no reader observes concurrent AST mutation

### Requirement: Explicit snapshot-bound native query surface

The native tooling surface SHALL expose `Analyze`, `Complete`, `GetSignatureHelp`, `GetHover` and `FindDefinition` over explicitly supplied immutable source, compilation configuration, dependencies and frozen host definitions. Each response SHALL identify the input revisions and analysis context it answers. Symbol visibility SHALL be limited to that explicit compilation closure and the maintained AS language semantics.

#### Scenario: Query answers only the supplied compilation environment

- **GIVEN** two otherwise identical requests supply different explicit host-definition images
- **WHEN** each request resolves a name or collects visible candidates
- **THEN** each response reflects only its own source, dependencies, configuration and host definitions

  - An unrelated workspace file is not discovered implicitly.
  - A missing native symbol is not supplied by the independent TypeScript parser or type database.
  - Removed `import` and `asset` syntax is not restored as a tooling-only language feature.

#### Scenario: Native query capability does not require an editor service

- **WHEN** a caller requests analysis, completion, signature help, hover or definition information directly from the native frontend
- **THEN** the request can complete without an LSP server, JSON-RPC transport, workspace index or legacy runtime bridge
  > The native result is a semantic contract for a future adapter, not a requirement to activate the existing editor integration or dormant test/runtime framework.

### Requirement: In-process language service exposes compile diagnostics and suggestions

The frontend SHALL provide an in-process `asCLanguageService` that attaches an owned diagnostic result from ordinary compilation and exposes formatted groups, structured notes and revision-bound fix alternatives without creating an `asCScriptEngine` or speaking JSON-RPC. Enabled features SHALL be explicit. Disabled or unimplemented features SHALL report unavailability rather than a successful empty payload.

#### Scenario: Format and inspect suggestions after a failed compilation

- **GIVEN** source `int F(){ int Count=1; return Cout; }` compiled through the engine-independent Builder with diagnostics and fixes enabled
- **WHEN** the language service attaches that compilation's diagnostic result
- **THEN** callers can read the unresolved-name group, format Clang-style text for it, inspect the `Count` suggestion as structured note data and apply the unique fix alternative in memory
  > Observables:
  >
  > - Formatted text identifies `Cout` with a caret and the note identifies `Count` with its range.
  > - Note and fix inspection uses typed arguments, ranges and replacement bytes, not parsed message text.
  > - Applying the unique alternative produces a new snapshot in which the original unresolved-name cause is gone.
- **AND** the original compilation snapshot and diagnostic result remain unchanged
- **BUT** the service does not write user files, start a language-server process or treat a hidden/truncated error as a successful empty diagnostic set

#### Scenario: Disabled features stay unavailable

- **GIVEN** a language service constructed with only diagnostic formatting enabled and an attached diagnostic result
- **WHEN** the caller requests a fix application or a semantic query feature
- **THEN** that request reports unavailability for the disabled feature
  > Observables: Unavailability is an explicit status, not a successful empty diagnostic list, empty note list or empty candidate set.
- **BUT** diagnostic group inspection and formatting of the attached result remain usable

### Requirement: Shared non-mutating semantic candidate assessment

Ordinary compilation, name correction, completion and signature help SHALL share the authoritative semantic rules for visibility, parameter mapping, receiver constraints, access and conversion viability. Tooling assessment SHALL report candidate viability and rejection reasons without committing AST conversions or changing the formal analysis result's diagnostics, declarations or frozen images.

#### Scenario: Query and compilation agree without query side effects

- **GIVEN** an overload set contains candidates rejected for different argument, access or receiver constraints
- **WHEN** tooling evaluates the candidates and the same complete call is evaluated for compilation
- **THEN** both use consistent applicability rules and explain the corresponding rejection causes

  - Tooling does not add conversion nodes to the formal AST.
  - Tooling does not append ordinary compilation diagnostics or alter a published diagnostic group.
  - Frozen definitions and host images remain unchanged.
- **AND** repeated queries over unchanged inputs produce the same assessment

#### Scenario: An unfinished call is not rejected as a completed short call

- **GIVEN** the cursor is inside a call whose later arguments have not yet been written
- **WHEN** semantic candidate assessment runs in that incomplete call context
- **THEN** it preserves candidates that remain viable after additional arguments are supplied
  > An absent future argument is unknown, not evidence of a completed-call arity mismatch. An already supplied incompatible argument may still provide a concrete rejection reason.

### Requirement: Contextual completion through independent cursor parsing

Completion SHALL obtain Parser and Sema context from an independent cursor-aware analysis of the requested source revision, including incomplete syntax. It SHALL NOT require a successful full compile or derive all candidates from diagnostic text or a completed AST walk. Cursor markers and query-only recovery SHALL NOT alter source byte offsets, the formal AST or its diagnostic result.

Completion SHALL provide visible locals, parameters, types, namespaces, members and applicable keywords according to current language rules. Candidates SHALL honor scope, shadowing, access, receiver and known expected-type context, and SHALL have deterministic filtering, ranking and deduplication.

#### Scenario: Member completion works immediately after a member access token

- **GIVEN** a local object's type is known and the source ends with `object.`
- **WHEN** completion is requested at the position after the dot
- **THEN** the response contains the accessible members applicable to that receiver

  - Unrelated module declarations do not replace the member candidate set.
  - Inaccessible or incompatible receiver-only members do not appear as applicable members.
- **BUT** the cursor marker is neither a source edit nor an ordinary diagnostic in the formal analysis result

#### Scenario: Lexical scope and expected type influence candidates

- **GIVEN** a local declaration shadows an outer name and the cursor has a known expected type
- **WHEN** completion is requested inside that local scope
- **THEN** the response respects the language's visibility and shadowing rules and ranks applicable candidates using the available type context
  > A declaration is visible only where current AS rules make it visible. Candidate presentation does not introduce declarations from later or unrelated scopes merely because their names match.
- **AND** repeated requests over the same context produce the same candidate order without duplicate semantic candidates

#### Scenario: Incomplete identifiers and EOF retain useful completion context

- **WHEN** completion is requested within an unfinished identifier, at EOF or inside an unclosed argument list
- **THEN** the response uses the recoverable cursor context and the already known semantic environment

  - An unfinished construct does not require a placeholder edit to the caller's source.
  - The replacement range, when provided, identifies actual source bytes in the requested revision.
  - An unknown expected type is reported as unknown rather than guessed from an unrelated recovery node.

### Requirement: Signature help preserves call and parameter context

Signature help SHALL return relevant candidate signatures, active argument information and the mapping from supplied arguments to formal parameters. It SHALL use the cursor's actual call context, including nested calls, named arguments, defaults and incomplete arguments supported by the maintained language. It SHALL distinguish known incompatibility from information unavailable until the call is complete.

#### Scenario: Named argument maps to its formal parameter

- **GIVEN** a callable has multiple parameters and the cursor is inside a named argument
- **WHEN** signature help evaluates the incomplete call
- **THEN** its active parameter identifies the named formal parameter rather than blindly using the argument's textual ordinal

  - Previously supplied positional or named arguments retain their resolved mappings.
  - Defaulted parameters are presented consistently with ordinary call resolution.
  - An unresolved candidate reports its own mapping or uncertainty instead of borrowing another overload's mapping.

#### Scenario: Nested and unclosed calls select the cursor's call

- **GIVEN** the cursor lies within an inner call inside an outer call's argument list
- **WHEN** signature help is requested before the inner argument list is closed
- **THEN** the response describes the inner call's candidates and active argument
  > An outer comma, an inner comma and a comma within a nested expression cannot be treated as interchangeable parameter separators.
- **AND** moving the cursor to the outer call context changes the selected call without changing the underlying source revision

### Requirement: Precise semantic hover and definition targets

Hover and definition queries SHALL resolve the token and semantic reference at the requested position, rather than selecting the largest AST range containing it. A containing token SHALL take precedence; an identifier touching the position at its end MAY be selected when no containing token has precedence. Whitespace, comments and unbound recovery nodes SHALL produce no semantic target.

Hover SHALL expose available type, signature and qualification information. Definition queries SHALL return authentic declaration or definition locations for the resolved entity, including the selected overload where resolution completed. Host entities without source locations SHALL be represented explicitly without fabricated source targets.

#### Scenario: Token identity wins over broad enclosing AST ranges

- **WHEN** a hover or definition request targets an identifier inside a larger expression
- **THEN** it resolves the identifier's bound semantic entity instead of the enclosing expression's unrelated declaration

  1. A token containing the requested position takes precedence.
  2. With no containing token taking precedence, an immediately adjacent identifier end may identify that identifier.
  3. Whitespace beyond that boundary, comments and unbound recovery nodes have no semantic target.

#### Scenario: A resolved call points to its selected overload

- **GIVEN** semantic analysis selected one overload for a call
- **WHEN** hover or definition information is requested for that call's referenced name
- **THEN** the result describes or locates the selected overload
  > Legitimate multiple declaration/definition locations for that same entity may be returned, but an unrelated overload cannot be substituted simply because its name matches.

#### Scenario: Host symbol lacks a source declaration

- **GIVEN** an explicitly supplied host definition contains semantic type or signature information but no source location
- **WHEN** hover and definition queries address that host symbol
- **THEN** hover can present the available semantics while definition information explicitly reports no source target
- **BUT** no file, line, byte range or script declaration is invented

### Requirement: Explicit query status and revision-safe positions

Query responses SHALL distinguish a successful empty result, complete analysis, partial analysis, cancellation, invalid input or position, and an unavailable analysis context. Cancelled or stale work SHALL NOT be represented as a complete successful response for a different request. Node handles SHALL remain analysis-result-local and SHALL be rejected across snapshots or unrelated analysis contexts.

Native query positions SHALL use snapshot-bound UTF-8 byte offsets. Presentation conversion SHALL use the coordinate and revision contract owned by `angelscript/language/frontend/source-diagnostics`; an editor document version SHALL NOT be treated as a source content revision.

#### Scenario: Cancellation is distinguishable from a valid empty response

- **WHEN** cancellation is observed before a semantic query completes
- **THEN** the response is marked cancelled and is not reported as a successful empty candidate or target set
  > Any retained partial data is explicitly marked partial and remains owned by the returned result. It cannot authorize publication or imply that all relevant semantic work completed.

#### Scenario: A handle or position is used with a different analysis

- **GIVEN** a caller retains a handle or snapshot-bound position from an earlier analysis result
- **WHEN** it submits that value to a different snapshot or incompatible analysis context
- **THEN** the query rejects the mismatched input instead of silently interpreting it against current source

  - A repeated file-local numeric identifier does not establish identity across snapshots.
  - The same content bytes do not authorize reuse of a semantic handle under different host definitions or compilation configuration.

#### Scenario: Native offsets and editor coordinates remain distinguishable

- **GIVEN** source contains multibyte characters and a caller uses a presentation coordinate encoding
- **WHEN** the caller converts the position through the source-diagnostics coordinate interface and issues a native query
- **THEN** the query addresses the resulting validated UTF-8 byte position in the specified revision
- **BUT** an unconverted UTF-16 column or editor document version is not accepted as an interchangeable native source coordinate or revision
