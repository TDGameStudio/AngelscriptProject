# Cache V2 Canonical AST sidecar schema V3 alignment

Date: 2026-08-24

Scope: tasks 6.3, 6.4, 6.6, and review blocker 13.9. This is a schema and
negative-lifecycle closure, not a claim that incremental AST dependency
closure, imports, or every Canonical CodeGen consumer is complete.

## Failure observed

A complete `Angelscript.TestModule.Cache` audit exposed two independent schema
drifts after the maintained fork advanced the Canonical AST DTO:

1. `asAST_SIDECAR_SCHEMA_VERSION` was `3`, while
   `FAngelscriptCacheASTBodySidecar::SchemaVersion` still advertised and
   accepted only `2`. The Runtime wrapper therefore rejected valid sidecars
   emitted by the current maintained fork.
2. The ExactWarm corruption fixtures parsed the declaration table using the
   old declaration tail. V3 serializes `byteOffset`, `byteSize`,
   `byteAlignment`, `hasConstantValue`, and 64-bit `constantValue`; the fixture
   skipped the four 32-bit layout/flag fields but not the final eight constant
   bytes. Its cursor became misaligned at the next declaration and returned
   false before it could produce the intended malformed graph.

The first failing ExactWarm report made the second problem observable:

- `Saved/Tests/cta-cache-exact-warm-after-v3-alignment/20260824_151106_744_4228511d/Report/index.json`
- Result: **12/15 PASS**.
- All three failures stopped in `PrepareColdFixture` with
  `Exact warm fixture could not apply its requested AST mutation`; none reached
  ExactStartup, declaration remap, or `context.Seal()`.

This distinguishes a broken adversarial fixture from a production verifier
failure. Relaxing the expected rejection text would not have repaired the
test's actual contract.

## Changes

- Runtime `FAngelscriptCacheASTBodySidecar::SchemaVersion` now matches the
  maintained-fork V3 constant.
- FunctionBody schema-V2 byte-exact tests account for the optional
  `ASTBodySidecar` presence byte and assert its exact record coordinate.
- AST sidecar header/truncation tests use
  `asAST_SIDECAR_SCHEMA_VERSION` rather than a hard-coded version byte.
- ExactWarm declaration and statement-owner mutation cursors now skip the
  complete V3 declaration tail, including the 64-bit constant payload.

The production sidecar decoder and ExactStartup verifier were not weakened.
The repaired fixtures still rebuild all Cache V2 record IDs and parent links,
so Store graph admission succeeds and the semantic rejection remains owned by
the private target-Engine restore stage.

## Verification

Build:

- `Saved/Build/cta-cache-v2-schema-alignment-build/20260824_150643_067_b1185aec/RunMetadata.json`
  — PASS.
- `Saved/Build/cta-cache-exact-warm-v3-mutation-build/20260824_151858_266_02761017/RunMetadata.json`
  — PASS.

Focused codecs:

- `Saved/Tests/cta-cache-functionbody-v2-layout-green/20260824_150935_255_ebf32813/Summary.json`
  — **5/5 PASS**.
- `Saved/Tests/cta-cache-ast-sidecar-v3-green/20260824_151022_365_1d7bb9e9/Summary.json`
  — **12/12 PASS**.

ExactWarm lifecycle:

- `Saved/Tests/cta-cache-exact-warm-v3-mutation-green/20260824_151950_854_01260e11/Summary.json`
  — **15/15 PASS**, zero failures/skips, process and final exit zero.

The refreshed ExactWarm run proves all of the following under V3 in one group:

- unchanged source restores and executes with zero frontend/compiler/Store
  publication work;
- a restored public sealed context re-encodes to the linked DTO byte-for-byte;
- missing, trailing, truncated, wrong-profile, and unremappable-type sidecars
  reject before target-module activation;
- a coherent but unresolvable function declaration and a detached non-body enum
  declaration reject at target-Engine declaration validation;
- an in-bounds `decl.body` / `stmt.owner` disagreement reaches final AST Seal
  verification and rejects before staging attachment/activation.

## Remaining work

- Task 6.6 still needs a current incremental identity/closure matrix. The
  present module-shared sidecar design must be reconciled explicitly with the
  requirement that one changed function rebuild only the intended
  FunctionBody/AST payload while unchanged record identities are reused.
- Canonical per-function build-artifact restore callbacks are not yet invoked
  by the current `asCBytecodeCodeGen` production path; the focused
  `Cache.BuildArtifactRestoreHook` audit is **1/3 PASS** and is the next active
  Cache/compiler integration slice.
- Clean complete-module capture still rejects import declarations, and
  verified Cache-restored AST consumption by every downstream backend remains
  open under 6.3/13.9.
