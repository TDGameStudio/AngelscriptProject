# Canonical mutable integer global initializer lifecycle — 2026-08-23

Worktree: `D:\as-cta`  
Change: `refactor-as-canonical-typed-ast-compiler`

## Scope

This is a bounded production-CodeGen vertical slice for a Sema-proven static
integer initializer on a mutable module global:

```angelscript
int G = 1;
```

It does **not** claim dynamic initializers, floating-point/string/object global
initialization, dependency ordering, Cache DTO fidelity, or full production
CodeGen closure.

## Why a direct Generate-time store was incorrect

`asCModule::Build()` calls `ResetGlobalVars(0)` when global initialization is
enabled. `ResetGlobalVars()` calls `CallInit()`, which clears mutable global
storage before executing each property's attached initialization function.
Writing `1` directly during `Generate()` therefore makes a mutable global read
as zero after Build. The maintained builder instead gives each initialized
property an `asCScriptFunction` init function.

Canonical CodeGen now follows that lifecycle protocol for the bounded integer
constant case. `const` primitive globals remain direct pure-constant storage;
non-const integer globals use a property-owned init function and remain
non-pure-constant.

## Root-cause trace for the first initializer-function crash

The first hand-emitted init function built and linked, but the focused test
crashed while `asCModule::CallInit()` prepared that function:

```text
asCContext::PrepareScriptFunction()  as_context.cpp:1740
asCContext::Execute()
asCModule::CallInit()
asCModule::Build()
```

The failing log is
`Saved/Tests/cta-mutable-global-init/20260823_120435_565_cc3cf8ec/Automation.log`.

`PrepareScriptFunction()` uses `scriptData->objVariablesOnHeap` as the count
for `objVariablePos[]`. The experimental scalar initializer called
`ExtractObjectVariableInfo()` but never initialized that count. The uninitialized
count caused a walk over arbitrary stack offsets. Both the maintained
`asCCompiler::FinalizeFunction()` and `asCCanonicalFunctionEmitter::Emit()`
establish this runtime value; the bounded helper did not.

The minimal repair explicitly sets `objVariablesOnHeap = 0`, which is correct
for this scalar-only initializer. No padding, direct storage workaround, or
relaxation of `ResetGlobalVars()` was used.

## Regression contract

`CanonicalMutableIntegerGlobalInitializesStoresAndPublishesCodeGen` executes
the actual VM/module lifecycle:

1. Build `int G = 1` with the CANONICAL pipeline and require publisher
   `CANONICAL_CODEGEN`.
2. Read `G` and require `1`.
3. Store `42` through a separately emitted script function and read `42` from
   another script function.
4. Call the public `Module->ResetGlobalVars(nullptr)` path.
5. Read the same global again and require `1`.

This would fail if the property initializer were missing, if mutable storage
were incorrectly marked pure constant, or if reset did not execute the
Canonical initializer.

## Fresh verification

| Command | Result | Evidence |
| --- | --- | --- |
| `Tools\\RunBuild.ps1 -Label cta-mutable-global-heap-count-build -NoXGE` | passed | `Saved/Build/cta-mutable-global-heap-count-build/20260823_120942_574_4fd5940f/RunMetadata.json` |
| focused test before reset assertion | passed `1/1` | `Saved/Tests/cta-mutable-global-heap-count/20260823_120954_814_11fdebfd/RunMetadata.json` |
| `Tools\\RunBuild.ps1 -Label cta-mutable-global-reset-build -NoXGE` | passed | `Saved/Build/cta-mutable-global-reset-build/20260823_121131_323_9f55b68f/RunMetadata.json` |
| focused lifecycle test | passed `1/1` | `Saved/Tests/cta-mutable-global-reset/20260823_121148_209_297d17b5/RunMetadata.json` |
| `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label cta-mutable-global-production-regression` | passed `58/58` | `Saved/Tests/cta-mutable-global-production-regression/20260823_121325_216_0f16839a/RunMetadata.json` |

