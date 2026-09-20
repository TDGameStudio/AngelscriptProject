## Purpose

Define SDK-owned symbolic bytecode authored on private script functions without an Engine, then linked against the receiving Engine's admitted host and private dependencies at Registration.

## Requirements

### Requirement: Stable bytecode hangs on the function without an Engine

The SDK SHALL write Emit's stable bytecode onto `asCScriptFunction` without creating a public `asCByteCodeImage`, and SHALL keep that stream free of Engine addresses and numeric TypeIds.

#### Scenario: Emit a compiled script function

- **GIVEN** a snapshot Builder that successfully froze `int32 Identity(int32 V) { return V; }`
- **WHEN** `asCByteCodeEmitter` runs during default `RunThrough`, or a caller calls the public Emit API on that Builder
- **THEN** that function's `GetStableByteCode` view is non-empty and contains no Engine pointer or TypeId operand

    Public `asCByteCodeImage`, `asCExecutableFunction`, and `asCExecutableSnapshot` are not products of this path.

- **BUT** missing labels, invalid operand roles or incomplete bodies produce explicit errors rather than a successful empty stable body

#### Scenario: Inspect stable bytecode on the function

- **WHEN** a caller dumps a function's stable bytecode
- **THEN** the dump identifies instructions, symbol roles, readable names, stable keys and compatibility requirements
- **BUT** display names are never parsed to recover authoritative semantic structure

### Requirement: Registration is the only runtime bytecode writer

The SDK SHALL write interpreter runtime bytecode onto `asCScriptFunction` only during `asCEngineCompileRegistration` Link, after Install, and SHALL NOT generate that stream at Emit or at first Prepare.

#### Scenario: Link after Install makes a function Prepare-able

- **GIVEN** a Taken set whose script functions already have stable bytecode
- **WHEN** Registration Install+Link succeeds on a live Engine
- **THEN** each script function's runtime bytecode is present and a Context Prepare of that function succeeds
- **BUT** Prepare of the same function before Registration returns `asNO_FUNCTION`

    Prepare reads the runtime stream. It does not Emit and does not Link.

#### Scenario: Reject a late binding failure atomically

- **GIVEN** a submitted list whose earlier functions would link
- **WHEN** a later function fails identity, layout, or Link
- **THEN** the entire Registration fails with the offending stable symbol and expected/actual contract
- **AND** no script function from that list is callable

    Candidate runtime streams from the failed list are not observable as successful output.

### Requirement: Executable verification precedes publication

The SDK SHALL reject invalid instruction, operand, control-flow, symbol, stack and cleanup contracts before runtime bytecode becomes visible on a function.

#### Scenario: Validate malformed executable control flow

- **WHEN** a body contains an unknown or retired opcode, wrong operand width/role, out-of-range symbol, jump into an operand, inconsistent stack join, invalid local range or inconsistent construction/unwind record
- **THEN** verification identifies the failing instruction or contract and Registration publishes no callable runtime bytecode for that function

    - Operand and symbol contracts also apply to unreachable instructions. Duplicate function bodies or duplicate requirement identities cannot choose a publication winner by ordering.
    - Local and argument spans follow actual frame addressing and full access width. Declared argument storage and return cleanup agree with the complete callable ABI.
    - Direct and indirect calls consume authenticated argument storage; an indirect call carries an explicit expected signature, and a mismatched live target is rejected before callback entry.
    - Every conditional fallthrough and indexed-table successor participates in stack and lifetime joins. Runtime indexed dispatch rejects indices outside the verified table.
    - Temporary stack reservation includes the verified reachable peak in addition to local storage. Cleanup at each reachable point follows completed construction on that path.

- **BUT** structural verification is not represented as a security sandbox for arbitrary native host code

#### Scenario: Distinguish runtime instructions from compiler records

- **WHEN** an executable input contains retired `STR`, reserved dummy opcodes, or compiler-only VarDecl/Block/ObjInfo/LINE/LABEL records
- **THEN** it is explicitly rejected
- **AND** authoring labels are resolved separately without persisting compiler pseudo instructions as runtime code

### Requirement: Stable symbol linking is transactional and generation-owned

The SDK SHALL resolve complete canonical requirements to the current Engine's materialized TypeInfo and live bindings during Registration.Link, and publish runtime bytecode atomically only after identity, visibility, ownership, schema, layout and callable ABI checks succeed.

#### Scenario: Resolve a type use and callable in the current Engine

- **GIVEN** a live Engine with materialized publications, its private TypeInfo and explicit native/global bindings
- **WHEN** Registration links nominal, qualified and generic type symbols together with callable and property requirements
- **THEN** the function runtime stream uses that Engine's TypeInfo pointers, published IDs, lowered type uses, callable entries and field addresses

    Primitive type uses resolve to primitive storage. Specializations resolve by their complete canonical identity. FunctionKey equality never substitutes for complete return/parameter agreement.

