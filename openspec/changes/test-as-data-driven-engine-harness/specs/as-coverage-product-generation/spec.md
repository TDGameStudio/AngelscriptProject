## ADDED Requirements

### Requirement: Coverage generation is slice-based, not wholesale
The harness SHALL treat `AngelscriptTest/Coverage/` as eligible for product generation only on homogeneous type, width, or parameter-mode cartesian rows. The harness SHALL NOT provide a single generator that emits all Coverage `TEST_METHOD`s. This capability applies to the Coverage scenario suite under prefix `Angelscript.TestModule.Coverage.*`. It SHALL NOT be implemented as, or confused with, the Runtime CodeCoverage engine extension.

#### Scenario: Wholesale Coverage rewrite is rejected
- **WHEN** an author proposes one generator that replaces every file under `AngelscriptTest/Coverage/`
- **THEN** the change SHALL be rejected
- **AND** existing Coverage CQTest SHALL remain the suite until each migrated slice has its own generator and dual-run evidence

#### Scenario: CodeCoverage extension is out of scope
- **WHEN** a Coverage product generator is added
- **THEN** it SHALL generate AngelScript scenario products for `AngelscriptTest/Coverage/`
- **AND** it SHALL NOT change per-line CodeCoverage tracking APIs

### Requirement: Homogeneous Coverage axes generate; unique scenarios stay authored
A Coverage row SHALL be generated when the next cell is produced by substituting a type family, integer width, container element or key type, or function parameter mode into a shared template whose expected result is a formula or a shared compile-fail diagnostic. A Coverage row SHALL remain an authored fixture or CQTest when it is a unique API method, Actor or World lifecycle story, environment-bound feature, or one-off diagnostic.

#### Scenario: Int family expression operators generate
- **WHEN** Coverage IntExpression `ArithmeticOperators` or `BitwiseAndShiftOperators` is migrated
- **THEN** the harness SHALL emit one product leaf per integer width from a C++ table
- **AND** it SHALL NOT require checked-in files `LocalInt8.as` through `LocalUInt64.as`

#### Scenario: Int family UPROPERTY defaults use a class template
- **WHEN** Coverage IntProperty `IntFamilyDeclarationDefaults` is migrated
- **THEN** the generator SHALL emit one `UCLASS` Actor with one `UPROPERTY` per integer width from the same type table
- **AND** it SHALL NOT be authored as eight unrelated fixture files

#### Scenario: TArray Sort stays authored
- **WHEN** Coverage includes `TArray.Sort` on an Actor with `UPROPERTY` and `BeginPlay`
- **THEN** that source SHALL be an authored fixture or remain CQTest
- **AND** it SHALL NOT be produced by substituting type names into an expression or bitwise template

#### Scenario: FString methods stay authored
- **WHEN** Coverage includes `FString.Find`, `Split`, `Len`, or `Format`
- **THEN** those scenarios SHALL stay authored
- **AND** they SHALL NOT be emitted by a type-family expression generator

#### Scenario: Environment-bound domains stay authored
- **WHEN** a scenario belongs to Coverage matrices 10 through 18 (components, timer, input, physics, widget, networking, assets, debug, misc)
- **THEN** Wave B and later generate slices in this change SHALL NOT migrate that domain
- **AND** those tests SHALL remain Coverage CQTest until a later change explicitly classifies a homogeneous subset

### Requirement: Coverage generators use FAngelscriptEngine templates, not raw SDK products
Coverage product generators SHALL compile through `FAngelscriptEngine` and UE bindings. They SHALL NOT replace Coverage with Native SDK `asIScriptEngine` products. Reuse of `FNativeTypeCase` or `AppendGeneratedAsLine` is allowed only as a width table or source-emit helper.

#### Scenario: IntExpression products run on the test engine
- **WHEN** generator `coverage-int-expression-arithmetic` expands a leaf
- **THEN** that leaf SHALL compile and execute on `FAngelscriptEngine`
- **AND** it SHALL NOT be counted as an `Angelscript.TestModule.AngelScriptSDK.*` case

