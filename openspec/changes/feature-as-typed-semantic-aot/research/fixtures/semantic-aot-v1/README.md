# Semantic AOT v1 research fixtures

This directory freezes a small, synthetic typed-HIR contract before the real
compiler-owned model and Semantic C++ emitter are implemented. It is a research
oracle, not a Runtime input format.

The corpus deliberately separates three outcomes:

- `Semantic`: structurally valid HIR with a deterministic C++ golden;
- `Fallback`: structurally valid HIR that contains an explicitly unsupported
  semantic form and must not publish C++;
- `NotEvaluated`: structurally invalid HIR whose verifier failure is the
  expected result.

Schema v3 includes a normalized function header, the expanded research call
contract, and explicit verified control-transfer targets. Every case records raw trait bits,
invocation kind, effective receiver, compile-out kind, hidden/determines-output
argument indexes, return-on-stack and cleanup state. The
`external-implicit-this` case proves that declared parameter zero remains in the
global signature and is also the receiver alias; it deliberately falls back
because the v1 scalar emitter does not support object/property writes. The
`invalid-effective-receiver` case proves a dangling receiver symbol fails
verification before eligibility or emission.

Resolved calls separate formal argument bindings from the authoritative
evaluation sequence. `call-reverse-evaluation` freezes the maintained fork's
three-argument behavior: effectful inputs are materialized in formal order
`2,1,0`, exception state is checked after every step, and the target receives
temporaries in formal ABI order `0,1,2`. `invalid-call-evaluation-sequence`
duplicates formal `2` and omits formal `1`; it must fail with
`InvalidCallEvaluationSequence`.

`Break` and `Continue` statements record `targetStatement` instead of the
under-specified word `nearest`. The verifier reconstructs lexical parentage and
requires the target to be the nearest legal enclosing construct: loops for
`continue`, and loops or `switch` for `break`. The `loop-switch` case freezes the
important nested shape: its `continue` targets the enclosing `For`, while its
`break` targets the inner `Switch`. A mutation that redirects the continue to
the switch must fail with `InvalidControlTarget`.

The JSON schema is local to this OpenSpec change. It must never be loaded by
`AngelscriptRuntime`, serialized into `PrecompiledScript.Cache`, exposed through
`angelscript.h`, or treated as a compatibility promise. The maintained C++ HIR
may use different in-memory representation details as long as it preserves the
recorded semantics and normalized dump.

The corpus currently contains ten cases: five Semantic scalar/control-flow/call
goldens, two structurally valid typed fallbacks, and three expected verifier
failures. Validator smoke tests additionally mutate a supported expression ID,
an external receiver type, a call evaluation sequence, a continue target, text
line endings, and generated C++ forbidden tokens.

Run the corpus validation with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File openspec/changes/feature-as-typed-semantic-aot/research/fixtures/semantic-aot-v1/Validate-Fixtures.ps1
```

Run the validator's positive and negative smoke tests with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File openspec/changes/feature-as-typed-semantic-aot/research/fixtures/semantic-aot-v1/Test-ValidateFixtures.ps1
```

Both scripts are network-free and use only Windows PowerShell built-ins. The
validator checks canonical UTF-8/LF text hashes, indexed references, statement
ownership, source spans, formal-call/evaluation consistency, canonical dumps,
explicit nearest-legal control targets, expected invalid/fallback outcomes, and
forbidden bytecode/provider tokens in Semantic C++ goldens. It does not parse
AngelScript, infer types, or generate C++.
