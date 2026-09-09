# Vector and integer-point binding verification

Task: 4.3. Parent base `a9afd56e73b9289ed32dee8210d7b96ac0b3b578`; plugin base `edc13e98d7a63fa22b76620302d1294fe6126641`.

## Commands and outcomes

- Build command: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`.
- Exact RED/GREEN command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.Vectors.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Initial RED `e8d76d6c`: six expected behavioral failures from the selected-provider recorder skeleton. The ten providers could not publish an installable detached family image.
- Intermediate run `20c9100`: two successes and four failures exposed template declarations incorrectly entering the selected-family catalog. After excluding template declarations for their later dedicated installer, run `66ef3a6e` reached the first successful case and exposed a test-context double release during fixture teardown; the fixture now creates and owns its raw native context directly.
- First six-case GREEN `e2bdbde73f2a40dbb61fdb4b4016f7f8`: six successes, zero warnings/errors, exit 0.
- Strengthening run `dfc75186f880483880c02c6076d636bd`: the new native constructor case succeeded. The sole failure (`Expected 372 to equal 389`) identified 17 intentionally recorded namespace constants omitted from the preliminary static estimate. Source recount independently established 372 constructors/properties/methods plus 17 constants.
- Final build `67a35734f7fc4eaaa3f53b300607f20b`: succeeded, exit 0, 14.5 seconds.
- Final exact GREEN `8995caea1ba74862bc02b05b0733514a`: seven successes, zero warnings/errors, exit 0.
- Shared command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Shared GREEN `acbc5958d8e143cb87fc70434a4b2700`: 139 successes, zero warnings/errors, exit 0. This refreshes the common catalog, Store, parser, application, ownership and reflection contracts used by the selected-family path.
- Every asynchronous operation was observed through terminal `ue.run.status`; source remained frozen during builds and tests.

The fixture records the real non-template declaration catalog, then executes exactly the ten owning vector/point providers into the same writable Store. It seals and installs that image without executing unrelated member providers. The exact inventory assertion accounts for all 389 provider-sourced contributions across type and namespace scopes. `FVector3f` and `FIntVector4` constructors are invoked through installed native contexts into correctly aligned storage, proving float32 and int32 argument transport rather than declaration presence alone.

## Exact case mapping

| Case | Task proof | Final result |
|---|---|---|
| `AllFamilyDeclarationsAndRepresentativeSurfaceAreRecorded` | All ten declarations contain constructors/properties; exact 389 selected-provider records are present | Success |
| `DoubleVectorSizeSquaredUsesLiteralComponents` | `FVector(1,2,3).SizeSquared()` returns 14 | Success |
| `DoubleVectorAdditionReturnsFiveSevenNine` | Native `opAdd` returns literal components `(5,7,9)` | Success |
| `IntegerPointIndexAliasesOnlySelectedComponent` | Mutable `FIntPoint::opIndex(1)` aliases Y and preserves X | Success |
| `FloatAndDoubleVariantsRetainWidthLayoutAndProperties` | float32/float64 sizes, alignments and X/W property declarations match native types | Success |
| `NormalizingZeroPreservesZeroContract` | Zero input remains zero and `GetSafeNormal` returns the supplied fallback | Success |
| `RepresentativeFloatAndIntegerConstructorsUseNativeWidths` | Installed `FVector3f` and `FIntVector4` constructors receive native-width arguments and construct exact components | Success |

## Final source and binary identity

| Path | SHA-256 |
|---|---|
| `Core/AngelscriptTypeBindInfoCatalog.h` | `0147e0b8ca4253551b3f66b84691a4fc4fe9c7f69bbc1fcbaa4e3ec4e7fbf0dc` |
| `Core/AngelscriptTypeBindInfoCatalog.cpp` | `89253ac1ee12da47c63d561e0e3a23481c6c9d5540b00086238ffe2828f60926` |
| `Binds/Bind_FVector.cpp` | `539dee935680f6788985651417f9776b81dce8a4abae7655dfce0702761fa41b` |
| `Binds/Bind_FVector2D.cpp` | `37827e57a1a237211855309fcf15fedf1645bc7e8023581ac1109650e1b3fbd3` |
| `Binds/Bind_FVector2f.cpp` | `6170dd5bb82f9a9800efcd515ad0da7af9310dab1f902dbedfefc96d99b7fd27` |
| `Binds/Bind_FVector3f.cpp` | `24b0dbfef30dc66b7b12eecf1bb1c0c344a6cf6c6995fc219f673b140ac12d02` |
| `Binds/Bind_FVector4.cpp` | `0573b10cb10879568576c3311f9121863795d7a5b5c3f03ca4fa0338bed8962a` |
| `Binds/Bind_FVector4f.cpp` | `e802143a00a7c69607373becd020b82b5791664c185fdcfef309436e84343cbb` |
| `Binds/Bind_FIntPoint.cpp` | `d36266a57faac76b6804f360f861132180b0f8f0d1a1f4651020927f6e2154b3` |
| `Binds/Bind_FIntVector.cpp` | `2bf527bc7532af5ca76fe5285d742adffebfe1ad131e0cc9edd4a804ce82c45b` |
| `Binds/Bind_FIntVector2.cpp` | `beeb31518a3f399fbac09964d1de67569a361cc06824309389358fd049bab7e8` |
| `Binds/Bind_FIntVector4.cpp` | `e6b1ac93d28965008a542ccc56178cb21a61c3db1d0960b76024415ea6007ea0` |
| `RuntimeBindingVectorsTests.cpp` | `216ff95a4a522f67829c840bc95b6fa70bfe1cf7b610f8716c993c4a0116c073` |
| `UnrealEditor-AngelscriptRuntime.dll` | `d6e997e5218fc5b1811c1a01835bebf092b5ac0fdb025587298eb6d699fb72a6` |
| `UnrealEditor-AngelscriptTest.dll` | `f35157208752dee6506db56730bffc2bee3b272428a6b541abc55c8e3ca87904` |

Final exact report: `Saved/Harness/Unreal/Runs/8995caea1ba74862bc02b05b0733514a/AutomationReport/index.json`, SHA-256 `56ef39a094b4c71c5f98e9517c75500e65d8970237726a482ad7a1a9f0e1696f`.

Shared report: `Saved/Harness/Unreal/Runs/acbc5958d8e143cb87fc70434a4b2700/AutomationReport/index.json`, SHA-256 `2ce83f4a0f168e616edeb643e2b60c55d383d1eed49664b5bc47de6fa724ab3b`.

Full Runtime coverage, other value families, templates, startup, packaging, legacy suites and Performance are omitted because task 4.3 changes one selected value family plus its catalog composition helper. The 139-case shared RuntimeBindings run covers the affected common contract; complete provider accounting remains task 8.2.
