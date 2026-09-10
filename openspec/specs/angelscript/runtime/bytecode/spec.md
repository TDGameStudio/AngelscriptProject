## Purpose

Define SDK-owned symbolic executable images that can be authored, inspected and cached independently of an Engine, then safely bound to pre-registered current runtime definitions.

## Requirements

### Requirement: Executable images are independent of source compilation and runtime identity

The SDK SHALL author and inspect executable bytecode with explicit signatures, frame contracts and typed stable symbols without creating a Builder, compiling source or persisting runtime addresses and IDs.

#### Scenario: Author a function using stable type and callable symbols

- **WHEN** a caller supplies a complete function signature, typed operands, labels and required runtime resources to the image builder
- **THEN** it produces an immutable image with compact image-local symbol slots and sufficient frame, local-object and unwind information for execution

    > Symbols distinguish nominal types, qualified type uses, specializations, callables, properties, globals and string resources. An image-local slot is not an Engine ID.

- **BUT** missing labels, invalid operand roles or incomplete bodies produce explicit errors rather than successful empty output

#### Scenario: Inspect persistent bytecode

- **WHEN** a caller dumps an encoded or decoded image
- **THEN** the dump identifies instructions, symbol roles, readable names, stable keys and compatibility requirements
- **BUT** display names are never parsed to recover authoritative semantic structure

### Requirement: Bytecode persistence is versioned and definition-free

The SDK SHALL persist executable bodies and complete symbol requirements in a deterministic bounded format while requiring destination definitions and mutable storage to be supplied independently.

#### Scenario: Load code against pre-existing definitions

- **GIVEN** a fresh Engine with compatible frozen types, all callable declarations, and global declarations with storage
- **WHEN** it loads a compatible symbolic bytecode image
- **THEN** cached bodies and string constants can bind to those current definitions without compiling source
- **BUT** the cache does not reconstruct types, global or member callable declarations, native addresses, global values, heap objects or suspended stacks

    > The rule is uniform for free functions, methods, constructors, destructors and native declarations. A signature in the cache authenticates a definition; it is not permission to create one.

#### Scenario: Reject an incompatible or corrupt wire image

- **WHEN** an image has an unsupported format/opcode/target/storage ABI, malformed section, invalid count, overflow, excessive nesting or missing dependency requirement
- **THEN** decoding or admission returns a specific failure without exposing a partial image or Engine mutation

    > The supported format requires the selected architecture, endianness, pointer width and storage/call ABI. Equal nominal keys do not make native bytecode cross-target portable.

#### Scenario: Encode equivalent symbolic input deterministically

- **WHEN** equivalent functions and requirements are supplied in different discovery or registration orders
- **THEN** canonical ordering and slot remapping yield byte-for-byte equal encoded output
- **AND** each decoded canonical witness is authenticated, including an explicit rejection of injected hash collisions

### Requirement: Executable verification precedes publication

The SDK SHALL reject invalid instruction, operand, control-flow, symbol, stack and cleanup contracts before an executable becomes visible.

#### Scenario: Validate malformed executable control flow

- **WHEN** a body contains an unknown or retired opcode, wrong operand width/role, out-of-range symbol, jump into an operand, inconsistent stack join, invalid local range or inconsistent construction/unwind record
- **THEN** verification identifies the failing instruction or contract and returns no executable snapshot

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

The SDK SHALL resolve complete canonical requirements to the current Engine's materialized TypeInfo and live bindings, and publish executable resources atomically only after identity, visibility, ownership, schema, layout and callable ABI checks succeed.

#### Scenario: Resolve a type use and callable in the current Engine

- **GIVEN** a live Engine with materialized publications, its private TypeInfo and explicit native/global bindings
- **WHEN** it links nominal, qualified and generic type symbols together with callable and property requirements
- **THEN** the snapshot exposes that Engine's TypeInfo pointers, published IDs, lowered type uses, callable entries and field addresses

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

### Requirement: Canonical source compilation produces the same verified executable image

The SDK SHALL compile the bounded supported AS source surface from its verified canonical frontend into the same symbolic executable format used by direct bytecode authoring, without an Engine prerequisite or a legacy compiler fallback.

#### Scenario: Emit and execute a supported source function

- **GIVEN** verified, sealed source semantics and matching authenticated frozen definitions
- **WHEN** a caller requests bytecode for supported basic expressions, control flow, calls and AS object operations
- **THEN** the resulting image contains executable bodies, complete stable requirements, frame and cleanup contracts, and owned source observations

    > The producer consumes typed declaration/call/conversion/transfer decisions rather than re-parsing source or AST dumps. Function identities match the frozen declarations; emission does not mutate them.

- **AND** explicit registration and linking in a live SDK Engine allow the real interpreter to return the expected value and lifetime effects
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
- **THEN** emission returns a structured failure with source location when available and no usable partial image

    > Unsupported valid syntax is distinct from a frontend language error. An existing frontend rejection remains a regression control, not evidence that a new emitter has executed.

- **AND** no executable body is published and no native callback runs
- **BUT** an empty body, fabricated default return, or legacy compilation path cannot stand in for missing code generation

#### Scenario: Source-produced cache retains definition-free loading

- **WHEN** a source-produced image is encoded, its producer inputs are released, and another Engine supplies compatible TypeInfo independently
- **THEN** decoding, linking and actual execution preserve expected results through that Engine's own bindings
- **BUT** source provenance and cached signatures cannot create missing TypeInfo, restore live values, attach an unadmitted publication or adopt another Engine's TypeInfo

### Requirement: Source definition placement preserves published dependencies and private ownership

The SDK SHALL keep source compilation engine-independent and SHALL allow the receiving Engine to uniquely own successful private TypeInfo batches that reference only its admitted publications.

#### Scenario: Adopt compiled source using a prebuilt native type

- **GIVEN** a published Pair record materialized in the receiving Engine
- **WHEN** source compilation produces a function that uses Pair
- **THEN** the compiled TypeInfo/functions belong to that Engine
- **BUT** another Engine must materialize Pair itself before linking the same cache
