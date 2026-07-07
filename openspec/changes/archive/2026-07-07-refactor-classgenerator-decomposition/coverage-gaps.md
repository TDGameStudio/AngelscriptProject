# ClassGenerator Test Coverage — What Is Covered vs Gaps

Correction to an earlier assumption: ClassGeneration is **not** thinly tested overall. `AngelscriptTest/ClassGenerator/` holds **32 test files**, and the `HotReload/` theme (31 files), `Compiler/`, `Coverage/`, and `Functional/` themes exercise generation heavily. The directory name is historical: the tests are really guarding the AS-to-Unreal Generator boundary, including generated `UASClass`, `UASFunction`, `UASStruct`, properties, metadata, default objects, hot reload, and public diagnostics. The refactor risk is concentrated in a few specific pipeline branches that lack **direct** assertions, not in the module as a whole.

## Already well covered (do NOT re-add)

| Generator area | Covering tests |
|---|---|
| Reload-requirement classification matrix | `HotReloadChangeClassificationTests` (22 methods: NoChange, PropertyCountChange, SuperClassChange, Function signature/added/removed/default-arg/metadata/BP-specifier/arg-name, BlueprintEventAdded, Enum value/metadata, Delegate signature/added/kind, DefaultStatement, Class metadata/flag) |
| Property full/soft reload | `HotReloadPropertyTests` (add/remove/type-change/specifier/inheritance-propagation/failed-reload-keeps-old) |
| Static constructors (actor/component/object) | `AngelscriptASClass{Actor,Component,Object}ConstructionTests` |
| Class creation / shape / CDO | `ScriptClassCreation`, `ScriptClassShape`, `ScriptClassStructure` (CompilesToUClass, spawn, CDO defaults, BP child, rename, non-UClass reject) |
| Dispatch subclass selection | `ASFunctionDispatchTests` (thread-safe + representative matrix), `ASFunctionOptimizedCall`, `ASFunctionProcessEvent` (ABI shapes) |
| WorldContext function generation | `ASFunctionWorldContextTests` |
| Compile-check hooks / reject paths | `AdditionalCompileChecksTests` (8 methods incl reject keeps published class) |
| Component default/override metadata | `ASClassComponentMetadata`, `ComponentMetadataValidation` (fail-closed), Syntax `DefaultComponent` |
| Tick settings | `ASClassTickSettingsTests` |
| Replication list | `ASClassReplicationTests` |
| GC reference schema | `ASClassReferenceSchemaTests`, `GC` theme |
| Struct / enum / delegate generation + reload | `ScriptStructHotReload`, Coverage `UStruct`/`UEnum`, `HotReloadEnumDelegate`, Delegate theme |
| ComposeOntoClass | `ComposeOntoClassTests` (missing target + no-op fail-closed) |
| Literal asset post-init | `LiteralAssetPostInitTests` |
| Generated type identity across reload | `ASGeneratedTypeIdentityTests` |
| Interface dispatch bridge | `InterfaceDispatchBridgeTests`, `CallInterfaceMethod` |
| Class rename redirects | `HotReloadClassRenameTests`, `RenameReplacesOldClass` |
| Module discard / file removal | `HotReloadFunctionTests`, `HotReloadFileRemovalTests`, `ASStructDiscardTests` |

## Existing `UASClass`-specific coverage

There is already a dedicated `Angelscript.TestModule.ClassGenerator.ASClass` test prefix. It covers the generated `UASClass` runtime class layer through public behavior, not by calling `FAngelscriptClassGenerator` private internals directly:

| `UASClass` area | Covering tests |
|---|---|
| Static actor/component/object constructors and default application | `AngelscriptASClassActorConstructionTests`, `AngelscriptASClassComponentConstructionTests`, `AngelscriptASClassObjectConstructionTests` |
| Construction context and current script object tracking | `AngelscriptASClassConstructionContextTests` |
| Hierarchy helpers and script/native ancestor resolution | `AngelscriptASClassHelperTests` |
| Metadata helpers such as developer-only and function-implemented checks | `AngelscriptASClassMetadataTests` |
| Default/override component metadata and soft-reload deduplication | `AngelscriptASClassComponentMetadataTests`, `AngelscriptComponentMetadataValidationTests` |
| Runtime reference schema / GC participation | `AngelscriptASClassReferenceSchemaTests`, plus the broader `GC` theme |
| Replication and tick behavior stored on generated classes | `AngelscriptASClassReplicationTests`, `AngelscriptASClassTickSettingsTests` |
| Script class shape and creation as generated `UASClass` artifacts | `AngelscriptScriptClassCreationTests`, `AngelscriptScriptClassShapeTests`, `AngelscriptScriptClassStructureTests` |

