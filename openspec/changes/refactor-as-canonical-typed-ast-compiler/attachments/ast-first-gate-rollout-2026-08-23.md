# AST-first gate rollout and evidence card

## Status and binding rule

This attachment turns the AST-first rule into the operating task protocol for
`refactor-as-canonical-typed-ast-compiler`. It applies to every unchecked task
in sections 2–10 and 13 that can alter canonical source semantics, sealed AST
content, canonical Bytecode input, snapshot publication, or AST-aware Cache
V2 restoration.

The canonical AST is the representation being made authoritative. Therefore a
source-level AST unit test is the entry gate for a semantic slice; VM, cache,
or broad-suite tests are evidence *after* that gate, not substitutes for it.
This attachment is normative under task **0.2**. A later task box cannot be
checked if its required card is absent or if the card's AST stage was skipped.

## Required gate card

Create one card for the smallest independently diagnosable behavior. Keep it
in that task's progress attachment; do not collect unrelated behaviors in a
single large “canonical pass” result.

```markdown
### Gate card: <short semantic fact>

- **OpenSpec task(s):** `5.2`, `13.2`
- **Source fixture:** exact inline AS source or checked-in `.as` fixture.
- **Canonical fact:** the fact that must exist after `Parser → Sema → Seal`
  (for example resolved callee/receiver, exact `asCQualType`, conversion,
  cleanup edge, control target, source range, snapshot generation, or decoded
  DTO identity).
- **AST test:** C++ source path and exact test method. State whether it reads
  `asIASTSnapshot` or a sealed internal context/deterministic canonical dump.
- **AST-red:** command, report path, expected diagnostic/assertion, and date.
- **AST-green:** command, report path, pass count, and the exact assertion that
  changed state. The test remains permanent.
- **CodeGen/provenance:** required command/report and proof that canonical
  CodeGen consumed the same sealed graph; use `N/A` only when no executable
  lowering is involved.
- **Lifecycle:** Cache V2, snapshot/reload, StaticJIT, or Standalone command
  and report when this fact crosses that boundary; otherwise explain `N/A`.
- **Focused regression:** owning group command/report after the repair.
- **Remaining boundary:** unsupported syntax/route/behavior that this card
  explicitly does not close.
```

### Sequencing rule

```text
test/diagnostic scaffolding only
          ↓
record AST-red from source → Parser → Sema → Seal
          ↓
repair semantic construction / verifier
          ↓
record AST-green
          ↓
repair or extend CodeGen, publication, persistence, or JIT as needed
          ↓
record downstream result and focused regression
```

No production Parser/Sema/AST/CodeGen/cache/snapshot modification may begin
before `AST-red`, except the minimal test or read-only diagnostic support that
makes the missing fact observable. If existing code already has the desired
behavior and a historical red run cannot be reproduced, the card must state
why and show the source-level absence that was fixed; it may not invent a red
result.

## What is an AST unit test

For a language semantic, the front test must compile real source through the
canonical-selected path and inspect a **sealed** AST (or V1 immutable public
view). It must assert the smallest fact that distinguishes the correct graph
from plausible wrong graphs. Good examples include:

- the declaration's stable owner/key, exact canonical type and qualifiers;
- a selected overload, effective receiver, source/default/hidden arguments,
  and conversion nodes rather than a later VM return value;
- an explicit temporary/cleanup or control-transfer target with source-order
  roles rather than merely the bytecode executing;
- the snapshot's sealed graph, lease/current-generation contract; or
- a Cache V2 decode's pointer-free source/type/decl/body relation before a
  restored VM function is invoked.

Directly constructing a node remains correct for allocator, verifier,
malformed-graph, and public-view boundary tests. It is **not sufficient by
itself** for a user-visible source construct: pair it with a source-path
Parser → Sema → Seal test so a hand-built AST cannot hide a missing parser
action or semantic resolution step.

The following do not qualify as an AST front gate on their own:

- a successful legacy compile or a canonical pipeline enum check;
- a source-to-VM result with no sealed AST assertion;
- a CodeGen dump/counter that says nothing about the graph it consumed;
- a zero-filled public-view struct that only checks overwrite behavior; or
- cache bytes accepted as an opaque non-empty placeholder.

## Routing matrix for all remaining work

