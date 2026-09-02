# TestSource audit coverage reconciliation

Plan-only reconciliation against current owner-qualified `as_inventory.py`; no TestSource/OpenSpec/product edits.

## Result

- Sources: **3041/3041** planned.
- Current callables: **11987/11987** planned with at least one proposal.
- Prior rows: **11974**; matched **11953**; missing current **34**; phantom **21**.
- Owner mismaps repaired: **16**; duplicate audit/current identities: **0/0**.
- Validation: **PASS**.

The exact identity is `sourcePath + owner + declaration + line`. The JSON embeds Draft 2020-12 `schemaDefinition`; all 11,987 exact rows are in `planRows`.

## Exact tuple categories

- `annotation-omitted`: 401
- `annotation-omitted+line-mismatch`: 1493
- `exact-four-tuple`: 6743
- `line-omitted`: 45
- `missing-from-prior-audits`: 34
- `owner-mismatch`: 13
- `owner-mismatch+annotation-omitted+line-mismatch`: 3
- `owner-omitted`: 3138
- `owner-omitted+annotation-omitted+line-mismatch`: 117

## Newly missing callable plans

### AR-7979F71A77E72E37 — `TestSource/Bindings/BlueprintEvent/Test_Behavior_01.as:22`

- Current: owner `::`, kind `event`, declaration `event void FTSBlueprintEventBehaviorMulticast(int Value)`; CaseId `TS-BIND-BLUEPRINTEVENT-003`.
- `reconcile-ftsblueprinteventbehaviormulticast-7979f71a` → `FTSBlueprintEventBehaviorMulticast` (`requiredName=true`)
  - Declaration: `event void FTSBlueprintEventBehaviorMulticast(int Value)`
  - Comment: `// CaseId TS-BIND-BLUEPRINTEVENT-003; subcase reconcile-ftsblueprinteventbehaviormulticast-7979f71a. Role: required-signature-declaration. Preserve FTSBlueprintEventBehaviorMulticast as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-7153C9C64531FCBF — `TestSource/Bindings/BlueprintEvent/Test_Behavior_01.as:23`

- Current: owner `::`, kind `delegate`, declaration `delegate void FTSBlueprintEventBehaviorDelegate(int Value)`; CaseId `TS-BIND-BLUEPRINTEVENT-003`.
- `reconcile-ftsblueprinteventbehaviordelegate-7153c9c6` → `FTSBlueprintEventBehaviorDelegate` (`requiredName=true`)
  - Declaration: `delegate void FTSBlueprintEventBehaviorDelegate(int Value)`
  - Comment: `// CaseId TS-BIND-BLUEPRINTEVENT-003; subcase reconcile-ftsblueprinteventbehaviordelegate-7153c9c6. Role: required-signature-declaration. Preserve FTSBlueprintEventBehaviorDelegate as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-A051989A2A0453F5 — `TestSource/Bindings/BlueprintEvent/Test_MutationAndLifecycle_01.as:17`

- Current: owner `::`, kind `event`, declaration `event void FTSBlueprintEventMutationMulticast(int Value)`; CaseId `TS-BIND-BLUEPRINTEVENT-001`.
- `reconcile-ftsblueprinteventmutationmulticast-a051989a` → `FTSBlueprintEventMutationMulticast` (`requiredName=true`)
  - Declaration: `event void FTSBlueprintEventMutationMulticast(int Value)`
  - Comment: `// CaseId TS-BIND-BLUEPRINTEVENT-001; subcase reconcile-ftsblueprinteventmutationmulticast-a051989a. Role: required-signature-declaration. Preserve FTSBlueprintEventMutationMulticast as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-E50CD4C546104DBA — `TestSource/Bindings/BlueprintEvent/Test_MutationAndLifecycle_01.as:18`

- Current: owner `::`, kind `delegate`, declaration `delegate void FTSBlueprintEventMutationDelegate(int Value)`; CaseId `TS-BIND-BLUEPRINTEVENT-001`.
- `reconcile-ftsblueprinteventmutationdelegate-e50cd4c5` → `FTSBlueprintEventMutationDelegate` (`requiredName=true`)
  - Declaration: `delegate void FTSBlueprintEventMutationDelegate(int Value)`
  - Comment: `// CaseId TS-BIND-BLUEPRINTEVENT-001; subcase reconcile-ftsblueprinteventmutationdelegate-e50cd4c5. Role: required-signature-declaration. Preserve FTSBlueprintEventMutationDelegate as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-C1C1CF11ABFDA291 — `TestSource/Bindings/Delegates/Test_Behavior_01.as:24`

