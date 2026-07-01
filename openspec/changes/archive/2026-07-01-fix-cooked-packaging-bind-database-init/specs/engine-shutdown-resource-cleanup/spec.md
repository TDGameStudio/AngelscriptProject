## ADDED Requirements

### Requirement: Script Struct Destructors Skipped After Engine Release At Exit

When AngelScript engines have been released for process exit, `FASStructOps::Destruct` MUST NOT invoke the script object's destructor, preventing a use-after-release crash when GC destroys `UASStruct` instances during cook/process teardown.

A process-global flag (`GAngelscriptEnginesReleasedForExit`, set in `FAngelscriptEngine::Shutdown()` when `IsEngineExitRequested()`) MUST be queryable via `FAngelscriptEngine::AreEnginesReleasedForExit()`.

#### Scenario: GC destruct during exit does not call freed engine

- **WHEN** GC destroys a `UASStruct` after `AreEnginesReleasedForExit()` returns true
- **THEN** `FASStructOps::Destruct` skips `ScriptObject->CallDestructor` and does not touch the released engine

#### Scenario: Cook commandlet exits cleanly

- **WHEN** the cook commandlet finishes and tears down with engine-owned script structs still alive
- **THEN** shutdown completes without a destructor-time crash
