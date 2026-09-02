# Cache V2 canonical-AST DTO and ExactStartup gate

**Scope:** Establish an AST-first gate around Cache V2 retained-AST capture and
restore, and correct stale task text that still described an empty
TranslationUnit placeholder.

## Required evidence order

```text
sealed source AST
  -> byte-exact sidecar DTO
  -> decode into a new sealed Context
  -> restore to a private staging module
  -> publish snapshot before the sole module-set swap
  -> verify zero frontend work and public AST traversal
```

Execution/VM cache success alone is not enough. A green gate must prove the
restored public snapshot contains the semantic graph that Cache V2 persisted.

## Current AST-first test matrix

| Test group | AST facts asserted before execution | Restore/lifecycle fact |
| --- | --- | --- |
| `Cache.ASTBodySidecar` | source sections, types, declarations, body/statement/expression edges, resolved float width/constant bits, deterministic function-body/profile identity and strict trailing-byte rejection | pointer-free schema/V2 envelope, bounded header-only inspection and shared sidecar incremental identity |
| `Cache.ExactWarmStartup.RetainedCanonicalAstPolicyRestoresPublishedSnapshotWithoutFrontendWork` | public AST V1 sees `Answer`, its body, `return`, integer literal `42` after a new-context restore | retained Cache V2 graph is decoded on staging and published as a current snapshot |
| `Cache.ExactWarmStartup.RetainedCanonicalAstReencodesByteExactSidecarWithoutFrontendWork` | source/type/decl/stmt/expr/reference graph is re-encoded from the restored public sealed Context using the selected owner/profile; every DTO byte must match the actual linked persisted sidecar | restores in a new Engine with zero frontend/publication work; this is not a synthetic empty translation unit or a dump-text surrogate |
| `Cache.ExactWarmStartup.UnchangedSecondLaunchRestoresWithZeroFrontendWorkAndNoPublication` | retained graph is a cache input rather than a parser/Sema substitute recreated on demand | preprocess, parse, module compiler, function compiler, publication attempts and frontend events are all zero |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsMissingAstSidecarBeforeEngineMutation` | a valid discard-policy VM generation deliberately has zero `ASTBodySidecar` records; it must never manufacture or publish an empty AST for a retain-policy consumer | ExactStartup is `Rejected` / `RestoreRejected` before target-module activation, with zero frontend and publication counters |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsTrailingAstSidecarBeforeEngineMutation` | the fixture repairs all Cache V2 record links/hashes after appending one forbidden DTO byte; graph admission therefore succeeds, but the strict AST decoder must reject it | ExactStartup is `Rejected` / `RestoreRejected` before target-module activation, with zero frontend and publication counters |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsTruncatedAstSidecarBeforeEngineMutation` | the fixture removes the final AST DTO byte while preserving the complete self-describing header and repairs record links/hashes, so graph admission succeeds but strict body decoding cannot complete | ExactStartup is `Rejected` / `RestoreRejected` before target-module activation, with zero frontend and publication counters |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsAstSidecarProfileMismatchBeforeEngineMutation` | the fixture changes one profile-hash nibble in the self-describing sidecar header and repairs record links/hashes; the sidecar remains graph-admissible but does not belong to its generation | ExactStartup is `Rejected` / `RestoreRejected` at the AST owner/profile guard before target-module activation, with zero frontend and publication counters |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsUnremappableAstTypeBeforeEngineActivation` | the fixture leaves source/decl/body data untouched and changes only the resolved local enum type's stable key from `EExactWarmState` to a same-length nonexistent key, then repairs Cache V2 record links/hashes | after private staging skeleton materialization, `asCRuntimeTypeBridge` rejects the unresolvable type before `ModuleDesc` assignment or module activation, with zero frontend and publication counters |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsUnremappableAstDeclarationBeforeEngineActivation` | the fixture changes the source-owned AST declaration name `Answer` to same-length `Xnswer` and coherently changes its derived stable key `Answer()` to `Xnswer()`, retaining an internally self-consistent source/body graph, Cache links/hashes, and the unchanged VM function declaration | after private staging skeleton materialization, `asCRuntimeTypeBridge` requires the canonical function signature to bind uniquely to the target module's `asFUNC_SCRIPT` skeleton, then rejects before `ModuleDesc` assignment or activation with zero frontend and publication counters |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsDetachedEnumDeclarationIdentityBeforeEngineActivation` | the fixture changes only the non-body enum declaration stable key `EExactWarmState` to the same-length `XExactWarmState`; source/type/body/VM records and Cache links/hashes remain valid, but no local `asCScriptFunction` owns this declaration | `ValidateContextDeclarations` reconstructs every declaration key, so it rejects before `ModuleDesc` assignment or activation with zero frontend and publication counters |
| `Cache.ExactWarmStartup.RetainedPolicyRejectsVerifierInvalidAstGraphBeforeEngineActivation` | the fixture changes only a declaration's actual body statement owner to a different, still-valid declaration ID; record admission and bounds checks still pass, while final `context.Seal()` must reject the semantic graph | ExactStartup is `Rejected` / `RestoreRejected` before staging attachment/module activation, with zero frontend and publication counters |
| `Cache.ExactWarmStartup` changed-source/projection cases | no stale AST is observed as an active module | mismatch is a miss before engine/module activation |

## Current implementation facts

`as_ast_sidecar.cpp` serializes all currently public semantic graph stores:

- SourceManager sections: logical key, origin, line offset and source bytes.
- Interned types: kind, primitive token and stable key.
- Declarations: parent/range/type/name/stable key, children/captures/body,
  traits, origin, defaults, dependencies, bases, initializers and constants.
