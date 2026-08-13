# Packaged Provider And Legacy Cutover Notes

This attachment is the incremental investigation log for tasks 10.1-10.4. It
records package-only failures and the evidence required before deleting the
legacy `FJITDatabase`/FunctionId/DataGuid activation path.

## 2026-08-13: first retained Development package probe

The pre-existing disposable Development archive at
`Saved/CachePackage/staticjit-testjit-game-exclusion-Development/20260812_210602_701_8ec82d49`
was intentionally reused only as an early probe; it is not final evidence for
the current source tree.

The earlier package build itself had succeeded, but the smoke correctly
rejected an ignored host artifact copied into the archive:
`Script/PrecompiledScript.Cache` (16,919 bytes). The workspace copy was moved
to the recoverable quarantine
`Saved/LegacyArtifacts/refactor-as-static-jit-multi-provider/PrecompiledScript.Cache`
and the archive copy to the run-root sibling
`QuarantinedPrecompiledScript.Cache`. This is derived legacy data, not source;
the current Cache V2 path neither needs nor accepts it.

After removing that artifact from the archive, the package-style process
reached Runtime binding but failed before AngelScript source compilation:

```text
FTestDynamicDelegateFloat
void Execute(float32 float) const allow_discard
Expected ')' or ','; instead found reserved keyword 'float'
```

The process therefore could not reach the StaticJIT Provider routing gate and
did not receive the normal `-as-cache-exit-after-startup` shutdown request. The
two launched processes were explicitly stopped after their paths were checked
to be inside that disposable archive.

This first observation was initially treated as a possible reflected-identifier
escaping defect. Current-source evidence does not support that conclusion: the
new package-style Engine regression
`Angelscript.TestModule.Bindings.DelegateReservedParameter` initializes the
full binding surface and resolves `FTestDynamicDelegateFloat.Execute`
successfully (`1/1 PASS`). No production binding change was made from the old
archive alone.

The retained archive is therefore classified as stale-binary evidence. It is
useful for proving that the package harness must fail closed when startup does
not reach StaticJIT routing, but it cannot establish a current source defect or
serve as the Development acceptance build. A fresh Development and Shipping
package from the current source tree remains mandatory.

## 2026-08-13: Development link-audit scope correction

The first fresh Development BuildCookRun completed successfully, but the new
package runner initially rejected the monolithic game link response because it
contained UE's `LiveCoding` objects. Investigation of UE 5.8 target rules proved
that Win64 x64 non-Shipping Game targets enable the Engine LiveCoding module by
default. This is not a dependency introduced by `AngelscriptJIT`; the generated
carrier's `AngelscriptJIT.Build.cs` depends only on `Core` and
`AngelscriptRuntime`, and its source includes no Live Coding or Editor surface.

The audit is corrected to enforce the stated architectural boundary: packaged
JIT/Runtime modules must not depend on Live Coding, Editor, or test modules. It
continues to reject Editor/Test objects and binaries in the game product, while
not treating an unrelated Engine-default component of the monolithic
Development executable as a JIT dependency. Shipping still naturally excludes
UE Live Coding. The project target is intentionally not weakened merely to
satisfy an over-broad string check.

## 2026-08-13: fresh Development process overturned the in-process result

After correcting the dependency-audit boundary, the freshly built Development
archive was launched. The independent game process reproduced the exact
`FTestDynamicDelegateFloat` registration failure before StaticJIT routing. This
overturns the earlier provisional conclusion based on the in-process
package-style test: that test ran after the Editor's primary binding lifecycle
and was not a sufficient process-isolation oracle. The fresh package is the
authoritative RED evidence.

The two process images were verified to live below the disposable archive and
stopped explicitly. The production fix is intentionally narrow and generic for
delegate declarations: `BindDelegateEvent` asks the target AngelScript Engine's
tokenizer whether each reflected parameter name is one complete identifier. A
keyword or otherwise invalid token is replaced by deterministic diagnostic-only
`__ASArg<N>`; positional marshalling and reflected property identity are
unchanged. This avoids a duplicated keyword table and also de-duplicates emitted
diagnostic names. The regression now asserts the exact safe declaration, not
merely that an `Execute` method exists.

