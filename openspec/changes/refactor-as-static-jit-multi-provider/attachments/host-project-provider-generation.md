# Host project Provider generation — 2026-08-13

## Scope

This attachment records the real `AngelscriptProject` adoption of the fixed
`Source/AngelscriptJIT` carrier. It complements isolated scaffold tests with
actual UBT discovery, three target-profile generations, non-unity builds,
Shipping linkage, commandlet shutdown, repeated-generation idempotence, and
coexistence with the committed `AngelscriptTestJIT` Provider.

## Host module and build runner

The scaffold added one `Runtime` / `PostDefault` module descriptor and owns:

```text
Source/AngelscriptJIT/
├── AngelscriptJIT.Build.cs
└── Private/
    ├── AngelscriptJITModule.cpp
    └── Generated/
        ├── Provider.generated.h
        ├── Provider.generated.cpp
        └── Profiles/<TargetProfile>/...
```

The module privately depends on `Core` and `AngelscriptRuntime`, uses non-unity
compilation, and enables Editor generated bodies only with its private
`AS_ENABLE_EDITOR_JITTED_CODE=1` definition. Its fixed feature object records
whether it registered and unregisters exactly itself during shutdown.

`Tools/RunBuild.ps1` now accepts optional `-Target` and `-Configuration`
without changing its default Editor/Development behavior. Positional binding
is disabled so arguments after `--`, such as `-Module=AngelscriptRuntime`, are
forwarded to UBT instead of being mistaken for the target. The parser and
metadata behavior is covered by `Tools/Diagnostics/tests/RunBuildSelfTests.ps1`
and documented Chinese-first in `Documents/Guides/Build.md`.

First discovery evidence:

- isolated project service matrix, 10/10:
  `Saved/Tests/staticjit-host-project-isolated-preflight/20260813_050718_006_b1892a99/Report`;
- first Editor build:
  `Saved/Build/staticjit-host-project-first-editor-build/20260813_050910_319_beded275`;
- first Game build:
  `Saved/Build/staticjit-host-project-first-game-build/20260813_051100_766_f30e8d6e`.

## UBT physical basename discovery

The initial real Generate produced the intended logical topology but used the
same `<StableModuleKey>.jit.cpp` basename beneath all three profile folders.
UE 5.8 UBT rejected the target before compilation because its non-unity
intermediate object naming flattens source directories. Thus profile
directories do not disambiguate equal source basenames.

- generated 9/19 EditorDevelopment, 8/18 GameDevelopment, and 8/18
  GameShipping module/function sets:
  `Saved/AngelscriptJITRuns/staticjit-host-generate-all/20260813_051447_056_ffc3c557`;
- duplicate-basename RED:
  `Saved/Build/staticjit-host-generated-editor-build/20260813_051654_424_c2d8bed2`.

Physical source names now use:

```text
Modules/<StableModuleKey>.<TargetProfile>.jit.cpp
```

This is still strictly one implementation translation unit per non-empty AS
module in each profile. No function slice, bucket, or cross-module source was
introduced. It merely ensures that all UBT-visible physical basenames are
unique. Migration left 25 `.jit.cpp` files across the three profiles, zero
duplicate basenames, and zero old unqualified module-source names.

- profile basename contract, 3/3:
  `Saved/Tests/staticjit-profile-basename-green/20260813_052213_410_e0d9b2b4/Report`;
- migration Generate:
  `Saved/AngelscriptJITRuns/staticjit-host-generate-profile-qualified/20260813_052304_383_b344f8b8`;
- Editor and Game builds:
  `Saved/Build/staticjit-host-generated-editor-build-green/20260813_052451_845_ca6cefd3` and
  `Saved/Build/staticjit-host-generated-game-build/20260813_052507_949_e1773bf9`.

## Exact target guards and selector invalidation

The next Shipping link failed with 54 unresolved generated entry symbols.
Provider generation had reused a static header compiled into the Development
Editor commandlet, nesting `UE_BUILD_DEVELOPMENT` inside the intended Shipping
guard. Shipping therefore compiled declarations/manifest references without
the matching entry definitions.

Provider output now uses a provider-only header/footer and exact guards:

```cpp
#if WITH_EDITOR && UE_BUILD_DEVELOPMENT
#if !WITH_EDITOR && UE_BUILD_DEVELOPMENT
#if !WITH_EDITOR && UE_BUILD_SHIPPING
```

