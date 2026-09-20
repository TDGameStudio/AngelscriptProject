# Frontend Preprocessing Specification

## Purpose

Define the language frontend contract for deterministic conditional compilation, complete directive preservation, and source-range backquery without textual macro expansion.

## Requirements

### Requirement: Frozen conditional configuration

The frontend SHALL evaluate conditional directives against one immutable, explicitly identified flag configuration for the lifetime of a source snapshot.

#### Scenario: Select one branch deterministically
- **GIVEN** frozen source tokens and boolean flags
    > Inputs: Conditions support flags, 0/1, defined, !, &&, || and parentheses with normal boolean precedence.
- **WHEN** a balanced conditional section is evaluated
- **THEN** the first eligible true branch is selected deterministically
- **BUT** flag lookup does not expand ordinary source identifiers as textual macros

#### Scenario: Balance a nested conditional inside inactive source
- **GIVEN** an outer branch that is inactive in the frozen configuration
- **WHEN** its body contains nested conditional directives
    > Details: Nested delimiters must still be parsed so the full tree remains balanced, but conditions that cannot affect selection are not evaluated.
- **THEN** the nested structure and source ranges are retained with a not-evaluated state
    > Observables: Unknown flags inside the unreachable nested branch do not emit evaluation diagnostics, and no nested body token enters the active stream.

### Requirement: Complete directive tree and active token stream

The frontend SHALL preserve every conditional directive and branch in a complete raw-source tree while exposing a separate parser input containing only active non-directive tokens.

#### Scenario: Preserve active and inactive branches
- **GIVEN** a conditional section with multiple alternative branches
- **WHEN** preprocessing completes successfully
- **THEN** the directive tree records each introducer, condition-token range, body range, parent conditional, terminator, and evaluation state
    > Observables: A consumer can enumerate both taken and inactive branches in authored source order.
- **AND** the parser-facing token stream contains only tokens from the selected branch and excludes all directive tokens
    > Verification: NativeEngine preprocessing fixtures compare exact active token spelling and the complete tree for nested and zero-taken cases.
- **BUT** inactive branch contents are not represented as typed declarations, statements, or expressions
    > Boundaries: They remain raw tokens and ranges suitable for display, comparison, and a future syntax-only tooling product.

#### Scenario: Preserve skipped ranges
- **WHEN** one or more branch bodies are excluded by the configuration
- **THEN** the preprocessing result exposes normalized, source-ordered, non-overlapping skipped byte ranges within the owning source file
    > Observables: Each skipped range is associated with its exact conditional branch and can be queried without reparsing the source text.

### Requirement: Snapshot-bound preprocessing backquery

The frontend SHALL provide range-based queries that relate source and AST ranges to conditional regions without placing a preprocessing record identifier on every AST node.

#### Scenario: Query a typed node range after parsing
- **GIVEN** an AST node whose half-open UTF-8 byte range belongs to the same immutable source snapshot as a preprocessing result
- **WHEN** a consumer asks for preprocessing records that overlap or contain that range
- **THEN** the query returns the matching conditional branch and directive records in deterministic source order
    > Observables: Consumers can ask whether two ranges belong to different conditional regions and whether a range intersects a directive boundary.
- **BUT** the AST node needs only its normal source range unless a later producer has a separate, explicit provenance relation that cannot be recovered by range
    > Boundaries: The ordinary AST does not retain raw pointers to preprocessing records or duplicate the directive tree.

#### Scenario: Reject a foreign snapshot coordinate
- **GIVEN** a range or preprocessing identifier created by another snapshot or an earlier generation
- **WHEN** it is supplied to a query on the current preprocessing result
- **THEN** the query returns a typed invalid-owner result and no records
    > Observables: Reused numeric file or record values cannot silently alias the current snapshot.

### Requirement: Restriction directives are typed preprocessing records

The frontend SHALL preserve the supported `#restrict usage allow/disallow` forms as typed records with exact authored ranges instead of rewriting them into text or generic key-value annotations.

#### Scenario: A valid usage restriction is encountered
- **WHEN** active source contains a well-formed `#restrict usage allow <pattern>` or `#restrict usage disallow <pattern>` directive
    > Inputs: The directive kind, usage operation, allow/disallow policy, non-empty pattern, and complete source range.
- **THEN** preprocessing emits one typed restriction record and removes the directive tokens from ordinary Parser input
    > Observables: Later semantic consumers can distinguish allow from disallow without reparsing directive text.
- **AND** the record remains queryable through the same snapshot-bound range index as conditional directives
    > Verification: Exact-range fixtures cover both policy values and nested conditional placement.