## 2026-08-13: target-profile identity was still derived from the Editor host

The next fresh Development archive built, cooked, staged, and linked the
`AngelscriptJIT` provider successfully. Its first packaged-process start did
reach routing, but the Summary-mode stdout capture contained no route record.
A retained Verbose relaunch and the Engine-owned full log showed that this was
not a missing module or registry registration:

```text
StaticJIT Provider routing: code=0 profile=GameDevelopment publication=1
providers=1 verified=18 exact=0 native=0 vm=18 references=12/12
matchResults=[5:18]
```

Match result `5` is `ProfileMismatch`. The generated GameDevelopment artifact
profile was `aff9d1e6...`, while the independent package process published
Cache V2 profile `99169f10...`. `BuildAngelscriptCacheEnvironmentProfile`
used compile-time `WITH_EDITOR`, `UE_BUILD_*`, and `PlatformName()` even when
the commandlet supplied an explicit Game target override. The fix makes the
target override authoritative for target kind, configuration, and platform
family (`Windows` rather than the Editor-host flavor `WindowsEditor`).

The new regression
`Cache.EnvironmentIdentity.FAngelscriptCacheEnvironmentTests.TargetOverrideContributesIndependentlyOfPreprocessorOptions`
failed before the fix and passed afterward. Its Game override produces the
same three identities observed in the real package:

- compatibility: `7b3283166ab36636343f06e3a3a93a400c6074a2b78084b2ad8f1fc108121f14`;
- context: `9876546bf9cd28ba543d9255dc5a397593efb0d9ac76e09c3cdbd815cf60c28f`;
- profile: `99169f10d0c9522dde3901374a568e9cb16b2d3d51948a4cddcc8abe19cd02fc`.

All three generated profiles were then regenerated and independently verified
with `DifferenceCount=0`.

## 2026-08-13: native-environment identity had the same host/target leak

After the artifact-profile fix, another Verbose retained-package launch showed
`matchResults=[6:18]`, i.e. `EnvironmentMismatch` for every otherwise matching
function. The Provider manifest used the Editor-host platform name when
building the native-environment fingerprint, while the packaged process used
the Game platform name.

The TDD regression
`StaticJIT.Generation.Profiles.FAngelscriptJITGenerationProfileTests.GameProfilesUseTheTargetPlatformFamilyForNativeIdentity`
failed first, then passed after Game profiles were changed to use
`FPlatformProperties::IniPlatformName()`. Editor profiles continue to use the
host-specific `PlatformName()`. Regeneration produced GameDevelopment native
environment `dd01149377820501cefac706ebb4e6e03cb4266c7547f7557e42bda1fda99758`
and GameShipping native environment
`abedcc75ddf259b22c885a1c17966cdec121bb098ef3d8cbf6bfc86c1ae22eb1`;
a second all-profile verification reported three `DifferenceCount=0` results.

## 2026-08-13: Development package and two-process gate passed

Fresh evidence root:
`Saved/StaticJITPackage/staticjit-provider-native-fixed-Development/20260813_090231_750_179fe075`.
BuildCookRun, link-response inspection, archive/module-surface inspection, and
both independent packaged-process starts passed. The two launches deliberately
used reverse-lexical isolated cache roots (`CacheZ`, then `CacheA`) and selected
the same stable signature. Each route reported:

```text
profile=GameDevelopment providers=1 verified=18 exact=18 native=18 vm=0
references=12/12 matchResults=[0:18]
```

The accepted Provider generation is
`09285201c8fd8b3817d2cc73ad6c292e1a6c821075631cf34ab616f81bc4bf5d`.
The stable comparison intentionally excludes process-local pointers, numeric
FunctionIds, and publication ordinals.

## 2026-08-13: first Shipping archive exposed two lifecycle/target-semantic gaps

