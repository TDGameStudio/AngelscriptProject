# AngelscriptTestJIT module and package boundary — 2026-08-12

## Completed ownership slice

OpenSpec task 6.1 is complete:

- `AngelscriptTestJIT` is declared before `AngelscriptTest` as
  `Editor/PostDefault` in `Angelscript.uplugin`.
- The dependency direction is `AngelscriptRuntime <- AngelscriptTestJIT <-
  AngelscriptTest`; Runtime has no reverse reference.
- The carrier contains a fixed modular-feature shell, no CQTest/Automation
  registration, no project Script/settings/Scaffold/descriptor path, and
  disables ordinary dynamic reloading.
- Its public fixed ProviderId is
  `7dc70fd55a76cc55d726e32d5c2434713bd93755a32e4dd524a4b7c39c8b5d44`.
- The current generated selector intentionally returns null until task 6.2/6.3
  installs the committed per-AS-module generated provider.

TDD and build evidence:

- RED ownership tests, 0/2 as expected because the module did not exist:
  `Saved/Tests/staticjit-testjit-module-red-tests/20260812_205813_786_320b4631/Report`;
- first directed TestJIT build:
  `Saved/Build/staticjit-testjit-module-green/20260812_205957_417_445a2f64`;
- required full Editor target build after adding a new UE module:
  `Saved/Build/staticjit-testjit-module-full-target-green/20260812_210241_454_7178e471`;
- ownership shell tests, 2/2:
  `Saved/Tests/staticjit-testjit-module-green-tests2/20260812_210302_484_f162293c/Report`;
- RED fixed-ProviderId compile:
  `Saved/Build/staticjit-testjit-providerid-red/20260812_210409_892_c833c6ba`;
- final Editor build and ownership/identity tests, 3/3:
  `Saved/Build/staticjit-testjit-providerid-green/20260812_210439_075_0439c561`,
  `Saved/Tests/staticjit-testjit-providerid-green-tests/20260812_210500_603_925ef90d/Report`.

## Development Game exclusion and discovered legacy cache

The required package smoke reached successful Development Game compile, Cook,
Stage, and Archive at:

`Saved/CachePackage/staticjit-testjit-game-exclusion-Development/20260812_210602_701_8ec82d49`

The Game build executed 61 actions and none compiled `AngelscriptTestJIT` or
`AngelscriptTest`. `Binaries/Win64/AngelscriptProject.target` contains neither
module, and the final Archive contains no matching DLL/PDB/file. This proves
the new Editor-only carrier is excluded from the non-Editor target.

The smoke runner nevertheless returned failure after the successful archive
because the workspace's ignored legacy
`Script/PrecompiledScript.Cache` (16,919 bytes) was copied into the archive.
The Cache V2 layout validator correctly rejects that artifact. It has not been
deleted during task 6.1 because task 6.4/10.4 owns replacement/removal of the
legacy local cache. Until that migration lands, the package smoke cannot reach
its later process-start matrix even though the TestJIT target-exclusion proof
itself is clean.
