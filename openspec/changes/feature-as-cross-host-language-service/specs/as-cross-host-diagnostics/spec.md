## ADDED Requirements

### Requirement: One host-neutral diagnostic evaluator is authoritative
The plugin SHALL own one standard-C++ diagnostic evaluator and rule registry that are compiled from the same source into `AngelscriptRuntime`, Native Standalone, Native Language Server, and WebAssembly. UE, Standalone, JavaScript, Wiki, and TypeScript adapters MUST NOT contain independent implementations of rules registered by that evaluator.

#### Scenario: Registered rule runs in every host
- **WHEN** the same normalized fact graph and rule policy are evaluated in UE, Native Standalone, and WebAssembly
- **THEN** each host SHALL invoke the same rule implementation
- **AND** no host-specific adapter SHALL replace the rule message, severity, suppression, or matching logic

#### Scenario: TypeScript rule is migrated
- **WHEN** a rule formerly implemented by the TypeScript Language Server is registered in the shared evaluator
- **THEN** the TypeScript implementation SHALL stop emitting that rule
- **AND** TypeScript SHALL only map and present the authoritative result

### Requirement: The initial shared rule catalog is stable and complete
The initial rule catalog SHALL define the following IDs and defaults: `ASLINT1001` unused local/parameter as Hint with Unnecessary, `ASLINT1002` resolved symbol missing explicit import as Information, `ASLINT1003` missing script `override` as Warning, `ASLINT1004` missing required Super call as Warning, `ASLINT1005` invalid delegate/event bind as non-fatal Error, `ASLINT1101` Unreal type naming as Warning, `ASLINT1102` Unreal function naming as Hint, and `ASLINT1103` Unreal variable/bool naming as Hint.

#### Scenario: Default catalog is requested
- **WHEN** a host evaluates a document without a caller override mask
- **THEN** all eight initial rules SHALL use the specified IDs and default severities
- **AND** rule ordering and messages SHALL be deterministic

#### Scenario: Rule groups are filtered by a client
- **WHEN** a client disables presentation or evaluation for an exposed rule group
- **THEN** the underlying rule identity and default policy SHALL remain unchanged
- **AND** another client using defaults SHALL receive the canonical result

### Requirement: Super-call and delegate rules use proven semantic facts
`ASLINT1004` SHALL require a proven BlueprintEvent or `RequireSuperCall` parent relationship and SHALL be suppressed by `NoSuperCall` on the parent or override. `ASLINT1005` SHALL compare a resolved delegate/event signature with a resolved target function and SHALL not infer incompatibility from an unknown or partial relationship.

#### Scenario: Required Super call is absent
- **WHEN** an override has a proven BlueprintEvent or `RequireSuperCall` parent, neither declaration has `NoSuperCall`, and no matching `Super::` call is observed
- **THEN** `ASLINT1004` SHALL report a Warning at the override

#### Scenario: NoSuperCall suppresses the warning
- **WHEN** the proven parent or override carries `NoSuperCall`
- **THEN** `ASLINT1004` SHALL emit no diagnostic for the missing Super call

#### Scenario: Delegate target signature differs
- **WHEN** a bind operation and target are resolved and their parameter/return signatures are incompatible
- **THEN** `ASLINT1005` SHALL report a non-fatal Error with related target information

#### Scenario: Partial profile cannot prove a delegate target
- **WHEN** the selected profile marks the required target or signature relationship unknown
- **THEN** `ASLINT1005` SHALL not report a missing or incompatible target as a definitive result

### Requirement: Static diagnostic severity does not control compilation success
Every shared static diagnostic SHALL carry an explicit `nonFatal` classification independent of its presentation severity. Shared static diagnostics SHALL NOT set UE module compile failure, reject hot reload, change packaging success, or change Standalone compiler success unless a later explicit lint-gate capability is selected.

#### Scenario: Invalid delegate bind is presented as Error
- **WHEN** `ASLINT1005` is emitted during a UE compilation that otherwise succeeds
- **THEN** the diagnostic SHALL be presented as Error and `nonFatal: true`
- **AND** the module compilation and eligible hot reload SHALL remain successful

