# Runtime JIT from the same test corpus

StaticJIT generate and Runtime JIT are different contracts. The **same Layer 1 AngelScript corpus** is the input for both. This change **prepares** Runtime JIT coverage; it does not require Angelsea/LLVM in default CI and does not cartesian every fixture against every BackendId.

## Two JIT families, one AS pile

| | StaticJIT (`typed-ast-generate`) | Runtime JIT (`runtime-jit`) |
|---|---|---|
| Engine purpose | `StaticJITGeneration` | Ordinary Full test engine, coordinator `RuntimeOnly` |
| Contract | `as-static-jit-backend` — emit `.jit.cpp`, no `asIJITCompiler` | `as-runtime-jit-backend` — factory + Engine-local session + bytecode snapshot |
| Oracle in Wave A | Generate completed or typed fallback reason | Same `executeInt` / `executeBool` as `vm`, or Info-skip if no factory |
| Disk identity | Required (temp `Script/` / isolated project dir) | Not required; memory mount is enough |
| CI without plugin | Skip if `AS_CAN_GENERATE_JIT` false | Skip if no compatible `IAngelscriptRuntimeJITBackendFactory` |
| Input | Layer 1 AS corpus | **Same** Layer 1 AS corpus |
| Not the input | Handwritten `.jit.cpp` | StaticJIT `.jit.cpp` / Provider DLL |

`as-static-jit-backend` already forbids sharing a backend interface with Runtime JIT. Corpus tests must not treat a generate leaf as a Runtime JIT leaf.

Angelsea (`Reference/angelsea`) remains an offline research clone, not a Runtime or CI dependency (`AGENTS.md`).

## What “prepare” means in Wave A

1. Register profile id `runtime-jit` (isolated, skip-if-no-factory). JSON stores the id, not a BackendId blob or `FAngelscriptEngineConfig`.
2. Ship one authored golden: `syntax.optional-empty` + `runtime-jit`, same `EchoEmpty` oracles as `vm`.
3. Enumeration always contains that leaf. Missing factory → Info skip naming BackendId/capability. Present factory → `executeInt` must match VM.
4. Do **not** auto-add `runtime-jit` to every fixture or product cell.
5. Generated products and Coverage slices stay eligible: later explicit cases (one cell first), same skip/execute rules.

That is the slot later Runtime backends walk into. Adding a fixture does not require a third AS copy under a Runtime JIT test folder.

## Later, when a factory exists

- Keep using `executeInt` / `executeBool` / `executeException`; do not invent a second oracle language.
- Additive profile ids (for example a pinned BackendId) are allowed; v1 uses one `runtime-jit` that reads the configured BackendId (open: ini vs harness default).
- Unsupported functions return typed `Unsupported` and must not be reported as VM success pretending to be JIT; if the coordinator falls back to VM, the leaf MUST say so (Info) rather than silently counting as Runtime JIT proof. Wave A may only assert execute result + skip-or-run; fallback-reason tightness can wait until a factory is in CI.
- Factory ABI, snapshot isolation, and session teardown stay `Angelscript.TestModule` Runtime JIT CQTest, not corpus leaves.

## Why not wait

Without a registered skip-or-run profile and a golden catalog case, later Runtime JIT work will copy AS into new CQTest methods again — the original pain. Preparing the slot now is the point of the corpus.
