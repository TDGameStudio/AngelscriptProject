## Purpose

Define the concrete typed statement and expression semantics produced after declaration resolution and before any AngelScript runtime candidate, bytecode, or VM artifact exists.

## Requirements

### Requirement: Body analysis starts from a frozen declaration environment

The frontend SHALL begin function-body parsing only after the compilation session has completed declaration collection and resolution, and SHALL perform all body lookup against that frozen declaration environment.

#### Scenario: A body calls a function declared in another source file
- **GIVEN** a resolved function declaration with a deferred body and a callable declaration in another logical source file
  > Context: Both declarations already have canonical semantic identities before either body is analyzed.
- **WHEN** Sema resolves the call inside the deferred body
  > Inputs: The frozen declaration-context tree, overload sets, stable type identities, body token range, and immutable frontend options.
- **THEN** the typed call expression refers to the canonical callable declaration independent of file submission order or body scheduling
  > Observables: Mutual recursion and later-file callees use the same lookup path as earlier-file callees.
- **AND** body analysis cannot add, remove, or replace a declaration in the frozen environment
  > Verification: Any attempted declaration-environment mutation is rejected as a phase violation.
- **BUT** no source-level import, runtime function ID, asCObjectType pointer, live Builder, or live Engine participates in lookup
  > Boundaries: Source membership was established by the compilation request, not by runtime registration.

#### Scenario: Declaration errors gate body work predictably
- **WHEN** a declaration result contains errors that invalidate a function's signature or ownership context
- **THEN** the session skips that function body with a structured dependent diagnostic or marks it unavailable according to the declared recovery policy
  > Observables: Other functions with valid declarations may still be analyzed for additional diagnostics.
- **BUT** a skipped body never produces a valid executable or publication candidate
  > Boundaries: Diagnostic continuation is distinct from successful compilation.

### Requirement: Parser and Sema produce concrete typed statements and expressions

The frontend SHALL represent each supported statement and expression category with a concrete subclass from the typed AST and SHALL make Sema-authored types, value categories, declaration references, conversions, and control targets authoritative.

#### Scenario: An overloaded call requires conversions
- **GIVEN** a call expression whose arguments admit one best viable declaration after language-defined conversions
- **WHEN** Parser reports the syntactic call components to Sema
  > Details: Parser supplies source structure and delimiters; it does not select a runtime function or write semantic fields directly.
- **THEN** Sema selects the canonical function declaration and creates a concrete call expression with explicit typed conversion nodes where required
  > Observables:
  >
  > - The callee is a semantic declaration reference, not a runtime function ID.
  > - Each argument retains authored order and range while also mapping to its formal parameter.
  > - The result type and value category are queryable without re-running overload resolution.
- **BUT** no bytecode instruction, temporary stack slot, or VM call target is allocated
  > Boundaries: The AST records language meaning; later code generation chooses an executable representation.

#### Scenario: A statement establishes structured control targets
- **WHEN** Sema accepts a loop, switch, return, break, or continue statement
- **THEN** the concrete statement records its validated enclosing semantic target and source range
  > Observables: Invalid transfers receive diagnostics at the authored transfer statement.
- **AND** visitors can traverse the body without switching on one wide record's enum as the only type distinction
  > Verification: Type-safe casts or the typed visitor identify concrete statement and expression categories.

### Requirement: Body semantics include explicit lifetime and cleanup facts

The frontend SHALL compute language-level temporary materialization, scope cleanup, destruction, and exit-edge obligations as typed semantic facts before bytecode generation.

#### Scenario: Control exits nested scopes containing owned values
- **GIVEN** a function body with nested scopes, temporaries, and an early return, break, continue, or exceptional semantic failure edge supported by the language
- **WHEN** Sema finalizes the affected full expressions and structured control-flow regions
- **THEN** the function body owns an ordered cleanup plan for every applicable exit edge
  > Observables:
  >
  > 1. Full-expression temporaries end at their semantic boundary.
  > 2. Lexical objects are destroyed in the language-defined reverse order.
  > 3. Each transfer names the cleanup obligations between its source and target scopes.
- **AND** equivalent structured bodies produce equivalent lifetime facts before code generation
  > Verification: Focused tests inspect typed semantic objects and stable keys, not emitted bytecode.
- **BUT** stack offsets, VM registers, opcodes, and JIT metadata are absent
  > Boundaries: Lifetime meaning is stable frontend input to a later executable lowering.

#### Scenario: An invalid construction does not invent cleanup
- **WHEN** object construction or conversion fails semantically
- **THEN** Sema emits the structured diagnostic and marks the affected typed node invalid or recovered
- **BUT** the lifetime plan does not claim that an unconstructed object must be destroyed
  > Verification: Later valid statements still receive their own correct cleanup facts.

### Requirement: Body fragments are isolated and deterministic

The frontend SHALL permit eligible function bodies to be analyzed independently after the declaration barrier and SHALL finalize their typed AST, semantic facts, and diagnostics independently of worker scheduling.

#### Scenario: Bodies are analyzed with different worker counts
- **GIVEN** the same frozen declaration environment, source snapshot, deferred body ranges, and frontend options
- **WHEN** a session analyzes all eligible bodies once with one worker and once with multiple workers
- **THEN** both sessions produce equivalent concrete body trees, resolved references, conversions, control/lifetime facts, and diagnostic sequences
  > Observables: Equivalence uses stable function and declaration keys, concrete node categories, source ranges, and semantic fields rather than addresses.
- **AND** final body attachment follows canonical order
  > Verification:
  >
  > - Stable owning-function key is the primary ordering key.
  > - Logical source range and fragment-local ordinal break remaining ties.
- **BUT** workers do not share mutable Parser, Sema, AST arena, Engine, Builder, or module state
  > Boundaries: Cross-body references are reads from the frozen declaration environment.

### Requirement: Body recovery preserves typed structure and progress

The frontend SHALL recover from malformed statements and expressions with range-bearing typed recovery nodes, deterministic structured diagnostics, and guaranteed token progress.

#### Scenario: A malformed expression precedes a valid statement
- **WHEN** Parser encounters an incomplete or malformed expression and later reaches a balanced statement or block synchronization point
  > Details: Synchronization is grammar-aware and may use a semicolon, closing delimiter, case label, or statement starter; it never loops on an unconsumed token.
- **THEN** the body contains a concrete asCRecoveryExpr with canonical asCErrorType, or the matching typed recovery statement, for the malformed range and a normal concrete node for the later valid statement
  > Observables:
  >
  > - The primary diagnostic and related ranges are stable across worker counts.
  > - The recovered node is visitable but carries invalid semantic state.
- **AND** analysis continues with later eligible function bodies
  > Verification: A failure in one fragment does not erase independent diagnostics from another fragment.
- **BUT** a body containing unrecovered semantic errors is never executable or runtime-publishable
  > Boundaries: Recovery serves tooling and diagnostic completeness, not partial execution.

### Requirement: Body phase preserves declaration inputs and failure state
The body stage SHALL analyze retained preprocessed input and SHALL propagate every parsing or semantic failure to its owning result.

#### Scenario: Analyze a body with selected conditional branches
- **WHEN** declarations were collected under a frozen flag configuration
- **THEN** later body analysis sees only that configuration's selected statements and retains valid identifier ownership
- **AND** body errors prevent executable or finalized success even when declarations resolved
  > Observables: Empty/missing body output cannot be accepted merely because a parser return value was ignored.
