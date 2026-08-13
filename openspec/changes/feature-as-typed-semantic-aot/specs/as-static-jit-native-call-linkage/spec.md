## ADDED Requirements

### Requirement: External native calls require an explicit linkage contract

A generated StaticJIT project module SHALL directly name a native binding target only when its native-call descriptor proves an externally consumable declaration, linkage kind, owning module, supported typed ABI, and safe routing. Existing `NativeFunction`, `NativeMethod`, or generated C++ name metadata alone SHALL NOT prove cross-module linkability.

#### Scenario: Exported Runtime symbol is direct-callable

- **WHEN** a Runtime-owned scalar call target has external linkage, an includable declaration marked `ANGELSCRIPTRUNTIME_API`, a declared owning module/header, a matching typed ABI, and safe routing
- **THEN** TypedASTJIT may emit a direct call from the generated project module
- **AND** the generated module includes the declared header instead of redeclaring the symbol

#### Scenario: Existing native form has no external contract

- **WHEN** a binding has a legacy `NativeFunction` or `NativeMethod` spelling but no explicit external linkage descriptor
- **THEN** TypedASTJIT classifies it as non-direct
- **AND** it uses a proven scalar bridge or makes the root ineligible rather than guessing that the symbol is exported

#### Scenario: Declaration is visible but symbol is not exported

- **WHEN** a target declaration can be included but its out-of-line implementation belongs to another DLL and lacks that module's import/export API contract
- **THEN** the target is not externally direct-callable
- **AND** compile-only visibility is not reported as successful linkability

### Requirement: Header-inline and module-exported targets remain distinct

The native-call descriptor SHALL distinguish fully defined header-inline/template targets from out-of-line exported symbols and SHALL validate the dependencies needed by the generated consumer module.

#### Scenario: Header-inline target needs no DLL export

- **WHEN** the complete supported function or template specialization is defined in an includable header and every required dependency is legal for the generated module
- **THEN** it may be classified `HeaderInline`
- **AND** no `_API` export is required solely for that inline definition

#### Scenario: Engine-owned target uses its owning module API

- **WHEN** the direct target is already publicly declared and exported by an Unreal Engine module
- **THEN** its descriptor records that header and owning module
- **AND** the plugin does not add `ANGELSCRIPTRUNTIME_API` to the Engine declaration

#### Scenario: Private module dependency blocks direct inclusion

- **WHEN** a candidate header depends on a module that is not a legal public dependency of the generated project module
- **THEN** the candidate is not classified as a public direct-call surface
- **AND** Runtime may expose a narrow thunk or the call may bridge/fall back

### Requirement: Runtime exports a reviewed callable surface, not binding providers wholesale

Runtime-owned FBind implementations selected for external direct calls SHALL have a narrow includable declaration marked `ANGELSCRIPTRUNTIME_API`, or SHALL be reached through a narrow exported Runtime thunk when their provider/helper type should remain private.

#### Scenario: Private FBind helper receives an exported thunk

- **WHEN** an eligible scalar binding implementation is provider-private or declared only in `Bind_*.cpp`
- **THEN** Runtime may publish a stable `ANGELSCRIPTRUNTIME_API` thunk with the exact supported signature
- **AND** the generated module calls the thunk while the provider class remains private

#### Scenario: Selected helper is intentionally public

- **WHEN** a reviewed binding helper is itself an appropriate supported Runtime API
- **THEN** its declaration is moved to a legal public header and marked with `ANGELSCRIPTRUNTIME_API`
- **AND** its external native-call descriptor names that declaration, header, and owning module

#### Scenario: Binding registrar lambda remains private

- **WHEN** `FAngelscriptBind` uses a lambda only to register functions during bind installation
- **THEN** the registrar lambda is not exported and is not treated as a script-call target
- **AND** direct-call eligibility is determined from the registered callable target and its external descriptor

### Requirement: Missing linkage degrades to bridge or typed fallback

Failure to prove cross-module native linkage SHALL NOT produce generated code that relies on an unresolved symbol. The call classifier SHALL choose an exported/inline direct entry, an exported Runtime thunk, the scalar bridge, or typed root fallback in that order according to available contracts.

#### Scenario: Private target has a scalar bridge

- **WHEN** the resolved target has no external direct symbol but its scalar parameters, return, exception behavior, and routing are supported by the bridge
- **THEN** the TypedASTJIT caller remains eligible and invokes the bridge
- **AND** diagnostics identify the call as bridged because its native target is provider-private or unexported

#### Scenario: Private target cannot be bridged

- **WHEN** the resolved target is neither externally callable nor supported by the bridge
- **THEN** the root receives `UnsupportedCall` with a stable external-linkage detail and source span
- **AND** no C++ reference to the private symbol is emitted

### Requirement: Cross-DLL linkability is verified by a separate consumer module

Every Runtime-owned native symbol or thunk advertised as externally direct-callable SHALL be compiled and linked from a UE module other than `AngelscriptRuntime`; generated-text and same-module tests alone are insufficient evidence.

#### Scenario: Missing API export fails the contract test

- **WHEN** an advertised out-of-line Runtime symbol has an includable declaration but is missing `ANGELSCRIPTRUNTIME_API` or has internal linkage
- **THEN** the separate consumer-module build fails the linkage gate or its descriptor validation fails before generation
- **AND** the symbol cannot be accepted as an external direct target

#### Scenario: Exported target links and executes

- **WHEN** the consumer module includes the declared header, links the exported symbol/thunk, and invokes it with the supported scalar ABI
- **THEN** the cross-module link test passes
- **AND** an AOT fixture proves the generated provider calls the same target without a bridge