## Follow-up: exact unsigned 64-bit storage — 2026-08-23

The original `int G = 1` vertical slice did not prove that the same lifecycle
obeyed AngelScript's complete scalar-width contract. The follow-up production
case is deliberately the unsigned boundary value:

```angelscript
uint64 G = 18446744073709551615;
uint64 Read() { return G; }
```

It reads the initial value, overwrites the exported global storage with `7`
from the embedding side, proves the reader observes that mutation, calls the
public `ResetGlobalVars(nullptr)` lifecycle, and requires the exact uint64
maximum again. The test also requires the reader bytecode to contain `RDR8`
and forbids the four-byte `CpyGtoV4` shortcut.

### Root-cause trace

The red-test sequence exposed three independent protocol defects rather than
one literal-parser issue:

1. The global-init gate used `IsIntegerType()` only. AngelScript classifies
   `uint` and `uint64` through `IsUnsignedType()`, so valid unsigned globals
   initially failed closed with `asNOT_SUPPORTED (-7)`.
2. The hand-emitted 8-byte initializer wrote its scalar at frame offset `1`.
   Canonical `AllocDwords(2)` reserves slots `1/2` and returns the high slot
   `2` for `SetV8`/`WRTV8`; offset `1` crosses the reserved frame boundary.
   The first symptom was a zero read and, after partial repair, garbage high
   bits.
3. `LoadGlobal()` always emitted `CpyGtoV4`, which copies only one dword. It
   therefore left the high half of every 8-byte global uninitialized. The
   correct common lowering is `LDG` followed by the existing typed
   `EmitReadValue()` (`RDR1`, `RDR2`, `RDR4`, or `RDR8`).

The Sema ingress also used Windows-width `strtoul` and `%u` formatting for
canonical integer facts. It now uses `strtoull` and a 64-bit format; the
global declaration's stored default-argument text preserves unsigned decimal
spelling while CodeGen continues to consume only the Sema-owned
`constantValue`, never reparsing presentation text.

The failed intermediate evidence is retained in:

- `Saved/Tests/cta-u64-global-red-group/20260823_121954_117_dfa26d3b/RunMetadata.json`
  — unsigned type class was rejected.
- `Saved/Tests/cta-u64-global-diagnostics/20260823_122746_083_f1e13bbb/RunMetadata.json`
  — initial read was zero before the eight-byte frame-slot repair.
- `Saved/Tests/cta-u64-global-stack/20260823_122943_401_0e48329d/RunMetadata.json`
  — partial read with uninitialized high dword before the typed global-load repair.

### Fresh verification for the follow-up

| Command | Result | Evidence |
| --- | --- | --- |
| `Tools\\RunBuild.ps1 -Label cta-u64-global-max-build` | passed | `Saved/Build/cta-u64-global-max-build/20260823_123327_022_3ae8c28c/RunMetadata.json` |
| exact uint64 initializer/reset regression | passed `1/1` | `Saved/Tests/cta-u64-global-max/20260823_123345_535_9522f914/RunMetadata.json` |
| `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label cta-u64-global-production-regression` | passed `59/59` | `Saved/Tests/cta-u64-global-production-regression/20260823_123423_259_02c4877c/RunMetadata.json` |

This increases the bounded mutable-global slice from signed 32-bit coverage to
all integer storage widths accepted by the helper's 1/2/4/8-byte protocol. It
does not claim overflow diagnostics, full signed/unsigned constant-expression
semantics, float/string/object initializers, initializer dependency order, or
general detached CodeGen publication.

## Non-claims

- This does not close tasks 5.4, 5.7, 5.8, 9.1, 9.5, 10.4, 13.2, or 13.6.
- The initialized value is restricted to the existing Sema-owned
  `hasConstantValue` / `constantValue` integer fact. CodeGen does not parse
  `defaultArg` text.
- General initializer ordering and reference/object cleanup need canonical
  expression/lifetime lowering before their own lifecycle routes can be
  claimed.