| Remaining task family | AST-first owning suite and fact | Mandatory follow-on before its task can close |
| --- | --- | --- |
| `2.2`, `13.10` SourceManager | `Frontend.CanonicalAST`: source-file identity/content remap and authored/processed/generated range on a sealed declaration/diagnostic | maintained diagnostic compatibility and public/cache source-model proof |
| `3.4`, `13.8`, `13.11` snapshots | `Module.CanonicalAST.Snapshot` plus Hot Reload AST tests: sealed content, lease, generation, failed-publish preservation | CodeGen build/replace or cache restore when the path publishes executable state |
| `4.2`–`4.6`, `13.2`, `13.3` declaration/type Sema | `Compiler.CanonicalAST.SemaAuthority`: source declaration, scope, signature/owner/type/trait/dependency fact | canonical CodeGen publisher/isolated behavior for executable declarations; cache remap where persisted |
| `5.2`–`5.9`, `13.2` expression/statement/lifetime Sema | `SemaAuthority`: resolved expression type/category, callee/arguments/conversion, control or cleanup fact | `ProductionCodeGen` plus isolated differential trace; StaticJIT/Cache only if the fact crosses it |
| `6.3`, `6.4`, `6.6`, `13.9` Cache V2 | Cache canonical-AST sidecar tests: decoded sealed graph equivalence, stable refs, owner/generation, pointer-free bytes | ExactStartup/warm-cache execution and atomic replacement evidence |
| `7.2`, `7.4`, `7.5`, `7.8` TypedASTJIT | Canonical AST StaticJIT tests: sealed AST visitor input, eligibility/call/cleanup/dependency facts | generated native artifact/provider selection plus reload freshness/fallback evidence |
| `9.1`, `9.5`, `9.6`, `13.6` Bytecode CodeGen | existing/new `SemaAuthority` test naming the exact input node/type/call/control/lifetime fact | `ProductionCodeGen` proves same-snapshot publisher, detached artifact and rollback; execution is third-layer evidence |
| `9.7`, `10.1`–`10.7`, `13.1` cutover | one source-build gate per purpose that seals and inspects the canonical graph and provenance | all purpose-specific CodeGen/provenance, lifecycle, differential, and final matrix results |

For a task that spans rows, create separate cards per semantic fact and join
them only in the parent task's final evidence. A single “all canonical tests
passed” card is deliberately invalid because it cannot identify which layer
first regressed.

## Commands and reporting

Use the supported runners from `D:\as-cta`; exact automation method targeting
uses the prior report's `fullTestPath` so an empty selector is never mistaken
for a pass.

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label <slice>-ast-frontend -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label <slice>-ast-sema -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot" -Label <slice>-ast-snapshot -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label <slice>-codegen -TimeoutMs 900000
```

For a red test, save the `RunMetadata.json` path and record the expected single
failure. For green, record both the focused method and its owning group count.
Before attaching a CodeGen result, inspect provenance/counter fields or a
dedicated assertion proving canonical CodeGen consumed the sealed snapshot;
“the script ran” is insufficient.

## Enforced Cache gate card: retained declaration identity and staging skeleton

- **OpenSpec task(s):** `6.3`, `6.4`, `13.9`.
- **Source fixture:** `MakeSource(42)` in
  `AngelscriptCacheExactWarmStartupTests.cpp`, producing source-owned
  `int Answer() { return 42; }` and a retained canonical sidecar whose stable
  function key is `Answer()`.
- **Canonical fact:** after the sidecar is decoded and sealed, every
  declaration's stable key must equal the key implied by its owner/name/type/
  parameter qualifiers. Each body-owning canonical function then binds exactly
  once to a target staging `asFUNC_SCRIPT` skeleton with matching
  owner/namespace, name, return type, parameter types/passing, and constness.
  This is a Cache DTO fact, not an assertion over VM return bytes.
- **AST test:**
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheExactWarmStartupTests.cpp`
  — `RetainedPolicyRejectsUnremappableAstDeclarationBeforeEngineActivation`.
  The test captures a real sealed source AST, mutates only the persisted
  declaration name/key `Answer` / `Answer()` → `Xnswer` / `Xnswer()` at equal
  byte length, repairs all Cache V2 links/hashes, then asks ExactStartup to
  decode and remap it. This keeps the AST declaration internally
  self-consistent while leaving the VM skeleton as `Answer`, so it exercises
  the target-skeleton mapping branch rather than only the key-integrity branch.
  It observes the production sealed context through the retained snapshot path;
  it is deliberately not a hand-built AST verifier test.
- **AST-red:** `Cache.ExactWarmStartup` reported `13` successful cases and
  one expected failing declaration gate: restored `Xnswer()` incorrectly
  activated because decode/Seal and Cache graph admission accepted the bytes
  while no declaration-to-skeleton verification existed. Evidence:
  `Saved/Tests/cta-cache-unremappable-declaration-red-group/20260823_183408_653_3e4c2428/Report/index.json`.
- **AST-green:** `asCRuntimeTypeBridge::ValidateContextDeclarations` rebuilds
  every canonical key, then resolves one exact staging skeleton for each
  body-owning declaration, and rejects before `ModuleDesc` assignment. Focused
  result: `1/1 PASS`,
  `Saved/Tests/cta-cache-function-skeleton-binding-green/20260823_185929_862_79afa39b/RunMetadata.json`.
  The second permanent source-path gate,
  `RetainedPolicyRejectsDetachedEnumDeclarationIdentityBeforeEngineActivation`,
  mutates only the non-body enum key `EExactWarmState` → `XExactWarmState`.
  It was a valid red because the prior bridge skipped non-function declarations
  (`Saved/Tests/cta-cache-detached-enum-declaration-red/20260823_185212_282_90ad2b1d/Report/index.json`), and is now `1/1 PASS`
  (`Saved/Tests/cta-cache-detached-enum-declaration-green/20260823_185320_359_32dbfbb9/RunMetadata.json`).
