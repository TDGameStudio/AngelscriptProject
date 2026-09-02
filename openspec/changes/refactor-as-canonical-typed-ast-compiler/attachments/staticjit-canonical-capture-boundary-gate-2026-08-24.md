# StaticJIT canonical capture boundary gate — 2026-08-24

## Outcome

TypedAST StaticJIT generation now selects and retains a verified canonical AST
snapshot without enabling the fork's transitional typed-semantic-IR capture.
The capture-profile spelling used by new production code is
`VerifiedCanonicalAST`; `VerifiedTypedHIR` remains only as a same-value
transition alias until the remaining ABI/diagnostic/test terminology is
removed.

StaticJIT generation is also independent of the Cache V2 product switch. A
generation Engine still prepares the existing clean compile-fact transport and
freezes its authoritative source graph when Cache V2 is disabled; it does not
perform Cache restore, publication, or persistence.

## TDD trail

The focused backend-profile assertion was first strengthened to require:

- TypedAST needs canonical AST snapshot retention;
- TypedAST does not require typed-semantic-IR capture; and
- applying the profile leaves `bCaptureTypedSemanticIR == false`.

It failed before the implementation:

- `Saved/Tests/cta-staticjit-no-hir-capture-red/20260824_191804_766_f35603c5`
  — **0/1**, at the new no-HIR assertion.

After separating the two engine configuration facts, the exact test passed:

- `Saved/Tests/cta-staticjit-canonical-capture-green/20260824_192443_812_504b1c2d`
  — **1/1**.
- `Saved/Tests/cta-staticjit-canonical-capture-backend-contract/20260824_192527_873_28b06d3d`
  — complete backend contract **9/9**.

The first ProjectSourceGraph run then found a real integration defect:

- `Saved/Tests/cta-staticjit-canonical-source-graph/20260824_192728_049_1fa9b377`
  — **1/2**; the positive artifact compile had no frozen source-graph snapshot.

Root cause: StaticJIT generation reused the clean compile-fact capture context,
but creation of that transport was incorrectly gated by `IsCacheV2Enabled()`.
With the newly established default-off Cache policy, source compilation
succeeded while snapshot freezing was skipped. The condition now admits an
independent StaticJIT generation consumer even when Cache V2 is disabled.

## Canonical CodeGen defect exposed by the broader gate

The first CanonicalASTMigration regression was **12/14**:

- `Saved/Tests/cta-staticjit-canonical-adapter-regression/20260824_193517_417_e798f2cb`.

One failure was the deliberately retained HIR migration baseline implicitly
running under the now-default CANONICAL compiler. It now explicitly selects
the LEGACY pipeline before enabling test-only HIR capture. The other failure
was real: sealed-AST Bytecode CodeGen did not map `**` / `**=` to the VM power
instructions. `asCBytecodeCodeGen` now selects `POWd`, `POWdi`, `POWf`, and
signed/unsigned 32/64-bit power instructions from the sealed operand types.

## Green evidence

- Build:
  `Saved/Build/cta-staticjit-generation-cache-independent-build-v2/20260824_193156_636_b0869d75`
  — success.
- Final CodeGen build:
  `Saved/Build/cta-canonical-pow-codegen-build/20260824_193848_456_16dd52db`
  — success.
- Generation profile with Cache V2 disabled:
  `Saved/Tests/cta-staticjit-generation-cache-independent-green/20260824_193223_982_5151b670`
  — **1/1**.
- Project source graph:
  `Saved/Tests/cta-staticjit-canonical-source-graph-green/20260824_193311_313_a3f15b53`
  — **2/2**.
- Existing HIR-dump command compatibility on canonical snapshot input:
  `Saved/Tests/cta-staticjit-canonical-hir-dump-compat/20260824_193354_256_b8f4c04e`
  — **5/5**.
- Canonical AST migration adapters and legacy HIR comparison baseline:
  `Saved/Tests/cta-staticjit-canonical-adapter-green/20260824_193911_634_5986040a`
  — **14/14**.
- Complete StaticJIT generation Engine group:
  `Saved/Tests/cta-staticjit-project-generation-engine-regression/20260824_193949_369_7d5187fe`
  — **32/32**.

## What this does not close

This gate does **not** complete Tasks 7.2, 7.8, 10.5, or 13.1:

- transitional `asCTypedSemanticFunction` overloads and HIR fallback branches
  remain in TypedASTJIT eligibility, closure, analyzer, dependency, and emitter
  sources;
- generation/backend view structs and installed-provider diagnostics still
  contain `VerifiedTypedHIR` fields for compatibility;
- the developer command is still named HIR Dump and can consult a LEGACY
  function-owned HIR when explicitly produced by a comparison test;
- the HIR builder, storage, accessors, and test oracles have not been deleted;
- full-language Canonical CodeGen/default-path provenance and the final
  subsystem matrix remain open.

The closed claim is narrower and important: production TypedAST generation no
longer turns on HIR capture to obtain its AST, and Cache V2 being off no longer
silently disables StaticJIT generation snapshot freezing.
