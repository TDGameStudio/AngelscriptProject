# CANONICAL Parser/FMemStack lifetime gate

Date: 2026-08-27  
Worktree: `D:\as-cta`

## Gate card

- **Issue:** CTA-LIFE-01.
- **Source fixture:** one CANONICAL module source build with at least one
  `asCParser` retained in `asCBuilder::parsers` through Stage 2.
- **Required fact:** every Builder destruction path destroys all owned
  `asCParser` instances, thereby releasing each Parser-owned `FMemStackBase`
  and its complete native `asCScriptNode` tree. LEGACY and CANONICAL must use
  one idempotent owner-level release routine.
- **Expected RED:** the architecture gate reports that Builder has no shared
  Parser release routine, the destructor does not release Parser ownership,
  and LEGACY alone carries the inline cleanup.
- **Owning gate:** `AngelscriptStandalone.Architecture`, followed by Runtime/
  Editor build and explicit CANONICAL cutover/repeated-generation regression.
- **Non-goal:** this does not delete the native syntax tree and does not close
  Parser-node semantic replay. It corrects only transient build ownership.

## Static diagnosis

`BuildParallelParseScripts()` allocates one `asCParser` per source section with
`asNEW(asCParser)` and stores raw owning pointers in
`asCBuilder::parsers`. Every Parser owns an `FMemStackBase`; all native
`asCScriptNode` instances for that section are allocated from that stack.

Before this gate, the only deletion loop lived at the end of
`asCBuilder::BuildCompileCode()`. That works for the LEGACY route because it
always reaches that function after successful staging. CANONICAL Stage 3
instead calls `SealCanonicalAST()` and
`asCBytecodeCodeGen::GeneratePreparedModule()`, then destroys Builder without
calling `BuildCompileCode()`.

`asCBuilder::~asCBuilder()` did not delete `parsers`, and
`asCArray<asCParser*>` only destroys pointer slots. Consequently each
successful CANONICAL source build leaked the Parser allocation and the Parser
FMemStack pages holding the native syntax tree. Repeated generation/hot reload
scales the leak with source sections and parsed node volume.

## TDD RED

The permanent Standalone architecture assertion was added before the source
repair. It requires all three ownership facts in the maintained fork:

1. `asCBuilder` declares one shared `ReleaseParsers()` routine;
2. that routine deletes every owned Parser and clears the pointer array;
3. both the Builder destructor and LEGACY `BuildCompileCode()` call the same
   idempotent routine.

Command:

```powershell
cmake --build Plugins\Angelscript\Standalone\out\build\win64-msvc --config Debug --target AngelscriptStandaloneArchitectureTests
ctest --test-dir Plugins\Angelscript\Standalone\out\build\win64-msvc -C Debug -R "^AngelscriptStandalone\.Architecture$" --output-on-failure
```

Result: **0/1 PASS**. The three failures were precisely the missing shared
routine, missing CANONICAL destruction backstop, and LEGACY's inline-only
cleanup. No unrelated architecture assertion failed.

## Repair

`asCBuilder` now owns an idempotent `ReleaseParsers()` implementation:

```text
for every owned parser:
    asDELETE(parser, asCParser)
parsers.SetLength(0)
```

The destructor calls it before destroying Canonical Sema/AST ownership, so
successful CANONICAL Stage 3, failed/aborted builds, and early Builder
destruction release every Parser-owned syntax arena. LEGACY
`BuildCompileCode()` calls the same routine as its earlier eager-release point;
the later destructor call is safe because the array is empty.

Files:

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp`
- `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp`

## GREEN evidence

### Standalone ownership and maintained-fork regressions

The focused architecture gate passed **1/1**. The complete maintained-fork
Debug build then succeeded, followed by complete Debug CTest **20/20 PASS** in
49.53 seconds. These runs prove the owner-level shape and both host-neutral
compiler selections after the source change.

### UE Runtime/Editor build

Command:

```powershell
Tools\RunBuild.ps1 -Label cta-parser-lifetime-green-build -TimeoutMs 1800000 -NoXGE
```

Result: **PASS**, 186/186 actions, exit 0. Evidence:
`Saved/Build/cta-parser-lifetime-green-build/20260827_211820_226_d38fc24c/RunMetadata.json`.

A later test-contract-only source edit was synchronized with a second
incremental UE build: **PASS**, 4/4 actions, exit 0. Evidence:
`Saved/Build/cta-transitional-cutover-test-sync/20260827_212608_472_cd1cb8ea/RunMetadata.json`.

### Explicit CANONICAL lifecycle and repeated generation

Commands:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT.GenerationVerification.FAngelscriptStaticJITAotGenerationVerificationTests.RepeatedTypedGenerationIsByteDeterministicAndCurrent" -Label cta-parser-lifetime-green-repeat-generation -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label cta-parser-lifetime-green-cutover-final -TimeoutMs 900000
```

Results:

- repeated real Engine/CANONICAL compilation and TypedAST generation:
  **1/1 PASS**, exit 0, 236.672 seconds;
- complete Cutover group: **12/12 PASS**, exit 0.

Evidence:

- `Saved/Tests/cta-parser-lifetime-green-repeat-generation/20260827_212202_430_097fe78e/RunMetadata.json`
- `Saved/Tests/cta-parser-lifetime-green-cutover-final/20260827_212626_867_9428d09d/RunMetadata.json`

The first Cutover run after the lifetime repair was **11/12** because one
pre-existing test still asserted the future final state (new Engine defaults
to CANONICAL) while production intentionally remains at the transitional
LEGACY default. That contract mismatch was repaired independently and is
recorded as CTA-GATE-01; it was not a lifetime or CANONICAL execution failure.

## Closure and non-claims

CTA-LIFE-01 is **resolved**. Parser/native-tree ownership now ends with Builder
on every backend route, while a retained Canonical snapshot has independent
ASTContext ownership.

This does **not** close CTA-SEMA-01 or Task 10.6. The Parser may be released at
the correct time and CANONICAL Sema may still have obtained semantic facts by
replaying its `asCScriptNode` tree earlier in the same build. Removing that
semantic dependency remains separate AST-first work.
