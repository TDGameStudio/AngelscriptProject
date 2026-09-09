# Plane, box, sphere and bounds binding verification

Task: 4.5. Parent base `a9afd56e73b9289ed32dee8210d7b96ac0b3b578`; plugin base `edc13e98d7a63fa22b76620302d1294fe6126641`.

## Commands and outcomes

- Build: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; NoWait = $true; TimeoutMs = 900000 }`.
- Exact tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.Bounds.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Behavioral RED `3bb2692bf704422b82eedce6e3400828`: one successful 144-contribution inventory control and six expected execution failures, zero warnings and 12 errors, exit 255. All execution cases reached Engine creation and identified the complete `FBoxSphereBounds` constructor's unresolved `TArray<FVector>` dependency. This evidence triggered the applied 5.2 dependency correction.
- After task 5.2, adjacent run `d52a60a834e0414eabe87874fd67b3c2` reproduced only these same six Bounds failures among 160 RuntimeBindings cases. The template specialization reached metadata admission, establishing that qualified container uses still needed an unqualified instance identity.
- `ResolveTypeUseInImage` now interns and materializes the unqualified specialization key, then applies the source qualifiers to the resulting data type. Six legacy trailing `no_discard` spellings in the owning FBox/FBoxSphereBounds providers now use typed `.NoDiscard()` metadata. Intermediate focused runs `fd51bc67370f4cc3803d6372869615c5` and `5fb7f1fcaa5843fbb5a065f6b089b666` localized those two ordinary installation failures.
- Final build `c201af87cf694c72ae47e5a9a3177fd1` succeeded.
- Exact GREEN `ffc00f9e7a5b483f831314fb140f9ba8`: seven successes, zero warnings/errors, exit 0, complete valid report.
- Shared tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Shared GREEN `3913911aebe64f45b1a68c17afb4a7d5`: 160 successes, zero warnings/errors, exit 0, complete valid report.
- All managed operations reached terminal status through `ue.run.status`; no source writes occurred during builds or tests.

The fixture combines the real non-template declaration catalog with the nine owning plane, box, sphere and box-sphere-bounds providers. It retains the complete provider declarations, including the `TArray<FVector>` constructor rather than substituting a reduced surface.

## Exact cases

| Case | Proof | GREEN |
|---|---|---|
| `AllFamilyDeclarationsAndProviderSurfaceAreRecorded` | Seven family declarations and all 144 selected provider contributions are present | Success |
| `BoxCenterUsesLiteralCorners` | Corners `(0,0,0)` and `(2,4,6)` yield center `(1,2,3)` | Success |
| `BoxInsideAndOutsidePointsClassifyCorrectly` | A literal inside point is accepted and an outside point rejected | Success |
| `BoxUnionExpandsBothEnds` | Union expands the minimum and maximum extents | Success |
| `SphereRadiusTwoContainsOriginButNotThree` | Radius two contains the origin and excludes `(3,0,0)` | Success |
| `PlaneDistanceUsesKnownNormal` | A known plane normal produces the expected signed distance | Success |
| `DefaultBoxConstructorPreservesInvalidEmptyState` | Default construction retains UE's invalid/empty box state | Success |

## Final identities

| Path | SHA-256 |
|---|---|
| `Core/AngelscriptTypeBindInfoDraft.cpp` | `53689d9a7f8ac46cba1c504c3466d5477dc6c93dc53101b5cf106ee8b74a1261` |
| `Binds/Bind_FPlane.cpp` | `5bc286723f82b24baeed8ef02d73e448ad757e24eef0da809956736d53f875d3` |
| `Binds/Bind_FBox.cpp` | `f8b606391e0c88267c0fff097780ad80ff0776e3fcf0d3927724f7c72fc44bf9` |
| `Binds/Bind_FBox3f.cpp` | `8949b282bd3760825c7f45570105ab1d7be72a736d9fba21c2c8735a82bf6d8b` |
| `Binds/Bind_FSphere.cpp` | `b6951a03cf5f14bf97efa3f2a85033ef8ecb4f4e683cd1b84b9972c6d3bfd2d` |
| `Binds/Bind_FBoxSphereBounds.cpp` | `302f85d14c38b9c3821c64915b35507e4149747308b9f7c753c1819e16387b49` |
| `Binds/Bind_FBoxSphereBounds3f.cpp` | `73506759bb887171d81851c5836e0d36dd3c4dd52d1d62397e92b17b54c26fd9` |
| `RuntimeBindingBoundsTests.cpp` | `df7951469f39a329a80a042754ea8514a7eb08cc514ee9aad4d8e74c53ded1da` |
| `UnrealEditor-AngelscriptRuntime.dll` | `36abbf0920e13e2c9d4f3e955115ffff276e9b257608b9f5202fbf6f61d1e573` |
| `UnrealEditor-AngelscriptTest.dll` | `8fe04a6e0c9b44893c7b9d9cabd3055c17e51f505aef3a39b92d70bb00b8a198` |

RED report `Saved/Harness/Unreal/Runs/3bb2692bf704422b82eedce6e3400828/AutomationReport/index.json`: `99231d28bd945a44c5239cbebd915edf1cf03351a073c618f75d317897ba7a91`.

Exact GREEN report `Saved/Harness/Unreal/Runs/ffc00f9e7a5b483f831314fb140f9ba8/AutomationReport/index.json`: `5f4525a7557aadca0176844b06f3e10ccd9f6d0aa49c1f5ccae115ae03a75d46`.

Shared GREEN report `Saved/Harness/Unreal/Runs/3913911aebe64f45b1a68c17afb4a7d5/AutomationReport/index.json`: `78d25c609549957e7c84ab9dbda9608fdb064e7dda3dd764551f799c34d05c98`.

Other value families, complete container members, reflection families, full Runtime accounting, startup, packaging, legacy suites and Performance are omitted because this task owns only the selected bounds providers. The 160-case shared RuntimeBindings run covers the affected canonical type, template, parser and application contracts.