The first Shipping BuildCookRun completed successfully and compiled all eight
`GameShipping` module-owned JIT sources, but its structure report showed all 18
verified artifact identities routed to VM with `MissingProviderEntry`. The
carrier was a Runtime module loaded at `PostDefault`, the same phase as
`AngelscriptRuntime`; a monolithic packaged process can perform the initial AS
compile before a same-phase project module starts. The carrier contract and
generated/project descriptors now use `PreDefault`, so registration is complete
before the Runtime's `PostDefault` bootstrap. The scaffold regression was first
made to fail on the old phase and now requires `Runtime` plus `PreDefault`.

The same report also exposed a Shipping-only artifact-profile mismatch. A true
Shipping host sets AngelScript's `asEP_BUILD_WITHOUT_LINE_CUES`, but an
Editor-hosted `GameShipping` generation engine had not emulated that target
property. The regression
`Cache.EnvironmentIdentity.FAngelscriptCacheEnvironmentTests.ShippingTargetOverrideUsesShippingEngineProperties`
failed with property value `0` and passes with `1`. Both engine initialization
paths now derive the setting from an explicit release target override when the
Editor host itself retains debug values.

After this correction, all profiles were regenerated and independently
verified with three `DifferenceCount=0` results. The new GameShipping identities
are:

- artifact profile:
  `5dc64764efed88608c4266d9449cbdb105571ca28fafba2603c771dc4f50e9aa`;
- native environment:
  `abedcc75ddf259b22c885a1c17966cdec121bb098ef3d8cbf6bfc86c1ae22eb1`;
- Provider generation:
  `52f368ac091b2dc96358bbf7cd45a2879c623a4cc17cbb24bdeec44e4e9467d2`.

Shipping target link response files also include the configuration suffix
(`AngelscriptProject-Win64-Shipping.exe.rsp`). Resolution is now configuration
aware and covered by a standalone PowerShell fixture.

Shipping builds do not emit the Development startup route log, but they do
write the Engine-owned schema-revisioned structure report requested by the smoke
runner. The gate now falls back only when the route log has zero records and
then verifies the current artifact profile plus every manifest
`moduleKey/functionKey/executionHash/debugHash` tuple. Every verified tuple must
have `artifactMatchResult=0` and select `Native`; unrelated non-artifact VM
routes are not misreported as Provider fallbacks. Duplicate, missing, stale,
partial, or VM-selected manifest routes fail the gate. This parser has a
standalone success-and-negative fixture.

The next two fresh Shipping archives both built/cooked/archived successfully
but correctly failed the strict runtime-profile gate: the process remained on
`1673868c...` while the manifest used `5dc64764...`. A temporary exhaustive
matrix proved that no combination of the six target preprocessor flags,
automatic imports, or line-cue mode alone reproduced the process identity.
Cache diagnostics were therefore extended to schema v5 with the exact sorted,
path-free canonical compile/context inputs that are hashed into the profile.
The resulting direct diff contained exactly two fields:

```text
Editor-hosted GameShipping: EngineProperty.8=1  EngineProperty.12=1
real Shipping process:      EngineProperty.8=0  EngineProperty.12=0
```

Properties 8 and 12 are `BUILD_WITHOUT_LINE_CUES` and
`INCLUDE_JIT_INSTRUCTIONS`. The latter exposed a Shipping-only C++ correctness
bug: both `SetEngineProperty(INCLUDE_JIT_INSTRUCTIONS)` and
`SetJITCompiler(...)` were side-effecting expressions inside `checkf`.
Shipping compiles out `checkf`, so neither call occurred. They now execute into
explicit result variables before assertion. The line-cue decision is also tied
directly to `UE_BUILD_SHIPPING || UE_BUILD_TEST` (or the explicit release target
override) rather than being inferred through debug-feature macros. The schema-v5
diagnostic surface is retained because it turns future environment mismatches
into a deterministic input diff rather than a hash-only investigation.

## 2026-08-13: Shipping package and two-process gate passed

