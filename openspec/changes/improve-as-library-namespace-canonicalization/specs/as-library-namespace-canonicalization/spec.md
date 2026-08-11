## ADDED Requirements

### Requirement: Function-library namespaces are selected by exact canonical mappings
The system SHALL support restart-required settings that map a function-library owner by stable Unreal class path to exactly one canonical Angelscript namespace.

#### Scenario: Built-in Math mappings are present by default
- **WHEN** the default Angelscript settings are used
- **THEN** `/Script/Engine.KismetMathLibrary` MUST map to `FMath`
- **AND** `/Script/AngelscriptRuntime.AngelscriptMathLibrary` MUST map to `FMath`

#### Scenario: A project maps another library
- **WHEN** a project configures a syntactically valid class path and Angelscript namespace
- **THEN** static namespace functions owned by that class MUST use the configured canonical namespace after restart

#### Scenario: Multiple libraries converge intentionally
- **WHEN** different class paths map to the same canonical namespace
- **THEN** the resolver MUST allow them to contribute to one namespace subject to declaration-collision validation

### Requirement: Canonical resolution preserves receiver methods and deterministic fallbacks
The system SHALL resolve compatible `ScriptMethod` and `ScriptMixin` receiver placement before consulting the canonical function-library namespace map, and SHALL use the registered AS type name when no exact mapping or intentional internal mixin static-factory namespace applies.

#### Scenario: Kismet Math receiver method remains on its type
- **WHEN** a `UKismetMathLibrary` function has a compatible `ScriptMethod` receiver
- **THEN** the function MUST remain a method on the receiver type
- **AND** mapping `UKismetMathLibrary` to `FMath` MUST NOT duplicate that method under `FMath`

#### Scenario: Internal mixin static factory keeps its authored type namespace
- **WHEN** an internal mixin library uses class `ScriptName` to host a valid non-receiver static factory such as an `FQuat` factory
- **AND** the owner has no exact canonical mapping
- **THEN** the static factory MUST retain its authored type-static namespace

#### Scenario: Unmapped ordinary Blueprint library uses full registered name
- **WHEN** an ordinary Blueprint function library has no exact canonical mapping
- **THEN** its static namespace functions MUST use the library's registered Angelscript type name
- **AND** class `ScriptName`, prefix stripping, and suffix stripping MUST NOT shorten that namespace

### Requirement: FMath is the sole default public Math namespace
The default initialized engine SHALL publish manual FMath globals, non-mixin `UAngelscriptMathLibrary` functions, and non-mixin `UKismetMathLibrary` static functions only through `FMath`.

#### Scenario: Representative functions from every Math source compile
- **WHEN** script calls representative manual FMath, `UAngelscriptMathLibrary`, and `UKismetMathLibrary` namespace functions through `FMath::`
- **THEN** each call MUST compile and bind to exactly one callable declaration

#### Scenario: Legacy Math namespace is rejected
- **WHEN** script calls a canonical Math function through `Math::`
- **THEN** compilation MUST fail because no `Math` namespace alias or redirect is registered

#### Scenario: Engine MathLibrary namespace is rejected
- **WHEN** script calls a canonical Math function through `MathLibrary::`
- **THEN** compilation MUST fail because class `ScriptName="MathLibrary"` does not create a public alias

#### Scenario: Legacy namespace is absent from discovery
- **WHEN** a consumer enumerates the initialized AS engine, generated API data, or an offline bundle
- **THEN** Math namespace callables MUST appear under `FMath`
- **AND** equivalent `Math` and `MathLibrary` namespace entries MUST be absent

### Requirement: Canonical namespace configuration is validated before publication
The system MUST validate and snapshot canonical function-library namespace settings before parallel reflected-function preparation or public API publication.

#### Scenario: Invalid class path is rejected
- **WHEN** a mapping contains an empty or syntactically invalid Unreal class path
- **THEN** engine binding MUST fail with a diagnostic that identifies the offending mapping

