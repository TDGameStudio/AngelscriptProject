## ADDED Requirements

### Requirement: Register attaches per-file asCModule identity

The SDK SHALL, when `asCEngineCompileRegistration` registers a compiled definition set together with that compile's `asCCompileOutput`, construct one `asCModule` per CompileOutput module, bind it to the receiving Engine, and attach the script types that belong to that module's logical source.

#### Scenario: Two source files become two modules

- **GIVEN** a successful Builder compile of `First.as` containing `class First {}` and `Second.as` containing `class Second {}`

    Each file is its own CompileOutput module. `ModuleName` equals the logical source key. Before Register, every `ScriptModule` is null and every script type reports null `module`.

- **WHEN** Registration registers the taken definitions together with that CompileOutput on Engine A

    > Inputs: `asCEngineCompileRegistration::Register(Sets, Output)` after TypeId install succeeds.

- **THEN** `A.GetModule("First.as")` and `A.GetModule("Second.as")` are distinct non-null modules

    `First.module` and the First ModuleDesc `ScriptModule` equal `GetModule("First.as")`.
    `Second.module` and the Second ModuleDesc `ScriptModule` equal `GetModule("Second.as")`.
    `GetModuleCount` is at least 2.

    > Observables: `asIScriptEngine::GetModule`, `GetModuleCount`, `Type.module`, `FAngelscriptModuleDesc::ScriptModule`.

    > Verification: NativeEngine CompileLifecycle two-file Register.

- **BUT** Registration that receives only definition sets, with no CompileOutput, SHALL NOT invent module shells

    Host and VM graphs that call `Register(Sets)` keep null `Type.module` and a null `GetModule` for those names.

#### Scenario: Empty Engine has no modules

- **GIVEN** a newly created Engine with no Register call
- **WHEN** a caller looks up `GetModule("Missing.as")`, `GetModuleCount()`, and `GetModuleByIndex(0)`
- **THEN** the name lookup and the index lookup return null and the count is 0

    > Verification: NativeEngine Compile SDK empty-engine lookup.

### Requirement: Engine module lookup is name-only

The maintained `asIScriptEngine` SHALL expose `GetModule(const char* name) const`, `GetModuleCount`, and `GetModuleByIndex` as table lookup, and SHALL NOT restore compile-factory module entry points.

#### Scenario: Missing name does not create a module

- **WHEN** a caller invokes `GetModule` with a name that is not in `scriptModulesByName`, or with a null name
- **THEN** the call returns nullptr and the Engine module tables are unchanged

    > Boundaries: `asEGMFlags`, `ALWAYS_CREATE`, and `ONLY_IF_EXISTS` are not part of the lookup.

    > Verification: NativeEngine Compile SDK `HasLookup` present and `HasCompile` / factory symbols absent.

#### Scenario: Compile factory stays absent

- **WHEN** C++ code attempts to call `AddScriptSection`, `Build`, `CompileFunction`, `DiscardModule`, or `GetModuleFromFuncId` on the maintained Engine or Module interfaces
- **THEN** those symbols are absent from the public SDK

    `asITypeInfo` and `asIScriptFunction` still have no `GetModule()` accessor.

    > Boundaries: Host `FAngelscriptEngine::GetModule` remains a `ModuleDesc` query and is not this Engine lookup.
