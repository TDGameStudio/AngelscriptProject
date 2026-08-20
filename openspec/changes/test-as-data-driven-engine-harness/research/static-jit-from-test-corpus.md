# Test AS corpus vs derived StaticJIT C++

Two libraries, not one mixed tree.

## Layer 1 — test AngelScript corpus (source of truth)

| Kind | Where | Checked in? |
|---|---|---|
| Authored scenarios | `AngelscriptTest/Fixtures/**/*.as` | Yes |
| Generated products | C++ tables → AS text at enumerate/run | No (memory; dump on failure) |

This is the **test codebase**. Coverage slices that become generators still emit AngelScript into this layer. Host `Script/` teaching corpus is a different tree.

## Layer 2 — derived StaticJIT C++ (generated code)

StaticJIT packager already emits **one** `<StableModuleKey>.<TargetProfile>.jit.cpp` per non-empty AS module (`as-static-jit-backend`). That C++ is **derived from Layer 1**. It is not a second handwritten corpus of the same functions.

| Consumer | What it proves | v1 |
|---|---|---|
| `typed-ast-generate` profile | Isolated `EAngelscriptEnginePurpose::StaticJITGeneration` can emit/fallback for this module | Yes (skip if `AS_CAN_GENERATE_JIT` false) |
| later `bytecode-generate` | Same pairing, bytecode backend | Additive profile; not Wave A |
| `AngelscriptTestJIT` carrier | Mechanical Provider C++ compiled into the Editor-only test module | Later publish; not required for skip-path leaves |

This pairing **is** StaticJIT generate testing. A corpus module with `vm` and `typed-ast-generate` leaves covers interpreter execute and StaticJIT generation on the same AS. Growing Fixtures or product tables, then listing the generate profile, grows that coverage. It does not replace `Angelscript.TestModule.StaticJIT.*` packager / Provider / coordinator / diagnostics CQTest. Provider-load native execute waits for mechanical `AngelscriptTestJIT` publish.

## Both source kinds get StaticJIT

Handwritten `OptionalEmpty.as` and generated `integral-bitwise` / later Coverage expression products are the same input kind to Layer 2: an AS module with a stable identity.

Rules:

1. Do **not** hand-write a `.jit.cpp` that copies `EchoEmpty` or `EvaluateBitAnd`.
2. Do **not** cartesian every fixture × `typed-ast` × `bytecode`. Catalogs list generate profiles explicitly.
3. Memory-mount VM leaves stay memory. Generate profiles **must** materialize source onto an isolated disk script root (same trick as ScriptCorpus) so virtual paths are `/Angelscript/Game/<logical>` and StableModuleKey is well-defined.
4. Production Editor rule is unchanged: a normal `.as` save does not generate C++. Test generate uses explicit generation purpose, not save hooks.
5. `"dual"` remains forbidden. Per-function typed-ast → bytecode → VM fallback stays the backend contract.
6. Generation Engine still must not materialize script reflection (`as-static-jit-backend`). Wave A golden is a global-function fixture (`OptionalEmpty`), not a World/Actor execute.
7. Session `.jit.cpp` under `Saved/Automation/` is not the source of truth and is not committed in Wave A. Optional later Generate/Verify may refresh `AngelscriptTestJIT` from this corpus; that output stays mechanical.

## Why not a third corpus

A checked-in `StaticJIT/Fixtures/*.jit.cpp` tree that shadows `Fixtures/*.as` would rot the same way inline `ASTEST_AS` already does. Layer 2 exists only as generator output.

Runtime JIT is not Layer 2. It executes Layer 1 through coordinator `RuntimeOnly`. See `runtime-jit-from-test-corpus.md`.