#### Scenario: A restriction directive is malformed
- **WHEN** `#restrict` has an unknown operation, missing policy, extra argument, or unsupported value
- **THEN** preprocessing emits a stable diagnostic at the smallest responsible range and marks the result invalid
- **BUT** it does not create a partially valid generic annotation
    > Boundaries: New restriction operations require an explicit typed grammar extension.

### Requirement: Explicit source coordinate and lifetime contract

The frontend SHALL express preprocessing locations as snapshot-owned file identifiers and half-open UTF-8 byte ranges, and SHALL keep all returned views valid only while their immutable snapshot lease is alive.

#### Scenario: Retain a preprocessing result
- **WHEN** a root frontend artifact retains the successful preprocessing result
- **THEN** one snapshot lease keeps source bytes, raw and active tokens, directive nodes, preprocessing records, and their range indexes alive together
    > Context: UE containers and `TSharedPtr` may implement this same-module ownership boundary, but node-level shared ownership is unnecessary.
- **AND** snapshot-local identifiers are checked against the owning snapshot identity or epoch
    > Verification: Tests create two snapshots with reusable local numeric identifiers and prove cross-snapshot queries fail closed.
- **BUT** serialized or hot-reload-stable anchors never depend on a `TSharedPtr` address, `FName` comparison index, raw pointer, or snapshot-local integer alone
    > Boundaries: Durable anchors use canonical logical source identity, content revision or digest, and byte ranges.

### Requirement: Conditional diagnostic recovery

The frontend SHALL diagnose malformed conditional structure with exact authored ranges and SHALL not publish a parser input as successful when the conditional result is structurally invalid.

#### Scenario: Encounter an invalid directive sequence
- **WHEN** preprocessing encounters an unknown evaluated flag, unmatched `#elif`/`#else`/`#endif`, duplicate `#else`, missing `#endif`, or unsupported preprocessing directive
- **THEN** it emits a stable diagnostic code at the responsible authored directive or condition range
    > Observables: The diagnostic identifies the source snapshot, exact half-open range, and failure category without relying only on line text.
- **AND** the partial directive tree remains inspectable for diagnostics while the parser-facing result is marked invalid
    > Verification: Malformed-input fixtures assert both recovery structure and the absence of a successful active-token publication.

#### Scenario: Include syntax is rejected without import guidance
- **WHEN** active source contains `#include`
- **THEN** preprocessing reports that include expansion is unsupported at the directive range
- **BUT** the diagnostic does not recommend, synthesize, or depend on `import`
    > Boundaries: File discovery and automatic module dependency construction belong to the compilation session and resolved declaration graph.

### Requirement: Preprocessor ownership boundary

The conditional preprocessing product SHALL remain separate from import resolution, reflection interpretation, and runtime publication.

#### Scenario: Encounter declaration annotations
- **WHEN** raw tokens contain `UCLASS`, `UFUNCTION`, or `UPROPERTY` outside an excluded branch
- **THEN** conditional routing preserves those active tokens and their source ranges for their owning later frontend stage
    > Observables: The preprocessing record does not synthesize `FAngelscriptClassDesc`, module edges, generated wrappers, or runtime objects.
- **BUT** it does not implement a second annotation scanner, invent a module-loading keyword, or invoke mutable host callbacks over the source buffer
    > Boundaries: Typed declaration binding and dependency/reflection projection occur after Parser and Sema, through separately versioned contracts.

### Requirement: Preprocessing does not implement language declarations

The preprocessor SHALL produce directive records and selected Tokens without parsing declarations, building reflection types or synthesizing language wrapper text.

#### Scenario: Preserve a deferred body input

- **WHEN** a function body is analyzed after its declaration phase and temporary caller lexer objects have been destroyed

- **THEN** analysis consumes the original selected Tokens with valid identifiers and source ranges

- **BUT** it does not re-preprocess the raw body with a new configuration or incomplete outer conditional context

#### Scenario: Route a language construct after preprocessing

- **WHEN** active source contains annotations, `DECLARE_*` callable declarations, leftover `delegate` / `event` introducers, defaults or range loops

    > Inputs: `UCLASS` / `UFUNCTION` annotations and `DECLARE_DELEGATE_OneParam(FOnDone, int);`.

- **THEN** the selected Tokens reach Parser/Sema without generated AS text

    > Observables: no synthesized `struct FOnDone { _FScriptDelegate _Inner; ... }` and no C-macro expansion of `DECLARE_*`.

    > Boundaries: Include expansion and text replacement macros remain unsupported; source backquery retains both active and inactive conditional regions.

- **BUT** `DetectClasses` / `ProcessDelegates` SHALL NOT collect leftover `delegate` / `event` text as wrapper-generation work

    > Boundaries: declaration semantics belong to Parser/Sema. Newlines increment the preprocessor line counter and do not split a Global chunk, so a multi-line `DECLARE_*` argument list stays one token stream for Parser.
