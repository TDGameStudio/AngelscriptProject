# as-compilation-events Specification

## Purpose
TBD - created by archiving change refactor-as-compilation-event-hook. Update Purpose after archive.
## Requirements
### Requirement: Default-quiet compilation events
The runtime SHALL provide structured compilation events that are silent and behavior-preserving when no listeners are registered.

#### Scenario: No listener preserves compilation behavior
- **WHEN** scripts are preprocessed and compiled with no compilation event listeners registered
- **THEN** compilation results, diagnostics, module swap behavior, and existing delegates SHALL remain equivalent to the pre-change behavior, and no compilation-event-specific logs, diagnostics, or exports SHALL be produced

#### Scenario: Registered listener receives structured events
- **WHEN** a caller registers a compilation event listener and runs preprocessing or module compilation
- **THEN** the listener SHALL receive structured value-style events describing stable phase, compile type, module/file identity, counts, result flags, and messages where applicable

### Requirement: Preprocessing events are emitted through compilation events
The runtime SHALL adapt existing preprocessing hook moments into structured compilation events.

#### Scenario: Process-chunks event is emitted
- **WHEN** preprocessing reaches the process-chunks hook point with a compilation event listener registered
- **THEN** the listener SHALL receive a preprocessing process-chunks event containing the relevant preprocessing summary

#### Scenario: Post-process-code event is emitted
- **WHEN** preprocessing reaches the post-process-code hook point with a compilation event listener registered
- **THEN** the listener SHALL receive a preprocessing post-process-code event containing the relevant preprocessing summary

### Requirement: Compile flow events cover stable stage boundaries
The runtime SHALL emit structured compilation events for compile begin/end, module stage boundaries, parse, type generation, layout, code compilation, conditional JIT status, globals initialization, and class-generation handoff.

#### Scenario: Successful compile emits ordered stage events
- **WHEN** a minimal script module compiles successfully with a compilation event listener registered
- **THEN** the listener SHALL receive an ordered event sequence covering compile begin, module assembly/type input, parse, type generation, function generation, layout, code compilation, globals initialization, class-generation handoff, and compile end

#### Scenario: JIT metadata reflects current availability
- **WHEN** a module reaches code compilation with a compilation event listener registered
- **THEN** the code compilation event SHALL indicate whether JIT is enabled or unavailable for that module, and SHALL include JIT handoff metadata only when a JIT handoff actually occurs

#### Scenario: Failed compile emits paired failure events
- **WHEN** script compilation fails after compile begin with a compilation event listener registered
- **THEN** the listener SHALL receive failure/result information and SHALL NOT leave unmatched begin events without a corresponding end/failure event

### Requirement: Event payload is read-only and stable
The runtime SHALL keep compilation event payloads read-only and value-style so event listeners cannot mutate active compiler, preprocessor, AS builder, or module internals through event data.

#### Scenario: Listener cannot mutate compiler state through payload
- **WHEN** a listener receives a compilation event
- **THEN** the payload SHALL expose summaries rather than mutable `FAngelscriptPreprocessor`, `asCBuilder`, or `asCModule` internals

### Requirement: Thin compilation context supports events without replacing the pipeline
The runtime SHALL introduce a per-run compilation context only for shared compile state and summary generation needed by compilation events and future phase extraction, without changing externally observable compile semantics.

#### Scenario: Context is scoped to one compile run
- **WHEN** `CompileModules()` executes
- **THEN** any compilation context used for event generation SHALL be created for that compile run and SHALL NOT become a persistent global engine state

#### Scenario: Existing compile delegates remain compatible
- **WHEN** code subscribes to existing runtime compile delegates such as pre-compile, post-compile, or pre-generate-classes
- **THEN** those delegates SHALL continue to fire according to their existing behavior while compilation events provide additional structured information

