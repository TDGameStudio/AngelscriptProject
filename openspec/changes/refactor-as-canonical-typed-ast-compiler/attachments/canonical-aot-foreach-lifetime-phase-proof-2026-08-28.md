# Canonical AOT foreach lifetime-phase proof — 2026-08-28

## Outcome

CTA-S52 closes the first special loop-phase slice of OpenSpec Task 7.5. A
value-object `foreach` iterator authored by Canonical Sema is now recognized as
one exact loop lifetime phase by the direct Canonical-AST TypedASTJIT analyzer.
The analyzer independently proves the iterator cleanup protocol across normal
exit, `return`, `break`, and `continue`, then publishes pointer-free lifetime
facts. It does not consume a dump, HIR, bytecode, persisted numeric TypeId, or
an AST pointer retained by a Provider binding.

This is a structural eligibility proof. It does not add native object storage
or execute object destruction in the current scalar TypedASTJIT emitter.
Functions requiring object iterator cleanup therefore continue to fall back
per function to BytecodeJIT/VM until a native object-frame ABI exists.

## Producer/backend protocol that is now proven

Canonical Sema seals a value-object `foreach` as exactly four statement
children:

1. a synthetic initializer `Block` that declares and constructs the generated
   iterator;
2. the authored loop body;
3. the increment/`opForNext` phase;
4. one exact scope-exit cleanup action for the generated iterator.

The iterator lifetime belongs to the `Foreach` statement, not to the synthetic
initializer block. Canonical Bytecode CodeGen installs that fourth child as the
loop-frame cleanup route:

- normal exhaustion enters the common loop cleanup label;
- `break` targeting this `foreach` enters the same cleanup label;
- `continue` targeting this `foreach` jumps to the increment phase and keeps
  the iterator live;
- `return` or a transfer escaping an outer scope is covered by
  `EmitTransferCleanups` for active loop phases;
- the common cleanup retires the object so the action cannot run twice.

The AOT analyzer now derives the required iterator action from the generated
declaration and its exact type/destructor identity, requires the sealed fourth
phase to match it, and reasons about transfers using the exact target IDs. It
does not reinterpret the synthetic initializer as an ordinary lexical block
whose cleanup would run before the loop body.

## TDD trail

The real CANONICAL source fixture is
`FCanonicalASTJITAdapterTests.SourceObjectIteratorForeachPhaseProvesReturnBreakAndContinueCoverage`.
It defines a value-object iterator/range through `opForBegin`, `opForEnd`,
`opForNext`, and `opForValue`, then places `return`, `break`, and `continue` in
the loop plus a normal post-loop return.

The valid RED and GREEN sequence is:

| Gate | Result | Evidence |
| --- | --- | --- |
| registration build before RED | PASS | `Saved/Build/cta-s52-foreach-lifetime-phase-red-build/20260828_150600_437_29a7d785/RunMetadata.json` |
| focused structural proof before implementation | **0/1 RED**; only transfer coverage failed | `Saved/Tests/cta-s52-foreach-lifetime-phase-red/20260828_150622_054_6913bdec/RunMetadata.json` |
| first implementation build | PASS | `Saved/Build/cta-s52-foreach-lifetime-phase-green-build/20260828_150927_524_b47e26ee/RunMetadata.json` |
| first return/break GREEN | **1/1 PASS** | `Saved/Tests/cta-s52-foreach-lifetime-phase-green/20260828_150941_766_1114c395/RunMetadata.json` |
| final build after adding `continue` | PASS | `Saved/Build/cta-s52-foreach-lifetime-phase-continue-build/20260828_151205_451_09cb8f11/RunMetadata.json` |
| final return/break/continue/normal fixture | **1/1 PASS** | `Saved/Tests/cta-s52-foreach-lifetime-phase-continue/20260828_151227_676_7cb06339/RunMetadata.json` |

The focused RED is authoritative: the same real source compiled and produced
the expected `ScriptDestructor` classification, but the previous analyzer
rejected the legal fourth phase and left
`bCleanupPlanCoversAllTransfers=false`.

## Regression evidence

| Scope | Result | Evidence |
| --- | --- | --- |
| Canonical TypedASTJIT adapter class | **15/15 PASS** | `Saved/Tests/cta-s52-canonical-jit-adapter-regression/20260828_151304_556_b4ff03ea/RunMetadata.json` |
| production Canonical Bytecode object-iterator execution | **1/1 PASS** | `Saved/Tests/cta-s52-canonical-object-foreach-codegen/20260828_151410_286_d9c54bab/RunMetadata.json` |
| complete Canonical SemaAuthority class | **392/392 PASS** | `Saved/Tests/cta-s52-sema-authority-regression/20260828_151445_829_638cad98/RunMetadata.json` |
| complete TypedASTJIT prefix | **44/44 PASS** | `Saved/Tests/cta-s52-typedastjit-regression/20260828_151530_868_f7b89496/RunMetadata.json` |

The existing Sema verifier tests for forged foreach cleanup literal/target/type
remain green inside the 392-test authority run. The production execution test
also proves the sealed fourth phase still executes through Canonical Bytecode
with CANONICAL publisher provenance and no retained LEGACY compiler call.

Two pre-existing compiler warnings remain unrelated to CTA-S52: C4191 in the
frame-recursion test and C4701 for `DividePosition` in another adapter test.
HTTP connectivity warnings emitted by unrelated Provider tests did not fail
the 44-test TypedASTJIT run.

## Boundaries that remain deliberately open

Task 7.5 remains open for the following reasons:

- partial construction needs per-initializer failure-edge/live-set metadata;
  normal and transfer children alone cannot prove which objects were
  constructed when an initializer fails;
- compiler exception regions are not represented by the current pointer-free
  Canonical AST protocol; the retired HIR test injected test-only external
  compiler metadata, so the new analyzer must not invent a region from source
  shape;
- current `asBC_SUSPEND` safe points are polling boundaries, not a cooperative
  resumable state machine; `bHasSuspendState=false` remains the truthful fact;
- other future special loop phases require their own exact source/protocol
  fixtures rather than being generalized from `foreach` by kind alone;
- object-frame storage, construction-live bits, destructor/release calls and
  exceptional unwinding are not implemented by the scalar native emitter;
- mutable globals/import slots, call-site fallback and the remaining Provider
  dependency publication families are still incomplete.

Sema and Bytecode CodeGen author/consume the lifetime protocol while the AOT
analyzer independently derives and verifies it. That intentional duplication
prevents blind trust, but it is also a drift risk. Final closure should expose
a versioned, verifier-authenticated Canonical lifetime protocol revision while
retaining structural consumer checks.

## Progress accounting

No umbrella task row closes, so mechanical completion remains **88/125
(70.4%)**. Weighted whole-change completion remains **about 79%** because the
remaining blockers are still high-risk lifecycle and cutover work. Direct
Canonical-AST AOT advances from **about 61% to about 63%**. Action-only Sema
remains **about 99%**, Canonical Bytecode/Runtime **about 74%**, and safe
default readiness **about 50%**. LEGACY remains the default, the original
native `asCScriptNode` AST remains retained for Parser/recovery/reference, and
HIR remains physically deleted.