#### Scenario: Invalid namespace is rejected
- **WHEN** a mapping contains an empty or syntactically invalid Angelscript qualified namespace
- **THEN** engine binding MUST fail with a diagnostic that identifies the class path and namespace

#### Scenario: Conflicting duplicate class mapping is rejected
- **WHEN** the same class path is configured more than once with different canonical namespaces
- **THEN** engine binding MUST fail instead of selecting an entry by iteration order

#### Scenario: Identical duplicate class mapping is stable
- **WHEN** config layering produces repeated identical class-path and namespace pairs
- **THEN** the resolver MUST collapse them to one mapping without publishing duplicate declarations

#### Scenario: Optional library is not loaded
- **WHEN** a syntactically valid mapped class path is not loaded or installed in the current target
- **THEN** resolver construction MUST NOT load that class or fail solely because it is absent

### Requirement: Converged libraries use complete declaration identity
When multiple sources contribute to one canonical namespace, the system SHALL distinguish exact duplicates, valid overloads, and incompatible collisions by complete AS declaration identity.

#### Scenario: Explicit binding wins an exact duplicate
- **WHEN** a reflected mapped function has the same canonical namespace and complete AS declaration as an existing manual explicit binding
- **THEN** the existing explicit binding MUST remain authoritative
- **AND** the reflected duplicate MUST NOT create a second public callable

#### Scenario: Valid overload remains visible
- **WHEN** two mapped sources contribute the same function name with different valid parameter declarations
- **THEN** both declarations MUST remain available as overloads in the canonical namespace

#### Scenario: Return or modifier collision fails
- **WHEN** an incoming function has the same namespace, name, and parameter identity as an existing callable but an incompatible return or declaration shape
- **THEN** binding MUST fail with a diagnostic containing the canonical namespace, incoming owner class path, incoming declaration, and existing declaration

### Requirement: Canonical namespace identity is shared by runtime and observers
Each Angelscript engine context SHALL own an immutable validated namespace resolver, and downstream systems SHALL consume the namespace stored on initialized AS declarations without maintaining separate rewrite tables.

#### Scenario: Multiple engine contexts agree
- **WHEN** multiple engine contexts initialize from the same settings snapshot
- **THEN** they MUST resolve the same library class to the same canonical namespace

#### Scenario: Parallel reflection reads immutable policy
- **WHEN** reflected UFunctions are prepared on worker threads
- **THEN** namespace resolution MUST read only the target engine's immutable resolver snapshot

#### Scenario: Static JIT preserves canonical namespace
- **WHEN** precompiled data or generated Static JIT output references a canonical Math callable
- **THEN** its AS identity MUST use `FMath`
- **AND** Static JIT MUST NOT contain a separate `Math` or `MathLibrary` rewrite policy

#### Scenario: Offline bundle preserves canonical namespace
- **WHEN** the offline exporter serializes the initialized engine surface
- **THEN** the emitted callable namespace MUST match the initialized declaration's `FMath` namespace
- **AND** the exporter MUST NOT synthesize aliases or rewrite namespaces independently

## Testing Requirements

- Target test layers: Runtime Integration, FunctionLibraries CQTest, Bindings/Coverage, StaticJIT, Dump/offline export, HotReload, and Standalone CTest.
- Expected Automation prefixes: `Angelscript.TestModule.FunctionLibraries.Namespace`, `Angelscript.TestModule.FunctionLibraries.Math`, `Angelscript.TestModule.Bindings.Math`, `Angelscript.TestModule.Coverage.MathNamespaceFunctions`, `Angelscript.TestModule.StaticJIT`, `Angelscript.TestModule.CppTests.OfflineContract.Core`, and `Angelscript.TestModule.HotReload.NativeScript`.
- New test files MUST start with `Angelscript` and use existing engine/module fixtures rather than creating a second binding harness.
- Verification entry points MUST be `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`, and OpenSpec validation for record structure.
