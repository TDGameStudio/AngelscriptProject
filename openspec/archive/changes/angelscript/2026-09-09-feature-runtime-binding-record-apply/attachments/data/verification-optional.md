# Task 5.6 TOptional verification

Task 5.6 completes per-owner `TOptional<T>` engagement, access, reset, copy, nested
lifetime, and UObject-reference operations using the contained type recipes captured in
the detached declaration catalog.

## Behavioral RED

With seven concrete cases present and the new optional-operation API implemented only as
compilable stubs, exact Harness run `c0208015e68245c2998c2cc318634516`
completed with 1 success and 6 expected failures, 0 warnings:

- `CompleteTOptionalProviderSurfaceIsRecorded` passed as the independent 14-member
  declaration-surface control.
- `DefaultAssignAndReadTrackEngagement`, `CopyRetainsValueAfterOriginalReset`,
  `ResetDestroysOneCountedElement`, `UnsetValueReportsDiagnostic`,
  `NestedOptionalCopiesIndependentValue`, and
  `HandleReferenceEnumerationFollowsEngagement` failed at the missing engagement API.

The validated RED report is under
`Saved/Harness/Unreal/Runs/c0208015e68245c2998c2cc318634516/AutomationReport`.

## Exact GREEN

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Optional.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `30fd5e613b9d4b08a23780b5f2e9d4be` passed all 7 cases with 0 warnings
and 0 errors. The cases prove default-unset and assign/read behavior; independent copies;
one destruction on counted reset; an explicit unset-access diagnostic; nested optional
copy ownership; handle enumeration only while engaged; and exact accounting of all 14
`TOptional.MethodSurface` members with native targets.

## Shared proof and identities

The final editor build was Harness run `43da2253271c48c0992bcd5e08dbad18`.
Impact-expanded Harness run `26be278b89c448c18116cbfc27a0a223` passed the full
`Angelscript.UnitTest.RuntimeBindings.` selection: 214/214 tests, 0 warnings, 0 errors.
Final SHA-256 identities:

- `UnrealEditor-AngelscriptRuntime.dll`: `9bd1e90ef67f60bf46d9977a67bb964fe2f59ade53ad5f21a6b484f588abe589`
- `UnrealEditor-AngelscriptTest.dll`: `91655aa9e87b614db9214c5e3f2061c421cf6664b1ade15da2ffd1ee31708597`
- `AngelscriptTypeBindInfoApply.cpp`: `352a05811b64b65c327996c72dfe417b8535c70eace914a54734cdd63bddc203`
- `AngelscriptTypeBindInfoApply.h`: `1222d7ee6710f40b9ea2e987d9a4c3d3446707bc88d7b2c3a559ffcdec5d679b`
- `RuntimeBindingOptionalTests.cpp`: `2f42098f8fee8a0f46a2ccbcf3cd1bc76da895b7aed8cdd3021257ef1f2e1d82`

No broader NativeEngine, Integration, Performance, or full Unreal suite was selected.
The full RuntimeBindings run covers the shared record/apply operation layer changed by
this bounded family migration.