### Requirement: Pattern D property oracles stay on the C++ property taxonomy
A `uclass-property-family` Coverage product SHALL assert values through `FPropertyBindingPath` / `VerifyByPath` (or an equivalent C++ reflective helper on the spawned script Actor). The harness SHALL NOT treat a script getter that reads the same `UPROPERTY` as sufficient proof of the UE property mapping.

#### Scenario: IntProperty defaults keep VerifyByPath
- **WHEN** `IntFamilyDeclarationDefaults` is generated
- **THEN** the leaf SHALL spawn the generated script Actor and read each width through the matching `FNumericProperty` subclass
- **AND** a generated `int ObserveInt8()` that returns the field SHALL NOT be the only oracle

#### Scenario: Pattern B expression products use executeInt
- **WHEN** an IntExpression operator product has no UPROPERTY
- **THEN** the leaf SHALL use existing `executeInt` / `executeBool` observations
- **AND** it SHALL NOT require Actor spawn

### Requirement: Generated Coverage leaves keep coverage-matrix identity
Each generated Coverage product leaf SHALL record the `coverage-matrix.md` scenario name and the Coverage `TEST_METHOD` it replaces or dual-runs. `coverage-matrix.md` SHALL remain the scenario index. The harness SHALL NOT introduce a second undocumented Coverage matrix.

#### Scenario: ArithmeticOperators maps to the matrix row
- **WHEN** generator leaves for integer `+` are enumerated
- **THEN** each leaf identity SHALL include scenario `ArithmeticOperators`
- **AND** `openspec/changes/test-coverage/matrices/01-basic-types.md` SHALL remain the row that names that scenario

#### Scenario: Matrix column updates on retirement
- **WHEN** a Coverage `TEST_METHOD` is removed after dual-run parity
- **THEN** the matrix Coverage Test Method column SHALL name the DataDriven product prefix or generator id
- **AND** the scenario row SHALL NOT be deleted

### Requirement: Existing Coverage CQTest stays until dual-run parity
A Coverage CQTest method SHALL remain registered until the matching generated DataDriven leaves pass on the same oracles. The harness SHALL NOT delete a Coverage `TEST_METHOD` in the same change that first adds its generator unless both prefixes are green in one verification run and the matrix row is updated.

#### Scenario: Wave B keeps IntExpression CQTest
- **WHEN** `coverage-int-expression-arithmetic` leaves are added
- **THEN** `Angelscript.TestModule.Coverage.IntExpression` SHALL still discover `ArithmeticOperators`
- **AND** both prefixes SHALL be required green before that method may be removed

### Requirement: Wave B starts with Pattern B IntExpression only
The first Coverage generate slice SHALL be integer-family Expression operators using `expression-product` and existing `executeInt` observations. Pattern D `uclass-property-family` and Pattern C `ufunction-width-product` SHALL wait until the harness has spawn-and-reflect observations. Wave B SHALL NOT check in one `.as` file per integer width.

#### Scenario: First Coverage generator is IntExpression arithmetic
- **WHEN** Wave B is applied after the harness golden (`integral-bitwise` and Syntax fixtures)
- **THEN** the first Coverage generator SHALL cover IntExpression arithmetic
- **AND** it SHALL NOT migrate `AngelscriptCoverageIntPropertyTests.cpp` in that slice

#### Scenario: Wave B does not auto-add StaticJIT leaves
- **WHEN** `coverage-int-expression-arithmetic` lists only profile `vm`
- **THEN** enumeration SHALL NOT add a `typed-ast-generate` leaf for every integer width
- **AND** StaticJIT pairing SHALL require a separate isolated case that lists `typed-ast-generate`, using the same corpus materialize path as `integral-bitwise`

#### Scenario: Generated Coverage source stays in memory
- **WHEN** Coverage expression products expand
- **THEN** the harness SHALL emit memory-mount source
- **AND** it SHALL NOT add `Fixtures/Generated/int8_*.as` through `uint64_*.as`