- **BUT** global Registry lookup cannot supply a missing admission, and linking cannot attach unadmitted publications, adopt another Engine's TypeInfo, create missing definitions or treat metadata FunctionIds as legacy array indices

#### Scenario: Reject a late binding failure atomically

- **GIVEN** an image whose earlier symbols are valid
- **WHEN** a later symbol has missing storage/native binding, wrong role/owner, conflicting schema/layout/signature, invalid frozen witness or an existing executable body
- **THEN** the entire link fails with the offending stable symbol and expected/actual contract
- **AND** callable visibility, global storage, object ownership and live resources are unchanged

    > Candidate allocations and leases are released. A concurrent shutdown or publication conflict is rechecked at commit and cannot expose a partially prepared image.

#### Scenario: Bind one cache independently in two Engines

- **WHEN** two Engines with compatible admitted publications link the same cached image
- **THEN** each executes through its own snapshot and live TypeInfo
- **AND** releasing A does not invalidate B's execution
- **BUT** cache loading does not authorize foreign TypeInfo adoption or replacement of an installed body

#### Scenario: Bind one compile independently in two Engines

- **WHEN** two Engines with compatible admitted publications each Register their own Taken sets compiled from the same source
- **THEN** each executes through its own Function runtime bytecode and live TypeInfo
- **AND** releasing A does not invalidate B's execution
- **BUT** compiling source does not authorize foreign TypeInfo adoption or replacement of an installed body

### Requirement: Source emission consumes frozen definitions

The SDK SHALL compile the bounded supported AS source surface from its verified canonical frontend into Function-hung stable bytecode, without an Engine prerequisite or a legacy compiler fallback.

#### Scenario: Emit and execute a supported source function

- **GIVEN** verified, sealed source semantics on a Taken definition set
- **WHEN** a caller requests bytecode for supported basic expressions, control flow, calls and AS object operations
- **THEN** each script function holds stable bytecode, complete stable requirements, frame and cleanup contracts, and owned source observations

    The producer consumes typed declaration/call/conversion/transfer decisions rather than re-parsing source or AST dumps. Function identities match the frozen declarations; emission does not mutate them.

- **AND** `asCEngineCompileRegistration` on a live SDK Engine allows the interpreter to return the expected value and lifetime effects
- **BUT** successful AST inspection or definition construction alone is not executable compilation

#### Scenario: Preserve argument mapping and lazy evaluation

- **WHEN** supported source uses named or default arguments, short-circuit operators, or a conditional expression
- **THEN** execution preserves the maintained AS semantic decisions and evaluates only the required expressions

    - Calls map arguments into formal slots, then evaluate from last formal to first, exactly once per supplied or expanded default expression.
    - Named authoring order is not the evaluation order; source provenance remains distinct from formal placement.
    - A non-selected logical or conditional branch has no side effects and cannot raise its otherwise reachable runtime exception.

- **BUT** borrowing Clang code-generation architecture does not substitute C++ evaluation order or operator precedence for AS semantics

#### Scenario: Reject unready or unsupported source emission without partial output

- **WHEN** source contains errors or recovery nodes, its AST is unverified, its definitions do not match, or a valid node is outside the supported source-emission surface
- **THEN** emission returns a structured failure with source location when available and no usable partial stable bytecode

    Unsupported valid syntax is distinct from a frontend language error. An existing frontend rejection remains a regression control, not evidence that a new emitter has executed.

- **AND** no runtime bytecode is published and no native callback runs
- **BUT** an empty body, fabricated default return, or legacy compilation path cannot stand in for missing code generation

### Requirement: Source definition placement preserves published dependencies and private ownership

The SDK SHALL compile without an Engine and register private source TypeInfo and runtime bytecode only against the receiving Engine's admitted dependencies, retaining shared host graphs without transferring their ownership.

#### Scenario: Adopt compiled source using a prebuilt native type

- **GIVEN** a frozen HostProcess Pair graph supplied through Options.Dependencies
- **WHEN** source using Pair is compiled and registered on an Engine that injected that graph
- **THEN** the new script types/functions and runtime bytecode belong to that Engine, while Pair remains the same shared null-Engine object
- **BUT** an uninjected Engine cannot register or execute that source merely by possessing the frozen dependency pointer

#### Scenario: Retire private bytecode without retiring host definitions

- **GIVEN** A and B each register private script functions against one injected host Pair graph
- **WHEN** A's private bytecode and definitions retire
- **THEN** B's script execution and the shared Pair function/native leases remain valid