The remaining ASClass-related gaps are therefore narrow: direct positive coverage for some component wiring details, namespaced-UCLASS generation, and debugger prototype observation. They do not imply that `UASClass` lacks a separate test area.

## Genuine gaps (target these in characterization group 2)

Ranked by refactor risk (highest first). Each maps to a generator function being relocated/extracted.

1. **Reload dependency propagation graph** — `PropagateReloadRequirements`, `AddReloadDependency`, `ResolvePendingReloadDependees` (generator lines ~2112–2285). Only 2 dependency tests exist (`HotReloadDependencyTests`: import rebind, struct param retarget), both about re-linking, not about **requirement-level escalation**. Missing: B requires full reload ⇒ dependent A escalated to full; multi-hop A→B→C propagation; pending-dependee resolution ordering; struct-used-as-property forcing dependent full reload; cyclic dependency termination.

2. **Interface list change classification** — `HasInterfaceListChanged` (line 2298). `HotReloadChangeClassification` covers super-class change but NOT interface add/remove; `HotReloadInterfaceTests` has a single unrelated method. Missing: adding/removing an implemented interface produces the correct `EReloadRequirement`.

3. **`VerifyClass` reject branches** — (line 5770, ~230 lines). Only ComposeOnto and component-metadata fail-closed paths are asserted. Missing direct coverage of other reject branches (invalid/unresolvable super, name conflict with native object, unsupported property/type, abstract-vs-instantiable, duplicate). Enumerate branches when extracting and pin accept + each reject.

4. **`Error` reload-requirement / name-conflict paths** — `Analyze` raises `ScriptCompileError` + `EReloadRequirement::Error` on struct-vs-non-struct name conflict and class/native name collisions (line ~231+). No negative test asserts the `Error` outcome. (`AdditionalCompileChecks` covers check-rejection, not name-conflict.)

5. **`AddFunctionArgument` VM/Parm marshalling matrix** — (line 4304). Dispatch *selection* is tested, but per-`EArgumentVMBehavior` marshalling *correctness* through a generated function is partial. Missing: out-param write-back, by-ref inout, `ReturnObjectValue` vs `ReturnObjectPOD`, `Value8Byte`, `FloatExtendedToDouble` on both arg and return.

6. **`ResolveCodeSuperForProperty`** — (line 3485). Zero direct references in tests. Missing: object/subclass property whose type usage resolves to a native code super.

7. **`CreateDebugValuePrototype`** — (line 5237). Zero references in the test tree (Debugger theme included). Missing: generated class produces the expected debug-value prototype for the debugger.

8. **Reinstancing live instances across full reload** — `DestructScriptObject` / `ReinitializeScriptObject` (lines 5117/5134). Partially covered by `HotReloadVersionChain` / `HotReloadSubsystem` / `CoverageUClass`. Missing a focused assertion: an already-spawned instance survives a full reload with the new layout, migrated state, and the old script object destructed exactly once.

9. **`FinalizeActorClass` override-component wiring detail** — (line 5517). Root/attach-parent layout and fail-closed validation are covered; positive coverage of override-component variable binding/offset, editor-only default components, and attach *socket* (vs parent) is thin.

10. **`GetNamespacedTypeInfoForClass` / namespaced class generation** — (line 6226). `Syntax NamespacedUSTRUCTNegative` covers struct rejection; the positive namespaced-UCLASS generation path is not directly asserted.

## How this feeds the refactor

Group 2 characterization tasks in `tasks.md` should add the missing direct assertions for gaps 1–10 **before** extracting the corresponding phase unit, so each `Analyze` / `ReloadPlanning` / `FullReload` / `SoftReload` / `Generation` / `Finalize` / `Reinstancing` extraction has a pin covering its riskiest branch. Gaps 1–5 are must-haves before touching the reload-planning and generation code; 6–10 can accompany their phase batch.
