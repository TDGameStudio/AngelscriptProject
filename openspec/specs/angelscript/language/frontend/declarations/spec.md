## Purpose

Define the typed, Engine-independent declaration authority and the deterministic two-phase compilation boundary used before AngelScript function bodies or runtime artifacts are produced.

## Requirements

### Requirement: Parser and Sema produce the concrete typed declaration hierarchy

The frontend SHALL represent each supported declaration category with a concrete asCDecl subclass in the scope selected by BEGIN_AS_NAMESPACE created through Parser-to-Sema actions, and SHALL treat those nodes and their declaration contexts as the sole authority for declaration meaning.

#### Scenario: A declaration is accepted through a semantic action
- **GIVEN** a token stream containing a syntactically valid namespace, type, function, property, parameter, or local declaration header
  > Context: The typed-AST capability supplies concrete nodes, casting helpers, visitors and context-owned lifetime directly inside the existing AS namespace scope; no nested frontend namespace or compatibility type is required.
- **WHEN** asCParser reaches the declaration's grammar milestone
  > Inputs: asCParser(asCSema&) consumes the retained selected-token input supplied by the compilation session and passes typed source locations, parsed components, attributes, and unresolved type syntax to Sema; it does not hand Sema a generic property bag.
- **THEN** Sema creates the matching concrete declaration node and places it in its typed declaration context
  > Observables:
  >
  > - Clients distinguish declaration categories with concrete type-safe casts or visitation.
  > - Authored ranges and attributes remain attached to the typed declaration.
  > - Semantic identity and resolved type facts are written only by Sema.
- **BUT** neither Parser nor Sema constructs an asCObjectType, calls a live asCBuilder, or mutates an asCScriptEngine
  > Boundaries: Runtime candidates and transactional publication are later capabilities, not hidden side effects of declaration parsing.

#### Scenario: Function bodies are deferred at the declaration boundary
- **WHEN** collection reaches a function definition whose header and body are both present
- **THEN** the function's concrete declaration records its header semantics and a validated deferred body range
  > Observables: The declaration is available to every source file before expression or statement semantics begin.
- **BUT** declaration resolution does not create body Stmt or Expr semantics, bytecode, runtime functions, or VM state
  > Boundaries: The body range remains owned by the same immutable source snapshot and token provenance.

### Requirement: One compilation session establishes a declaration barrier before resolution

The frontend SHALL collect declarations from every logical source in the compilation request before resolving cross-declaration types, bases, signatures, and references.

#### Scenario: A declaration refers to a type authored later
- **GIVEN** two logical source files in one compilation request, where an earlier file names a type declared in a later file
  > Example: A.as declares B@ MakeB() while B.as later declares class B {}.
- **WHEN** the compilation session processes the request
  > Details: Collection records the unresolved type location in the function declaration, then the declaration barrier closes only after both files have contributed fragments.

  1. Collect every top-level and nested declaration header.
  2. Deterministically merge declaration contexts and canonical symbols.
  3. Resolve names, bases, and complete signatures against the frozen declaration set.
- **THEN** Sema resolves the reference to the same canonical type declaration regardless of source-file submission order
  > Observables: The resolved typed AST and structured diagnostics are equal for both orders.
- **AND** no source-level import directive or pre-registered runtime type stub is required
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
  > Verification: No edge contains an asCObjectType pointer, runtime type ID, function ID, or module registration slot.

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

### Requirement: Native callable type declarations
The Parser and Sema SHALL represent delegate and event as explicit callable-type declarations with single/multicast classification and structured signatures.

#### Scenario: Resolve a forward-referenced signature
- **WHEN** a delegate/event signature refers to a type collected later in the same source set
- **THEN** declaration collection retains the unresolved type location and declaration resolution supplies the canonical type and dependency
- **BUT** the frontend does not manufacture an AS wrapper struct or infer the signature from generated Execute/Broadcast methods

### Requirement: Removed asset and import syntax fails explicitly
The replacement frontend SHALL reject the legacy asset declaration and import syntax with source diagnostics and controlled recovery.

#### Scenario: Encounter an old asset declaration
- **WHEN** active source contains asset Name of Type followed by an initializer block
- **THEN** the Parser reports the removed syntax and can continue with the following declaration
- **BUT** no valid asset definition, generated variable, getter, initializer or postinit record is published

#### Scenario: Use ordinary asset identifiers or inactive old syntax
- **WHEN** asset/of occurs as an ordinary identifier, in a string/comment, or in a skipped conditional branch
- **THEN** the removed-declaration diagnostic is not emitted for that occurrence
  > Boundaries: Removal does not globally reserve asset/of or remove unrelated UE asset APIs.

### Requirement: Declaration membership is supplied by the compilation request

The declaration frontend SHALL obtain source membership and external provider definitions from the compilation request and SHALL reject source shared/external module-sharing policy and funcdef declarations.

#### Scenario: Resolve declarations across supplied files
- **GIVEN** two source files in one Session and a frozen externally supplied definition set
- **WHEN** declarations reference names in the other file or supplied provider
- **THEN** the normal declaration barrier and semantic lookup resolve them without shared/external modifiers or source funcdef registration
- **BUT** this contract does not discover files or schedule missing providers automatically

#### Scenario: Reject declaration-level compatibility syntax
- **WHEN** active source authors shared/external declaration modifiers, funcdef, a virtual property or a property decorator
- **THEN** the frontend reports an explicit removed-feature diagnostic and withholds publishable resolved declarations for the failed compilation

### Requirement: Ordinary methods do not synthesize virtual properties

The frontend SHALL treat get/set-shaped function names as ordinary functions and SHALL not infer an implicit property from them.

#### Scenario: Call explicit accessor-shaped methods
- **WHEN** a class declares and calls GetValue(), SetValue(int), get_Value() or set_Value(int) as ordinary methods
- **THEN** normal function resolution applies
- **BUT** those functions alone do not create a field named Value or permit property assignment syntax

### Requirement: Declaration failures retain specific semantic explanations

Declaration analysis SHALL report every current invalid declaration cause as a concrete structured diagnostic, retain the relevant authored name/type/attribute locations, and preserve independent declarations through controlled recovery.

#### Scenario: Resolve an unknown declaration type

- **GIVEN** a declaration names an unavailable type and a later independent function has a valid signature
- **WHEN** declaration resolution completes against the full collected source set
- **THEN** the unknown type diagnostic identifies its authored type use and requested name, while the independent function remains inspectable

    > Observables: The failure is present in the structured collection, not only a stable text projection.
- **BUT** the failed declaration does not satisfy another unresolved type reference or become a publication candidate

#### Scenario: Explain declaration conflicts and invalid annotations

- **WHEN** duplicate declarations, invalid inheritance/signatures or illegal annotation targets are encountered
- **THEN** the diagnostic identifies the specific cause and relevant declaration or annotation, with related-source notes where another declaration explains it

    > Examples: A duplicate points to the conflicting declaration and the prior declaration; an invalid parameter annotation identifies the parameter annotation rather than only setting an invalid bit.
- **AND** valid later declarations remain available after a grammar-appropriate recovery boundary

    > Boundaries: Recovery does not skip semantic checks on independent declarations or emit a generic follow-up for every use of one invalid declaration.
