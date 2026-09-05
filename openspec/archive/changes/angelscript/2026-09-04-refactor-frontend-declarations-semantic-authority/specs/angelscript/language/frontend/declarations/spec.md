## Purpose

Define the typed, Engine-independent declaration authority and the deterministic two-phase compilation boundary used before AngelScript function bodies or runtime artifacts are produced.

## ADDED Requirements

### Requirement: Parser and Sema produce the concrete typed declaration hierarchy

The frontend SHALL represent each supported declaration category with a concrete `frontend::asCDecl` subclass created through Parser-to-Sema actions, and SHALL treat those nodes and their declaration contexts as the sole authority for declaration meaning.

#### Scenario: A declaration is accepted through a semantic action
- **GIVEN** a token stream containing a syntactically valid namespace, type, function, property, parameter, or local declaration header
  > Context: The typed-AST capability supplies the final lowercase `frontend` namespace, concrete node hierarchy, casting helpers, visitors, and context-owned lifetime.
- **WHEN** `frontend::asCParser` reaches the declaration's grammar milestone
  > Inputs: `frontend::asCParser(frontend::asCPreprocessor&, frontend::asCSema&)` reads the preprocessor-owned active-token result and passes typed source locations, parsed components, attributes, and unresolved type syntax to Sema; it does not hand Sema a generic property bag.
- **THEN** Sema creates the matching concrete declaration node and places it in its typed declaration context
  > Observables:
  >
  > - Clients distinguish declaration categories with concrete type-safe casts or visitation.
  > - Authored ranges and attributes remain attached to the typed declaration.
  > - Semantic identity and resolved type facts are written only by Sema.
- **BUT** neither Parser nor Sema constructs an `asCObjectType`, calls a live `asCBuilder`, or mutates an `asCScriptEngine`
  > Boundaries: Runtime candidates and transactional publication are later capabilities, not hidden side effects of declaration parsing.

#### Scenario: Function bodies are deferred at the declaration boundary
- **WHEN** collection reaches a function definition whose header and body are both present
- **THEN** the function's concrete declaration records its header semantics and a validated deferred body range
  > Observables: The declaration is available to every source file before expression or statement semantics begin.
- **BUT** declaration resolution does not create body `Stmt` or `Expr` semantics, bytecode, runtime functions, or VM state
  > Boundaries: The body range remains owned by the same immutable source snapshot and token provenance.

### Requirement: One compilation session establishes a declaration barrier before resolution

The frontend SHALL collect declarations from every logical source in the compilation request before resolving cross-declaration types, bases, signatures, and references.

#### Scenario: A declaration refers to a type authored later
- **GIVEN** two logical source files in one compilation request, where an earlier file names a type declared in a later file
  > Example: `A.as` declares `B@ MakeB()` while `B.as` later declares `class B {}`.
- **WHEN** the compilation session processes the request
  > Details: Collection records the unresolved type location in the function declaration, then the declaration barrier closes only after both files have contributed fragments.

  1. Collect every top-level and nested declaration header.
  2. Deterministically merge declaration contexts and canonical symbols.
  3. Resolve names, bases, and complete signatures against the frozen declaration set.
- **THEN** Sema resolves the reference to the same canonical type declaration regardless of source-file submission order
  > Observables: The resolved typed AST and structured diagnostics are equal for both orders.
- **AND** no source-level `import` directive or pre-registered runtime type stub is required
  > Verification: The scenario contains only the two ordinary source files and the session input list.

#### Scenario: Declaration phases expose distinct allowed products
- **WHEN** a client observes the compilation session at a declared phase boundary
- **THEN** only the products allowed for that completed phase are visible

  | Completed phase | Visible typed products | Products that remain unavailable |
  |---|---|---|
  | Collection | Concrete declarations, scopes, attributes, unresolved type locations, deferred body ranges | Resolved cross-file types, body semantics, runtime objects |
  | Declaration resolution | Canonical symbols, resolved bases and signatures, declaration-reference edges, diagnostics | Body semantics, bytecode, Engine publication |
- **BUT** a client cannot resolve against a partially collected source set
  > Boundaries: Closing the collection barrier is an explicit one-way session transition.

### Requirement: Declaration lookup is source-order independent and stable-key based

The frontend SHALL perform declaration-context lookup, duplicate detection, overload-set formation, and type-reference resolution using frontend-owned canonical identities rather than runtime IDs, addresses, registration order, or mutable Engine tables.

#### Scenario: Equivalent source sets arrive in different orders
- **WHEN** two sessions receive byte-identical logical sources in different enumeration orders
- **THEN** their canonical declarations, lookup results, overload ordering, and diagnostic sequence are identical
  > Observables: Stable type and symbol keys, not insertion order, select the same declarations.
- **AND** declaration-reference edges point to typed declaration identities that remain valid for the frozen AST lifetime
  > Verification: No edge contains an `asCObjectType*`, runtime type ID, function ID, or module registration slot.

#### Scenario: Conflicting declarations are diagnosed deterministically
- **GIVEN** multiple files contribute declarations that conflict under the language's redeclaration rules
- **WHEN** Sema forms the canonical declaration set
- **THEN** it selects the same primary declaration and emits the same error and related-source notes for every worker count and input enumeration order
  > Observables:
  >
  > - The primary location is chosen by stable logical source ordering and byte range.
  > - Each conflicting declaration remains queryable as a typed invalid or redeclaration node.
- **BUT** conflict handling never publishes a partial winner to the Engine
  > Boundaries: A declaration result with errors is inspectable but not runtime-publishable.

### Requirement: Declaration fragments are isolated and merge deterministically

The frontend SHALL permit declaration fragments to be collected independently and SHALL make the finalized declaration result independent of worker scheduling.

#### Scenario: The same request uses one worker and several workers
- **GIVEN** immutable options, source snapshots, tokens, directive records, and stable identity inputs
- **WHEN** declaration collection executes once with one worker and once with multiple workers
- **THEN** both executions produce an equivalent typed declaration tree, canonical symbol index, reference set, and structured diagnostic sequence
  > Observables: Equality is assessed by stable keys, concrete node kinds, source ranges, semantic fields, and diagnostics rather than arena addresses.
- **AND** fragment merge follows a stable ordering rule
  > Verification:
  >
  > 1. Logical source key and source range order declarations.
  > 2. Stable semantic key and fragment-local ordinal break remaining ties.
- **BUT** worker completion order, atomics, pointer values, and thread IDs are not semantic inputs
  > Boundaries: Workers do not mutate one shared live Engine, Builder, or module registry.

### Requirement: Declaration recovery preserves later semantic work

The frontend SHALL represent recoverable declaration failures with typed recovery state, emit structured diagnostics, and continue at a grammar-appropriate synchronization point without treating recovered nodes as valid declarations.

#### Scenario: A malformed declaration precedes a valid declaration
- **WHEN** Parser encounters a malformed declaration header followed by a recoverable boundary and a valid declaration
  > Details: Recovery may synchronize at a balanced declaration terminator, closing brace, or another grammar-defined declaration starter.
- **THEN** the AST contains a range-bearing typed recovery or invalid declaration for the malformed construct and a normal concrete declaration for the later construct
  > Observables:
  >
  > - The primary diagnostic points at the malformed range and may carry fix-its or related ranges.
  > - The later declaration participates in lookup when its own semantics are valid.
- **AND** finalization marks the overall declaration result as containing errors
  > Verification: Inspection remains available for tooling and additional diagnostics.
- **BUT** invalid declarations cannot become canonical runtime candidates or satisfy otherwise unresolved type references
  > Boundaries: Recovery improves analysis continuity; it does not invent successful semantics.
