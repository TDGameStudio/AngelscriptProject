## Actor spawn-parameter wave

### Approved public surface

- `FActorSpawnParameters` is registered as a hand-authored non-reflected value type.
- The initial field set is `Name`, `Template`, `Owner`, `Instigator`, `OverrideLevel`,
  `SpawnCollisionHandlingOverride`, and `NameMode`.
- `bNoFail`, `bDeferConstruction`, and `bAllowDuringConstructionScript` use explicit
  `Getb*` / `Setb*` accessors because they are native bitfields.
- `ObjectFlags`, `OverrideParentComponent`, editor-only package fields, and the native
  `CustomPreSpawnInitialization` callback remain intentionally unbound: they either expose
  low-level UObject construction policy or require a separately designed script callback
  lifetime contract.
- New transform-plus-parameter overloads are available through global `SpawnActor`, global
  `SpawnPersistentActor`, `UWorld.SpawnActor`, and each reflected `<ActorType>::Spawn`.
- Global and typed spawning retain existing dynamic/caller level resolution when
  `OverrideLevel` is null. `UWorld.SpawnActor` and `SpawnPersistentActor` pass the supplied
  parameters through unchanged.

### Validation record

- `Tools/RunBuild.ps1 -Label actor-spawn-parameters-test-surface -TimeoutMs 900000`
  compiled the changed Runtime and Actor test sources and linked both static libraries.
- Final DLL linking remains blocked by the pre-existing unresolved
  `IsEditorOnlyClass(UClass*)` reference in `FAngelscriptFunctionSignature::ModifyScriptFunction`.
  This affects `AngelscriptRuntime`, `AngelscriptTest`, and `AngelscriptGameplayTagsTest`.
- The focused Automation test has not been run because the failed DLL link would leave the
  test runner using stale binaries; a fresh successful build is required before it can provide
  valid behavioral evidence.
