# as-haze-macro-removal Specification

## Purpose
TBD - created by archiving change refactor-as-audit-remove-with-angelscript-haze. Update Purpose after archive.
## Requirements
### Requirement: Haze macro is absent from active source

The `WITH_ANGELSCRIPT_HAZE` preprocessor symbol SHALL NOT be defined, tested, assigned from, or otherwise referenced by active source files.

#### Scenario: Macro definition is absent from runtime header

- **WHEN** `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` is read
- **THEN** the file SHALL NOT contain `#ifndef WITH_ANGELSCRIPT_HAZE`, `#define WITH_ANGELSCRIPT_HAZE`, or any reference to `WITH_ANGELSCRIPT_HAZE`

#### Scenario: Active source search returns zero matches

- **WHEN** `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` runs from the repository root
- **THEN** zero matches SHALL be returned

#### Scenario: Historical OpenSpec records may mention removed macro

- **WHEN** OpenSpec change records or archived change records mention `WITH_ANGELSCRIPT_HAZE`
- **THEN** those mentions SHALL be treated as historical documentation, not active implementation references

### Requirement: Standard UE RPC remains supported

Removing the Haze fork SHALL NOT remove or weaken the standard UE RPC path used by AngelScript UFUNCTION declarations.

#### Scenario: Standard RPC specifiers remain recognised

- **WHEN** a script declares standard UE RPC UFUNCTION specifiers such as `Server`, `Client`, `NetMulticast`, reliability, or validation
- **THEN** the AngelScript preprocessor and class generator SHALL continue to produce the standard UE networking flags and behavior

#### Scenario: UHT generic RPC detection remains intact

- **WHEN** the UHT tool inspects standard UE RPC functions
- **THEN** generic helper names such as `IsRpcNetFunction` SHALL continue to mean "standard UE network UFunction" and SHALL NOT be removed merely because they contain `NetFunction`

### Requirement: Hazelight-only RPC specifiers are unrecognised

The fork SHALL NOT recognise the Hazelight-only UFUNCTION specifiers `NetFunction`, `CrumbFunction`, or `DevFunction`.

#### Scenario: NetFunction specifier on a UFUNCTION

- **WHEN** an AngelScript source declares `UFUNCTION(NetFunction)`
- **THEN** the AngelScript preprocessor SHALL emit an unknown-specifier error

#### Scenario: CrumbFunction or DevFunction specifier on a UFUNCTION

- **WHEN** an AngelScript source declares `UFUNCTION(CrumbFunction)` or `UFUNCTION(DevFunction)`
- **THEN** the AngelScript preprocessor SHALL emit an unknown-specifier error

### Requirement: Hazelight-only RPC metadata is removed

Runtime, precompiled, and dump metadata SHALL NOT keep fields that only existed to persist the removed Hazelight-only RPC path.

#### Scenario: Function descriptors omit Haze-only fields

- **WHEN** `FAngelscriptFunctionDesc` is read
- **THEN** it SHALL NOT contain `bNetFunction` or `bDevFunction`

#### Scenario: StaticJIT precompiled data omits Haze-only fields

- **WHEN** `StaticJIT/PrecompiledData.h` and `StaticJIT/PrecompiledData.cpp` are read
- **THEN** they SHALL NOT serialize, load, or restore `bNetFunction` or `bDevFunction`

#### Scenario: State dump omits Haze-only columns

- **WHEN** Angelscript state dump output includes function descriptor columns
- **THEN** it SHALL NOT include a `bNetFunction` column that reflects the removed Haze-only path

#### Scenario: Generated UFunctions do not set Haze-only flags

- **WHEN** `AngelscriptClassGenerator` finalizes a script-defined UFunction
- **THEN** the resulting `UFunction` SHALL NOT be assigned `FUNC_NetFunction`, `FUNC_DevFunction`, `HazeFunctionFlags`, or `HAZEFUNC_CrumbFunction`

### Requirement: AActor instigator accessors use UE-original names

The AngelScript `AActor` binding SHALL expose instigator helpers under the UE-canonical names `GetInstigator()` and `GetInstigatorController()` rather than `GetActorInstigator()` and `GetActorInstigatorController()`.

#### Scenario: Script calls GetInstigator on an actor

- **WHEN** a script invokes `actor.GetInstigator()` on an `AActor` reference
- **THEN** the call SHALL compile and return the actor's `Instigator` `APawn`, or `null` when no instigator is set

#### Scenario: Script calls GetInstigatorController on an actor

- **WHEN** a script invokes `actor.GetInstigatorController()` on an `AActor` reference
- **THEN** the call SHALL compile and return the actor's instigator-derived `AController`, or `null` when no controller is available

#### Scenario: Old names no longer compile

- **WHEN** a script invokes `actor.GetActorInstigator()` or `actor.GetActorInstigatorController()`
- **THEN** compilation SHALL fail with the standard no-matching-method diagnostic

### Requirement: AsyncTrace globals live in the System namespace

Asynchronous trace global helpers SHALL be exposed only under the current non-Haze `System` namespace.

#### Scenario: Calling async trace from script

- **WHEN** a script invokes asynchronous tracing helpers
- **THEN** the script SHALL use `System::AsyncLineTraceByChannel(...)` and related helpers
- **AND** the alternative `AsyncTrace::` namespace SHALL NOT be registered

### Requirement: AS_ENSURE is permanently ensureMsgf

`AS_ENSURE` in `ASClass.cpp` SHALL expand to `ensureMsgf` unconditionally.

#### Scenario: ASClass.cpp defines AS_ENSURE without conditional

- **WHEN** `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp` is read
- **THEN** the file SHALL contain `#define AS_ENSURE ensureMsgf` without a `WITH_ANGELSCRIPT_HAZE` guard
- **AND** the alternate `devEnsure` mapping SHALL NOT be present

### Requirement: Debugger protocol no longer carries the Haze flag

`FAngelscriptDebugDatabaseSettings` SHALL NOT contain `bUseAngelscriptHaze`, and the debug server SHALL NOT emit or assign that field.

#### Scenario: Protocol struct is missing the field

- **WHEN** `FAngelscriptDebugDatabaseSettings` is searched
- **THEN** no `bUseAngelscriptHaze` member SHALL exist

#### Scenario: Debug server does not assign the field

- **WHEN** `AngelscriptDebugServer.cpp` is searched
- **THEN** no statement SHALL assign to `DebugSettings.bUseAngelscriptHaze`

#### Scenario: Debugger test no longer mirrors the removed flag

- **WHEN** `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerDatabaseTests.cpp` is searched for `bUseAngelscriptHaze`
- **THEN** zero matches SHALL be returned

### Requirement: Functional baseline holds after macro removal

The catalogued automation baseline SHALL pass after the macro removal is implemented.

#### Scenario: Build passes

- **WHEN** `Tools\RunBuild.ps1 -Label haze-final -TimeoutMs 900000` runs after implementation
- **THEN** the build SHALL exit with code 0

#### Scenario: Functional suite passes

- **WHEN** `Tools\RunTests.ps1 -Suite Functional -Label haze-final-functional -TimeoutMs 900000` runs after implementation
- **THEN** the functional baseline SHALL pass without newly disabled tests

