# Scheme overview

Recorded from the 2026-08-18 design discussion. Product rules are in `../design.md`.

## Two axes

**Backend** (frozen at process start; change requires restart):

| Backend | HIR | Matching Editor Generate |
|---|---|---|
| `bytecode` (default) | off | Read primary bytecode. No generation Engine. |
| `typed-ast` | needed on the Engine that compiles that request | Read primary verified HIR. If capture is off, fail `CaptureRequired`. Do not spawn a generation Engine to obtain matching HIR. |

No production `"dual"` backend. One ineligible function falls back BytecodeJIT/VM.

**Target profile** (three independent `.jit.cpp` trees):

| Profile | Used by | vs a live Editor |
|---|---|---|
| `EditorDevelopment` | Editor / PIE | Matching |
| `GameDevelopment` | Development package | Non-matching |
| `GameShipping` | Shipping package | Non-matching |

Output stays `Source/AngelscriptJIT/Generated/<Profile>/`. TestJIT stays `Generated/EditorDevelopment`.

## Who compiles

```text
Generate request
  profile == this process's primary Engine
    → read that Engine; never Create StaticJITGeneration
  otherwise, or commandlet with no live Editor
    → one StaticJITGeneration Engine for that profile
    → compile, emit Generated/<Profile>/, destroy
    → at most one extra Engine alive
```

Editor and commandlet share the same generation-Engine helper. `.jit.cpp` content for a given profile+backend must not depend on which host asked. Commandlet is the pack-time entry (`Tools\RunAngelscriptJIT.ps1`).

`IsRunningCommandlet()` in script is an ordinary bound UE API. It is not the JIT commandlet and does not decide whether Generate runs.

## Optional HIR

Capture is frozen at `FAngelscriptEngine::Create()`. `"bytecode"` stays off. A `"typed-ast"` generation Engine captures for that request only. Primary capture is optional so matching TypedASTJIT Generate can read live HIR.

Dump (`UAngelscriptHIRDumpCommandlet`) is a separate request. `.hir.txt` / `.hir.json` are never compiler inputs.

## Cache V2

Optional `TypedHIRSidecar = 8` on FunctionBody, like DebugSidecar. Pointer-free, stable keys. ExactStartup remaps then re-verifies. Capture-on typed-ast misses bytecode-only caches. `"bytecode"` sessions ignore sidecars. `SaveByteCode` stays HIR-free.

## Pack / Cook

GameDevelopment / GameShipping trees must be Generated, then compiled into the Game target, then Cooked. Cook does not Generate. EditorDevelopment does not substitute for Shipping. Packaged runtime loads the already-built Provider DLL.
