# engine-shutdown-resource-cleanup Specification

## Purpose
TBD - created by archiving change fix-as-engine-shutdown-memory-leak. Update Purpose after archive.
## Requirements
### Requirement: UObject Root References Released on Shutdown

AngelscriptEngine Shutdown MUST remove all owned UASClass/UASStruct/UDelegateFunction/UUserDefinedEnum from the GC root set.

#### Scenario: UASClass RemoveFromRoot on Shutdown

- **Given** a fully initialized FAngelscriptEngine instance (Init + Bind + Compile complete)
- **When** `Shutdown()` is called on an owned engine
- **Then** all UASClass objects with `OwnerScriptEngine == Engine` are no longer GC roots (`IsRooted() == false`)

#### Scenario: UASStruct RemoveFromRoot on Shutdown

- **Given** same as above
- **When** Shutdown
- **Then** all engine-owned UASStruct objects are no longer GC roots

#### Scenario: UDelegateFunction RemoveFromRoot on Shutdown

- **Given** same as above
- **When** Shutdown
- **Then** all UDelegateFunction objects within the engine-owned Package are no longer GC roots

#### Scenario: UUserDefinedEnum RemoveFromRoot on Shutdown

- **Given** same as above
- **When** Shutdown
- **Then** all UUserDefinedEnum objects within the engine-owned Package are no longer GC roots

### Requirement: Global Static Containers Cleared on Shutdown

AngelscriptEngine Shutdown MUST clear all global static containers that hold engine-scoped references to prevent dangling pointers.

#### Scenario: GBlueprintEventsByScriptName Cleared on Shutdown

- **Given** the engine has completed binding (`Bind_BlueprintEvent` has populated the global map)
- **When** Shutdown
- **Then** `GBlueprintEventsByScriptName` is empty

#### Scenario: AngelscriptGameplayTagsLookup Preserved Across Shutdown

- **Given** the engine has registered gameplay tags
- **When** Shutdown
- **Then** `AngelscriptGameplayTagsLookup` remains unchanged (it is the dedup index for the global TChunkedArray; the Rebind mechanism relies on that array as the tag truth source)

### Requirement: Heap-Allocated Global Resources Released on Shutdown

AngelscriptEngine Shutdown MUST release all heap-allocated global resources to prevent linear memory growth.

#### Scenario: GScriptNativeForms Released on Shutdown

- **Given** the engine has bound native forms via `FScriptFunctionNativeForm::BindNativeXxx`
- **When** Shutdown
- **Then** all `new`-ed `FScriptFunctionNativeForm` objects are deleted and `GScriptNativeForms` is empty

#### Scenario: AngelscriptDocs TMaps Cleared on Shutdown

- **Given** the engine has populated documentation maps
- **When** Shutdown
- **Then** all four static documentation TMaps (`UnrealDocumentation`, `UnrealTypeDocumentation`, `GlobalVariableDocumentation`, `UnrealPropertyDocumentation`) are empty

### Requirement: Multi-Cycle Memory Stability

Multiple consecutive engine lifecycles MUST NOT cause unbounded memory growth from retained UObject roots.

#### Scenario: Multi-Cycle Memory Growth Bounded

- **Given** N consecutive (N >= 3) full Init → Shutdown cycles
- **When** process memory is observed after each Shutdown
- **Then** per-cycle memory growth does not exceed 2x the first cycle's growth (excluding FName accumulation)

### Requirement: Script Struct Destructors Skipped After Engine Release At Exit

When AngelScript engines have been released for process exit, `FASStructOps::Destruct` MUST NOT invoke the script object's destructor, preventing a use-after-release crash when GC destroys `UASStruct` instances during cook/process teardown.

A process-global flag (`GAngelscriptEnginesReleasedForExit`, set in `FAngelscriptEngine::Shutdown()` when `IsEngineExitRequested()`) MUST be queryable via `FAngelscriptEngine::AreEnginesReleasedForExit()`.

#### Scenario: GC destruct during exit does not call freed engine

- **WHEN** GC destroys a `UASStruct` after `AreEnginesReleasedForExit()` returns true
- **THEN** `FASStructOps::Destruct` skips `ScriptObject->CallDestructor` and does not touch the released engine

#### Scenario: Cook commandlet exits cleanly

- **WHEN** the cook commandlet finishes and tears down with engine-owned script structs still alive
- **THEN** shutdown completes without a destructor-time crash

