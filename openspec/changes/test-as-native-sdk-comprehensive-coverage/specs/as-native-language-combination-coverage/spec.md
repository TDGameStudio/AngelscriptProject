## ADDED Requirements

### Requirement: Core language coverage SHALL be defined by explicit semantic dimensions
The native SDK suite SHALL maintain source-controlled coverage catalogs for declarations, functions, variables, properties, constructors, destructors, inheritance, references, expressions, operators, conversions, control flow, `foreach`, and exceptions. Each catalog entry SHALL identify its syntax element, dimension values, current-fork or selected-2.38 classification, expected result, evidence layers, and final test owner.

#### Scenario: A language theme is evaluated for completion
- **WHEN** a language theme is audited
- **THEN** every required dimension value SHALL have an implemented coverage ID, an approved concrete exclusion, an API-deferred disposition, or a compiled Disabled selected-2.38 test
- **AND** a file, method, assertion, or source-line count alone SHALL NOT make the theme complete

#### Scenario: A new fork syntax or semantic path is introduced
- **WHEN** vendored-source work adds or changes a core syntax or semantic path
- **THEN** the owning catalog SHALL be updated with its dimensions, interactions, classification, and expected evidence before the suite is represented as complete

### Requirement: Interacting local dimensions SHALL receive complete Cartesian-product coverage
Dimensions that participate in the same parsing, resolution, ABI, execution, state, or lifetime decision SHALL be exercised as a complete legal or constrained Cartesian product. An omitted cell MUST name a proven semantic-independence rule, structural impossibility, current-fork rejection, or absent API.

#### Scenario: A compact function-parameter contract is implemented
- **WHEN** parameter type, direction, position, and arity affect argument binding or writeback
- **THEN** every legal cell in the declared local product SHALL have a stable coverage ID and type-correct runtime evidence
- **AND** invalid temporary, const, direction, type, or arity cells SHALL have isolated diagnostics

#### Scenario: A product is reduced
- **WHEN** an implementation proposes representative values instead of all catalog cells
- **THEN** the catalog SHALL record source-backed proof that the reduced axes use one semantically identical path
- **AND** all distinct boundaries and rejection rules SHALL remain covered

### Requirement: Function and parameter-list coverage SHALL be comprehensive
Function tests SHALL cover call target, arity, parameter position, every core type category, value/`in`/`out`/`inout`, constness, argument source, defaults, returns, overload resolution, recursion, indirect calls, exceptions, and lifecycle interactions according to `coverage/functions.md`.

#### Scenario: Parameter direction is tested
- **WHEN** a supported core type can appear as a parameter
- **THEN** every legal direction SHALL validate exact declaration lookup, input transfer, output writeback, argument position, ABI slot order, and cleanup

#### Scenario: Defaults and overloads interact
- **WHEN** omitted/defaulted arguments and conversions can select more than one overload
- **THEN** the test SHALL assert the selected function identity and runtime result for every required cell
- **AND** ambiguity and no-match cells SHALL assert one authoritative diagnostic

#### Scenario: A value object crosses a call boundary
- **WHEN** a value object is passed, returned, copied, or unwound through a function
- **THEN** construction, copy/assignment, result value, independence or aliasing, destruction order, and exception cleanup SHALL be observable

### Requirement: Object-language coverage SHALL include complete lifecycle and dispatch interactions
Properties, constructors, destructors, inheritance, and automatic references SHALL cover storage, initialization, access, overload/dispatch, aliasing, null, copy, teardown, and exception paths across base/member/derived relationships.

#### Scenario: Construction succeeds through inheritance
- **WHEN** a derived object has base and member initialization
- **THEN** declaration-order initialization, constructor body order, final field/property values, virtual/non-virtual dispatch boundaries, and reverse destruction SHALL be asserted

#### Scenario: Construction fails partway
- **WHEN** an exception occurs at a base, member, or derived initialization point
- **THEN** only initialized objects SHALL be destroyed exactly once in reverse order
- **AND** the context SHALL be reusable through the documented cleanup sequence