The stable root selector uses the same exact conditions. A second real issue
was UBT dependency invalidation for `__has_include`: compiling the null
selector before a profile include exists creates no positive include
dependency, so adding the file later need not recompile the selector. Generate
now touches the stable selector only after every requested profile succeeds
and only when the generated module-source set changes. Verify is read-only and
never touches it.

- Shipping RED:
  `Saved/Build/staticjit-host-generated-shipping-build/20260813_052538_303_a4684639`;
- profile, scaffold, and selector matrices, 6/6 each:
  `Saved/Tests/staticjit-profile-guards-green/20260813_053542_906_e2b6eadb/Report`,
  `Saved/Tests/staticjit-scaffold-guards-green/20260813_053637_921_132fce08/Report`, and
  `Saved/Tests/staticjit-selector-touch-green/20260813_053722_573_90e216e1/Report`;
- real fixed-profile Generate:
  `Saved/AngelscriptJITRuns/staticjit-host-generate-profile-guards/20260813_053906_384_5499a847`;
- actual Editor, GameDevelopment, and GameShipping Provider builds:
  `Saved/Build/staticjit-host-profile-guards-editor-build/20260813_054054_057_0a0470a7`,
  `Saved/Build/staticjit-host-profile-guards-game-build/20260813_054111_876_c7c41419`, and
  `Saved/Build/staticjit-host-profile-guards-shipping-build/20260813_054143_662_b0ce91d9`.

## DLL shutdown and balanced ownership

The first Verify All found zero profile differences and returned commandlet
result zero, then crashed during `FModuleManager::UnloadModulesAtShutdown()`.
The exact Windows loader-reference root cause and fix are recorded in
`provider-dll-lifetime-and-retirement.md`.

- RED:
  `Saved/AngelscriptJITRuns/staticjit-host-verify-all-final/20260813_054224_251_fc61f6d2`;
- Runtime build using balanced address-based acquisition:
  `Saved/Build/staticjit-dll-retain-refcount-fix-build/20260813_054920_621_1a42b717`;
- GREEN Verify All, three profiles current, every `DifferenceCount=0`, full
  module shutdown, final process exit zero:
  `Saved/AngelscriptJITRuns/staticjit-host-dll-lifetime-green/20260813_054956_174_87828f5d`;
- scaffold/Registry/real TestJIT unload-reload and coexistence, 19/19:
  `Saved/Tests/staticjit-dll-lifecycle-regression/20260813_055350_403_b7963ae4/Report`.

## Repeated Generate and TestJIT alignment

A before/after snapshot covered every file under the real generated root:
relative path, SHA-256, byte length, and `LastWriteTimeUtc` ticks. Repeated
Generate All reported all profiles current and `RequiresFullBuild=false`.
All 39 files were identical; added, removed, content-changed, and
timestamp-changed counts were all zero.

- `Saved/AngelscriptJITRuns/staticjit-host-repeat-generate-idempotency/20260813_055605_192_c4dbf3c8`.

TestJIT was then regenerated through the canonical product runner. It now owns
exactly two EditorDevelopment module sources with the same profile-qualified
basename rule and 46 functions total.

- baseline build:
  `Saved/Build/staticjit-testjit-profile-qualified-final_01_baseline_build/20260813_055824_769_8fb31421`;
- Generate:
  `Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit-profile-qualified-final_02_generate/20260813_055831_742_7b5bd1bb`;
- generated-source build:
  `Saved/Build/staticjit-testjit-profile-qualified-final_03_generated_build/20260813_055956_509_10ce8d1e`;
- read-only Verify:
  `Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit-profile-qualified-final_04_verify/20260813_060005_094_4e4baed1`;
- complete StaticJIT run: 119/121, only two stale test guard strings failed:
  `Saved/Tests/staticjit-testjit-profile-qualified-final_05_tests/20260813_060152_788_afaa2c5e/Report`;
- corrected exact-guard generation prefixes: 8/8:
  `Saved/Tests/staticjit-generation-exact-guard-green/20260813_061203_788_73750144/Report`.

This closes host scaffolding/generation group 7. It does not claim that
Editor/PIE edit classification, Live Coding patch refresh, package/multi-start,
or final configured-suite work is complete.
