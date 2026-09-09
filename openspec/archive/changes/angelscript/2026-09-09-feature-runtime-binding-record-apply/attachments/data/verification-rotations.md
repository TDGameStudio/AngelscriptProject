# Rotation, transform and matrix binding verification

Task: 4.4. Parent base `a9afd56e73b9289ed32dee8210d7b96ac0b3b578`; plugin base `edc13e98d7a63fa22b76620302d1294fe6126641`.

## Commands and outcomes

- Build: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`.
- Exact tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.Rotations.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Setup build `d4de19551a334f27bdaf2500a56403ec` failed because the new fixture's generic names collided with the preceding vector fixture in a unity translation unit. Unique rotation fixture names corrected this test-only setup failure; build `1493a88b66bf48a09baf4547245c97f5` succeeded.
- Pre-RED run `99de79972c0341cbb20def24edcf8ad8` asserted in `Bind_FMatrix.cpp` because the provider requested `GetTargetEngine()` while recording. It produced no Automation report and is retained as setup evidence, not behavioral RED. All seven provider namespace scopes were changed to the recording-aware `FNamespace(Binds, ...)` form.
- Behavioral RED `5d313c0caa924a3bbe6ce4fe18ab0e58`: five expected execution failures and one passing 386-record inventory control, exit 255. Engine creation rejected legacy trailing `no_discard` tokens in `FQuat.MakeFromEuler`; the five execution cases all stopped at that shared installation prerequisite.
- The affected rotator/quaternion global declarations now express `NoDiscard` through typed binding metadata rather than parser text. Build `e1090be1252c4aac8057715c2f61ee75` succeeded.
- Exact GREEN `c728c35df71f4e339c4129241dc67271`: six successes, zero warnings/errors, exit 0.
- Shared tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Shared GREEN `c031eea5591a4ee28d2a1fba70b3751c`: 145 successes, zero warnings/errors, exit 0.
- All managed operations reached terminal status through `ue.run.status`; no source writes occurred during builds or tests.

The fixture combines the real non-template declaration catalog with exactly seven owning member providers: double/float rotators, quaternions and transforms plus `FMatrix`. The inventory control accounts for 386 selected-provider records. Native execution proves identity and translated transform positions, inverse round-trip within `1.e-9`, quaternion identity composition within `1.e-12`, and homogeneous matrix output with W=1.

## Exact cases

| Case | Proof | GREEN |
|---|---|---|
| `AllFamilyDeclarationsAndProviderSurfaceAreRecorded` | Seven native declarations and all 386 provider contributions | Success |
| `IdentityTransformPreservesLiteralPosition` | Identity maps `(1,2,3)` exactly | Success |
| `TranslationAddsTenTwentyThirty` | Translation maps `(1,2,3)` to `(11,22,33)` exactly | Success |
| `InverseTransformReturnsOriginalWithinEpsilon` | Transformed point round-trips within `1.e-9` | Success |
| `IdentityQuaternionCompositionIsUnchanged` | Multiplication by identity preserves the quaternion within `1.e-12` | Success |
| `MatrixIdentityPreservesHomogeneousPosition` | Identity matrix returns `(1,2,3,1)` | Success |

## Final identities

| Path | SHA-256 |
|---|---|
| `Binds/Bind_FRotator.cpp` | `11b181af2fac9b5215343b4c7ce3220ecddc27b4cb24ec22b67aec26d14cfd74` |
| `Binds/Bind_FRotator3f.cpp` | `4935b710d1d478fc6f4bf35dba86e93b7eef8893f25706d230a366e3511f2890` |
| `Binds/Bind_FQuat.cpp` | `82ffca766618e1d888ad1e2534e1207c8f851e80a069e64b4379a3ccd4ca7595` |
| `Binds/Bind_FQuat4f.cpp` | `70de7cf6335b5947fbfeb4e60e4be4b8c293b0d002ec0dea76b2ac817bcf0841` |
| `Binds/Bind_FTransform.cpp` | `a2eb72695c3be3e26e8a17ac17fb9be2a1658142f535b26276f3bdc0e08ad478` |
| `Binds/Bind_FTransform3f.cpp` | `c655a52005840a92dbc325133838387ce93983863134d4b72420e2e8f158d668` |
| `Binds/Bind_FMatrix.cpp` | `583c34cc5b0b85962850893ae8e1242b1b6857a4e5ba29a514aed697f970794d` |
| `RuntimeBindingRotationsTests.cpp` | `f06766bb2535e793110fc3bee3494c05a430ef7dbca5a661abc2e960d6778a83` |
| `UnrealEditor-AngelscriptRuntime.dll` | `5f0b0d5c0f5cdb6e0c0367cbc7ed347f4aee8c10af071608ef8609580a8f0d4e` |
| `UnrealEditor-AngelscriptTest.dll` | `3d2e47018f40a1ffa63f4ad36c0e86720f4adae62c0f3d84b42d8fefe15f6b69` |

RED report `Saved/Harness/Unreal/Runs/5d313c0caa924a3bbe6ce4fe18ab0e58/AutomationReport/index.json`: `b9af06968f935bfbf38e1db2f4b5d48627808cf7f5d33534ab2c433177660d0e`.

Exact GREEN report `Saved/Harness/Unreal/Runs/c728c35df71f4e339c4129241dc67271/AutomationReport/index.json`: `05a58686d1855c3f555fd70c4e18f5c7a1f3af500706d84f6200ac50b7efd0f6`.

Shared GREEN report `Saved/Harness/Unreal/Runs/c031eea5591a4ee28d2a1fba70b3751c/AutomationReport/index.json`: `19fddfbf06c68fcde83802281a5da43eb11c805a8345b1191b78dfc2d0c3e778`.

Other value families, templates, full Runtime accounting, startup, packaging, legacy suites and Performance are omitted because this task owns only the selected rotation/transform/matrix providers. The 145-case shared RuntimeBindings run covers the affected catalog/parser/application contracts.
