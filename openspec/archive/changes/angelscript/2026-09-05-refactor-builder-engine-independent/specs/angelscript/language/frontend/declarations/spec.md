## MODIFIED Requirements

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

## ADDED Requirements

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