- Current: owner `::`, kind `delegate`, declaration `delegate int FTSDelegatesBehaviorCompute(int Value)`; CaseId `TS-BIND-DELEGATES-005`.
- `reconcile-ftsdelegatesbehaviorcompute-c1c1cf11` → `FTSDelegatesBehaviorCompute` (`requiredName=true`)
  - Declaration: `delegate int FTSDelegatesBehaviorCompute(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-005; subcase reconcile-ftsdelegatesbehaviorcompute-c1c1cf11. Role: required-signature-declaration. Preserve FTSDelegatesBehaviorCompute as the exact surface. Inputs: int Value (value). Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-9A33B5C88C267734 — `TestSource/Bindings/Delegates/Test_Behavior_01.as:25`

- Current: owner `::`, kind `event`, declaration `event void FTSDelegatesBehaviorNotify(int Value)`; CaseId `TS-BIND-DELEGATES-005`.
- `reconcile-ftsdelegatesbehaviornotify-9a33b5c8` → `FTSDelegatesBehaviorNotify` (`requiredName=true`)
  - Declaration: `event void FTSDelegatesBehaviorNotify(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-005; subcase reconcile-ftsdelegatesbehaviornotify-9a33b5c8. Role: required-signature-declaration. Preserve FTSDelegatesBehaviorNotify as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-B246E6297228971D — `TestSource/Bindings/Delegates/Test_Behavior_02.as:16`

- Current: owner `::`, kind `delegate`, declaration `delegate void FTSDelegatesSignatureNotify(int Value)`; CaseId `TS-BIND-DELEGATES-006`.
- `reconcile-ftsdelegatessignaturenotify-b246e629` → `FTSDelegatesSignatureNotify` (`requiredName=true`)
  - Declaration: `delegate void FTSDelegatesSignatureNotify(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-006; subcase reconcile-ftsdelegatessignaturenotify-b246e629. Role: required-signature-declaration. Preserve FTSDelegatesSignatureNotify as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-38EB45F638C83BE1 — `TestSource/Bindings/Delegates/Test_Behavior_02.as:17`

- Current: owner `::`, kind `event`, declaration `event void FTSDelegatesSignatureMulticast(int Value)`; CaseId `TS-BIND-DELEGATES-006`.
- `reconcile-ftsdelegatessignaturemulticast-38eb45f6` → `FTSDelegatesSignatureMulticast` (`requiredName=true`)
  - Declaration: `event void FTSDelegatesSignatureMulticast(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-006; subcase reconcile-ftsdelegatessignaturemulticast-38eb45f6. Role: required-signature-declaration. Preserve FTSDelegatesSignatureMulticast as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-29A8E55FF8932056 — `TestSource/Bindings/Delegates/Test_ConstructionAndAssignment_01.as:13`

- Current: owner `::`, kind `delegate`, declaration `delegate int FTSDelegatesAssignmentCompute(int Value)`; CaseId `TS-BIND-DELEGATES-001`.
- `reconcile-ftsdelegatesassignmentcompute-29a8e55f` → `FTSDelegatesAssignmentCompute` (`requiredName=true`)
  - Declaration: `delegate int FTSDelegatesAssignmentCompute(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-001; subcase reconcile-ftsdelegatesassignmentcompute-29a8e55f. Role: required-signature-declaration. Preserve FTSDelegatesAssignmentCompute as the exact surface. Inputs: int Value (value). Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-F18009B6F873DA06 — `TestSource/Bindings/Delegates/Test_ConstructionAndAssignment_01.as:14`

- Current: owner `::`, kind `event`, declaration `event void FTSDelegatesAssignmentNotify(int Value)`; CaseId `TS-BIND-DELEGATES-001`.
- `reconcile-ftsdelegatesassignmentnotify-f18009b6` → `FTSDelegatesAssignmentNotify` (`requiredName=true`)
  - Declaration: `event void FTSDelegatesAssignmentNotify(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-001; subcase reconcile-ftsdelegatesassignmentnotify-f18009b6. Role: required-signature-declaration. Preserve FTSDelegatesAssignmentNotify as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-8FF5E5B1CC3F9534 — `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_01.as:23`

- Current: owner `::`, kind `delegate`, declaration `delegate int FTSDelegatesMutationCompute(int Value)`; CaseId `TS-BIND-DELEGATES-003`.
- `reconcile-ftsdelegatesmutationcompute-8ff5e5b1` → `FTSDelegatesMutationCompute` (`requiredName=true`)
  - Declaration: `delegate int FTSDelegatesMutationCompute(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-003; subcase reconcile-ftsdelegatesmutationcompute-8ff5e5b1. Role: required-signature-declaration. Preserve FTSDelegatesMutationCompute as the exact surface. Inputs: int Value (value). Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-AD9C2B949987F038 — `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_01.as:24`

- Current: owner `::`, kind `event`, declaration `event void FTSDelegatesMutationNotify(int Value)`; CaseId `TS-BIND-DELEGATES-003`.
- `reconcile-ftsdelegatesmutationnotify-ad9c2b94` → `FTSDelegatesMutationNotify` (`requiredName=true`)
  - Declaration: `event void FTSDelegatesMutationNotify(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-003; subcase reconcile-ftsdelegatesmutationnotify-ad9c2b94. Role: required-signature-declaration. Preserve FTSDelegatesMutationNotify as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-9B1082128805A294 — `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_02.as:20`

- Current: owner `::`, kind `delegate`, declaration `delegate void FTSDelegatesErasedNotify(int Value)`; CaseId `TS-BIND-DELEGATES-004`.
- `reconcile-ftsdelegateserasednotify-9b108212` → `FTSDelegatesErasedNotify` (`requiredName=true`)
  - Declaration: `delegate void FTSDelegatesErasedNotify(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-004; subcase reconcile-ftsdelegateserasednotify-9b108212. Role: required-signature-declaration. Preserve FTSDelegatesErasedNotify as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-C85C976181631C86 — `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_02.as:21`

- Current: owner `::`, kind `event`, declaration `event void FTSDelegatesErasedMulticast(int Value)`; CaseId `TS-BIND-DELEGATES-004`.
- `reconcile-ftsdelegateserasedmulticast-c85c9761` → `FTSDelegatesErasedMulticast` (`requiredName=true`)
  - Declaration: `event void FTSDelegatesErasedMulticast(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-004; subcase reconcile-ftsdelegateserasedmulticast-c85c9761. Role: required-signature-declaration. Preserve FTSDelegatesErasedMulticast as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-FEC036E2D33CC375 — `TestSource/Bindings/Delegates/Test_Queries_01.as:14`

- Current: owner `::`, kind `delegate`, declaration `delegate int FTSDelegatesQueryCompute(int Value)`; CaseId `TS-BIND-DELEGATES-002`.
- `reconcile-ftsdelegatesquerycompute-fec036e2` → `FTSDelegatesQueryCompute` (`requiredName=true`)
  - Declaration: `delegate int FTSDelegatesQueryCompute(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-002; subcase reconcile-ftsdelegatesquerycompute-fec036e2. Role: required-signature-declaration. Preserve FTSDelegatesQueryCompute as the exact surface. Inputs: int Value (value). Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-63DAC330ED60D255 — `TestSource/Bindings/Delegates/Test_Queries_01.as:15`

- Current: owner `::`, kind `event`, declaration `event void FTSDelegatesQueryNotify(int Value)`; CaseId `TS-BIND-DELEGATES-002`.
- `reconcile-ftsdelegatesquerynotify-63dac330` → `FTSDelegatesQueryNotify` (`requiredName=true`)
  - Declaration: `event void FTSDelegatesQueryNotify(int Value)`
  - Comment: `// CaseId TS-BIND-DELEGATES-002; subcase reconcile-ftsdelegatesquerynotify-63dac330. Role: required-signature-declaration. Preserve FTSDelegatesQueryNotify as the exact surface. Inputs: int Value (value). Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[{"name": "Value", "type": "int", "direction": "value", "default": null}]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-14A2E619B0867E3D — `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:48`

- Current: owner `::`, kind `function`, declaration `int GetAssetsByPathParity( bool bExpectedGetAssetsByPath, int ExpectedAssetsByPathCount, const FString& ExpectedObjectPathString, const FString& ExpectedSoftObjectPathString, FName EngineMaterialsPath)`; CaseId `TS-CONT-0005`.
- `query-assets-by-path` → `QueryAssetsByPath` (`requiredName=false`)
  - Declaration: `void QueryAssetsByPath(FName EngineMaterialsPath, bool&out Succeeded, TArray<FAssetData>&out Assets)`
  - Comment: `// CaseId TS-CONT-0005; subcase query-assets-by-path. Role: raw query. Expose the raw AssetRegistry success flag and asset array; expected count/path values stay in contract vectors. Fixture: runner initializes AssetRegistry/path inputs. Cleanup: release arrays, handles, and module on every exit.`
  - Inputs/result/writebacks: `[{"name": "bExpectedGetAssetsByPath", "type": "bool", "direction": "value", "default": null}, {"name": "ExpectedAssetsByPathCount", "type": "int", "direction": "value", "default": null}, {"name": "ExpectedObjectPathString", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ExpectedSoftObjectPathString", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "EngineMaterialsPath", "type": "FName", "direction": "value", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-asset-registry-fixture", "cleanup": "Release arrays/assets and discard module."}` / `reviewed-exact-reconciliation` / `[]`

### AR-175D30472CD25891 — `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:87`

- Current: owner `::`, kind `function`, declaration `int GetAssetByObjectPathParity( const FString& TargetObjectPath, const FString& ExpectedObjectPathString, const FString& ExpectedSoftObjectPathString)`; CaseId `TS-CONT-0005`.
- `query-asset-by-object-path` → `QueryAssetByObjectPath` (`requiredName=false`)
  - Declaration: `FAssetData QueryAssetByObjectPath(const FString&in TargetObjectPath)`
  - Comment: `// CaseId TS-CONT-0005; subcase query-asset-by-object-path. Role: raw query. Return raw FAssetData; the runner compares object-path and soft-path fields. Fixture: runner initializes AssetRegistry/path inputs. Cleanup: release arrays, handles, and module on every exit.`
  - Inputs/result/writebacks: `[{"name": "TargetObjectPath", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ExpectedObjectPathString", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ExpectedSoftObjectPathString", "type": "const FString&", "direction": "unspecified", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-asset-registry-fixture", "cleanup": "Release arrays/assets and discard module."}` / `reviewed-exact-reconciliation` / `[]`

### AR-989C497905A4914D — `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:127`

- Current: owner `::`, kind `function`, declaration `int GetAllAssetsParity( bool bExpectedGetAllAssets, bool bExpectedAllAssetsContainTarget, int ExpectedAllAssetsCount, const FString& ExpectedObjectPathString)`; CaseId `TS-CONT-0005`.
- `query-all-assets` → `QueryAllAssets` (`requiredName=false`)
  - Declaration: `bool QueryAllAssets(TArray<FAssetData>&out Assets)`
  - Comment: `// CaseId TS-CONT-0005; subcase query-all-assets. Role: raw query. Expose raw GetAllAssets success and result array; count/membership expectations stay in vectors. Fixture: runner initializes AssetRegistry/path inputs. Cleanup: release arrays, handles, and module on every exit.`
  - Inputs/result/writebacks: `[{"name": "bExpectedGetAllAssets", "type": "bool", "direction": "value", "default": null}, {"name": "bExpectedAllAssetsContainTarget", "type": "bool", "direction": "value", "default": null}, {"name": "ExpectedAllAssetsCount", "type": "int", "direction": "value", "default": null}, {"name": "ExpectedObjectPathString", "type": "const FString&", "direction": "unspecified", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-asset-registry-fixture", "cleanup": "Release arrays/assets and discard module."}` / `reviewed-exact-reconciliation` / `[]`

### AR-68F18461D9332A40 — `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:162`

- Current: owner `::`, kind `function`, declaration `int Observe_GetAssetByObjectPath_CopyIndependence( const FString& TargetObjectPath, const FString& ExpectedObjectPathString)`; CaseId `TS-CONT-0005`.
- `query-object-path-twice` → `QueryAssetByObjectPathTwice` (`requiredName=false`)
  - Declaration: `void QueryAssetByObjectPathTwice(const FString&in TargetObjectPath, FAssetData&out First, FAssetData&out Second)`
  - Comment: `// CaseId TS-CONT-0005; subcase query-object-path-twice. Role: raw query. Expose both raw lookup values so the runner verifies equality and copy independence. Fixture: runner initializes AssetRegistry/path inputs. Cleanup: release arrays, handles, and module on every exit.`
  - Inputs/result/writebacks: `[{"name": "TargetObjectPath", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ExpectedObjectPathString", "type": "const FString&", "direction": "unspecified", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-asset-registry-fixture", "cleanup": "Release arrays/assets and discard module."}` / `reviewed-exact-reconciliation` / `[]`

### AR-0229A438FC2EC0CA — `TestSource/Containers/TSet/Test_SoftPathStringIdentityAndMissingClassBoundaries.as:127`

- Current: owner `::`, kind `function`, declaration `int Observe_SoftPathIdentity_Nominal( const FString& TexturePathString, const FString& TexturePackage, const FString& TextureAsset, const FString& ActorClassPath, const FString& ActorClassPackage, const FString& ActorClassAsset, const FString& MissingClassPath)`; CaseId `TS-CONT-0003`.
- `read-soft-object-path-state` → `ReadSoftObjectPathState` (`requiredName=false`)
  - Declaration: `void ReadSoftObjectPathState(const FString&in PathString, bool&out IsValid, bool&out IsNull, bool&out IsAsset, bool&out IsSubobject, FString&out RoundTrip, FString&out LongPackageName, FString&out AssetName)`
  - Comment: `// CaseId TS-CONT-0003; subcase read-soft-object-path-state. Role: raw query. Expose every raw FSoftObjectPath field independently. Fixture: runner initializes AssetRegistry/path inputs. Cleanup: release arrays, handles, and module on every exit.`
  - Inputs/result/writebacks: `[{"name": "TexturePathString", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "TexturePackage", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "TextureAsset", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassPath", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassPackage", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassAsset", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "MissingClassPath", "type": "const FString&", "direction": "unspecified", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-asset-registry-fixture", "cleanup": "Release arrays/assets and discard module."}` / `reviewed-exact-reconciliation` / `[]`
- `read-soft-class-path-state` → `ReadSoftClassPathState` (`requiredName=false`)
  - Declaration: `void ReadSoftClassPathState(const FString&in PathString, bool&out IsValid, bool&out IsNull, bool&out IsAsset, bool&out IsSubobject, FString&out RoundTrip, FString&out LongPackageName, FString&out AssetName)`
  - Comment: `// CaseId TS-CONT-0003; subcase read-soft-class-path-state. Role: raw query. Expose every raw FSoftClassPath field independently. Fixture: runner initializes AssetRegistry/path inputs. Cleanup: release arrays, handles, and module on every exit.`
  - Inputs/result/writebacks: `[{"name": "TexturePathString", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "TexturePackage", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "TextureAsset", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassPath", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassPackage", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassAsset", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "MissingClassPath", "type": "const FString&", "direction": "unspecified", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-asset-registry-fixture", "cleanup": "Release arrays/assets and discard module."}` / `reviewed-exact-reconciliation` / `[]`
- `read-missing-soft-class-state` → `ReadMissingSoftClassState` (`requiredName=false`)
  - Declaration: `void ReadMissingSoftClassState(const FString&in PathString, bool&out IsValid, UClass&out ResolvedClass, UClass&out LoadedClass)`
  - Comment: `// CaseId TS-CONT-0003; subcase read-missing-soft-class-state. Role: raw query. Expose raw validity, ResolveClass, and TryLoadClass results without a parity wrapper. Fixture: runner initializes AssetRegistry/path inputs. Cleanup: release arrays, handles, and module on every exit.`
  - Inputs/result/writebacks: `[{"name": "TexturePathString", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "TexturePackage", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "TextureAsset", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassPath", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassPackage", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "ActorClassAsset", "type": "const FString&", "direction": "unspecified", "default": null}, {"name": "MissingClassPath", "type": "const FString&", "direction": "unspecified", "default": null}]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-asset-registry-fixture", "cleanup": "Release arrays/assets and discard module."}` / `reviewed-exact-reconciliation` / `[]`

### AR-1A9DB54C47DDF052 — `TestSource/Definitions/UFunction/Test_Specifiers_Negative_09.as:9`

- Current: owner `AUFuncGarbageActor`, kind `method`, declaration `UFUNCTION() garbage void Foo()`; CaseId `TS-DEF-0457`.
- `reconcile-foo-1a9db54c` → `Foo` (`requiredName=true`)
  - Declaration: `UFUNCTION() garbage void Foo()`
  - Comment: `// CaseId TS-DEF-0457; subcase reconcile-foo-1a9db54c. Role: required-member-or-negative-declaration. Preserve Foo as the exact surface. Inputs: none. Raw result: garbage void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "garbage void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[{"kind": "expected-compile-diagnostic", "exactText": "copy from authoritative runner before implementation"}]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `blocking-exact-diagnostic-reconciliation` / `["Preserve exact compiler diagnostic and source line while adding the adjacent comment."]`

### AR-A887A1D1D8DA9028 — `TestSource/Feature/Default/Test_DefaultsOnlyAccess_01.as:13`

- Current: owner `UDefaultsOnlyOkTarget`, kind `method`, declaration `int BuildDefaultValue() defaults`; CaseId `TS-FEAT-0243`.
- `reconcile-builddefaultvalue-a887a1d1` → `BuildDefaultValue` (`requiredName=true`)
  - Declaration: `int BuildDefaultValue() defaults`
  - Comment: `// CaseId TS-FEAT-0243; subcase reconcile-builddefaultvalue-a887a1d1. Role: required-member-or-negative-declaration. Preserve BuildDefaultValue as the exact surface. Inputs: none. Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `reviewed-exact-reconciliation` / `[]`

### AR-47342131114E831A — `TestSource/Feature/Default/Test_DefaultsOnlyAccess_02.as:12`

- Current: owner `UDefaultsOnlyRejectTarget`, kind `method`, declaration `int BuildDefaultValue() defaults`; CaseId `TS-FEAT-0244`.
- `reconcile-builddefaultvalue-47342131` → `BuildDefaultValue` (`requiredName=true`)
  - Declaration: `int BuildDefaultValue() defaults`
  - Comment: `// CaseId TS-FEAT-0244; subcase reconcile-builddefaultvalue-47342131. Role: required-member-or-negative-declaration. Preserve BuildDefaultValue as the exact surface. Inputs: none. Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `reviewed-exact-reconciliation` / `[]`

### AR-B864673337CB1F2D — `TestSource/Feature/Default/Test_UnsafeDuringConstructionRejectsDefaultAndConstructor_01.as:12`

- Current: owner `UUnsafeDefaultTarget`, kind `method`, declaration `int UnsafeValue() unsafe_during_construction`; CaseId `TS-FEAT-0240`.
- `reconcile-unsafevalue-b8646733` → `UnsafeValue` (`requiredName=true`)
  - Declaration: `int UnsafeValue() unsafe_during_construction`
  - Comment: `// CaseId TS-FEAT-0240; subcase reconcile-unsafevalue-b8646733. Role: required-member-or-negative-declaration. Preserve UnsafeValue as the exact surface. Inputs: none. Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[{"kind": "expected-compile-diagnostic", "exactText": "copy from authoritative runner before implementation"}]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `blocking-exact-diagnostic-reconciliation` / `["Preserve exact compiler diagnostic and source line while adding the adjacent comment."]`

### AR-EC748866AFE2B759 — `TestSource/Feature/Default/Test_UnsafeDuringConstructionRejectsDefaultAndConstructor_02.as:10`

- Current: owner `UnsafeConstructorCarrier`, kind `method`, declaration `int UnsafeValue() unsafe_during_construction`; CaseId `TS-FEAT-0241`.
- `reconcile-unsafevalue-ec748866` → `UnsafeValue` (`requiredName=true`)
  - Declaration: `int UnsafeValue() unsafe_during_construction`
  - Comment: `// CaseId TS-FEAT-0241; subcase reconcile-unsafevalue-ec748866. Role: required-member-or-negative-declaration. Preserve UnsafeValue as the exact surface. Inputs: none. Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[{"kind": "expected-compile-diagnostic", "exactText": "copy from authoritative runner before implementation"}]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `blocking-exact-diagnostic-reconciliation` / `["Preserve exact compiler diagnostic and source line while adding the adjacent comment."]`

### AR-81AF672C7DF416EC — `TestSource/Feature/Default/Test_UnsafeDuringConstructionRejectsDefaultAndConstructor_03.as:13`

- Current: owner `UUnsafeOrdinaryTarget`, kind `method`, declaration `int UnsafeValue() unsafe_during_construction`; CaseId `TS-FEAT-0242`.
- `reconcile-unsafevalue-81af672c` → `UnsafeValue` (`requiredName=true`)
  - Declaration: `int UnsafeValue() unsafe_during_construction`
  - Comment: `// CaseId TS-FEAT-0242; subcase reconcile-unsafevalue-81af672c. Role: required-member-or-negative-declaration. Preserve UnsafeValue as the exact surface. Inputs: none. Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[{"kind": "expected-compile-diagnostic", "exactText": "copy from authoritative runner before implementation"}]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `blocking-exact-diagnostic-reconciliation` / `["Preserve exact compiler diagnostic and source line while adding the adjacent comment."]`

### AR-281C984D74AB3BCB — `TestSource/Feature/Delegates/Test_TimerDelegateLambdaSetTimerBoundary.as:19`

- Current: owner `ACoverageTimerDelegateLambdaActor::BeginPlay@L15#lambda-01@L19C56`, kind `lambda`, declaration `function()`; CaseId `TS-FEAT-0078`.
- `reconcile-lambda-01-l19c56-281c984d` → `RepeatingTimerDelegateLambda` (`requiredName=true`)
  - Declaration: `function()`
  - Comment: `// CaseId TS-FEAT-0078; subcase reconcile-lambda-01-l19c56-281c984d. Role: anonymous-lambda-expression. Preserve RepeatingTimerDelegateLambda as the exact surface. Inputs: none. Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `reviewed-required-anonymous-syntax` / `[]`

### AR-A4EAE9098083F211 — `TestSource/Feature/Delegates/Test_TimerDelegateLambdaSingleShotBoundary.as:27`

- Current: owner `ACoverageTimerDelegateLambdaActor::BeginPlay@L24#lambda-01@L27C56`, kind `lambda`, declaration `function()`; CaseId `TS-FEAT-0079`.
- `reconcile-lambda-01-l27c56-a4eae909` → `SingleShotTimerDelegateLambda` (`requiredName=true`)
  - Declaration: `function()`
  - Comment: `// CaseId TS-FEAT-0079; subcase reconcile-lambda-01-l27c56-a4eae909. Role: anonymous-lambda-expression. Preserve SingleShotTimerDelegateLambda as the exact surface. Inputs: none. Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `reviewed-required-anonymous-syntax` / `[]`

### AR-5E7B272990992CB1 — `TestSource/Language/Preprocessor/Test_RejectUnsupportedConditionalPlacement_02.as:14`

- Current: owner `UBadPropertyConditionalCarrier`, kind `method`, declaration `#ifndef UNKNOWN_FLAG UPROPERTY() int BadValue`; CaseId `TS-LANG-0312`.
- `reconcile-uproperty-5e7b2729` → `UPROPERTY` (`requiredName=true`)
  - Declaration: `#ifndef UNKNOWN_FLAG UPROPERTY() int BadValue`
  - Comment: `// CaseId TS-LANG-0312; subcase reconcile-uproperty-5e7b2729. Role: required-member-or-negative-declaration. Preserve UPROPERTY as the exact surface. Inputs: none. Raw result: #ifndef UNKNOWN_FLAG; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "#ifndef UNKNOWN_FLAG", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[{"kind": "expected-compile-diagnostic", "exactText": "copy from authoritative runner before implementation"}]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `blocking-exact-diagnostic-reconciliation` / `["Preserve exact compiler diagnostic and source line while adding the adjacent comment."]`

### AR-C6A18A2BAC312615 — `TestSource/Language/Preprocessor/Test_RejectUnsupportedConditionalPlacement_03.as:14`

- Current: owner `UEditorConditionalCarrier`, kind `method`, declaration `#if EDITOR UPROPERTY() int EditorValue`; CaseId `TS-LANG-0313`.
- `reconcile-uproperty-c6a18a2b` → `UPROPERTY` (`requiredName=true`)
  - Declaration: `#if EDITOR UPROPERTY() int EditorValue`
  - Comment: `// CaseId TS-LANG-0313; subcase reconcile-uproperty-c6a18a2b. Role: required-member-or-negative-declaration. Preserve UPROPERTY as the exact surface. Inputs: none. Raw result: #if EDITOR; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "#if EDITOR", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[{"kind": "expected-compile-diagnostic", "exactText": "copy from authoritative runner before implementation"}]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `blocking-exact-diagnostic-reconciliation` / `["Preserve exact compiler diagnostic and source line while adding the adjacent comment."]`

### AR-8E15E268EA13CDCC — `TestSource/Language/Syntax/EdgeCases/Test_DeclaredFunctionImportRebindsAfterProviderReload_03.as:7`

- Current: owner `::`, kind `import`, declaration `import int SharedValue() from "Tests.Compiler.ImportReloadSource"`; CaseId `TS-LANG-0027`.
- `reconcile-sharedvalue-8e15e268` → `SharedValue` (`requiredName=true`)
  - Declaration: `import int SharedValue() from "Tests.Compiler.ImportReloadSource"`
  - Comment: `// CaseId TS-LANG-0027; subcase reconcile-sharedvalue-8e15e268. Role: required-import-declaration. Preserve SharedValue as the exact surface. Inputs: none. Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-AA768BDF12D98D68 — `TestSource/Language/Syntax/EdgeCases/Test_DeclaredFunctionImportRoundTrip_02.as:7`

- Current: owner `::`, kind `import`, declaration `import int SharedValue() from "Tests.Compiler.ImportSource"`; CaseId `TS-LANG-0029`.
- `reconcile-sharedvalue-aa768bdf` → `SharedValue` (`requiredName=true`)
  - Declaration: `import int SharedValue() from "Tests.Compiler.ImportSource"`
  - Comment: `// CaseId TS-LANG-0029; subcase reconcile-sharedvalue-aa768bdf. Role: required-import-declaration. Preserve SharedValue as the exact surface. Inputs: none. Raw result: int; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "int", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "isolated-script-module", "setup": "Supply typed vectors without hidden expected-value arguments.", "cleanup": "Discard module and retain no mutable global state."}` / `reviewed-exact-reconciliation` / `[]`

### AR-1136E7887CF90B6F — `TestSource/Language/Syntax/EdgeCases/Test_EventNonScriptFacingBoundaries_02.as:13`

- Current: owner `ACoverageEventTimerLambdaBoundaryActor::TryTimerLambda@L10#lambda-01@L13C26`, kind `lambda`, declaration `[]()`; CaseId `TS-LANG-0097`.
- `reconcile-lambda-01-l13c26-1136e788` → `RejectedTimerDelegateLambda` (`requiredName=true`)
  - Declaration: `[]()`
  - Comment: `// CaseId TS-LANG-0097; subcase reconcile-lambda-01-l13c26-1136e788. Role: anonymous-lambda-expression. Preserve RejectedTimerDelegateLambda as the exact surface. Inputs: none. Raw result: void; writebacks: none. Expected values stay in typed vectors. Runner cleans module/delegate/timer/UObject/World state on every exit.`
  - Inputs/result/writebacks: `[]` / `{"type": "void", "comparisonOwner": "contract vector / runner"}` / `[]`
  - Diagnostics/fixture/status/blockers: `[]` / `{"kind": "runner-owned-ue-fixture", "setup": "Create exact World/UObject/Actor/component identity.", "cleanup": "Tear down objects, delegates, timers, worlds, modules, and retained handles on every exit."}` / `reviewed-required-anonymous-syntax` / `[]`

## Owner-mismapped rows

- `TestSource/Definitions/UClass/Test_InterfaceImplementation_01.as:8`: `::` → `IClassFeaturesScriptInterface`; `void Interact()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceDeclarationBoundariesRejected_01.as:9`: `::` → `ICoverageMacrosScriptInterface`; `void Execute()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceDeclarationBoundariesRejected_02.as:10`: `::` → `ICoverageMacrosBlueprintTypeInterface`; `void Execute()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceDeclarationBoundariesRejected_03.as:10`: `::` → `ICoverageMacrosBlueprintableInterface`; `void Execute()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceDeclarationBoundariesRejected_04.as:9`: `::` → `ICoverageMacrosInterfaceFunction`; `UFUNCTION(BlueprintCallable) void Execute()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceKeywordRejected.as:10`: `::` → `ICoverageUnsupportedInterface`; `void Execute()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceMethodsRejected.as:10`: `::` → `ICoverageUnsupportedMethodInterface`; `void PureMethod()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceMethodsRejected.as:12`: `::` → `ICoverageUnsupportedMethodInterface`; `void DefaultMethod()`.
- `TestSource/Definitions/UInterface/Test_ScriptInterfaceMethodsRejected.as:16`: `::` → `ICoverageUnsupportedMethodInterface`; `UFUNCTION() void ReflectedMethod()`.
- `TestSource/Definitions/UInterface/Test_UInterfaceBlueprintableSpecifierRejected.as:11`: `::` → `ICoverageUnsupportedBlueprintableInterface`; `void Execute()`.
- `TestSource/Definitions/UInterface/Test_UInterfaceMacroDeclarationRejected.as:10`: `::` → `ICoverageMacrosUnsupportedUInterface`; `void Execute()`.
- `TestSource/Definitions/UInterface/Test_UInterfaceMacroDeclarationRejected_R01967.as:11`: `::` → `ICoverageUnsupportedUInterface`; `void Execute()`.
- `TestSource/Definitions/UInterface/Test_UInterfaceSpecifierDeclarationRejected.as:11`: `::` → `ICoverageUnsupportedBlueprintTypeInterface`; `UFUNCTION(BlueprintCallable) int GetValue()`.
- `TestSource/Language/Syntax/EdgeCases/Test_Interface_Mixed_01.as:11`: `::` → `UIntfBasic`; `void DoSomething()`.
- `TestSource/Language/Syntax/EdgeCases/Test_Interface_Mixed_01.as:12`: `::` → `UIntfBasic`; `int GetValue()`.
- `TestSource/Language/Syntax/EdgeCases/Test_Interface_Mixed_03.as:10`: `::` → `UIntfBody`; `void DoSomething()`.

## Phantom prior rows

- `LDF` `TestSource/Language/Literals/FString/Test_Negative_01.as:8` owner `::` declaration `void Test()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Preprocessor/Test_ExplicitContextControlsFlagsAndDefaults.as:16` owner `UExplicitContextCarrier` declaration `void ImplicitFunction()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Preprocessor/Test_MissingSemicolonReportsSyntax_02.as:8` owner `::` declaration `int UseShared()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Preprocessor/Test_RejectUnsupportedConditionalPlacement_01.as:16` owner `UBadFunctionConditionalCarrier` declaration `int BadFunction()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Preprocessor/Test_RestrictUsageAllowPattern.as:9` owner `::` declaration `int Entry()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Preprocessor/Test_RestrictUsageInactiveBranchIgnored_01.as:10` owner `::` declaration `int Entry()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Preprocessor/Test_RestrictUsageInactiveBranchIgnored_02.as:10` owner `::` declaration `int Entry()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Syntax/EdgeCases/Test_EdgeCases_Negative_01.as:7` owner `::` declaration `void Test()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Syntax/EdgeCases/Test_Enum_Negative_06.as:10` owner `::` declaration `void Foo()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Language/Syntax/EdgeCases/Test_Interface_Mixed_04.as:10` owner `::` declaration `void Foo()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Definitions/Meta/Test_MacroExpansionIgnoresCommentsStringsAndInactiveBranches.as:20` owner `ACoverageMacrosExpansionBoundaryActor` declaration `int GetLiteralLength() const` — retire/repair; do not synthesize.
- `LDF` `TestSource/Definitions/Meta/Test_MacroMetadataStringsWithClosingParen.as:19` owner `::` declaration `Alpha UMETA(DisplayName="Alpha ) Value", ToolTip="Alpha ) ToolTip"), Beta } int Observe_ClosingParenText_Nominal()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Definitions/Meta/Test_ReflectionMacroCombination.as:9` owner `::` declaration `Ready UMETA(DisplayName="Ready State"), Blocked UMETA(Hidden) } delegate void FCoverageMacroCombinedSignal(int Value)` — retire/repair; do not synthesize.
- `LDF` `TestSource/Definitions/Meta/Test_ReflectionMacroCombination.as:10` owner `::` declaration `Blocked UMETA(Hidden) } delegate void FCoverageMacroCombinedSignal(int Value)` — retire/repair; do not synthesize.
- `LDF` `TestSource/Definitions/UFunction/Test_Params_UnnamedParameter.as:11` owner `AUFuncPNoNameActor` declaration `void Foo(int)` — retire/repair; do not synthesize.
- `LDF` `TestSource/Feature/Delegates/Test_Declaration_Negative_MissingSemicolon.as:8` owner `::` declaration `delegate void FOnActionNoSemi()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Feature/Delegates/Test_Declaration_Negative_NoName.as:8` owner `::` declaration `delegate void ()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Feature/PropertyAccess/Test_BlueprintGetterRemainsCallableWithoutSyntheticAlias.as:12` owner `AAutoAccessorGetterScriptActor` declaration `int32 CheckGetterAccess()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Feature/PropertyAccess/Test_BlueprintGetterSyntheticAliasDoesNotCompile.as:11` owner `AAutoAccessorGetterScriptActorFailure` declaration `int32 CheckSyntheticGetterAlias()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Feature/PropertyAccess/Test_RawFieldAccessCompilesAndRuns.as:12` owner `AAutoAccessorRawFieldScriptActor` declaration `int32 CheckRawFieldAccess()` — retire/repair; do not synthesize.
- `LDF` `TestSource/Feature/PropertyAccess/Test_RawFieldSyntheticGetterDoesNotCompile.as:11` owner `AAutoAccessorRawFieldScriptActorFailure` declaration `int32 CheckSyntheticGetter()` — retire/repair; do not synthesize.

## Final assertions

- `sources=3041/3041`
- `planRows=11987/11987`
- `uniqueCanonicalIdentities=11987/11987`
- `zeroProposalRows=0`
- `passed=true`