#### Scenario: Compiler error and lint error coexist
- **WHEN** a document has a compiler Error and a non-fatal shared Error
- **THEN** compile failure SHALL be caused only by the compiler Error
- **AND** the two diagnostics SHALL retain distinct sources and fatality

### Requirement: Normalized facts preserve proof and completeness
Host adapters SHALL provide a versioned normalized fact graph containing stable document/range identities, declarations, references, imports, resolved stable IDs, class and method relationships, metadata flags, resolved Super calls, delegate signatures, naming contexts, and completeness. The evaluator SHALL distinguish proven absence from unknown information.

#### Scenario: UE supplies authoritative facts
- **WHEN** UE has final compiler and reflection facts for a relationship
- **THEN** the UE adapter SHALL normalize them without exposing UObject pointers or process-local IDs

#### Scenario: Offline profile is incomplete
- **WHEN** Standalone or WASM cannot prove a relationship because the selected profile is partial
- **THEN** the fact SHALL be marked unknown rather than absent
- **AND** absence-dependent rules SHALL not create a definitive diagnostic

### Requirement: Diagnostic results have a versioned editor-neutral shape
Each diagnostic result SHALL include stable diagnostic ID, rule ID, source, severity, non-fatal flag, message, zero-based UTF-16 range, related information, tags, document version, profile identity, rule-set version, and rule-set hash. Result ordering SHALL be deterministic and SHALL not include elapsed time or process-local identity in equality comparisons.

#### Scenario: Source contains non-BMP Unicode
- **WHEN** a diagnostic follows an emoji or other non-BMP code point in UTF-8 source
- **THEN** its external range SHALL identify the same text using zero-based UTF-16 positions in UE, Native Standalone, WASM, and LSP projections

#### Scenario: Equivalent analysis repeats
- **WHEN** the same source, profile, rule policy, and semantic facts are evaluated twice
- **THEN** the normalized diagnostic arrays SHALL be byte-equivalent after canonical serialization

### Requirement: Incomplete compilation suppresses dependent lint cascades
The shared pipeline SHALL classify which rules require structurally complete frontend or semantic facts and SHALL suppress those rules when the prerequisite stage fails.

#### Scenario: Parser cannot build the function body
- **WHEN** a syntax error prevents reliable local-variable and call facts
- **THEN** the compiler diagnostic SHALL be returned
- **AND** unused, missing-Super, and delegate-bind rules requiring those facts SHALL not emit cascade diagnostics

### Requirement: Rule-set identity changes with normative behavior
The rule registry SHALL publish a deterministic `ruleSetVersion` and `ruleSetHash`. Any change to a registered rule's ID, default severity, message template, suppression behavior, or matching semantics SHALL update the normative identity and cross-host fixtures.

#### Scenario: Message or severity changes
- **WHEN** a registered rule's canonical message template or default severity changes
- **THEN** the rule-set identity SHALL change
- **AND** parity fixtures SHALL require explicit updated expectations

#### Scenario: Host adapter changes without rule behavior change
- **WHEN** a host adapter is refactored but produces the same normalized facts and diagnostics
- **THEN** the rule-set identity SHALL remain unchanged

### Requirement: Offline diagnostic facts are bounded and versioned
The UE offline producer SHALL export only explicit language-service semantic fields required by the shared fact contract, including BlueprintEvent, `RequireSuperCall`, `NoSuperCall`, signature identity, inheritance, and override availability. It SHALL NOT export an arbitrary metadata map, code body, address, or private machine path.

#### Scenario: Language-service facts are exported
- **WHEN** a callable participates in a shared rule and its fact is known in final UE state
- **THEN** the versioned offline record SHALL contain the corresponding explicit semantic field

#### Scenario: Unrelated metadata exists
- **WHEN** a reflected declaration contains metadata not selected by the language-service contract
- **THEN** that metadata SHALL not be copied into an open-ended offline map