- Statements and expressions: kind/range/owners/targets/children, body and
  expression edges, resolved declaration/receiver, literals, literal bits and
  safe-point roles.

The decoder re-creates each Context-local ID in deterministic order, validates
references while installing cross-links, requires `offset == length`, and
seals before it reports success. `AngelscriptCacheRestore.cpp` attaches that
sealed context only to a private staging module. Once its cached type/function
skeletons exist, `asCRuntimeTypeBridge::ValidateContextTypes` resolves every
named AST type against the current Engine before `ModuleDesc` assignment.
`ValidateContextDeclarations` reconstructs the canonical stable key for every
decoded declaration, including declarations without a local script-function
skeleton. For every body-owning
function/method/constructor/destructor/mixin it additionally requires one
exact target staging `asFUNC_SCRIPT` skeleton: owner/namespace, name, return
type, parameters, passing flags, and constness must agree. A failed decode,
final sealed-AST verification, type resolution, or declaration resolution
discards staging before `SwapInModules` can expose it.

## Verification

DTO gate:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Cache.ASTBodySidecar" `
  -Label "cta-ast-cache-dto-gate-current" -TimeoutMs 900000
```

Result: **12/12 PASS**, 0 failed, 0 skipped.

- Metadata: `Saved/Tests/cta-ast-cache-dto-gate-current/20260823_173340_570_2bdc1119/RunMetadata.json`
- Report: `Saved/Tests/cta-ast-cache-dto-gate-current/20260823_173340_570_2bdc1119/Report/index.json`

ExactStartup AST gate:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Cache.ExactWarmStartup" `
  -Label "cta-cache-exact-startup-ast-gate-current" -TimeoutMs 900000
```

Result: **15/15 PASS**, 0 failed, 0 skipped. Thirteen test records carry the
pre-existing external HTTP connection warning, but no test warning/error is
attributable to this change.

- Original function declaration build: `Saved/Build/cta-cache-unremappable-declaration-green-build/20260823_183940_475_ba9530a8/RunMetadata.json` (**PASS**)
- New enum-key red: `Saved/Tests/cta-cache-detached-enum-declaration-red/20260823_185212_282_90ad2b1d/Report/index.json` (**expected 1 failure**: the non-body declaration was incorrectly accepted)
- New enum-key build: `Saved/Build/cta-cache-detached-enum-declaration-green-build/20260823_185307_451_ed258ba4/RunMetadata.json` (**PASS**)
- New enum-key focused green: `Saved/Tests/cta-cache-detached-enum-declaration-green/20260823_185320_359_32dbfbb9/RunMetadata.json` (**1/1 PASS**)
- Current coherent function-name/key skeleton green: `Saved/Build/cta-cache-function-skeleton-binding-build/20260823_185910_620_591ca620/RunMetadata.json` (**build PASS**) and `Saved/Tests/cta-cache-function-skeleton-binding-green/20260823_185929_862_79afa39b/RunMetadata.json` (**1/1 PASS**)
- Final full report after the coherent function-name/key fixture strengthening: `Saved/Tests/cta-cache-exact-startup-declaration-integrity-final/20260823_190040_067_423fda07/Report/index.json` (**15/15 PASS**; runner `TimedOut=false`, process/final exit `0`)

The outer shell observer has a fixed ~64-second limit and timed out while the
full group was still running, but the project runner completed normally:
`RunMetadata.json` records `TimedOut: false`, process exit `0`, and the report
records `failed: 0`, `notRun: 0`, and all fifteen test records successful.
The initial retained-AST baseline remains **6/6 PASS** at
`Saved/Tests/cta-cache-exact-startup-ast-gate-current/20260823_173448_942_a8603055/`;
the following run adds the missing-sidecar no-mutation regression at
`Saved/Tests/cta-cache-retain-missing-ast-test-green/20260823_173900_118_728e6733/`,
the next run adds the graph-consistent trailing-byte regression at
`Saved/Tests/cta-cache-trailing-ast-gate-green/20260823_174601_143_5446442b/`,
the following run adds the profile-header mismatch regression at
`Saved/Tests/cta-cache-ast-profile-gate-green/20260823_174954_575_033735a5/`,
the next run adds the truncated-body regression at
`Saved/Tests/cta-cache-truncated-ast-gate-green/20260823_175300_124_5ff6e410/`,
the following run adds the restored-context byte-exact DTO equivalence gate,
the next run adds the target-Engine unremappable-type rejection gate, then the
verifier-invalid semantic-graph rejection gate, and the current run adds the
target-Engine declaration-key/skeleton-binding rejection gate.

## Remaining closure conditions

Task 6.3 is intentionally still open; task 6.4 is now closed by the complete
15-case ExactStartup gate:

1. Named stable types, all decoded declaration keys, and body-owning source
   declaration skeletons now have validation gates. Clean complete-module
   capture currently rejects imports, so import replay is not an untested
   positive ExactStartup contract: it is an explicit future Cache V2 shape
   expansion. Before an exact-restored graph may be fed to CodeGen or a
   typed-native backend, that expanded import route and the consumer must
   prove they use only the verified/staged graph.
2. Missing-sidecar, graph-consistent trailing-sidecar, truncated-sidecar,
   profile-header mismatch, unremappable-type, unremappable-declaration, and
   verifier-invalid graph retain-policy restores are end-to-end
   target-Engine-untouched cases.
   Restored-context DTO byte fidelity is also explicit. Direct decoder tests
   remain complementary to these lifecycle guarantees.