- **CodeGen/provenance:** N/A for this narrow persistence firewall: no
  lowering changed, and its point is to deny unverified data before any later
  CodeGen/native consumer can receive it. A verified consumer remains an open
  `6.3`/`13.9` requirement.
- **Lifecycle:** full ExactStartup group `15/15 PASS`, zero failed/not-run;
  it proves normal retained restores plus every negative sidecar gate remain
  valid. Evidence:
  `Saved/Tests/cta-cache-exact-startup-declaration-integrity-final/20260823_190040_067_423fda07/Report/index.json`.
- **Focused regression:** the same full group above is the owning lifecycle
  regression. Build evidence is
  `Saved/Build/cta-cache-unremappable-declaration-green-build/20260823_183940_475_ba9530a8/RunMetadata.json`.
- **Remaining boundary:** the non-skeleton key-integrity slice is covered, but
  the clean complete-module capture path currently rejects imports; import
  replay needs an explicit Cache V2 shape/target-slot remap contract. Bytecode/
  TypedASTJIT must later prove they receive only this verified staged graph.
  This card does not close `6.3` or `13.9`.

## Enforced StaticJIT gate card: semantic type key identity

- **OpenSpec task(s):** `7.2`, `7.4`, `7.8`, `13.3`.
- **Source fixture:** the global and class-method overload fixtures in
  `AngelscriptStaticJITCanonicalASTIdentityTests.cpp` each declare `F(int)`
  and source-spelled `F(float)` while compiling in the normal
  `asEP_FLOAT_IS_FLOAT64` configuration.
- **Canonical fact:** a declaration stable key is a semantic identity, not a
  replay of source token spelling. The parser resolves `float` to
  `ttFloat64` in this configuration, and `asCASTContext::InternPrimitive`
  canonically renders that type as `double`; the expected keys are therefore
  `F(double)` and `T::F(double)`. The StaticJIT snapshot's runtime-to-AST
  binder must build precisely that same normalized key before it accepts one
  unique sealed declaration ID.
- **AST observation/red:** the existing identity suite reproducibly failed
  (`6/8`) when `PrimitiveAstTypeKey` was changed to preserve a misleading
  runtime/display spelling and the old assertions still expected `F(float)`.
  The failure moved from missing identity to a bound `F(double)` declaration,
  locating the boundary at the runtime-key-to-canonical-key conversion rather
  than in overload selection. Evidence:
  `Saved/Tests/cta-staticjit-canonical-identity-float-fix-green/20260823_190550_268_80386b61/Report/index.json`.
  This was an audit-discovery red on an already-existing test, not a claim
  that the entire StaticJIT migration is TDD-closed.
- **AST-green:** `PrimitiveAstTypeKey` maps `ttFloat`/`ttFloat32` to `float`
  and `ttDouble`/`ttFloat64` to `double`; the permanent assertions now state
  the normalized `F(double)` / `T::F(double)` contract alongside ordinary
  unique-overload, namespace, ctor/dtor, operator, mixin, and lambda checks.
  Build: `Saved/Build/cta-staticjit-canonical-identity-semantic-float-build/20260823_190942_771_9ad3b812/RunMetadata.json`.
  Focused owning group: **8/8 PASS**, zero failed/skipped,
  `Saved/Tests/cta-staticjit-canonical-identity-semantic-float-green/20260823_191005_742_22d5d261/RunMetadata.json`.
- **CodeGen/provenance:** N/A for this narrow immutable-generation snapshot
  identity gate. It proves the input declaration ID is exact before an
  eventual TypedASTJIT visitor consumes it; it does not prove native artifact
  emission or provider selection.
- **Lifecycle:** snapshots own public V1 AST leases; the identity lookup uses
  the sealed context held by that lease. The latest group exercises this
  retained-Bytecode identity path, not a raw module-context borrow.
- **Remaining boundary:** the snapshot still reconstructs its key from
  Engine-local function metadata. A full canonical compiler cutover should
  carry the declaration ID/key from Sema directly rather than reconstruct it
  at a backend boundary. `TypedHIR` remains a structural consumer and the
  TypedASTJIT/native-provider routes remain open; this card does not close
  `7.2`, `7.4`, `7.8`, or `13.3`.

## Completion interpretation

An AST-green card proves exactly its recorded semantic contract, not a whole
section. A downstream failure after AST-green is classified as CodeGen,
publication, persistence, or runtime work and must not be hidden by weakening
the AST assertion. Conversely, a downstream pass cannot close a task with a
missing/red AST card.

Task **0.2** remains open as the umbrella audit until every still-open
applicable item has at least one completed card. Task **0.3** must list all
cards and rerun the entire routing matrix immediately before any default
pipeline change. This preserves AST tests as enduring preflight gates rather
than a one-off refactor artifact.
