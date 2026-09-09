# Collision-family runtime binding verification

Task: 7.2. Verification date: 2026-09-09 (Asia/Shanghai).

## Outcome

The collision providers record into a detached Store, install into an explicitly owned Engine, and expose usable value, reflected-property, and world-query behavior. Recording-aware namespaces replace ambient Engine access. World-collision async signatures own their concrete callback declarations, reflected structs supply their captured lifecycles to template instances, and the query adapter rejects absent/null contexts before invoking `UWorld::LineTraceTestByChannel`.

`FTraceHandle` retains the non-overlapping `_FrameNumber` and `_Index` view. The redundant `_Handle` union alias was removed because the accepted metadata layout contract rejects overlapping native properties. `FTraceDatum::TraceChannel` now uses its own native member rather than the unrelated overlap-datum member.

## RED and setup evidence

The exact selector was `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.'; Fast = $true; TimeoutMs = 600000 }`.

Initial compilation and execution exposed setup defects before behavioral RED: a missing overlap header, a unity-build fixture symbol collision, declaration providers selected twice, detached providers calling `GetTargetEngine`, the overlapping `FTraceHandle` layout, missing async callback nominals, the missing reflected-struct/template lifetime handoff, and double initialization of a transient `UWorld`. Each was repaired at its demonstrated boundary and is not claimed as behavioral RED.

Run `bf2e983062a448ee873f88d4182cddef` is the valid grouped RED: six discovered and executed cases, four successes, two failures, zero warnings. `EmptyTransientWorldQueryReturnsNoHit` and `NullWorldContextProducesExplicitDiagnostic` reached the deliberately unavailable collision adapter and failed; the value/property/accounting controls passed. Report SHA-256: `04F1C5B4242B9ADE3FF9CCEC5B061459662DA4DBF59905CBEB8D13BF1F074215`.

## GREEN evidence

Build run `a8783cd8b066426e8f10e4869687ccf7` succeeded for `AngelscriptProjectEditor Win64 Development`, exit 0.

Exact run `18c1a59f26e7457082e57128e4aff777` passed all six cases with zero warnings/errors, exit 0:

- `Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.Collision.SphereShapeRadiusTwoRoundTrips`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.Collision.QueryIgnoredActorCollectionCopiesIndependently`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.Collision.HitAndOverlapPropertiesMatchFixtureValues`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.Collision.EmptyTransientWorldQueryReturnsNoHit`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.Collision.NullWorldContextProducesExplicitDiagnostic`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.Collision.EveryCollisionDeclarationAndNativeRecipeIsAccounted`

Exact report SHA-256: `C6914F9F3A6DC4C3F279B3A4E2F6AE03103320F185691C96BB8E02263C331B31`.

Shared run `71d54eced621487b8495a2dca8202d89` passed all 260 `Angelscript.UnitTest.RuntimeBindings.` cases with zero warnings/errors, exit 0. Shared report SHA-256: `AA6BB79A7F93E97190C16C40997B70C3D54F3436B81291BB44A60371D0270057`.

## Final source and binary identity

| Path | SHA-256 |
|---|---|
| `Core/AngelscriptTypeBindInfoApply.h` | `DADBD401ADEB1819528EA72046293376AE3134BA4BBA6CA760F8872A8410C7D4` |
| `Core/AngelscriptTypeBindInfoApply.cpp` | `3D3EA887E3609C49E983B8C135E3052063779102C73F32FD89F311B740C18115` |
| `Binds/Bind_CollisionProfile.cpp` | `D437E121BC94A8EE75142EED631461C80265D4DD74E2110E5B9C261CCD7DA658` |
| `Binds/Bind_FCollisionQueryParams.cpp` | `80D812646511601B27A21EEB3B60096631A63CE97ABEC4C716647CC497FF79E1` |
| `Binds/Bind_FCollisionShape.cpp` | `5398AA521C300EC83935360B1792377E3C11203FC1266397C65557D3224A5C71` |
| `Binds/Bind_UCollisionProfile.cpp` | `681122980E1098CC4B4D3348686AE93CC63AA977B1E27132DCD571CAA0787718` |
| `Binds/Bind_WorldCollision.cpp` | `5EA510962B7B699BC43EB7481C92FDC47A91559D12C70C7E40BC3C28E958E98E` |
| `Bindings/RuntimeBindingCollisionTests.cpp` | `6946308D87574C82A2C97F248E0692ADA4533BECBCC48FDE197C8A28B320B67C` |
| `UnrealEditor-AngelscriptRuntime.dll` | `45013F71012C9FD47B935E89D611F59BBF25ABD88132DE97DADC2054C1E6BD0C` |
| `UnrealEditor-AngelscriptTest.dll` | `661ED0DCE0D3A4F61908458B407A34103C179F21D906245E0A5C7630DF9A351D` |

NativeEngine, baseline, packaging, performance, JIT, and legacy suites remain reserved for their final or separately scoped tasks. The full RuntimeBindings run covers the affected shared template/runtime contract.