#### Scenario: An automatic reference is used
- **WHEN** a reference is assigned, passed, returned, cast, compared, or dereferenced
- **THEN** identity, null state, qualifier, lifetime, overload resolution, and mutation visibility SHALL match the current fork's automatic-reference rules
- **AND** explicit-handle syntax SHALL remain a separate enabled fork-rejection test

### Requirement: Expression, operator, and conversion coverage SHALL cross type and value categories
Every supported built-in operator SHALL be crossed with its supported operand categories, relevant mixed-type pairs, value boundaries, value categories, and result contexts. Primitive conversions SHALL cover the complete constrained source-type × target-type × implicit/explicit space.

#### Scenario: A built-in operator is audited
- **WHEN** an operator token is supported for one or more operand categories
- **THEN** all supported categories and relevant mixed pairs SHALL have runtime results at normal and boundary values
- **AND** const, lvalue, divide/shift, overflow, and unsupported-type boundaries SHALL have exact outcomes

#### Scenario: Numeric conversion is audited
- **WHEN** one primitive type converts to another
- **THEN** implicit and explicit acceptance SHALL be recorded for the type pair
- **AND** accepted cells SHALL validate zero, sign, range, narrowing, and fractional boundaries applicable to that pair

#### Scenario: An overloaded operator participates in another expression
- **WHEN** an overloaded result is converted, assigned, passed to an overload, or used as a condition
- **THEN** selected operator/function identities, evaluation order, side effects, and final runtime result SHALL be asserted

### Requirement: Statement coverage SHALL include control transfer, nesting, and lifetime
Conditionals, loops, switches, jumps, and `foreach` SHALL cover empty/one/many execution, mixed nesting, target selection, side effects, invalid placement, bytecode targets, and cleanup on every transfer path.

#### Scenario: A loop family is tested
- **WHEN** `while`, `do while`, or classic `for` executes
- **THEN** zero, one, and many iteration cases SHALL cross normal completion, break, continue, and return where legal
- **AND** condition/body/increment counts and local lifetime SHALL be asserted

#### Scenario: A switch is tested
- **WHEN** a supported selector category enters a switch
- **THEN** first/middle/last match, default, no match, grouped cases, and current fallthrough behavior SHALL be asserted
- **AND** duplicate/non-constant/unsupported cases SHALL have isolated diagnostics

#### Scenario: Foreach lowers through the fork protocol
- **WHEN** a minimal non-add-on iterable is used
- **THEN** empty/one/many inputs, value/reference variables, mutation, nesting, transfers, overload resolution, and iterator cleanup SHALL be covered
- **AND** every missing or malformed protocol member SHALL own a diagnostic case

### Requirement: Exception coverage SHALL correlate propagation, cleanup, metadata, and reuse
Supported exception origins SHALL be crossed with call depth, handling mode, live object state, debug metadata, and follow-up context operations.

#### Scenario: An uncaught nested exception occurs
- **WHEN** a nested or recursive call raises an uncaught exception
- **THEN** context result, text, function, section, row/column, call-stack order, live locals/`this`, and reverse cleanup SHALL agree
- **AND** documented unprepare/prepare reuse with a differently shaped function SHALL succeed

#### Scenario: An exception is caught or rethrown
- **WHEN** nested handlers and rethrow are supported by the current fork
- **THEN** nearest-handler selection, message/origin behavior, cleanup, and continuation SHALL be asserted for every required handling cell

### Requirement: Cross-theme interaction chains SHALL remain explicit
The suite SHALL implement the named chains in `coverage/cross-theme-interactions.md` so completing isolated themes cannot hide resolution, lifetime, serialization, optimization, module, GC, or debug failures.

#### Scenario: Theme catalogs are individually complete
- **WHEN** all isolated theme rows are implemented but a required cross-theme chain is missing
- **THEN** the language capability SHALL remain incomplete

#### Scenario: One test owns a shared interaction
- **WHEN** a chain is naturally owned by one risk-bearing transition
- **THEN** one test MAY satisfy multiple catalogs through the same stable coverage ID
- **AND** duplicate tests SHALL NOT be required solely to inflate per-theme counts