Fresh evidence root:
`Saved/StaticJITPackage/staticjit-provider-shipping-sideeffect-fixed-Shipping/20260813_100132_684_a63da84f`.
BuildCookRun, the configuration-aware link-response check, archive/module
surface checks, and both independent packaged-process starts passed. Each
schema-v5 structure report proved:

```text
profile=GameShipping providers=1 verified=18 exact=18 native=18 vm=0
references=12/12 matchResults=[0:18]
EngineProperty.8=1 EngineProperty.12=1
```

The report contains 38 additional, unverified functions that correctly retain
VM routes; `vm=0` above is specifically the fallback count among the 18
Provider-owned verified artifacts. Both launches selected the identical stable
route set with Provider generation
`52f368ac091b2dc96358bbf7cd45a2879c623a4cc17cbb24bdeec44e4e9467d2`.

## 2026-08-13: final Development package and two-process gate passed

Fresh evidence root:
`Saved/StaticJITPackage/staticjit-provider-development-predefault-final-Development/20260813_100413_445_817f3901`.
BuildCookRun, link-response inspection, archive/module-surface checks, and two
independent packaged-process starts passed. Both starts proved:

```text
profile=GameDevelopment providers=1 verified=18 exact=18 native=18 vm=0
references=12/12 matchResults=[0:18]
```

Both processes selected ProviderId
`a3ac00735be3d508aaa9d19ed244c9e0b93eaa2d6e55778b99453b291a186ce5`,
Provider generation
`09285201c8fd8b3817d2cc73ad6c292e1a6c821075631cf34ab616f81bc4bf5d`,
and the identical stable module/function route set. The run used different
fresh cache roots, so cache creation order and transient numeric FunctionIds
were not inputs to provider selection.

## 2026-08-13: package parity gates and legacy deletion completed

The package-style C++ matrices cover both GameDevelopment and GameShipping,
complete immutable artifact sets, partial/stale/missing Provider fallback,
ProviderId conflict/recovery, owner unload/reload, delayed code-lifetime
retirement, multiple Providers, and multiple AS modules. The independent
Development and Shipping archives above prove the project `AngelscriptJIT`
carrier is linked and loaded while Editor/Test carriers and their source/build
dependencies are absent. Both configurations complete two clean process starts
with stable Provider/route results.

Only after those gates passed, the superseded activation path was deleted:

- `FJITDatabase` and FunctionId-indexed generated registration;
- `FStaticJITCompiledInfo::ActiveInfo` and the single global active catalog;
- whole-cache `DataGuid` pairing/clearing and Engine activation branches;
- `FJitRef_*` / `FJitVerify*` global-reference emit and runtime helpers;
- legacy diagnostic generator modes and marker flags;
- `AngelscriptCacheLegacyCutover.*` and its compatibility inspection/tests;
- `AngelscriptPrecompiledDataArchiveTests.cpp` and legacy test cache helpers;
- committed `StaticJITAotFixture.Cache`, `.jit.hpp`, aggregate
  `AngelscriptJitCode_*.jit.cpp`, and `AngelscriptJitInfo.jit.cpp` artifacts;
- old state-dump `JITDatabase` and `PrecompiledData` CSV views.

No compatibility reader, migration command, fallback activation flag, or
dual-write path was added. `FAngelscriptPrecompiledData` remains only as a
generation-time analysis/reference collector; it is not an Engine-owned
load/save/activation database.

Post-deletion source scans report:

```text
NO_LEGACY_RUNTIME_MATCHES
NO_LEGACY_GENERATED_FILES
```

The focused Editor build passed at
`Saved/Build/static-jit-legacy-cutover-r2/20260813_110315_768_ae698f6b`.
Provider generation, diagnostics, and state dumps then passed together 13/13
at `Saved/Tests/static-jit-diagnostics-generated-r8/20260813_112319_274_8fd18d01/Report`.
The final broad StaticJIT/Cache/package/All-suite gates remain task 11.6; they
do not reopen the deleted legacy design.
