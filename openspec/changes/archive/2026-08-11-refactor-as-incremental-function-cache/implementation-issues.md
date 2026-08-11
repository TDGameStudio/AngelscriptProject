# Current Implementation Issues

This file contains only the issue set that can affect the next executable Cache
V2 work. The complete discovery-order ledger IC-001 through IC-141 is preserved
unchanged at
`history/pre-refactor-2026-08-09/implementation-issues.md` (SHA-256
`70B7163F855ADB32AC456CFE6C7101C93551B7DF0C0F73223C5D7CCE690940DE`).

## Status summary

| Range | Current disposition | Detail authority |
|---|---|---|
| IC-001–IC-127 | Historical/resolved or absorbed into frozen authority and current tasks | Archived full ledger; reopen with a new issue if a regression is observed. |
| IC-128–IC-134 | Closed for exact approved Manifest/Pack RED authority | `manifest-pack-red-test-authority.md`, current C1 and archived review/evidence. |
| IC-135–IC-137 | Design constraints absorbed into B5–B11 | Sole token/factory/private decoders and precise offsets remain acceptance conditions, not separate completion claims. |
| IC-138 | Open Important; B1 representative RED approved | Normal TypeSchema producer semantic validation remains incomplete; B2/B3 own exhaustive RED and production closure. |
| IC-139 | Closed exact-current-candidate authority | LayoutInputHash and EnumAuthorityHash literals independently recomputed and approved on the final B1 SHA. |
| IC-140 | Critical repair at compile frontier | Nested allocator observation/rejection and behavior proof. |
| IC-141 | Critical partial repair; decoder consumption open | TypeSchema checkpoint/fault-injection consumption. |
| IC-142 | Closed environment-record correction | B1's stale UE 5.7 precondition was reconciled to the worktree's project-associated UE 5.8 toolchain. |
| IC-143 | Closed verification-command correction | The B1 nested `powershell.exe -File ... --` spelling failed before UBT; the current wrapper's explicit `-ExtraArgs` array is authoritative. |
| IC-144 | Closed after exact-SHA rereview | The first B1 candidate omitted a normal-producer `UnknownFlags` result; the isolated repair compiled and received 0C/0I/0M approval. |
| IC-145 | Closed link/evidence-order constraint | The minimum private decoder bridge and Manifest/Pack declaration/stub frontier now make the complete modules link; focused Runtime Automation executes. This does not close B6/B7 or C2 behavior. |
| IC-146 | Closed by V1.2 KindPayload behavior | The shared producer/decoder validator now reports `InvalidQualifierCombination` for `Funcdef.bMulticast=true`; IC-216 records linked GREEN evidence. |
| IC-147 | Closed exact-SHA Slice-1 authority | The initial direct-interface check was self-confirming; the approved asymmetric fixture now separates canonicalization-stage and final-writer evidence. |
| IC-148 | Closed exact-SHA Slice-1 authority | Duplicate B1 Class flag witnesses were removed and remain absent in the approved candidate. |
| IC-149 | Closed exact-SHA Slice-1 authority | The hash-contaminated reversed-payload inequality was replaced by an independently recomputed full normal-output RecordId golden. |
| IC-150 | Closed by V1.2 KindPayload behavior | Delegate and Funcdef now distinguish zero StableFunctionKey from missing ExpectedSignatureAbi; IC-216 records linked GREEN evidence. |
| IC-151 | Closed by V1.2 KindPayload behavior | Typedef now accepts only an unqualified non-Void primitive with no subtypes; IC-216 records linked GREEN evidence. |
| IC-152 | Closed by V1.2 Enum behavior | The shared validator now replays Enum ordinals, names and metadata before EnumAuthorityHash; IC-217 records decoder GREEN evidence. |
| IC-153 | Closed combined authority | Pairing mismatch is explicitly `InvalidQualifierCombination/LocalSemantic` after individually valid stored tuples; fresh combined rereview approved the exact authority. |
| IC-154 | Closed exact-SHA repair and combined authority | The inherited decoder Cartesian misclassification has an approved 495-cell repair and the fresh combined rereview approved Slice-3 materialization. |
| IC-155 | Closed capture/archive wording correction | Compose NotCacheable live-capture disposition was not explicitly separated from explicit DTO/payload `InvalidPresence`. |
| IC-156 | Closed Slice-3 packet count correction | The audit labelled its explicitly listed 13 LayoutInput legal baselines as 12 and its minimum-call totals were not stable after IC-154; the executable packet uses explicit coordinates, not those mechanical totals. |
| IC-157 | Closed packet authority | Nine hash-precondition LayoutInput rows retain stale hashes so their earlier field-local results reach Normal Producer without a fatal fixture finalizer. |
| IC-158 | Closed packet authority | The packet freezes 13 legal calls / five required LayoutInput instances across four non-empty schemas. |
| IC-159 | Closed packet authority | Missing-required coverage separates plain and derived BaseType, yielding five exact form/role rows. |
| IC-160 | Closed packet authority | Required-role optional masks contain all 12 invalid two-bit coordinates, separate from whole-input absence. |
| IC-161 | Closed packet authority | Pairing proof contains eight key-only/ABI-only and both peer-direction rows. |
| IC-162 | Closed packet precision | Overflow uses unsigned arithmetic and wrong-role replacements use single-input baselines. |
| IC-163 | Closed review-handoff identity race | An interim rereview-report hash was observed before reviewer FINAL; the implementer stopped before editing and release was reissued only from the final immutable report SHA. |
| IC-164 | Closed compile-local defect | Two explicit `-> int32` annotations repaired the local lookup-lambda C3487 failure; the fresh exact SingleFile rerun compiled the complete TU successfully. |
| IC-165 | Closed evidence-materialization gap | Slice-2 and Slice-3 blob IDs had been computed read-only but were not readable objects; exact predecessor reconstruction reproduced both recorded identities before both immutable blobs were materialized without changing the working file. |
| IC-166 | Closed Slice-4 ownership conflict | Property stale hashes belong to Slice 6 with final TypeLayoutHash; Slice 4 owns legal property hash regeneration and offset/hash inequality only. |
| IC-167 | Open Important / B2 RED target | Raw PrimitiveType `13/255` is frozen as `UnknownEnumValue`; the current normal producer incorrectly collapses it to `InvalidPresence`. |
| IC-168 | Closed packet transcription defect | The first Slice-4 packet plan mislabeled legal UStruct SkipReplication as owner-forbidden; it now names Config `0x08001` and the brief spells all three forbidden UStruct masks. |
| IC-169 | Closed immutable-input pin defect | After IC-168 changed the plan SHA, the corrected Slice-4 brief still pinned the rejected plan identity; the pin now names the actual corrected plan and requires a fresh rereview. |
| IC-172 | Source repair compiled / behavior pending | Local TypeSchema cannot prove a unique zero-parameter constructor. Slice 5 now moves the affected local rows to success; linked Automation remains pending. |
| IC-173 | Source repair compiled / behavior pending | The 952 ghost-empty decoder calls are removed and eleven real legal-form empty baselines compile; linked Automation remains pending. |
| IC-174–IC-180 | Source materialized / behavior pending | Presence-only Behavior owners, no-look-ahead form closure, exact literals/coordinates, all-nonhash finalization and optional-owner precedence are materialized in the Slice-5 test TU. |
| IC-181 | Closed exact authority | Duplicate/conflicting singleton Relation/LayoutInput rows fail in the earlier field-local pass and never reach form closure. |
| IC-182 | Closed exact ready-packet authority | Seven TypeKind baselines were replaced by eleven legal-form empties in the double-RELEASE packet; the obsolete 2,088-call ledger cannot authorize source. |
| IC-183 | Closed exact authority | DTO-derived Dependency set equality is uniquely local; graph owns target/entity/owner/module/ABI resolution and separate record/declaration coverage. |
| IC-184 | Closed exact ready-packet authority | The double-RELEASE packet uses the reviewed deduplicated 64-call focused ledger with per-kind ordinal, owner-precedence and Environment-copy controls. |
| IC-185 | Closed Slice-5 source/compile guard | Reachability-preserving dependency reconstruction replaces broad Declaration/EnvironmentAbi deletion in repaired/new fixtures; source scan and complete-TU compile pass. |
| IC-186–IC-190 | Source materialized / behavior pending | Two rejected packet candidates remain preserved; repair-2 coordinates and companion recipes now compile in the Slice-5 test TU. |
| IC-191 | Closed compile-local test-wire mapping defect | Logical `BehaviorDeclaringOwner` assertions map to existing wire span `BehaviorDeclaringOwnerOptionalTag`, same primary row and secondary index `1`; the exact rerun compiles. |
| IC-192 | Closed CQTest runner-addressing defect | Exact method prefixes require the `FAngelscriptCacheTypeSchemaTests` class segment; a zero-discovery run is not behavior RED. |
| IC-193–IC-194 | Closed B5 physical-reader defects | Fixed-field and declared-array truncation now report `OutOfBounds` at the first unavailable byte while preserving stronger budget/range/overflow classifications. |
| IC-195 | Closed test-authority coordinate defect | DataType optional-tag raw-wire assertions now use Property `0`, preorder node `0`; corrected source SHA `2ACBD5...E5EB` supersedes `18A552...D5F9`. |
| IC-196 | Closed shared Behavior defect | One phase-separated validator now rejects the Behavior family on producer and decoder paths; focused evidence is GREEN. |
| IC-197–IC-205 | Closed B2/Behavior/header executable findings | All eleven producer methods execute; fixture, coordinate and phase-order repairs are preserved in their detailed entries. |
| IC-206 | Closed Relations executable findings | The full 195-scenario producer and 495-cell decoder products pass with production dependency ordering and bounded logs. |
| IC-207–IC-208 | Closed LayoutInputs authority/harness findings | Shared LayoutInputs validation passes 100 producer scenarios and three bounded decoder groups; the test-only array self-alias crash is repaired. |
| IC-209 | Closed cross-family fixture isolation defect | Relations fixtures no longer accumulate LayoutInput co-faults; exploratory Runtime phase changes were reverted and the combined regression is 15/15. |

An archived issue marked closed describes the evidence available at its historical
snapshot. If later source changed, approval does not transfer to the new SHA.

## IC-138 — producer accepted self-consistent illegal TypeSchema semantics

- Severity/state: Important / open; blocks B2–B3 and approval of the current
  producer SHA.
- Observed boundary: `SerializeTypeSchema` canonicalizes and checks selected values
  and derived hashes, but the normal producer path does not prove the complete
  frozen canonical-local semantic matrix. For example, conflicting singleton
  LayoutInputs can be rehashed into a self-consistent but illegal schema.
- Required decision: one producer-side canonical-local validator, independent of
  Budget, captured offsets and current resolvers. Normal serialization fails closed,
  clears sentinel output and does not mutate the input DTO. The guarded physical
  writer remains only for physically representable hostile decoder fixtures.
- Required evidence: exact producer result cases spanning conflict/duplicate,
  unknown enum/flag, ordinals, shapes and immutable layout replay; complete test-TU
  compile, focused producer Automation and fresh exact-SHA 0C/0I review.
- Current behavior evidence: the linked normal-producer Behavior matrix reaches
  returned result/output mismatches at
  `Saved/Tests/cache-b2-behavior-producer-red/20260809_111447_046_077c5b75`.
  B2 still requires the complete eleven-method prefix before this issue can close.

## IC-139 — two hash domains lack independently frozen literal vectors

- Severity/state: Important evidence gap / closed for exact B1 candidate SHA
  `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`.
- Gap: StorageLayoutHash, PropertyLayoutFingerprint and TypeLayoutHash have literal
  evidence, while LayoutInputHash and EnumAuthorityHash were historically prepared
  by public helpers that could drift with the producer.
- Required decision: keep literal expected-hex and one-field-mutation vectors in the
  existing TypeSchema authority/test surface. Do not create a second production
  hash helper, wire implementation or redundant authority document.
- Close evidence: the final complete test TU compiled fresh; two independent
  reviews rebuilt the canonical LayoutInputHash and EnumAuthorityHash byte streams
  without project hash helpers and matched all four literals. Final exact-SHA
  review `reviews/b1-typeschema-red-review-183B7AF5.md`, SHA-256
  `09EAAB56B73EDA7A85F0631EB5E0C8DE5479E7F49F2BFAEFA72B3E910D63DBD2`,
  returned 0 Critical / 0 Important / 0 Minor. Focused behavior remains a later
  IC-145 link prerequisite, not an IC-139 literal-authority gap.

## IC-140 — nested canonical allocation observation bypassed the factory

- Severity/state: Critical / a repair compiles; behavior and fresh independent
  rereview remain open.
- Original fault: controller and payload used the candidate transaction, but nested
  canonical strings/arrays/offset arrays received an empty observer. Their Budget
  effect was real while the claimed exact chronology and rejection count were not.
- Paused repair: one stack-local context forwards accepted nested allocations and
  rejected reservations into the sole candidate/probe chronology. It must still
  prove allocator requested/reserved/element/alignment/actual-byte equality,
  one-byte-short rejection, cleanup and Shipping-disabled seam equivalence.
- Compile evidence only:
  `Saved/Build/cache-decoded-factory-observer-tu15/20260808_235612_351_d4f02462/`
  and
  `Saved/Build/cache-canonical-observer-compat-tu/20260808_235625_855_c63efc7a/`.
- Paused factory source SHA-256:
  `66231C6614B6A858E772399D8D61704C4D608070F4B07D9118FB9367BFCA1292`.

## IC-141 — declared TypeSchema injection/checkpoints were not consumed

- Severity/state: Critical / probe lifecycle compiles; the private decoder remains
  incomplete.
- Original fault: physical/local/hash/checkpoint target setters existed, but the
  production decode path did not consume them. A configured fault therefore could
  not prove attribution, rollback or prior-output preservation.
- Paused repair: factory call setup/reset, physical-after-success behavior and
  call-local lifecycle exist. The TypeSchema bridge must still consume deferred
  local/hash targets and twelve validation checkpoints at their exact captured
  offsets on the same decoder path.
- Required evidence: complete link, exact fault matrix, zero/undersized/exact probe
  capacity, two callers/thread isolation where applicable, prior-output
  preservation, focused Automation and fresh exact-SHA review with IC-140.

## IC-142 — B1 named a stale UE 5.7 toolchain

- Severity/state: record correctness / closed before the fresh B1 compile.
- Observation: the B1 precondition named UE 5.7, while the authoritative
  worktree `AngelscriptProject.uproject` has `EngineAssociation` `5.8`,
  `AgentConfig.ini` resolves `C:\\Program Files\\Epic Games\\UE_5.8`, and that
  installation reports `5.8.0` changelist `55116800`. No default-path UE 5.7
  installation exists on this machine.
- Decision: B1 compilation uses the project-associated UE 5.8 toolchain. The
  exact wrapper, target, single-file input and other acceptance conditions stay
  unchanged; only the stale engine-version label is corrected.
- Required evidence/task impact: retain the environment inspection in the current
  verification ledger; B1 remains the active task and no production source or
  test candidate changes are authorized by this correction.
- Scope: this is OpenSpec evidence hygiene, not a Cache V2 behavior change and
  not authority to rewrite repository-wide engine-version guidance in this
  change.

## IC-143 — B1's nested PowerShell command did not reach UBT

- Severity/state: verification command correctness / closed after root-cause
  investigation; the failed invocation is not TypeSchema RED evidence.
- Reproduction: invoking `powershell.exe -File Tools\\RunBuild.ps1` with a bare
  `--` before `-SingleFile` exited 1 in 1.1 seconds. PowerShell bound an empty
  parameter name and reported it ambiguous among the wrapper parameters; no UBT
  process or build artifact directory was created.
- Root cause: `RunBuild.ps1` exposes a `ValueFromRemainingArguments` `ExtraArgs`
  array, while repository success evidence passes dash-prefixed UBT values
  explicitly via `-ExtraArgs @(...)`. The nested Windows PowerShell `-File`
  invocation did not preserve the documented bare separator as a remaining
  argument.
- Decision: B1 resolves the test TU in the current project shell and calls the
  repository wrapper with
  `-ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')`.
  No wrapper or production source change is needed.
- Required evidence/task impact: rerun the corrected B1 command fresh, require
  wrapper exit 0 and verify `RunMetadata.json` contains the intended two UBT
  arguments. B1 remains open until the compile and exact-SHA review close.

## IC-144 — B1 normal-producer RED omitted its unknown-flag representative

- Severity/state: Important review finding / closed after the amended complete TU
  compiled and the exact SHA received independent 0C/0I/0M approval.
- Exact boundary: independent review of test SHA
  `A6EE78A19AC83A6F93AB86AD2072BF7E0758C0B699436D46D396DCAEB19CE66A`
  returned 0 Critical / 1 Important / 0 Minor. The sole normal-producer method
  covered duplicate/conflict, ordinals, shapes, immutable layout replay and two
  `UnknownEnumValue` results, but every explicit unknown high flag bit still used
  the hostile physical writer plus decoder. That did not satisfy IC-138's explicit
  producer-result span over unknown enum/flag.
- Review authority:
  `reviews/b1-typeschema-red-review-A6EE78A1.md`, SHA-256
  `53BE748441E3F836826F1C4884A9DD6A8587C714298D34FC014091C5CBA74BCE`.
- Decision: keep B1 narrower than B2's future exhaustive producer matrix, but add
  one valid Class baseline with only the unknown `TypeSemanticFlags` bit `0x100u`,
  recompute its derived hashes, and route the real
  `SerializeTypeSchema` entry through
  `ExpectExactProducerFailureAndInputUnchanged`, expecting `UnknownFlags`.
  This reuses the exact tuple, sentinel clearing and immutable-input proof; it does
  not add a test-local validator or change Runtime source.
- Current amended candidate: SHA-256
  `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`,
  467,181 bytes, 10,678 LF, 55 `TEST_METHOD` definitions, zero CRLF and final LF.
  Fresh complete-TU artifact:
  `Saved/Build/cache-b1-typeschema-red-tu-rereview/20260809_012321_011_77e2f449/`,
  wrapper/process exit zero with exactly one candidate compile.
- Close evidence/task impact: final fresh compile artifact
  `Saved/Build/cache-b1-typeschema-red-tu-final/20260809_013727_047_f66a7ff2/`
  exited zero with one complete test-TU action. Exact-SHA rereview
  `reviews/b1-typeschema-red-review-183B7AF5.md`, SHA-256
  `09EAAB56B73EDA7A85F0631EB5E0C8DE5479E7F49F2BFAEFA72B3E910D63DBD2`,
  returned APPROVE with 0 Critical / 0 Important / 0 Minor and proved that removing
  only the added seven lines reconstructs the rejected predecessor byte-for-byte.
  B1 is closed; B2 still owns exhaustive canonical-local producer RED coverage.

## IC-145 — B3 behavior cannot precede the current module-link prerequisites

- Severity/state: execution-plan correctness / open until the two link frontiers
  close; this is not a Cache semantic failure and does not block B1/B2 authority
  work or B3 source authoring.
- Exact evidence: full wrapper artifact
  `Saved/Build/ic138-producer-red-link/20260809_000350_244_1ad1e48d/`
  reached UBT and exited with process code 6 / wrapper code 1 after 52,238 ms.
  `AngelscriptCacheManifestPackTests.cpp:1` cannot include the intentionally absent
  `Cache/AngelscriptCacheManifestPack.h` owned by C2, and
  `UnrealEditor-AngelscriptRuntime.dll` cannot link the declared but undefined
  `FDecodedRecordCodecBridge::TryDecodeTypeSchema` owned by B5–B7. Automation was
  never discovered or executed; this artifact is neither producer RED nor GREEN.
- Decision: do not add a placeholder decoder, fake Manifest header, test-file gate,
  alternate module, direct UBT invocation or stale-editor test run. B3 has two
  evidence subgates: after B2, implement the producer validator and fresh-compile
  the exact production/test TUs; the B3 checkbox and IC-138 Behavior GREEN remain
  open until B5–B7 define/link the private decoder and C2 supplies the real
  Manifest/Pack declaration, after which the focused producer prefix runs through
  `Tools\RunTests.ps1`.
- Task impact: the compiled B3 production surface may feed B5 without pretending
  B3 behavior has passed, so this is not a dependency cycle. The earliest point at
  which both prerequisites exist must run the deferred producer prefix immediately,
  rather than waiting silently for final package validation. B12 reruns it as part
  of the complete record/factory/graph regression.
- Required close evidence: successful full module build/link, focused
  `Angelscript.TestModule.Cache.Archive.TypeSchema` discovered/executed/pass counts,
  exact artifact/report paths and confirmation that neither prerequisite was
  satisfied by a stub or disabled test registration.

## IC-146 — Funcdef multicast producer error disagreed with frozen local semantics

- Severity/state: Important semantic mismatch / closed by the V1.2 KindPayload
  implementation and evidence recorded in IC-216.
- Exact boundary: `ValidateProducerShape` currently returns `InvalidBoolean` when
  `TypeKind=Funcdef` and the selected callable payload has `bMulticast=true`
  (`AngelscriptCacheTypeSchema.cpp:513-517`). The frozen TypeSchema matrix treats
  this as a known-but-forbidden semantic combination and requires
  `InvalidQualifierCombination`, matching the decoder-side canonical-local rule.
- Decision: B2 adds an explicit normal `SerializeTypeSchema` case with an otherwise
  valid, fully rehashed Funcdef fixture and exact inactive producer coordinate;
  it must not route through the physical writer/decoder or relax the frozen matrix.
  B3 replaces the narrow producer-only interpretation by the sole shared
  canonical-local semantic owner rather than adding a one-off special case.
- Required evidence/task impact: current code must first produce the wrong returned
  result under a truthfully linked focused RED run after IC-145 prerequisites;
  final GREEN requires exact `InvalidQualifierCombination`, cleared output,
  unchanged input, focused prefix pass and decoder regression. IC-216 now records
  this linked GREEN closure through the sole shared local validator.

## IC-147 — B2 direct-interface order initially used a self-confirming payload

- Severity/state: Important test-authority finding / closed by the fix-2 exact-SHA
  full-slice review.
- Exact boundary: the first Slice-1 candidate serialized one direct-interface DTO
  through normal `SerializeTypeSchema` to obtain `DirectInterfaceExpected`, then
  serialized that same DTO through the same normal producer again. A producer
  that incorrectly target-sorted the sequence could therefore generate its own
  expected bytes and pass. Independent review of candidate SHA-256
  `069D4B7B11110E4C2A9A7FBC2A74CF3CECCF55C0E271AC4046C4DCDC22E1C738`
  reported this as Important in
  `.superpowers/sdd/b2-slice-1-review.md`.
- Decision: keep decoder, raw scanner and physical writer out of semantic-order
  expectations. The final repair retains one valid asymmetric Interface DTO with
  high target `f2/f3` at semantic ordinal `0` and lower target `e2/e3` at ordinal
  `1`, plus canonically sorted dependencies. Its independently frozen stored
  `TypeLayoutHash` and normal-producer success prove that copy/canonicalize/
  validate does not target-sort the direct-interface subsection before
  validation. IC-149 separately owns final writer-order evidence.
- Close evidence/task impact: candidate SHA-256
  `3A16BF271B718B80E1AFF401B549D89DC7CF64391DD5BE7A7F5724F18946C942`
  compiled as the sole action in
  `Saved/Build/cache-b2-typeschema-producer-red-slice1-fix2-tu/20260809_022947_475_6f860f1a/`.
  Fresh report `.superpowers/sdd/b2-slice-1-fix2-review.md`, SHA-256
  `BDBC0B91B17F0A46D8D17E634B6AFC431DE2F9700AF608C2FB9E49EE26E4458D`,
  reviewed the complete B1-to-fix2 blob and returned APPROVED with 0 Critical /
  0 Important / 0 Minor. B2 remains behavior-open under IC-145 despite this
  closed Slice-1 authority finding.

## IC-148 — B2 initially duplicated retained B1 Class flag witnesses

- Severity/state: Important test-maintenance finding / closed by the fix-1 exact-
  SHA rereview; the overall slice remains open for unrelated IC-149.
- Exact boundary: the first Slice-1 candidate added new Class missing-
  `ReferenceType` and `Abstract|Final` producer rows even though B1 already froze
  those exact representative cases. It also repeated the identical
  `ReferenceType|ValueType` Class fixture once as a forbidden-bit witness and once
  as a cross-bit witness. This violated the authoring packet's explicit rule to
  retain, not duplicate, B1 representatives.
- Decision: remove the two B1 duplicates and explicitly cite the retained rows.
  Keep one Class `ReferenceType|ValueType` literal because the Class forbidden-
  `ValueType` rule and the globally forbidden cross-bit combination are
  unavoidably the same observable DTO; label that single row as both witnesses.
  All nonduplicated seven-kind required/allowed/forbidden and behavior-coupling
  rows remain.
- Close evidence/task impact: the fix-1 artifact and candidate identity in IC-147
  prove compilation. Fresh report
  `.superpowers/sdd/b2-slice-1-fix1-review.md` explicitly confirmed that both B1
  duplicates and the repeated Class `ReferenceType|ValueType` call are gone, the
  retained B1 literals remain, and the one surviving Class forbidden-Value row
  also witnesses the unavoidable cross-bit form. This finding is closed even
  though that review returned 1 unrelated Important for IC-149. It changes test
  authority only and does not authorize Runtime work or close the deferred focused
  RED gate.

## IC-149 — reversed direct-interface payload inequality was hash-contaminated

- Severity/state: Important exact-SHA rereview finding / closed by independent
  golden recomputation, SingleFile compilation and full-slice exact-SHA review.
- Exact boundary: fix-1 candidate SHA-256
  `D4F022FA56C012DB325A0F1E11C84ACD5ED9FF4BD10B1BABD5E493CC0F972D15`
  makes two otherwise-equal Interface DTOs with reversed direct-interface targets,
  rehashes each, serializes both normally and asserts that their complete payloads
  differ. Because `TypeLayoutHash` itself covers relation ordinals and targets,
  the stored hash already differs before either payload is written. Complete-
  payload inequality can therefore remain true even if a future write-only bug
  target-sorts the emitted relation rows. Fresh report
  `.superpowers/sdd/b2-slice-1-fix1-review.md` returned 0 Critical / 1 Important /
  0 Minor on this exact boundary.
- Decision: retain the high-key-at-ordinal-zero normal-success case because it
  proves copy/canonicalize/validate does not reorder within the relation kind: a
  pre-validation target sort would make the stored TypeLayoutHash stale. Replace
  the contaminated inequality as write-stage evidence with an independently
  recomputed TypeSchema RecordId golden for the same explicit DTO. The final test
  requires a `479`-byte normal output and compares the common RecordId actual with
  literal content hash
  `1048a8e8b3e5833e6e600776e93f319fde7281879e8a4ae0bde5ec39effc080d`.
  The literal was not obtained from normal/physical serialization, a decoder, raw
  scanner, patcher or a new producer observation API.
- Close evidence/task impact:
  `reviews/b2-slice1-direct-interface-golden-recomputation.md` records three
  concordant independent byte/hash derivations,
  the exact `479`-byte payload, common record header, stored TypeLayoutHash and
  RecordId golden. The fix-2 artifact and exact candidate identity are recorded
  in IC-147. The final review independently traced canonicalization, validation
  and writer boundaries and approved the complete Slice-1 candidate with
  0 Critical / 0 Important / 0 Minor. This remains authority/compile evidence
  only until IC-145 permits focused RED.

## IC-150 — callable missing ABI was collapsed into the stable-key error

- Severity/state: Important semantic mismatch / closed by V1.2 KindPayload;
  consolidated linked/focused evidence is recorded in IC-216.
- Exact boundary: `ValidateProducerShape` currently checks
  `SignatureFunctionKey.Hash.IsZero() || ExpectedSignatureAbi.IsZero()` in one
  branch and returns `ZeroStableKey` for either condition. The frozen callable
  matrix requires `ZeroStableKey` only for a zero function key and
  `MissingExpectedAbi` for a zero expected signature ABI, for both Delegate and
  Funcdef.
- Decision: add four isolated normal-producer rows: zero key with ABI retained and
  zero ABI with key retained for each callable kind. Expected values remain
  literal; B3 must use the sole canonical-local rule owner rather than add another
  producer-only special case.
- Required evidence/task impact: complete-TU compile and exact-SHA review may
  approve test authority. Slice-2 candidate SHA-256
  `6408703A2A3DD6E981D92FAC97EAC20B0D85ACDD4F3CE13425D1F8A2EBD905F5`
  compiled in
  `Saved/Build/cache-b2-typeschema-producer-red-slice2-tu/20260809_025005_186_0a1e42ad/`;
  exact-SHA report `.superpowers/sdd/b2-slice-2-review.md`, SHA-256
  `D1EB6F393C1AE1ABF903CCE72FDD967C0CE6E18EF8B59263A67DFAE57A9034C5`,
  approved 0C/0I/0M. The truthful current RED and final GREEN now exist under
  IC-216; both callable kinds distinguish missing ABI from a zero stable key.

## IC-151 — Typedef producer accepted forms outside the primitive-only contract

- Severity/state: Important semantic gap / closed by V1.2 KindPayload;
  consolidated linked/focused evidence is recorded in IC-216.
- Exact boundary: the current producer rejects only Auto, and reports
  `InvalidPresence`; it otherwise delegates to generic DataType validation.
  Consequently Void, ScriptType/object, ObjectHandle-qualified,
  Reference-qualified and nonempty-subtype Typedef aliases may reach success.
  The frozen TypeSchema rule permits only one unqualified non-Void primitive and
  requires `InvalidQualifierCombination` for every listed invalid form.
- Decision: add six isolated normal-producer rows for Void, Auto, ScriptType,
  ObjectHandle, Reference and nonempty subtype-array mutations. The subtype form
  is hostile but DTO-representable; out-of-model raw encodings stay decoder-only.
- Required evidence/task impact: the exact candidate/artifact/review recorded in
  IC-150 approves the six Slice-2 test rows at 0C/0I/0M. Behavior closure waits
  the six literal results, cleared output, immutable caller input and the retained
  legal primitive descriptor regression are now covered by IC-216 behavior evidence.

## IC-152 — Enum producer hash acceptance omitted local ordinal/name replay

- Severity/state: Important semantic gap / closed by V1.2 Enum behavior; IC-217
  records current RED, shared-validator repair and final decoder GREEN.
- Exact boundary: current EnumAuthorityHash computation validates required name
  strings and canonical metadata, but does not replay declaration ordinals or
  reject duplicate canonical names. A malformed ordinal/name DTO can therefore
  be rehashed into a self-consistent producer success. B1 already freezes
  `DuplicateOrdinal`, `OrdinalGap` and duplicate-name `DuplicateKey` returned
  results; Slice 1 freezes Enum metadata duplicate/conflict and canonicalization.
- Decision: do not duplicate those accepted rows. Slice 2 adds the remaining
  empty-name `InvalidPresence`, signed MIN/MAX numeric-alias success and stale
  EnumAuthorityHash `DerivedHashMismatch` rows, then cites the retained B1/Slice-1
  witnesses as the complete local Enum set.
- Required evidence/task impact: the exact candidate/artifact/review recorded in
  IC-150 approves the surrounding Slice-2 Enum rows at 0C/0I/0M. IC-152 closes
  after the retained malformed rows execute against the shared local validator.
  IC-217 supplies that evidence without a second hash or semantic table.

## IC-153 — relation-to-LayoutInput target mismatch has no explicit literal

- Severity/state: authority ambiguity / closed by normative correction and fresh
  combined 0C/0I/0M authority rereview before Slice-3 assertions.
- Exact boundary: the TypeSchema matrix and layout authority freeze local field
  order and require exact pairing between BaseType/Base and CodeRoot/ShadowSuper+
  CodeSuper targets, but they do not explicitly name the returned local error for
  a well-formed LayoutInput reference whose kind/key/ABI differs from its required
  relation. `producer-b2-coverage-audit.md` lists
  `InvalidQualifierCombination` among role/pairing/range results, which is an
  inference rather than a row-level normative mapping.
- Decision: the owning matrix now selects `InvalidQualifierCombination` for two
  individually valid stored target tuples that disagree. Missing/extra roles or
  wrong optional masks remain `InvalidPresence`; malformed references retain
  common errors; dependency coverage remains later. Stored tuple equality is
  local, while resolved target/category/owner/ABI/code-root semantics remain
  ModuleGraph work. The B2 audit is synchronized and each affected producer row
  uses a direct literal.
- Close evidence/task impact: the exact amendment and rationale passed strict
  OpenSpec validation and fresh combined rereview
  `reviews/b2-slice3-authority-correction-rereview.md`, SHA-256
  `02C09AAD8C242E83BF455E8B934BB07D52646BCC30B12B31F077E6D6A8C2DCC3`,
  at 0 Critical / 0 Important / 0 Minor. Slice 3 may now use the direct literal;
  it must not create a computed error predicate. The read-only discovery report is
  `.superpowers/sdd/b2-slice-3-authority-audit.md`, SHA-256
  `F576A7C5252D72EB79154EF8AA9AC7855EF896CE4291C93BD85CD062662F0E9A`.

## IC-154 — forbidden relation kinds were misclassified at count two

- Severity/state: Important executable-authority defect / closed by exact-SHA
  fixture repair plus fresh combined 0C/0I/0M authority rereview.
- Exact boundary: the read-only audit's 165-cell table assigned
  `ConflictingKey` to two distinct targets for every relation kind, including
  kinds whose legal cardinality is zero. Independent review then found the same
  overgeneralization in the existing decoder Cartesian fixture
  `RelationKindsFormsCardinalitiesAndReferenceKindsAreCartesian`: its expected
  result selects `ConflictingKey` for every count-two non-interface relation,
  including forbidden Compose. The frozen matrix maps a disallowed relation
  kind/cardinality to `InvalidPresence`; `ConflictingKey` is the distinct-target
  result only for an allowed singleton (`0..1` or exactly `1`).
- Decision: the correction attachment freezes the four cardinality patterns
  `0..N`, `0..1`, exactly `1`, and forbidden. An identical duplicate is tested
  separately on a legal relation form as `DuplicateKey`. Wrong-reference-kind
  validation keeps its existing earlier precedence for nonzero rows.
- Evidence/task impact: the isolated fixture repair is exact SHA-256
  `AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`,
  plugin blob `4164f9f66e8f89915d13ae3dc25c131822925b1e`; complete-TU compile succeeded and
  independent review SHA-256
  `26C5D7F40B22928380C130732FAA2779C0F4B6A85A0456E64D97FDA63B3B22C8`
  returned 0 Critical / 0 Important / 0 Minor after all 495 cells matched. Fresh
  combined authority rereview SHA-256
  `02C09AAD8C242E83BF455E8B934BB07D52646BCC30B12B31F077E6D6A8C2DCC3`
  also returned 0 Critical / 0 Important / 0 Minor and permits Slice-3
  materialization. The repair adds no production semantic validator, alters no
  Runtime source and claims no focused behavior through IC-145.

## IC-155 — Compose capture disposition was ambiguous at archive boundary

- Severity/state: authority wording ambiguity / closed before Slice-3 source
  authoring.
- Exact boundary: the relation matrix said a producer seeing Compose returns
  NotCacheable, while its error table says disallowed relation kind/cardinality is
  `InvalidPresence`. `NotCacheable` is not an archive validation error.
- Decision: live capture observing Compose marks the module NotCacheable and emits
  no TypeSchema. If an explicit DTO/payload containing Compose reaches the normal
  serializer or decoder, it returns `InvalidPresence/LocalSemantic`. Both paths
  preserve valid V1 cardinality zero.
- Close evidence/task impact: the owning TypeSchema matrix and correction
  attachment now state the two boundaries explicitly. Slice 3 uses literal
  `InvalidPresence` for nonzero Compose DTO rows and does not simulate live capture.

## IC-156 — Slice-3 audit mechanical baseline/call counts were inconsistent

- Severity/state: packet-materialization bookkeeping defect / closed before
  Slice-3 assignment.
- Exact boundary: the audit's LayoutInput table explicitly lists Class+None
  without Base, Class+None with Base, ordinary UClass root, ordinary UClass
  derived, statics UClass, Struct+None, Struct+UStruct, Interface, Enum+None,
  Enum+UEnum, Delegate, Typedef and Funcdef: 13 legal baselines, although the prose
  calls them 12. Its `53 minimum` and relation `188 minimum` were also compiled
  before IC-154 corrected forbidden count-two results and do not constitute a
  stable acceptance count.
- Decision/evidence impact: the materialized Slice-3 packet explicitly enumerates
  all 13 legal LayoutInput baselines, all 165 relation form/kind/cardinality cells
  and each named extra row. Completion is proven by coordinate inventory and
  exact-SHA review, not the obsolete minimum-call totals. No normative wire/error
  behavior changes and no source was edited to close this bookkeeping issue.

## IC-157 — hash-precondition rows cannot use the valid-fixture finalizer

- Severity/state: Important test-packet defect / closed by corrected packet and
  fresh 0C/0I/0M rereview before source editing.
- Exact boundary: `FinalizeValidFixtureHashes` requires
  `ComputeLayoutInputHash(...).IsSuccess()` with `check`. Raw InputKind 0/4/255,
  zero Target StableKey and missing ExpectedAbi fail inside that helper, so nine
  intended Normal Producer rows would terminate during setup.
- Decision/evidence impact: each row starts from an already finalized legal
  baseline, mutates only the invalid field and retains the old LayoutInputHash and
  TypeLayoutHash. Normal serialization must return UnknownEnumValue, ZeroStableKey
  or MissingExpectedAbi before hash comparison. The distinct stale-hash row still
  mutates only LayoutInputHash. No test-local hash implementation is permitted.
  Close review SHA-256:
  `D7EFFB20EC2F8232732865FEB7D76D65A5047D7455AE2C9D1B993CB7081F54D9`.

## IC-158 — legal-baseline input witness count was overstated

- Severity/state: Important packet contradiction / closed by corrected packet and
  fresh 0C/0I/0M rereview.
- Exact boundary: 13 legal baseline calls contain five required input instances
  across four non-empty schemas: plain BaseType, root CodeRoot, derived
  BaseType+CodeRoot and StructHeader. The plan incorrectly said six positives.
- Decision/evidence impact: retain exactly 13 success calls and report 13 calls /
  five required instances; do not invent or duplicate a sixth witness.

## IC-159 — derived-UClass missing BaseType row was absent

- Severity/state: Important coverage omission / closed by corrected packet and
  fresh 0C/0I/0M rereview.
- Exact boundary: a positive derived schema with BaseType does not prove the
  derived form requires it. Plain Class+Base and ordinary derived UClass are
  distinct presence rows.
- Decision/evidence impact: missing-input coverage is exactly five calls: plain
  BaseType, derived BaseType, root CodeRoot, derived CodeRoot and StructHeader,
  each preserving the other required roles.

## IC-160 — required-role optional-mask inventory was incomplete

- Severity/state: Important coverage omission / closed by corrected packet and
  fresh 0C/0I/0M rereview.
- Exact boundary: a present input with neither optional is distinct from an absent
  input. The prior prose represented at most eight of twelve invalid masks.
- Decision/evidence impact: literal InvalidPresence rows are BaseType required 3
  against 0/1/2; root CodeRoot required 3 against 0/1/2; derived CodeRoot required
  2 against 0/1/3; StructHeader required 1 against 0/2/3. Whole-input absence stays
  in IC-159's five rows.

## IC-161 — generic pairing mutations did not prove both tuple fields and peers

- Severity/state: Important coverage omission / closed by corrected packet and
  fresh 0C/0I/0M rereview.
- Exact boundary: one mutation changing key+ABI cannot prove both are compared,
  and CodeRoot differing from two equal peers cannot prove both ShadowSuper and
  CodeSuper are checked. ReferenceKind cannot be isolated at pairing because its
  field-local error correctly wins earlier.
- Decision/evidence impact: eight literal InvalidQualifierCombination rows cover
  Base key-only/ABI-only; CodeRoot versus both peers key-only/ABI-only; only
  CodeSuper different key-only/ABI-only; and only ShadowSuper different
  key-only/ABI-only. Every reference remains individually valid.

## IC-162 — overflow and wrong-role fixtures needed exact C++/precedence shape

- Severity/state: Minor packet precision / closed by corrected packet and fresh
  0C/0I/0M rereview.
- Exact boundary: signed `MAX_int32 + 1` risks overflow/diagnostics, and replacing
  a role in the derived two-input baseline can introduce duplicate/conflict
  precedence.
- Decision/evidence impact: use `static_cast<uint32>(MAX_int32) + 1u` for all five
  overflow rows, with root CodeRoot owning its boundary witness. Use single-input
  plain Base, root CodeRoot and UStruct baselines for the three wrong-role
  replacements.

## IC-163 — rereview report was hashed before final handoff

- Severity/state: evidence-handoff race / closed without source edit.
- Exact boundary: root observed an approved report while its reviewer was still
  finishing the end-state section and briefly released the implementer against
  interim SHA `06B980...2081`. The implementer recomputed the file before editing,
  detected final bytes at another SHA and stopped. Brief, plan and TU remained
  exact and no source was edited.
- Decision/evidence impact: release was revoked until the reviewer sent FINAL and
  guaranteed no later report write. Final immutable rereview SHA-256 is
  `D7EFFB20EC2F8232732865FEB7D76D65A5047D7455AE2C9D1B993CB7081F54D9`,
  with 0C/0I/0M and true end-state brief/plan/TU hashes. Future review release
  uses the agent FINAL handoff, not mere report-file existence.

## IC-164 — Slice-3 local index lambdas failed auto return deduction

- Severity/state: compile-local defect / closed by minimal repair and fresh
  successful complete-TU rerun.
- Exact boundary: the first exact wrapper artifact
  `Saved/Build/cache-b2-typeschema-producer-red-slice3-tu/20260809_042152_347_e5b34b99/`
  reached exactly `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp` and
  returned process/wrapper `6/1`, `TimedOut=false`. C3487 at lines 7472 and 7486
  reported that `FindInputIndex` and `FindRelationIndex` deduced `int32` for found
  indexes but the anonymous `INDEX_NONE` enum for the not-found return.
- Decision/evidence impact: explicit `-> int32` was added to only those two
  method-local lambdas; all 195/100/295 rows, literals and counters were
  preserved. The fresh exact wrapper artifact
  `Saved/Build/cache-b2-typeschema-producer-red-slice3-tu/20260809_042228_503_9dce9428/`
  records exactly one `[1/1] Compile [x64]
  AngelscriptCacheTypeSchemaTests.cpp`, `TimedOut=false`, process/wrapper `0/0`
  and `Result: Succeeded`. The failed artifact remains syntax evidence, not RED
  behavior. The independent exact-candidate review is a separate Slice-3 release
  gate and does not reopen this compile-local issue.

## IC-165 — recorded blob IDs were not yet readable Git objects

- Severity/state: evidence-materialization gap / closed without source edit.
- Exact boundary: the Slice-2 authority and Slice-3 implementation report used
  read-only `git hash-object` identities. Before the exact Slice-3 review, both
  `git cat-file` lookups were absent, so an immutable object-to-object diff could
  not yet be executed even though the SHA-256 and blob IDs were recorded.
- Decision/evidence impact: the primary agent removed only current lines
  6876–7960 in memory. The reconstructed 514,861-byte predecessor independently
  reproduced SHA-256
  `AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`
  and blob `4164f9f66e8f89915d13ae3dc25c131822925b1e`. It then materialized that exact
  byte stream through `git hash-object -w --stdin` and materialized the unchanged
  candidate as blob `653f8b05ad7a398f151690d44647571aa50380e9`. Candidate SHA-256 before and after
  remained
  `3CC1A95A748106A05291CD0DE8D7B57ABCE61E807A8F89E2F4F204D6B23D2338`;
  neither operation changed the working tree, index, commit, branch or gitlink.
  `git diff` between the now-readable blobs proves exactly 1,085 insertions and
  zero deletions. Git-object materialization is review evidence only, not source
  publication or B2 completion.

## IC-166 — property stale hashes had two Slice owners

- Severity/state: Important packet ownership contradiction / closed before the
  Slice-4 ready brief.
- Exact boundary: `producer-b2-coverage-audit.md` section 4.7 listed stale
  `StorageLayoutHash` and `PropertyLayoutFingerprint` under the property/layout
  method, while section 4.12 and the eleven-method map assigned the stored-hash
  integration inventory to Slice 6's
  `NormalProducerUsesFrozenHashesAndNeverAcceptsResolvers`. Literal repetition
  would also duplicate the already approved stale `EnumAuthorityHash` and
  `LayoutInputHash` rows from Slices 2 and 3 if “all five” were read as five new
  Slice-6 calls.
- Decision/evidence impact: the five-hash list is a whole-B2 exactly-once
  inventory. Slice 2 owns stale EnumAuthorityHash; Slice 3 owns stale
  LayoutInputHash; Slice 6 owns stale StorageLayoutHash,
  PropertyLayoutFingerprint and final TypeLayoutHash. Slice 4 has `H=0`: it
  finalizes legal property DTOs, proves successful normal serialization, and for
  the same-terminal-size offset witness proves that legal and wrong DTOs produce
  unequal property/type hashes without deliberately submitting a stale stored
  hash. This keeps derived-hash precedence concentrated in Slice 6 and removes
  duplicate normal-producer calls.
- Research authority: `.superpowers/sdd/b2-slice-4-research.md`, final SHA-256
  `18045B2ABB5ED44B13B787CF3EFD85C932ED3F34B9F7DF01C6926A9E0E064237`.

## IC-167 — raw PrimitiveType values lacked a frozen normal-producer error

- Severity/state: Important semantic mismatch / open B2 RED and future B3 GREEN
  target; the packet literal itself is frozen.
- Exact boundary: `Primitive::Invalid=0` is a declared sentinel used for the
  absent union arm and a Primitive-kind DTO carrying it is `InvalidPresence`.
  Raw `13` and `255` are instead outside the frozen append-only `1..12` primitive
  enum. `record-wire-v1.md` states that unknown enum/tag values reject, and the
  private physical reader already reports `UnknownEnumValue` for raw values above
  12. Current normal `ValidateDataType` combines `<1 || >12` into
  `InvalidPresence`, so implementation behavior cannot be the oracle.
- Decision/evidence impact: Slice 4 adds exactly two literal normal-producer
  failures, raw `13` and raw `255`, both expecting `UnknownEnumValue`; raw `0`
  remains a separate `InvalidPresence` row. Start from finalized legal property
  baselines, mutate only the primitive enum and do not call
  `FinalizeValidFixtureHashes` after the invalid mutation. This raises the
  Slice-4 inventory from the contradiction-free 658-call core to the frozen
  660-call packet: 83 legal and 577 negative. B3 must later route producer and
  decoder through the shared enum/presence validation order; IC-167 closes only
  after focused GREEN proves the normal producer result.

## IC-168 — Slice-4 plan confused UStruct SkipReplication with Config

- Severity/state: Important executable-packet contradiction / closed by narrow
  plan/brief repair; fresh packet rereview required before implementation.
- Exact boundary: the first packet plan named UStruct `Skip` as the third
  owner-forbidden Region-C negative while its 16-positive list, research and
  frozen type matrix all permit UStruct SkipReplication (`0x00801` with
  HasUnrealProperty). The actual forbidden third state is Config (`0x08001`);
  Replicated `0x00401` and RepNotify `0x04401` with metadata are the other two.
  An implementer following the old text could duplicate the legal Skip cell as a
  negative and omit Config while still reporting 19 rows.
- Decision/evidence impact: rejected packet review
  `.superpowers/sdd/b2-slice-4-packet-review.md`, SHA-256
  `33C76F83B584DB63B8BEAC29606690BF1DFDFA41D4B9874B54E5B4BBE6417BE5`,
  returned 0 Critical / 1 Important / 0 Minor and HOLD. The executable plan now
  replaces only `Skip` with `Config`; the candidate brief expands the three
  UStruct negatives to exact masks `0x00401`, `0x04401` plus nonempty metadata,
  and `0x08001`. Region C remains 50 positive / 19 negative / 69 total; no
  Runtime/test source or normative authority changed. Release requires a fresh
  exact-input rereview at 0C/0I and reviewer FINAL.

## IC-169 — corrected Slice-4 brief retained the rejected plan SHA

- Severity/state: Important immutable-input contract defect / closed by a
  one-token SHA-pin refresh; fresh rereview still required before release.
- Exact boundary: IC-168 changed the executable plan SHA from
  `1900823269B6FA17CBBB01BC570FE1E50251BDD0605F9BD1082AA4BAA375FCB3` to
  `64112D126F1CD83E30BED9D95FD2C81F1D27DB678857132D00A875695832E178`,
  but the corrected candidate brief's immutable-input table still required the
  old value while also instructing the implementer to stop on any mismatch.
  Region A could therefore never legitimately start from that exact brief.
- Decision/evidence impact: first corrected-packet rereview
  `.superpowers/sdd/b2-slice-4-packet-rereview.md`, SHA-256
  `1D53F5D252676561329B407766DC5524474A7BACA4D4369EFCB4D940A557BFA0`,
  returned 0 Critical / 1 Important / 0 Minor and HOLD while confirming IC-168
  and the complete 83/577/660 packet had no other finding. Only the brief's plan
  SHA pin is replaced with `64112D...E178`; plan, research, routing audit,
  normative inputs and TypeSchema TU remain byte-identical. Release still waits
  for a fresh exact-input 0C/0I reviewer FINAL.

## IC-170 — Region-A Auto payload rows did not isolate their named faults

- Severity/state: Important test-authority isolation defect / closed by exact
  repair, clean complete-TU compile and fresh 0C/0I/0M review.
- Exact boundary: the first Region-A candidate was SHA-256
  `F55D1B975B1E13A6A1AE536DBACB7C1B4EF91288774B02B98D746164FD9D683E`.
  Its two Auto payload rows changed `DataTypeKind` to `Auto` but inherited
  `QualifierFlags == 0` from the Primitive `PlainStruct` baseline. Frozen wire
  authority requires Auto Kind and the Auto qualifier bit together. Both rows
  therefore reached the earlier Kind/bit agreement failure before the intended
  non-Invalid-Primitive and present-TypeReference payload faults. All three
  faults use `InvalidQualifierCombination`, so the expected literal alone could
  not reveal the missing coverage.
- Discovery evidence: independent exact-source report
  `.superpowers/sdd/b2-slice-4-region-a-review.md`, SHA-256
  `CD8DCCB9C16293894C9B4AF7C8C4CAEA89BA775065C94E6AC92BA43360ECDB9C`,
  returned 0 Critical / 1 Important / 0 Minor and HOLD. It approved the immutable
  +310/-0 source boundary, 7/40/47 arithmetic, all other expected literals and
  finalizer discipline, absence of Regions B–D, and the successful one-TU compile
  artifact `20260809_054713_556_404516b4`; the two Auto rows were its sole
  finding.
- Decision and required repair: set exactly
  `EAngelscriptCachedTypeQualifierFlags::Auto` on both Auto payload fixtures.
  Do not re-finalize either invalid fixture. The first row must then contain only
  its non-Invalid Primitive fault; the second only its present TypeReference
  fault. Keep the literal error and exact 7 success / 40 negative / 47 total
  inventory unchanged.
- Closure evidence: the repair added exactly two identical two-line Auto qualifier
  assignments, +4/-0 and +244 bytes. Repaired TU SHA/blob is
  `B3DA117B83CF89D92A1BB64B40DE58548465065717B29F56F594F9F0A5DD1711` /
  `8da8550bab9144bda65ba872712f571da829d579`; removing those four lines in
  memory reconstructs the rejected candidate exactly, while removing the whole
  314-line method reconstructs approved Slice 3. Artifact
  `20260809_060210_936_daa912b4` has process/wrapper `0/0`, one exact target-TU
  compile in each log and zero diagnostics. Repair report SHA-256 is
  `A567CFD0FB9ED2D328D13E50D307BD763398CD1087E4D9D9B96B2BAA2F96747E`.
  Fresh exact-source rereview
  `.superpowers/sdd/b2-slice-4-region-a-rereview.md`, SHA-256
  `A647CBFCFA6B87D8149CF2788C31862B116A59273F301659A7BE5C46C270ACCA`,
  returned 0 Critical / 0 Important / 0 Minor and RELEASE. Region B may now be
  explicitly released from this exact candidate; IC-145 still prohibits a linked
  or Automation claim.

## IC-171 — Region-D terminal AlignUp row duplicated the layout-size range fault

- Severity/state: Important test-authority first-error isolation defect / closed
  before the first Region-D wrapper run, with fresh final exact-blob approval.
- Exact boundary: the first Region-D source candidate set the terminal-AlignUp
  fixture's single property to offset zero, size `MAX_int32`, alignment one and
  aggregate alignment eight, but also stored
  `Layout.SemanticSize = uint64(MAX_int32) + 1`. The packet already owns a
  separate layout-scalar-above-INT32 `Overflow` row. Because top-level layout
  scalar range validation precedes property replay, the terminal fixture could
  fail for that earlier duplicated scalar reason rather than prove checked
  `AlignUp(MAX_int32, 8)` crosses maintained INT32 arithmetic.
- Discovery/decision: primary precompile source review stopped the Region-D
  wrapper before any artifact was created. Frozen exact-layout authority requires
  stored layout scalars to remain in range for this coordinate. Change only the
  stored SemanticSize to `MAX_int32`; then the final cursor is still
  `MAX_int32`, while terminal alignment computes 2,147,483,648 and independently
  returns literal `Overflow`.
- Closure evidence: inverse replacement reconstructs first D candidate SHA/blob
  `867B6453814152DA3C78654691DB8C4D7DEF495D5FFBA5CF358D0F150D817ECB` /
  `07e6921f5d29c29bd37552910df05a7bc4ddee60`; the repair is exactly one line,
  -12 bytes and zero LF. Final D candidate SHA is
  `9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`.
  Artifact `20260809_070957_972_ad87c6c3` has process/wrapper `0/0`, one target
  compile in each log and zero diagnostics. Final whole-Slice-4 review
  `.superpowers/sdd/b2-slice-4-final-review.md`, SHA-256
  `FB9CC81BDAF70A4F4650030886499FF4038BDE96D4A29BAF95800C5E21E9212A`,
  returned 0 Critical / 0 Important / 0 Minor and RELEASE. It independently
  confirms the repaired terminal coordinate, exact D 5/27/32 and 17/10 split,
  and the final 83/577/660 source/compile authority. IC-145 still forbids linked
  or Automation evidence.

## IC-172 — HasDefaultConstructor cannot be derived from a local BehaviorSlot

- Discovery: Slice-5 read-only research compared the frozen behavior matrix with
  the actual `FAngelscriptCachedBehaviorSlot` DTO before materializing a ready
  packet. The DTO contains only `BehaviorKind`, `SlotOrdinal`, `Target` and an
  optional `DeclaringOwner`; it contains no canonical parameter types, in/out
  modes, defaults or explicit default-constructor marker.
- Contradiction: `type-schema-matrix-v1.md` correctly assigns function-entity,
  parameter/default and ABI resolution to the ModuleSnapshot graph, but its local
  behavior wording and `producer-b2-coverage-audit.md` also ask the TypeSchema
  producer/decoder to prove that `HasDefaultConstructor` is bidirectionally equal
  to the unique zero-parameter Construct row. The approved Slice-1
  `NormalProducerRejectsHeaderStringsAndTypeFlagRulesAtomically` method contains
  three reverse Class/Struct/Delegate rows that clear `HasDefaultConstructor`
  from an opaque Construct fixture and expect failure. The existing
  `DefaultConstructorFlagAndConstructFactoryRowsAreBidirectional` decoder test
  likewise treats one opaque Construct target as proof of a default constructor.
- Failure mode: a type with exactly one parameterized constructor is locally
  indistinguishable from a type with exactly one zero-parameter constructor. A
  local `Construct => HasDefaultConstructor` rule therefore creates a false cache
  rejection; accepting the flag without graph resolution cannot prove it either.
- Required correction before Slice 5 source authoring:
  1. keep locally observable BehaviorKind/group/order/cardinality, target-reference
     shape and owner-presence/equality rules in TypeSchema;
  2. locally allow `HasDefaultConstructor=false` with one or more Construct rows,
     because all may be parameterized;
  3. treat `HasDefaultConstructor=true` with no Construct row (and, for Class, no
     Factory row) only as a locally knowable necessary-condition failure;
  4. assign the unique zero-parameter Construct, matching Class Factory signature,
     parameter/default equality and the reverse implication to ModuleSnapshot graph
     validation; and
  5. repair and freshly rereview the three approved Slice-1 reverse producer rows
     plus the existing decoder test instead of copying their unobservable
     assumption into the new Slice-5 method.
- Evidence state: independently confirmed during read-only Slice-5 research. No
  test or Runtime source changed; the exact Slice-4 SHA
  `9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`
  remains the source frontier. A reviewed authority correction and a fresh
  Slice-5 ready packet are required before implementation.

## IC-173 — zero-cardinality Behavior rows used unencoded ghost coordinates

- Discovery: mechanical Slice-5 source audit expanded the existing
  `AllSeventeenBehaviorKindsHaveTheFullLocalCartesianMatrix` loops. At
  `Cardinality == 0`, the fixture adds no `FAngelscriptCachedBehaviorSlot`, but
  `bExpected` still depends on the loop's BehaviorKind, Script/Environment target
  choice and four owner cases.
- Exact defect: the zero-cardinality branch executes `17 * 7 * 2 * 4 = 952`
  cases. Within one TypeKind those cases serialize the same empty behavior array,
  yet the dynamic predicate labels some success and others failure according to
  values absent from the DTO. No producer or decoder can observe those values.
- Required correction: an empty behavior set is represented by absence only and
  is tested as a legal baseline per actual type/form. Kind, target, owner,
  cardinality and alias expectations count only when one or more concrete rows
  encode those coordinates. The Slice-5 producer packet must use explicit
  represented coordinates and literal expected errors, not reuse the dynamic
  decoder predicate. The existing decoder Cartesian must be repaired or rerouted
  before it becomes executable behavior authority.
- Evidence state: no source edit or wrapper run occurred. IC-173 joins IC-172 as
  a precondition for a reviewable Slice-5 authority correction; Slice-4 SHA
  `9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`
  remains unchanged.

## IC-174 — Behavior owner equality was routed to both local and graph validation

- Discovery: the non-normative producer audit requests “local owner equality,”
  while the normative Behavior target table requires a script owner to be present
  and the two-stage Cartesian/graph split assigns exact declaration owner/module
  resolution to ModuleSnapshot graph. The retained decoder Cartesian admits self,
  other-local and other-module nonzero owner values locally.
- Released decision: ScriptFunction requires owner
  present/nonzero; EnvironmentSymbol requires owner absent. A nonzero script owner
  unequal to the enclosing TypeKey is local-success/graph-pending. Local equality
  is required only when CopyConstruct/CopyFactory must repeat the exact peer alias
  tuple. This flips 56 nonempty Cartesian cells compared with the audit wording.
- Evidence/task impact: the released four-file authority now uses this one split.
  Ready-packet and future exact-source review remain required; no source changed.

## IC-175 — statics sequence rules required forbidden look-ahead

- Discovery: the wire/local order validates OrderedMethods, VFT and Behaviors
  before Reflection, but StaticsClass is known only from later
  `ReflectionKind::UClass|ClassReflectionFlags::StaticsClass`. Enforcing statics
  emptiness inside an earlier sequence validator would inspect a later field to
  choose its result, contrary to the explicit no-look-ahead rule.
- Released decision: every earlier field performs only its
  form-independent row/scalar checks rather than assuming ordinary Class. After
  every field-local check through Dependencies, one reflection-form closure derives
  the TypeKind+Reflection form and applies the prior-field allowlists. A malformed
  row-local coordinate wins; otherwise a legal but forbidden statics array returns
  `InvalidPresence` at the first offending captured container in wire order.
- Evidence/task impact: the final authority patch freezes the closure point and
  existing captured-coordinate mapping. Source evidence remains pending.

## IC-176 — Method/VFT duplicate/order and owner first-error literals were incomplete

- Discovery: the matrix requires duplicate FunctionKey and complete-row reorder
  negatives but did not uniquely map all of them to literals; zero owner keys also
  overlap role predicates, and Behavior's optional owner has different inactive-
  value precedence from required Method/VFT owner fields.
- Released decisions:
  - any repeated FunctionKey inside one Method or VFT sequence, with distinct valid
    ordinals, is `DuplicateKey`; owner/ABI differences do not create a second local
    `ConflictingKey` coordinate;
  - duplicate ordinal wins `DuplicateOrdinal`, a non-exact ordinal set wins
    `OrdinalGap`, and an exact set stored out of ordinal position wins
    `NonCanonicalOrder`;
  - required Method/VFT owner zero is `ZeroStableKey` before role predicates;
  - Script Behavior owner absent is `InvalidPresence`, present-zero is
    `ZeroStableKey`; Environment Behavior owner present is `InvalidPresence`
    without interpreting the inactive value.
- Evidence/task impact: these choices retain the 121-call Method/VFT candidate
  rather than adding an unsupported duplicate/conflict submatrix. The exact
  normative patch received 0C/0I/0M release; packet/source review remains.

## IC-177 — flag/Behavior producer and decoder literals disagreed

- Discovery: approved Slice-1 producer rows use
  `InvalidQualifierCombination` for HasDefault/HasDestructor group coupling, while
  the retained decoder behavior tests hardcode `InvalidPresence` for the same
  HasDestructor and default-constructor directions. Producer normalization removes
  stage/offset, but it does not justify a different error enum.
- Released decision: form/cardinality/count failures remain
  `InvalidPresence` at BehaviorSlots. After those and all field-local checks pass,
  a flag/group parity contradiction is `InvalidQualifierCombination`: a set flag
  with no required group is captured at TypeSemanticFlags; clear HasDestructor
  with one Destruct row is captured at BehaviorSlots. The unobservable
  HasDefault=false+Construct reverse direction becomes local success and moves to
  graph after signature resolution.
- Evidence/task impact: the Slice-5 ready packet must repair the three approved
  Slice-1 default-constructor reverse rows and every retained decoder flag-coupling
  expectation affected by this unified rule, then obtain fresh exact-TU review.

## IC-178 — early field failures were allowed to carry a stale final hash

- Discovery: the first authority-correction proposal exempted raw enum, zero key,
  missing ABI, wrong reference kind and present-zero owner mutations from
  `FinalizeValidFixtureHashes`, arguing their earlier error would win. That leaves
  an independent stale TypeLayoutHash fault and trespasses on Slice 6's exactly-once
  stale-final-hash ownership.
- Decision/repair: every representable non-hash Method/VFT/Behavior mutation now
  closes/sorts the dependency coordinate as far as the same root fault permits and
  recomputes TypeLayoutHash. The helper is a consistency tool, never the expected
  legality oracle. The physical malformed-ordinal helper remains forbidden.
- Evidence state: repaired proposal SHA
  `429B182728277F7362BD72AC1AAAA52BCE17B4B0055AE33CD58D16DF61C47558`
  received a fresh 0 Critical / 2 Important / 1 Minor HOLD. The final-hash
  finding itself was accepted as closed; the later findings are IC-179/180.
  No test or Runtime source changed.

## IC-179 — closure diagnostics named containers absent from the captured API

- Severity/state: Important authority-coordinate gap / closed by exact normative
  transcription and 0C/0I/0M authority rereview.
- Exact boundary: the second proposal named `Relations`, `LayoutInputs`, `Layout`,
  `Properties`, `Methods`, `VFT` and `BehaviorSlots` as decoder capture targets.
  `EAngelscriptTypeSchemaCapturedField` contains no such top-level array-container
  values. It exposes top-level scalars plus per-row `Relation`, `LayoutInput`,
  `OrderedProperty`, `OrderedMethod`, `VirtualFunctionSlot`, `BehaviorSlot` and
  `ReflectedFunctionMember` coordinates. A missing required row has no physical
  row offset at all.
- Decision: a present forbidden/excess row uses its existing row field and lowest
  proving physical array index; layout scalar parity uses `LayoutExpectation`;
  semantic flags use `TypeSemanticFlags`; a missing row required by a
  `(TypeKind, ReflectionKind)` form uses the already captured `Reflection`
  discriminator. Class Construct/Factory count mismatch always has a real
  unmatched row and uses that row's physical `BehaviorSlot` index. A
  Base-relation-driven missing BaseType input remains in the later pairing phase
  and uses the requiring `Relation` row rather than the reflection fallback.
- Closure evidence/task impact: final proposal SHA
  `D48D94CF54288A09E12400AAA830A0063285D9AAE23D7E7F55E9DE9C746C18E1`
  received independent 0 Critical / 0 Important / 1 Minor RELEASE. The normative
  patch freezes this mapping for
  statics and every non-statics form, including ordinary UClass Shadow/Code roots,
  UStruct StructHeader, forbidden arrays, reflection strings and reflected-member
  presence. Slice-5 decoder expectations may not use an invented container or
  offset zero. Packet and exact-source review remain required before source work.

## IC-180 — Behavior optional owner was validated in two precedence phases

- Severity/state: Important first-error ambiguity / closed by exact normative
  transcription and 0C/0I/0M authority rereview.
- Exact boundary: proposal phase 2 claimed the entire target-selected optional
  owner arm while phase 4 also claimed owner presence. That left paired fixtures
  involving a missing ScriptFunction owner or present EnvironmentSymbol owner plus
  an ordinal fault with no unique winner, and risked interpreting an inactive
  EnvironmentSymbol owner value as `ZeroStableKey`.
- Decision: phase 2 validates Behavior target key/ABI and only a **present active**
  ScriptFunction owner value as nonzero. It does not validate the optional tag and
  never reads an EnvironmentSymbol owner value. After ordinal duplicate/gap/order,
  phase 4 validates the tag: ScriptFunction absent and EnvironmentSymbol present
  are `InvalidPresence`; Environment present-zero remains `InvalidPresence`.
  Therefore Script present-zero wins before ordinal faults, whereas both tag-shape
  faults lose to ordinal faults.
- Closure evidence/task impact: final proposal SHA
  `D48D94CF54288A09E12400AAA830A0063285D9AAE23D7E7F55E9DE9C746C18E1`
  received independent 0 Critical / 0 Important / 1 Minor RELEASE. The exact
  normative order, paired-winner table,
  producer calls and decoder captured-coordinate tests must all use this single
  split. Ready-packet review remains required; no source has changed.

## IC-181 — singleton excess rows were unreachable in reflection-form closure

- Severity/state: Minor proposal-transcription defect / closed in the released
  exact authority patch.
- Exact boundary: the released proposal's coordinate table listed “too many rows
  of a required singleton Relation kind” and the corresponding LayoutInput case
  as `ReflectionFormClosure` failures. The mandatory field-local canonical pass
  already sees a second identical singleton coordinate as `DuplicateKey`, or a
  second same-kind/different-target authority as `ConflictingKey`, at that second
  physical row. Closure cannot observe either case.
- Decision: the normative matrix, layout authority and wire authority explicitly
  say the second singleton row fails field-locally and never reaches closure.
  Closure coordinates retain only representable present-forbidden rows and
  absent-required form rows. The latter use `Reflection` because no absent-row
  offset exists.
- Evidence/task impact: final proposal review
  `reviews/b2-slice5-authority-correction-proposal-final-review.md` returned
  0 Critical / 0 Important / 1 Minor RELEASE with this mandatory transcription
  rule. The final authority-patch review returned 0C/0I/0M; ready-packet review is
  now the remaining pre-source gate.

## IC-182 — seven TypeKind empty baselines undercounted eleven legal forms

- Severity/state: Important ready-packet inventory invalidation / closed by the
  double-reviewed repair-2 packet.
- Exact boundary: Slice-5 research replaced 952 unencoded cardinality-zero ghost
  calls with seven empty baselines, one per TypeKind, and reported a contingent
  Behavior inventory of 1,967 calls. The released authority proposal and exact
  normative candidate require one empty Behavior array per **legal
  TypeKind+Reflection form**, including both ordinary/statics UClass and the
  None/reflected variants. The frozen form table has eleven legal forms, not seven.
- Decision: preserve the research counts only as historical discovery evidence;
  do not promote `121 + 1967 = 2088` into a ready packet. Candidate
  `b2-slice5-ready-packet.md` now enumerates all eleven forms and separates the
  represented nonempty, statics, focused and prior-repair ledgers. IC-184 proved
  that merely adding four empty successes to obtain 2,092 was still insufficient.
- Evidence/task impact: released packet
  `2B51C3601888B53DABDFB2C021605138113DF937773C2450DA653C43D47AF625`
  uses 2,115 new producer scenarios and received two independent 0C/0I/0M
  reviews. This closes packet authority only; source evidence is still pending.

## IC-183 — derived Dependency coverage was assigned to local and graph

- Severity/state: Important normative semantic-owner conflict / closed by the
  final exact atomic authority rereview.
- Exact boundary: `type-schema-matrix-v1.md` section 10 said graph owns exact
  derived Dependency coverage, while its section 11, both co-normative authorities
  and the normal-producer audit place locally derivable set equality in the local
  cross-field pass. Approved B1 producer rows already expect local
  `MissingCoverage`/`UnexpectedRecord`.
- Decision: Dependency row/reference/canonical structure is field-local. After
  reflection-form, copy-alias, flag and relation/input closures, TypeSchema local
  validation derives the exact Dependency set from its own DTO: missing is
  `MissingCoverage/LocalSemantic`, extra is `UnexpectedRecord/LocalSemantic`, and
  duplicate/conflict remains earlier. Graph resolves each locally exact target's
  existence/entity/owner/module/ABI and owns record/declaration coverage, not a
  second copy of DTO-derived set equality.
- Diagnostic boundary: a missing row has no public row coordinate and uses the
  physical Dependencies-array/enclosing-field error offset already frozen by
  decoder tests; an extra row uses its physical indexed Dependency row. Do not
  invent a public top-level captured container.
- Evidence/task impact: exact review
  `reviews/b2-slice5-authority-patch-review.md` rejected packet SHA
  `88B55F94470919BB5A01F151CF2F5653AB31D95686E9A463297D0C9D02EA31A3`
  with 0 Critical / 1 Important / 0 Minor. All four candidate identities and the
  packet must be refreshed and rereviewed before source work.
- First repair evidence: packet
  `32E72EE160E5E6E1ABB57B9533840037E17A896EECA13B3289F08EE8142CC2D8`
  correctly fixed the main order/error/offset paragraphs but fresh rereview
  `reviews/b2-slice5-authority-patch-rereview.md` still returned 0 Critical /
  1 Important / 0 Minor. Three surviving clauses said forbidden extra kinds fail
  graph validation, graph re-proves property ValueLayout dependency coverage, and
  graph TS-SCR-19 owns exact dependency-coverage indexes. Those clauses must become
  local extra-set rejection or graph dependency-target resolution respectively.

- Final evidence: released packet
  `b2-slice5-authority-patch.md`, SHA-256
  `0C978C15083B81EDCDF298881238C1CEEA2F4D92FB4A6CDB3D785D0B37E8A144`,
  and `reviews/b2-slice5-authority-patch-final-review.md`, SHA-256
  `06A8E9F91B2B6B4F0F18E57B6D551DAD4ED235C971A2DB9DF4A0D96645946D69`,
  received 0 Critical / 0 Important / 0 Minor RELEASE. Slice 5 closes exact
  dependencies in fixtures but adds no Dependency negative; Slice 6 retains the
  exactly-once negative method.

## IC-184 — historical focused Behavior ledger was arithmetically and semantically incomplete

- Severity/state: Important ready-packet inventory defect / closed by the exact
  double-RELEASE Slice-5 packet.
- Discovery: the historical research labelled one focused partition as 19 calls
  while listing `2 gaps + 2 duplicates + 2 reorders + 1 group disorder + 14
  singleton overflows`, which sums to 21. More importantly, the released normative
  matrix requires a gap and duplicate witness per BehaviorKind, four observable
  owner/ordinal winners, canonical Environment present-zero rejection, script
  CopyConstruct/CopyFactory no-peer failure and Environment-copy anti-alias
  controls. The old 41-call total cannot authorize source.
- Deduplication decision: the 14 singleton `0,1` overflow cases already exist in
  the 1,904-cell cardinality-two product and are not repeated. B1 owns Construct's
  first gap. Slice 5 adds gaps for the other sixteen kinds and duplicate `0,0` for
  all seventeen. Three ordinal-winning optional-owner pairs are embedded in named
  ListConstruct/AddRef/Release gap rows; Script present-zero/ordinal gap and
  canonical Environment present-zero remain separate. Environment copy no-peer
  successes remain in the product; four focused positives prove unrelated/equal-
  bytes Script peers do not create local aliasing.
- Final packet result: `b2-slice5-ready-packet.md` freezes 64 focused calls
  (`6 success / 58 failure`), 1,994 Behavior calls and 2,115 total producer calls.
  It intentionally retains one abstract-Class plus Construct/Factory cross-field
  success because the normative matrix explicitly forbids treating abstractness as
  local instantiability. Both final exact-file reviews returned 0C/0I/0M RELEASE.

## IC-185 — broad Behavior dependency reset can create a second root fault

- Severity/state: Important fixture-construction hazard / closed for Slice-5
  source and compile; linked behavior remains part of B2.
- Discovery: the existing decoder Cartesian clears Behavior slots and then removes
  every Declaration and EnvironmentAbi dependency. `MakeMinimalSchema(Delegate)`
  is actually `MakeCompleteDelegateSchema()` and retains an OrderedMethod and
  callable payload. Removing all Declaration rows can therefore delete a method-
  owned dependency rather than only a Behavior-exclusive dependency. Other legal
  reflected/form builders likewise retain Relation, Reflection or Layout-owned
  dependencies.
- Decision: every repaired decoder baseline and new Slice-5 fixture removes only
  references no longer reachable from any DTO source, adds the exact dependency
  for new Method/VFT/Behavior targets, merges cross-role duplicates, canonical-
  sorts and finalizes the containing hash. A mechanical fixture helper may assemble
  this set but cannot select expected legality or become a second semantic oracle.
- Evidence: the source adds reachability-based reconstruction helpers covering
  Relation, Layout, nested Property, Method, VFT, Behavior, callable, Typedef and
  Reflection references; the Behavior decoder region no longer contains the
  broad reset. Canonical sorting/finalization is shared mechanically and the
  complete test TU compiles in artifact
  `Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/20260809_103033_382_7db8e595`.
  Slice 6 still owns missing/extra/duplicate/conflicting Dependency negatives;
  IC-185 does not add such a Slice-5 negative call.

## IC-186 — decoder optional-owner diagnostics used the wrong captured field

- Severity/state: Important exact-packet defect / closed by repair-2 double
  RELEASE; exact-source evidence remains pending.
- Discovery: independent review of packet SHA
  `A06F117FF4556C01D9E78EB380736D32F0DBEEBA1287780C080FBF22D92C3FD7`
  found a blanket instruction to report present-row failures at `BehaviorSlot`.
  Released wire authority instead records Script present-zero and every
  Environment owner-present tag at `BehaviorDeclaringOwner`; only Script absence
  falls back to `BehaviorSlot` because the optional subfield is unset.
- Decision: the packet now separates Behavior row, target and declaring-owner
  captured fields and freezes the five paired-owner decoder results at physical
  PrimaryIndex `0` or `1`. Environment owner values remain inactive and are never
  interpreted as `ZeroStableKey`.
- Evidence: the rejected exact-file review is preserved at
  `reviews/b2-slice5-ready-packet-review-A06F117F.md`; both final reviews approve
  repair-2. Later exact-source review must still inspect every decoder literal.

## IC-187 — product success cells lacked a companion-state assembly contract

- Severity/state: Important executable-packet defect / closed by repair-2 double
  RELEASE; exact-source evidence remains pending.
- Discovery: the 101-success arithmetic was correct, but a primary Class
  Construct/Factory row alone violates equal counts; a legal Destruct row without
  `HasDestructor` violates parity; Script CopyConstruct/CopyFactory requires an
  exact peer; and the complete Delegate fixture carries pre-existing Behavior and
  non-Behavior dependencies. The four Environment anti-alias controls also need a
  count-matching Class Construct whenever they add a Script Factory peer.
- Decision: every product row begins from a Behavior-clean canonical baseline and
  carries a static companion recipe. The runner never derives expected legality.
  It preserves non-Behavior reachability, supplies equal Class groups, destructor
  flags and script-copy peers as required, merges dependencies, sorts and
  finalizes. Focused alias negatives mutate one coordinate from that valid state.
- Evidence: the rejected review records all hidden companion requirements and both
  final reviews approve repair-2. Later exact-source proof must still show that all
  101 positive coordinates reach local success without a second fault.

## IC-188 — only allowed compile wrapper was syntactically invalid PowerShell

- Severity/state: Important verification-gate defect / closed at packet authority;
  future complete-TU execution remains pending.
- Discovery: packet SHA `A06F...C3FD7` spelled its only permitted `-ExtraArgs`
  array with `\"` escapes. PowerShell does not use backslash for quote escaping;
  the expression failed parser probing with `Missing argument in parameter list`.
- Decision: the packet now uses
  `@("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')` exactly. This repair
  changes only future command authority and does not run the command in the
  OpenSpec-only round.
- Evidence: root and both final reviewers parser-checked the repaired wrapper. The
  source round must still execute it successfully before any compile claim.

## IC-189 — owner-absent Script Copy companion can steal the first diagnostic

- Severity/state: Important executable-packet defect / closed by repair-2 double
  RELEASE; exact-source evidence remains pending.
- Discovery: review of repair SHA
  `9E3222C92135C01BE4A8712BE26D9F982BD49C386AAD8764CAD3C4E607F38A6D`
  found that copying the primary owner into an exact Construct/Factory peer is
  wrong for owner-absent Script Copy coordinates. Canonical group order validates
  Construct before CopyConstruct and Factory before CopyFactory, so the earlier
  absent-owner peer returns `InvalidPresence` and the primary represented row is
  never observed. Delegate CopyConstruct also recreates a B1-owned absent-owner
  Construct shape.
- Decision: an owner-present-nonzero locally admitted Script Copy row receives its
  exact alias peer. An owner-absent primary receives no invalid earlier peer; its
  earlier companion state must remain owner-valid and count-balanced, or empty,
  so the primary Copy row is the first owner-tag failure. Static literal data, not
  an expectation oracle, chooses the recipe.
- Evidence: both rejected 9E3222 reviews preserve the discovery; both final
  repair-2 reviews approve the split recipe. Later source review must prove these
  owner-absent cells do not copy a B1 fixture or fail before the primary row.

## IC-190 — CopyFactory no-peer negative can be masked by Class count closure

- Severity/state: Important executable-packet defect / closed by repair-2 double
  RELEASE; exact-source evidence remains pending.
- Discovery: the first companion repair started Script CopyFactory from exact
  Factory plus balancing Construct, then told the no-peer negative to mutate only
  peer presence. Removing Factory alone leaves `Construct=1, Factory=0`, so
  ReflectionFormClosure returns `InvalidPresence` before script copy alias closure
  can return the required `InvalidQualifierCombination`.
- Decision: the no-peer fixture removes both the exact Factory and its solely
  balancing Construct, yielding valid `0/0`. Key/ABI/owner mismatch fixtures keep
  the balanced exact-peer baseline and mutate one tuple component. Dependencies
  are rebuilt, sorted and final hashes regenerated after either operation.
- Evidence: the rejected repair reviews are authority for the discovery; both
  final repair-2 reviews approve the `0/0` no-peer recipe. Exact-source proof is
  still required.

## IC-191 — logical Behavior owner field differs from the test wire span enum

- Severity/state: Compile-local test-coordinate defect / closed in the same
  source round.
- Exact boundary: Runtime capture authority names logical field
  `EAngelscriptTypeSchemaCapturedField::BehaviorDeclaringOwner`. The independent
  test wire span enum does not duplicate that member; it exposes
  `EAngelscriptCacheTypeSchemaTestField::BehaviorDeclaringOwnerOptionalTag`.
  After reading the optional tag, the scanner captures the owner hash through the
  same test field at the same physical primary row with `SecondaryIndex=1`.
- Discovery/evidence: the first complete-TU wrapper run failed with C2838/C2065
  at the invented test-enum member. Artifact:
  `Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/20260809_102901_365_9387a66e`.
  This was a source compilation failure, not a returned Runtime behavior RED.
- Decision: do not add or rename a Runtime/header field. Extend the test assertion
  helper to accept the secondary index and map logical owner diagnostics to
  `BehaviorDeclaringOwnerOptionalTag`, primary physical row, secondary `1`.
- Resolution/task impact: the exact wrapper rerun succeeded with process/wrapper
  exit `0/0` at
  `Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/20260809_103033_382_7db8e595`.
  Slice-5 source reaches Compile Frontier only; B2 remains open until linked
  focused Automation returns the expected result/output mismatches.

## IC-192 — exact CQTest method prefix omitted the test-class segment

- Severity/state: Verification-addressing defect / closed in the same session.
- Discovery: the first exact method run used
  `Angelscript.TestModule.Cache.Archive.TypeSchema.<Method>`, discovered zero tests
  and therefore provided no RED or GREEN evidence. CQTest publishes these methods
  beneath `FAngelscriptCacheTypeSchemaTests`.
- Decision: exact runs use
  `Angelscript.TestModule.Cache.Archive.TypeSchema.FAngelscriptCacheTypeSchemaTests.<Method>`.
  Prefix discovery count is checked before classifying any outcome.
- Evidence: the non-evidence run remains at
  `Saved/Tests/cache-b5-typeschema-physical-red/20260809_105534_514_b8713857`.
  Subsequent exact runs discover and execute the intended methods.
- Task impact: none on Runtime semantics; it prevents a zero-discovery run from
  being misreported as B2/B5/B6 evidence.

## IC-193 — fixed-width truncation reported the field start

- Severity/state: B5 physical diagnostic defect / closed and focused GREEN.
- Exact boundary: common `FReader::ReadFixed()` used its current field offset for
  `OutOfBounds`, while the frozen physical authority requires the first unavailable
  byte. For a truncated byte span this is exactly `Bytes.Num()`.
- Decision: retain the overflow-safe bounds predicate and report the available-byte
  count when the requested fixed range exceeds the input.
- Evidence: Runtime TU compile
  `Saved/Build/cache-b5-truncation-offset-runtime-tu/20260809_110310_515_e49cbe1f`
  and linked build
  `Saved/Build/cache-b5-truncation-offset-linked/20260809_110323_979_b263ea97`.
  The first rerun then exposed IC-194 rather than this coordinate mismatch.
- Task impact: B5 truncation coordinates now agree with the independent scanner.

## IC-194 — valid declared array with truncated payload was classified impossible

- Severity/state: B5 physical error-precedence defect / closed and focused GREEN.
- Exact boundary: after reading a representable, in-budget count,
  `ReadArrayCountAndReserve()` treated insufficient remaining payload bytes as
  `ImpossibleCount` at the count field. The count itself is possible; the archive
  is physically truncated.
- Decision: preserve `BudgetExceeded` for element limits, `ImpossibleCount` for
  values outside the addressable array range, and `Overflow` for multiplication.
  Only insufficient backing bytes becomes `OutOfBounds` at `Bytes.Num()`.
- Evidence: linked build
  `Saved/Build/cache-b5-array-truncation-linked/20260809_110535_826_a8d2b5a5`
  followed by 1/1 PASS at
  `Saved/Tests/cache-b5-truncation-boundaries-green-2/20260809_110557_312_8091027b`.
- Task impact: closes the last observed B5 one-byte-truncation failure.

## IC-195 — raw DataType optional-tag test used an incomplete coordinate

- Severity/state: Crash-level independent-test-authority defect / closed by a
  minimal test-only coordinate repair.
- Discovery: the raw enum/tag method crashed because the helper requested field
  `DataTypeTypeReferenceOptionalTag` at `(Primary=0, Secondary=INDEX_NONE)`, but
  both Runtime physical capture and the independent scanner identify Property
  DataType nodes as `(PropertyIndex, PreOrderNode)`. A temporary diagnostic build
  identified missing field `67` at `Primary=0`; it was reverted before the
  permanent change.
- Decision: extend `AssertRawTag` to forward an explicit secondary coordinate and
  address this tag at `(0, 0)`. Do not change Runtime wire/capture coordinates.
- Evidence: crash
  `Saved/Tests/cache-b5-raw-domains-red/20260809_110735_609_f0ec2a6d`, diagnostic
  build/run
  `Saved/Build/cache-b5-raw-span-diagnostic-linked/20260809_110932_426_9bb35446`
  and
  `Saved/Tests/cache-b5-raw-span-diagnostic/20260809_110952_966_52959757`, final
  linked build
  `Saved/Build/cache-b5-raw-coordinate-authority-linked/20260809_111213_253_ca0338bb`
  and 1/1 PASS
  `Saved/Tests/cache-b5-raw-domains-after-coordinate-fix/20260809_111228_730_e026fdb4`.
- Identity/task impact: old SHA
  `18A55226D0786BC0C9C7E120492D55A9DB487CBC0070A1612BE3AB1BE356D5F9`
  remains historical. Current authority SHA is
  `2ACBD5E2005141805586D2D04FFE815E72B564F38FAE203D9C92D8810023E5EB`,
  Git blob `1d9709a896e1b493b08fdbeeb94d740a7a0dbec7`, 680,785 bytes,
  15,695 LF, zero CR, final LF and 63 methods.

## IC-196 — Behavior canonical-local validation was absent on both entry paths

- Severity/state: Important shared-semantic defect / closed by the shared
  field-local/cross-field validator.
- Exact boundary: a Class `Construct` Behavior row with cardinality one,
  `ScriptFunction` target and absent declaring owner must fail
  `InvalidPresence/LocalSemantic` with output unpublished. Both the private decoder
  and normal producer accepted/published it because `ValidateProducerShape()`
  did not validate Behavior groups.
- Trustworthy RED evidence: decoder method
  `AllSeventeenBehaviorKindsUseRepresentedNonemptyRowsAndElevenEmptyForms` fails
  normally at
  `Saved/Tests/cache-b5-behavior-kinds-red/20260809_105855_049_5c3939e3`;
  producer method
  `NormalProducerRejectsBehaviorGroupsOwnersFlagsAndAliasesAtomically` fails
  normally at
  `Saved/Tests/cache-b2-behavior-producer-red/20260809_111447_046_077c5b75`.
  Neither failure is a missing symbol, check, crash or timeout.
- Decision: implement one canonical-local validator used by normal serialization
  and private decoding after physical read but before publication/current-resolver
  stages. It owns only frozen local semantics; graph truth stays in B11.
- Closure evidence/task impact: all eleven `NormalProducer...` methods executed to
  close B2 RED coverage. The shared producer/decoder Behavior set is `5/5` GREEN
  at
  `Saved/Tests/cache-b3-b6-behavior-phase-split-green-2/20260809_120235_410_1be0ff56`;
  B3/B6 remain open only for other families.

## IC-197 — planned eleven-method producer authority materialized as nine methods

- Severity/state: Important RED-coverage gap / closed; B2 is now complete at its
  trustworthy RED-authority scope.
- Discovery: the first linked `NormalProducer` prefix discovered only nine
  methods. The released audit required eleven distinct methods; reflection had
  remained under a generic local-semantics name and Dependency coverage plus
  frozen-hash/resolver independence had no executable method.
- Decision: rename the generic method to the exact reflection authority name and
  add the two missing methods without creating a test-side production resolver.
  The frozen-hash method asserts the exact resolver-free producer signature and
  literal precomputed hashes; the Dependency method owns local DTO-derived set
  coverage and conflict cases.
- Evidence/task impact: the repaired prefix at
  `Saved/Tests/cache-b2-eleven-normal-producer-red/20260809_113425_474_134b2368`
  discovered all eleven, passed one, failed ten, skipped zero and had no crash,
  check, unresolved symbol or timeout. That trustworthy mixed RED closes B2;
  later B3 work may legitimately turn individual methods GREEN.

## IC-198 — invalid metadata fixtures invoked the valid-fixture finalizer and self-aliased TArray adds

- Severity/state: Crash-level test-authority defects / closed by test-only fixture
  repairs.
- Discovery: the complete producer prefix first finalized a deliberately
  duplicate/conflicting metadata fixture, causing the derived-hash helper to
  reject it before the named producer assertion. The next run passed an element
  from a `TArray` back into `Add()` on that same array, tripping UE 5.8's
  self-alias guard during possible reallocation.
- Decision: metadata duplicate/conflict rows retain the last valid frozen hashes
  and never call `FinalizeValidFixtureHashes`; seven self-alias mutations now
  take explicit value copies before array growth. Production semantics were not
  changed for either repair.
- Evidence: failures are preserved at
  `Saved/Tests/cache-b2-typeschema-normal-producer-red/20260809_112156_494_e74aeb06`
  and
  `Saved/Tests/cache-b2-typeschema-normal-producer-red-2/20260809_112440_175_e2c33672`;
  repaired linked builds are
  `Saved/Build/cache-b2-metadata-fixture-authority-linked/20260809_112418_163_99c1a7f3`
  and
  `Saved/Build/cache-b2-container-alias-fixture-linked/20260809_112608_167_648b41f5`.

## IC-199 — physical test snapshot dereferenced a deliberately absent required union arm

- Severity/state: Crash-level test infrastructure defect / closed defensively.
- Exact boundary: `SerializeTypeSchemaPhysicalForTests` is intentionally able to
  snapshot malformed DTOs before and after the normal producer call. It
  dereferenced an unset Enum payload in the `Enum without required arm` negative,
  so the test never reached the producer result.
- Decision: the test-only physical writer emits deterministic zero/default bytes
  for absent Enum, Callable and Typedef arms. The normal producer still rejects
  the missing arm before publication; this does not create a permissive runtime
  wire form.
- Evidence: crash
  `Saved/Tests/cache-b2-typeschema-normal-producer-red-3/20260809_112628_944_46283db9`,
  linked repair
  `Saved/Build/cache-b2-physical-missing-arm-safe-linked/20260809_112843_001_3d999a6a`,
  then a stable nine-method `0/9` RED at
  `Saved/Tests/cache-b2-typeschema-normal-producer-red-4/20260809_112858_084_e909c532`.

## IC-200 — shared semantic errors had no exact physical-coordinate channel

- Severity/state: Important decoder-diagnostic gap / closed for the shared
  Behavior slice; remaining fields continue under B6.
- Exact boundary: the shared validator correctly returned the Behavior error, but
  decoder local validation could only guess an offset from the error enum and
  fell back to `KindPayload` byte `362` instead of Behavior byte `188`.
- Decision: `ValidateProducerShape` accepts an internal optional failure
  coordinate. Producer calls keep `nullptr` and normalized byte zero; decoder
  calls receive the logical field/physical indices and resolve them through all
  retained offset groups. Behavior row, target and optional owner failures now
  share one semantic owner while retaining entry-specific presentation.
- Evidence: diagnostic RED
  `Saved/Tests/cache-b6-behavior-offset-diagnostic/20260809_114254_538_d84d0cc7`,
  builds
  `Saved/Build/cache-b6-exact-behavior-coordinate-linked/20260809_114857_000_d2370fdf`
  and
  `Saved/Build/cache-b6-behavior-owner-precedence-linked/20260809_115058_234_e281d072`.

## IC-201 — statics decoder assertion selected the fixture's primary row instead of the first physical row

- Severity/state: Important exact-coordinate authority conflict / closed by a
  test-only correction to the already-frozen normative rule.
- Discovery: after the represented Behavior product passed, a statics Factory
  fixture expected its requested row even though a mechanically generated
  Construct companion sorted before it. The normative matrix and released packet
  both require reflection-form closure to reject the lowest physical forbidden
  Behavior row after all row-local checks.
- Decision: expect physical index zero for the seventeen canonical statics
  negatives. Runtime does not learn test-only primary/companion concepts.
- Evidence: mismatch
  `Saved/Tests/cache-b6-behavior-exact-coordinate-green-2/20260809_115113_787_a5561895`,
  linked repair
  `Saved/Build/cache-b6-statics-coordinate-authority-linked/20260809_115241_032_c7cb2c56`,
  followed by the full product method GREEN at
  `Saved/Tests/cache-b6-behavior-product-green/20260809_115259_085_64aeb7d9`.

## IC-202 — group reorder and Class count diagnostics selected the detection row, not the proving row

- Severity/state: Important deterministic-coordinate mismatch / closed.
- Exact boundary: `[Copy, Construct...]` is detected when the second row is read,
  but the first physical row is the earliest row already out of canonical
  position. Class `2/1` or `1/2` count closure likewise requires the first
  unmatched ordinal, not the first Construct/Factory row.
- Decision: a decreasing BehaviorKind reports the preceding physical row; Class
  count closure selects Construct ordinal `FactoryCount` or Factory ordinal
  `ConstructCount`. Duplicate/gap coordinates retain their separately frozen
  precedence.
- Evidence: `3/4` intermediate run
  `Saved/Tests/cache-b6-behavior-four-method-focused/20260809_115412_204_c522bd7e`,
  linked repair
  `Saved/Build/cache-b6-behavior-proving-row-linked/20260809_115546_493_00d8acad`,
  then decoder Behavior `4/4` GREEN at
  `Saved/Tests/cache-b6-behavior-four-method-green/20260809_115600_913_d9cd757e`.

## IC-203 — the first shared Behavior implementation violated no-look-ahead phase ordering

- Severity/state: Important architecture defect / closed by phase separation.
- Discovery: a behaviorally green first pass inspected the later Reflection
  `StaticsClass` discriminator and applied singleton/count/alias/flag closure
  inside the earlier Behavior field pass, before Dependencies. That contradicted
  IC-175 and could mask a later field-local error.
- Decision: split the sole shared implementation into
  `ValidateBehaviorFieldLocal` and `ValidateBehaviorCrossFieldClosure`. The first
  owns raw/reference/owner/ordinal/TypeKind-local rows without Reflection
  look-ahead. The second runs only after Dependencies field-local validation and
  owns statics, cardinality, count, alias and flag coupling.
- Evidence: linked phase split
  `Saved/Build/cache-b3-b6-behavior-phase-split-linked/20260809_120038_120_7f73729d`.
  The first focused rerun exposed IC-204 rather than a Runtime crash.

## IC-204 — Copy ABI alias negative is masked by a later-field Dependency conflict

- Severity/state: Important unreachable test literal / closed consistently with
  the frozen field-local-before-cross-field order.
- Exact boundary: changing only a Copy row's `ExpectedAbi` while retaining an
  otherwise equal peer StableKey necessarily creates two Dependency rows with the
  same role/kind/key and different ABI. Dependencies therefore return
  `ConflictingKey` before script-copy alias closure; the old expected
  `InvalidQualifierCombination` was unreachable for both copy kinds.
- Decision: keep key, owner and no-peer cases as direct alias-closure proofs, but
  classify ABI mismatch as the earlier Dependency conflict. Do not move alias
  closure forward or discard required Dependency coverage to satisfy the fixture.
- Evidence: phase-split `4/5` run
  `Saved/Tests/cache-b3-b6-behavior-phase-split-green/20260809_120053_814_b6200660`,
  linked expectation repair
  `Saved/Build/cache-b3-b6-dependency-before-alias-linked/20260809_120215_108_6bcca30a`,
  final shared producer/decoder Behavior `5/5` GREEN at
  `Saved/Tests/cache-b3-b6-behavior-phase-split-green-2/20260809_120235_410_1be0ff56`.

## IC-205 — header/flag RED exposed three malformed-fixture observation defects

- Severity/state: Important test-authority defect / closed without relaxing the
  normal producer.
- Exact boundary: the first `Header/String/TypeSemanticFlags` implementation run
  left three non-production mismatches. `AppendChar(0)` followed by `Append` did
  not retain an embedded NUL inside `FString`; the physical trace scanner rejected
  an intentionally unknown TypeKind before it could snapshot the malformed DTO;
  and the Delegate minimal fixture already owned Construct/Copy rows, so the
  negative `HasDefaultConstructor requires Construct` case was not behavior-free.
- Decision: insert NUL directly into the owned character array before the final
  terminator; treat an unknown discriminator as an empty arm only in both
  test-observation scanners; and clear behavior-owned rows/dependencies before
  restoring the exact flags under test. Normal serialization still rejects the
  unknown TypeKind and embedded NUL before publishing bytes. No valid Delegate
  form was made illegal.
- Evidence: initial focused RED
  `Saved/Tests/cache-b3-header-flags-focused-red/20260809_120658_149_86e24771`,
  intermediate failing run
  `Saved/Tests/cache-b3-header-flags-focused-green-2/20260809_121333_022_296a52ea`,
  linked repair
  `Saved/Build/cache-b3-header-flags-fixture-fix2-linked/20260809_121449_770_bbe0d936`,
  and final focused `1/1` GREEN
  `Saved/Tests/cache-b3-header-flags-focused-green-3/20260809_121508_408_8012ea2b`.
  The complete producer prefix then reports `3/11` GREEN at
  `Saved/Tests/cache-b3-normal-producer-progress-header-flags/20260809_121545_510_187f063f`,
  while B5 remains `5/5` GREEN at
  `Saved/Tests/cache-b5-physical-after-unknown-kind-green/20260809_121630_317_2699ef2d`.
- Task impact: advances B3 through the Header/String/TypeSemanticFlags family but
  does not close B3 or B6; eight producer families and their decoder coordinates
  remain.

## IC-206 — Relations product exposed two earlier Dependency failures and one verification-wrapper timeout

- Severity/state: Important executable-authority and verification-discipline
  findings / closed; no Runtime semantic relaxation.
- Exact boundary: the first 495-cell Relations decoder product reached
  `NonCanonicalOrder` at Dependencies byte `338` instead of the intended
  Relation row byte `136` because the test fixture sorted dependencies only by
  role and stable key. After switching the fixture to the production canonical
  comparator, the Statics forbidden-Shadow cell reached `DuplicateKey` at the
  same Dependency coordinate because it reused the valid Code environment
  target. The Shadow/Code same-target companion is required only for ordinary
  `UClass`, not Statics. Both errors correctly preceded Relations cross-field
  closure under the frozen field-local-before-cross-field order.
- Decision: keep Runtime ordering and precedence unchanged. Canonicalize fixture
  dependencies with `CompareDependencies` and create the Shadow/Code companion
  only for ordinary `UClass`. Add bounded structured logs: producer reports
  `165 matrix + 30 focused = 195` scenarios (including 16 wrong-reference
  checks); decoder reports `495` Cartesian cells with `167` expected successes
  and `328` expected failures. Per-cell detail is emitted only on assertion
  failure to avoid log flooding.
- Test-selection note: an intermediate five-method Behavior command accidentally
  included the future `MethodVftBehaviorAndReflectedMemberSequencesStayIndependent`
  backlog and therefore reported `4/5`. The correct historical Behavior set was
  rerun and remains `5/5`; this was selection error, not a Behavior regression.
- Wrapper note: the first post-Relations B5 command was launched through a tool
  with a five-second parent timeout. UE continued and wrote five successful test
  results plus `Report/index.json`, but the killed parent could not write
  `Summary.json`. The identical command was rerun with a 60-second wrapper window
  and produced the standard `5/5` summary. This is a harness-invocation issue,
  not a product failure.
- Evidence: Cartesian diagnostics
  `Saved/Tests/cache-b6-relations-cartesian-error-context/20260809_124426_588_66f1f961`
  and
  `Saved/Tests/cache-b6-relations-cartesian-green/20260809_124557_194_76c338a3`;
  final producer/decoder Relations `5/5` GREEN at
  `Saved/Tests/cache-b3-b6-relations-structured-green/20260809_125251_480_9d10a235`;
  full producer prefix `4/11` at
  `Saved/Tests/cache-b3-normal-producer-progress-relations/20260809_124905_758_a5c519a1`;
  corrected Behavior `5/5` at
  `Saved/Tests/cache-b3-b6-behavior-after-relations-green-2/20260809_125105_450_15079206`;
  standard B5 rerun `5/5` at
  `Saved/Tests/cache-b5-physical-after-relations-green-2/20260809_125645_939_761a4a12`.
- Task impact: advances the Relations family of B3/B6 but does not close either
  task. `LayoutInputs` is next; B7 hashes remain deferred until its local
  role/presence/pairing semantics are complete.

## IC-207 — LayoutInputs executable product corrected phase and coordinate assumptions

- Severity/state: Important executable-authority findings / closed; shared Runtime
  validation implemented without a producer-only rule table.
- Exact boundary: the focused normal-producer RED executed all `100` frozen
  scenarios. After the shared validator landed, two nominal pairing cases reached
  the earlier Dependencies `ConflictingKey` because their `ExpectedAbi` differed;
  this is the frozen field-local-before-cross-field winner. Decoder execution then
  exposed three stale coordinate assumptions: changing only a BaseType role while
  retaining its ScriptType target is `WrongReferenceKind` at that LayoutInput row;
  a missing BaseType is proven by the requiring Base Relation row; missing
  CodeRoot/StructHeader is proven by Reflection; and duplicate/conflicting
  singleton inputs use the second physical LayoutInput row.
- Decision: preserve Runtime phase order. The producer inventory now names six
  reachable pairing failures plus two Dependency-precedence controls. Use one
  shared field-local/cross-field validator for raw kind, reference kind, optional
  contribution masks, range/alignment, stable row hash, order/singleton closure,
  form presence and Relation pairing. Producer failures remain normalized while
  decoder failures consume the shared logical coordinate.
- Logging: the producer emits a bounded start/end category ledger for all `100`
  calls. Decoder logs expose `36` role/mask/target/missing cells, `5` focused
  presence cells and `11` exact form/pair/order/hash failures without printing
  every passing assertion.
- Evidence: trustworthy RED
  `Saved/Tests/cache-b3-layoutinputs-focused-red/20260809_130126_064_0201a885`;
  precedence diagnostic
  `Saved/Tests/cache-b3-layoutinputs-focused-post-shared/20260809_130718_990_a176b40b`;
  producer GREEN
  `Saved/Tests/cache-b3-layoutinputs-producer-focused-green/20260809_130841_024_f16a85b7`;
  decoder diagnostics/final
  `Saved/Tests/cache-b6-layoutinputs-two-method-diagnostic/20260809_130919_336_c7cdde94`
  and
  `Saved/Tests/cache-b6-layoutinputs-two-method-green/20260809_131126_538_dc701212`;
  final combined `4/4`
  `Saved/Tests/cache-b3-b6-layoutinputs-structured-final/20260809_132735_879_327c67af`.
- Task impact: advances the LayoutInputs family of B3/B6. B7 remains open because
  current-layout resolution, property/enum/final hash checkpoints and prospective
  layout consumption are separate later work.

## IC-208 — LayoutInput duplicate test self-aliased a growing TArray

- Severity/state: Test-harness crash / closed by a test-only lifetime repair.
- Exact boundary: `LayoutInputFormPairingAndSingletonFailuresUseExactRows` used
  `Invalid.LayoutInputs.Add(Invalid.LayoutInputs[0])`. Array growth invalidated the
  referenced element and triggered a UE container assertion before the decoder was
  called. Artifact
  `Saved/Tests/cache-b6-layoutinputs-closure-focused/20260809_131500_371_7f5b62dd`
  exited `3` without an Automation report; the assertion points to test line
  `11828` in that source revision.
- Decision: copy the source row to a local value before `Add`. Do not weaken the
  Runtime duplicate/conflict rules and do not count the crash as semantic RED.
- Evidence: test-only linked build
  `Saved/Build/cache-b6-layoutinputs-self-alias-repair-linked/20260809_131557_048_36463e73`;
  repaired exact method `1/1`
  `Saved/Tests/cache-b6-layoutinputs-closure-focused-2/20260809_131612_389_35e4cb36`;
  final combined evidence is the IC-207 `4/4` artifact.
- Task impact: no production behavior change; closes the executable-test blocker
  for the eleven exact LayoutInput closure cases.

## IC-209 — Relations Cartesian fixture accumulated LayoutInput faults after the new validator

- Severity/state: Cross-family regression-fixture isolation defect / closed; two
  exploratory Runtime changes were reverted before final evidence.
- Exact boundary: the first post-LayoutInputs 15-method regression was `14/15` at
  `Saved/Tests/cache-b3-b5-b6-after-layoutinputs-regression-green/20260809_131733_545_c1f671a4`.
  The old Relations Cartesian fixture created one LayoutInput per injected Base or
  ordinary Code relation, including wrong-reference and cardinality-two cases,
  and did not regenerate hashes for expected-invalid schemas. The intended
  Relation fault therefore coexisted with wrong-role, duplicate or stale-hash
  LayoutInput faults. Two exploratory runs that moved invariant target/cardinality
  checks into Relations field-local validation failed at successive cells:
  `Saved/Tests/cache-b6-relations-intrinsic-target-coordinate-green/20260809_132126_150_b75f42f6`
  and
  `Saved/Tests/cache-b6-relations-intrinsic-rules-green/20260809_132300_063_413125f2`.
  The second proved that broad early target validation would incorrectly replace a
  Reflection-selected forbidden-form `InvalidPresence` with `WrongReferenceKind`.
- Decision: revert both exploratory Runtime changes and retain the frozen
  field-local-before-cross-field architecture. Repair only the fixture: create at
  most one canonical companion LayoutInput, substitute a role-valid placeholder
  target when the Relation deliberately has a wrong reference kind, sort the
  inputs and recompute derived hashes for the malformed-but-physically-consistent
  fixture. Each Cartesian cell again contains only the intended Relation fault.
- Evidence: final linked build
  `Saved/Build/cache-b6-relations-isolated-layout-fixture-linked/20260809_132607_778_17d405af`;
  exact 495-cell decoder `1/1` with `167` success and `328` expected failure at
  `Saved/Tests/cache-b6-relations-isolated-layout-fixture-green/20260809_132624_956_445b1450`;
  full Relations/Behavior/B5 regression `15/15` at
  `Saved/Tests/cache-b3-b5-b6-after-layoutinputs-regression-final/20260809_132701_941_ccd52550`.
- Task impact: preserves Relations and B5/Behavior evidence while allowing the
  LayoutInputs family to remain enabled. No Runtime relaxation or phase reorder
  survives in the final source.

## IC-210 — Dependency authority text conflated script inheritance and environment ABI

- Severity/state: Normative wording conflict / closed before Runtime implementation.
- Exact boundary: `type-schema-matrix-v1.md` said every Relation emitted an
  `Inheritance` dependency, while approved ordinary/statics `UClass` fixtures,
  LayoutInput authority and all existing dependency builders classify a
  Relation by its stored target domain. A ScriptType Base/Interface target is an
  inheritance edge; an EnvironmentSymbol ShadowSuper/CodeSuper target is an
  environment ABI edge. Treating both as `Inheritance` would reject the current
  legal fixtures and blur graph invalidation semantics.
- Decision: the stored target domain is the sole mapping authority:
  `ScriptType -> Inheritance`, `EnvironmentSymbol -> EnvironmentAbi`. BaseType
  reuses the former row; CodeRoot and StructHeader reuse the latter. No new wire
  enum, duplicate LayoutInput dependency or compatibility behavior is added.
- Required evidence: the focused dependency RED at
  `Saved/Tests/cache-b3-dependency-focused-red/20260809_134146_859_10784fe3`
  executes the intended test normally and demonstrates missing/extra closure is
  not yet implemented. GREEN evidence must cover both legal relation domains,
  exact missing and extra rows, the eleven-kind allowed-set boundary and retained
  error coordinates.
- Task impact: unblocks the Dependency vertical slice of B3/B6. It does not
  authorize B7 current-layout resolution, graph lookup or any Editor/runtime
  Cache service work.

## IC-211 — Horizontal execution gates delayed the first real Cache loop and blurred candidate authority

- Severity/state: Execution-architecture defect / closed in OpenSpec; Runtime
  implementation remains governed by V0–V7 evidence.
- Exact boundary: the superseded plan required the complete B record/factory/graph
  milestone before Pack/Manifest, then the complete Store before Source/Compiler
  integration. Its status explicitly kept Store, compiler, service, PIE and package
  work outside the current critical path. Separately, the exact-warm wording grouped
  raw/direct inputs with include/generated/effective-conditional data that may
  require preprocessing, which could be read as rerunning the preprocessor before a
  zero-preprocess lookup. The external sccache comparison also transferred a mature
  two-phase candidate pattern without sufficiently distinguishing its translation-
  unit granularity from this project's AS function/VM/StaticJIT composition.
- Decision: preserve the complete function-level target—StableFunctionKey,
  FunctionInputDigest, FunctionBody and StaticJIT mapping—but reorganize execution
  into V0–V7 vertical checkpoints. DirectSourceInputs select a bounded persisted
  preprocess dependency candidate; candidate mismatch enters the existing
  authoritative frontend. A forced-clean compile is the fallback and equivalence
  oracle, while V5 still requires real per-invocation compiler hits. TypeSchema
  Dependencies remain thin record-self-consistency/graph inputs, not a source
  classifier. The previous plan/tasks/status are byte-preserved under
  `history/pre-vertical-refactor-2026-08-09/`.
- Required evidence: strict OpenSpec validation, history copy hash verification and
  link/task/traceability consistency for V0.3. Runtime behavior is not credited by
  this documentation change; V1–V7 retain their named build/test/integration gates.
- Task impact: replaces horizontal B/C/D/E/F/G execution mapping with V0–V7 and
  permits pure Pack/Store work to start at its independent boundary without
  bypassing selected-module decoder/graph/VM validation. No stable identity, wire,
  error number, publication or StaticJIT provider contract is removed.

## IC-212 — Split Dependency fixture self-aliased a TArray Add and crashed before validation

- Severity/state: Test-fixture execution blocker / closed.
- Exact boundary: the first linked producer run at
  `Saved/Tests/cache-v11-dependency-producer-green/20260809_150058_573_3400d103`
  discovered the intended one test, then UE 5.8 asserted in `TArray::Add` at
  `AngelscriptCacheTypeSchemaDependencyTests.cpp:296`. The argument was
  `Invalid.Dependencies[0]` from the same array being modified, so no Cache
  producer validation executed and the process exited `3`.
- Decision: copy the dependency to a local value before `Add`; do not change Runtime
  validation or suppress the container assertion. This is the same fixture class as
  IC-208, now recorded at the new focused-file boundary.
- Required evidence: full linked repair
  `Saved/Build/cache-v11-dependency-fixture-alias-fix-linked/20260809_150224_507_84dd3381`
  and focused producer `1/1` GREEN at
  `Saved/Tests/cache-v11-dependency-producer-green-2/20260809_150242_568_606a7080`.
- Task impact: removes only a test harness blocker; V1.1 credit comes from the
  subsequently executed 16 semantic cases.

## IC-213 — Decoder extra-Dependency assertion retained the missing-row offset rule

- Severity/state: Stale diagnostic expectation / closed against normative authority.
- Exact boundary: the first decoder rerun at
  `Saved/Tests/cache-v11-dependency-decoder-green/20260809_150317_790_36ed53d7`
  returned the expected `UnexpectedRecord/LocalSemantic`, but the test expected the
  `Dependencies` array-count offset `199` while Runtime returned the physical extra
  `Dependency[0]` row offset `203`.
- Decision: preserve Runtime behavior and update the test to the indexed row. The
  frozen rule is asymmetric by design: an absent required row has no coordinate and
  uses the array enclosing offset; a present extra row uses its own physical row.
- Required evidence: linked test update
  `Saved/Build/cache-v11-dependency-decoder-coordinate-fix-linked/20260809_150414_143_c42f51cc`
  and decoder `1/1` GREEN with `required=5 excluded=6 total=11` at
  `Saved/Tests/cache-v11-dependency-decoder-green-2/20260809_150428_828_96482e94`.
- Task impact: closes the V1.1 decoder coordinate contract without changing wire,
  error values or production phase order.

## IC-214 — Broad TypeSchema fixtures do not all maintain exact Dependency coverage

- Severity/state: V1.2 regression-fixture debt / open, non-blocking for the completed
  focused V1.1 behavior but blocking a truthful full TypeSchema GREEN claim.
- Exact boundary: `Saved/Tests/cache-v11-typeschema-regression/20260809_150512_262_37013fb7`
  ran the broad prefix after V1.1. Several historical negatives mutate Reflection,
  properties, relations or kind payloads without synchronizing their now-authoritative
  Dependency set, so Dependency closure wins at its frozen phase. A static TS-SCR
  representative fixture then called `check(SerializeTypeSchema(...).IsSuccess())`
  at line 4883 and terminated the process; no complete report totals were produced.
- Decision: do not relax or reorder the exact closure and do not launch a standalone
  test-file cleanup project. Repair fixture derivation alongside the corresponding
  V1.2 semantic family, and replace fatal setup checks where they prevent the runner
  from reporting independent failures.
- Required evidence: each touched V1.2 family needs its focused GREEN plus the named
  prior-family regression; the broad TypeSchema prefix must eventually finish with a
  structured report before V1.6 closes.
- Task impact: V1.1 remains GREEN from its exact producer/decoder tests and linked
  build. V1.2/V1.6 remain open; no Editor/Store/Cache-service claim is inferred.

## IC-215 — Method/VFT ordinal gaps initially masked complete-row reorders

- Severity/state: Local error-classification defect / closed during V1.2 Method/VFT.
- Exact boundary: the current RED was a normal `1/1` failure at
  `Saved/Tests/cache-v12-method-vft-red-current/20260809_150951_210_470de67f`.
  After the first Runtime implementation and linked build
  `Saved/Build/cache-v12-method-vft-linked/20260809_151229_389_4e308b06`, only four
  of the 121 producer calls disagreed at
  `Saved/Tests/cache-v12-method-vft-green-1/20260809_151242_590_9152d21d`:
  first/last complete-row swaps in each array returned `OrdinalGap`.
- Decision: when the current expected ordinal is present in a later physical row,
  classify the mismatch as `NonCanonicalOrder`; use `OrdinalGap` only when that
  ordinal is absent. Apply the same bounded look-ahead to OrderedMethods and VFT.
- Required evidence: full linked repair
  `Saved/Build/cache-v12-method-vft-order-fix-linked/20260809_151341_950_6550f3c5`
  and exact producer GREEN
  `Saved/Tests/cache-v12-method-vft-green-2/20260809_151353_838_c537f546`, total
  `1`, passed `1`, failed/skipped `0`; the method asserts `121` calls, `20` legal
  and `101` rejected.
- Task impact: advances V1.2 Method/VFT local validation only. Graph reconstruction,
  declaration resolution and the remaining TypeSchema families stay open.

## IC-216 — Callable and Typedef KindPayload producer rules were not fail-closed

- Severity/state: V1.2 semantic gap / closed.
- Exact boundary: the trustworthy current RED at
  `Saved/Tests/cache-v12-kindpayload-red-current/20260809_151521_913_78bbf65b`
  showed four independent production gaps: zero callable ExpectedSignatureAbi was
  classified as `ZeroStableKey`; Funcdef multicast as `InvalidBoolean`; and the
  generic DataType path admitted Typedef forms outside the unqualified non-Void
  primitive-only contract. Wrong selected/inactive payload arms already matched.
- Decision: keep one shared producer/decoder local validator. Split key and ABI
  checks, classify Funcdef multicast as `InvalidQualifierCombination`, and reject
  non-Primitive, Void, qualified or subtyped Typedef descriptors before generic
  DataType validation. No graph resolver, source classifier or compatibility path
  is introduced.
- Required evidence: linked Editor target
  `Saved/Build/cache-v12-kindpayload-linked/20260809_152249_816_61c6d939`, `4/4`
  actions and process/wrapper `0/0`; final focused producer
  `Saved/Tests/cache-v12-kindpayload-green-final/20260809_153103_544_3cd8dd93`,
  total `1`, passed `1`, failed/skipped `0`. The seven selected-arm regression also
  passes at
  `Saved/Tests/cache-v12-kindpayload-seven-kinds-regression/20260809_152349_199_61c02c56`.
- Task impact: closes IC-146/IC-150/IC-151 and the Callable/Typedef portion of V1.2
  KindPayload. Reflection, form layout/property replay and graph resolution remain
  separate work.

## IC-217 — Enum local replay and derived-hash failures lacked complete ownership

- Severity/state: V1.2 semantic/diagnostic gap / closed.
- Exact boundary: the first adjacent decoder run
  `Saved/Tests/cache-v12-kindpayload-enum-regression/20260809_152425_719_8d34757c`
  returned no local Enum ordinal/name failure because a malformed payload could be
  rehashed into a self-consistent EnumAuthorityHash. After ordinal/name validation
  was added, the intermediate run
  `Saved/Tests/cache-v12-kindpayload-enum-green-1/20260809_152831_493_cf08559d`
  reduced to one mismatch: stale EnumAuthorityHash had the correct error/stage but
  guessed byte offset `122` instead of the captured KindPayload offset `186`.
- Decision: replay stored declaration ordinals, required canonical names, canonical
  metadata and duplicate names in the shared local path. Preserve numeric aliases
  and all signed-int32 values. Attach `KindPayload` to both row-local failures and
  EnumAuthorityHash mismatch rather than relying on generic offset guessing.
- Required evidence: final linked Editor target
  `Saved/Build/cache-v12-kindpayload-enum-coordinate-linked/20260809_152922_342_59c42037`,
  `4/4` actions and process/wrapper `0/0`; decoder behavior
  `Saved/Tests/cache-v12-kindpayload-enum-green-2/20260809_152935_082_d2a1374a`,
  total `1`, passed `1`, failed/skipped `0`.
- Task impact: closes IC-152 and the Enum portion of KindPayload. It does not close
  Reflection, Layout, Property or ModuleSnapshot graph work.

## IC-218 — Funcdef descriptor layout has no form-local rejection yet

- Severity/state: V1.2 form-layout semantic gap / closed.
- Exact boundary: the adjacent regression
  `Saved/Tests/cache-v12-kindpayload-typedef-funcdef-regression/20260809_153009_570_12e57210`
  passes through the newly implemented Typedef/Callable checks and stops at
  `Funcdef descriptor layout`: a Funcdef with mutated semantic size does not return
  the required `InvalidQualifierCombination/LocalSemantic` at the captured Layout
  coordinate. The artifact is diagnostic, not a regression pass.
- Decision: keep fixed descriptor layout validation in the TypeKind/form-local
  Layout/Reflection closure. Do not treat it as a KindPayload rule and do not let a
  later derived TypeLayoutHash mismatch mask the earlier form contradiction.
- Required evidence: the linked Editor target at
  `Saved/Build/cache-v12-descriptor-layout-linked/20260809_153910_182_97116e37`
  completed `4/4` actions with process/wrapper `0/0`; the exact Typedef/Funcdef
  descriptor method is `1/1` GREEN at
  `Saved/Tests/cache-v12-descriptor-layout-green-1/20260809_153924_766_b14d04d6`.
  Prior KindPayload and Enum regressions remain `1/1` GREEN at
  `Saved/Tests/cache-v12-kindpayload-after-descriptor-regression/20260809_154004_588_4e8618e7`
  and
  `Saved/Tests/cache-v12-enum-after-descriptor-regression/20260809_154040_821_0be93841`.
- Task impact: selects the next V1.2 Property/Layout implementation boundary. It
  does not require graph lookup or current Engine layout resolution.

## IC-219 — Property rows, UE flags and exact layout replay are not validated

- Severity/state: V1.2 record-integrity semantic gap / closed on the focused
  producer surface.
- Exact boundary: the dedicated current RED at
  `Saved/Tests/cache-v12-property-layout-red-current/20260809_154212_391_e846f174`
  discovers and executes one automation method without a process crash, but its
  `660` normal-producer calls expose `377` distinct failing contexts. Runtime
  currently recomputes `StorageLayoutHash` and `PropertyLayoutFingerprint` only;
  it does not yet reject forbidden owner forms, noncanonical property ordinals,
  invalid DataType/storage/qualifier combinations, contradictory UE property and
  replication flags, or a layout whose explicit offsets/size do not replay the
  frozen cursor algorithm.
- Decision: implement this as one shared pointer-free producer/decoder validator
  over the already captured TypeSchema record. Keep four deterministic substeps:
  property row-local shape, owner/form closure, UE flag/replication closure and
  checked layout replay. Do not add AS Engine construction, file preprocessing,
  dependency resolution or cross-module lookup; those are neither needed nor
  allowed to decide this record-local validity.
- Implementation findings: the first linked implementation build was GREEN at
  `Saved/Build/cache-v12-property-layout-linked-1/20260809_155456_550_0937e348`,
  `5/5` actions, but the first behavior run
  `Saved/Tests/cache-v12-property-layout-green-1/20260809_155520_990_fa1c6a20`
  correctly remained RED. It isolated three causes rather than a broad Runtime
  defect: Typedef/Funcdef error priority, twenty Script/Environment success
  fixtures whose changed DataType had not rebuilt frozen `ValueLayout`
  Dependencies (IC-214), and stored `offset+size` overflow needing to precede
  cursor equality. The adjacent three-test run at
  `Saved/Tests/cache-v12-property-layout-adjacent-regressions/20260809_155852_861_9d61fb03`
  further found one stale Funcdef fixture whose owner-sensitive
  PropertyLayoutFingerprint was not rehashed; Runtime kept the normative
  property-derived-hash-before-form-closure order and the fixture was repaired.
- Required evidence: final Runtime/Test linked Editor build
  `Saved/Build/cache-v12-property-layout-linked-2/20260809_155726_224_028bfcd3`
  completed `8/8` actions with process/wrapper `0/0`. The exact method is `1/1`
  GREEN at
  `Saved/Tests/cache-v12-property-layout-green-2/20260809_155744_084_8110f9c5`;
  its source-owned ledger remains exactly `83` legal, `577` rejected and `660`
  total producer calls. The focused fixture relink at
  `Saved/Build/cache-v12-property-layout-fixture-linked/20260809_155954_533_96b81045`
  completed `5/5`, after which KindPayload, Enum and Typedef/Funcdef are `3/3`
  GREEN together at
  `Saved/Tests/cache-v12-property-layout-adjacent-regressions-green/20260809_160013_730_1114065a`.
- Task impact: closes the Property/Layout portion of V1.2 only. Reflection form
  closure, decoder-coordinate breadth, record codecs, graph, Store, warm restore
  and Editor/PIE/package verification remain separate later gates.

## New issue policy

## IC-220 — Reflection strings, member rows and legal forms are not fail-closed

- Severity/state: V1.2 reflection semantic gap / closed on the record-local
  producer/decoder surface.
- Exact boundary: after Property/Layout became GREEN, the trustworthy current RED
  `Saved/Tests/cache-v12-reflection-red-after-property/20260809_160222_169_044869f4`
  discovered and executed exactly one focused method, then failed normally rather
  than crashing. The first newly unmasked case is an ordinary UClass with a
  present-but-empty ConfigName: Runtime returns success, an invalid/default record
  classification and nonempty producer output instead of atomic
  `InvalidPresence`. Earlier relation/layout/property/method/behavior cases in the
  same method now pass and no longer mask Reflection.
- Decision: add one shared producer/decoder Reflection field-local pass for raw
  discriminator/flag domains, optional-string contents and explicit ordered
  UFunction membership; then one post-Dependencies form closure for the frozen
  TypeKind+Reflection allowlist, class-flag parity, statics rules, string presence,
  member presence and special fixed layouts. UFunction membership remains explicit
  even when declaration ReflectionFlags are zero; local validation never infers
  membership from flags, names or metadata and does not resolve declarations.
- Implementation findings: the first broad diagnostic run at
  `Saved/Tests/cache-v12-reflection-typeschema-full-1/20260809_160914_484_e0d2e07b`
  was intentionally not accepted as a regression pass. It exposed three current
  Reflection defects plus unrelated historical fixtures and eventually reached a
  pre-existing static `check`. The focused repairs removed Reflection look-ahead
  from Method/VFT field-local validation, made the StaticsClass discriminator
  bidirectional without allowing an illegal known mask to redirect the form, and
  attached ordinal/reference failures to the exact reflected-member/target row.
  Exhaustive diagnostics also repaired three non-single-fault fixtures: legal
  `Placeable` statics masks now rebuild TypeLayoutHash; the injected statics Method
  now has the enclosing TypeKey owner; and Interface/Enum forbidden-property
  fixtures preserve their fixed layout so the property-presence rule is the sole
  fault. The attempted `+`-joined exact-prefix run at
  `Saved/Tests/cache-v12-reflection-exhaustive-regression-1/20260809_160821_796_4a3705ab`
  selected zero tests under UE 5.8 and is retained only as runner diagnostics.
- Required evidence: final linked Editor build
  `Saved/Build/cache-v12-reflection-property-fixture-linked-2/20260809_163620_976_a19159bf`
  completed `5/5` actions with process/wrapper `0/0`. Focused Reflection evidence is:
  producer `1/1` at
  `Saved/Tests/cache-v12-reflection-producer-green-final/20260809_163903_920_04e6649c`;
  legal forms/optional names `2/2` at
  `Saved/Tests/cache-v12-reflection-form-prefix-green/20260809_162846_644_c86afefe`;
  all `0x000..0x3ff` class masks `1/1` at
  `Saved/Tests/cache-v12-reflection-classmask-green-2/20260809_162253_447_68548931`;
  ordinary/statics/UStruct shape isolation `1/1` at
  `Saved/Tests/cache-v12-reflection-shapes-green-2/20260809_162634_626_ce2df191`;
  and UFunction ordinals/reference shapes `1/1` at
  `Saved/Tests/cache-v12-reflection-members-2/20260809_162709_029_f6337cd7`.
  The append-only public coordinate matrix is `1/1` GREEN at
  `Saved/Tests/cache-v12-reflection-coordinate-matrix-green/20260809_163143_532_75c89f20`.
  Property/Layout, KindPayload, Enum and Typedef/Funcdef each remain `1/1` GREEN at
  `Saved/Tests/cache-v12-reflection-property-regression-green-2/20260809_163638_609_952dc5ca`,
  `Saved/Tests/cache-v12-reflection-kindpayload-regression/20260809_163717_204_07f7a6a7`,
  `Saved/Tests/cache-v12-reflection-enum-regression/20260809_163755_754_e36582d5` and
  `Saved/Tests/cache-v12-reflection-descriptor-regression/20260809_163830_753_af4eb8df`
  respectively. Graph owner/entity
  resolution remains separate.
- Task impact: completes the remaining focused V1.2 form-local family and freezes
  the cache boundary used when UFUNCTION exposure/dispatch metadata changes. It
  does not implement Editor ClassGenerator refresh, Blueprint impact, StaticJIT
  route invalidation or end-to-end changed-module selection.

## IC-221 — Semantic subfield failure coordinates are not uniformly exact

- Severity/state: V1 diagnostic-contract breadth / open, non-blocking for the
  closed IC-220 Reflection form behavior.
- Exact boundary: Reflection originally retained only the top-level discriminator
  and member rows. That made an unknown ClassReflectionFlags bit report offset
  `439` while the owning field begins at `440`. The append-only public field enum
  now retains `ReflectionKind=39` and `ClassReflectionFlags=40`; the complete
  `0..40` valid/surplus/allocation-free lookup matrix is GREEN. The broader
  `EveryUnknownFlagBitFailsAtItsOwningField` run at
  `Saved/Tests/cache-v12-reflection-unknownflags-green/20260809_163218_355_eb029e45`
  proves the Reflection section passes and then exposes the next older gap:
  PropertySemanticFlags expects exact offset `530`, while the retained
  OrderedProperty row coordinate reports `427`.
- Decision: keep the two new Reflection coordinates append-only and do not fake
  exact Property/DataType offsets by returning unrelated rows. Treat remaining
  subfield precision as one explicit diagnostic-taxonomy task: inventory which
  semantic failures require a durable public coordinate, append only the minimal
  fields, and preserve top-level/row fallbacks for form-selected absence. It must
  not alter StableFunctionKey, cache invalidation, graph resolution or Store
  behavior.
- Required evidence: current linked coordinate build
  `Saved/Build/cache-v12-reflection-coordinate-matrix-linked-2/20260809_163107_870_2dc84479`
  completed `5/5`; the `0..40` matrix artifact above is `1/1` GREEN. Closure needs
  the full unknown-bit method GREEN plus updated append-only wire authority and
  clean captured-offset lookup tests.
- Task impact: improves corrupt-cache diagnostics and test observability only.
  It is not a reason to reopen Reflection semantics or delay record codecs/graph
  work unless an imprecise coordinate masks a functional failure.

## IC-222 — Remaining-record archive and factory dispatch are declaration-only

- Severity/state: V1.3 functional blocker / partially closed; the first
  DebugSidecar vertical slice is GREEN while the other remaining kinds are open.
- Exact boundary: the four remaining DTOs, decoded alternatives, typed coordinate
  overloads and aggregate Budget transaction exist, but there is no producer
  archive for the remaining record kinds and the sole decoded-record factory
  returns `UnexpectedRecord` for them. The first TDD build
  `Saved/Build/cache-v13-debugsidecar-red/20260809_165443_633_749c63df`
  compiled the full UE 5.8 Development Editor target until the new focused test
  referenced the intentionally missing `FAngelscriptCacheRemainingRecordArchive`,
  `TryBuildLogicalSectionKey` and `SerializeDebugSidecar` symbols. UBT exited `6`
  and the wrapper exited `1`; no unrelated compiler failure preceded these errors.
- Decision: introduce one remaining-record producer archive and one private
  non-owning codec bridge. Start with DebugSidecar, then extend the same bridge to
  ModuleSnapshot, FunctionBody and ModuleState. Every decoder runs inside the
  existing factory-owned aggregate candidate, captures its public diagnostic
  coordinates, completes physical/local/hash validation, promotes once, and only
  then publishes the immutable handle. Do not add a second public owning decoder
  or a record-specific promotion path.
- Required evidence: the new focused test must link and execute normally, proving
  canonical bytes, RecordId recomputation, private factory dispatch, exact offsets,
  immutable typed access and scratch-to-retained promotion. Each subsequent kind
  adds its own RED/GREEN behavior before V1.3 can close; the final gate remains one
  linked Runtime/Test build plus the complete remaining-record/factory prefix.
- Current evidence: the linked UE 5.8 Development Editor build
  `Saved/Build/cache-v13-debugsidecar-green-attempt-1/20260809_165900_174_bce8b948`
  completed `12/12` actions. The first focused Runtime behavior artifact
  `Saved/Tests/cache-v13-debugsidecar-focused-attempt-1/20260809_165927_611_9530401b`
  discovered one test and passed `1/1`; it proves the `191`-byte canonical payload,
  RecordId/factory dispatch, typed immutable value, every exact fixture coordinate,
  and aggregate promotion with zero temporary bytes after publication. This is not
  GUI Editor or cold/warm Cache evidence.
  The second TDD boundary failed only on the missing `SerializeModuleSnapshot`
  member at
  `Saved/Build/cache-v13-modulesnapshot-red/20260809_170435_131_f36124bd`.
  After implementing the same factory bridge, the linked build
  `Saved/Build/cache-v13-modulesnapshot-green-attempt-1/20260809_170842_448_f54fd5ab`
  completed `10/10` actions and the combined focused artifact
  `Saved/Tests/cache-v13-modulesnapshot-focused-attempt-1/20260809_170905_999_69ffc0bd`
  passed `2/2`. DebugSidecar and ModuleSnapshot are now real factory alternatives;
  FunctionBody and ModuleState were still open at that boundary. The third TDD boundary is the full
  Editor-target compile RED
  `Saved/Build/cache-v13-functionbody-red/20260809_171137_521_eda0e024`:
  compilation reached the new FunctionBody method and failed only because
  `SerializeFunctionBody` is not yet a member of the remaining-record archive
  (UBT/wrapper `6/1`). Its fixture freezes the `310`-byte present-debug wire,
  execution identity, optional typed RecordId, exact `0..27` occurrence offsets
  used by the fixture, and the same one-candidate/one-promotion boundary.
- Task impact: directly advances V1.3. It does not claim ModuleSnapshot graph
  validation (V1.4), clean-engine capture (V1.5), Store, warm restore or lifecycle.

## IC-223 — DebugSidecar semantic validation introduced unbudgeted offset scratch

- Severity/state: V1 Budget/ownership invariant / closed and regression GREEN.
- Exact boundary: the first GREEN decoder correctly budgeted the published DTO,
  canonical payload and captured-offset arrays, but also copied four offsets per
  source into a `TArray<uint64, TInlineAllocator<16>>` for the post-physical
  semantic pass. More than four sources could spill this scratch array to the heap
  without extending the factory candidate or appearing in AR-SCR-DS-01.
- Decision: remove the duplicate scratch container. The semantic pass now indexes
  the already retained and candidate-charged captured-offset entries using their
  frozen layout (`6 + source * 4 + component`); producer validation uses an
  allocation-free zero-offset provider. Physical-end-before-semantic precedence
  and exact diagnostics are unchanged.
- Required evidence: rebuild and rerun the focused DebugSidecar prefix; later
  AR-SCR-DS-01 multi-source exact/one-byte-short tests must prove no independent
  scratch allocation family appears.
- Closure evidence: linked build
  `Saved/Build/cache-v13-debugsidecar-scratch-free-linked/20260809_170237_024_7d2f919b`
  completed `4/4`; focused artifact
  `Saved/Tests/cache-v13-debugsidecar-scratch-free-green/20260809_170252_850_37a2e695`
  passed `1/1`. The following ModuleSnapshot `2/2` run above independently kept
  the refactored DebugSidecar method GREEN.
- Task impact: preserves the sole candidate/Budget architecture needed by V1.3;
  it adds no new cache or lifecycle behavior.

## IC-224 — FunctionBody optional occurrences cannot use worst-case offset capacity

- Severity/state: V1 immutable-memory/Budget invariant / closed and focused GREEN.
- Exact boundary: FunctionBody discovers each dependency's optional
  `ExpectedContentOrValue` while reading the dependency array. One ordinary
  `8 * dependency-count` captured-offset array would either retain unused entries
  for absent values or require growth/replacement after allocations had already
  entered the factory candidate. The same shape applies to the singleton optional
  DebugSidecar link. Neither outcome satisfies exact preflighted retained memory.
- Decision: use one specialized FunctionBody offset storage: `16` always-present
  coordinates are inline in the decoded controller; each dependency owns seven
  exact base entries plus one `TOptional<Entry>` slot; the three DebugSidecar
  child coordinates are inline optionals. DTO payload/dependency arrays and both
  dynamic offset arrays are preflighted through the outer candidate charge sink.
  RecordId and StableReference reads also consume the cumulative bounded
  references/relocations counter.
- Required evidence: present-sidecar and absent-sidecar fixtures must prove exact
  occurrence lookup, absent optional lookup failure, canonical reserialization,
  reference counts and candidate rollback when the second dependency exceeds a
  limit of one reference.
- Closure evidence: linked build
  `Saved/Build/cache-v13-functionbody-dependency-absence-linked/20260809_172627_054_33820903`
  completed `4/4`. Combined Automation
  `Saved/Tests/cache-v13-functionbody-dependency-absence-green/20260809_172650_214_a4a65f89`
  passed `5/5`: the `310`-byte present-sidecar body consumes one reference; the
  `443`-byte canonicalized two-dependency/absent-sidecar body consumes two; the
  tight run rejects with `BudgetExceeded` at byte `344`, retains one cumulative
  reference and rolls candidate temporary bytes back to zero.
- Task impact: closes the focused FunctionBody producer/private-decoder shape and
  supplies the shared profile-specific debug-absence identity used by the sibling
  StaticJIT design. Opaque execution validation and cross-record graph checks
  remain V1.4; compiler attachment remains V5.

## IC-225 — GlobalStorage content presence conflicts with its ModuleState invalidation role

- Severity/state: V1.3 dependency-schema contradiction / closed and focused GREEN.
- Exact boundary: the common dependency presence matrix in `record-schema.md` and
  `record-wire-v1.md`, plus all three current codec validators, require
  `ExpectedContentOrValue` only for HardValue, Initializer and CompileOption.
  `module-state-matrix-v1.md` instead requires each ModuleState GlobalStorage row
  to carry its `StorageLayoutFingerprint`. Using one shared SemanticDependency DTO
  makes those rules mutually exclusive. Reusing `DependencyRequiresContent` to
  determine ModuleInterface ABI membership is also incorrect: GlobalStorage must
  remain ABI-bearing by stable reference while its layout content hash must not be
  folded into InterfaceAbi itself.
- Decision: make GlobalStorage a content-bearing dependency everywhere and split
  the two concepts in code. `DependencyRequiresContent` admits GlobalStorage,
  HardValue, Initializer and CompileOption; a separate
  `DependencyContributesToInterfaceAbi` predicate preserves the ABI-bearing kind
  set and hashes only kind/reference/expected ABI coordinates. Synchronize the
  common wire/presence matrix instead of adding a ModuleState-only exception.
- Required evidence: first change the dependency matrix test to RED for a
  GlobalStorage row without content; add an InterfaceAbi regression proving that
  changing only GlobalStorage content does not change InterfaceAbi while changing
  its stable/ABI coordinate does; then link the Editor target and rerun focused
  Dependency, TypeSchema and remaining-record families before admitting a
  representative non-empty ModuleState.
- Closure evidence: the intended presence RED is
  `Saved/Tests/cache-ic225-presence-red-class/20260809_174710_095_e9cb9bd4`
  at `AngelscriptCacheArchivePrimitiveTests.cpp:495`; the independent InterfaceAbi
  RED is
  `Saved/Tests/cache-ic225-interface-abi-red/20260809_174751_885_9024d4b7`
  at `AngelscriptCacheSourceInterfaceTests.cpp:3847`. The linked Editor target
  `Saved/Build/cache-ic225-global-storage-green-attempt-1/20260809_174907_150_133df63c`
  completed `6/6`. Exact presence and ABI-isolation methods then passed `1/1`
  respectively at
  `Saved/Tests/cache-ic225-presence-green/20260809_174920_425_40ddc55d`
  and
  `Saved/Tests/cache-ic225-interface-abi-green/20260809_174955_876_86a8dc23`.
- Task impact: blocks truthful non-empty ModuleState completion but not the empty
  codec skeleton. Closure now unblocks the representative non-empty ModuleState
  fixture and provides precise invalidation after global storage layout changes;
  it does not add file preprocessing, Store or Editor lifecycle behavior.

## IC-226 — CQTest method targets require the generated test-class path segment

- Severity/state: verification invocation defect / closed.
- Exact boundary: the first narrow invocation used
  `Angelscript.TestModule.Cache.Archive.Primitives.ReferenceDependencyAndQualifierRulesFailClosed`.
  CQTest registers the method under
  `...Primitives.FAngelscriptCacheArchivePrimitiveTests.ReferenceDependencyAndQualifierRulesFailClosed`,
  so the runner correctly reported no matching test and never executed the RED.
- Decision: use the fully discovered Automation path for single CQTest methods;
  use the class prefix only when intentionally running every method in the class.
- Evidence: no-match artifact
  `Saved/Tests/cache-ic225-presence-red/20260809_174619_843_216e71c6`;
  the corrected class run reached the intended line `495` RED, and the final
  fully qualified method run is `1/1` GREEN in IC-225.
- Task impact: verification-only; no production behavior changed.

## IC-227 — The broad primitive class exposes an unrelated UE allocator slack assumption

- Severity/state: adjacent V1.6 regression / closed on 2026-08-10.
- Exact boundary: the class-wide presence RED also ran
  `ReaderChargesActualAllocatorCapacityAtomicallyBeforeAllocation`, which failed
  at `AngelscriptCacheArchivePrimitiveTests.cpp:1184` because the active UE 5.8
  allocator did not expose the test's searched typed-array slack boundary. The
  IC-225 edits do not touch allocator code or that fixture.
- Decision: `CalculateSlackReserve` is permitted to return exactly the requested
  capacity for a large element type; extra whole-element slack is not a Cache
  contract. Keep the TCHAR fixture as the independent slack-capacity witness. For
  the typed recursive array, select the first observed slack boundary when one
  exists and otherwise use a fixed nonzero exact-reserve count. In both cases
  preserve the same independent reserve-byte calculation, post-allocation
  `GetAllocatedSize` equality, event chronology and one-byte-short atomicity.
- Evidence: class artifact
  `Saved/Tests/cache-ic225-presence-red-class/20260809_174710_095_e9cb9bd4`,
  totals `13`, passed `11`, failed `2`; the two failures were the intended IC-225
  presence RED and this independent allocator assertion. The fully qualified
  IC-225 method later passed independently.
- Resolution/evidence: the complete Cache run reproduced this as its sole failure
  (`244/245`) at
  `Saved/Tests/cache-ic255-complete-cache-regression-attempt-1/20260810_030614_106_9a1deb05`.
  The test-only portability correction linked at
  `Saved/Build/cache-ic227-allocator-portability-green-build-attempt-1/20260810_030822_915_5ba5414a`.
  The focused method passed `1/1` at
  `Saved/Tests/cache-ic227-allocator-portability-green-attempt-1/20260810_030844_814_01c9b869`,
  the full Archive.Primitives prefix passed `13/13` at
  `Saved/Tests/cache-ic227-archive-primitives-green-attempt-1/20260810_030925_600_439a1b33`,
  and the complete current Cache prefix passed `245/245` at
  `Saved/Tests/cache-v1-complete-cache-green-attempt-1/20260810_030957_530_7bdf5872`.
- Task impact: closes the final known V1.6 broad regression. It changes no Runtime
  allocator behavior and does not prove real compiler capture or Saved Store.

## IC-228 — Remaining-record byte payloads use u32 despite the frozen u64 wire primitive

- Severity/state: V1 common-wire incompatibility / closed and focused GREEN.
- Exact boundary: `record-wire-v1.md` defines a byte payload as `u64` length plus
  bytes. `FWriter::WriteByteArray` in the private remaining-record codec writes
  `u32`, and DebugSidecar/FunctionBody decoders reuse the generic `u32` array
  reader. This already made their focused `191`, `310` and `443` byte records
  four bytes too short and would encode ModuleState CanonicalValue/initializer
  payloads incorrectly. The artifact identity writer is a separate frozen hash
  stream and intentionally remains unchanged.
- Decision: add a dedicated u64 byte-payload reader primitive with the same
  pre-allocation Budget rules; switch only remaining-record byte payload fields
  to it. Keep semantic arrays and strings on u32, and do not alter identity hash
  streams.
- Required evidence: update existing exact DebugSidecar/FunctionBody lengths,
  downstream offsets and bounded-reference failure coordinate first; observe
  their focused RED; then link and rerun the complete remaining-record codec
  family before ModuleState persists its first non-empty byte payload.
- Closure evidence: full Editor target with test-first expectations linked at
  `Saved/Build/cache-ic228-byte-payload-red-linked/20260809_175542_547_b299bc1b`;
  the intended Automation RED
  `Saved/Tests/cache-ic228-byte-payload-red/20260809_175601_571_69156f1c`
  had totals `5`, passed `2`, failed `3`, with exactly DebugSidecar and the two
  FunctionBody byte-payload methods failing. The u64 reader/writer implementation
  linked at
  `Saved/Build/cache-ic228-byte-payload-green-linked/20260809_175723_269_843f16b5`
  (`9/9`) and the same complete family passed `5/5` at
  `Saved/Tests/cache-ic228-byte-payload-green/20260809_175745_478_bbb3f93f`.
- Task impact: prerequisite for wire-correct ModuleState. RecordIds change because
  canonical payload bytes change; no compatibility migration is required during
  plugin development.

## IC-229 — Public ModuleState hash helpers initially admitted invalid semantic DTOs

- Severity/state: V1.3 producer-boundary consistency / closed and focused GREEN.
- Exact boundary: the first implementations of
  `ComputeGlobalStorageLayoutFingerprint`,
  `ComputeGlobalConstantHardValueHash` and
  `ComputeInitializerExecutionHash` domain-separated and hashed their inputs but
  did not all fail closed for malformed strings, invalid stable references,
  unsupported type/value shapes, illegal flags or invalid enum/presence pairs.
  `SerializeModuleState` performed broader validation, so callers could otherwise
  manufacture a stable-looking derived hash for a DTO the canonical record would
  reject.
- Decision: make each public helper validate its complete local semantic input
  before emitting a hash; retain cross-record existence and declaration ownership
  for `ValidateModuleSnapshotGraph` rather than teaching local hash helpers about a
  graph.
- Required evidence: keep the invalid-shape method RED before the fix, then rerun
  it together with canonical-order, exact nested-offset and trailing-data
  precedence tests through the public API and sole decoder factory.
- Closure evidence: the first validation artifact
  `Saved/Tests/cache-v13-modulestate-validation-red/20260809_183022_969_3ff344dd`
  passed `3/4` and failed only
  `HashHelpersRejectInvalidSemanticInputs`. The final combined prefix
  `Saved/Tests/cache-v13-modulestate-focused-green/20260809_183154_140_bfbdfafb`
  passed `5/5`, failed/not-run `0`, with process/wrapper `0/0`.
- Task impact: closes the representative local ModuleState producer boundary in
  V1.3. It does not close seven-kind factory dispatch, graph validation, real
  module capture, Store or Editor lifecycle.

## IC-230 — Minimal ModuleInterface factory fixture declared an unused namespace

- Severity/state: verification fixture correctness / closed before production
  ModuleInterface implementation.
- Exact boundary: after the new SourceIndex factory branch passed the first half
  of the combined test, `MakeMinimalModuleInterface` called
  `ComputeModuleInterfaceAbi` with `CanonicalNamespaces={"Gameplay"}` but no
  declaration or import using that namespace. Existing producer validation
  correctly rejects every unused canonical namespace, and the helper's precondition
  `check` terminated the Automation process at the call site before the intended
  ModuleInterface `UnexpectedRecord` assertion could run.
- Decision: a truly minimal valid interface owns an empty namespace set. Keep the
  top-level namespace-count coordinate at byte `76`, require an indexed namespace
  coordinate to be unset, and defer present namespace/nested row coverage to the
  representative factory fixture rather than weakening the semantic rule.
- Required evidence: rebuild the corrected fixture and rerun the same focused
  method; it must pass all SourceIndex assertions and reach an ordinary assertion
  RED at the still-stubbed ModuleInterface factory result without a process crash.
- Closure evidence: the crash artifact is
  `Saved/Tests/cache-v13-source-index-factory-intermediate-red/20260809_185147_435_dd36d6ce`
  and its call stack points to line `106` of the test fixture. The corrected
  fixture linked at
  `Saved/Build/cache-v13-source-index-factory-linked-fixture-fix/20260809_185259_387_ddc42674`
  (`4/4`). Its rerun reached the intended ordinary assertion RED at line `110`
  for the still-missing ModuleInterface factory branch, without a crash, at
  `Saved/Tests/cache-v13-source-index-factory-green-module-interface-red/20260809_185315_946_693ae544`.
  After that branch was implemented, the same method passed `1/1` at
  `Saved/Tests/cache-v13-source-interface-factory-minimal-green-attempt-1/20260809_185822_378_b92b2f0e`.
- Task impact: verification-only. SourceIndex production behavior remains linked;
  the corrected fixture no longer blocks ModuleInterface factory work.

## IC-231 — Transitional record-specific owning decoders coexist with the sole factory

- Severity/state: V1.3 public API/decoder-authority duplication / closed.
- Exact boundary: `FAngelscriptDecodedCacheRecord::TryDecode` now dispatches all
  seven record kinds, but `FAngelscriptCacheSemanticArchive` still publicly exposes
  `DeserializeSourceIndex`, `DeserializeModuleInterface` and the owning
  `FAngelscriptValidatedSourceIndex` token. The historical SourceInterface test TU
  still invokes those paths extensively. Keeping them as production alternatives
  would leave two physical decoder authorities for SourceIndex/ModuleInterface.
- Decision: keep serialization and hash construction public, migrate production
  eligibility queries and tests to the immutable kind-tagged decoded record, then
  remove the record-specific owning decode APIs. Explicit test-gated fixture writers
  may remain only where they cannot become a Runtime read path.
- Required evidence: representative SourceIndex/ModuleInterface factory fixtures;
  migrated exact-fast-path tests including wrong-kind rejection; no production
  references to the old owning token or record-specific deserialize APIs; linked
  Editor target and focused source/interface regression.
- Closure evidence: the Runtime header and implementation no longer declare or
  define `FAngelscriptValidatedSourceIndex`, either public record-specific
  deserialize API, `DeserializeSourceIndexForTests`, the validated-token query
  overload, or the two noncapturing whole-record readers. A read-only search of
  `Plugins/Angelscript/Source` returned zero references for all six obsolete
  symbol families; the only retained read authority is the common decoded-record
  factory bridge through `TryDecodeSourceIndex`/`TryDecodeModuleInterface` and the
  captured payload readers. The complete UE 5.8 Development Editor target rebuilt
  and linked Runtime/Test at
  `Saved/Build/cache-ic231-old-decoder-removal-build-attempt-1/20260809_200152_369_0b946304`
  (`13/13`, process/wrapper `0/0`). The complete SourceInterface prefix then passed
  `37/37`, failed/skipped `0`, at
  `Saved/Tests/cache-ic231-old-decoder-removal-tests-attempt-1/20260809_200226_338_f82c8cd2`.
- Task impact: the duplicate decoder authority is closed. V1.3 itself remains open
  on IC-232's complete captured-coordinate/Budget matrix and does not imply V1.4
  graph, Pack, Editor lifecycle, PIE or package readiness.

## IC-232 — Nested SourceIndex/ModuleInterface semantic diagnostics still use shallow offsets

- Severity/state: V1.3 diagnostic-coordinate precision / closed.
- Exact boundary: the immutable candidates retain structured exact offsets for
  nested discovery options, mounts, providers, files, inputs, edges, declarations,
  data types, parameters, metadata, slots, imports and dependencies. The older
  shallow `FSourceIndexReadOffsets` / `FModuleInterfaceReadOffsets` model is now
  deleted and the named scalar/reference families route through the one captured
  store. The remaining boundary is proof and routing breadth: optional values,
  duplicate/order second occurrences, physical precedence and exact retained
  allocation/Budget rows are not yet complete.
- Decision: route semantic preparation through the same captured-offset authority
  used by `FindCapturedOffset`; do not rescan payload bytes and do not preserve a
  second offset model in the final production path.
- Required evidence: one-fault-at-a-time nested negative matrices for both record
  kinds, with exact `FieldId/index/subindex -> byte offset` assertions, trailing-data
  precedence, exact one-byte-short Budget failure and unchanged output on failure.
- Partial closure evidence: the intended two-case RED linked at
  `Saved/Build/cache-ic232-nested-offsets-red-linked/20260809_192109_982_19d17456`
  and failed `0/2` at
  `Saved/Tests/cache-ic232-nested-offsets-red/20260809_192131_980_fcece6f2`:
  provider capability expected byte `250` but received parent byte `52`, while
  declaration parameter ordinal expected `293` but received parent byte `92`.
  A borrowed view over the sole private captured store linked at
  `Saved/Build/cache-ic232-nested-offsets-green-attempt-1/20260809_192449_321_79ca5fe1`
  (`13/13`) and the same prefix passed `2/2` at
  `Saved/Tests/cache-ic232-nested-offsets-green-attempt-1/20260809_192512_241_3ae0062e`.
  The issue remains open for every untested nested family and the required
  physical/Budget precedence matrix.
- Further partial evidence: the expanded intended RED linked at
  `Saved/Build/cache-ic232-derived-coordinates-red-linked/20260809_192917_183_20287cd5`
  and its focused run
  `Saved/Tests/cache-ic232-derived-coordinates-red/20260809_192936_858_85607733`
  passed the two earlier methods but failed both new table methods. It exposed
  parent byte `48` versus exact MountKey byte `52`, and stale parameter byte
  `303` versus exact DeclarationStableKey byte `110`. After per-row exact
  selection, the target passed at
  `Saved/Build/cache-ic232-derived-coordinates-green-attempt-1/20260809_193239_664_ed026cf0`
  and the four-method prefix passed `4/4` at
  `Saved/Tests/cache-ic232-derived-coordinates-green-attempt-1/20260809_193251_595_795aa712`.
  This closes the six Source derived-key and six Module derived-hash/import/slot
  occurrences only; the issue remains open.
- Further partial evidence: every Source `0..89` and Module `0..88` captured-field
  numeric/index shape now has contiguous compile-time and runtime applicability,
  missing/unused/out-of-range coverage. Source scalar/reference/ordinal routing
  failed as intended at parent byte `36` versus exact byte `40`, then passed after
  per-field selection. Module DataType/Parameter/Reflection/Import/Dependency
  routing failed as intended at declaration parent byte `102` versus exact byte
  `291`. Captured readers now defer semantic validation until the full store is
  available; the focused table passed after the split. The first broad regression
  was `39/40` solely because IC-236 still froze parent offsets. After preserving
  and migrating all six cases, the complete SourceInterface prefix passed `40/40`
  at
  `Saved/Tests/cache-ic232-exact-nested-sourceinterface-green-attempt-1/20260809_203426_964_3ff46014`.
- Final closure evidence: duplicate/noncanonical-order validation now selects the
  first physical row that proves the error, including nested option, trait,
  metadata and slot arrays. Invalid optional tags retain physical precedence over
  earlier semantic mutations. The focused duplicate/order and physical-precedence
  methods passed `1/1` each, then the complete SourceInterface prefix passed
  `42/42` at
  `Saved/Tests/cache-ic232-order-physical-sourceinterface-broad-attempt-1/20260809_205913_397_71dcfedd`.
  The allocation probe now exposes each accepted allocation's physical field
  offset. One representative non-empty record of each kind inventories every
  allocation it actually performs, proves exact total/resident/combined-peak
  boundaries and injects failure after every accepted allocation. That method
  passed `1/1` at
  `Saved/Tests/cache-ic232-allocation-origin-focused-attempt-3/20260809_211115_576_fbdc7ec1`,
  and the complete prefix passed `43/43` at
  `Saved/Tests/cache-ic232-allocation-sourceinterface-broad-attempt-1/20260809_211152_055_b8b0acbb`.
- Task impact: IC-232 is closed. V1.3 still depends on the sole
  `ValidateModuleSnapshotGraph` authority; this diagnostic/allocation closure does
  not imply graph, real-module, Store, warm-restore or Editor/PIE/package behavior.

## IC-233 — Transitional query overload made an old function-name type assertion ambiguous

- Severity/state: V1.3 migration compile issue / closed at the transitional
  boundary.
- Exact boundary: adding the common-record overload for
  `QueryExactFastPathEligibility` made the historical
  `decltype(&FAngelscriptCacheSemanticArchive::QueryExactFastPathEligibility)`
  assertion ambiguous. Runtime had already compiled and linked; only the test TU
  failed because an overloaded function name has no unique address type without a
  target signature.
- Decision: make the assertion's old-overload function-pointer type explicit with
  `static_cast` while that migration bridge exists. Do not rename or weaken the
  common-token production API to preserve a test assumption about unique overload
  names. Remove the transitional assertion together with the old overload when
  IC-231 closes.
- Required evidence: one failed complete Editor build at the exact assertion, then
  one successful complete Editor build and the focused wrong-kind query test.
- Closure evidence: the compile failure is
  `Saved/Build/cache-ic231-query-common-token-green-attempt-1/20260809_190851_515_dc0772b9`.
  The repaired target passed at
  `Saved/Build/cache-ic231-query-common-token-green-attempt-2/20260809_190929_398_5f2a1562`
  (`4/4`), and the focused prefix passed `2/2` at
  `Saved/Tests/cache-ic231-query-common-token-green/20260809_190947_224_39a40b40`.
- Task impact: verification-only; no Runtime query semantics changed. IC-231 remains
  open until the migration bridge itself is removed.

## IC-234 — Owned-capacity fixture assumes allocator slack that UE 5.8 does not provide

- Severity/state: test-fixture portability / closed.
- Exact boundary: the broad SourceInterface regression reaches
  `EligibilityResultChargesActualOwnedCapacitiesAndRejectsOneByteShort`, but its
  setup scans requested `TCHAR` capacities `2..4097` and requires
  `CalculateArrayReserveCapacityForTests<TCHAR>(Requested) > Requested`. The
  current UE 5.8 allocator returns no such candidate in that bounded range, so
  the method fails at fixture line `3648` before constructing a SourceIndex,
  invoking the common-record query or checking any Cache Budget counter.
- Decision: preserve the production rule that owned result memory is charged by
  actual retained capacities. Refactor the test to prove exact-capacity and
  one-byte-short behavior without requiring allocator over-allocation for a
  particular element type or bounded request range; do not change Runtime Budget
  accounting merely to make the fixture discover slack.
- Required evidence: focused intended fixture RED, a portable capacity fixture
  that reaches the query, exact successful owned-byte charge, one-byte-short
  `BudgetExceeded` with atomic output reset, and the complete SourceInterface
  prefix GREEN.
- Discovery evidence: UE 5.8 Development Automation at
  `Saved/Tests/cache-ic231-test-migration-broad-attempt-1/20260809_193844_659_50791bc1`
  discovered `37` methods and passed `35`; this method was one of two failures and
  stopped before Runtime behavior. Process exit `255` and wrapper exit `1` are
  expected for the failed test run.
- Closure evidence: the fixture now uses five matching scope kinds and a fixed
  non-empty diagnostic, computes expected capacities using the same public UE
  allocator contract, and permits exact reserve capacity. It still compares
  actual owned bytes, exact total/peak limits, total one-byte-short and resident
  one-byte-short rejection with atomic output reset. The historical class first
  passed this method in the `29/30` diagnostic at
  `Saved/Tests/cache-ic231-broad-fixture-fix-focused-attempt-1/20260809_194523_217_ace14921`,
  and the complete SourceInterface prefix is `37/37` GREEN at
  `Saved/Tests/cache-ic231-source-interface-broad-green-attempt-2/20260809_195448_341_b7ca8c98`.
- Task impact: verification-only after closure; no Runtime Budget behavior changed.

## IC-235 — Exact slot-phase refactor introduced a shadowed loop variable

- Severity/state: local compile integration / closed.
- Exact boundary: splitting ModuleInterface slot ordinal validation from local
  declaration preparation added a loop variable named `DeclarationIndex` in a
  scope that already owned the stable-hash index table with that name. UE 5.8
  promotes C4456 to a compile error. The first rename patch also touched the
  adjacent occurrence-building loop incompletely and produced two undeclared
  identifier errors on the second build attempt.
- Decision: keep the phase refactor and use `DeclarationOrdinal` consistently for
  loop coordinates, reserving `DeclarationIndex` for the stable-hash lookup table.
  Do not weaken compiler warning policy.
- Required evidence: preserve both failed official build artifacts, then one full
  Editor target GREEN and the affected exact-offset plus broad regression GREEN.
- Closure evidence: failed attempts are
  `Saved/Build/cache-ic232-slot-phase-exact-build-attempt-1/20260809_195104_997_aa789126`
  and
  `Saved/Build/cache-ic232-slot-phase-exact-build-attempt-2/20260809_195129_779_5fa5bb9d`.
  The corrected complete target passed at
  `Saved/Build/cache-ic232-slot-phase-exact-build-attempt-3/20260809_195154_588_c5ec6dec`;
  the final phase arrangement linked again at
  `Saved/Build/cache-ic232-slot-phase-exact-build-attempt-4/20260809_195435_353_c20cb7cf`.
  The exact method passed `1/1`, and the broad prefix passed `37/37` at the paths
  recorded under IC-232/IC-234.
- Task impact: verification-only after closure; no public or wire contract changed.

## IC-236 — Historical nested semantic test froze obsolete parent offsets

- Severity/state: verification contract migration / closed.
- Exact boundary: after ModuleInterface nested validation moved from captured
  readers to exact semantic preparation, the complete SourceInterface prefix
  passed `39/40`. The sole failure was
  `NestedSemanticReadFailuresUseCapturedEnclosingFieldOffsets`, whose six semantic
  mutations deliberately expected Declarations/Imports/Dependencies collection
  offsets. That contradicted the frozen diagnostic-routing table, while its
  physical invalid-optional-tag case already expected the exact tag byte.
- Decision: retain every corruption scenario and the complete-output-reset check,
  rename the method to describe the current contract, and assert exact DataType
  qualifier, Parameter trait, Import ExpectedAbi, Dependency presence,
  Dependency ExpectedAbi and Dependency content offsets. Preserve exact physical
  tag routing independently; do not restore reader-time semantic checks or weaken
  the new focused table.
- Required evidence: preserve the `39/40` broad artifact, link the migrated test,
  pass it focused, then pass the same complete SourceInterface prefix.
- Discovery evidence: the official UE 5.8 Development Automation wrapper run at
  `Saved/Tests/cache-ic232-module-semantic-routing-sourceinterface-broad/20260809_203024_132_feb75fde`
  had total `40`, passed `39`, failed `1`, process exit `255`, wrapper exit `1`.
  Its first obsolete assertion expected parent byte `102` while production
  returned exact byte `291`.
- Closure evidence: the migrated test linked at
  `Saved/Build/cache-ic232-exact-nested-regression-build-attempt-1/20260809_203328_448_b1492ba2`
  (`4/4`, process/wrapper `0/0`), passed focused `1/1` at
  `Saved/Tests/cache-ic232-exact-nested-regression-green-attempt-1/20260809_203348_116_bae78983`,
  and the complete prefix passed `40/40`, failed/skipped `0`, process/wrapper
  `0/0` at
  `Saved/Tests/cache-ic232-exact-nested-sourceinterface-green-attempt-1/20260809_203426_964_3ff46014`.
- Task impact: verification-only after closure. Production exact-routing behavior
  remains the OpenSpec authority; IC-232's later closure evidence is recorded in
  its own final paragraph above.

## IC-237 — Duplicate/order fixture removed a namespace still used by its declaration

- Severity/state: test-fixture validity / closed.
- Exact boundary: the first complete captured-offset class run crashed while
  recomputing a malformed ModuleInterface ABI. The duplicate/order fixture had
  replaced `Engine`/`Gameplay` with unrelated namespace strings, while its retained
  declaration still named `Gameplay`; the producer-side hash helper correctly
  rejected that internally inconsistent setup before the target decoder assertion.
- Decision: keep both valid namespaces, reorder their physical rows only, and make
  the fixture refresh helpers return validation results so future fixture mistakes
  fail as ordinary assertions instead of `check` crashes. Do not weaken Runtime
  namespace validation.
- Required evidence: preserve the crash artifact, rebuild the corrected fixture,
  pass the intended duplicate/order method and the complete SourceInterface prefix.
- Closure evidence: the invalid fixture run is
  `Saved/Tests/cache-ic232-duplicate-order-captured-prefix-attempt-1/20260809_205428_974_e28b845a`.
  The corrected method passed at
  `Saved/Tests/cache-ic232-duplicate-order-focused-attempt-2/20260809_205636_336_2b8c76f1`,
  and the subsequent complete prefix passed `42/42` at the IC-232 path above.
- Task impact: test-only; no Runtime behavior was relaxed.

## IC-238 — Allocation test conflated retained, cumulative and combined-peak dimensions

- Severity/state: allocation-oracle test interpretation / closed.
- Exact boundary: the first executing allocation matrix observed `5766` bytes of
  SourceIndex retained allocations but `8790` total/peak decoded bytes. The initial
  assertion treated all three counters as the same quantity. It also enumerated
  only occurrence zero, so ModuleInterface's second namespace string allocation at
  byte `90` appeared to lack a published coordinate.
- Decision: preserve the Runtime accounting model. Retained bytes equal the sum of
  accepted physical allocations; TotalDecoded additionally remains monotonic over
  released validation scratch; the resident limit applies to the measured
  candidate-plus-scratch combined-live peak. Enumerate every captured occurrence,
  not just index zero. Do not hide the difference by refunding scratch or by
  weakening coordinate assertions.
- Required evidence: retain both diagnostic failures, then prove exact success,
  each limit one byte short, every accepted allocation origin, per-event failure
  rollback and broad regression.
- Closure evidence: the two diagnostic runs are
  `Saved/Tests/cache-ic232-allocation-origin-focused-attempt-1/20260809_210748_724_404173ef`
  and
  `Saved/Tests/cache-ic232-allocation-origin-focused-attempt-2/20260809_210927_178_cdf1118e`.
  The corrected matrix passed `1/1` at
  `Saved/Tests/cache-ic232-allocation-origin-focused-attempt-3/20260809_211115_576_fbdc7ec1`:
  SourceIndex reported `29` retained allocation events / `5766` bytes and
  ModuleInterface `36` / `5357`. The complete SourceInterface prefix then passed
  `43/43` at the IC-232 path above.
- Task impact: closes the practical AR-SCR-SI/MI vertical allocation gate without
  creating an empty/one/slack/many Cartesian matrix for every DTO field. The shared
  canonical codec's exhaustive TypeSchema allocation tests remain the mechanism
  breadth authority.

## IC-239 — Module-graph code assumed an equality operator for the opaque Profile key

- Severity/state: V1.4 compile integration / closed.
- Exact boundary: the first complete Development Editor build of the minimal
  `ValidateModuleSnapshotGraph` vertical compared two
  `FAngelscriptArtifactProfileKey` values directly. That wrapper deliberately
  exposes only its stable `Hash` and has no `operator==`, so MSVC rejected the
  CurrentResolver profile check before any graph behavior could execute.
- Decision: compare `State.Profile.Hash` with `Context.SelectedProfile.Hash`, as
  the surrounding cache identity code already does. Do not widen the artifact
  identity public API merely for one validator expression.
- Required evidence: preserve the official failed build, rebuild the complete
  target, then execute the graph context-mismatch behavior rather than treating a
  linked DLL as sufficient.
- Closure evidence: `Tools/RunBuild.ps1 -Label
  cache-v14-minimal-graph-green-build-attempt-1` failed at the exact expression in
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-1/20260809_212409_236_0324e39d`.
  After the identity comparison repair, the complete target ultimately passed at
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-3/20260809_212814_296_20b997b0`.
  The context-mismatch and missing-child rollback method passed as part of `2/2`
  at
  `Saved/Tests/cache-v14-minimal-graph-focused-attempt-1/20260809_212839_711_485e22f4`.
- Task impact: closes only the Profile comparison compile fault; it does not close
  TypeSchema/function/state/dependency graph coverage or V1.4.

## IC-240 — Exported graph validator and its friend declaration had different DLL linkage

- Severity/state: V1.4 public API compile integration / closed.
- Exact boundary: declaring `ValidateModuleSnapshotGraph` before the graph class
  removed the original redefinition diagnostic but did not make the later friend
  declaration inherit `ANGELSCRIPTRUNTIME_API` under MSVC. The second complete
  build therefore failed with C4273 `dll linkage inconsistent` in every consuming
  test unity translation unit.
- Decision: retain one exported public declaration before the graph class and give
  the exact friend declaration the same export macro. Do not expose the graph's
  candidate arrays or replace atomic construction with public setters to avoid the
  friend boundary.
- Required evidence: preserve both compile diagnostics, link Runtime and Test in a
  complete Editor target, then pass graph publication and failure-reset behavior.
- Closure evidence: the original different-linkage/redefinition diagnostic is in
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-1/20260809_212409_236_0324e39d`;
  the narrower C4273 reproduction is
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-2/20260809_212742_020_42c5ca6c`.
  The corrected target passed at
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-3/20260809_212814_296_20b997b0`,
  and the focused ModuleSnapshotGraph prefix passed `2/2`, failed/skipped `0`, at
  `Saved/Tests/cache-v14-minimal-graph-focused-attempt-1/20260809_212839_711_485e22f4`.
- Task impact: the public graph API now links across Runtime/Test module boundaries.
  This is the first V1.4 vertical only; all seven-kind graph authority remains open.

## IC-241 — Stable TypeKey equality wrapper does not define canonical ordering

- Severity/state: V1.4 TypeSchema graph compile integration / closed.
- Exact boundary: the first exact-coverage implementation sorted and merge-walked
  `FAngelscriptStableTypeKey` wrappers directly. They intentionally expose
  equality only, while canonical ordering belongs to their contained
  `FAngelscriptHash256`; the complete Development Editor build failed at both `<`
  expressions before the new TypeSchema RED could turn GREEN.
- Decision: retain the public identity wrapper and compare `TypeKey.Hash` for
  canonical ordering, matching Snapshot's existing local record comparator. Do
  not add a new wrapper operator solely for graph scratch.
- Required evidence: preserve the failed official build, link the same complete
  target, and run the exact declaration/link/reachability behavior.
- Closure evidence: the failed build is
  `Saved/Build/cache-v14-type-coverage-green-build-attempt-1/20260809_213715_154_24b10436`.
  The repaired complete target passed at
  `Saved/Build/cache-v14-type-coverage-green-build-attempt-2/20260809_213734_025_f3b1c3ee`.
  The focused graph prefix then passed `4/4`, failed/skipped `0`, at
  `Saved/Tests/cache-v14-type-coverage-green-attempt-1/20260809_213752_171_f5f6c5e4`.
- Task impact: closes the keyed TypeSchema coverage sort integration issue. The
  graph still accepts only simple Class/Struct/Interface schemas while deeper
  relation/property/method/reflection/layout closure remains fail-closed.

## IC-242 — Opaque summary ownership had no atomic graph-candidate budget path

- Severity/state: V1.4 architecture/budget correctness / closed on 2026-08-09.
- Exact boundary: the frozen opaque validator returned owning relocation,
  debug-source and canonical-byte arrays while receiving only the ordinary
  `FAngelscriptCacheReadBudget`. A codec could reserve temporary scratch, but it
  could not transfer that reservation to the module graph. Independently promoting
  returned arrays would leak retained accounting if a later graph/current check
  failed; letting the graph measure them after return would allocate before the
  budget decision; charging both would double count.
- Decision: expose a narrow `IAngelscriptCacheCandidateChargeSink` backed by the
  graph's one private `FDecodedCandidateTransaction` and pass that sink into
  `Validate`. Codec-local scratch still uses `Budget`; every capacity returned in
  `OutSummary` extends the sink before allocation and is never independently
  promoted. The codec cannot begin, inspect, promote, or close the transaction.
  Graph containers extend the same transaction and step 11 promotes it once.
  Remove compatibility with the four-argument development-only seam. The first
  API RED also proved that directly naming the private nested transaction would
  violate its intended access boundary; that form was discarded rather than
  making the transaction public.
- Required evidence: preserve the direct-private-type compile RED, then an intended
  override/API compile RED at the changed sink interface; deterministic
  fixture codec success; exact and one-byte-short summary capacity; codec failure
  and a later immutable/current failure both leaving graph empty, temporary bytes
  zero and no extra retained summary bytes; a complete graph prefix GREEN.
- Task impact: updates `record-wire-v1-remaining.md` and the capability spec before
  implementing FunctionBody/initializer/debug summaries. It does not change the
  opaque byte format or allow common graph code to parse VM bytes.
- Resolution/evidence: the discarded direct-private-transaction API failed at
  `Saved/Build/cache-ic242-opaque-candidate-api-red-build-attempt-1/20260809_214322_338_1e2c66db`;
  the narrowed public sink linked at
  `Saved/Build/cache-ic242-opaque-candidate-sink-green-build-attempt-1/20260809_214423_640_dad27b53`.
  `ValidateModuleSnapshotGraph` now owns the one private candidate transaction,
  charges each graph container before allocation, passes only the narrow sink to
  codecs and promotes once at step 11. The retained-summary fixture linked at
  `Saved/Build/cache-ic242-candidate-budget-build-attempt-1/20260809_220449_278_a0205e8a`
  and the complete graph prefix passed `7/7`, failed/skipped `0`, at
  `Saved/Tests/cache-ic242-candidate-budget-attempt-1/20260809_220516_248_38e1ca3a`.
  Its allocator-authoritative observation is `696` graph decoded bytes, `468`
  retained bytes, `8305` absolute peak-live bytes and `56` bytes of codec-owned
  empty-array slack. Exact limits pass; total/resident one byte short and a
  post-codec ABI failure leave OutGraph empty, temporary bytes zero and resident
  bytes at the decoded-token baseline. The production VM/debug/initializer codec
  and nonempty semantic summary validation remain later V1.4/V1.5 work, not part
  of this budget-path closure.

## IC-243 — Graph SourceIndex fixture omitted one ProviderKey identity coordinate

- Severity/state: V1.4 test-fixture identity correctness / closed on 2026-08-09.
- Exact boundary: adding a real SourceIndex file for nonempty Debug source-row
  coverage caused every graph fixture to fail before graph traversal with
  `DerivedHashMismatch`. The fixture built `FAngelscriptSourceProviderIdentityInput`
  from ProviderKind and CanonicalImplementationIdentity but omitted the required
  IdentityFingerprint coordinate. Production recomputation correctly rejected the
  internally inconsistent fixture.
- Decision: keep production validation unchanged and make the graph fixture use
  the same complete three-coordinate identity input as SourceInterface tests. Keep
  the diagnostic `checkf` so a future fixture-construction failure prints the
  validation class/kind/stage/offset instead of an opaque assertion.
- Required evidence: preserve the diagnostic failure, link the complete Editor
  target, prove the valid nonempty source row publishes, and prove missing
  SourceIndex membership/codec rows reject atomically.
- Resolution/evidence: the diagnostic failure is
  `Saved/Tests/cache-v14-debug-source-diagnostic-attempt-1/20260809_221723_571_7271386f`;
  the complete build passed at
  `Saved/Build/cache-v14-debug-source-fixture-fix-build-attempt-1/20260809_222106_018_9751d49e`;
  the graph prefix passed `10/10` at
  `Saved/Tests/cache-v14-debug-source-fixture-fix-prefix-attempt-1/20260809_222214_335_b30d6a12`.
- Task impact: closes only the fixture problem and the nonempty Debug source-row
  case. It does not broaden accepted production graph semantics.

## IC-244 — Local-only initializer fixture did not satisfy the frozen graph callable shape

- Severity/state: V1.4 test-fixture/cross-record contract / closed on 2026-08-09.
- Exact boundary: the first graph fixture was initially modeled after the older
  SourceInterface local-serialization helper, which gave a ModuleInitializer a
  normal Function slot and omitted the common `Generated` trait. That DTO is
  locally serializable because callable ownership/coverage is intentionally a
  graph-stage rule, but it is not a valid activatable initializer under the frozen
  declaration/unit/action contract in `record-wire-v1-remaining.md`.
- Decision: do not weaken or overload the local ModuleInterface serializer with
  cross-record ModuleState knowledge. Make the graph fixture use the frozen
  Generated-only, zero-reflection/metadata/slot, zero-parameter `void` shape and
  enforce that complete shape in the sole graph validator before publication.
  Keep initializer execution inside ModuleState and forbid an independent
  FunctionBody link.
- Required evidence: retain the intended initializer behavioral RED, link the
  complete Development Editor target after the fixture/production correction,
  and pass success plus missing/extra/ABI/opaque-hash atomic cases.
- Resolution/evidence: the RED prefix is
  `Saved/Tests/cache-v14-module-initializer-red-attempt-1/20260809_225045_372_ac765fda`;
  the corrected complete target is
  `Saved/Build/cache-v14-module-initializer-green-build-attempt-1/20260809_225627_159_1c975c56`;
  the graph prefix passed `13/13` at
  `Saved/Tests/cache-v14-module-initializer-green-attempt-1/20260809_225651_695_c5ccee44`.
- Task impact: closes the first module-initializer graph vertical only. It does not
  claim GlobalInitializer/global cleanup/dependency breadth, real compiler capture
  or lifecycle integration.

## IC-245 — CQTest assertion helper inside dependency fixture lambda needed the test instance

- Severity/state: V1.4 test-fixture compilation / closed on 2026-08-09.
- Exact boundary: the new dependency/current-resolver test extracted repeated
  atomic-failure assertions into a lambda that captured only the output graph.
  CQTest's `ASSERT_THAT` macro routes through the generated test-class instance,
  so MSVC correctly rejected each assertion because the lambda could not
  implicitly capture `this`. The failure occurred after Runtime linked and before
  any dependency behavior ran.
- Decision: keep the shared assertion helper, but explicitly capture `this` and
  the graph by reference. Do not change Runtime code or weaken assertions in
  response to a test-harness ownership error.
- Required evidence: preserve the failed complete-target build, then link the
  corrected fixture and obtain the intended behavioral RED from the focused
  dependency prefix before implementing production dependency support.
- Resolution/evidence: the diagnostic build is
  `Saved/Build/cache-v14-dependency-red-build-attempt-1/20260809_231312_818_01e6e818`.
  The fixture correction linked the complete UE 5.8 Development Editor target at
  `Saved/Build/cache-v14-dependency-red-build-attempt-2/20260809_231452_790_0c27f0f8`.
  The focused prefix then executed both intended cases and failed `0/2`,
  failed/skipped `2/0`, process/wrapper `255/1`, at
  `Saved/Tests/cache-v14-dependency-red-attempt-1/20260809_231523_094_7decf730`:
  production returned the former unsupported-dependency error `47` before either
  relocation/current-symbol rule existed.
- Task impact: fixture-only. It does not implement or validate dependency,
  relocation or current-symbol behavior.

## IC-246 — Step-10 dependency-loop ordinal shadowed the step-7 merge cursor

- Severity/state: V1.4 production compilation / closed on 2026-08-09.
- Exact boundary: `ValidateModuleSnapshotGraph` keeps the step-7
  `BodyLinkOrdinal` merge cursor in function scope. The first dependency-current
  implementation reused that identifier in two later `for` initializers. UE's
  MSVC configuration promotes C4456 shadowing to an error, so the complete
  target stopped before linking.
- Decision: retain the existing merge cursor and name the later iteration
  coordinate `DependencyBodyOrdinal`; it describes the separate step-10 owner
  walk and avoids weakening project warning policy.
- Required evidence: preserve the failed build, then link the corrected complete
  target and run both the dependency prefix and the established graph prefix.
- Resolution/evidence: the diagnostic build is
  `Saved/Build/cache-v14-dependency-green-build-attempt-1/20260809_232141_056_e3a96620`.
  The first mechanical rename matched the earlier opaque-codec body loop rather
  than the later dependency-count loop, so the same C4456 correctly remained at
  `Saved/Build/cache-v14-dependency-green-build-attempt-2/20260809_232227_347_a81091ce`;
  the second edit used the unique `FunctionDependencyCount` context and renamed
  the actual remaining declaration.
  The complete target then linked at
  `Saved/Build/cache-v14-dependency-green-build-attempt-3/20260809_232309_502_a6838b23`.
  The focused dependency prefix passed `2/2`, failed/skipped `0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v14-dependency-green-attempt-1/20260809_232327_298_53874c5f`;
  the established graph prefix independently remained `13/13` GREEN at
  `Saved/Tests/cache-v14-dependency-graph-regression-attempt-1/20260809_232711_164_fac2afc2`.
- Task impact: naming/compilation only. It changes no graph ordering or
  dependency semantics.

## IC-247 — Selected-module Function dependencies were rejected in current eligibility

- Severity/state: V1.4 immutable/current precedence / closed on 2026-08-09.
- Exact boundary: the first external-current vertical recognized a dependency
  whose StableKey belonged to the selected ModuleInterface, but deliberately
  returned `GraphAbiMismatch` from the later step-10 walk because no immutable
  ABI authority was implemented yet. That both rejected a valid local function
  call and allowed selected source/profile mismatch to win before the stored
  declaration contradiction, contrary to the frozen step-9-before-step-10 order.
- Decision: resolve selected-module `ScriptFunction` rows against the sorted
  immutable function-declaration index before source/profile eligibility. Compare
  `ExpectedAbi` with the target declaration `SignatureHash`; when explicit
  content is present, require a linked body and compare its execution hash. Skip
  the already graph-closed row in step 10 so it makes zero current-symbol calls.
  Keep the other local ScriptType/Global/Property/Import authorities fail-closed
  until their exact graph verticals exist.
- Required evidence: one valid local function dependency succeeds with zero
  current-symbol calls; a wrong local ABI paired with deliberately wrong selected
  source/profile still reports `GraphAbiMismatch/ModuleGraph`, publishes nothing
  and releases all temporary ownership; external current behavior and the full
  established graph prefix remain GREEN.
- Resolution/evidence: the complete Development Editor test source linked before
  production support at
  `Saved/Build/cache-v14-local-function-dependency-red-build-attempt-1/20260809_233330_415_2629f264`.
  The focused prefix preserved the previous `2/2` methods and failed only the new
  method at
  `Saved/Tests/cache-v14-local-function-dependency-red-attempt-1/20260809_233356_033_74a3a6de`
  (`3/2/1/0`, process/wrapper `255/1`). Production linked at
  `Saved/Build/cache-v14-local-function-dependency-green-build-attempt-1/20260809_233539_999_96f6240f`;
  the focused prefix passed `3/3` at
  `Saved/Tests/cache-v14-local-function-dependency-green-attempt-1/20260809_233558_558_9b6d684c`,
  and the established graph prefix passed `13/13` at
  `Saved/Tests/cache-v14-local-function-dependency-graph-regression-attempt-1/20260809_233841_325_096c80aa`.
- Task impact: closes selected-module FunctionBody-to-ScriptFunction dependency
  ABI/content and precedence only. It does not close selected-module type/global/
  property/import authority, non-FunctionBody dependency owners or CurrentLayouts.

## IC-248 — Manifest/Pack RED fixture hard-asserts the stubbed pack builder

- Severity/state: V2.1 test-harness RED observability / closed on 2026-08-10.
- Exact boundary: the first corrected focused command
  `Tools\\RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache.PackFormat
  -Label cache-v21-pack-format-red-attempt-1 -TimeoutMs 600000` reached the
  behavior tests, but `MakeZeroModuleGenerationFixture()` calls
  `check(BuildAngelscriptCachePacks(...).IsSuccess())`. Because all production
  Pack/Manifest functions are still declaration-frontier stubs, randomized test
  execution reached that helper after several ordinary failures and terminated
  the Editor process at test line 690 instead of reporting the complete RED
  matrix. The artifact is
  `Saved/Tests/cache-v21-pack-format-red-attempt-1/20260810_004701_684_8364c458`
  (Development Editor, process/wrapper `3/1`).
- Decision: implement and independently validate the deterministic Pack builder
  first because it is both production functionality and the shared fixture
  prerequisite. Do not reinterpret the crash as a Runtime product crash or use
  it as behavioral GREEN. Once construction is GREEN, rerun the complete prefix;
  if another production prerequisite can still trip a test-process `check`, move
  that fixture precondition behind a nonfatal CQTest assertion or a fallible
  helper without weakening the tested contract.
- Required evidence: complete target link; focused Pack-construction methods
  execute without process assertion; eventually the full PackFormat prefix
  reports all discovered tests and no process/wrapper failure. Preserve the RED
  artifact and the earlier no-match diagnostic separately.
- Task impact: the hard assertion obscures breadth only. It does not change the
  frozen Manifest/Pack wire or justify a narrower implementation.
- Resolution/evidence: the real Pack prerequisite removed the assertion path. The
  complete prefix later executed all `26` methods with process/wrapper `0/0` and
  passed `26/26` at
  `Saved/Tests/cache-v21-generation-green-attempt-1/20260810_011249_433_048e522c`.

## IC-249 — Two Pack malformed fixtures violated an earlier frozen invariant

- Severity/state: V2.1 executable-authority consistency / closed on 2026-08-10.
- Exact boundary: after the first real Pack implementation linked, the focused
  prefix reached `13/26` at
  `Saved/Tests/cache-v21-pack-core-mixed-attempt-1/20260810_005518_063_19132525`.
  Two Pack-focused methods failed because their mutations were not isolated:
  `LaterRangePastEof` increased a None entry's `StoredSize` without increasing
  `RawSize`, so the normative per-codec size check owned the earlier failure;
  `TrailingZlib` changed the complete pack bytes/expected PackId but retained the
  old PackId in its manifest location, so manifest-to-pack association failed
  before canonical decompression. Both outcomes follow the frozen Pack
  precedence even though the assertions expected the later fault.
- Decision: preserve production fail-fast ordering. For the EOF row, mutate both
  None StoredSize and RawSize so their equality remains valid and the range alone
  crosses EOF. For the trailing-zlib row, update the manifest location PackId to
  the mutated complete pack's expected ID while retaining the increased stored
  range, so canonical recompression is the first contradiction. Do not move pack
  association or codec-size validation later merely to satisfy an ambiguous
  hostile fixture.
- Required evidence: the two corrected cases pass with their original intended
  errors/absolute offsets; all previously GREEN Pack byte-golden, codec and
  budget cases remain GREEN; the complete prefix continues to expose only the
  intentionally unimplemented Manifest decode/generation/reachability surface.
- Resolution/evidence: both corrected range/canonical-Zlib rows and all adjacent
  byte-golden, codec and budget rows passed in the final `26/26` prefix at
  `Saved/Tests/cache-v21-generation-green-attempt-1/20260810_011249_433_048e522c`.
- Task impact: test mutation isolation only. Pack wire bytes, production
  validation precedence and public API remain unchanged.

## IC-250 — Checksum and RecordId Pack fixtures retained the pre-mutation PackId

- Severity/state: V2.1 executable-authority consistency / closed on 2026-08-10.
- Exact boundary: the first linked reachability run completed all `26` methods
  without a process assertion and reached `18/26` at
  `Saved/Tests/cache-v21-reachability-green-attempt-1/20260810_010231_005_2add145b`.
  In `PackOrderDuplicatePackIdLocationCodecChecksumAndRecordIdFailuresPrecedeDecode`,
  the `WrongChecksum` and `WrongRecordId` fixtures mutate bytes inside the complete
  pack and pass the recomputed outer expected PackId, but their manifest locations
  still named the original frozen PackId. The frozen Pack precedence therefore
  correctly returned the earlier PackId-association `PackIndexMismatch` instead of
  reaching `ChecksumMismatch` or `RecordIdMismatch`.
- Decision: preserve the production precedence and whole-file PackId identity.
  Update each mutated fixture's manifest-location PackId to the direct hash of the
  mutated complete pack, exactly as already required for the trailing-Zlib fixture.
  Keep the mutated checksum/RecordId fields so the intended later contradiction is
  isolated.
- Required evidence: the corrected checksum and semantic RecordId rows report their
  intended errors and absolute pack-index offsets; all earlier location, codec,
  canonical-Zlib, budget and byte-golden rows remain GREEN.
- Task impact: test mutation isolation only. No production wire, identity or
  validation-order change is authorized by this issue.
- Resolution/evidence: the corrected checksum and semantic RecordId mutations now
  reach their intended later failures, while the complete `PackFormat` matrix
  passed `26/26` with process/wrapper `0/0` at
  `Saved/Tests/cache-v21-generation-green-attempt-1/20260810_011249_433_048e522c`.

## IC-251 — Generation decoded records promote before reachability and revalidate Packs per record

- Severity/state: V2.1 publication atomicity and startup-performance defect /
  closed on 2026-08-10.
- Exact boundary: the frozen `PackFormat` matrix passed `26/26` at
  `Saved/Tests/cache-v21-generation-green-attempt-1/20260810_011249_433_048e522c`,
  and adjacent Module/Graph plus SourceInterface regressions passed `30/30` and
  `43/43`. A post-GREEN code audit then found two linked defects in
  `ValidateAngelscriptCacheGeneration`: it calls the public standalone record read
  for every selected record, so each call rebuilds the index and recomputes the
  whole PackId even though that distinct Pack was already validated; and the sole
  decoded-record factory promotes each handle before generation reachability is
  known. A later `UnexpectedRecord` therefore clears the public generation output
  but leaves failed-candidate bytes counted as retained.
- Decision: add a shared decoded-record batch candidate backed by one existing
  Budget transaction. Pack reads inside a generation must decode into that batch
  without promotion; exact reachability succeeds before the batch promotes once.
  Split the pack read into a validated-index internal path so the public standalone
  API still validates once, while generation validates each distinct Pack once and
  reuses its immutable index for all selected records. Do not add a second decoder,
  weaken whole-file PackId, or special-case the extra-record test.
- Required evidence: the historical-extra generation failure reports
  `UnexpectedRecord/ManifestGraph`, publishes no output and leaves both retained
  and temporary resident bytes at zero; success still satisfies every exact/one-
  short cumulative Budget boundary; one distinct Pack source call remains exact;
  complete `PackFormat`, Module and SourceInterface prefixes remain GREEN.
- Task impact: V2.1 is reopened until the aggregate candidate and validate-once
  read path are linked and verified. Saved Store and real compiler capture remain
  outside this correction.

- Resolution/evidence: the intended RED at
  `Saved/Tests/cache-v21-ic251-red-attempt-1/20260810_011839_331_a7476d97`
  failed the late-reachability retained-ownership assertion. The first GREEN
  compile exposed only a missing unit-test access friendship at
  `Saved/Build/cache-v21-ic251-green-build-attempt-1/20260810_012142_218_f3779b18`;
  after limiting that friendship to the test build, the complete Development
  Editor target linked at
  `Saved/Build/cache-v21-ic251-green-build-attempt-2/20260810_012220_667_3b5a488b`.
  The focused correction passed `1/1` at
  `Saved/Tests/cache-v21-ic251-green-attempt-1/20260810_012246_170_af0c7a7f`,
  the complete PackFormat prefix passed `26/26` at
  `Saved/Tests/cache-v21-ic251-final-attempt-1/20260810_012320_017_f0d7ee62`,
  and the post-correction Module and SourceInterface prefixes passed `30/30` and
  `43/43` at
  `Saved/Tests/cache-v21-ic251-module-regression-attempt-1/20260810_012707_664_ed85ef7e`
  and
  `Saved/Tests/cache-v21-ic251-source-interface-regression-attempt-1/20260810_012744_427_98eeb7b9`.
  Generation now validates each distinct Pack once, decodes all selected records
  into one transaction and promotes that batch only after exact reachability.

## IC-252 — Manifest and Pack index arrays allocate before the cumulative Budget reservation

- Severity/state: V2.1 memory-boundary and hostile-input defect / closed on
  2026-08-10.
- Exact boundary: the IC-251 post-GREEN audit found that `DecodeManifest()` calls
  `Reserve()` for keyed roots, record locations, a record-count-sized sorted
  PackId array and the retained distinct-PackId array before the caller reserves
  their decoded/live bytes. The later generation reservation charges roots and
  records only after those allocations already exist and omits both PackId arrays.
  Independently, `ValidateAngelscriptCachePack()` explicitly discards its Budget
  argument and allocates its returned pack-index array without any decoded/live
  charge. These behaviors contradict the frozen rule that every candidate DTO,
  index and distinct-ID allocation is reserved before allocation under the one
  cumulative read session.
- Decision: split structural count/size preflight from allocation. Reserve the
  exact retained manifest/output arrays and temporary sorted/distinct PackId
  arrays before their respective `TArray::Reserve` calls; preserve those
  reservations through validation, release scratch on every exit, and promote
  only the final generation-owned arrays. Give standalone Pack-index validation
  an exact pre-allocation reservation and promotion for its returned index, while
  generation and standalone record reads use an internal caller-precharged index
  validator so temporary indexes do not become retained or double charged.
- Required evidence: new tests fail on the current implementation and then prove
  exact-capacity success, one-byte-short pre-allocation failure, monotonic decoded
  accounting, zero temporary ownership after failure, no pack lookup on manifest
  budget failure and no double charge in the existing complete-generation exact
  boundary. The complete PackFormat, Budget, Module and SourceInterface prefixes
  remain GREEN after the correction.
- Task impact: V2.1 remains open through IC-252. Saved Store implementation must
  not begin on top of an unbounded Manifest/Pack index reader.

- Resolution/evidence: the Development Editor test source linked at
  `Saved/Build/cache-v21-ic252-red-build-attempt-1/20260810_013235_297_819f0310`.
  The intended focused RED then failed the first exact Pack-index accounting
  assertion (`1/0/1/0`, process/wrapper `255/1`) at
  `Saved/Tests/cache-v21-ic252-red-attempt-1/20260810_013254_404_e20374cb`.
  Production linked at
  `Saved/Build/cache-v21-ic252-green-build-attempt-1/20260810_013830_558_f328c1b8`
  and the focused method passed `1/1` at
  `Saved/Tests/cache-v21-ic252-green-attempt-1/20260810_013849_273_29653429`.
  The first complete PackFormat rerun exposed two stale raw-only budget
  expectations (`25/27`) at
  `Saved/Tests/cache-v21-ic252-packformat-final-attempt-1/20260810_013924_677_e3106f7c`:
  both correctly observed the newly charged 96-byte temporary Pack index. After
  rewriting those expectations to verify the combined index-plus-raw live peak,
  the test-only correction linked at
  `Saved/Build/cache-v21-ic252-regression-fixture-build-attempt-1/20260810_014041_061_7f5544e6`
  and PackFormat passed `27/27` at
  `Saved/Tests/cache-v21-ic252-packformat-final-attempt-2/20260810_014059_588_c31faf0c`.
  Adjacent Budget, Module, SourceInterface and DecodedRecordDeclaration prefixes
  passed `16/16`, `30/30`, `43/43` and `1/1` at
  `Saved/Tests/cache-v21-ic252-budget-regression-attempt-1/20260810_014143_368_ac32c1c4`,
  `Saved/Tests/cache-v21-ic252-module-regression-attempt-1/20260810_014218_392_5c648f70`,
  `Saved/Tests/cache-v21-ic252-source-interface-regression-attempt-1/20260810_014252_974_797b1b3a`
  and
  `Saved/Tests/cache-v21-ic252-decoded-record-regression-attempt-1/20260810_014326_668_0db00eb9`.

## IC-253 — Canonical-Zlib verification scratch and duplicate reachability work can exceed their charge

- Severity/state: V2.1 hostile-input memory-boundary defect / closed on
  2026-08-10.
- Exact boundary: after IC-252, `ReadRecordFromValidatedPack()` still asks the
  variable-output writer codec to create an uncharged recompression `TArray` and
  compares it through `TArray<uint8>(Stored)`, which allocates a second uncharged
  copy. A malformed compressed stream or injected codec therefore operates
  outside TotalDecoded/combined-live accounting even though its expected stored
  length is known. Separately, generation reachability reserves `RecordCount`
  pending ordinals but marks a target visited only when popped; repeated roots or
  links may enqueue the same ordinal multiple times and grow the queue beyond the
  fixed scratch charge before later graph ownership rejects the candidate.
- Decision: extend the internal storage-codec seam with a fixed-output canonical
  Zlib compressor used only by reads. Reserve exactly StoredSize before creating
  its output, require the reported size to equal StoredSize, compare views without
  another allocation and release the scratch on every exit. Keep the existing
  variable-output method for deterministic writers. Mark reachability ordinals
  when enqueued so every manifest record enters the bounded pending array at most
  once; visited/reachable meaning remains identical.
- Required evidence: canonical-mismatch input charges `PackIndex + RawSize +
  StoredSize`, exact capacity reaches the mismatch, one byte short reports
  `BudgetExceeded/PackDecode` before recompression allocation, all temporary
  ownership returns to zero, and the codec interface shape remains compile-time
  checked. Exact/missing/wrong-kind/unreachable/duplicate reachability fixtures,
  complete PackFormat and adjacent regressions remain GREEN.
- Task impact: V2.1 remains open through IC-253; no wire bytes, PackId, RecordId,
  GenerationId or accepted canonical Zlib stream changes.

- Resolution/evidence: the Development Editor test source linked at
  `Saved/Build/cache-v21-ic253-red-build-attempt-1/20260810_014747_959_4fc4a9f9`.
  The intended focused RED failed the new canonical-verification decoded-budget
  assertion at
  `Saved/Tests/cache-v21-ic253-red-attempt-1/20260810_014808_639_19d31f3d`
  (`1/0/1/0`, process/wrapper `255/1`). The fixed-output codec seam, explicit
  StoredSize reservation, allocation-free comparison and enqueue-time reachability
  deduplication linked at
  `Saved/Build/cache-v21-ic253-green-build-attempt-1/20260810_014948_242_7bf97904`.
  The focused method passed `1/1` at
  `Saved/Tests/cache-v21-ic253-green-attempt-1/20260810_015008_928_80417c20`
  and the complete PackFormat prefix passed `27/27`, failed/skipped `0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v21-ic253-packformat-final-attempt-1/20260810_015042_611_77e41215`.
  The byte-level wire and all external IDs remain unchanged.

## IC-254 — Complete Cache prefix exposes the still-open TypeSchema matrix and a fixture hard assertion

- Severity/state: V1 complete-artifact regression gate / open on 2026-08-10.
- Exact boundary: after IC-253's focused and complete PackFormat GREEN, the first
  unified `Angelscript.TestModule.Cache` run discovered `244` methods. It started
  `167`, completed `149` successes and `17` ordinary failures, then terminated
  with process/wrapper `3/1` when
  `GetResolvedTsScrRepresentativeFixturesForTests()` hard-asserted that
  `SerializeTypeSchema()` succeeded at `AngelscriptCacheTypeSchemaTests.cpp:4885`.
  The artifact is
  `Saved/Tests/cache-v21-complete-cache-regression-attempt-1/20260810_015123_950_0a79dbc9`.
  One ordinary failure is the already-open IC-227 Archive.Primitives allocator-
  capacity witness. The remaining `16` are the broad TypeSchema/IC-214 surface:
  behavior/method/VFT/relations/properties, exact offsets and TS-SCR dependency/
  budget closure. PackFormat `27/27`, Budget `16/16`, Module `30/30`,
  SourceInterface `43/43` and DecodedRecordDeclaration `1/1` passed independently
  against the same linked implementation, so this is not evidence of an IC-253
  Pack/Manifest regression; it is stronger evidence that V1.1–V1.6 cannot yet be
  called complete.
- Decision: preserve the unified run as the new broad baseline. Replace the
  fixture hard assertion with a fallible test precondition only while diagnosing,
  determine the first producer/fixture semantic contradiction through focused
  TypeSchema runs, and repair production or stale expectations by frozen
  authority rather than bulk-changing offsets. Rerun the complete TypeSchema
  class without process termination, then the full 244-method Cache prefix.
- Required evidence: zero hard assertions; every discovered TypeSchema method
  completes; failures are reduced through focused RED/GREEN artifacts; final
  `Angelscript.TestModule.Cache` reports all discovered methods, failed/skipped
  zero and process/wrapper `0/0`.
- Task impact: IC-254 blocks V1.6, real clean-module capture and final Cache V2
  acceptance. It does not reopen the already scoped Pack/Manifest wire behavior.
- Progress on 2026-08-10: a new nonfatal
  `TsScrRepresentativeFixturesRemainLocallySerializable` diagnostic reduced the
  hard assertion to exactly fixture `44`, family `11`, variant `3`, cardinality
  `21`, with local `ConflictingKey`. The RED is
  `Saved/Tests/cache-ic254-ts-scr-diagnostic-attempt-1/20260810_015929_078_856bc219`.
  Its inheritance target key range reached the owning Class TypeKey `0x51` at
  index `17`, accidentally modeling self-inheritance. Moving only that test
  fixture range away from the owner preserved its 21-row allocation shape and
  production validation. The linked build passed at
  `Saved/Build/cache-ic254-ts-scr-fixture-green-build-attempt-1/20260810_020125_432_b23141e0`
  and the diagnostic passed `1/1` (all `45/45` fixtures serializable) at
  `Saved/Tests/cache-ic254-ts-scr-fixture-green-attempt-1/20260810_020141_909_849e9447`.
  The complete TypeSchema class then finished without a process assertion at
  `Saved/Tests/cache-ic254-typeschema-regression-attempt-1/20260810_020225_238_f552cad5`:
  total `66`, passed `48`, failed `18`, skipped `0`. The two newly visible TS-SCR
  failures were previously hidden behind static initialization, so `18` is the
  first complete class baseline rather than evidence of two new Runtime regressions.
  IC-254 remained open at that checkpoint. The later IC-255 closure below brings
  the complete current TypeSchema prefix to GREEN; IC-227 and the complete Cache
  prefix are still separate broad-regression gates.

## IC-255 — TypeSchema exact allocation and reference authorities encoded allocator hints and invalid Behavior variants

- Severity/state: V1 hostile-input accounting and independent-test-authority
  defect / closed on 2026-08-10.
- Exact boundary: the remaining TypeSchema/TS-SCR failures were not one defect.
  `GetDecodedControllerCharge()` and one public-factory test treated
  `FMemory::QuantizeSize` as an exact allocation charge even though the UE 5.8
  allocator reported `960` quantized bytes and an actual `1024`-byte controller
  allocation. `DecodePhysical()` reserved nine `FlatHeaderOffsets` entries but
  appended ten, permitting the final header coordinate to grow outside Budget.
  The independent TS-SCR plan used two coordinates as if allocation failure
  offset and stable-reference visibility were always identical, although the
  secondary nested-property/selected-arm/reflection indexes become visible only
  after later fields. Finally, the frozen family-8 reference whitelist admitted
  both forbidden `TemplateCallback` variants `33/34` and omitted the two valid
  `ReleaseRefs` variants `53/54`. The family-11 excluded-dependency fixture also
  omitted `GlobalStorage.ExpectedContentOrValue`, so it failed for the wrong local
  semantic reason.
- Decision: calibrate the actual intrusive-controller allocation once per process
  with the same size/alignment request and use `QuantizeSize` only as a defensive
  fallback; this occurs before the real hostile-input candidate allocation and
  retains budget-before-allocation ordering. Reserve all ten header offsets.
  Keep independent error coordinates separate from reference-visibility
  coordinates. Freeze the valid family-8 closure as all non-TemplateCallback
  ScriptFunction/owner rows plus exactly the environment-capable no-owner rows,
  including `ReleaseRefs`. Complete excluded dependency fixtures must populate
  every field required by their own dependency kind.
- Required evidence: an intended RED must expose the ten-versus-nine header
  reserve and exact total/resident deltas; actual controller charge must agree
  with an independent raw allocator request; every late failure and one-short
  path must restore all ownership; all 78 valid reference fixtures and every
  relocation prefix must pass; the complete TypeSchema prefix must finish without
  assertion or failure.
- Task impact: this closes the TypeSchema/TS-SCR portion of IC-254 and permits the
  complete Cache prefix to become the next V1 regression authority. It does not
  by itself prove ModuleSnapshot graph closure, Saved Store, compiler capture or
  lifecycle behavior.
- Resolution/evidence: the dependency/controller correction first passed `9/11`
  at
  `Saved/Tests/cache-ic254-ts-scr-four-fixes-focused-attempt-1/20260810_024521_500_84196e71`.
  Diagnostic chronology then identified the behavior parallel-offset factor and
  delayed reflection-index visibility at
  `Saved/Tests/cache-ic254-ts-scr-chronology-diagnostic-attempt-1/20260810_024920_670_56440117`.
  The explicit ten-header expectation produced the intended `5/11` RED with a
  first `expected 10 / actual 9` mismatch and consistent 24-byte deltas at
  `Saved/Tests/cache-ic255-flat-header-growth-red-attempt-1/20260810_025125_562_87b33ba6`.
  After the production reserve became ten, the dual error/visibility coordinate
  model reached `10/11` at
  `Saved/Tests/cache-ic255-dual-coordinate-green-attempt-1/20260810_025410_000_349f43f5`.
  Two subsequent `10/11` runs exposed the forbidden TemplateCallback authorities,
  ending at
  `Saved/Tests/cache-ic255-valid-reference-closure-attempt-1/20260810_025533_527_209c5d2e`.
  Auditing the complete 17-kind product replaced variants `33/34` with valid
  ReleaseRefs variants `53/54`; the final TS-SCR prefix passed `11/11` at
  `Saved/Tests/cache-ic255-reference-authority-green-attempt-1/20260810_030043_067_a3eb367f`.
  The complete prefix then exposed one stale public-factory `QuantizeSize`
  assertion (`66/67`) at
  `Saved/Tests/cache-ic255-typeschema-full-green-attempt-1/20260810_030120_048_d5538d96`.
  Its independent actual-allocation witness passed `1/1` at
  `Saved/Tests/cache-ic255-public-factory-controller-green-attempt-1/20260810_030325_784_7ab86522`,
  and the complete current TypeSchema prefix passed `67/67`, failed/skipped zero,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-ic255-typeschema-full-green-attempt-2/20260810_030403_223_eb384cce`.
  The final linked Development Editor build is
  `Saved/Build/cache-ic255-public-factory-controller-green-build-attempt-1/20260810_030304_668_3b3f9425`.

## IC-256 — Empty-string NUL probing rejected every canonical Store root

- Severity/state: V2.2 Saved Store root-construction defect / closed on
  2026-08-10.
- Exact boundary: the first `Angelscript.TestModule.Cache.Store` runtime execution
  linked successfully but `BuildAngelscriptCacheStorePaths()` returned
  `InvalidRoot/RootValidation` for the canonical absolute test root
  `D:/Project/Saved/Angelscript/CacheV2`. The validator used
  `Path.Contains(TEXT("\0"))`; the C-string view ends at that leading NUL, so the
  API receives an empty search string and treats every nonempty path as a match.
  This made the newly added writable Store impossible even though the compile-only
  gate was GREEN.
- Decision: inspect the counted `FString` characters directly and reject only an
  actual embedded zero code unit. Keep absolute-path, forward-separator, dot-
  segment and canonical-platform-seam checks separate so an input validation
  failure identifies the real invariant.
- Required evidence: retain the original exact full-hash namespace test, observe
  its runtime `InvalidRoot` failure, then pass it without weakening any expected
  path or lower-case 64-hex assertion.
- Task impact: this closes only the first V2.2 namespace-construction slice. It
  does not prove override/default-root resolution, temp parsing, immutable object
  installation, pointer publication or a production platform seam.
- Resolution/evidence: the missing-API TDD build failed as intended at
  `Saved/Build/cache-v2-store-paths-red-attempt-1/20260810_031738_249_27e83ecf`.
  The first linked implementation exposed the runtime defect at
  `Saved/Tests/cache-v2-store-paths-green-attempt-1/20260810_031950_865_3fdf4314`;
  the diagnostic rerun fixed the result at `error=1 stage=1` in
  `Saved/Tests/cache-v2-store-paths-diagnostic-attempt-1/20260810_032127_728_b0835afc`.
  The counted-character repair linked at
  `Saved/Build/cache-v2-store-paths-green-build-attempt-2/20260810_032216_588_a64e17a4`
  and the Store prefix passed `1/1`, failed/skipped `0/0`, process/wrapper `0/0`,
  at
  `Saved/Tests/cache-v2-store-paths-green-attempt-2/20260810_032232_335_847b4f99`.

## IC-257 — The frozen atomic-file seam could not perform its required own-temp cleanup

- Severity/state: V2.2 filesystem fault-containment contract gap / closed on
  2026-08-10.
- Exact boundary: `store-publication-v1.md` requires a writer to record every
  temp it creates and attempt to delete only those exact paths on local failure,
  but the frozen injectable seam exposed write/read/rename/pointer/sync only.
  Calling `IFileManager` directly from Store control flow would bypass the
  deterministic filesystem seam and make cleanup faults untestable. The first
  compile RED proves the missing boundary because the fake filesystem's
  `RemoveOwnTemp(...) override` has no base virtual method.
- Decision: add one narrow `RemoveOwnTemp(ExactTempPath)` seam operation. Store
  code may call it only for a strict temp path built from the current validated
  WriterToken; it never accepts a final object, pointer slot, directory or glob.
  Cleanup failure remains secondary diagnostic state and never masks the primary
  write/read/content/rename error.
- Required evidence: truncate a successful `WriteFlushClose` result, reopen the
  physical temp, fail real Pack validation before rename, call exactly one temp
  removal, leave no final object, and preserve `ContentValidationFailed/PackTemp`
  plus its nested archive result.
- Task impact: V2.2 cannot claim fault-contained immutable installation until this
  is GREEN. It changes no Pack/Manifest/pointer bytes and does not authorize broad
  deletion.
- Resolution/evidence: the missing seam produced the intended compile RED at
  `Saved/Build/cache-v2-store-temp-cleanup-red-attempt-1/20260810_033753_191_c06734dd`.
  After adding only `RemoveOwnTemp(ExactTempPath)`, the Development Editor target
  linked at
  `Saved/Build/cache-v2-store-temp-cleanup-green-build-attempt-1/20260810_033906_140_6beb2af4`.
  The Store prefix passed `8/8`, failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v2-store-temp-cleanup-green-attempt-1/20260810_033923_067_e7adde8a`.
  Its corrupt-temp case performed one exact own-temp removal, no rename and no
  final-object mutation while preserving `ContentValidationFailed/PackTemp` and
  the nested Pack validation result. The later Manifest slice remains GREEN in
  the `9/9` evidence under IC-258.

## IC-258 — The zero-module Manifest fixture used an arbitrary derived Profile key

- Severity/state: V2.2 test-fixture identity-authority defect / closed on
  2026-08-10.
- Exact boundary: the first runtime execution of the new immutable Manifest
  install test terminated at `AngelscriptCacheStoreTests.cpp:214` before entering
  `PutAngelscriptCacheManifestIfAbsent()`. The fixture assigned a repeated-byte
  placeholder to `Manifest.Profile`, but the production encoder requires Profile
  to equal the canonical `BuildArtifactProfileKey(Compatibility, Context)`
  derivation. Consequently the fixture's hard `check` observed
  `DerivedHashMismatch`; this was neither a Store publication fault nor grounds
  to weaken Manifest validation.
- Decision: build fixture Profile through the same public artifact-identity
  authority used by production. Keep the complete encoder validation active and
  keep the runtime Store test responsible for the missing-final flow: write,
  flush/close, reopen, validate the Manifest plus its final Pack, no-replace
  rename, directory sync, final reopen and complete revalidation.
- Required evidence: retain the initial process failure, rebuild after only the
  fixture correction, and pass the complete Store prefix including the Manifest
  operation sequence. The test must make both pre-install and post-install
  Manifest validations resolve the referenced Pack from its final path.
- Task impact: this repairs the test oracle and proves the current in-memory seam
  for immutable Manifest installation. It does not prove production filesystem
  durability, pointer publication, writer locking, read-session pinning or real
  Saved-directory behavior.
- Resolution/evidence: the production Manifest implementation first linked at
  `Saved/Build/cache-v2-store-manifest-install-green-build-attempt-1/20260810_034215_769_bdf95afa`,
  while the invalid fixture terminated the first runtime attempt at
  `Saved/Tests/cache-v2-store-manifest-install-green-attempt-1/20260810_034234_677_c62ad313`.
  The authoritative Profile correction linked at
  `Saved/Build/cache-v2-store-manifest-fixture-green-build-attempt-1/20260810_034610_467_120aa967`.
  The complete Store prefix then passed `9/9`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v2-store-manifest-install-green-attempt-2/20260810_034634_256_49d26b31`.

## IC-259 — The atomic-file seam could not create a first-launch namespace

- Severity/state: V2.2 first-launch filesystem contract gap / closed on
  2026-08-10.
- Exact boundary: the required Saved-first product starts with no Cache V2 root,
  namespace, `Packs` or `Generations` directories. The frozen atomic-file seam
  could write an already reachable temp but had no injectable directory-creation
  operation. Hand-creating directories in the disk test or inside Win64 Store
  control flow would hide this product boundary, bypass fault injection and make
  the first end-user launch depend on unspecified external setup.
- Decision: add one idempotent `EnsureDirectoryTree(ExactDirectoryPath)` operation.
  Store code supplies only its already constructed Base, Namespace, Packs and
  Generations paths after namespace-lock acquisition. After creation it
  re-canonicalizes Namespace/Packs/Generations and requires exact equality with
  the precomputed identity descendants, so a junction/symlink alias cannot
  silently redirect publication. The operation accepts no glob and removes
  nothing.
- Required evidence: a test begins below a genuinely missing `FirstLaunch/CacheV2`
  base, builds paths using the production seam, invokes one Store directory API
  and observes all four directories. The intended compile RED must show that the
  API did not previously exist; the green run must use the physical Saved tree.
- Task impact: V2.2 and the user's first-launch requirement cannot close until
  this is GREEN. The final production call still belongs inside V2.3's namespace
  lock; a standalone directory test does not prove writer serialization.
- Resolution/evidence: the missing Store directory API produced the intended
  compile RED at
  `Saved/Build/cache-v2-store-first-launch-directories-red-attempt-1/20260810_035423_192_10ec3f0b`.
  The Win64 production seam and exact Store directory boundary linked at
  `Saved/Build/cache-v2-store-first-launch-directories-green-build-attempt-1/20260810_035625_962_60732ecb`.
  The real Saved directory prefix passed `3/3`, including a missing-base first
  launch, at
  `Saved/Tests/cache-v2-store-first-launch-directories-green-attempt-1/20260810_035648_039_a73d5ea2`.
  A subsequent physical Pack+Manifest install/reuse test passed `4/4` at
  `Saved/Tests/cache-v2-store-real-generation-green-attempt-1/20260810_035834_725_528314e3`.
  The combined Store prefix passed `13/13` at
  `Saved/Tests/cache-v2-store-v22-complete-green-attempt-1/20260810_035909_690_48032542`,
  and the complete Cache prefix passed `258/258` at
  `Saved/Tests/cache-v2-store-v22-full-cache-green-attempt-1/20260810_035954_026_4c7d56d2`;
  every run had failed/skipped and process/wrapper counts `0/0`.

## IC-260 — CQTest could not format the stable hash value used by the Pointer round-trip assertion

- Severity/state: V2.3 test-oracle integration defect / closed on 2026-08-10.
- Exact boundary: the first linked Pointer-wire run passed the wrong-kind and
  malformed-wire methods but failed the valid round trip at the assertion that
  compared two `FAngelscriptHash256` values. The report stack terminates in
  `CQTestConvert::ToString<FAngelscriptHash256>` with an Ensure stating that the
  custom type has no converter. It does not report different GenerationId bytes,
  and the same encode/decode path passes when the full 64-character lowercase
  values are compared as `FString`.
- Decision: Pointer tests compare stable hashes through `ToHexString()` (or direct
  equality inside `IsTrue`) instead of constructing an `AreEqual` matcher for a
  type CQTest cannot format. Do not add a production-facing CQTest converter to
  satisfy one test. Freeze the complete 80-byte Current pointer as a hard-coded
  hexadecimal golden so the wire oracle is independent of the encoder's field
  assembly and checksum recomputation.
- Required evidence: preserve the original runtime failure, pass the same three
  methods after only the assertion-boundary correction, observe one intentional
  golden RED that prints all 80 actual bytes, then pass the frozen-golden run.
- Task impact: this closes the current Pointer wire oracle only. It does not prove
  physical pointer replacement/removal, namespace locking, old-or-new visibility,
  reread/rebase, committed-state reporting, or reader pinning.
- Resolution/evidence: the original `2/3` run and converter stack are at
  `Saved/Tests/cache-v2-store-pointer-wire-green-attempt-1/20260810_040521_834_7f3eb78d`.
  The assertion correction built at
  `Saved/Build/cache-v2-store-pointer-wire-diagnostic-build-attempt-1/20260810_041053_577_58b0aa2d`
  and passed `3/3` at
  `Saved/Tests/cache-v2-store-pointer-wire-diagnostic-attempt-1/20260810_041109_480_f9700514`.
  The intended full-golden RED passed the other two methods and printed the exact
  160-character wire at
  `Saved/Tests/cache-v2-store-pointer-golden-red-attempt-1/20260810_041248_309_6af2652d`.
  After freezing those bytes, the Development Editor build passed at
  `Saved/Build/cache-v2-store-pointer-golden-green-build-attempt-1/20260810_041332_597_580435e3`
  and the Pointer prefix passed `3/3`, failed/skipped `0/0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v2-store-pointer-golden-green-attempt-1/20260810_041350_418_886c8be2`.

## IC-261 — The first generation-read RED mixed missing production behavior with test-fixture API mistakes

- Severity/state: V2.3 TDD evidence-quality defect / closed 2026-08-10.
- Exact boundary: the first build of the new locked generation-read fixture did
  report the intended missing
  `ReadAndValidateAngelscriptCacheGenerationUnderLock()` API, but it also used
  nonexistent `FAngelscriptEncodedPack::CompleteBytes`, placed instance-bound
  CQTest `ASSERT_THAT` macros in a static helper, and called `GetRecordId()` on
  the `TSharedRef` wrapper rather than through `operator->`. That mixed build is
  not accepted as the feature RED.
- Decision: align the fixture with the existing ManifestPack authorities:
  `FAngelscriptEncodedPack::Bytes`, a non-static class helper for matcher
  assertions, and `Handle->GetRecordId()`. Do not alter production types or add
  test-only aliases. Rebuild before writing production code and accept the RED
  only when every diagnostic is the intentionally absent generation-read API.
- Required evidence: preserve the mixed build, then retain a second clean RED
  containing only missing-API diagnostics; after the production seam is added,
  pass the same focused five methods and the affected Store/Cache regressions.
- Task impact: this changes no Cache V2 wire, Store result or runtime behavior.
  It protects the TDD chronology for V2.3's locked complete-generation reread.
- Evidence so far: the mixed build is
  `Saved/Build/cache-v2-store-generation-read-api-red-attempt-1/20260810_044708_781_fde88126`.
  After only the three fixture corrections, the authoritative clean RED is
  `Saved/Build/cache-v2-store-generation-read-api-red-attempt-2/20260810_044754_830_368af0f7`;
  all five diagnostics are the missing production API. The production seam then
  built at
  `Saved/Build/cache-v2-store-generation-read-green-build-attempt-1/20260810_044911_534_fec73331`
  and the same five methods passed at
  `Saved/Tests/cache-v2-store-generation-read-green-attempt-1/20260810_044928_760_3e9bd764`.
  The composed Store prefix passed `47/47` at
  `Saved/Tests/cache-v2-store-v23-transaction-regression-attempt-1/20260810_050700_720_23dda09a`
  and the complete Cache prefix passed `292/292` at
  `Saved/Tests/cache-v2-store-v23-full-cache-regression-attempt-1/20260810_050737_676_b3935c7b`.

## IC-262 — The first composed writer incorrectly blocked repair of a corrupt old Current

- Severity/state: V2.3 recovery-contract contradiction / closed 2026-08-10.
- Exact boundary: the first high-level transaction validated the pointer-selected
  Current generation and returned `ContentValidationFailed` immediately when its
  Pack was corrupt. `store-publication-v1.md` instead requires a source-valid new
  generation to replace corrupt Current without promoting that invalid base to
  Previous; an already valid Previous must remain untouched. Blocking the write
  would make one disk-corruption event permanently disable normal cache repair,
  contrary to the user's regenerate-on-mismatch requirement.
- Decision: when the selected slot still equals the request's observed
  GenerationId but its manifest/packs fail physical/content validation, classify
  it as an invalid non-reusable base and continue the already source-validated
  publication. Pass no validated prior generation into the pointer protocol, so
  Previous is not rotated. Preserve a pre-existing Previous byte-for-byte. If the
  selected ID changed concurrently and cannot be validated, require caller/source
  revalidation instead of overwriting an unknown writer result.
- Required evidence: retain one focused `4/5` RED whose only failure expected a
  successful repair but received Store error 20; then pass the same five-method
  transaction prefix and affected Store/Cache regressions. The corrected method
  must assert new Current, unchanged valid Previous, no validated GenerationBefore,
  and no Previous replacement call.
- Task impact: V2.3 cannot close while corrupt Current prevents forward repair or
  can be rotated into Previous. Candidate fallback for readers remains separate
  V2.4/V3 work and does not authorize different-source stale execution.
- Evidence so far: the corrected recovery expectation built at
  `Saved/Build/cache-v2-store-corrupt-current-repair-red-build-attempt-1/20260810_045802_222_8603c85b`.
  The focused runtime RED passed the other four methods and failed only this
  recovery case (`4/5`, failed `1`) because actual error was
  `ContentValidationFailed` at
  `Saved/Tests/cache-v2-store-corrupt-current-repair-red-attempt-1/20260810_045820_862_492615e7`.
  The root-cause fix built at
  `Saved/Build/cache-v2-store-corrupt-current-repair-green-build-attempt-1/20260810_050004_387_cd699be7`
  and the five-method transaction prefix passed at
  `Saved/Tests/cache-v2-store-corrupt-current-repair-green-attempt-1/20260810_050020_222_b0579c7f`.
  Production disk publication/rotation/reopen/no-op passed as part of `6/6` at
  `Saved/Tests/cache-v2-store-physical-transaction-attempt-1/20260810_050220_017_61b8fadc`;
  the composed Store and complete Cache regressions passed `47/47` and `292/292`
  at the IC-261 paths above.

## IC-263 — The first all-root reread RED was masked by two extra matcher parentheses

- Severity/state: V2.3 TDD evidence-quality defect / closed 2026-08-10.
- Exact boundary: the first build of
  `CurrentPublicationRereadsEveryPhysicalRootBeforeTheFirstWrite` did not execute
  the missing Store behavior because two diagnostic matcher expressions each had
  one extra closing parenthesis. This is a test-source syntax defect, not evidence
  for or against the all-three-root transaction.
- Decision: preserve the failed build, remove only the two extra parentheses, and
  rebuild before changing Runtime code. Accept the feature RED only when the
  complete test class executes and the new method alone reports the first missing
  Previous/Pending locked read.
- Required evidence: retain the syntax-failure build, a clean linked `5/6` RED,
  the same `6/6` GREEN after the production all-root snapshot, and affected Store/
  Cache regressions. The test must prove every pointer, Manifest and Pack read is
  before the first file write.
- Task impact: no wire or Store result changes. This protects the TDD chronology
  for the V2.3 abandoned-writer/all-physical-root recovery boundary.
- Evidence so far: the rejected syntax build is
  `Saved/Build/cache-v2-store-all-roots-red-build-attempt-1/20260810_051233_014_669d65d4`.
  After only the matcher correction, the clean Development Editor build passed at
  `Saved/Build/cache-v2-store-all-roots-red-build-attempt-2/20260810_051259_617_e6819a67`;
  the transaction prefix then passed the existing five methods and failed only
  the new missing Previous read (`5/6`) at
  `Saved/Tests/cache-v2-store-all-roots-red-attempt-1/20260810_051317_611_2a3a2d78`.
  The all-root implementation built at
  `Saved/Build/cache-v2-store-all-roots-green-build-attempt-1/20260810_051625_515_cf32110d`
  and passed the same `6/6` prefix at
  `Saved/Tests/cache-v2-store-all-roots-green-attempt-1/20260810_051643_472_c86cb75e`.
  A separate duplicate-root RED then proved one manifest was read three times
  rather than once (`6/7`) at
  `Saved/Tests/cache-v2-store-duplicate-roots-red-attempt-1/20260810_051815_328_c35fd147`;
  full-GenerationId deduplication built at
  `Saved/Build/cache-v2-store-duplicate-roots-green-build-attempt-1/20260810_051858_123_ab0c360a`
  and passed `7/7` at
  `Saved/Tests/cache-v2-store-duplicate-roots-green-attempt-1/20260810_051914_374_fcec274c`.
  The affected Store prefix passed `49/49` at
  `Saved/Tests/cache-v2-store-all-roots-regression-attempt-1/20260810_051953_912_edd8910b`
  and the complete Cache prefix passed `294/294` at
  `Saved/Tests/cache-v2-store-all-roots-full-cache-regression-attempt-1/20260810_052027_889_4a57adb1`.

## IC-264 — Case-insensitive fake-file keys replaced the valid lowercase Pack temp

- Severity/state: V2.3 focused-fixture identity defect / closed 2026-08-10.
- Exact boundary: the first stale-temp runtime attempt passed enumeration-failure
  atomicity but removed only four of the five expected canonical temps. Focused
  parser logging showed that the fake Pack directory contained the intentionally
  invalid uppercase-nonce sibling and no longer contained the earlier lowercase
  valid name. The test's `TMap<FString, ...>` file table had collapsed/replaced
  the two case-only-distinct paths before production enumeration; the strict
  parser correctly rejected the surviving uppercase token.
- Decision: keep the production parser unchanged. Replace this fixture's fake
  file table with a case-sensitive path array and explicit case-sensitive
  contains/remove predicates so a lowercase valid file and uppercase-invalid
  sibling coexist. Remove the temporary parser logging before the next run.
- Required evidence: preserve the `1/2` runtime failure and parser diagnostic,
  then pass both focused cases without production parser changes. Add a production
  Win64 directory case containing the five valid direct temp forms plus preserved
  invalid/final/nested names before closing the issue.
- Task impact: this does not relax the lowercase full-hash/canonical-token rule.
  It prevents a test-double identity model from hiding the case-sensitive Store
  filename contract.
- Evidence so far: the first linked implementation build passed at
  `Saved/Build/cache-v2-store-stale-temp-green-build-attempt-1/20260810_052743_130_d8fa097b`;
  the focused runtime result was `1/2` at
  `Saved/Tests/cache-v2-store-stale-temp-green-attempt-1/20260810_052804_026_87b28cf3`.
  The diagnostic build is
  `Saved/Build/cache-v2-store-stale-temp-parser-diagnostic-build-attempt-1/20260810_053005_457_6d60a495`
  and its one-method run is
  `Saved/Tests/cache-v2-store-stale-temp-parser-diagnostic-attempt-1/20260810_053024_194_87be40a0`.
  Replacing only the fake identity table and removing the temporary parser log
  built at
  `Saved/Build/cache-v2-store-stale-temp-fixture-green-build-attempt-1/20260810_053143_876_67464f75`;
  both focused methods then passed (`2/2`, warnings/errors `0/0`) at
  `Saved/Tests/cache-v2-store-stale-temp-fixture-green-attempt-1/20260810_053202_488_fc38f86b`.
  Production Win64 enumeration, namespace locking and deletion built at
  `Saved/Build/cache-v2-store-stale-temp-disk-build-attempt-1/20260810_053735_578_3152dd7d`.
  `StoreDisk` passed `7/7` at
  `Saved/Tests/cache-v2-store-stale-temp-disk-attempt-1/20260810_053754_972_5b145538`;
  the physical test removed all five canonical direct files while preserving a
  final Pack, uppercase-token file, wrong-directory file, nested file and a
  temp-shaped directory.

## IC-265 — The intentional non-fatal cleanup warning initially polluted the GREEN report

- Severity/state: V2.3 verification-cleanliness defect / closed 2026-08-10.
- Exact boundary: the first nine-method transaction GREEN correctly continued
  publication after an injected stale-temp delete failure and emitted the
  required sanitized warning, but the automation report classified that one
  method as `SucceededWithWarnings`. The production diagnostic was correct; the
  test had not declared that exact warning as expected.
- Decision: retain the production warning at Warning severity. Register the
  stable message prefix with the CQTest runner only in the injected-failure
  method, with an exact expected count of one. Do not lower production severity
  or globally suppress Cache Store warnings to make the report green.
- Required evidence: preserve the first `9/9` functional run with report totals
  `succeeded=8`, `succeededWithWarnings=1`, then rebuild and rerun the same prefix
  with `9/9`, warnings/errors `0/0`. The log must still show the expected message
  (downgraded to Verbose by the automation expectation) and its sanitized Error,
  Stage, PathCategory and platform code.
- Task impact: no Store wire, cleanup, commit or failure semantics change. This
  ensures future broad Cache runs remain zero-warning while still testing the
  diagnostic path.
- Resolution/evidence: the first transaction prefix is
  `Saved/Tests/cache-v2-store-stale-temp-transaction-attempt-1/20260810_054304_698_ca290e80`.
  It passed all nine methods but reported one expected-by-design warning. The
  scoped expectation built at
  `Saved/Build/cache-v2-store-stale-temp-expected-log-build-attempt-1/20260810_054416_461_85fb4994`;
  the same prefix then passed `9/9`, `succeededWithWarnings=0`, failed/skipped
  `0/0`, at
  `Saved/Tests/cache-v2-store-stale-temp-transaction-attempt-2/20260810_054437_221_3e4ebf9b`.

## IC-266 — Exported read-session opener could not also own a private-constructor friend declaration

- Severity/state: V2.4 Development build integration defect / closed 2026-08-10.
- Exact boundary: the first implementation declared
  `OpenBestAngelscriptCacheReadSession` as a class friend without DLL export and
  later as `ANGELSCRIPTRUNTIME_API`. MSVC reported C2375 different linkage. Moving
  the exported declaration before the class still left the friend redeclaration
  without matching DLL linkage and produced C4273. Runtime algorithms and the RED
  test were not compiled far enough to execute.
- Decision: do not make the exported API declaration carry private-constructor
  access. Friend one non-exported `FAngelscriptCacheReadSessionFactory`; let the
  exported function call that factory after the session has been fully validated.
  This gives the API one authoritative exported declaration and keeps direct
  session construction private.
- Required evidence: preserve both deterministic build failures, then pass the
  same Development Editor build and focused production session method without
  changing the test expectation or making the constructor public.
- Task impact/evidence: attempt 1 is
  `Saved/Build/cache-v2-store-read-session-green-build-attempt-1/20260810_062110_830_7bc5430b`;
  the declaration-order hypothesis was rejected by attempt 2 at
  `Saved/Build/cache-v2-store-read-session-green-build-attempt-2/20260810_062145_979_f4387875`.
  The internal-factory correction passed at
  `Saved/Build/cache-v2-store-read-session-green-build-attempt-3/20260810_062225_263_e3c282dd`,
  followed by the `2/2` focused result recorded in verification. No wire, Budget,
  lock, selection or handle-lifetime rule changed.

## IC-267 — The two-Pack pin-limit fixture used a nonexistent RecordId field name

- Severity/state: V2.4 test-fixture API misuse / closed 2026-08-10.
- Exact boundary: the expanded read-session matrix constructed an intentionally
  locally valid second Manifest record but assigned its hash through `.Hash`;
  `FAngelscriptCacheRecordId` exposes `.ContentHash`. The build stopped at that
  single C2039 before any new Runtime behavior executed.
- Decision: change only the fixture member to `ContentHash`; retain record kind,
  PackId, canonical ordering, limit and expected zero-Pack-open assertion. Do not
  add an alias to production RecordId or alter the Manifest encoder.
- Required evidence: preserve the isolated failed build, rebuild without Runtime
  edits, then run the complete six-method read-session matrix and broad Store/
  Cache regressions.
- Task impact/evidence: the isolated failure is
  `Saved/Build/cache-v2-store-read-session-matrix-build-attempt-1/20260810_062600_255_e84c3088`.
  The corrected build, `6/6` focused run and `68/68`/`313/313` broad results are
  recorded in verification. This changed no Cache contract or production code.

## IC-268 — The first focused Pending-promotion run omitted the CQTest class segment

- Severity/state: V2.4 test-runner addressing defect / closed 2026-08-10.
- Exact boundary: the new promotion method compiled and registered, but the first
  `RunTests.ps1` attempt targeted
  `Angelscript.TestModule.Cache.StorePointerPublication.<Method>`. CQTest registers
  the full path as
  `Angelscript.TestModule.Cache.StorePointerPublication.<Class>.<Method>`, so the
  runner found zero tests and returned nonzero. No production behavior executed;
  this attempt is neither RED nor GREEN evidence.
- Decision: inspect prior Automation reports to recover the registered full path,
  retain the no-match artifact for chronology, and rerun with the class segment.
  Do not rename the test class or weaken the runner's anchored prefix matching.
- Required evidence: preserve the zero-match attempt, then prove exactly one test
  executes and fails for the intended missing Pending removal before any Runtime
  fix. Subsequent focused GREEN must use the identical full path.
- Task impact/evidence: the rejected run is
  `Saved/Tests/cache-v2-pending-promotion-red-attempt-1/20260810_063411_463_cf04682a`.
  The corrected full-path run executed exactly one test and failed only because
  the matching Pending pointer remained at
  `Saved/Tests/cache-v2-pending-promotion-red-attempt-2/20260810_063454_914_9c392ecb`.
  No source edit was needed to correct the runner address. The same address-only
  mistake recurred during Compaction Phase A verification: the rejected
  zero-match invocation is preserved at
  `Saved/Tests/cache-v2-compaction-phase-a-green-attempt-1/20260810_070324_457_63abfca5`,
  while the corrected full class+method path executed and passed at
  `Saved/Tests/cache-v2-compaction-phase-a-green-attempt-2/20260810_070410_277_e2cac4fe`.
  This recurrence changes no source or behavior evidence and remains covered by
  IC-268 rather than consuming a new implementation-issue number.

## IC-269 — The first Current-publication call-count assertion predated Pending reread

- Severity/state: V2.4 stale test expectation / closed 2026-08-10.
- Exact boundary: after the matching-Pending cleanup was GREEN, the complete
  pointer-publication class passed nine of ten methods. The only failure expected
  exactly four fake filesystem calls for a first Current publication. The new
  contract requires a fifth call that rereads `PendingColdStart` after Current is
  committed and directory-synced, even when the slot is absent.
- Decision: preserve the production sequence. Update only the old assertion from
  four to five calls and require the fifth call to be the exact Pending pointer
  read. Do not suppress the reread or remove ordering assertions to retain an old
  implementation trace.
- Required evidence: retain the isolated `9/10` class failure, rebuild after only
  the expectation correction and companion acceptance tests, then pass the whole
  Store and Cache prefixes.
- Task impact/evidence: the stale-expectation result is
  `Saved/Tests/cache-v2-pending-promotion-class-regression-attempt-1/20260810_063703_528_3911e4a0`.
  The corrected matrix built at
  `Saved/Build/cache-v2-pending-selection-matrix-build-attempt-1/20260810_063915_608_affc9b8f`;
  Store passed `74/74` and Cache passed `319/319` at the paths recorded in
  verification. No Store wire, pointer bytes or commit-state values changed.

## IC-270 — The frozen compaction protocol had no final-immutable deletion seam

- Severity/state: V2.4 Store interface/contract gap / closed 2026-08-10.
- Exact boundary: Phase B normatively enumerates and deletes only unmarked strict-
  name final Packs/Manifests, and must classify a pinned-reader sharing refusal as
  `DeleteDeferred`. `IAngelscriptCacheAtomicFileOps` currently exposes only
  `AtomicRemovePointer` and `RemoveOwnTemp`; using either for a final immutable
  object would violate its stated target and rollback boundary. Direct
  `IFileManager` calls in the compactor would bypass deterministic injection and
  production platform-error classification.
- Decision: add one narrow `RemoveFinalImmutable` seam. The locked compactor must
  enumerate direct children, accept only `<lower-full-hash>.aspack` and
  `<lower-full-hash>.asmanifest`, construct the exact same-directory path, and
  call the seam only for unmarked finals. Production Win64 maps a live-handle
  sharing refusal to `DeleteDeferred`; pointer/temp APIs remain separate.
- Required evidence: first add a missing-compaction-API RED with zero filesystem
  mutation for missing authority; then prove strict final filtering, marked-root
  preservation, pinned/deferred deletion and later retry through focused fake and
  production Win64 tests. Broad Store/Cache runs must remain clean.
- Task impact/evidence: the Store contract code block and Phase B text now
  explicitly own this seam. The production Win64 seam uses delete-sharing pinned
  handles; the production read-session method proves old bytes remain readable
  after `RemoveFinalImmutable` unlinks and the path is reused. The injected Store
  matrix proves `DeleteDeferred` continues other orphan cleanup and a later
  explicit compaction retries it. StoreCompaction passed `12/12` at
  `Saved/Tests/cache-v2-compaction-phase-ab-class-green-attempt-2/20260810_073602_447_9ad50457`,
  Store passed `86/86` at
  `Saved/Tests/cache-v2-compaction-phase-ab-store-regression-attempt-1/20260810_073635_836_6007f818`,
  and Cache passed `331/331` at
  `Saved/Tests/cache-v2-compaction-phase-ab-cache-regression-attempt-1/20260810_073710_751_f947eed3`.
  No Pack/Manifest/pointer wire, identity hash or normal publication path changed.

## IC-271 — A case-variant strict-name fixture aliased its orphan in the memory Store

- Severity/state: V2.4 test-fixture identity error / closed 2026-08-10.
- Exact boundary: the first Phase B GREEN attempt tried to keep both
  `<e1...>.aspack` and the uppercase form of that identical basename in the fake
  Store's `TMap<FString, TArray<uint8>>`. Unreal's `GetTypeHash(FString)` is case-
  insensitive, matching Windows path identity, so the second insertion did not
  model an independent sibling. It changed the one enumerable key form to the
  uppercase invalid name; strict filtering correctly retained it, while the test
  incorrectly expected a separate lowercase orphan to have been deleted.
- Decision: retain production strict-name filtering. Give the uppercase invalid
  sibling a different full hash so it is independent from the lowercase strict
  orphan even in a Windows-faithful memory map. Do not make the fake invent two
  same-directory Windows paths that differ only by case, and do not weaken the
  lower-case final-name contract.
- Required evidence: preserve the first post-implementation `1/1` failure at the
  orphan-Pack assertion, rebuild after only the fixture identity correction, then
  pass the identical focused Phase B method and the complete StoreCompaction
  class.
- Task impact/evidence: the diagnostic run is
  `Saved/Tests/cache-v2-compaction-phase-b-sweep-green-attempt-1/20260810_071240_762_61d6826b`.
  It already proved a successful committed result and removal of the old Pack and
  old Manifest before reaching the aliased fixture assertion; it is not final
  GREEN evidence. No Runtime source or Store contract changed for IC-271.

## IC-272 — The three-root compaction fixture used a nonexistent TArray IndexOf API

- Severity/state: V2.4 test-fixture API misuse / closed 2026-08-10.
- Exact boundary: the first build of the new Current/Previous/Pending union and
  ineligible-Pending tests stopped in test-only code because UE's `TArray` exposes
  `Find`/`IndexOfByPredicate`, not `IndexOf`, for locating a value. No compaction
  Runtime code or new test body executed.
- Decision: replace only the exact-call lookup with `TArray::Find`; retain the
  frozen assertion that Pending removal precedes the first Current same-slot
  replacement. Do not weaken ordering checks or add a production helper for a
  test-container lookup.
- Required evidence: preserve the isolated compiler failure, rebuild without
  Runtime changes, and run both new three-root/ineligible-Pending methods followed
  by the complete StoreCompaction class.
- Task impact/evidence: the isolated Development Editor build failure is
  `Saved/Build/cache-v2-compaction-phase-a-three-root-tests-build-attempt-1/20260810_072501_660_7baddd2c`.
  It failed only at `AngelscriptCacheStoreCompactionTests.cpp:1039` with C2039;
  follow-up GREEN artifacts are recorded in verification. No wire, pointer,
  compaction, deletion or cache-selection behavior changed.

## IC-273 — Phase B re-decoded duplicate physical Generation roots

- Severity/state: V2.4 physical-root deduplication contract defect / closed
  2026-08-10.
- Exact boundary: Phase A already deduplicated Current/Previous/Pending slots that
  referenced one GenerationId, but Phase B reread and prepared the same Manifest
  once per slot. This produced the correct mark set by accident while charging
  the cumulative Budget and allocating decoded state up to three times, contrary
  to the frozen rule that duplicate physical pointers are deduplicated for work.
- Decision: retain three independent pointer rereads, because each slot must be
  physically observed after lock reacquisition, but keep a bounded three-entry
  GenerationId set and prepare/mark each distinct Manifest exactly once. Do not
  reset Budget, merge pointer slots, or bypass Manifest validation.
- Required evidence: one focused RED with three slots pointing to the same valid
  generation and an exact Phase-B Manifest-read count of one; then the identical
  test GREEN, the complete StoreCompaction class, and broad Store/Cache prefixes.
- Task impact/evidence: the RED executed exactly `1/1` and failed only at the
  duplicate-decode assertion at
  `Saved/Tests/cache-v2-compaction-phase-b-dedup-red-attempt-1/20260810_073333_774_355b9c91`.
  The Runtime correction built at
  `Saved/Build/cache-v2-compaction-phase-b-dedup-green-build-attempt-1/20260810_073434_041_8bdace32`
  and the identical method passed `1/1` at
  `Saved/Tests/cache-v2-compaction-phase-b-dedup-green-attempt-1/20260810_073455_131_2d42e274`.
  Pointer wire, root order and reachable-object identity did not change.

## IC-274 — A successful normal compile has no production pointer-free Cache V2 capture seam

- Severity/state: V1.5/V2.5 compiler-to-generation functional gap / closed
  2026-08-10 at the representative clean-capture/cold-publication boundary;
  malformed opaque graph evidence remains separately open as IC-276.
- Exact boundary: the immutable record factories, complete seven-record graph,
  deterministic Pack/Manifest builder and crash-safe Store are implemented, but a
  successful `FAngelscriptEngine::CompileModules` transaction does not currently
  freeze its `FAngelscriptModuleDesc`/`asCModule` into those pointer-free records.
  Existing compile-end summaries are diagnostic-only and occur too late to let a
  worker safely reread mutable AS/UE compiler state. The maintained fork exposes
  whole-module `SaveByteCode`, but no bounded per-function execution artifact or
  stable canonical source slice; using the whole module as every FunctionBody
  would violate function-level reuse and stable StaticJIT identity.
- Decision: add one synchronous clean-capture API at the successful compile safe
  point and keep the resulting DTO pointer-free before any asynchronous Store
  work. Extend the maintained AngelScript fork where required to export one
  versioned, pointer-free function execution artifact and canonical token source
  for the actual compiled function. The first vertical supports a representative
  module containing one enum and one dependency-free primitive global function,
  emits exactly SourceIndex, ModuleInterface, TypeSchema, ModuleState,
  FunctionBody, DebugSidecar and ModuleSnapshot, and fails the complete module
  closed as `NotCacheable` for unsupported declarations or symbolic-reference
  tables. It must not publish a synthetic Store-only graph, duplicate whole-module
  bytecode into a FunctionBody, persist numeric FunctionIds/pointers/absolute
  paths, or edit business `.as` source to manufacture a hit.
- Required evidence: first retain the production-header-missing RED; then build
  the real capture/export path, prove byte-identical seven-record output from two
  isolated full engines, publish it as Current, and reopen the identical
  Generation through a fresh pinned read session. Follow with focused malformed/
  unsupported fail-closed coverage and the affected Archive/Store/Cache prefixes.
- Task impact/evidence: the official wrapper
  `Tools\RunBuild.ps1 -Label cache-v2-cold-generation-red -TimeoutMs 180000`
  failed only because `Cache/AngelscriptCacheCleanCapture.h` did not exist at
  `Saved/Build/cache-v2-cold-generation-red/20260810_080356_168_b90266b6`;
  `Build.log` records C1083 at the new real cold-generation test's first include.
  This was the expected TDD frontier for V1.5/V2.5, not a baseline regression.
  The production seam now captures the representative enum/function module twice
  from isolated normal full-engine compiles, returns byte-identical pointer-free
  seven-record artifacts, publishes one Pack and reopens the same Generation in a
  fresh pinned session. The latest combined factory/graph/publication proof passed
  at
  `Saved/Tests/cache-v2-complete-graph-context-coverage-green-attempt-2/20260810_091116_709_c8599729`;
  IC-275–IC-279 preserve the integration defects found while reaching that point.

## IC-275 — Clean capture composed rooted virtual-path and mount-name APIs as artifact coordinates

- Severity/state: V1.5/V2.5 real-compile identity integration defect / closed
  2026-08-10.
- Exact boundary: the first real normal-compile run reaches
  `CaptureAngelscriptCleanCompiledModule`, successfully parses the code section's
  `/Angelscript/Game/ASCacheV2ColdGeneration.as` virtual path, then passes
  `VirtualPath.ToString()` and `VirtualPath.GetMountName()` to
  `TryBuildModuleKey`. The first value is intentionally slash-rooted while the
  artifact identity builder intentionally accepts only mount-relative logical
  paths so host absolute paths fail closed. The second value is intentionally
  empty for the built-in Game root, while the frozen Cache identity fixtures use
  the explicit logical mount `Game`. Two individually correct APIs were therefore
  composed at the wrong abstraction boundary, and the capture returns
  `NotCacheable` before emitting any record.
- Decision: keep both existing invariants. Do not teach artifact identity to
  accept arbitrary rooted strings and do not change the source-path parser's
  established mount-name meaning. At the clean-capture boundary derive a
  kind-qualified logical mount (`Game` for this first disk vertical) and pass
  only `GetRelativePath()` into `TryBuildModuleKey`; use the same logical mount in
  SourceIndex provider/mount configuration so ModuleKey and source graph share
  one coordinate model. Unsupported/ambiguous source kinds continue to fail
  closed rather than falling back to an absolute or rooted path.
- Required evidence: retain the identical real `BuildModule` RED, make only the
  coordinate-boundary correction, rebuild with the official wrapper and rerun
  the same full CQTest path. The test must advance beyond ModuleKey construction;
  any later capture/record/Store failure is a distinct issue rather than evidence
  that this identity defect remains.
- Task impact/evidence: `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ColdGeneration" -Label
  cache-v2-cold-generation-discovery-attempt-2 -TimeoutMs 600000` found and ran
  exactly one test at
  `Saved/Tests/cache-v2-cold-generation-discovery-attempt-2/20260810_082745_495_e10e3597`.
  `Automation.log` reports `Error=2`, zero records and
  `Detail=The module identity cannot be normalized`. Source inspection confirms
  `TryCreateLogicalVirtualPath` rejects slash-rooted input by contract and the
  parsed Game virtual path stores an empty mount name. No Store file was opened or
  published in this failure. The coordinate-only correction built successfully at
  `Saved/Build/cache-v2-cold-generation-ic275-green-build-attempt-1/20260810_083404_499_78cb42fa`.
  The identical class prefix then passed `1/1` with wrapper/process exit `0/0` at
  `Saved/Tests/cache-v2-cold-generation-ic275-green-attempt-1/20260810_083420_661_1fc9425c`.
  Its log proves two successful seven-record captures, one Pack, Current
  publication, and a fresh pinned-session reopen of the same Generation. No
  identity-builder acceptance rule, wire schema or absolute-path behavior was
  weakened.

## IC-276 — Real cold publication did not cross the sole semantic record factory and graph

- Severity/state: V1.4/V1.5 semantic-authority integration gap / closed
  2026-08-10.
- Exact boundary: the original V2.5 publication path produced locally valid
  records but did not decode those exact payload bytes through
  `FAngelscriptDecodedCacheRecordBatch` or call the sole
  `ValidateModuleSnapshotGraph` traversal. Clean capture now performs both
  synchronously and returns no records on any graph failure. The remaining open
  boundary is explicit evidence that a deliberately corrupt/truncated maintained-
  fork execution payload and versioned debug payload reach the production opaque
  validator and leave both graph and capture output empty.
- Decision: a successful clean capture must synchronously decode its exact emitted
  payloads through the sole immutable record factory and validate the root
  ModuleSnapshot with the existing graph authority before returning publishable
  artifacts. The graph must use a production opaque validator for the maintained-
  fork function artifact and the versioned debug payload, plus fail-closed no-
  external resolvers for this dependency-free first vertical. The result reports
  the actual graph reachable-record count; it must never synthesize `7`, bypass
  opaque validation, or retain a partial graph/output on failure.
- Required evidence: retain a compile RED for the missing observable graph result;
  extend the maintained AngelScript fork only as needed for bounded, non-mutating
  function-artifact validation; then rebuild and run the identical real two-engine
  test. Both captures must report seven graph-reachable records. Corrupt/truncated
  execution and debug payloads must fail at the opaque-codec/graph boundary with
  empty output before V1.4/V1.5 close.
- Task impact/evidence: `Tools\RunBuild.ps1 -Label
  cache-v2-real-graph-validation-red-attempt-1 -TimeoutMs 180000` failed with
  wrapper/process exit `1/6` at
  `Saved/Build/cache-v2-real-graph-validation-red-attempt-1/20260810_084123_497_48653130`.
  The first error is C2039 for the wished-for
  `FAngelscriptCacheCleanCaptureResult::ValidatedGraphRecordCount`; the format-
  string diagnostic is the same missing argument's compile-time cascade. No
  Runtime source was changed before this RED. The happy-path implementation built
  at
  `Saved/Build/cache-v2-complete-graph-context-coverage-green-build-attempt-1/20260810_090912_969_1ba4b673`
  and the exact two-engine method passed at
  `Saved/Tests/cache-v2-complete-graph-context-coverage-green-attempt-2/20260810_091116_709_c8599729`
  with `Records=7 GraphRecords=7` twice and empty failure state. Do not close this
  issue until the required corrupt/truncated execution and debug cases also prove
  atomic rejection. That final evidence passed `2/2` at
  `Saved/Tests/cache-v2-detached-validation-quiet-green-attempt-1/20260810_092545_012_02e8db04`:
  execution and debug truncation/corruption all reached OpaqueCodec with zero graph
  records and zero promoted output. The affected module families passed `30/30`
  at
  `Saved/Tests/cache-v2-opaque-promotion-module-graph-regression-attempt-1/20260810_092726_150_48b5068d`,
  and the complete Cache prefix passed `334/334` at
  `Saved/Tests/cache-v2-opaque-promotion-complete-cache-regression-attempt-1/20260810_092759_316_85a24db8`.

## IC-277 — The first detached function-artifact reader rejects the real payload at byte 37

- Severity/state: V1.4/V1.5 maintained-fork execution-codec integration defect /
  closed 2026-08-10.
- Exact boundary: the IC-276 implementation now builds and sends the exact seven
  emitted records through `FAngelscriptDecodedCacheRecordBatch` and the sole
  `ValidateModuleSnapshotGraph`. The real normal-compile test advances through
  SourceIndex, ModuleInterface, TypeSchema, ModuleState and record identity, but
  the production opaque validator initially rejected the FunctionBody execution
  payload as `OpaquePayloadMalformed` at stream offset `37`. Bounded stage
  diagnostics then proved that the writer emitted 37 bytes, the backing stream
  consumed all 37, `ReadFunction` returned one new function, but
  `asCReader::bytesRead` reported only 31 bytes at the exact-length gate. The
  six-byte difference was the function name: `ReadString` read its bytes directly
  from the stream without incrementing `bytesRead`. The payload and writer
  contract were valid; the detached reader's accounting was not. This was not a
  Store, ModuleKey, Pack, Manifest or debug-sidecar failure.
- Decision: do not bypass the opaque codec and do not mark the payload valid from
  its outer hash alone. Keep bounded maintained-fork validation diagnostics at the
  writer/reader symmetry boundary. Increment `bytesRead` after the existing
  bounded direct string read; do not change wire bytes or relax exact-length
  validation. Validation remains detached from module/engine registration and
  must destroy every half-created function on failure. Unsupported symbolic
  reference tables continue to fail closed.
- Required evidence: preserve the real two-engine RED and exact writer/reader
  diagnostics, correct the proven accounting asymmetry, and rerun the identical
  ColdGeneration method. Both captures must report seven validated records. Then
  add truncated/corrupt execution-artifact coverage proving `OpaqueCodec`
  rejection, exact failure coordinates and empty graph/capture output before
  closing IC-276.
- Task impact/evidence: the graph implementation first built successfully at
  `Saved/Build/cache-v2-real-graph-validation-green-build-attempt-2/20260810_085027_710_ae141a27`.
  The focused runtime attempt failed `0/1` at
  `Saved/Tests/cache-v2-real-graph-validation-green-attempt-1/20260810_085046_540_bc4fb602`
  with FunctionBody `OpaquePayloadMalformed`. After adding the bounded stream
  offset diagnostic, the Runtime/Test build passed at
  `Saved/Build/cache-v2-real-graph-validation-diagnostic-build-attempt-1/20260810_085213_664_6eb69844`;
  the identical test failed `0/1` at
  `Saved/Tests/cache-v2-real-graph-validation-diagnostic-attempt-1/20260810_085223_446_3f0cffe2`.
  Its `Automation.log` reports clean-capture `Error=8`, graph `Error=45`, class
  `3`, FunctionBody kind `5`, OpaqueCodec stage `4`, offset `37`, zero returned
  records and zero graph records. The bounded stage build passed at
  `Saved/Build/cache-v2-function-artifact-stage-diagnostic-build-attempt-1/20260810_090012_428_6216ced9`;
  its focused RED at
  `Saved/Tests/cache-v2-function-artifact-stage-diagnostic-attempt-1/20260810_090031_438_b2758820`
  reported `expected=37 read=31 stream=37 stage=8 error=0 new=1` and isolated the
  reader-accounting defect. The correction built at
  `Saved/Build/cache-v2-function-artifact-byte-count-green-build-attempt-1/20260810_090131_029_cb507c7b`.
  The next focused run at
  `Saved/Tests/cache-v2-function-artifact-byte-count-green-attempt-1/20260810_090143_892_a8bff4c4`
  passed the opaque FunctionBody boundary and advanced to the distinct enum graph
  failure recorded as IC-278. The final happy-path proof is shared with IC-279.
  Execution truncation and corrupt-magic coverage then passed through the same
  production reader/graph at
  `Saved/Tests/cache-v2-detached-validation-quiet-green-attempt-1/20260810_092545_012_02e8db04`;
  both return FunctionBody kind, OpaqueCodec stage, exact stream offset, zero graph
  records and zero promoted artifacts.

## IC-278 — The sole module graph rejects the clean-captured enum TypeSchema

- Severity/state: V1.4/V1.5 real-module graph coverage defect / closed
  2026-08-10.
- Exact boundary: after IC-277, all seven records decoded successfully and the
  FunctionBody opaque validator passed, but the sole graph returned
  `MissingCoverage` at TypeSchema stage offset `68`. Captured diagnostics proved
  exact one-to-one TypeDeclaration/TypeSchema keys and exact one-to-one
  FunctionDeclaration/FunctionBody keys. Offset `68` is TypeSchema `TypeKind`;
  the graph admitted only Class/Struct/Interface even though the local TypeSchema
  decoder already fully validates Enum payload presence, ordered enumerators,
  hashes and layout authority. The representative real module's enum was locally
  valid but impossible to traverse.
- Decision: admit only the already-authoritative simple Enum form: non-empty Enum
  payload, no callable/typedef form, no relations/layout inputs/properties/
  methods/VFT/behaviors/dependencies/reflected functions. Continue to reject every
  unsupported mixed or structural form. Graph declaration/link validation still
  requires the exact TypeKey, kind, namespace, name and declaration digest; no
  local decoder check is bypassed.
- Required evidence: retain the offset-68 RED, rebuild, and prove that the same
  real compile advances beyond TypeSchema graph coverage without weakening the
  existing ModuleGraph suite. Corrupt/truncated opaque evidence remains an IC-276
  exit condition, not part of enum admission.
- Task impact/evidence: the coverage-diagnostic build passed at
  `Saved/Build/cache-v2-graph-coverage-diagnostic-build-attempt-1/20260810_090451_448_5fe0071b`;
  the focused RED at
  `Saved/Tests/cache-v2-graph-coverage-diagnostic-attempt-1/20260810_090507_268_f1f0e20f`
  reported matching type/function keys but `MissingCoverage` at offset `68`.
  Narrow enum admission built at
  `Saved/Build/cache-v2-enum-graph-coverage-green-build-attempt-1/20260810_090730_099_30bd61f0`.
  The next focused run at
  `Saved/Tests/cache-v2-enum-graph-coverage-green-attempt-1/20260810_090747_702_e9908a1c`
  passed the graph itself and advanced only to the distinct complete-capture
  accounting defect recorded as IC-279. After the final fixes, the affected
  `Cache.Archive.Module*` aggregation passed `30/30` at
  `Saved/Tests/cache-v2-opaque-promotion-module-graph-regression-attempt-1/20260810_092726_150_48b5068d`
  and complete Cache passed `334/334` at
  `Saved/Tests/cache-v2-opaque-promotion-complete-cache-regression-attempt-1/20260810_092759_316_85a24db8`.

## IC-279 — Clean capture counted SourceIndex as ModuleSnapshot-owned reachability

- Severity/state: V1.5 clean-capture postcondition ownership defect / closed
  2026-08-10.
- Exact boundary: the sole graph intentionally exposes six ModuleSnapshot-owned
  records for this representative module: ModuleSnapshot, ModuleInterface,
  ModuleState, TypeSchema, FunctionBody and DebugSidecar. SourceIndex is a
  generation/context authority consumed while validating selected source and
  debug coordinates, but is deliberately not an ordinal owned by
  `ModuleSnapshotGraph::GetReachableRecords()`. Clean capture instead required a
  hard-coded graph count of seven, so a completely valid graph was discarded as
  incomplete.
- Decision: preserve graph ownership semantics and remove the magic count. The
  clean-capture postcondition now requires the exact ModuleKey, traverses every
  decoded record, counts exactly one SourceIndex as external context authority,
  requires every other decoded record to be discoverable through the sole graph,
  and accepts only when this exact traversal covers the entire decoded batch.
  `ValidatedGraphRecordCount` reports that observed total; it never synthesizes
  seven.
- Required evidence: official Development Editor build, then the identical normal
  two-engine ColdGeneration method showing both captures report `Records=7` and
  `GraphRecords=7`, followed by one-Pack publication and fresh pinned-session
  reopen of the same Generation.
- Task impact/evidence: the correction built with wrapper/process exit `0/0` at
  `Saved/Build/cache-v2-complete-graph-context-coverage-green-build-attempt-1/20260810_090912_969_1ba4b673`.
  The focused method passed `1/1`, failed/skipped `0/0`, wrapper/process exit
  `0/0`, at
  `Saved/Tests/cache-v2-complete-graph-context-coverage-green-attempt-2/20260810_091116_709_c8599729`.
  Its Automation log records two independent clean captures with `Records=7
  GraphRecords=7`, one prepared Pack, Current publication and a fresh pinned read
  session reopening seven records from the identical Generation. IC-276 remains
  open only for the explicit corrupt/truncated opaque and atomic-empty-output
  evidence.

## IC-280 — Clean capture has no reusable validate-and-promote boundary for malformed artifacts

- Severity/state: V1.4/V1.5 atomic malformed-input verification gap / closed
  2026-08-10.
- Exact boundary: `CaptureAngelscriptCleanCompiledModule` validates its private
  candidate before assigning `OutArtifacts`, but callers cannot submit an already
  captured/reloaded pointer-free candidate to that same production codec/sole-
  graph boundary. Testing only `FAngelscriptFunctionArtifactCodec` would prove
  local parsing but not whole-graph atomic output; injecting a mutation callback
  into capture options would add test behavior to production configuration. The
  missing boundary also prevents later warm-restore/publication code from reusing
  the exact clean-candidate promotion contract.
- Decision: expose one production `ValidateAndPromote...` operation that accepts a
  candidate by value, resets output first, executes the existing exact decode/
  opaque/graph validation, and moves the complete candidate into output only on
  success. Failure destroys the private candidate and leaves zero validated count
  plus a fully reset output. Normal capture must route through this operation so
  tests and production cannot acquire different validation semantics.
- Required evidence: add a separate Runtime-integration CQTest file that normally
  compiles/captures the representative enum/function module, then rebuilds locally
  self-consistent record/link/hash chains around truncated and corrupt execution
  and debug opaque payloads. All four candidates must reach OpaqueCodec stage,
  fail as `GraphValidationFailed`, report zero validated graph records and clear a
  pre-populated output. Preserve the missing-API compile RED, then run the focused
  class, ColdGeneration, affected ModuleGraph and complete Cache prefixes.
- Task impact/evidence: official Development Editor RED command
  `Tools\\RunBuild.ps1 -Label cache-v2-opaque-atomic-promotion-red-attempt-1
  -TimeoutMs 180000` failed with wrapper/process exit `1/6` at
  `Saved/Build/cache-v2-opaque-atomic-promotion-red-attempt-1/20260810_092220_271_dad54890`.
  The only compiler error is C3861 at
  `AngelscriptCacheCleanCaptureOpaqueValidationTests.cpp(362)` for the wished-for
  `ValidateAndPromoteAngelscriptCleanCompiledModuleArtifacts`; the mutation,
  reserialization and assertion fixture otherwise compiles. No Runtime source was
  changed before this RED. The API implementation built at
  `Saved/Build/cache-v2-opaque-atomic-promotion-green-build-attempt-1/20260810_092325_077_014db2b3`.
  Normal capture now routes through the same operation. After IC-281's message-
  routing correction, all four malformed candidates passed their rejection
  assertions `2/2` at
  `Saved/Tests/cache-v2-detached-validation-quiet-green-attempt-1/20260810_092545_012_02e8db04`,
  followed by `1/1` ColdGeneration, `30/30` affected module families and
  `334/334` complete Cache.

## IC-281 — Detached execution validation publishes expected corruption as an engine error log

- Severity/state: V1.4 production validation side-effect defect / closed
  2026-08-10.
- Exact boundary: all structural assertions for truncated/corrupt FunctionBody
  payloads already pass: graph error is OpaqueCodec, validated count is zero and
  the pre-populated output is reset. Nevertheless `asCReader::Error` always calls
  `engine->WriteMessage(asMSGTYPE_ERROR, ...)`. Malformed-input validation is an
  eligibility operation, so these expected failures escape the result channel as
  global AngelScript errors and UE Automation marks the otherwise-correct method
  failed. Debug corruption does not use `asCReader` and passes both variants.
- Decision: while `validatingFunctionArtifact` is true, retain the reader error
  bit, result, stage, byte counts and half-created cleanup but do not publish a
  global engine message. Ordinary whole-module `LoadByteCode` keeps the existing
  error message behavior. The Runtime codec remains responsible for returning the
  bounded failure detail to Cache diagnostics.
- Required evidence: preserve the `1/2` focused run and exact emitted messages;
  make only the detached-reader message-routing correction, rebuild, and rerun
  the same class. Both execution and debug methods must pass while their info logs
  retain exact OpaqueCodec results and zero output.
- Task impact/evidence: the first focused run at
  `Saved/Tests/cache-v2-opaque-atomic-promotion-green-attempt-1/20260810_092346_320_1e78bb72`
  executed two tests: Debug passed, Execution failed. Execution's own info rows
  prove `Error=8`, `GraphRecords=0`, `OutputRecords=0`, FunctionBody `Kind=5`,
  `Stage=4` for both mutations, but Automation captured `Unexpected end of file`
  and `LoadByteCode failed...` as Error log events. Source tracing reaches the
  unconditional `engine->WriteMessage` in `asCReader::Error`; there is no graph,
  serializer, assertion or Store failure. The detached-only message correction
  built with wrapper/process exit `0/0` at
  `Saved/Build/cache-v2-detached-validation-quiet-green-build-attempt-1/20260810_092533_584_bb262966`.
  The identical focused class then passed `2/2`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v2-detached-validation-quiet-green-attempt-1/20260810_092545_012_02e8db04`;
  expected failures remain visible as bounded Cache info diagnostics without any
  global AngelScript Error event. Ordinary module restore message routing was not
  changed, and complete Cache subsequently passed `334/334`.

## IC-282 — Store implements operation failures but has no exact named crash-checkpoint seam

- Severity/state: V2.6 publication/crash evidence gap / closed 2026-08-10.
- Exact boundary: the frozen Store contract names twelve checkpoints spanning
  Pack temp creation through Current/Pending commit. Runtime currently exposes
  filesystem operations and cancellation callbacks, so existing tests can fail
  writes, reads, renames, replacements and syncs, but no production transaction
  surface identifies those twelve exact boundaries. Tests cannot distinguish
  "temp flushed but not reopened" from a nearby file-operation count, prove the
  checkpoint order, or simulate a process stop without normal cleanup.
- Decision: add one transaction-local optional fault injector carrying an exact
  enum. The normal caller passes null; there is no global state or persisted
  identity input. Pack, Manifest and pointer helpers forward the same injector.
  An injected stop returns a distinct Store control-flow error, preserves the
  correct commit state, and deliberately leaves the exact crash-visible temp/
  final/pointer state for a later publisher to clean and recover.
- Required evidence: independent production-disk tests cover all five immutable,
  all five Current/Previous, and both Pending checkpoints. Every case asserts
  temp/final/pointer state, exact pre/post-commit result, then runs a new writer
  which cleans strict temps, rereads roots and publishes/reuses the valid target.
  After the focused GREEN, run complete Store and Cache regressions.
- Task impact/evidence: the official Development Editor TDD build
  `Tools\\RunBuild.ps1 -Label cache-v26-fault-checkpoint-api-red-attempt-1
  -TimeoutMs 1800000 -NoXGE` failed as intended with wrapper/process exit `1/6`
  at
  `Saved/Build/cache-v26-fault-checkpoint-api-red-attempt-1/20260810_094151_509_d35fd5b7`.
  The new `AngelscriptCacheStoreFaultInjectionTests.cpp` is discovered by UBT;
  its first errors are the absent `IAngelscriptCacheStoreFaultInjector` and
  `EAngelscriptCacheStoreFaultPoint`, followed by the deliberately requested
  `FaultInjected` result/API argument. No existing Runtime source was changed
  before this RED.
  The production API built at
  `Saved/Build/cache-v26-fault-checkpoint-green-build-attempt-2/20260810_094550_021_8c6a4ed6`.
  All twelve exact points passed in three grouped production-disk methods at
  `Saved/Tests/cache-v26-fault-checkpoint-green-attempt-1/20260810_094615_473_4fbc6148`;
  every case then recovered through a new normal publisher. The actual-thread
  publisher and pinned-reader/writer compositions passed `2/2` at
  `Saved/Tests/cache-v26-store-concurrency-attempt-1/20260810_095009_844_093f6527`.
  Complete Store passed `91/91`, and complete Cache passed `339/339`, both with
  zero failure/skip and wrapper/process exit `0/0`.

## IC-283 — Windows PowerShell promotes unittest progress stderr into wrapper errors

- Severity/state: V2.7 test-entry reliability defect / closed 2026-08-10.
- Exact boundary: Python `unittest -v` writes its ordinary progress and final
  report to stderr. Windows PowerShell 5's native redirection wraps those rows as
  `NativeCommandError`; with the wrapper's normal stop-on-error policy the first
  intended missing-module RED terminated before writing its structured summary.
  Merely changing ErrorActionPreference allowed completion but still polluted a
  successful log with PowerShell error metadata.
- Decision: keep Python's native stdout/stderr behavior and launch one foreground
  `System.Diagnostics.Process` with both streams redirected. Read both streams,
  wait for completion, preserve `Process.ExitCode`, emit one combined log, and
  write the wrapper summary after the process exits. This changes only test
  transport; the dump tool never invokes PowerShell.
- Required evidence: a missing-module RED must write `summary.json` with exit 1;
  a GREEN verbose run must contain ordinary unittest rows without
  `NativeCommandError`, and the wrapper/process exit must be 0/0.
- Task impact/evidence: the incomplete first wrapper attempt is
  `Saved/Tests/cache-v27-python-red-attempt-1`; the corrected RED is
  `Saved/Tests/cache-v27-python-red-attempt-2`. Clean final wrapper output and
  exit `0/0` are preserved at
  `Saved/Tests/cache-v27-python-corruption-attempt-1`, where all 13 tests pass.

## IC-284 — Standalone Python has no standard BLAKE3 while every Cache V2 identity requires it

- Severity/state: V2.7 portability/integrity implementation risk / closed
  2026-08-10.
- Exact boundary: the local Python 3.14 standard library provides no BLAKE3 and
  the `blake3` module is not a valid required bootstrap dependency. Pointer
  checksums, RawChecksum, RecordId, PackId and GenerationId all use BLAKE3;
  omitting recomputation would let corrupt input appear valid. A short-input-only
  implementation would also fail real Packs after the 1024-byte tree boundary.
- Decision: implement the exact unkeyed BLAKE3-256 algorithm as a dependency-free
  fallback and use an already-installed `blake3` package only as an optional
  accelerator. Freeze official empty/`abc` vectors, a deterministic 4097-byte
  multi-chunk tree vector, and the existing C++ Pack/Manifest/Zlib golden
  identities. RecordId separately freezes the Runtime's
  `UEAS-CACHE-RECORD\0 + archive-schema + kind + payload-size + payload` domain.
- Required evidence: Python vectors and C++ frozen bytes must pass; direct Pack/
  Manifest reads must report exact existing IDs, and mutated Pack bytes must fail
  nonzero. Dump-tool behavior belongs to the Python suite rather than UE
  Automation.
- Task impact/evidence: Python passed `13/13` at
  `Saved/Tests/cache-v27-python-corruption-attempt-1`; the complete Cache prefix
  passed `340/340` before IC-285 removed the redundant one-method UE test, at
  `Saved/Tests/cache-v27-complete-cache-regression-attempt-1`.

## IC-285 — Python dump behavior was redundantly represented as a UE test

- Severity/state: V2.7 test-ownership and maintenance issue / closed 2026-08-10.
- Exact boundary: `AngelscriptCachePythonDumpContractTests.cpp` did not launch
  Python and did not read a Cache V2 artifact. It only recomputed one BLAKE3
  vector already asserted by the Python suite, so its name implied integration
  coverage that it did not provide and increased the complete UE Cache count by
  one unrelated method.
- Decision: remove the C++ file. Python owns dump/parser/CLI/fallback-hash tests;
  existing C++ Manifest/Pack tests own writer-format golden bytes; the Python
  suite consumes those exact C++ bytes to prove the useful compatibility seam.
- Required evidence: Python remains `13/13`; OpenSpec no longer cites the removed
  method as acceptance authority; the next full Cache run is expected to discover
  `339` methods unless other tests are added first.
- Task impact/evidence: no production code changed. The Python method was also
  renamed from `test_unreal_cross_runtime_tree_vector` to
  `test_multichunk_tree_vector` so its name describes its actual ownership.
  Historical build and full Cache evidence remain valid for V2.7 behavior, but
  the focused `1/1` run is explicitly non-authoritative and the redundant source
  file is deleted. The corrected Python-only suite passed `13/13` at
  `Saved/Tests/cache-v27-python-test-ownership-correction-2`.

## IC-286 — Focused V3.1 test was prevented by another project's live Build.bat lock

- Severity/state: V3.1 verification-entry contention / closed 2026-08-10.
- Exact boundary: after the V3.1 Development Editor build succeeded, the first
  `Tools\RunTests.ps1 -TestPrefix
  Angelscript.TestModule.Cache.DirectSourcePlanner -Label
  cache-v31-direct-source -OutputRoot
  Saved/Tests/cache-v31-direct-source-attempt-1 -Fast -TimeoutMs 600000`
  attempt never launched Unreal Automation. It waited about 201 seconds for
  `C:\Users\scottmei\AppData\Local\Temp\C-Program Files-Epic
  Games-UE_5.8-Engine-Build-BatchFiles-Build.bat.lock` and then reported that
  the lock did not release. Process inspection showed live PID 67732 running
  `UnrealBuildTool.dll SigilProjectEditor Win64 Development
  D:\Workspace\SigilProject\SigilProject.uproject -WaitMutex`, with its XGE
  `BuildSystem.exe` child started at the same time. No V3.1 test method ran.
- Decision: do not delete a live cross-project lock and do not terminate the
  other project's build. Continue local source/OpenSpec work, poll process state,
  and retry the official test wrapper only after the owner exits naturally.
- Required evidence: the owner PID disappears and the lock releases; the retry
  must produce an ordinary Automation report with discovered/pass/fail counts.
  The lock-only attempt is infrastructure evidence, never a feature RED/GREEN.
- Resolution/evidence: PID 67732 exited naturally; no lock file was deleted and
  no external build was terminated. The retry acquired the build lock after
  about 4046 ms and produced the ordinary Automation artifact
  `Saved/Tests/cache-v31-direct-source-attempt-2/Tests/cache-v31-direct-source/20260810_104606_207_0e2f938f`.
  That run reached all five then-current methods and produced a genuine behavior
  RED, which is separately recorded as IC-287. Later focused attempts acquired
  the lock in 3–4 ms. The final focused report passed `10/10`, and the complete
  Cache prefix passed `349/349` at
  `Saved/Tests/cache-v31-complete-cache-regression-attempt-1/Tests/cache-v31-complete-cache-regression/20260810_105834_737_ac33983e`.
- Task impact/evidence: the transient infrastructure contention is closed and
  did not require a production workaround. The first wrapper's misleading outer
  shell exit remains a runner-observation rule: acceptance requires `Summary.json`
  or `Report/index.json`, discovered counts and process/wrapper exit codes, not a
  shell exit alone.

## IC-287 — FString terminator was mistaken for an embedded NUL in direct options

- Severity/state: V3.1 validation and test-fixture correctness / closed
  2026-08-10.
- Exact boundary: the first real focused behavior run at
  `Saved/Tests/cache-v31-direct-source-attempt-2/Tests/cache-v31-direct-source/20260810_104606_207_0e2f938f`
  executed the five then-current methods and failed `0/5`. Every valid input was
  rejected with validation error `18` because production used
  `FString::FindChar(TEXT('\0'), ...)`; the search sees FString's required
  terminal NUL as well as characters within its logical length. The first
  regression fixture also attempted `AppendChar(0)`, which is a no-op and did
  not construct a true embedded-NUL value.
- Decision: validate embedded NUL only over logical indices `[0, Len)`. Construct
  the hostile fixture through `GetCharArray().Insert(TEXT('\0'), 2)`, assert its
  logical length and the zero code unit before invoking production, and retain a
  dedicated fail-closed method so the terminator/embedded distinction cannot
  regress.
- Required evidence: ordinary valid options must pass; a real embedded NUL in an
  option value must fail; empty raw option keys must fail before namespace
  prefixing; shared string/option budgets and the frozen direct-digest identity
  must remain deterministic.
- Resolution/evidence: the bounded scan compiled at
  `Saved/Build/cache-v31-direct-source-nul-fix-build-attempt-1/Build/cache-v31-direct-source-nul-fix-build/20260810_104728_597_78fa529e`,
  and the initial five-method focused class passed `5/5` at
  `Saved/Tests/cache-v31-direct-source-attempt-3/Tests/cache-v31-direct-source/20260810_104743_332_16c57872`.
  The expanded RED matrix then exposed the empty-key, aggregate-budget and
  invalid-fixture gaps (`5/10` at
  `Saved/Tests/cache-v31-direct-source-hardening-split-red-attempt-1/Tests/cache-v31-direct-source-hardening-split-red/20260810_105123_094_855c6e53`).
  After correcting those boundaries and freezing
  `a0344dacb06ef4c92ec9a8a413d1bbcca7a4814d80ad2d1f1b2bac4157202197`,
  the final class passed `10/10` and the complete Cache prefix passed `349/349`.
- Task impact/evidence: V3.1 now distinguishes the FString storage terminator
  from hostile logical content and shares limits across every direct authority.
  No wire schema changed.

## IC-288 — V3.2 generated-source fixture used a BuiltInDisk provider and crashed on check

- Severity/state: V3.2 test-fixture/source-contract mismatch / closed 2026-08-10.
- Exact boundary: the first focused V3.2 run at
  `Saved/Tests/cache-v32-dependency-candidate-attempt-1/Tests/cache-v32-dependency-candidate/20260810_110957_217_b60050a3`
  discovered the new prefix and entered its first method, but emitted no report
  because `BuildDirectPlan` failed inside the fixture and a helper `check`
  terminated Editor-Cmd. `Summary.json` records exit `3` and no totals; the log
  points to `AngelscriptCacheDependencyCandidateTests.cpp:236`.
- Root cause: the fixture assigned `GeneratedSourceKey` and
  `GeneratedConfigurationFingerprint` to a file mounted through a
  `BuiltInDisk` provider. The existing sole SourceIndex semantic authority
  intentionally requires generated-key presence to be exactly equivalent to a
  `Generated` provider kind, so it rejected the direct plan with
  `InvalidPresence` before any V3.2 candidate API ran.
- Decision: retain the production invariant. Give the generated fixture its own
  typed `Generated` provider and Mount; do not weaken SourceIndex or hide the
  fixture defect inside the V3.2 planner.
- Required evidence: the same focused prefix must reach all methods through the
  official wrapper without an assertion/crash, and the complete Cache prefix
  must remain GREEN before V3.2 closes.
- Resolution/evidence: the generated fixture now uses its own `Generated`
  provider and typed Mount. The unchanged production invariant compiled at
  `Saved/Build/cache-v32-generated-fixture-fix-build-attempt-1/Build/cache-v32-generated-fixture-fix-build/20260810_111145_921_db49bb79`.
  The focused prefix then reached and passed all `8/8` methods, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v32-dependency-candidate-attempt-2/Tests/cache-v32-dependency-candidate/20260810_111406_005_d85903c5`.
  The complete Cache prefix passed `357/357` at
  `Saved/Tests/cache-v32-complete-cache-regression-attempt-1/Tests/cache-v32-complete-cache-regression/20260810_111543_110_4cef0ceb`.
- Task impact/evidence: IC-288 is closed as a fixture correction. The first
  no-report crash remains explicitly non-behavioral evidence; V3.2 acceptance is
  based on the later ordinary reports.

## IC-289 — V3.3 implementation build was denied by saturated XGE capacity

- Severity/state: V3.3 verification infrastructure contention / closed
  2026-08-10.
- Exact boundary: the first post-implementation official command,
  `Tools\RunBuild.ps1 -Label cache-v33-production-discovery-build -TimeoutMs
  180000`, reached UBT but XGE rejected all 108 requested actions with
  `Maximum number of concurrent builds reached`. No C++ action ran. The artifact
  is
  `Saved/Build/cache-v33-production-discovery-build/20260810_114007_109_f6483c3d`.
- Decision: do not treat an executor-capacity refusal as implementation RED and
  do not interfere with other builds. Rerun the same worktree through the
  official wrapper with `-NoXGE`, which keeps build ownership and logs isolated
  while using the local executor.
- Required evidence: the `-NoXGE` retry must execute the changed C++ actions and
  either provide ordinary compiler diagnostics or pass wrapper/process `0/0`.
- Resolution/evidence: the `-NoXGE` retry entered the local UBA executor and
  completed 93 of 108 actions with no compiler error before the separate
  180-second wrapper timeout recorded as IC-290. This proves the XGE admission
  blocker was bypassed, but does not prove the full build.
- Task impact/evidence: no production workaround or external-process
  interference was introduced.

## IC-290 — First local V3.3 implementation build exceeded the 180-second limit

- Severity/state: V3.3 verification timeout / closed 2026-08-10.
- Exact boundary: `Tools\RunBuild.ps1 -Label
  cache-v33-production-discovery-build-noxge -TimeoutMs 180000 -NoXGE`
  executed the real changed build locally and completed 93/108 actions without
  a compiler error, but the wrapper reached its 179750 ms deadline before the
  remaining compile/link actions. It terminated the UBT process tree and
  reported process `124`, wrapper `2`. The artifact is
  `Saved/Build/cache-v33-production-discovery-build-noxge/20260810_114111_588_f016cfb2`.
- Decision: keep `-NoXGE` and rerun the now-incremental build with the official
  wrapper at `TimeoutMs 600000`. Do not infer success from partial actions.
- Required evidence: the retry must finish all actions and report wrapper/process
  `0/0`, or expose ordinary compiler/linker diagnostics for correction.
- Resolution/evidence: the incremental `-NoXGE -TimeoutMs 600000` retry completed
  all remaining 14 actions and reported process/wrapper `0/0` at
  `Saved/Build/cache-v33-production-discovery-build-noxge-600s/20260810_114443_692_d4b057a4`.
- Task impact/evidence: no source correction was made for the timeout; V3.3 can
  proceed to focused behavior tests.

## IC-291 — V3.3 accepted a provider-injected module name and conflated budget failure with path invalidity

- Severity/state: V3.3 stable-coordinate correctness and diagnostic taxonomy /
  closed 2026-08-10.
- Exact boundary: after extending the production-discovery matrix from eight to
  twelve methods, the official focused RED run reported `10/12`, failed `2`,
  skipped `0`, at
  `Saved/Tests/cache-v33-discovery-coordinate-budget-red-attempt-1/Tests/cache-v33-discovery-coordinate-budget-red/20260810_115712_989_305e921f`.
  `MismatchedDerivedModuleNameFailsBeforeReading` observed success (`0`) instead
  of `InvalidSourceDescriptor` (`4`), while
  `ModuleNameBudgetIsTypedBeforeReading` observed `InvalidSourceDescriptor`
  (`4`) instead of `DirectPlanRejected` (`5`). The two raw-byte budget additions
  passed in the same run.
- Root cause: discovery verified the typed virtual-path parts and required a
  nonempty `ModuleName`, but never compared that name with
  `VirtualPath.ToModuleName()`. It also placed the module-name character budget
  inside the structural-path predicate, so a resource limit was reported as
  `InvalidLogicalPath` rather than `BudgetExceeded`.
- Decision: preserve the authoritative source coordinate. Reject a module-name
  mismatch before source I/O, and split configured-budget preflight from
  structural descriptor validation. Do not derive a second module identity from
  provider-supplied inconsistent text and do not weaken the limit.
- Required evidence: verify each failed method independently after its minimal
  fix, then pass the complete twelve-method discovery prefix, SourceProvider
  compatibility prefix and complete Cache regression before closing V3.3.
- Resolution/evidence: the stable module-coordinate check compiled at
  `Saved/Build/cache-v33-module-coordinate-fix-build/Build/cache-v33-module-coordinate-fix-build/20260810_115834_824_fa21b299`
  and its exact test passed `1/1` at
  `Saved/Tests/cache-v33-module-coordinate-fix-attempt-1/Tests/cache-v33-module-coordinate-fix/20260810_115848_575_631b84ab`.
  The separated budget preflight compiled at
  `Saved/Build/cache-v33-module-budget-fix-build/Build/cache-v33-module-budget-fix-build/20260810_115932_981_1a93f0ec`
  and its exact test passed `1/1` at
  `Saved/Tests/cache-v33-module-budget-fix-attempt-1/Tests/cache-v33-module-budget-fix/20260810_115946_423_ff99ec9f`.
  The final discovery class is `12/12`, SourceProvider compatibility is `4/4`,
  and complete Cache is `371/371` at the exact artifacts recorded in
  `verification.md`.
- Task impact/evidence: IC-291 is closed without a persisted wire change.
  V3.3 now rejects a provider-injected alternate module coordinate before source
  I/O and preserves distinct structural-versus-budget failure domains.

## IC-292 — Producer module-eligibility planning repeats whole-SourceIndex preparation

- Severity/state: V3.3/V6 startup scaling and cumulative-accounting debt / open
  2026-08-10, non-blocking for V3.3 correctness but required before V6 lifecycle
  acceptance.
- Exact boundary: `DiscoverProductionSources` currently loops every discovered
  module and calls `QueryCurrentExactFastPathEligibility` with a fresh read
  budget. That producer query recomputes/validates the complete SourceSnapshot
  and rebuilds file/hook scratch indexes for each module before invoking the sole
  matching implementation. Focused and complete tests prove the answers, not a
  linear batching cost; `371/371` therefore does not close this performance item.
- Root cause: V3.3 correctly avoided duplicating decoded-record eligibility
  rules, but the only shared producer entry point was a one-module validated
  query. Reusing it in a loop trades semantic consistency for avoidable repeated
  preparation, and fresh per-module budgets do not express a cumulative result
  allocation bound.
- Decision: retain the one matching authority and add a validated/prepared batch
  query rather than copying its logic into discovery. Validate SourceSnapshot
  once, construct reusable indexes once where possible, use one cumulative
  accounting owner and publish module results atomically. Do not weaken exact
  scope/hook closure or expose an unchecked public query.
- Required evidence: a TDD matrix must prove single preparation, equality with
  the decoded one-module authority, cumulative budget failure with empty output,
  deterministic module order and a many-module benchmark before V6 production
  startup integration. V7 retains cold/warm performance acceptance.
- Resolution/evidence: pending.
- Task impact/evidence: V3.4 fresh-engine correctness may proceed. IC-292 must be
  closed before V6 claims the Editor/PIE production lifecycle is ready.

## IC-293 — A VM-only restore would leave `FAngelscriptEngine` internally incomplete

- Severity/state: V3.4 activation correctness / closed 2026-08-10.
- Exact boundary: V3.3's opaque validator constructs and destroys a detached
  `asCScriptFunction`, while the existing legacy Stage1/2/3 path is invoked from
  `FAngelscriptEngine` compilation and relies on an already populated
  `FAngelscriptModuleDesc`. Extending only `asCReader` to publish an
  `asCModule` would leave `ActiveModules`, `ModulesByScriptModule`, active
  class/enum/delegate indexes, descriptor live links, ClassGenerator/reflection
  handoff and the new stable function route table absent or inconsistent.
- Root cause: the maintained fork owns VM reconstruction mechanics, but
  `FAngelscriptEngine` is the product-level module/lifecycle owner. Earlier
  V3.4 wording named fresh-engine activation without explicitly separating
  freshly initialized environment state from the Cache-reconstructed script
  projection.
- Decision: make the V3.4 coordinator engine-owned and preserve an immutable
  candidate -> staging projection -> active projection boundary. Recreate
  binds/TypeDatabase environment normally; rebuild script-derived VM and plugin
  descriptor state from the validated semantic records; publish module indexes,
  reflection handoff and stable routes only after complete validation. A raw
  `asCModule*` execution test is necessary but not sufficient. The detailed
  contract and tests are fixed in `v3.4-fresh-engine-restore.md`.
- Required evidence: Engine A must be destroyed before Engine B restores;
  Engine B must expose the restored function through normal module lookup and
  the engine-owned stable route, execute it, expose the reconstructed enum and
  module descriptor, and leave all active/plugin route state empty after an
  injected late failure. Complete Cache regression remains required.
- Resolution/evidence: the maintained fork now restores a complete private
  `asCScriptFunction` into a staging `asCModule`, assigns a current-Engine
  numeric ID and attaches it through the normal VM registries. The engine-owned
  coordinator reconstructs the admitted enum/module descriptor, runs the
  ClassGenerator handoff, swaps the module into `ActiveModules` and
  `ModulesByScriptModule`, and only then publishes the stable route table. The
  focused class passes `4/4` at
  `Saved/Tests/cache-v34-route-tests-green/20260810_124331_825_81601c2d`:
  physical disk reopen executes `Answer()==42`; a VM/debug apply failure leaves
  active modules/types/routes empty and permits authoritative compile; duplicate
  route activation is rejected; discard removes the route; and two isolated
  Engines both allocate numeric ID `79776` yet resolve distinct live function
  pointers. The authoritative complete Cache prefix then passed `375/375` at
  `Saved/Tests/cache-v34-complete-cache-regression/20260810_124733_974_69772c2e`.
- Task impact/evidence: this is a correctness requirement for V3.4, not a V6
  production-integration deferral. Later class/global verticals must extend the
  same coordinator rather than create parallel restore paths.

## IC-294 — Exact restore needs a transient current-source projection

- Severity/state: V3.4 descriptor completeness and V6 HotReload integration /
  partially resolved 2026-08-10; V3.5 closes the exact-start/current-path portion,
  while subsequent real HotReload/source-navigation lifecycle evidence remains
  open for V6.
- Exact boundary: persisted `SourceIndex` intentionally retains stable provider,
  mount and relative logical coordinates plus hashes, but not host absolute
  paths or preprocessor scratch text. The first restore adapter can therefore
  reconstruct `FCodeSection::VirtualPath` and `RelativeFilename`, while
  `AbsoluteFilename`, raw/current source ownership, `Code` and the legacy
  64-bit `CodeHash` remain unavailable. Filling those fields with cached host
  paths or treating raw `.as` bytes as preprocessed code would violate
  relocation independence and exact warm-start semantics; leaving every field
  empty is insufficient for later file watching, source navigation and
  HotReload after warm activation.
- Root cause: `FAngelscriptModuleDesc::FCodeSection` combines durable semantic
  coordinates with transient discovery/preprocessor state. V3.3 has the
  authoritative current provider inventory and exact raw bytes in memory, while
  the V3.4 proof intentionally accepts only the persisted generation and thus
  exposes the ownership split.
- Decision: do not serialize host absolute paths and do not rerun preprocessing
  merely to recreate obsolete scratch. Production restore must receive a
  bounded transient current-source view from V3.3 discovery, prove its
  SourceFileKey/content agreement with the selected generation, and project the
  current absolute/watch coordinates into the module descriptor. Any remaining
  consumers of preprocessed `FCodeSection::Code` must be moved to semantic Cache
  records or an explicit lazily rebuilt DTO; raw source must never masquerade as
  preprocessed source.
- Required evidence: a warm-restored production module must support source
  navigation and a subsequent real HotReload edit using current machine paths;
  an unchanged second launch must still report zero preprocessing; relocation to
  another Saved/project root must not invalidate a semantically identical
  generation solely because an absolute path changed; mismatched transient
  source keys must fail before activation.
- Resolution/evidence: V3.5 production discovery now carries a bounded transient
  current-source projection; exact restore proves its full source/module keys,
  logical coordinates and raw-byte content hash before staging, projects the
  current absolute path, and deliberately leaves preprocessed `Code`/`CodeHash`
  absent. Unchanged and relocated restores plus the tampered-projection miss pass
  in `Saved/Tests/cache-v35-final-exact-warm/20260810_132038_346_5b02677b`.
  The unchanged branch reports zero frontend/compiler work and relocation uses
  SourceB's absolute path with the original generation identity.
- Remaining evidence: V6 must wire this same projection into the real production
  startup owner, prove source navigation/file watching against the restored module
  and perform a subsequent real HotReload edit. Do not create a second projection
  or serialize host paths to close that lifecycle work.
- Task impact/evidence: the exact-start subset no longer blocks V3.5. IC-294 stays
  open only for the named V6 Editor lifecycle evidence; V3.5 does not claim that
  the current Editor globally boots project classes from Cache V2.

## IC-295 — First V3.4 implementation build hit a local shadow-warning error

- Severity/state: V3.4 compile correction / closed 2026-08-10.
- Exact boundary: the first post-RED implementation build at
  `Saved/Build/cache-v34-fresh-engine-restore-impl-build-1/20260810_122827_472_9cbd7795`
  reached the new restore coordinator but failed C4456 because a local decoded
  ModuleState variable reused the name `Candidate` already used for candidate
  transaction terminology.
- Decision: rename the local records to `InterfaceCandidate` and
  `StateCandidate`; do not disable warnings or weaken the build configuration.
- Required evidence: the same Runtime/Test implementation must compile through
  the official wrapper and then reach the focused behavior test.
- Resolution/evidence: the correction passed process/wrapper `0/0` at
  `Saved/Build/cache-v34-fresh-engine-restore-impl-build-2/20260810_123025_542_a0af6aaa`,
  and the first executable fresh-engine method subsequently passed `1/1` at
  `Saved/Tests/cache-v34-fresh-engine-restore-green-attempt-1/20260810_123054_571_77152844`.
- Task impact/evidence: no behavior or persisted format changed; this was a
  local naming correction.

## IC-296 — A 10-second outer tool deadline interrupted one disk-reopen launch

- Severity/state: V3.4 verification harness invocation / closed 2026-08-10.
- Exact boundary: `cache-v34-disk-reopen-green-attempt-1` invoked the official
  `RunTests.ps1` wrapper with its proper 300-second test limit, but the outer
  shell request itself had a 10-second deadline. UnrealEditor-Cmd was terminated
  during startup and no behavior result was produced.
- Decision: retain the official wrapper's 300-second limit and give the outer
  command a matching 310-second allowance. Do not classify process startup
  interruption as a product failure or alter test logic.
- Required evidence: rerun the identical focused prefix to a normal Automation
  report with wrapper/process `0/0`.
- Resolution/evidence: the corrected invocation passed `1/1` and physically
  reopened one pinned Pack at
  `Saved/Tests/cache-v34-disk-reopen-green-attempt-2/20260810_123626_188_bbe08ffa`.
- Task impact/evidence: none; the interrupted attempt is not RED or GREEN
  behavior evidence.

## IC-297 — OpenSpec apply-instruction progress command used obsolete argument order

- Severity/state: V3.4 record verification invocation / closed 2026-08-10.
- Exact boundary: after strict validation and both diff checks passed, the first
  progress query used `openspec instructions apply
  refactor-as-incremental-function-cache`. The installed CLI accepts one
  positional artifact and requires the change through `--change`, so it returned
  `too many arguments`; this did not alter files or invalidate the already
  successful strict/diff results.
- Decision: inspect `openspec instructions --help` and use the installed syntax
  `openspec instructions apply --change
  refactor-as-incremental-function-cache`. Do not infer progress from a failed
  query or change the OpenSpec files to accommodate an obsolete command shape.
- Required evidence: the corrected command must exit zero and list the checked
  V3.4 item.
- Resolution/evidence: the corrected command exited `0` and reports `20/43`
  complete with V3.4 checked and V3.5 first pending.
- Task impact/evidence: none; V3.4 behavior evidence remains the official build,
  test, strict-validation and diff-check artifacts.

## IC-298 — Current source projection compared wrapper keys directly

- Severity/state: V3.5 compile correction / closed 2026-08-10.
- Exact boundary: the first exact-start implementation build at
  `Saved/Build/cache-v35-exact-warm-impl-build-1/20260810_130734_730_c4d10882`
  compiled the new discovery/capture/coordinator sources but failed in the
  restore projection join because `FAngelscriptCachedSourceFileKey` deliberately
  has no wrapper-level `operator==`.
- Root cause: the new join compared the strong wrapper objects directly instead
  of their canonical `FAngelscriptHash256 Hash` members. Existing semantic key
  wrappers are nominal coordinate types; equality is expressed through their
  contained full hashes unless that specific wrapper defines an operator.
- Decision: compare `SourceFileKey.Hash` at both the validation and descriptor-
  projection joins. Do not add a broad implicit operator merely to satisfy these
  local sites or weaken the strong-key types.
- Required evidence: the same implementation must pass the official wrapper
  build and reach the focused V3.5 behavior tests.
- Resolution/evidence: the two joins now compare the full 256-bit hash members.
  The final official build passed at
  `Saved/Build/cache-v35-final-memory-transfer-build/20260810_131939_595_4a650427`;
  exact startup passed `4/4` at
  `Saved/Tests/cache-v35-final-exact-warm/20260810_132038_346_5b02677b`, and the
  complete Cache prefix passed `379/379` at
  `Saved/Tests/cache-v35-final-complete-cache/20260810_132137_955_1755286f`.
- Task impact/evidence: no persisted bytes, hash domains or behavior contract
  changed.

## IC-299 — Restore duplicated the root slash of production logical mounts

- Severity/state: V3.5 exact activation correctness / closed 2026-08-10.
- Exact boundary: the first focused V3.5 run at
  `Saved/Tests/cache-v35-exact-warm-green-attempt-1/20260810_130833_753_960e1b01`
  passed the changed-source and tampered-projection methods but failed the two
  successful-restore methods (`2/4`). Both failed closed before Engine mutation
  because the transient virtual path did not equal the persisted logical path.
- Root cause: the V3.4 legacy convenience capture stores `Game` as its logical
  mount, while V3.3 production discovery uses the canonical
  `/Angelscript/Game`. `BuildLogicalVirtualPath` was written for the legacy form
  and unconditionally prepended `/`, producing
  `//Angelscript/Game/ExactWarm.as` for the authoritative production candidate.
- Decision: the restore projection accepts both already persisted forms at this
  compatibility seam by prepending a root slash only when the logical mount does
  not already start with one. Production discovery remains the canonical
  authority; no persisted V3.3 SourceIndex bytes or stable-key inputs change.
- Required evidence: unchanged and relocated exact warm starts must activate
  with `/Angelscript/Game/ExactWarm.as`, use the current absolute path, execute
  the cached function and retain zero frontend/publication work; the two miss
  cases must remain GREEN.
- Resolution/evidence: the helper now performs conditional root normalization.
  The final focused run passed `4/4` at
  `Saved/Tests/cache-v35-final-exact-warm/20260810_132038_346_5b02677b`; both
  unchanged and SourceA-to-SourceB relocation restored the cached function and
  retained zero frontend/publication work. The complete Cache prefix passed
  `379/379` at
  `Saved/Tests/cache-v35-final-complete-cache/20260810_132137_955_1755286f`.
- Task impact/evidence: this is an integration defect caught by IC-294's
  transient projection gate. The failed transaction published no module/type/
  route state.

## IC-300 — V4.1 public compile-policy rebuild exceeded the short wrapper timeout

- Severity/state: V4.1 build-infrastructure timing / closed 2026-08-10.
- Exact boundary: `Tools\RunBuild.ps1 -Label
  cache-v41-forced-clean-impl-build-1 -TimeoutMs 180000` at
  `Saved/Build/cache-v41-forced-clean-impl-build-1/20260810_133353_025_7ae0aa15`
  regenerated UHT bindings and scheduled 99 compile/link actions because
  `AngelscriptEngine.h` and the compilation-event surface changed. It reached
  action `67/99` without a compile error, then the wrapper terminated the process
  tree at its configured 180-second limit (`ProcessExitCode=124`,
  `FinalExitCode=2`).
- Decision: do not treat the timeout as source failure and do not narrow the
  compile-policy API merely to avoid the correct rebuild. Rerun the same official
  Development Editor build with a 600-second timeout so completed objects may be
  reused; diagnose source only if the longer run emits an actual compiler/linker
  error.
- Required evidence: the longer wrapper run must complete with process/wrapper
  `0/0` before either V4.1 behavior test is launched.
- Resolution/evidence: the 600-second rerun reused the completed objects and
  finished the remaining 32 actions with process/wrapper `0/0` at
  `Saved/Build/cache-v41-forced-clean-impl-build-2/20260810_133714_877_b72f6b1b`.
  The focused behavior class then passed `2/2` at
  `Saved/Tests/cache-v41-forced-clean-green-attempt-1/20260810_133757_487_fc00e815`,
  and complete Cache passed `381/381` at
  `Saved/Tests/cache-v41-forced-clean-complete-cache/20260810_134134_892_5078dbcc`.
- Task impact/evidence: no source or design correction was required; V4.1 may
  close on the longer build plus behavior/regression evidence.

## IC-301 — V4.2 TDD RED stopped at the missing semantic-diff API

- Severity/state: V4.2 intended compile RED / closed 2026-08-10.
- Exact boundary: the official Development Editor build
  `Tools\\RunBuild.ps1 -Label cache-v42-semantic-diff-red -TimeoutMs 600000`
  failed at
  `Saved/Build/cache-v42-semantic-diff-red/20260810_135341_468_1b3cad17`.
  UBT scheduled four actions and the new independent test TU failed only because
  `Cache/AngelscriptCacheSemanticDiff.h` did not exist.
- Decision: retain this as the intended behavior-first frontier and implement one
  Runtime comparator over two graph-validated generations; do not place the
  comparison in the test module or compare Pack bytes.
- Required evidence: the production header/implementation and test TU must pass
  the official Editor build before Automation runs.
- Resolution/evidence: the first implementation build compiled and linked all
  seven affected actions with process/wrapper `0/0` at
  `Saved/Build/cache-v42-semantic-diff-impl-build-1/20260810_135821_316_5ba59fe9`.
- Task impact/evidence: no prior Runtime behavior or persisted wire changed.

## IC-302 — ForceZlib was not a valid physical-difference fixture for every record

- Severity/state: V4.2 test-fixture assumption / closed 2026-08-10.
- Exact boundary: the first focused run at
  `Saved/Tests/cache-v42-semantic-diff-green-attempt-1/20260810_135852_610_c2c9812c`
  passed four real edit-classification methods and failed only
  `PhysicalPackDifferencesDoNotCreateSemanticChanges`, for `4/5`. Pack building
  rejected the FunctionBody with `UnsupportedStorageCodec` at PackDecode because
  `ForceZlibForTest` requires every non-empty payload to compress smaller; the
  opaque execution record legitimately did not.
- Root cause: the fixture treated forced Zlib as a general alternate layout,
  while its production contract is an all-record test assertion rather than a
  request to retain larger compressed bytes.
- Decision: prove physical independence deterministically with the same None
  codec but two Pack grouping policies: one aggregate target and a one-byte target
  that creates one-record shards. Both generations contain identical decoded
  RecordIds while their Pack/Manifest/Generation locations differ.
- Required evidence: the corrected focused class must pass all five methods and
  prove seven reused, zero new and zero retired semantic records.
- Resolution/evidence: the corrected build passed process/wrapper `0/0` at
  `Saved/Build/cache-v42-semantic-diff-fixture-fix-build/20260810_140103_635_1356eaf7`.
  The corrected five-method class passed `5/5` at
  `Saved/Tests/cache-v42-semantic-diff-green-attempt-2/20260810_140131_151_470415fe`;
  after adding the two fail-closed methods, the final focused class passed `7/7`
  at
  `Saved/Tests/cache-v42-semantic-diff-final-focused/20260810_140331_856_1467137c`.
  The physical regrouping case logged seven reused, zero new and zero retired
  semantic records even though the GenerationIds differed.
- Task impact/evidence: production Pack codec and semantic comparator behavior are
  unchanged; only the invalid physical-layout test input was corrected.

## IC-303 — V4.3 TDD RED stopped at the missing incremental Generation API

- Severity/state: V4.3 intended compile RED / closed 2026-08-10.
- Exact boundary: the official Development Editor build
  `Tools\\RunBuild.ps1 -Label cache-v43-incremental-generation-red -TimeoutMs
  600000` failed at
  `Saved/Build/cache-v43-incremental-generation-red/20260810_142019_531_68deff97`.
  UBT scheduled four actions and the new independent test TU failed only because
  `Cache/AngelscriptCacheIncrementalGeneration.h` does not yet exist
  (`C1083`); process/wrapper exit was `6/1`.
- Decision: retain this as the intended behavior-first frontier. Implement one
  Runtime preparation API over two validated generations. It must compute V4.2
  diff authority internally, build Packs only from current decoded `NewRecordIds`,
  copy exact base locations for reused IDs and emit a complete current Manifest;
  do not add a second Store transaction or accept caller-authored diff lists.
- Required evidence: production header/implementation must pass the official
  Editor build; the focused tests must prove exact new-record count, no-op
  determinism, mixed old/new Store publication, pinned-base lifetime and atomic
  failure before V4.3 closes.
- Resolution/evidence: the first production build compiled and linked all 36
  affected Runtime/Test actions with process/wrapper `0/0` at
  `Saved/Build/cache-v43-incremental-generation-impl-build-1/20260810_142328_542_70a41c82`.
  The focused class passed `4/4` at
  `Saved/Tests/cache-v43-incremental-generation-green-attempt-1/20260810_142451_128_d5b43af2`.
  The authoritative complete Cache prefix then passed `392/392`, failed/not-run
  `0/0`, at
  `Saved/Tests/cache-v43-incremental-generation-complete-cache/20260810_142605_935_752c2e62`.
- Task impact/evidence: V4.3 adds a pure immutable preparation API and a separate
  test TU. It does not change Pack/Manifest wire schemas, hash domains, the
  existing Store transaction, Engine activation or source language behavior.

## IC-304 — V4.4 TDD RED stopped at the missing dependency-propagation API

- Severity/state: V4.4 intended compile RED / closed 2026-08-10.
- Exact boundary: the official Development Editor build
  `Tools\RunBuild.ps1 -Label cache-v44-dependency-propagation-red -TimeoutMs
  600000 -NoXGE` failed at
  `Saved/Build/cache-v44-dependency-propagation-red/20260810_145034_117_fc804328`.
  UBT scheduled 14 actions; the new independent test TU failed only because
  `Cache/AngelscriptCacheDependencyPropagation.h` does not yet exist (`C1083`).
  Process/wrapper exit was `6/1`; the other scheduled unity actions emitted no
  compiler error.
- Decision: preserve this as the intended behavior-first frontier. Implement one
  pure Runtime planner over a complete locally validated candidate Generation.
  It must rebuild current typed semantic authorities, return only the next
  forced-clean module wave, use the injected resolver only for targets outside
  the candidate, and turn uncertainty into a typed module miss rather than a
  forged success. Do not add a parallel `.as` parser or recursively over-mark a
  speculative transitive closure.
- Required evidence: the production header/cpp and the complete independent test
  TU must first pass the official Editor build. Focused GREEN must prove ABI-only
  caller reuse, explicit content invalidation, removed/external target handling,
  deterministic record-order independence, atomic malformed-input failure and
  the A-to-B-to-C fixed-point wave before structural/global widening and the full
  Cache prefix run.
- Task impact/evidence: no Runtime implementation or persisted schema changed at
  this RED frontier. `v4.4-dependent-recompile-wave.md` fixes the production
  contract; `fresh-engine-reconstruction-boundary.md` separately prevents this
  planner from being cited as complete `FAngelscriptEngine` restoration.
- Resolution/evidence: the pure Runtime planner and independent test TU now
  build in the official Development Editor target. After the structural and
  semantic corrections recorded in IC-306 through IC-310, the final focused
  class is `11/11 PASS` at
  `Saved/Tests/cache-v44-layout-coordinate-green-propagation/20260810_154734_135_5b8dfcef`,
  and the complete Cache prefix is `403/403 PASS` at
  `Saved/Tests/cache-v44-layout-coordinate-complete-cache-regression/20260810_155314_432_207700c8`.

## IC-305 — The typed dependency schema had no ordinary function-content kind

- Severity/state: V4.4 semantic-schema gap / closed 2026-08-10.
- Exact boundary: while constructing the first behavior fixture after IC-304,
  an ABI-only `Declaration` edge correctly forbade
  `ExpectedContentOrValue`, but every existing content-bearing kind was a
  different authority: `GlobalStorage`, `HardValue`, `Initializer` or
  `CompileOption`. The design nevertheless requires a compiler transformation
  that embeds an ordinary callee body to invalidate on its execution hash.
- Root cause: the prose distinguished declaration ABI from embedded function
  content, but the persisted enum stopped at `EnvironmentAbi=11`; no wire value
  represented the latter without lying about its semantic source.
- Decision: append `FunctionContent=12`. It requires a ScriptFunction target,
  nonzero ExpectedAbi and nonzero `ExpectedContentOrValue`; it is excluded from
  ModuleInterface ABI just like other content-bearing edges. Do not reinterpret
  `HardValue`, `Initializer` or `CompileOption`. Existing numeric values and wire
  widths stay fixed; unpublished old cache compatibility is intentionally not
  required during plugin development.
- Required evidence: common codecs reject missing content and non-function
  targets, round-trip the new enum, the Python dump names it, and V4.4 proves a
  body-only change leaves Declaration callers reusable while selecting a
  FunctionContent caller.
- Task impact/evidence: update the common semantic dependency enum/validators,
  focused primitive/codec coverage, dump mapping and normative OpenSpec before
  closing IC-305. No `.as` syntax or business script changes are involved.
- Resolution/evidence: `FunctionContent=12` is append-only in the common enum,
  requires a ScriptFunction target plus declaration ABI and execution-content
  hash, and is named by the read-only Python dump. Primitive wire coverage is
  `13/13 PASS`, V4.4 propagation is `11/11 PASS`, Python is `16/16 PASS`, and the
  complete Cache prefix is `403/403 PASS` in the final artifacts cited by
  IC-309/IC-310.

## IC-306 — V4.4 first GREEN attempt misused semantic-diff change reporting

- Severity/state: V4.4 implementation preflight defect / closed 2026-08-10.
- Exact boundary: focused run
  `Tools\RunTests.ps1 -TestPrefix
  Angelscript.TestModule.Cache.DependencyPropagation -Label
  cache-v44-dependency-propagation-green-attempt-1 -TimeoutMs 600000` at
  `Saved/Tests/cache-v44-dependency-propagation-green-attempt-1/20260810_150107_301_9f683310`
  completed `1/7`: the forged-generation atomic failure passed, while every valid
  candidate returned `InvalidValidatedGeneration`. Logs showed self-diff
  `Error=0`, all records reused and no new/retired records, but the planner also
  required `HasSemanticChanges()==false`.
- Root cause: V4.4 only needs V4.2's `BuildGenerationView` validation side effect,
  which is represented by `SelfDiff.IsSuccess()`. `HasSemanticChanges` is a
  reporting convenience over the populated per-module diff view and is not an
  additional validated-generation invariant for this boundary.
- Decision: accept a self-diff whenever it succeeds; retain typed rejection only
  for its actual `SemanticDiffError`. Do not duplicate V4.2's private generation
  parser or infer validity from reused/new counts.
- Required evidence: rebuild, then all seven focused methods must execute the
  actual authority comparisons; forged input must remain the sole typed planner
  error case.
- Resolution/evidence: the single redundant predicate was removed. The corrected
  build passed at
  `Saved/Build/cache-v44-self-diff-preflight-fix-build/20260810_150215_735_934d1933`,
  and the complete seven-method focused class passed `7/7`, failed/not-run `0/0`,
  at
  `Saved/Tests/cache-v44-dependency-propagation-green-attempt-2/20260810_150230_175_9a5becbe`.
- Task impact/evidence: no persisted record, authority mapping or test fixture
  changed; this was a planner preflight interpretation error.

## IC-307 — The first structural RED used an illegal declaration-only function fixture

- Severity/state: V4.4 test-fixture crash / closed 2026-08-10.
- Exact boundary: the official Development Editor build passed process/wrapper
  `0/0` at
  `Saved/Build/cache-v44-structural-dependency-red/20260810_151124_902_fe78b963`,
  but the subsequent focused command
  `Tools\RunTests.ps1 -TestPrefix
  Angelscript.TestModule.Cache.DependencyPropagation -Label
  cache-v44-structural-dependency-red -TimeoutMs 600000` terminated with process
  exit `3`, wrapper `1`, at
  `Saved/Tests/cache-v44-structural-dependency-red/20260810_151150_019_aec207f9`.
  The crash occurred in `MakeDeclarationOnlyFunction`: changing an ordinary
  GlobalFunction from Required to Forbidden body coverage violates the frozen
  declaration-shape contract, so `ComputeDeclarationHashes` correctly rejected
  the fixture before the intended planner assertion.
- Root cause: the test attempted to manufacture `ContentUnavailable` with an
  entity shape the semantic schema deliberately forbids. A legal
  ModuleInitializer declaration already provides the required ScriptFunction
  identity without an ordinary FunctionBody record.
- Decision: remove the illegal helper and target a legal declaration-only
  ModuleInitializer with `FunctionContent`. Keep `check`-backed fixture builders;
  do not weaken production declaration validation to make a negative planner
  test possible.
- Required evidence: the corrected RED run must execute all methods without
  process crash and fail only because the extended Generation builder does not
  yet publish the new structural/state/import fixture fields. The later GREEN
  run must report `ContentUnavailable` for this exact legal target.
- Resolution/evidence: the fixture-only rebuild passed process/wrapper `0/0` at
  `Saved/Build/cache-v44-structural-dependency-red-fixture-fix/20260810_151325_694_0192b786`.
  The corrected RED at
  `Saved/Tests/cache-v44-structural-dependency-red-attempt-2/20260810_151348_441_81f26f86`
  executed all `11` methods without a crash: the original `7` passed and exactly
  the `4` newly introduced behaviors failed because the Generation fixture still
  omitted their fields. After the builder implementation, the legal
  ModuleInitializer target logged one `ContentUnavailable` reason before the
  later structural fixture failure.
- Task impact/evidence: test fixture only; no persisted schema or Runtime planner
  behavior changes. The corrected 11-method RED and subsequent final 11/11 GREEN
  cited above close the fixture issue without weakening declaration validation.

## IC-308 — PropertyLayout was placed in a TypeSchema without a deriving field

- Severity/state: V4.4 structural fixture model error / closed 2026-08-10.
- Exact boundary: after the extended Generation builder compiled at
  `Saved/Build/cache-v44-structural-dependency-fixture-impl/20260810_151616_299_648e9f4f`,
  focused run
  `Saved/Tests/cache-v44-structural-dependency-green-attempt-1/20260810_151643_763_6e54441e`
  reached and passed the new HardValue/Initializer, import and
  ContentUnavailable paths, then the TypeSchema helper `check` terminated the
  process. The diagnostic rebuild passed at
  `Saved/Build/cache-v44-type-schema-diagnostic-build/20260810_151753_675_5e7c2404`;
  the isolated test at
  `Saved/Tests/cache-v44-type-schema-diagnostic/20260810_151820_341_a1cce737`
  reported `UnexpectedRecord` (`Error=51`) for the Consumer TypeSchema.
- Root cause: TypeSchema dependencies are closed over fields in the schema.
  `ValueLayout` derives from a ScriptType/EnvironmentType property, while
  `PropertyLayout` represents compiled code that embeds a property coordinate
  and is not derivable from this schema's own property declaration. The fixture
  had appended both dependencies to an otherwise primitive property, violating
  the producer-completeness invariant.
- Decision: make the consumer's cached property an inline ScriptType whose exact
  stable reference derives the `ValueLayout` edge, and place the
  `PropertyLayout` edge in the consumer FunctionBody where an embedded property
  offset belongs. Keep TypeSchema closure strict; do not expand its admitted
  kinds merely for planner coverage.
- Required evidence: TypeSchema serialization and complete Generation
  validation must succeed; the planner must return exactly the Consumer with two
  layout invalidation reasons and leave the unrelated module reusable.
- Resolution/evidence: the fixture now derives ValueLayout from the consumer's
  ScriptType property and owns PropertyLayout in the consumer FunctionBody. The
  later IC-310 correction classified both layout-only changes as
  `ContentMismatch`, which is the final intended meaning. TypeSchema dependency
  closure passed `1/1`, the complete TypeSchema prefix passed `67/67`, and V4.4
  propagation passed `11/11`; the unrelated module remains reusable.
- Task impact/evidence: the original fault was fixture-only. The subsequent
  two-coordinate correction changed the development cache schema consistently;
  TypeSchema still admits no unrelated PropertyLayout row.

## IC-309 — Python dump swallowed a corrupt known-version dependency as successful inspection

- Severity/state: V4.4 diagnostic-observability regression / closed 2026-08-10.
- Exact boundary: `Tools\\RunCacheV2DumpTests.ps1` wrote
  `Saved/Tests/cache-v2-dump/20260810_152940_930` and completed `14/15`; wrapper
  exit was `1`. `test_unknown_dependency_kind_is_a_structured_decode_error`
  constructed a physically self-consistent FunctionBody v1 containing semantic
  DependencyKind `13`, but the CLI returned success instead of the expected
  structured `UNKNOWN_ENUM_VALUE` error.
- Root cause: `_read_dependency` correctly raises the typed error, but
  `summarize_record` catches every `CacheDumpError` and converts it to
  `decoder_scope: unavailable`. That policy does not distinguish an unsupported
  future record schema from corruption inside a decoder that explicitly matches
  the record's schema version.
- Decision: keep the Python tool a read-only testing/debugging/observation
  surface, not a Runtime validator or production recovery dependency. A record
  with an unsupported schema remains observable as opaque/unavailable metadata;
  once a matching schema decoder is selected, malformed fields are a structured
  nonzero error and must never be hidden behind an `ok: true` document. Python
  owns this behavior directly; do not add a redundant C++ test.
- Required evidence: preserve the illegal-kind RED, add a separate RED proving
  schema v2 is not mislabeled as the v1 FunctionBody decoder, implement the
  schema-selection/error split, and rerun the official wrapper with zero
  file-content/size/mtime changes for both cases. The widened RED is `14/16` at
  `Saved/Tests/cache-v44-python-schema-red` and fails exactly those two cases.
- Resolution/evidence: the first GREEN attempt at
  `Saved/Tests/cache-v44-python-schema-green` reached `15/16` and exposed a
  separate compatibility requirement: the C++ physical-minimum golden has no
  four-byte payload schema selector and must remain observable as an opaque
  record rather than be treated as known-version corruption. The final official
  wrapper artifact
  `Saved/Tests/cache-v44-python-schema-green-attempt-2` is `16/16 PASS` with
  wrapper/process exit `0`; unsupported/missing schema selection remains
  `decoder_scope=unavailable`, while malformed fields inside a selected known
  schema now return a structured nonzero error. The tests also prove that file
  content, size and mtime remain unchanged.
- Task impact/evidence: Python decoder/tests, dump README and V2.7 documentation
  only; no Cache wire bytes, Runtime validator, Engine state or `.as` source
  changes. Python dump remains a read-only testing, debugging, verification and
  cache-observation tool. It is not a production recovery path and needs no
  redundant C++ wrapper test.

## IC-310 — ExpectedAbi had incompatible declaration and layout meanings

- Severity/state: V4.4 semantic-coordinate architecture defect / closed
  2026-08-10.
- Exact boundary: selected-module validation in
  `AngelscriptCacheModuleGraph.cpp` compares every ScriptType dependency
  `Target.ExpectedAbi` with the target declaration `SignatureHash`, while the
  V4.4 generation planner in `AngelscriptCacheDependencyPropagation.cpp`
  reinterprets that same field as `TypeLayoutHash` for `ValueLayout` and as
  `PropertyLayoutFingerprint` for `PropertyLayout`. The existing 11/11 focused
  planner run did not expose the contradiction because its cross-module
  generation fixture does not exercise selected-module local graph closure for
  those two coordinates.
- Root cause: `FAngelscriptCachedDataType::TypeReference` is shared by public
  declaration identity and TypeSchema layout consumption, but `ExpectedAbi` was
  overloaded according to dependency kind. One stable reference therefore had
  no single meaning, and local graph validation and dependent-wave resolution
  could disagree about the same serialized bytes.
- Decision: use a two-coordinate dependency model. `Target.ExpectedAbi` always
  names the target declaration/call ABI (`SignatureHash`). For mutable semantic
  projections, `ExpectedContentOrValue` stores exactly what the consumer
  compiled against: `TypeLayoutHash` for `ValueLayout` and
  `PropertyLayoutFingerprint` for `PropertyLayout`. Declaration changes produce
  `AbiMismatch`; layout-only changes produce `ContentMismatch`. This follows the
  already established `GlobalStorage` pattern and intentionally changes the
  development-only cache schema without old-cache compatibility.
- Required evidence: first freeze RED coverage for the dependency presence
  matrix and V4.4 type/property propagation; then update all three semantic
  validators, TypeSchema derived-dependency matching, selected-module graph
  closure and the planner. Add/repair local graph coverage proving declaration
  ABI plus layout-content matching, and rerun the affected build, primitive,
  TypeSchema, ModuleGraph, DependencyPropagation and broader Cache prefixes.
- Task impact/evidence: Runtime cache format semantics, cache-only C++ fixtures,
  Python symbolic observation documentation and OpenSpec. No `.as` source,
  Engine heap snapshot, editor business code or StaticJIT route is changed.
- Resolution/evidence: RED was frozen by the successful Editor build
  `Saved/Build/cache-v44-layout-coordinate-red-build/20260810_154026_494_a6fad054`,
  followed by the expected primitive `12/13` failure at
  `Saved/Tests/cache-v44-layout-coordinate-red-primitives/20260810_154048_991_8f706d34`
  and the FunctionBody presence assertion at
  `Saved/Tests/cache-v44-layout-coordinate-red-propagation/20260810_154124_661_4eb31b00`.
  All three validators now require content for ValueLayout/PropertyLayout;
  TypeSchema matches the derived target while preserving that content; local
  ModuleGraph resolves selected type/property content from linked TypeSchemas;
  and the planner returns declaration ABI plus layout content independently.
  Final evidence is: build
  `Saved/Build/cache-v44-property-layout-graph-build/20260810_155220_224_3a957dec`,
  primitives `13/13`, TypeSchema `67/67`, selected-module layout graph `8/8`
  including exact/wrong PropertyLayout, dependency propagation `11/11`, Python
  dump `16/16`, and complete Cache `403/403`, all with zero failures/skips and
  zero final exit codes.

## IC-311 — Python wrapper rerun used an unsupported Label parameter

- Severity/state: verification invocation mistake / closed 2026-08-10.
- Exact boundary: after the complete Cache regression, the command
  `Tools\RunCacheV2DumpTests.ps1 -Label cache-v44-layout-coordinate-python-final`
  exited `1` before starting Python because this standalone wrapper exposes
  `OutputRoot` and `Verbosity`, not the UE runner's `Label` parameter.
- Root cause: the UE build/test wrapper convention was incorrectly applied to
  the independent Python wrapper even though its parameter block is explicit.
- Decision: do not change the wrapper API merely to hide an invocation mistake.
  Use an explicit `-OutputRoot` so the artifact remains deterministic and easy
  to inspect.
- Resolution/evidence: `Tools\RunCacheV2DumpTests.ps1 -OutputRoot
  Saved\Tests\cache-v44-layout-coordinate-python-final` ran all `16` tests in
  `0.252s`, passed `16/16`, and exited `0`. No Runtime, wire-format or Python
  implementation change was required.
- Task impact/evidence: verification record only.

## IC-312 — V4.5 producer admission and debug ownership were narrower than the mutation claims

- Severity/state: V4.5 production-completeness architecture gap / open
  2026-08-10.
- Exact boundary: `CaptureAngelscriptCleanCompiledModuleImpl` rejects any
  compiled shape other than one disk source, one enum and one dependency-free
  global `int` function. It constructs exactly one TypeSchema, an empty
  ModuleState and one FunctionBody/DebugSidecar pair. Therefore serialized
  fixture mutations cannot prove production class/property/global/initializer
  capture. Separately, FunctionBody stores both the exact DebugSidecar RecordId
  and the debug hash, so a debug-only source edit cannot physically reuse the
  FunctionBody RecordId even when execution bytes are unchanged.
- Root cause: V3.4-V4.4 deliberately landed a narrow executable restore/capture
  vertical, while the V4 exit matrix described the eventual producer surface.
  The record graph also chose FunctionBody as the v1 debug-sidecar owner, which
  couples physical record identity without coupling execution semantics.
- Decision: freeze the executable matrix in
  `v4.5-clean-oracle-mutation-matrix.md`, then widen the real clean-capture
  producer in fail-closed increments. Representative supported shapes must come
  from independent normal compiles; unsupported shapes remain typed
  `NotCacheable`. For v1, debug-only evidence expects SourceIndex,
  DebugSidecar, FunctionBody and ModuleSnapshot RecordIds to change while
  StableFunctionKey, declaration ABI, FunctionSource/Input digests and execution
  hash remain stable. StaticJIT execution mapping must not consume debug bytes.
- Required evidence: dedicated V4.5 RED/GREEN tests for unchanged, body,
  signature, class/property/layout, global/initializer, include/options and
  debug-only families; initializer opaque validation support where the actual
  VM initializer artifact requires it; complete mixed-generation equivalence;
  focused/full Cache regression and strict OpenSpec validation.
- Task impact/evidence: production clean capture, maintained-fork observation
  hooks or opaque codec where necessary, dedicated Cache tests and OpenSpec. It
  does not widen fresh-Engine restore claims, alter business `.as` sources or
  make Python part of Runtime recovery. Close this issue only with the final
  V4.5 evidence packet.

## IC-313 — The first V4.5 global fixture used a language form the plugin forbids

- Severity/state: V4.5 RED fixture error / closed 2026-08-10.
- Exact boundary: the dedicated CleanOracleMutation test built successfully at
  `Saved/Build/cache-v45-producer-admission-red-build/20260810_160900_215_a49b45be`,
  but the first focused run at
  `Saved/Tests/cache-v45-producer-admission-red/20260810_161023_829_77eea9ab`
  failed during the normal compile with `Global variable 'GCacheAnswer' must be
  const. Mutable global variables are not supported.` Capture was never called.
- Root cause: the new representative source used stock AngelScript mutable
  global syntax without respecting the plugin's deliberate global-state rule.
- Decision: use `const int GCacheAnswer = 41`. This is a legal real producer
  form and exercises global declaration/storage plus PureConstant/HardValue
  initialization. Do not weaken the language rule for a cache test. A later
  legal VM/module initializer fixture may extend the initializer execution
  branch independently.
- Required evidence: rebuild the corrected test and rerun it to a unique RED at
  production capture (`NotCacheable`), with no preprocess/compiler diagnostic.
- Resolution/evidence: the corrected fixture rebuilt successfully at
  `Saved/Build/cache-v45-producer-admission-red-fixture-fix/20260810_161125_360_15e85fce`.
  The focused follow-up at
  `Saved/Tests/cache-v45-producer-admission-red-attempt-2/20260810_161154_592_f2b26724`
  compiled and activated the script normally, then failed uniquely at the
  expected producer boundary with `Error=2 NotCacheable`, zero records and the
  existing one-enum admission diagnostic. This is the valid V4.5 RED.
- Task impact/evidence: test fixture and OpenSpec evidence only; no Runtime,
  wire-format or language behavior change.

## IC-314 — A reflected script class contributes derived VM helper entities

- Severity/state: V4.5 production-completeness modelling gap / open
  2026-08-10.
- Exact boundary: the focused real-compile diagnostic at
  `Saved/Tests/cache-v45-producer-entity-diagnostic/20260810_161709_865_509a2410`
  compiled and activated the representative class/property/const-global source,
  then reached the expected production `NotCacheable` RED. The normal compiled
  module contains one user class, but its VM-facing global lists contain four
  entities: user `const int GCacheAnswer`, generated
  `const TSubclassOf<UObject> __StaticType_FCachePayload`, user
  `int GetCacheAnswer()` and generated `UClass StaticClass()`. The build that
  exposed these names is
  `Saved/Build/cache-v45-producer-entity-diagnostic-build/20260810_161644_467_b3ff5058`.
- Root cause: ClassGenerator/preprocessor support materializes a reflected
  script class through derived helper globals/functions. Counting raw VM global
  lists as if every entry were an independent user declaration would either
  reject ordinary classes forever or duplicate generated state in
  ModuleInterface/ModuleState/FunctionBody.
- Decision: classify entities through authoritative descriptors. Persist the
  user class, its properties and reflection recipe in TypeSchema; persist user
  globals/functions in ModuleState/FunctionBody; recognize the exact
  `StaticClassGlobalVariableName` plus matching generated `StaticClass()` helper
  as TypeSchema/ClassGenerator-derived implementation artifacts. They are not
  separate public cache units. Any extra VM global/function that cannot be
  matched to a user descriptor or an explicitly supported generated recipe
  remains a typed `NotCacheable` miss; never silently omit an unknown entity.
- Required evidence: capture diagnostics must prove exact one-to-one
  classification, TypeSchema must retain the generated static-class global
  recipe, the representative source must emit a graph-valid record set, and a
  negative unclassified-helper fixture or producer seam must prove fail-closed
  behavior. The follow-up diagnostic build
  `Saved/Build/cache-v45-class-layout-diagnostic-build/20260810_161959_733_ca42e5f2`
  and run
  `Saved/Tests/cache-v45-class-layout-diagnostic/20260810_162018_478_eb3b9b67`
  recorded the real code super and VM layout before the producer implementation
  is written.
- Task impact/evidence: production clean capture, its dedicated V4.5 tests and
  OpenSpec. No business `.as` source, fresh-Engine restore claim or Python
  runtime dependency is introduced.

## IC-315 — Reflection descriptors do not enumerate ordinary VM properties

- Severity/state: V4.5 type-schema authority gap / open 2026-08-10.
- Exact boundary: the same real-compile run at
  `Saved/Tests/cache-v45-class-layout-diagnostic/20260810_162018_478_eb3b9b67`
  reported `DescProperties=0` but `VmProperties=1` for the source member
  `int Count`. It also measured the actual root-UClass layout as `VmSize=56`,
  `VmAlign=8`, `BaseBoundary=48`, with code super
  `/Script/CoreUObject.Object`.
- Root cause: `FAngelscriptClassDesc::Properties` describes properties promoted
  into Unreal reflection; it is not the complete AngelScript object-property
  table. An ordinary script member still participates in VM byte offsets,
  FunctionBody relocation, class size/alignment and TypeSchema invalidation even
  when it has no `FProperty` descriptor.
- Decision: use the compiled `asCObjectType` local property sequence as the
  complete structural/layout authority. Match an optional
  `FAngelscriptPropertyDesc` by script index/name only to add UE reflection
  flags and metadata. Descriptor-only or VM-only mismatches that cannot be
  explained by the supported mapping are typed `NotCacheable`; never build the
  property list only from reflection descriptors.
- Required evidence: the first GREEN must serialize `Count` as a Property
  declaration plus ordered TypeSchema property at byte offset 48 with primitive
  size/alignment 4 and enclosing size/alignment 56/8. A later reflected-property
  mutation row must prove that descriptor flags augment, rather than replace,
  VM layout authority.
- Task impact/evidence: production TypeSchema capture and dedicated V4.5 tests;
  no AngelScript language rule or ClassGenerator behavior changes.

## IC-316 — Pure constants retain an initializer function that runtime skips

- Severity/state: V4.5 producer-classification mistake / closed 2026-08-10.
- Exact boundary: after the producer compiled at
  `Saved/Build/cache-v45-root-class-producer-compile/20260810_163036_049_a24c1f3e`,
  the first GREEN attempt
  `Saved/Tests/cache-v45-root-class-producer-green-attempt-1/20260810_163056_759_72912743`
  stopped at global classification. The diagnostic rebuild
  `Saved/Build/cache-v45-global-shape-diagnostic-build/20260810_163149_187_f550a37a`
  and run
  `Saved/Tests/cache-v45-global-shape-diagnostic/20260810_163212_241_2b7d3294`
  proved `GCacheAnswer` has `isPureConstant=1`, `isDefaultInit=0` and a non-null
  init function.
- Root cause: the compiler leaves the compiled initialization function attached
  after folding a readonly primitive into `storage`. `asCModule::CallInit`
  explicitly skips `isPureConstant` globals before consulting `GetInitFunc()`,
  so non-null init-function presence does not make this a VM initializer.
- Decision: classification follows runtime execution semantics:
  `isPureConstant` owns the authoritative fixed-width value and maps to one
  `PureConstant` Global plus one `GlobalConstant` HardValue. Its retained,
  unreachable init function is compiler implementation debris and is not an
  Initializer unit. Preserve fail-closed behavior for a non-pure global with an
  init function.
- Required evidence: the representative source must advance past producer
  classification, serialize one exact HardValue and reach graph validation;
  later initializer tests must distinguish a legal executable initializer from
  this skipped function.
- Resolution/evidence: source inspection at `as_module.cpp::CallInit` lines
  371-389 provides the runtime oracle; the producer no longer rejects a pure
  constant merely because `GetInitFunc()` is non-null. Final focused GREEN is
  pending the remaining graph-coverage work tracked by IC-312.
- Task impact/evidence: production global classification and OpenSpec only; no
  compiler/runtime behavior or wire schema changes.

## IC-317 — The widened producer allocated declaration ordinals per entity

- Severity/state: V4.5 producer ABI conformance defect / closed 2026-08-10.
- Exact boundary: the corrected pure-constant producer build passed at
  `Saved/Build/cache-v45-pure-constant-classification-build/20260810_163403_322_48dbac40`,
  but the focused real-compile run at
  `Saved/Tests/cache-v45-pure-constant-graph-red/20260810_163433_787_de9eaae6`
  stopped before record serialization with `Module interface ABI failed:
  Error=33 Class=4 Kind=2`, which resolves to `DuplicateOrdinal`. Inspection of
  `ValidateGlobalSlotOrdinals` proved that slot kinds `Declaration`, `Function`
  and `Import` each form a module-wide dense sequence. The new class vertical
  emitted class declaration ordinal 0, property ordinal 1 and global
  declaration ordinal 0.
- Root cause: the widened producer treated the global's declaration slot as a
  declaration-local coordinate, even though the semantic ABI deliberately uses
  a module-global coordinate per slot kind. The earlier one-enum vertical had
  only one declaration and did not expose this mistake.
- Decision: retain the existing wire/ABI contract. Allocate the root class at
  declaration ordinal 0, local properties at ordinals 1..N, and the user global
  at ordinal N+1. Function slots remain their own dense sequence beginning at
  zero. Future multi-entity capture must use an explicit per-slot-kind allocator
  rather than restarting ordinals for each entity.
- Required evidence: rebuild the focused test and prove that production capture
  advances past `ComputeModuleInterfaceAbi`; any later failure must identify a
  different, deeper semantic boundary. The final V4.5 mutation matrix must keep
  module interface decoding/canonical validation enabled so ordinal regressions
  cannot be hidden by fixture-only construction.
- Resolution/evidence: the producer now assigns the global declaration ordinal
  immediately after the class and all local properties. The official rebuild
  passed at
  `Saved/Build/cache-v45-declaration-ordinal-fix-build/20260810_163837_402_c037ed0b`;
  the focused run at
  `Saved/Tests/cache-v45-declaration-ordinal-fix-test/20260810_163902_283_b6d1ac93`
  advanced beyond `ComputeModuleInterfaceAbi`, serialized all seven records and
  stopped only at the distinct deeper ModuleGraph pure-constant rule recorded
  as IC-318.
- Task impact/evidence: production clean capture and OpenSpec only; no wire
  version, identity formula, AS language behavior or business script changes.

## IC-318 — ModuleGraph still rejected locally valid pure-constant state

- Severity/state: V4.5 cross-record coverage gap / partially closed
  2026-08-10; positive production path GREEN, negative mutation packet pending.
- Exact boundary: after IC-317, the official build succeeded at
  `Saved/Build/cache-v45-declaration-ordinal-fix-build/20260810_163837_402_c037ed0b`.
  The focused real-compile run at
  `Saved/Tests/cache-v45-declaration-ordinal-fix-test/20260810_163902_283_b6d1ac93`
  advanced past ModuleInterface ABI and record serialization, then failed at
  graph-validation step 5 with `Error=50 MissingCoverage`, ModuleState offset
  175. The exact rule admitted only `Default + None` globals, and step 8 also
  required `HardValues.IsEmpty()` despite the ModuleState local validator
  already defining `PureConstant` as one const global plus exactly one
  `GlobalConstant` HardValue.
- Root cause: the graph validator retained the first narrow default-global
  vertical after the ModuleState semantic model and production producer had
  grown to represent pure constants. Local validity alone cannot prove that the
  hard value belongs to the declaration selected by ModuleInterface.
- Decision: admit `PureConstant` only with `CleanupPolicy::None`, the const
  declaration trait and an exact one-to-one hard-value match. Cross-check the
  HardValue kind, ScriptGlobal owner kind, stable GlobalKey, declaration
  SignatureHash in `Owner.ExpectedAbi`, and exact cached data type. Consume the
  canonical hard-value sequence by stable owner key and reject any missing,
  duplicated, unowned, mismatched or additional value. Continue rejecting
  EnumAuthority and other unimplemented hard-value families fail-closed.
- Required evidence: the real producer fixture must pass graph validation and
  expose one decoded PureConstant plus one HardValue. Dedicated negative graph
  tests must mutate owner key, expected declaration ABI, type and surplus value
  and observe a typed graph failure at the owning ModuleState coordinate. Full
  Cache regression must remain green.
- Resolution/evidence: the graph now admits only exact `PureConstant` coverage
  and consumes its canonical HardValue sequence one-to-one. The Runtime rebuild
  passed at
  `Saved/Build/cache-v45-pure-constant-graph-build/20260810_164221_108_9eaf5914`.
  The first real producer GREEN is
  `Saved/Tests/cache-v45-pure-constant-graph-green/20260810_164239_646_988d862b`
  (`1/1 PASS`, seven locally and graph-validated records). The strengthened
  follow-up at
  `Saved/Tests/cache-v45-production-shape-assertions-test/20260810_164629_527_c035994b`
  decodes the output and proves exact class layout `56/8/48`, property `Count`
  at offset 48 with `4/4` storage, one `PureConstant`, value bytes for 41,
  declaration ABI ownership, one user FunctionBody, and generated helper
  exclusion. Negative graph mutations and full Cache regression remain pending.
- Task impact/evidence: ModuleGraph cross-record validation, dedicated Cache
  tests and OpenSpec. It does not widen VM initializer execution, fresh-Engine
  restoration or Runtime dependence on Python.

## IC-319 — Production-shape test used two nonexistent API names

- Severity/state: V4.5 test implementation compile failure / closed
  2026-08-10.
- Exact boundary: after the first production graph GREEN, the assertion-strengthening
  build at
  `Saved/Build/cache-v45-production-shape-assertions-build/20260810_164519_523_10f32a15`
  failed in `AngelscriptCacheCleanOracleMutationTests.cpp`. `TArray` in the
  configured UE version has no `CountByPredicate` member, and the cache schema
  enum names the object case `EAngelscriptCachedTypeKind::Class`, not `Object`.
  Runtime compilation was not implicated.
- Root cause: the new test helper assumed a container convenience member and a
  colloquial enum name without checking the project API. Neither assumption was
  part of the cache design.
- Decision: use an explicit allocation-free record-count loop and assert the
  authoritative `Class` enum value. Retain all production-shape assertions;
  do not reduce the tested record or layout surface.
- Required evidence: the corrected Editor target must build and the strengthened
  clean-oracle test must remain GREEN while decoding and checking all seven
  records.
- Resolution/evidence: source corrections are applied; build/test evidence is
  complete. The corrected official build passed at
  `Saved/Build/cache-v45-production-shape-assertions-build-fix/20260810_164600_139_a539d606`,
  and the strengthened test passed at
  `Saved/Tests/cache-v45-production-shape-assertions-test/20260810_164629_527_c035994b`.
- Task impact/evidence: dedicated test and OpenSpec only; no Runtime behavior,
  format, identity or AS source rule changed.

## IC-320 — Input-matrix test compared a strong hook key wrapper directly

- Severity/state: V4.5 test implementation compile failure / closed
  2026-08-10.
- Exact boundary: the first official build of the dedicated input/compile-option
  mutation translation unit failed at
  `Saved/Build/cache-v45-input-option-matrix-build-rerun/20260810_170303_969_7e91641b`.
  `AngelscriptCacheCleanOracleInputMutationTests.cpp` compared two
  `FAngelscriptCachedPreprocessHookKey` values with `operator==`, but this
  semantic key is an intentionally thin strong wrapper and exposes equality
  through its contained `Hash` coordinate.
- Root cause: the test used the equality surface provided by higher-level stable
  key types without checking this SourceIndex key wrapper's actual API. The
  production SourceIndex codec, hook identity formula and Runtime build were not
  implicated.
- Decision: compare `HookKey.Hash` exactly and retain the stable-key assertion;
  do not weaken it to a string or omit the owner-input identity check.
- Required evidence: the corrected Editor target must build and both real
  input-mutation tests must progress to normal preprocess/compile/capture.
- Resolution/evidence: the exact contained hash is now compared. The corrected
  Editor target passed at
  `Saved/Build/cache-v45-input-option-matrix-build-fix/20260810_170337_858_7aa7d8b8`.
  Both tests then completed normal production discovery, preprocessing,
  isolated-Engine compilation, seven-record capture and graph validation at
  `Saved/Tests/cache-v45-input-option-matrix-red/20260810_170409_394_57ddf741`
  (`2/2 PASS`).
- Task impact/evidence: dedicated Cache test and OpenSpec only; no production
  format, cache identity, AS behavior or business script change.

## IC-321 — HardValue graph-negative test asserted the child record as the diagnostic owner

- Severity/state: V4.5 negative-test contract mismatch / closed 2026-08-10.
- Exact boundary: the official Editor target build passed at
  `Saved/Build/cache-v45-hardvalue-negative-build/20260810_170905_065_ad03b969`,
  but the focused run at
  `Saved/Tests/cache-v45-hardvalue-negative-red/20260810_170926_983_904d410c`
  finished `1/2 PASS`. The production baseline captured seven records and
  validated all seven. The `ExpectedDeclarationAbi` mutation then correctly
  failed closed with `GraphAbiMismatch` (`Error=60`) at exact offset `247`, but
  the test expected `Kind=4 Stage=4`; the authoritative result was
  `Kind=7 Stage=5`.
- Root cause: the test treated the mutated ModuleState child as the public
  diagnostic owner and confused `OpaqueCodec` with cross-record graph
  validation. `ValidateModuleSnapshotGraph` deliberately reports graph-wide
  failures against the ModuleSnapshot root (`Kind=ModuleSnapshot`) at
  `Stage=ModuleGraph`, while retaining the exact offending child-field offset.
  Production validation, failure atomicity and the ABI mismatch result were not
  implicated.
- Decision: assert the named `ModuleSnapshot` and `ModuleGraph` enum values in
  the diagnostic string rather than magic numbers. Keep the exact error and
  child-field offset assertions, zero validated-record count, empty promoted
  records and zero output identities.
- Required evidence: rebuild with the official wrapper, rerun both focused
  HardValue tests, and prove all three locally valid cross-record mutations
  reject at their exact recorded offsets without promoting any record.
- Resolution/evidence: the assertion correction is applied. The official UE
  5.8 Editor target passed at
  `Saved/Build/cache-v45-hardvalue-negative-diagnostic-fix-build/20260810_171315_305_bd2f4c3e`.
  The focused rerun at
  `Saved/Tests/cache-v45-hardvalue-negative-diagnostic-fix-test/20260810_171328_886_5c1e77af`
  passed `2/2`. The three locally valid cross-record mutations rejected at
  exact offsets `247`, `279` and `336` with zero validated/promoted records;
  the local owner-key mismatch also remained fail-closed before graph admission.
- Task impact/evidence: dedicated Cache test and OpenSpec only; no Runtime
  validation behavior, wire format, identity formula or AS language rule changed.

## IC-322 — Maintained builder had no shared invocation descriptor seam

- Severity/state: V5.1 required maintained-fork capability / closed 2026-08-10.
- Exact boundary: the first official UE 5.8 Editor build for the dedicated
  builder-invocation test failed at
  `Saved/Build/cache-v51-builder-invocation-red-build/20260810_173409_112_759b2d9a`.
  `AngelscriptCacheBuilderInvocationTests.cpp` cannot include
  `as_buildartifact.h` because the maintained fork currently exposes only raw
  `sFunctionDescription`/`sFactoryDescription` internals and direct compiler
  calls. There is no kind-tagged, host-observable contract shared by module,
  factory and public-single paths.
- Root cause: V0-V4 capture retained a canonical token slice after compilation,
  but no pre-compiler invocation boundary yet exists. Runtime-side inference
  cannot distinguish generated default constructor/destructor, factory,
  `__InitDefaults`, public single-function and lambda eligibility without
  duplicating builder knowledge.
- Decision: add one Unreal-free `as_buildartifact.h` contract, emit it
  synchronously from every actual builder compiler invocation, and route the
  observer through module/builder transaction state rather than process-global
  state. Stable module/namespace/owner/declaration/source coordinates are
  explicit; public snippets and unstable lambdas carry typed NotCacheable
  reasons. This V5.1 observer is the descriptor seam that the V5.3 lookup/result
  hook will extend; it does not yet skip `asCCompiler`.
- Required evidence: official Editor build, actual module-family descriptor
  coverage, actual public-single NotCacheable coverage, typed unstable-lambda
  classification and unaffected Cache/AngelScriptSDK builder regressions.
- Resolution/evidence: the Unreal-free contract and all maintained builder/module
  emission points are implemented. The official UE 5.8 Editor build passed at
  `Saved/Build/cache-v51-builder-invocation-green-build-fix1/20260810_174256_866_d7ce3ef4`.
  After fixture corrections recorded separately below, the focused prefix passed
  `3/3` at
  `Saved/Tests/cache-v51-initdefaults-fixture-test/20260810_174916_049_7430e779`.
  The real module build logged 13 invocations spanning global, method, explicit
  constructor/destructor, factory, generated default constructor/destructor and
  `__InitDefaults`; every stable family had `Ineligible=0` and complete module,
  owner, declaration, canonical-source and section coordinates. Public-single
  logged kind `9`/reason `7`, while lambda and invalid kinds retained their typed
  NotCacheable reasons. V5.1 observer capability is closed; it still intentionally
  does not restore or skip compiler work before V5.3. The complete Cache prefix
  then passed `418/418` at
  `Saved/Tests/cache-v51-complete-regression/20260810_175055_781_66b4224b`,
  and the affected AngelScriptSDK Compiler.Builder prefix passed `64/64` at
  `Saved/Tests/cache-v51-angelscript-sdk-builder-regression/20260810_175544_720_b6b6d4e6`.
- Task impact/evidence: maintained AngelScript builder/module internals,
  dedicated Cache test and OpenSpec; no project script, AS syntax or Runtime
  recovery behavior changes in V5.1.

## IC-323 — First V5.1 GREEN build exposed warning-as-error and UE container API mismatches

- Severity/state: V5.1 integration compile blocker / closed 2026-08-10.
- Exact boundary: the official UE 5.8 Editor build
  `Tools\RunBuild.ps1 -Label 'cache-v51-builder-invocation-green-build'`
  failed at
  `Saved/Build/cache-v51-builder-invocation-green-build/20260810_173803_800_14c1fd85`
  after reaching action `79/90`. The maintained-fork module setter parameter
  `userData` triggered C4458 because it hid `asCModule::userData`, and the
  dedicated test used a nonexistent UE 5.8 `TArray::CountByPredicate` member.
- Root cause: the new callback API selected a conventional parameter name that
  conflicts with this fork's existing typed module user-data array under the
  target's warnings-as-errors policy. Separately, the test assumed a container
  convenience method not present on the project's actual UE 5.8 `TArray` API.
  Neither error reached or exercised descriptor classification behavior.
- Decision: rename only the module setter parameter to `callbackUserData`,
  preserving ABI and stored state, and implement the small test count with an
  explicit range loop. Do not weaken the target warning policy or add a generic
  container helper for one assertion.
- Required evidence: the same official Editor target must build, then the
  focused `Angelscript.TestModule.Cache.BuilderInvocation` prefix must execute
  all actual module/public-single and typed synthetic-lambda assertions.
- Resolution/evidence: the parameter rename and explicit count loop passed the
  full 90-action official Editor build at
  `Saved/Build/cache-v51-builder-invocation-green-build-fix1/20260810_174256_866_d7ce3ef4`.
  The focused prefix then executed normally; subsequent fixture-only findings
  are IC-324 and IC-325. This integration compile blocker is closed.
- Task impact/evidence: one internal maintained-fork parameter name, one
  dedicated test helper and OpenSpec only; no cache format, descriptor value,
  invocation routing or AS behavior change.

## IC-324 — Module-family descriptor fixture used an unsupported class-member handle

- Severity/state: V5.1 focused-test fixture blocker / closed 2026-08-10.
- Exact boundary: after the official UE 5.8 Editor target passed `90/90` at
  `Saved/Build/cache-v51-builder-invocation-green-build-fix1/20260810_174256_866_d7ce3ef4`,
  `Tools\RunTests.ps1 -TestPrefix
  'Angelscript.TestModule.Cache.BuilderInvocation' -Label
  'cache-v51-builder-invocation-green-test'` finished `2/3 PASS` at
  `Saved/Tests/cache-v51-builder-invocation-green-test/20260810_174545_721_19397af3`.
  Public-single descriptor emission and typed lambda/invalid NotCacheable
  classification passed. The module-family fixture failed during parse at
  `BuilderInvocation.as:8:2` on `FInvocationLeaf@ Child;`, before any module
  build invocation could be observed.
- Root cause: this maintained fork accepts local handles to script classes but
  does not accept that handle form as a script-class property in the selected
  isolated-engine dialect. The fixture used it only to force a generated
  destructor and accidentally tested unsupported member syntax instead of the
  builder seam.
- Decision: use a by-value `FInvocationLeaf Child;` property. A by-value script
  object with a destructor still exercises recursive default-destructor
  generation while remaining valid class-property syntax. Preserve the
  explicit constructor/destructor class and every required invocation-kind
  assertion.
- Required evidence: rebuild the official Editor target and rerun the same
  three-test prefix; the real module build must succeed and log every required
  ordinary/generated/factory family with stable coordinates.
- Resolution/evidence: the by-value fixture passed parsing and completed the
  real module build at
  `Saved/Tests/cache-v51-builder-invocation-fixture-fix-test/20260810_174736_156_9d6df57e`.
  It emitted 12 descriptors including the by-value owner's generated default
  destructor with stable coordinates. The prefix remained `2/3 PASS` only
  because a separate missing `__InitDefaults` fixture trigger was then exposed;
  the class-member syntax issue itself is closed.
- Task impact/evidence: dedicated inline test fixture and OpenSpec only; no
  business `.as`, parser rule, Runtime builder behavior or cache identity change.

## IC-325 — Ordinary property initializer does not exercise `__InitDefaults`

- Severity/state: V5.1 invocation-family coverage gap / closed 2026-08-10.
- Exact boundary: the fixture-corrected official build passed `4/4` at
  `Saved/Build/cache-v51-builder-invocation-fixture-fix-build/20260810_174715_929_94b9d0d9`.
  The focused run at
  `Saved/Tests/cache-v51-builder-invocation-fixture-fix-test/20260810_174736_156_9d6df57e`
  completed a successful real module build and logged kinds `1` through `7`
  across 12 invocations, but no kind `8`; the assertion at line 198 therefore
  found no `InitDefaults` descriptor. Both other tests again passed.
- Root cause: `int Value = 3;` is an ordinary property initializer. This fork
  creates `__InitDefaults` only when the parser records an explicit
  `snClassDefaultStatement`, whose supported syntax is `default <statement>;`.
  The test conflated two distinct initialization mechanisms.
- Decision: retain the property initializer and add `default Value = 5;` to the
  same inline class. This follows the maintained parser's actual syntax and
  forces the production `AddInitDefaultsFunction` path; do not relabel ordinary
  initialization as kind `8` or weaken the required family matrix.
- Required evidence: official incremental Editor build and the same three-test
  prefix must pass, with a logged kind-8 descriptor containing module, owner,
  declaration, canonical source and section coordinates.
- Resolution/evidence: the explicit default statement passed the official
  incremental Editor build at
  `Saved/Build/cache-v51-initdefaults-fixture-build/20260810_174856_159_e87f9ad8`.
  The focused prefix passed `3/3` at
  `Saved/Tests/cache-v51-initdefaults-fixture-test/20260810_174916_049_7430e779`;
  invocation index 7 logged kind `8`, `Ineligible=0`, owner
  `FGeneratedInvocation`, declaration
  `void FGeneratedInvocation::__InitDefaults()`, canonical class source and
  `BuilderInvocation.as`. This fixture coverage gap is closed.
- Task impact/evidence: dedicated inline test fixture and OpenSpec only; no
  business `.as`, default-statement semantics, builder behavior or cache format
  change.

## IC-326 — Successful function compilation had no actual-dependency result contract

- Severity/state: V5.2 required maintained-fork/Runtime capability / closed
  2026-08-10.
- Exact boundary: the dedicated V5.2 RED tests were added in separate
  `CompilerDependencyCapture` and `FunctionInput` translation units, then the
  official UE 5.8 Editor build
  `Tools\RunBuild.ps1 -Label cache-v52-dependency-contract-red-build` failed at
  `Saved/Build/cache-v52-dependency-contract-red-build/20260810_181223_132_2f0f128c`.
  The maintained fork has no typed `asSBuildArtifactDependency`, no successful
  compile-result callback, no per-function retained dependency collection and no
  module setter for such a callback. Runtime also has no
  `AngelscriptCacheCompilerBridge` capable of canonicalizing observed
  dependencies, short-circuiting a changed `FunctionSourceDigest`, resolving
  current declaration/layout/hard-value/environment authorities and producing
  the current `FunctionInputDigest`.
- Root cause: V5.1 deliberately stopped at a pre-compiler invocation
  descriptor. Existing `asCBuilder::MarkDependency` calls update only coarse
  cross-module HotReload information and discard local-symbol granularity; they
  neither delimit one compiler invocation nor publish only on successful
  compilation. Existing FunctionBody capture consequently stores an empty
  `ActualDependencies` array and hashes only its FunctionSourceDigest.
- Decision: extend the Unreal-free maintained-fork artifact seam with typed raw
  Type/Function/Global/Property dependencies and a post-compile result emitted
  by the same builder transaction. Retain successful dependencies on the
  compiled `asCScriptFunction`, clear them on failure, and capture local symbols
  before the existing module-level early-outs. Add a Runtime compiler bridge
  that converts successful raw observations through an explicit stable-symbol
  resolver, canonicalizes/deduplicates them, resolves persisted dependencies
  against the current ModuleInterface/TypeSchema/ModuleState/function/environment
  authorities, and computes the input digest. A source mismatch must return
  before consulting any dependency resolver. Do not infer dependencies by
  rescanning source or perform a second semantic compile pass.
- Required evidence: official Editor build; real isolated-engine successful and
  failed compile-result tests covering type layout, function signature, pure
  global hard value and property layout; Runtime order/dedup/source-short-circuit/
  current-ABI-value tests; a real clean-capture mutation proving unchanged
  function source plus changed referenced hard value changes FunctionInputDigest;
  and unaffected Cache/AngelScriptSDK builder regressions.
- Resolution/evidence: the maintained fork now retains a typed dependency list
  per successful/cacheable function invocation and clears it on compiler failure;
  the Runtime bridge canonicalizes stable semantic dependencies and resolves the
  current source/input digest. The official build passed at
  `Saved/Build/cache-v52-dependency-contract-green-build3/20260810_182143_350_8c134de8`.
  Compiler capture passed `2/2` at
  `Saved/Tests/cache-v52-compiler-dependency-capture-test2/20260810_182407_560_d79b519b`,
  logging class declaration, property layout, callee signature and global hard
  value dependencies while the failed compiler transaction published zero.
  Runtime FunctionInput resolution passed `2/2` at
  `Saved/Tests/cache-v52-function-input-test1/20260810_182450_499_9ecbc9c5`.
  The real clean-capture vertical then passed `1/1` at
  `Saved/Tests/cache-v52-clean-capture-dependency-green-test2/20260810_183835_489_1874c2c8`:
  `GCacheAnswer` 41 versus 42 retained source digest
  `cd0d11b5...a83b978`, stable global key `97c9d8f0...f772e45`, and changed only
  the resolved input digest from `1fe98b95...bda2a1` to
  `9dab095d...db2815`. Dedicated type/property/global current-authority coverage
  passed `1/1` at
  `Saved/Tests/cache-v52-function-input-authority-test/20260810_184126_428_a05d796f`.
  The direct-generated factory/default-constructor/default-destructor/member-
  initialization and derived-base audit passed `1/1` at
  `Saved/Tests/cache-v52-generated-derived-dependency-test2/20260810_184946_726_5dc2bdca`.
  The authoritative complete Cache regression passed `425/425`, failed/not-run
  `0/0`, at
  `Saved/Tests/cache-v52-complete-regression/20260810_185048_935_dbe431ce`,
  and the affected AngelScriptSDK Compiler.Builder prefix passed `64/64`,
  failed/not-run `0/0`, at
  `Saved/Tests/cache-v52-angelscript-sdk-builder-regression/20260810_185541_770_85ca22af`.
  These runs close the required successful/failure, current-authority, real
  clean-capture, generated-family and regression evidence boundary.
- Task impact/evidence: maintained AngelScript builder/module/compiler/function
  internals, new Runtime compiler bridge, dedicated Cache tests and OpenSpec.
  No business `.as`, AS syntax, Pack/Manifest format or Editor lifecycle is
  changed by the RED contract.

## IC-327 — Negative dependency-capture test did not register expected compiler diagnostics

- Severity/state: V5.2 test protocol mismatch / closed 2026-08-10.
- Exact boundary: after the official build passed, the focused run
  `Tools\RunTests.ps1 -TestPrefix
  'Angelscript.TestModule.Cache.CompilerDependencyCapture' -Label
  cache-v52-compiler-dependency-capture-test1` finished `0/2 PASS` at
  `Saved/Tests/cache-v52-compiler-dependency-capture-test1/20260810_182203_998_d0d70b6b`.
  The negative fixture reached `BrokenDependencyConsumer`, observed the global
  dependency and then deliberately failed on `MissingAfterObservedDependency`,
  but UE Automation counted the two emitted compiler diagnostics as unexpected
  test errors before evaluating the callback assertions.
- Root cause: the test intentionally drives a compiler error but omitted the
  CQTest/Automation expected-error registration required by the project test
  conventions. Production failure cleanup was not contradicted.
- Decision: register the exact section diagnostic and missing-identifier
  fragment once each, then retain the failed-result, negative compile code and
  zero published dependency assertions. Do not suppress all log errors.
- Required evidence: the focused negative test passes while the compiler still
  emits both registered diagnostics and its result callback publishes zero
  dependencies.
- Resolution/evidence: the exact expected diagnostics remained visible and the
  failed compile-result callback published zero dependencies; the focused prefix
  passed `2/2` at
  `Saved/Tests/cache-v52-compiler-dependency-capture-test2/20260810_182407_560_d79b519b`.
- Task impact/evidence: dedicated test and OpenSpec only.

## IC-328 — Script class parameter was incorrectly expected to be a value-layout dependency

- Severity/state: V5.2 typed dependency test expectation mismatch / closed
  2026-08-10.
- Exact boundary: the successful real module compile in the same focused run
  reached its result callback, but the first dependency assertion failed at
  `AngelscriptCacheCompilerDependencyCaptureTests.cpp:158`, expecting
  `FDependencyValue` as `VALUE_LAYOUT`.
- Root cause: ordinary AngelScript `class` types in this fork are reference
  types. Their use is a declaration/ABI dependency; the concrete `Count` member
  offset is independently represented by the required `PROPERTY_LAYOUT`
  dependency. Treating every class use as an inline value layout would
  unnecessarily miss functions after unrelated class layout changes and would
  collapse two intentionally distinct dependency categories.
- Decision: require a typed class `DECLARATION` dependency and keep the separate
  property-layout assertion. Add per-result dependency logs before assertions so
  all emitted kinds/names are visible in the automation report. Value types
  remain classified as `VALUE_LAYOUT` from their AS object flags and receive
  separate coverage when a stable value-type fixture is added.
- Required evidence: focused successful compile logs and passes class
  declaration, callee signature, pure-global hard-value and property-layout
  dependencies, with the retained function collection equal to the callback
  collection.
- Resolution/evidence: the corrected focused run passed `2/2` at
  `Saved/Tests/cache-v52-compiler-dependency-capture-test2/20260810_182407_560_d79b519b`.
  Its successful compile logged exactly `FDependencyValue` as declaration,
  `Count` as property layout, `DependencyCallee` as signature and
  `GHardValue` as hard value, and the retained per-function list equalled the
  callback list.
- Task impact/evidence: dedicated test and OpenSpec only; no production
  dependency classification changed.

## IC-329 — Generated default destructor had no persistent artifact entity kind

- Severity/state: V5.2 stable source-identity gap / closed 2026-08-10.
- Exact boundary: the V5.1 maintained-fork invocation enum already distinguished
  generated default destructor as kind `7`, but
  `EAngelscriptArtifactEntityKind` had no corresponding persistent entity. The
  Runtime source-digest bridge therefore could not map that successful invocation
  without collapsing it into ordinary destructor identity or rejecting it.
- Root cause: the persistent identity enum predated complete builder-family
  observation and contained generated default constructor but not its destructor
  counterpart.
- Decision: add the append-only value `GeneratedDefaultDestructor = 42`, admit it
  as a function-owned entity in semantic validation and module-graph invocation
  mapping, and explicitly cover it in identity/source-digest tests. Do not reuse
  or renumber an existing entity kind.
- Required evidence: official Editor build plus FunctionInput coverage proving
  generated constructor and destructor canonical source produce different source
  digests.
- Resolution/evidence: the official build passed at
  `Saved/Build/cache-v52-dependency-contract-green-build3/20260810_182143_350_8c134de8`;
  FunctionInput passed `2/2` at
  `Saved/Tests/cache-v52-function-input-test1/20260810_182450_499_9ecbc9c5`.
- Task impact/evidence: append-only persistent entity enum, semantic/module graph
  validation, identity test and OpenSpec; no existing numeric identity changed.

## IC-330 — First clean-capture integration test used wrong fixture/hash APIs

- Severity/state: V5.2 test integration compile blocker / closed 2026-08-10.
- Exact boundary: the official build
  `Tools\RunBuild.ps1 -Label cache-v52-clean-capture-dependency-red-build2`
  failed at
  `Saved/Build/cache-v52-clean-capture-dependency-red-build2/20260810_183055_762_f4627009`.
  The new test passed a `TEXT()` module name to the fixture's `const char*` API
  and called nonexistent `FAngelscriptHash256::ToString()` methods.
- Root cause: the fixture deliberately retains the AngelScript narrow module-name
  API, while the stable hash exposes `ToHexString()`.
- Decision: use a narrow module literal and the canonical hex formatter. Preserve
  the behavioral RED assertion; do not add adapter overloads solely for one test.
- Required evidence: the test translation unit builds and the focused run fails
  only because clean capture still persisted zero actual dependencies.
- Resolution/evidence: the corrected build passed at
  `Saved/Build/cache-v52-clean-capture-dependency-red-build3/20260810_183122_613_f821cac6`;
  the focused RED run at
  `Saved/Tests/cache-v52-clean-capture-dependency-red-test/20260810_183140_392_2a38d6b2`
  reached two successful 7-record captures and failed exactly at expected
  dependency count `1` versus actual `0`.
- Task impact/evidence: dedicated test only; no Runtime API or behavior change.

## IC-331 — Module graph did not admit selected-module global dependencies

- Severity/state: V5.2 cross-record authority gap / closed 2026-08-10.
- Exact boundary: after actual hard-value dependency persistence compiled
  successfully, the first GREEN run
  `Saved/Tests/cache-v52-clean-capture-dependency-green-test1/20260810_183515_183_eaecc298`
  failed during immutable graph validation with `GraphAbiMismatch` at FunctionBody
  actual-dependency offset 324. The record targeted a valid selected-module
  `ScriptGlobal`, but Step 9 understood module/type/property/function targets only.
- Root cause: earlier FunctionBody captures had empty actual dependencies. The
  graph validator already owned global declaration, storage-layout and HardValue
  authorities but had no branch connecting a FunctionBody dependency to them.
  The new Runtime resolver also initially placed layout hashes in ExpectedAbi,
  conflicting with the established semantic rule that ExpectedAbi is declaration
  signature and layout/value is ExpectedContentOrValue.
- Decision: preserve one semantic convention for every stable reference:
  ExpectedAbi is its declaration signature; optional layout/content/value is the
  content witness. Extend immutable graph validation for ScriptGlobal targets,
  validating GlobalStorage against `StorageLayoutFingerprint` and HardValue
  against the exactly owned `HardValueHash`; reject missing, duplicate or
  wrong-kind authorities. Align current type/property/global resolution with the
  same ABI-plus-content convention.
- Required evidence: official build, 7/7 graph-valid clean captures for both
  values, stable source/global identity, changed input digest, and current-state
  recomputation equal to the newly captured digest.
- Resolution/evidence: the official build passed at
  `Saved/Build/cache-v52-clean-capture-dependency-green-build2/20260810_183818_703_442272f5`.
  The focused integration passed `1/1` at
  `Saved/Tests/cache-v52-clean-capture-dependency-green-test2/20260810_183835_489_1874c2c8`
  and logged both 7-record graph admissions plus exact stable/source/input hashes.
- Task impact/evidence: Runtime compiler bridge, immutable ModuleSnapshot graph,
  clean-capture resolver, dedicated test and OpenSpec; no format version or
  business script change.

## IC-332 — Direct generated bytecode paths published zero actual dependencies

- Severity/state: V5.2 generated-family correctness gap / closed 2026-08-10.
- Exact boundary: the generated-family RED test compiled and then failed at
  `Saved/Tests/cache-v52-generated-dependency-red-test/20260810_184414_633_a7ecfa63`.
  Factory, generated default constructor and generated default destructor all
  reported successful compiler transactions with dependency count zero, even
  though their bytecode embedded object-type/function identities and member
  offsets.
- Root cause: `CompileFactory`, `CompileDefaultConstructor` and
  `CompileDefaultDestructor` write several VM instructions directly rather than
  passing through ordinary expression/property/function resolution where
  `MarkDependency` is normally called. `CompileMemberInitialization` likewise
  used the selected property offset without marking the property-layout
  authority.
- Decision: mark exactly the authorities embedded by each direct path: factory
  object type and selected constructor; member initialization/cleanup property
  layout and member type; direct base constructor/destructor calls. Keep these
  observations inside the existing per-invocation transaction so failure still
  clears them and raw pointers never persist.
- Required evidence: official Editor build and real module compile-result logs
  proving non-empty typed dependencies for factory, generated constructor,
  generated destructor, InitDefaults and derived base calls.
- Resolution/evidence: the maintained compiler changes built at
  `Saved/Build/cache-v52-generated-dependency-green-build1/20260810_184539_231_f8877af2`.
  The final expanded generated-family test passed `1/1` at
  `Saved/Tests/cache-v52-generated-derived-dependency-test2/20260810_184946_726_5dc2bdca`
  after the official build
  `Saved/Build/cache-v52-generated-derived-dependency-build2/20260810_184929_874_5f63c4ac`.
  Logs show factory type+constructor, constructor/destructor property+member-type,
  InitDefaults property, derived constructor base-content and derived destructor
  base-signature dependencies.
- Task impact/evidence: maintained AngelScript compiler, dedicated generated
  dependency test and OpenSpec; no AS syntax or business script change.

## IC-333 — Reference member cleanup was incorrectly expected to call its destructor directly

- Severity/state: V5.2 generated-family test expectation mismatch / closed
  2026-08-10.
- Exact boundary: after IC-332 was implemented, the focused run
  `Saved/Tests/cache-v52-generated-dependency-green-test1/20260810_184553_915_a2fec3b4`
  logged three correct destructor dependencies but failed the final assertion
  expecting a direct child-destructor function signature.
- Root cause: `FGeneratedDependencyChild Child` is a reference-class member in
  this dialect. Generated cleanup emits `REFCPY` against the child type so the
  final destructor is reached through reference counting; it does not embed a
  direct call to `~FGeneratedDependencyChild`. The embedded authorities are the
  `Child` property layout and child type declaration.
- Decision: assert the child type declaration instead of inventing a function
  dependency. Separately, a derived generated default constructor's direct base
  call remains `FunctionContent` because constructor/defaults compilation runs in
  hard-dependency mode; the derived destructor's direct base call is a normal
  signature dependency.
- Required evidence: focused generated-family logs and pass across owner member,
  InitDefaults and derived base paths.
- Resolution/evidence: the corrected and expanded test passed `1/1` at
  `Saved/Tests/cache-v52-generated-derived-dependency-test2/20260810_184946_726_5dc2bdca`.
- Task impact/evidence: dedicated test expectations and OpenSpec only; production
  bytecode and dependency classification were not weakened.

## IC-334 — Builder had no typed pre-compiler restore decision or atomic donor commit

- Severity/state: V5.3 required maintained-fork/Runtime capability / closed
  2026-08-10.
- Exact boundary: the new dedicated
  `AngelscriptCacheBuildArtifactRestoreHookTests.cpp` was added first. The
  official UE 5.8 Editor build
  `Tools\RunBuild.ps1 -Label cache-v53-restore-hook-red-build2` failed at
  `Saved/Build/cache-v53-restore-hook-red-build2/20260810_190852_309_0cb83984`.
  `as_buildartifact.h` has no `Restored/Miss/RejectedCorrupt/NotCacheable`
  result, module/builder restore callback or `compilerInvoked` observation, and
  the Runtime compiler bridge has no complete-artifact attach entry point.
- Root cause: V5.1 deliberately emitted an observer-only invocation before the
  compiler, while V3.4 restored a self-contained global function by creating a
  new function inside a disposable staging module. The builder path already
  owns a declared current-Engine function/FunctionId, so creating a second
  function would duplicate identity; applying debug after publishing execution
  would also permit partial live mutation on a corrupt sidecar.
- Decision: add one synchronous maintained-fork restore decision per actual
  compiler invocation. Only `Restored` may skip `asCCompiler`. Reconstruct and
  relocate execution into an unpublished donor function, apply the complete
  host debug payload to that donor, strictly compare it with the builder's
  current declaration, then atomically swap complete private `scriptData` into
  the existing target and retain its current numeric FunctionId. Miss,
  corruption and NotCacheable all run the authoritative compiler. Raw bytecode
  assignment and status-only fake hits are forbidden.
- Required evidence: official Editor build; a real producer clean capture
  destroyed before consumer use; current-Engine FunctionId preservation;
  executable restored behavior with `compilerInvoked=false`; Miss and corrupt
  fallback with target bytecode still empty immediately after lookup and normal
  compile success; public-single NotCacheable without invoking lookup; affected
  Cache and AngelScriptSDK builder regressions.
- Resolution/evidence: the maintained builder now asks exactly once immediately
  before every real compiler invocation and only skips the compiler for a
  verified `Restored` result. Runtime verifies the candidate, the maintained
  reader reconstructs execution into an unpublished donor, the debug sidecar is
  applied to that donor, and a strict final commit swaps complete private VM
  state into the already-declared current function while retaining its current
  FunctionId. The final focused test passed `3/3` at
  `Saved/Tests/cache-v53-restore-hook-hardening-test/20260810_192006_215_c1ca7642`.
  It proves a real producer/consumer hit with `CompilerCalls=0`, producer/current
  IDs `79776/79777` and result 42; Miss, corrupt execution, corrupt debug with
  recomputed hashes and a status-only fake hit all leave the target empty and
  compile normally; public-single reports NotCacheable without lookup.
- Task impact/evidence: maintained AngelScript artifact/builder/module/restore
  internals, Runtime VM codec/compiler bridge, a separate Cache test translation
  unit and OpenSpec. The authoritative complete Cache regression passed
  `428/428` with failures/skips `0/0` at
  `Saved/Tests/cache-v53-complete-regression/20260810_192417_808_01a4837a`;
  affected AngelScriptSDK Compiler.Builder passed `64/64` with failures/skips
  `0/0` at
  `Saved/Tests/cache-v53-angelscript-sdk-builder-regression/20260810_192933_269_c453da17`.

## IC-335 — First V5.3 RED fixture attempted to assign a non-copyable read budget

- Severity/state: V5.3 test-fixture compile noise / closed 2026-08-10.
- Exact boundary: the first RED build
  `Saved/Build/cache-v53-restore-hook-red-build/20260810_190827_485_79722d2e`
  included the intended missing production APIs but also failed because
  `BuildConsumer` used `OutRestore = {}` while `FRestoreContext` owns the
  deliberately non-copyable `FAngelscriptCacheReadBudget`.
- Decision/resolution: each consumer already supplies a fresh context; reset
  only its scalar/log fields and leave the transaction budget object in place.
  The second RED build above then failed only at the missing V5.3 contract and
  its dependent cascade.
- Required evidence/task impact: isolated RED compile boundary only; no Runtime,
  format or business-script behavior changed.

## IC-336 — Full header rebuild exceeded the outer 180-second build invocation

- Severity/state: V5.3 build-infrastructure timing / closed 2026-08-10.
- Exact boundary: `Tools\RunBuild.ps1 -Label
  cache-v53-restore-hook-impl-build1` changed the maintained artifact header and
  triggered 91 XGE actions. The outer tool invocation stopped at 184 seconds,
  while `UBT.log` at
  `Saved/Build/cache-v53-restore-hook-impl-build1/20260810_191326_348_a2c5b9ad`
  completed at 187.02 seconds with `91/91`, `Rebuild All: 1 succeeded`, and
  `Result: Succeeded`.
- Decision/resolution: treat the outer timeout as non-behavioral rather than a
  compile failure, inspect the authoritative UBT result, then rerun the official
  wrapper incrementally. The rerun returned process/final `0/0` at
  `Saved/Build/cache-v53-restore-hook-impl-build2/20260810_191656_247_ab66fb26`.
- Required evidence/task impact: no source change was made for the timeout. The
  later focused behavior run and regressions remain the V5.3 authority.

## IC-337 — Detached artifact donor had no module identity at final commit

- Severity/state: V5.3 donor-commit integration defect / closed 2026-08-10.
- Exact boundary: the first focused behavior run passed Miss/corruption and
  NotCacheable but failed the valid hit at
  `Saved/Tests/cache-v53-restore-hook-green-test1/20260810_191702_331_47535882`.
  The Runtime reported `FunctionArtifact target commit failed: Result=-5
  TargetId=79777`; target bytecode remained empty and the authoritative fallback
  compiler still produced executable result 42.
- Root cause: `ReadFunction(..., addToModule=false, ...)` correctly creates an
  unpublished donor with `module == nullptr`. The final strict commit requires
  the donor and target to name the same current module, but the detached helper
  had not assigned that non-publication ownership coordinate after successful
  reconstruction.
- Decision/resolution: after exact-length validation and relocation succeed,
  assign the reader's current module to the donor without registering the donor
  in the module or Engine. The strict equality check remains intact. The
  incremental official build passed at
  `Saved/Build/cache-v53-restore-hook-donor-module-build/20260810_191815_891_6e70cb39`.
  The focused run then passed `3/3` at
  `Saved/Tests/cache-v53-restore-hook-green-test2/20260810_191827_556_0e6be9b1`:
  the valid path logged `CompilerCalls=0`, producer/current FunctionIds
  `79776/79777`, five restored bytecode words and result 42.
- Hardening evidence: the final focused run at
  `Saved/Tests/cache-v53-restore-hook-hardening-test/20260810_192006_215_c1ca7642`
  also rejects a debug payload whose hash was recomputed after corruption and a
  status-only fake `Restored`; both leave target bytecode at zero before the
  normal compiler runs.
- Task impact/evidence: maintained restore donor ownership only; no persisted
  bytes, stable keys or business script changed.

## IC-338 — No graph-owned stable-key/source/input candidate lookup existed

- Severity/state: V5.4 required Runtime selection capability / closed 2026-08-10.
- Exact boundary: the dedicated same-module two-function RED test was added in
  `AngelscriptCacheFunctionCandidateLookupTests.cpp`. The official Editor build
  failed at
  `Saved/Build/cache-v54-function-lookup-red-build/20260810_193629_676_c9dfb006`
  because Runtime exposes neither a way to reopen clean artifacts as an owning
  `FAngelscriptValidatedModuleGraph` nor a lookup that consumes that immutable
  graph before delegating to the V5.3 VM commit. Errors after the missing result
  type/API are ordinary C++ parse cascades.
- Decision: candidate selection must consume the graph-published, stable-key-
  sorted function ordinals and their owned decoded records, not an arbitrary
  caller-supplied FunctionBody DTO. It shall compare the full current stable
  function key and Profile, compute the current source digest from the builder
  invocation, resolve the persisted actual dependencies against current
  authorities to obtain the current input digest, and call V5.3 restore only
  after all coordinates match. Body-only source mismatch is a typed Miss and
  never reaches artifact attachment.
- Required evidence: the producer graph must contain two functions from one
  source/module; a consumer with only one changed body must compile that
  function to its new result while the unchanged function is a real
  pre-compiler Restored hit with `compilerInvoked=false`. Both functions must
  execute, and complete Cache plus affected Builder regressions remain green.
- Task impact/evidence: Runtime graph-open/compiler-bridge API, widening the
  admitted enum/global-function clean-capture vertical from exactly one to a
  bounded complete function set, the dedicated test translation unit and
  OpenSpec. No business `.as` file or persistent wire version changes.
- Resolution/evidence: clean artifacts now reopen through the sole owning graph
  decoder/validator and candidate lookup binary-searches graph-published
  function ordinals by the complete stable key before checking Profile,
  current source and current input. The final isolated caller/callee behavior is
  GREEN at
  `Saved/Tests/cache-v54-function-relocation-green-test2/20260810_195823_234_a2735fc1`:
  the changed function is SourceChanged and compiled to 42, while the unchanged
  caller is Restored with compiler count zero and executes 43.

## IC-339 — Function artifacts rejected a real caller relocation table

- Severity/state: V5.4 maintained-fork symbolic-reference capability / closed
  2026-08-10.
- Exact boundary: after the independent two-function lookup test first passed,
  the unchanged function was strengthened to call the body-edited function.
  The official build passed at
  `Saved/Build/cache-v54-caller-relocation-red-build/20260810_194417_409_8185a0f8`,
  while the behavior RED failed at
  `Saved/Tests/cache-v54-caller-relocation-red-test/20260810_194430_988_b43a8611`.
  Clean capture reported `Function int UnchangedBody() contains symbolic
  reference tables not supported by the admitted cold-capture vertical`.
- Root cause: maintained `WriteFunctionArtifact` currently writes only the root
  function and deliberately rejects every nonempty used-function/type/global/
  string/property table. V5.3 therefore proves only self-contained execution;
  it cannot yet relocate a caller's function operand to the current Engine.
- Decision: add a new execution-codec revision that appends a bounded used-
  function signature table, resolves it against the current module before
  bytecode translation, and exposes the resolved raw function references to the
  Runtime opaque validator. Runtime maps those references back to graph-owned
  stable function dependencies and publishes explicit relocation uses; it must
  not persist numeric FunctionIds or accept an unrecorded relocation. Other
  symbolic table kinds stay NotCacheable until their own complete adapters are
  added.
- Required evidence: clean graph validation must observe the function
  relocation as a subset of persisted actual dependencies; the unchanged
  caller must restore before compiler, call the newly compiled current callee
  and return 43. Corrupt/unresolved tables must fail closed without target
  mutation, and Cache/Builder regressions remain green.
- Task impact/evidence: maintained reader/writer execution stream, Runtime
  opaque summary mapping, clean-capture actual-dependency population, focused
  tests and OpenSpec. The common FunctionBody wire layout remains unchanged;
  only its explicit VM execution codec coordinate advances.
- Resolution/evidence: execution codec v2 appends only the bounded
  used-function signature table; all other symbolic tables remain
  `NotCacheable`. The maintained reader resolves each signature against the
  current module, translates the instruction operand to the current function
  and exports its instruction/operand coordinate. Runtime derives the same
  stable function key from that current pointer and accepts the relocation only
  when it exactly matches a persisted Signature dependency. The focused
  function prefix passed `7/7` at
  `Saved/Tests/cache-v54-function-focused-green/20260810_200138_761_61013c78`.
  Removing the caller's declared dependency while retaining locally consistent
  hashes is rejected before promotion as `RelocationDependencyMismatch`
  (`Error=47`), with zero graph/output records.

## IC-340 — V5.4 lookup callback supplied no current declaration authority

- Severity/state: V5.4 focused integration defect / closed 2026-08-10.
- Exact boundary: after execution codec v2 admitted the used-function signature
  table, the official Editor build passed at
  `Saved/Build/cache-v54-function-relocation-impl-build1/20260810_195352_626_a191c154`.
  The first strengthened behavior run at
  `Saved/Tests/cache-v54-function-relocation-green-test1/20260810_195433_543_4a505bdb`
  still failed `0/1`: producer capture and graph-open succeeded with two
  functions and nine records, `ChangedBody` was the expected SourceChanged
  miss, but `UnchangedBody` reported `DependencyMissing` ordinal 0 and invoked
  the compiler. Both consumer functions nevertheless executed current behavior
  (`42` and `43`), so this is not a stale FunctionId execution fault.
- Root cause: the dedicated precompiler callback constructed an empty
  `FAngelscriptCacheFunctionInputAuthorities`. Clean capture now correctly
  persists the caller's Signature dependency, so lookup correctly refuses to
  claim a hit without a current declaration ABI authority for `ChangedBody`.
- Decision: keep the fail-closed Runtime check. The focused admitted-shape test
  adapter will derive a fresh current module interface from the consumer's
  already-declared global no-parameter `int` functions before each lookup and
  pass that current authority to the bridge. It must not reuse the producer
  interface merely to make the digest match. V6 will replace this focused test
  adapter with the lifecycle service's complete precompile authority snapshot.
- Required evidence: the lookup reports Restored, compiler count remains zero,
  and the restored caller executes 43 through the consumer Engine's compiled
  callee. A deliberately absent current signature authority must remain a typed
  `DependencyMissing` miss.
- Implementation note: the first adapter build at
  `Saved/Build/cache-v54-current-authority-build1/20260810_195733_505_80f2db81`
  failed because the test used the restore translation unit's private
  `m_scriptFunctions` compatibility alias. The adapter was corrected to the
  public `GetFunctionCount()/GetFunctionByIndex()` observer surface; no private
  module container alias is exported to tests.
- Task impact/evidence: focused test authority adapter and later negative test;
  no cache wire relaxation and no persisted producer authority is treated as
  current state.
- Resolution/evidence: the focused adapter derives the current consumer
  declaration interface through public `GetFunctionCount()` /
  `GetFunctionByIndex()` observations before every lookup. Supplying it restores
  the caller and executes 43; deliberately omitting it remains the expected
  typed `DependencyMissing` miss and invokes the authoritative compiler. Both
  paths are included in the final `7/7` focused evidence. The official final
  build passed at
  `Saved/Build/cache-v54-negative-tests-build/20260810_200115_365_ef51eda7`.
  Complete Cache passed `431/431` at
  `Saved/Tests/cache-v54-complete-regression/20260810_200235_410_c5c978c7`,
  and affected Compiler.Builder passed `64/64` at
  `Saved/Tests/cache-v54-angelscript-sdk-builder-regression/20260810_200751_633_09022f77`.

## IC-341 — Seven stable invocation families still have no complete symbolic artifact

- Severity/state: V5.5 maintained-fork execution-codec capability / closed
  2026-08-10.
- Exact boundary: the dedicated real-module probe
  `AngelscriptCacheInvocationFamilyArtifactTests.cpp` compiled into the official
  Development Editor target, then failed as intended at
  `Saved/Tests/cache-v55-invocation-family-probe-red/20260810_201814_760_772c5c85`.
  `GlobalFunction` wrote a 54-byte artifact successfully, while `Method`,
  explicit `Constructor`, explicit `Destructor`, `Factory`,
  `GeneratedDefaultConstructor`, `GeneratedDefaultDestructor` and
  `InitDefaults` all returned `asNOT_SUPPORTED (-7)`. Their partial streams were
  respectively 62, 72, 82, 47, 44, 82 and 74 bytes before the fail-closed table
  check. The test used the same source shape already proven to emit all eight
  cacheable builder invocation descriptors, so this is an execution artifact
  gap rather than missing builder routing.
- Root cause: execution codec v2 deliberately admits only the used-function
  signature table. Every non-global family exercised at least one still-
  rejected type-id/type/global/string/object-property table, but the current
  writer result does not expose which table caused the rejection. Treating
  those functions as restored or comparing only their descriptor would attach
  incomplete VM state.
- Decision: first add bounded read-only writer diagnostics that identify every
  populated symbolic table and the rejection stage. Use that evidence to add
  complete stable semantic adapters in the maintained fork and Runtime opaque
  validator, one table family at a time. Each adapter must resolve only against
  current Engine declarations/type/property/global authorities and publish
  exact relocation uses backed by persisted actual dependencies; numeric ids,
  offsets and pointers remain non-persistent. Public-single and lambda remain
  explicitly `NotCacheable` because their descriptor coordinates are unstable.
- Required evidence: all eight stable invocation families must write, validate
  and attach complete artifacts in a separately initialized Engine; cached and
  forced-clean functions must have equal canonical execution/debug content,
  stable semantic hashes, complete VM-state snapshots and observable behavior.
  Every unsupported or unresolved symbolic coordinate must be a typed safe miss
  with the target still empty before normal compilation.
- Task impact/evidence: V5.5 maintained writer/reader diagnostics and symbolic
  tables, Runtime stable relocation mapping, a dedicated invocation-family test
  translation unit and progressive OpenSpec evidence. This does not widen the
  production Editor/PIE lifecycle or alter business `.as` files.

## IC-342 — Detached artifacts lose lifecycle/generated function traits

- Severity/state: V5.5 cross-Engine atomic-commit defect / closed 2026-08-10.
- Exact boundary: execution artifact v3 and the complete semantic symbol tables
  first made all eight invocation families readable in one Engine at
  `Saved/Tests/cache-v55-symbol-tables-reader-test1/20260810_202859_914_89a39adf`.
  The strengthened two-independent-Engine oracle then reached the real restore
  hook with all eight families and 19 artifacts. Its diagnostic RED at
  `Saved/Tests/cache-v55-special-function-commit-diagnostics-red/20260810_205900_657_815d4913`
  restored every ordinary Method, GlobalFunction and `InitDefaults`, but rejected
  every Factory, Constructor, Destructor, GeneratedDefaultConstructor and
  GeneratedDefaultDestructor at the sole atomic commit with `asINVALID_ARG (-5)`.
- Root cause: the common `WriteFunction`/`ReadFunction` bytecode stream preserves
  only the historical signature trait subset. The detached donor therefore had
  `traits=0`, while the already-declared current target retained constructor
  (`0x1`), destructor (`0x2`), generated (`0x40000`) and/or
  unsafe-during-construction (`0x2000000`) semantics. Engine, module, func type,
  object type, namespace and `IsSignatureEqual()` were all equal, donor bytecode
  was complete and target bytecode remained empty. Relaxing the exact commit
  check would hide an omitted semantic field and could admit a stale invocation
  classification.
- Decision: extend the maintained function-artifact envelope with a fixed-width
  complete root-function trait word, validate/restore it onto the detached donor,
  and bump the execution artifact codec version so an older stream cannot be
  interpreted under the widened contract. Keep exact donor/target trait equality
  at the atomic commit; the current declaration remains the authority and a
  mismatch remains a safe rejected candidate before normal compilation.
- Required evidence: all 19 artifacts restore into the second Engine with changed
  numeric FunctionIds and zero corresponding compiler calls; execution/debug,
  content, stable-key and complete VM-state hashes equal the forced-clean Engine;
  explicit and generated constructor/destructor behavior remains correct. A
  deliberately changed or truncated trait word must be rejected without mutating
  the target.
- Task impact/evidence: maintained writer/reader artifact envelope, Runtime
  execution codec version, focused corruption coverage and the V5.5 two-Engine
  parity oracle. No Editor/PIE lifecycle or business `.as` source is changed.

## IC-343 — Generic bytecode restore reconstructs incomplete derived VM frame state

- Severity/state: V5.5 cross-Engine VM-state parity defect / closed 2026-08-10.
- Exact boundary: execution artifact v4 explicitly preserved the root trait word
  and the official build passed at
  `Saved/Build/cache-v55-function-artifact-v4-root-traits-build1/20260810_210150_598_438a5cc3`.
  The next two-Engine run at
  `Saved/Tests/cache-v55-function-artifact-v4-root-traits-test1/20260810_210212_597_34ab9078`
  restored all 19 artifacts with zero compiler calls, equal execution/debug bytes
  and equal stable keys. It then failed complete VM-state equality on the first
  Factory. The field-level rerun at
  `Saved/Tests/cache-v55-vm-state-breakdown-red/20260810_210402_428_7b4fa70e`
  showed producer `StackNeeded=6`, `ObjVariablesOnHeap=1`,
  `ObjTypes=[FParityLeaf]`, `ObjPos=[2]`, but restored consumer
  `StackNeeded=4`, zero heap objects and empty legacy object arrays.
- Root cause: the historical function stream persists bytecode, adjusted
  `variableSpace`, object-lifetime ranges and declared local variables, then the
  reader recomputes `stackNeeded` and APV2 legacy `objVariableTypes/Pos` from
  those fields. That heuristic cannot recover every compiler-created object
  temporary used by Factory and other special functions. Equal reserialized
  execution bytes therefore did not prove equal executable frame-cleanup state.
- Decision: widen the function-artifact-only envelope with bounded canonical
  derived frame metadata: adjusted `stackNeeded`, exact ordered
  `objVariableTypes/objVariablePos` and `objVariablesOnHeap`. Type coordinates
  use the same semantic current-Engine resolver and are pre-registered in the
  symbolic type table so graph authority can validate them. The reader first
  performs normal bytecode translation, then replaces the heuristic result with
  the validated exact metadata before atomic commit. Numeric FunctionIds,
  pointers and raw engine-owned addresses remain forbidden.
- Required evidence: complete VM-state hashes match for every one of the 19
  products and behavior executes after Engine A destruction. Malformed counts,
  unknown types, invalid heap prefix or invalid positions must reject before
  target mutation. The emitted type dependencies must be visible to graph
  admission rather than hidden inside the opaque payload.
- Task impact/evidence: maintained function-artifact writer/reader, v4 opaque
  validator, symbol-relocation authority and focused VM metadata corruption
  tests. V5.5 stays open until graph-owned adapters and all parity assertions pass.

## IC-344 — DebugSidecar omits explicit local-variable names and declaration positions

- Severity/state: V5.5 debug/VM-state parity defect / closed 2026-08-10.
- Exact boundary: exact derived frame metadata passed Factory and every special
  lifecycle product through the two-Engine equality loop at
  `Saved/Tests/cache-v55-exact-derived-frame-state-test1/20260810_210915_887_b480fdec`.
  The first remaining mismatch was global `RunGeneratedParityBehavior`: execution
  bytes, debug payload hash, traits, stack/object state and stable key all matched,
  but producer local variable `Generated` retained declaration position 1 while
  the consumer local had an empty name and position 0.
- Root cause: the execution writer deliberately strips debug tables. Debug codec
  v1 restores function declaration position, lines, section transitions, parameter
  names and temporary-variable token/offset entries, but never serializes the
  debug half of `scriptData->variables`. The execution stream correctly retains
  each local's type/stack offset/on-heap semantics, leaving its name and source
  declaration position empty after restore.
- Decision: add an ordinal-aligned explicit-local debug table to DebugSidecar and
  bump the debug codec version. Each row contains only the retained local name and
  program declaration position; decode requires its count to equal the execution
  donor's local-variable count before applying. Type, stack offset and lifetime
  remain execution-owned and are not duplicated. Validation remains bounded and
  exact-length; stale v1 payloads are unsupported rather than partially applied.
- Required evidence: all 19 products have equal complete VM-state/debug hashes and
  behavior after cross-Engine restore. Count mismatch, over-limit position,
  malformed UTF-8 and trailing bytes reject the donor before target commit. Clean
  capture and the dedicated parity fixture must use the same production encoder.
- Task impact/evidence: `FAngelscriptFunctionDebugArtifact`, debug codec encode/
  decode/apply, clean capture adapter, parity capture and focused corruption tests.
  This does not change `.as` source or the persisted record envelope schema.

## IC-345 — Clean capture still rejects local debug rows after DebugSidecar v2

- Severity/state: V5.5 production clean-capture eligibility defect / closed
  2026-08-10.
- Exact boundary: the new graph-safety fixture first compiled successfully after
  correcting plugin handle syntax, but the baseline clean capture returned
  `NotCacheable` before graph construction at
  `Saved/Tests/cache-v55-symbol-dependencies-red-test2/20260810_212323_416_9798f50a`.
  Its exact detail was `Local-variable debug descriptors are not supported by the
  first cold-capture vertical`. The function only declared one ordinary local in
  order to exercise a real script-property bytecode relocation.
- Root cause: DebugSidecar v2 and `TryBuildDebugPayload` now encode every
  ordinal-aligned `scriptData->variables` name/declaration position, but an older
  v1 eligibility guard still returned before that encoder ran. The stale guard
  made otherwise supported functions with explicit locals permanently miss the
  cache and prevented the graph from validating their type/property symbols.
- Decision: remove the obsolete early return. Keep the later v2 loop as the sole
  production authority: null rows, invalid names, count mismatches, malformed
  payloads and positions still fail closed through the bounded debug codec. Do
  not special-case the test or discard local debug information.
- Required evidence: the real clean-capture baseline with a local script-class
  reference reaches a validated graph; removing its PropertyLayout dependency
  then produces the intended relocation-coverage RED. Existing two-Engine local
  debug parity remains green, and malformed local-table coverage will be added
  before V5.5 closes.
- Task impact/evidence: production clean capture, the dedicated V5.5 symbol
  dependency validation translation unit and Cache regression. No business `.as`
  file or Editor lifecycle is changed.

## IC-346 — Opaque validation does not report property/type symbol-table uses

- Severity/state: V5.5 graph-admission safety defect / closed 2026-08-10.
- Exact boundary: after IC-345 was removed, the new production-backed fixture at
  `Saved/Tests/cache-v55-symbol-dependencies-red-test3/20260810_212448_175_0bf73655`
  generated and validated seven records for a root class, one property, one hard
  global value and one global function. The function published three actual
  dependencies. The fixture removed only its PropertyLayout dependency, rebuilt
  the FunctionInputDigest and all affected record/root hashes, then called the
  real promotion path. Validation incorrectly returned success and promoted all
  seven records (`Error=0 Graph=7 OutputRecords=7`).
- Root cause: maintained artifact v4 resolves used type/type-id/global/property
  tables to current Engine objects, but `FAngelscriptFunctionArtifactCodec`
  exports only instruction-level function relocations. Consequently
  `RelocationsAreDependencySubset` sees no property use and cannot prove that the
  decoded bytecode offset is backed by the persisted stable PropertyLayout edge.
- Decision: expose one bounded read-only semantic-use view for every artifact
  table family from `asCReader`. Runtime converts those current objects to the
  same stable TypeKey/PropertyKey/GlobalKey/FunctionKey identity used by clean
  capture, requires exactly one matching declared dependency, and emits an
  opaque relocation use. String constants remain payload-owned canonical bytes;
  numeric ids, offsets, addresses and pointers remain transient only. Start with
  the failing property path, then cover type, type-id, global and function tables
  through the same interface before V5.5 closes.
- Required evidence: unchanged baseline promotes; deleting, rekeying or
  duplicating the property dependency is `RelocationDependencyMismatch` before
  output promotion. Equivalent coverage is required for type, global and
  function symbols, followed by two-Engine parity and complete Cache/Builder
  regression.
- Task impact/evidence: maintained reader observation API, Runtime opaque codec,
  dedicated symbol-dependency tests and graph diagnostics. No persisted pointer
  fields or business `.as` changes are permitted.

## IC-347 — Mutable-global fixture cannot represent the product GlobalStorage path

- Severity/state: V5.5 symbol-coverage test-design and generated-symbol authority
  question / closed by explicit unsupported-shape decision 2026-08-10.
- Exact boundary: after Type Declaration and Function Signature production graph
  negatives passed, the first dedicated GlobalStorage/ValueLayout matrix ran at
  `Saved/Tests/cache-v55-symbol-storage-value-red-test1/20260810_214407_271_68671db8`.
  The real by-value script struct reached the maintained writer/reader and passed
  both the complete two-relocation baseline and missing-ValueLayout rejection.
  The mutable-global source never reached artifact validation: the authoritative
  builder rejected `int GMutableCacheValue = 41` with `Global variable ... must be
  const. Mutable global variables are not supported.` The prefix therefore ended
  `4/5 PASS`; treating this as a codec failure or weakening the language rule
  would test a product shape that does not exist.
- Root cause/question: the admitted plugin language uses pure constants for user
  script globals, which are compiler inputs/HardValues rather than runtime storage
  relocations. The real local-module global-storage candidate is the generated
  `__StaticType_<Class>` backing symbol used by generated `StaticClass` machinery.
  Existing ModuleInterface/ModuleState intentionally exclude that implementation
  symbol from user declarations, so blindly assigning it a ScriptGlobal key would
  create a second public authority for one logical Type.
- Decision: preserve the mutable-global prohibition. Probe the actual generated
  StaticClass function and its writer/global table, then assign its use to one
  existing stable Type authority or explicitly model a type-owned internal symbol;
  do not invent a cacheable mutable user-global path. If no admitted executable
  function can carry GlobalStorage under current language semantics, document and
  test the table as fail-closed/unreachable rather than claiming production graph
  coverage from a raw unsupported fixture.
- Required evidence: writer diagnostics for the generated StaticClass/global pair;
  a stable identity decision consistent with TypeSchema and ModuleState ownership;
  complete dependency acceptance plus missing/rekeyed/duplicated dependency
  rejection if the table is admitted, or an explicit typed NotCacheable result if
  it remains unsupported. Re-run the complete symbol matrix without any expected
  compile error and preserve the existing mutable-global diagnostic behavior.
- Task impact/evidence: maintained-fork artifact symbol adapter, generated class
  test fixture, clean-capture authority mapping and OpenSpec. No business `.as`
  source or language-level mutable-global support is added.

## IC-348 — Generated StaticClass dependencies have no Type-owned normalization

- Severity/state: V5.5 production dependency capture and opaque-relocation
  authority defect / closed 2026-08-10.
- Exact boundary: the corrected generated-symbol tests ran at
  `Saved/Tests/cache-v55-generated-static-authority-red-test1/20260810_214902_452_50207c75`.
  The real generated `StaticClass()` artifact proved one used-global table row
  backed by `__StaticType_FCacheGeneratedStaticStorage` and one raw compiler
  `GlobalStorage` dependency. Separately, an ordinary user function calling its
  generated `StaticClass()` failed production clean capture with `Error=64` at
  `Function actual dependency capture`, before any record was emitted. The
  maintained compiler reported the generated helper function, but the clean
  resolver registered only the user function and public Type declaration.
- Root cause: IC-314 deliberately classified the generated static global and
  generated StaticClass function as TypeSchema/ClassGenerator-derived artifacts,
  not independent ModuleInterface/ModuleState/FunctionBody cache units. The V5
  dependency resolver and opaque codec nevertheless attempted to map their raw
  function/global pointers as ordinary ScriptFunction/ScriptGlobal identities,
  for which no graph authority exists.
- Decision: retain the single TypeSchema authority. During clean dependency
  normalization, recognize only the exact descriptor-classified generated
  global/helper pointers and convert their `GlobalStorage`/`Signature` compiler
  observations to the owning ScriptType `Declaration` dependency. During opaque
  validation, recognize the same exact generated naming/trait relationship and
  require the same TypeKey Declaration edge while still resolving the actual
  current-Engine function/global operand. Unknown lookalikes fail closed. The
  generated helper body itself remains a derived implementation artifact rather
  than a new public FunctionBody.
- Required evidence: the ordinary user-function production capture succeeds with
  one Type-owned declaration edge; deleting that edge after repairing all derived
  hashes is `RelocationDependencyMismatch` with zero promotion. The manual
  generated helper artifact continues to expose its real global table but cannot
  be admitted by an invented public ScriptGlobal dependency. Existing ordinary
  type/property/function/value-layout negatives and full Cache/Builder regressions
  remain green.
- Task impact/evidence: production clean-capture resolver, Runtime function
  artifact stable-identity adapter, generated-symbol tests and OpenSpec only. No
  new public declaration, mutable global or business `.as` change is introduced.
- Resolution evidence: exact generated global/function pointer classification
  now normalizes both compiler observations and opaque relocations to the owning
  ScriptType Declaration. Together with IC-349's environment edge, the ordinary
  caller baseline and missing-owner negative pass in
  `Saved/Tests/cache-v55-environment-type-bridge-test2/20260810_220839_935_d53ec283`.

## IC-349 — Opaque artifact validation cannot resolve engine-owned type symbols

- Severity/state: V5.5 current-Engine stable-symbol bridge gap / closed 2026-08-10.
- Exact boundary: after IC-348 added exact Type-owned normalization for the
  generated `StaticClass()` function and `__StaticType_*` global, the focused
  run at
  `Saved/Tests/cache-v55-generated-static-authority-green-test1/20260810_215259_228_1185ca3c`
  ended `5/6 PASS`. The ordinary user function now reaches production graph
  validation, but its first maintained-reader Type Declaration observation is
  the engine-owned `UClass` return type of `StaticClass()`. The opaque adapter
  only resolves types declared by the current script module, so validation
  rejects the artifact with `Function artifact symbol use 0 kind 1 could not
  resolve to one current stable identity`. The generated-helper fail-closed
  probe reports the same environment-type boundary, as expected.
- Root cause: local `ScriptType` identity and generated Type-owned normalization
  are implemented, while the already-designed `EnvironmentType` /
  `EnvironmentAbi` graph authorities are not yet connected to the maintained
  reader's current-Engine type observations. Treating `UClass` as a local
  `ScriptType`, ignoring the observation, or persisting its current numeric type
  id/address would make cross-launch validation unsound.
- Decision: resolve non-local engine-owned type observations through the single
  canonical environment type/ABI identity builder already used by Cache V2
  environment records. Require an exact current-Engine match and an exact
  declared `EnvironmentType` or `EnvironmentAbi` dependency as appropriate;
  ambiguous, unknown and ABI-mismatched symbols fail closed. Keep generated
  StaticClass function/global identity normalized to the owning script Type
  Declaration from IC-348.
- Required evidence: the real user `StaticClass()` caller captures and promotes
  with both the owning script Type Declaration and canonical `UClass`
  environment authority; deleting, rekeying or duplicating either edge after
  repairing derived hashes rejects atomically with zero promotion. Preserve the
  generated-helper non-public/fail-closed probe, then rerun the complete symbol
  matrix, two-Engine parity and Cache/Builder regressions.
- Task impact/evidence: Cache V2 environment identity lookup, production clean
  dependency capture if the compiler dependency set does not already publish
  the environment edge, Runtime opaque symbol adapter, focused tests and
  verification notes. No business `.as`, public generated cache entity or
  persisted pointer/numeric id is added.
- Resolution evidence: one shared environment-type identity builder now derives
  the application-registered AS surface key and structural ABI; the maintained
  builder records non-primitive return/parameter signature types, clean capture
  resolves them to `EnvironmentAbi`, current-Engine graph validation uses the
  same resolver, and opaque type observations require the same exact edge. The
  official build passed at
  `Saved/Build/cache-v55-environment-type-bridge-build3/20260810_220826_919_a15bdf33`.
  The six-test matrix passed `6/6` at
  `Saved/Tests/cache-v55-environment-type-bridge-test2/20260810_220839_935_d53ec283`;
  its real `StaticClass()` caller promotes seven records, while deleting either
  the `UClass EnvironmentAbi` or owning ScriptType Declaration rejects at
  `RelocationDependencyMismatch` with graph/output both zero.

## IC-350 — Environment bridge test used a non-existent UE TArray predicate API

- Severity/state: V5.5 test translation-unit compile defect / fixed 2026-08-10.
- Exact boundary: the first environment-type bridge build used wrapper label
  `cache-v55-environment-type-bridge-build1`, with UBT evidence under
  `Saved/Build/cache-v55-environment-type-bridge-build1/20260810_220540_891_4c937062`.
  All changed Runtime unity units compiled and the Runtime library linked, but
  `AngelscriptCacheSymbolDependencyValidationTests.cpp:761` failed because UE
  5.8 `TArray` has no `CountByPredicate` member. The short wrapper polling
  process had already exited, so the authoritative artifact is `UBT.log`
  rather than a generated `Summary.json`.
- Root cause: the new test used an assumed container convenience API instead of
  the UE 5.8 `TArray` surface available to this project.
- Decision/resolution: replace the convenience call with one explicit bounded
  loop over `ActualDependencies`; preserve the exact assertion that precisely
  one `EnvironmentAbi -> EnvironmentSymbol` edge exists. No Runtime or wire
  behavior changes are justified by this test-only compile failure.
- Required evidence: the next official wrapper build compiles both Runtime and
  AngelscriptTest, followed by the six-test SymbolDependencyValidation run.
- Task impact/evidence: one test translation unit and this issue record only.

## IC-351 — Generic EnvironmentAbi resolver incorrectly published storage category

- Severity/state: V5.5 current-resolver contract mismatch / fixed 2026-08-10.
- Exact boundary: after the environment bridge compiled at
  `Saved/Build/cache-v55-environment-type-bridge-build2/20260810_220635_970_54d298c7`,
  the focused run
  `Saved/Tests/cache-v55-environment-type-bridge-test1/20260810_220657_396_750778b7`
  ended `5/6 PASS`. The `StaticClass()` caller progressed past stable-symbol
  resolution but graph admission rejected the ModuleSnapshot with `Error=43
  CurrentAbiMismatch`, `Stage=6 CurrentResolver`, offset 631.
- Root cause: `FAngelscriptCacheEngineEnvironmentResolver` returned both the
  exact current ABI and `CurrentValueStorageKind`. The authoritative generic
  semantic-dependency validator requires storage category to be absent; storage
  is queried separately through `IAngelscriptCacheCurrentLayoutResolver` only
  when an `EnvironmentType` is materialized as property/global storage.
- Decision/resolution: keep the environment symbol resolver single-purpose and
  return only current ABI/content authority. Do not infer or publish storage
  ownership while validating a FunctionBody `EnvironmentAbi` edge. Future
  EnvironmentType storage materialization remains owned by the existing current
  layout resolver contract.
- Required evidence: the same six-test prefix must promote the complete baseline
  and then reject deletion of either `UClass EnvironmentAbi` or owning script
  Type Declaration with `RelocationDependencyMismatch` and zero output.
- Task impact/evidence: shared environment resolver and OpenSpec only; no wire
  bytes or identity hashes change.

## IC-352 — Stable FunctionKey accepts a mismatched transient owner type

- Severity/state: V5.5 stable-identity correctness defect / closed 2026-08-10.
- Exact boundary: the new production-identity RED run
  `Saved/Tests/cache-v55-stable-symbol-owner-red-test1/20260810_222136_423_7800968b`
  built a script `FStableKeyClass::Read()` method, replaced only its transient
  builder-owned `artifactOwnerType` with the unrelated same-module
  `FStableKeyStruct`, and observed `Accepted=1` with no failure detail. The
  official prerequisite build passed at
  `Saved/Build/cache-v55-stable-symbol-owner-red-build1/20260810_222110_560_8b12d4f3`.
- Root cause: `TryBuildFunctionKey` verifies that the supplied owner belongs to
  the same module and can produce a stable TypeKey, but does not require an
  ordinary method/lifecycle function's semantic `objectType` to equal that
  owner. The resulting hash is stable but belongs to the wrong type and could
  collide with the wrong declaration family.
- Decision: validate invocation-kind-specific owner shape before hashing.
  Global functions require no type owner; factories require their explicit
  builder owner and must not silently infer an unrelated type; methods,
  constructors, destructors, generated default lifecycle functions and
  `InitDefaults` require exact equality between the semantic function
  `objectType` and `artifactOwnerType`. Any missing or mismatched transient
  metadata is non-cacheable/fail-closed rather than repaired from a name.
- Required evidence: the dedicated StableSymbolIdentity prefix must accept the
  normal global/class/struct identities, reject invalid invocation kind,
  missing owner, wrong same-module owner and a type-owned global function, and
  retain the exact `struct` versus `class` canonical TypeKey distinction. Then
  rerun the 19-product two-Engine parity using the production key builder.
- Task impact/evidence: shared Runtime stable-symbol identity builder, one
  dedicated Cache test translation unit, parity regression and verification
  notes. No persisted schema, business `.as` file or numeric FunctionId enters
  the key.

## IC-353 — Reusing one script struct name across isolated CQ methods crashes ClassGenerator reload

- Severity/state: focused-test isolation defect / closed for this fixture
  2026-08-10.
- Exact boundary: after the intentional IC-352 assertion failed, the same RED
  process advanced to a second test method that rebuilt the identical script
  struct/module fixture. It crashed in `FASStructOps::SetFromStruct` through
  `UASStruct::UpdateScriptType` and `FAngelscriptClassGenerator::PerformReload`;
  the full callstack is retained in
  `Saved/Tests/cache-v55-stable-symbol-owner-red-test1/20260810_222136_423_7800968b/Automation_2.log`.
- Root cause: `ETestEngineMode::IsolatedFull` creates a new AS Engine but the UE
  ClassGenerator surface for a generated script struct is process-owned; the
  first CQ method leaves the same named `UASStruct` visible to the second
  method's reload path. This is a fixture-name collision, not a Cache V2
  restore or runtime corruption failure.
- Decision: exercise canonical type-kind and malformed function-owner cases in
  one isolated Engine/module build, so each generated script type name is
  introduced exactly once per test process. Do not weaken the product test by
  deleting the real script-struct assertion or globally resetting unrelated UE
  generated types.
- Required evidence: the revised prefix completes without crash and reports
  both canonical type-kind assertions plus every fail-closed owner assertion.
  Existing ClassGenerator/hot-reload behavior is outside this focused fix and
  will still be covered by the later Editor lifecycle gate.
- Task impact/evidence: test organization and this issue record only; no
  production ClassGenerator behavior changes in V5.5.

## IC-354 — Unknown function-artifact type discriminator is not a recoverable rejection

- Severity/state: V5.5 corruption-safety defect / closed 2026-08-10.
- Exact boundary: while deriving exact VM runtime-state corruptions required by
  IC-343, the maintained reader audit found `asCReader::ReadTypeInfo()` accepts
  only `a/l/s/o/c/\0`, but its unknown-discriminator branch used
  `asASSERT(ch == '\0' || error)` and then returned null. An unknown type byte
  from an otherwise hash-consistent Cache V2 artifact could therefore crash an
  assertion-enabled process or silently continue as null when assertions are
  compiled out instead of producing `RejectedCorrupt`.
- Root cause: the generic bytecode reader historically treated the discriminator
  as trusted module output. Cache V2 deliberately validates untrusted/reopened
  artifact bytes, so an assertion is not a valid input-validation boundary.
- Decision: make every unknown discriminator call the reader's normal `Error`
  path and return null immediately. Extend the existing non-persisted
  `asSFunctionArtifactValidationDiagnostics` with current-stream runtime-state
  byte coordinates so focused tests can mutate stack, heap, count, first type
  and first position fields without duplicating the variable-length serializer.
  These coordinates are diagnostic observations only and do not alter the v4
  execution payload or any Cache V2 record schema.
- Required evidence: a valid artifact with real object-frame metadata must first
  report bounded in-range coordinates. Unknown type tag, invalid heap prefix,
  impossible count and invalid object position must each return
  `RejectedCorrupt`, leave the builder target at zero bytecode words, invoke the
  authoritative compiler exactly once and still execute the expected result.
  The complete 19-product parity and broader maintained save/load tests must
  remain green.
- Task impact/evidence: maintained `as_restore` diagnostics/reader, a dedicated
  function-artifact corruption test file, Cache/Builder regression and this
  record. No business `.as`, persisted pointer/id, execution schema version or
  ClassGenerator behavior changes.

## IC-355 — A root-class module with no user global is rejected by clean capture

- Severity/state: V5.5 ordinary-module eligibility defect / closed 2026-08-10.
- Exact boundary: the first VM corruption run
  `Saved/Tests/cache-v55-vm-corruption-test1/20260810_223600_277_96bd8bb6`
  compiled a normal script class plus `int Answer()` but no user global. The
  authoritative compile succeeded; clean capture returned `NotCacheable`, zero
  records and detail `Generated=1 User=<none> PureConstant=0 DefaultInit=0
  HasInitFunction=0` before the corruption matrix could start.
- Root cause: the initial root-class vertical correctly recognizes the one
  generated `__StaticType_*` helper but also hard-requires exactly one user
  pure-constant global. ModuleState and ModuleInterface already support empty
  global arrays; the capture adapter nevertheless unconditionally constructed
  and referenced one Global declaration/schema/hard value.
- Decision: support zero or one user global in this vertical. The generated
  StaticClass helper remains derived/non-public and still must occur exactly
  once. When no user global exists, emit an empty but normally hashed
  ModuleState, omit the Global declaration and dependency resolver row, and
  preserve all type/property/function authorities. Do not manufacture a dummy
  global or expose `__StaticType_*` as a public cache entity.
- Required evidence: the no-user-global class fixture must promote a complete
  graph, select the exact `Answer()` FunctionBody by production StableKey and
  reach the VM corruption matrix. Existing one-const-global fixtures and the
  generated StaticClass dependency matrix must remain green, followed by full
  Cache regression.
- Task impact/evidence: production clean-capture optional-global branch, the
  dedicated corruption fixture, generated-symbol regressions and OpenSpec. No
  persisted schema/version or business `.as` source changes.

## IC-356 — VM corruption fixture default-declared a null script-class handle

- Severity/state: focused-test source defect / fixed 2026-08-10.
- Exact boundary: after IC-355 allowed the no-user-global module to capture seven
  records, the second run
  `Saved/Tests/cache-v55-vm-corruption-test2/20260810_223858_574_cc617f33`
  reached fallback compilation but `Answer()` raised `Null pointer access` at
  its property read. The inline fixture used
  `FArtifactCorruptionLeaf Leaf;`, which is a null script-class handle rather
  than an object construction.
- Decision/resolution: explicitly construct the local with
  `FArtifactCorruptionLeaf Leaf = FArtifactCorruptionLeaf();`. Retain the class
  local because its object-frame metadata is the subject of IC-343/IC-354; do
  not switch to a primitive-only fixture that would make the corruption offsets
  vacuous.
- Required evidence: normal producer and compiler-fallback execution both return
  `42`, and the diagnostic reports at least one object-variable row before all
  eight mutations are asserted.
- Task impact/evidence: one inline AS test fixture and this record only; no
  project/business `.as` or production language semantics change.

## IC-357 — Generated zero-argument factory dependency has no public resolver row

- Severity/state: V5.5 ordinary-class construction dependency defect / closed
  2026-08-10.
- Exact boundary: after IC-355 and IC-356 let the object-frame corruption fixture
  compile and execute normally, the third focused run
  `Saved/Tests/cache-v55-vm-corruption-test3/20260810_224057_314_56f0e50c`
  stopped before artifact selection. Clean capture returned `NotCacheable` with
  builder dependency error `64` (`CurrentSymbolMissing`) for `Answer()` in the
  expression
  `FArtifactCorruptionLeaf Leaf = FArtifactCorruptionLeaf();`. The compiler
  records a signature dependency on the implementation-generated zero-argument
  Factory, while `FCleanCaptureBuildDependencyResolver` originally exposed only
  user functions, local type/property/global declarations, generated
  `StaticClass` derivations and environment authorities.
- Root cause: the generated zero-argument Factory is not an independently
  authored public script declaration in this narrow clean graph. Its signature
  is completely derived from the owning local script type, but capture and
  opaque relocation had only encoded the equivalent derived-owner rule for
  `StaticClass`. Persisting the generated Factory as a public Function
  Declaration solely to satisfy this compiler edge would duplicate type-owned
  identity and create a false invalidation unit.
- Decision/resolution: normalize only a generated, zero-parameter Factory whose
  return type and `artifactOwnerType` are the same current-module local type to
  that owning Type Declaration. Apply the same rule in actual compiler
  dependency capture and Function Artifact opaque relocation validation, so the
  persisted edge and reopened-current-symbol proof cannot disagree. Keep
  ordinary and parameterized factories as real Function artifacts with their
  own production Stable FunctionKey; this derived dependency rule must not
  collapse the eight supported invocation families or remove Factory routing
  from StaticJIT.
- Diagnostic correction: the initial implementation additionally required
  `asTRAIT_GENERATED_FUNCTION`, but the official focused probe
  `Saved/Tests/cache-v55-vm-corruption-test5/20260810_224937_830_e8ecbf26`
  proved the actual dependency is `Kind=Signature`, `Ref=Function`,
  `Invocation=Factory`, zero parameters, same current module and equal owner /
  return type while `Generated=0`. AngelScript synthesizes this Factory callable
  without publishing that trait. The corrected predicate therefore uses the
  structural Factory metadata above and does not rely on the absent trait;
  parameterized factories and every non-Factory callable remain excluded.
- Required evidence: the no-user-global class fixture must promote its seven
  records, locate `Answer()` by the production Stable FunctionKey and enter all
  eight hash-consistent VM corruption mutations. Every mutation must report
  `RejectedCorrupt`, leave the target at zero bytecode words, invoke the normal
  compiler exactly once and execute `42` afterward. The symbol dependency
  matrix, 19-artifact/two-Engine invocation parity and restore-hook fallback
  suites must remain green, followed by complete Cache and affected Builder
  regressions.
- Task impact/evidence: production clean-capture dependency resolution, Runtime
  opaque Function Artifact relocation validation, the existing focused
  corruption fixture and OpenSpec evidence. No persisted schema/version,
  business `.as` source or public StaticJIT Provider API changes.

## IC-358 — Factory metadata probe had one excess closing parenthesis

- Severity/state: focused-test diagnostic build defect / fixed 2026-08-10.
- Exact boundary: the first probe build
  `Tools\RunBuild.ps1 -Label cache-v55-generated-factory-metadata-probe-build1
  -TimeoutMs 1800000 -NoXGE` failed in
  `Saved/Build/cache-v55-generated-factory-metadata-probe-build1/20260810_224840_914_ddf43a13`
  with MSVC `C2059` at
  `AngelscriptCacheFunctionArtifactCorruptionTests.cpp:221`; the newly added
  `Test.AddInfo(FString::Printf(...))` expression closed one parenthesis too
  many. UBT exited before linking, so this run contains no product runtime
  evidence and does not change IC-357's diagnosis.
- Decision/resolution: remove only the excess delimiter and retain the detailed
  dependency probe. Do not alter production resolution conditions until the
  probe prints the actual dependency kind and Factory metadata.
- Required evidence: the corrected test translation unit must compile through
  the official wrapper, and the rerun must emit dependency kind, reference kind,
  generated trait, invocation kind, parameter count, module ownership, owner,
  return type and object type before clean capture.
- Task impact/evidence: one test-only punctuation correction and this issue
  record; no Runtime, maintained-fork, schema or business `.as` behavior change.

## IC-359 — Invocation-family parity bypasses the production clean graph envelope

- Severity/state: V5.5 production-admission gap / closed 2026-08-11.
- Exact boundary: the maintained writer/reader/restore oracle now passes all 19
  products and eight stable invocation families across two independently
  initialized Engines, but
  `AngelscriptCacheInvocationFamilyParityTests.cpp` constructs the surrounding
  `FAngelscriptCachedFunctionBody` coordinates directly before calling the real
  codec and hook. The production
  `CaptureRootClassPrimitiveVertical` still requires
  `ClassDesc->Methods.IsEmpty()`, rejects a second user function, constructs one
  GlobalFunction declaration/body/debug tuple and publishes exactly one
  FunctionBody link in its ModuleSnapshot. Therefore the current Cache service
  input cannot yet persist or graph-select the already-proven Method,
  Constructor, Destructor, Factory, GeneratedDefaultConstructor,
  GeneratedDefaultDestructor and InitDefaults artifacts.
- Decision: retain the codec/VM parity as necessary lower-level evidence, but do
  not mark V5.5 complete from it. Add a dedicated production clean-capture
  invocation-family test, then widen the root-class producer to enumerate stable
  cacheable functions from the compiled module, build their declarations from
  the shared production Stable FunctionKey authority, resolve all actual
  dependencies against a complete current-module function/type/property/global
  table, serialize one FunctionBody plus DebugSidecar per admitted invocation and
  publish every link through the normal validated ModuleSnapshot. Public-single
  and lambda remain explicit `NotCacheable` unless their full stable coordinates
  are available; do not invent identities or relax graph validation.
- Required evidence: at least one generated/default class fixture and one
  explicit lifecycle fixture must pass normal clean capture and collectively
  publish all eight stable invocation kinds with exact declaration owners,
  unique Stable FunctionKeys and graph-owned body/debug links. Reopened immutable
  graphs must drive the existing per-invocation restore hook in a second Engine,
  preserve semantic/VM/behavior parity and compile zero restored invocations.
  Missing/duplicate/wrong-owner function declarations and one omitted dependency
  must fail before promotion. Complete Cache and Compiler.Builder regressions
  remain mandatory before V5.5 closes.
- Resolution evidence: production Clean Capture now enumerates the complete
  admitted module function table and publishes one declaration/body/debug tuple
  for every stable invocation. The generated/default and explicit-lifecycle
  fixture passed `1/1` at
  `Saved/Tests/cache-v55-final-production-graph-evidence/20260810_235742_130_edd0c1ca`;
  its graph contains all eight invocation kinds with unique Stable FunctionKeys
  and exact dependency-owned links. Reopened validated-graph lookup passed `2/2`
  at
  `Saved/Tests/cache-v55-final-validated-graph-lookup-evidence/20260810_235834_804_a721299d`,
  and the independent 19-product/two-Engine restore oracle passed `1/1` at
  `Saved/Tests/cache-v55-final-parity-evidence/20260810_235659_719_5a33fb38`.
  This composition deliberately leaves the generic Current Authorities/lifecycle
  service to V6 rather than duplicating it in a V5.5-only fixture.
- Task impact/evidence: production clean capture and dedicated Cache tests first;
  common codecs, Store format and business `.as` files do not change unless the
  executable RED proves a deeper maintained-fork metadata gap.

## IC-360 — First production-family RED used TCHAR module/source parameters

- Severity/state: focused-test integration build defect / fixed 2026-08-10.
- Exact boundary: the official build
  `Tools\RunBuild.ps1 -Label cache-v55-production-invocation-graph-red-build1
  -TimeoutMs 1800000 -NoXGE` failed at
  `Saved/Build/cache-v55-production-invocation-graph-red-build1/20260810_230445_122_199d1358`
  with MSVC `C2664`. The new test helper passed `const TCHAR*` for both
  parameters, while `FAngelscriptTestFixture::BuildModule` requires an ANSI
  `const char*` module name and `const FString&` source. UBT stopped before link,
  so this is not IC-359's intended product behavior RED.
- Decision/resolution: keep the helper's human-readable label as `TCHAR`, change
  only the module-name parameter to `const char*`, and pass explicit `FString`
  source values. Do not change production clean capture from a compile-only
  failure.
- Required evidence: the corrected Editor target links, discovers exactly the
  dedicated production-family test and then fails at a logged production
  capture/admission assertion rather than at C++ compilation.
- Task impact/evidence: one new test translation unit and this issue record only;
  no Runtime, maintained-fork, schema or business `.as` behavior change.

## IC-361 — Primitive-only root class does not emit a generated default destructor

- Severity/state: V5.5 production-family fixture and TypeSchema breadth gap /
  closed 2026-08-11.
- Exact boundary: the official behavior RED
  `Saved/Tests/cache-v55-production-invocation-graph-red-test1/20260810_230603_960_c917dc61`
  compiled the generated/default fixture successfully and logged real maintained-
  fork functions for Method (`2`), Factory (`5`), GeneratedDefaultConstructor
  (`6`), InitDefaults (`8`) and GlobalFunction (`1`), but no
  GeneratedDefaultDestructor (`7`). The fixture owns only a primitive `int`
  property, whose storage requires no destructor. The direct 19-product parity
  fixture observed kind `7` only when its owner contained a non-trivial script-
  class value. Production root-class capture currently admits exactly one class
  and maps only primitive `int` properties, so it cannot yet construct the same
  real builder condition through its normal TypeSchema path.
- Decision: do not fabricate a default destructor, mutate invocation metadata or
  weaken the eight-family requirement. First widen the one-root producer to
  publish every stable function that the actual module already owns. Then add a
  destructor-requiring property shape whose stable type/property/layout authority
  is represented by the production TypeSchema path; extend the maintained fork or
  clean-capture TypeSchema seam if the real builder evidence requires it.
- Required evidence: a normal source fixture must make the maintained builder emit
  a module-owned function with invocation kind
  `asBUILD_ARTIFACT_INVOCATION_GENERATED_DEFAULT_DESTRUCTOR`; production clean
  capture must assign it the shared stable FunctionKey, exact type owner,
  Generated trait, FunctionBody and DebugSidecar, and the reopened graph must
  restore it in a second Engine. The primitive-only fixture must remain accepted
  without a synthetic destructor.
- Resolution evidence: the production fixture now owns a real inline `FString`
  value, so the maintained builder naturally emits the generated default
  destructor and the production EnvironmentType/property/layout path admits it;
  no invocation was fabricated. The all-family production graph passed `1/1` at
  `Saved/Tests/cache-v55-final-production-graph-evidence/20260810_235742_130_edd0c1ca`,
  while the primitive fixture remains valid. The maintained codec/hook then
  restored the destructor and all other products in the separately initialized
  consumer Engine at
  `Saved/Tests/cache-v55-final-parity-evidence/20260810_235659_719_5a33fb38`.
- Task impact/evidence: the production invocation-family fixture, root-class
  function-table capture and possibly the smallest coherent TypeSchema/property
  or maintained-builder metadata seam. No business `.as` source, persisted
  numeric FunctionId or test-only invocation substitution is authorized.

## IC-362 — Generated invocation canonical source was callback-only metadata

- Severity/state: V5.5 maintained-builder persistence gap / closed 2026-08-11.
- Exact boundary: the production RED log in
  `Saved/Tests/cache-v55-production-invocation-graph-red-test1/20260810_230603_960_c917dc61`
  reports `CanonicalSourceBytes=0` for Factory, GeneratedDefaultConstructor and
  InitDefaults even though `asCBuilder::BuildArtifactInvocation` derives a
  non-empty canonical token slice from the owning class declaration and passes it
  to the compile/restore callbacks. Authored functions retain their node slice at
  registration, but generated lifecycle functions have no authored function node;
  the invocation-local source is discarded after compilation and later production
  clean capture cannot reconstruct the exact `FunctionSourceDigest` authority.
- Decision: persist the finalized invocation's canonical source on the exact
  `asCScriptFunction::scriptData` at the common builder compile boundary for every
  cacheable invocation. The Runtime producer must consume this maintained-fork
  authority and must not tokenize source again, copy one generated function's
  digest to another or synthesize a test-only string. Keep invocation kind in the
  source-digest domain so lifecycle functions sharing the class token slice remain
  distinct.
- Required evidence: the production fixture must log non-zero retained canonical
  source for every admitted generated invocation; forced-clean and reopened-
  Engine compilation must derive the same source digest from the builder callback
  and persisted FunctionBody. Existing builder descriptor/ineligibility tests and
  complete Compiler.Builder regression must remain green.
- Resolution evidence: the common maintained-builder boundary now retains the
  finalized canonical invocation source on the exact function `scriptData`, and
  production Clean Capture consumes that authority directly for generated
  Factory/default lifecycle/InitDefaults products. The production graph run above
  validates every resulting FunctionSourceDigest; UE BuilderIntegration passed
  `2/2` at
  `Saved/Tests/cache-v55-final-compiler-builder-regression/20260811_002611_964_b1f145b6`,
  and native AngelScriptSDK Compiler.Builder passed `64/64` at
  `Saved/Tests/cache-v55-final-native-sdk-builder-regression/20260811_002706_535_578818cd`.
- Task impact/evidence: the maintained fork's common builder artifact boundary,
  production clean capture and focused logging. No source language, persisted
  schema version, business `.as` file or Runtime retokenization path changes.

## IC-363 — First complete production graph exposed an undeclared artifact relocation edge

- Severity/state: V5.5 production Function Artifact dependency-closure gap /
  closed 2026-08-11.
- Exact boundary: after the complete function-table producer and IC-362 source
  retention built successfully, the official focused run
  `Saved/Tests/cache-v55-production-function-table-test1/20260810_231700_213_40dbf473`
  logged non-zero canonical source for Method, GeneratedDefaultConstructor,
  Factory, InitDefaults and GlobalFunction and advanced through declaration/body
  construction. Final atomic graph promotion rejected the candidate with
  `RelocationDependencyMismatch` (`Error=47`, FunctionBody, OpaqueCodec, byte
  offset `109`): artifact symbol use `0`, kind `1`, referenced stable key
  `dc48fa6cccae1669c3042fd347e38343584b636017d010b1e9ffe0befdf894da`
  without an equal declared stable dependency. No records were promoted.
- Decision: keep the opaque validator strict. Identify the exact owning function,
  artifact symbol kind and compiler observation that should authorize this use;
  then make the maintained writer/dependency capture or production resolver emit
  one matching semantic edge. Do not append dependencies by scanning opaque bytes
  after compilation and do not relax `RelocationDependencyMismatch`.
- Required evidence: focused diagnostics must associate every artifact symbol use
  with its exact stable dependency before serialization, the generated fixture
  must promote atomically, and deleting or changing that one dependency must still
  reproduce the typed graph rejection. Existing symbol-dependency corruption and
  VM corruption suites remain green.
- Resolution evidence: maintained compiler dependency capture now emits the
  intrinsic owning ScriptType Declaration edge before serialization; opaque
  relocation validation remains strict. The all-family production graph passed,
  and `SymbolDependencyValidation` passed `6/6` at
  `Saved/Tests/cache-v55-ic370-symbol-dependency-focused1/20260811_001723_002_010b82a6`.
  Removing the exact dependency still rejects atomically as Error `47` at
  OpaqueCodec with graph/output count zero.
- Task impact/evidence: maintained Function Artifact diagnostics/dependency capture
  or the production stable resolver, plus focused logs and this issue. No schema
  version, business `.as` source or post-hoc opaque dependency invention.

## IC-364 — Production-family test retained DTO pointers after decoded handles died

- Severity/state: focused-test ownership defect / fixed 2026-08-10.
- Exact boundary: after IC-363's intrinsic owner dependency let the generated
  production graph pass opaque relocation validation, the official run
  `Saved/Tests/cache-v55-intrinsic-owner-dependency-test1/20260810_232209_771_bfb70432`
  crashed with an access violation at
  `AngelscriptCacheCleanCaptureInvocationFamilyTests.cpp:384`. `CaptureCase`
  stored raw `ModuleInterface`, `ModuleSnapshot` and `FunctionBody` pointers from
  a loop-local immutable decoded-record handle; each handle was destroyed at the
  end of its iteration, so the later declaration/body cross-check dereferenced
  released backing storage. This is test ownership, not Runtime graph mutation.
- Decision/resolution: retain every `FAngelscriptDecodedCacheRecordHandle` for the
  whole assertion scope and derive DTO pointers from those retained handles. Keep
  Runtime decoded records immutable; do not copy DTOs merely to conceal lifetime
  rules and do not weaken the body/declaration cross-check.
- Required evidence: the same focused run must complete without a process crash,
  report the generated graph envelope/body logs, and either pass or fail at the
  next explicit semantic assertion. Subsequent complete Cache regression must
  show no crash.
- Task impact/evidence: one focused test ownership fix and this issue only; no
  Runtime, maintained-fork, schema or business `.as` behavior change.

## IC-365 — Environment value lifecycle functions had no stable Cache identity

- Severity/state: V5.5 environment-function relocation gap / closed 2026-08-11.
- Exact boundary: adding a real inline `FString` member made the maintained builder
  emit GeneratedDefaultDestructor and let the production TypeSchema admit the
  environment value, but the official run
  `Saved/Tests/cache-v55-environment-value-property-test1/20260810_232829_289_13a29b30`
  stopped while capturing the generated default constructor with
  `CurrentSymbolMissing` (`Error=64`). Its raw dependencies contain `FString`
  ValueLayout plus FunctionContent for `FString(const FString&inout)`; the generated
  destructor similarly contains Signature for `~FString()`. The current environment
  identity/resolver exposes registered types only, while the build resolver and
  opaque function-symbol validator assume every non-derived function is a local
  script FunctionKey.
- Decision: add a pointer-free `EnvironmentSymbol` identity and ABI for application-
  registered functions/behaviours. Key it from canonical owner/type and declaration
  coordinates; commit VM calling-interface-relevant traits into its ABI. Normalize
  external Signature and FunctionContent compiler observations to EnvironmentAbi,
  because current native/system function code is routed by the current Engine and
  does not become a persisted script FunctionBody. Teach current-Engine resolution
  and opaque relocation validation the same single authority. Do not persist native
  pointers, numeric FunctionIds or manufacture a script Function declaration.
- Required evidence: generated `FString` constructor/destructor uses must resolve to
  exact environment references in actual dependencies and opaque relocation
  summaries, the production graph must publish all eight stable script invocation
  families, and removing/wrong-ABI/ambiguous environment functions must fail closed.
  Existing environment-type, symbol-dependency and invocation parity suites remain
  green across two Engines.
- Resolution evidence: `FString(const FString&inout)` and `~FString()` now receive
  pointer-free EnvironmentSymbol Key+ABI identities; actual FunctionContent and
  Signature observations normalize to EnvironmentAbi and resolve uniquely from
  the current Engine. The production-family run reports one stable candidate,
  one object match and equal current ABI for each referenced environment function
  before publishing all eight script families. A production mutation removes a
  real EnvironmentAbi dependency and fails OpaqueCodec closure; the dedicated
  current-symbol graph matrix independently proves missing and wrong-ABI
  EnvironmentSymbol authorities reject atomically as `CurrentSymbolMissing` and
  `CurrentAbiMismatch`. The production resolver resets its match and returns no
  authority as soon as a duplicate stable key is observed, so ambiguity reaches
  the same fail-closed missing-authority path; normal AngelScript registration
  rejects duplicate exact declarations before this defensive branch can be formed
  through public APIs. The final production graph, two-Engine parity and complete
  `442/442` Cache regression provide the combined evidence.
- Task impact/evidence: environment identity/resolver, clean build-dependency
  resolver, Function Artifact relocation validation and focused tests. No business
  `.as` source, persisted numeric FunctionId or external function body cache.

## IC-366 — UE function caller is a tagged wrapper, not a nullable pointer

- Severity/state: maintained-fork environment ABI compile boundary / fixed
  2026-08-10.
- Exact boundary: the official Development Editor build
  `Tools\RunBuild.ps1 -Label cache-v55-environment-function-abi-build2
  -TimeoutMs 600000 -NoXGE` failed at
  `Saved/Build/cache-v55-environment-function-abi-build2/20260810_233554_568_e475af94`.
  `AngelscriptCacheEnvironment.cpp:355` attempted
  `Interface.caller != nullptr`, but this maintained UE fork defines
  `asFunctionCaller` as a tagged union with `type` values `0` (unbound), `1`
  (free-function caller) and `2` (method caller); it is deliberately not a raw
  function pointer and has no null-comparison operator.
- Decision/resolution: validate the bounded `caller.type` domain and commit that
  tag to the environment-function ABI. The tag is semantically stronger than a
  presence bit because free-function and method adapters are different calling
  surfaces, while remaining pointer-free. Do not serialize `FunctionCaller`,
  `MethodCaller`, `func`, `method` or any native address.
- Required evidence: the same official build must compile, two independently
  registered Engines must derive equal environment-function references, and the
  production invocation-family test must reach the next explicit semantic
  boundary. A caller-tag difference must produce a different ABI when a focused
  fixture can register both forms.
- Task impact/evidence: one environment ABI field correction and this issue; no
  Cache schema, business `.as`, stable script FunctionKey or native-call behavior
  change.

## IC-367 — Broad patch context relocated the environment fallback into Global

- Severity/state: implementation placement defect / fixed 2026-08-10.
- Exact boundary: after the environment identity compiled, the official focused
  run
  `Saved/Tests/cache-v55-environment-function-probe-test1/20260810_233854_083_de305c9b`
  still rejected the generated default constructor with `CurrentSymbolMissing`.
  Its added probe proved `FString(const FString&inout)`, `~FString()` and
  `TSubclassOf::opImplConv` each independently produced a non-zero stable Key and
  ABI (`Resolved=1`). Source inspection then showed the earlier broad
  `if (Entry == nullptr)` patch had removed the invalid Property insertion but
  reinserted the fallback in the adjacent `FGlobalEntry` branch at line 937;
  the intended `FFunctionEntry` branch still returned false directly.
- Decision/resolution: remove the fallback from Global resolution and install it
  only after the derived zero-argument Factory normalization in the Function
  reference case. Use discriminating surrounding entry types/factory context for
  this repeated-shape switch rather than a bare `Entry == nullptr` hunk. Keep the
  focused environment probe until the production graph and two-Engine tests are
  green because it demonstrates identity construction separately from resolver
  routing.
- Required evidence: source search must show exactly one `EnvironmentFunction`
  fallback inside `asBUILD_ARTIFACT_REFERENCE_FUNCTION`; the focused production
  test must advance beyond actual dependency capture; Global missing-symbol tests
  must retain their fail-closed behavior in the complete Cache regression.
- Task impact/evidence: one resolver placement correction, focused diagnostic log
  and this issue; no semantic key/ABI, Cache schema or business `.as` change.

## IC-368 — Environment value capture had no production current-layout resolver

- Severity/state: V5.5 production TypeSchema current-authority gap / fixed
  2026-08-10.
- Exact boundary: after IC-367 let all `FString` environment function dependencies
  capture successfully, the official focused runs
  `Saved/Tests/cache-v55-environment-function-routing-test1/20260810_234037_251_f77a4fc0`
  and
  `Saved/Tests/cache-v55-current-resolver-detail-test1/20260810_234803_346_3e2bade7`
  failed graph validation with `CurrentSymbolMissing` (`Error=64`,
  `ModuleSnapshot`, `CurrentResolver`). Direct probes showed the three environment
  function identities and current resolver results were unique and ABI-equal. The
  remaining production `FCleanCaptureCurrentLayouts::ResolveDataTypeLayout()` was
  still an unconditional empty stub, so the newly admitted inline `FString Label`
  property had no current size/alignment/storage authority.
- Decision/resolution: snapshot stable environment type references and their
  current value size/alignment from the same Engine registry used by environment
  ABI identity. Resolve only exact EnvironmentType Key+ABI matches, fail closed on
  conflicting duplicate layouts, use the profile pointer constants for handles and
  current registered size/alignment for inline values. Do not trust persisted
  property sizes as their own current authority and do not add a text parser.
- Required evidence: the generated production graph must advance beyond current
  DataType layout validation, wrong/missing environment type ABI/layout remains a
  typed rejection, and focused/complete module-layout tests stay green.
- Task impact/evidence: production current-layout resolver, focused logs and this
  issue; no Cache wire version, business `.as` or reflected class mutation.

## IC-369 — Cached DataType stable reference is optional, not inline

- Severity/state: V5.5 current-layout compile correction / fixed 2026-08-10.
- Exact boundary: the official build
  `Saved/Build/cache-v55-environment-current-layout-build1/20260810_235033_213_a4f46d38`
  failed because the first IC-368 resolver implementation accessed `Kind`,
  `StableKey` and `ExpectedAbi` directly on
  `FAngelscriptCachedDataType::TypeReference`; the schema represents that field as
  `TOptional<FAngelscriptCacheStableReference>` so primitive/auto shapes can omit
  it canonically.
- Decision/resolution: require the EnvironmentType kind and a set reference before
  reading the exact EnvironmentSymbol Key/ABI. Treat an absent reference as an
  ordinary fail-closed current-layout miss. Do not fabricate a zero reference or
  weaken the local schema's optional-shape validation.
- Required evidence: the official Editor build compiles and existing absent/wrong
  TypeReference tests remain rejected while the real `FString` property resolves.
- Task impact/evidence: one optional access correction and this issue only; no wire
  format, identity domain or business `.as` change.

## IC-370 — Full Cache tests selected production functions by count or array order

- Severity/state: V5.5 full-regression test-contract defect / closed 2026-08-11.
- Exact boundary: the focused production graph, validated-graph lookup and
  two-Engine invocation parity runs passed `1/1`, `2/2` and `1/1`, but the official
  complete command `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache
  -Label cache-v55-final-complete-cache-regression -TimeoutMs 1200000` reported
  `391` success, `36` success-with-warning and `15` failures at
  `Saved/Tests/cache-v55-final-complete-cache-regression/
  20260810_235923_352_016f3c55`. All failures assumed that production Clean Capture
  still emitted one FunctionBody/DebugSidecar and seven records, or selected the
  business function by the first array element/fixed ordinal. The corrected
  production root-class graph now intentionally emits three stable functions and
  eleven records, including generated `StaticClass`/factory lifecycle products;
  mutation assertions consequently inspected an unchanged generated function and
  incremental/relocation fixtures rejected valid extra coverage.
- Decision: retain the wider production capture. Refactor tests to locate their
  subject by full StableFunctionKey or exact canonical declaration/name and assert
  required semantic subsets plus uniqueness. Fixed body/debug/record counts remain
  valid only where cardinality itself is the contract. Never recover the old green
  suite by dropping generated functions, relying on record order or weakening
  graph closure.
- Required evidence: the four affected prefixes (`CleanOracleInputMutation`,
  `CleanOracleMutation`, `FunctionDependencyIntegration`,
  `IncrementalGeneration`, `SymbolDependencyValidation`) pass independently;
  complete Cache and affected Compiler.Builder prefixes then pass with the wider
  three-function production graph. Logs must continue to show exact target keys,
  dependencies and typed fail-closed mutations.
- Resolution evidence: all affected fixtures now select the intended declaration,
  FunctionBody and DebugSidecar through its exact canonical name and full stable
  key; graph-wide cardinality assertions derive their expected complete count.
  Focused results are CleanOracle `10/10` at
  `Saved/Tests/cache-v55-ic370-clean-oracle-focused1/20260811_001357_582_a47b66a8`,
  FunctionDependencyIntegration `1/1` at
  `Saved/Tests/cache-v55-ic370-function-dependency-focused1/20260811_001543_254_09a1941c`,
  IncrementalGeneration `4/4` at
  `Saved/Tests/cache-v55-ic370-incremental-generation-focused1/20260811_001625_356_92b403fe`
  and SymbolDependencyValidation `6/6` at
  `Saved/Tests/cache-v55-ic370-symbol-dependency-focused1/20260811_001723_002_010b82a6`.
  Complete Cache passed `442/442` at
  `Saved/Tests/cache-v55-final-complete-cache-regression-after-ic370/20260811_001818_920_d42cbea4`;
  UE BuilderIntegration passed `2/2` and native SDK Builder passed `64/64` at the
  two distinct artifacts recorded above.
- Task impact/evidence: test selector/expectation refactor plus this issue and
  complete regression evidence. No Cache Runtime/schema/maintained-fork behavior,
  business `.as` source or production function ordering change.

## IC-371 — V6.1 had no per-Engine Cache service or mutation/freeze API

- Severity/state: V6.1 intended interface RED / closed 2026-08-11.
- Exact boundary: the new dedicated
  `AngelscriptCacheServiceTests.cpp` asks an isolated full Engine for its owned
  service, enters a mutation with explicit-token-only reentrancy, and freezes one
  real production Clean Capture into a self-owned successful-publication DTO.
  The official Development Editor build
  `Tools\RunBuild.ps1 -Label cache-v61-service-gate-freeze-red-build
  -TimeoutMs 1800000 -NoXGE` failed only because
  `Cache/AngelscriptCacheService.h` does not exist, at
  `Saved/Build/cache-v61-service-gate-freeze-red-build/20260811_003711_904_a417040d`.
  This is the intended missing-product interface RED; UBT exited `6` before link.
- Decision: add one Runtime-owned `FAngelscriptCacheService` instance to each
  `FAngelscriptEngine`, distinct from `CompilationLock`. Its mutation guard uses
  an ephemeral service identity/epoch/thread token; same-thread nesting requires
  the current explicit token, runtime ownership is game-thread-only after
  initialization, and shutdown closes admission before AS state is released.
  Freeze consumes only already validated pointer-free Clean Capture artifacts,
  canonicalizes module order, rejects invalid/duplicate coordinates atomically
  and exposes a thread-safe shared-const DTO that survives Engine destruction.
  Do not copy AS/UE pointers or mutable module descriptors and do not build a
  parallel test-only lifecycle service.
- Required evidence: the new focused class must link and prove service isolation,
  explicit reentry, outside-gate rejection, one monotonic transaction and DTO
  lifetime after Engine destruction. A second gate test must cover stale token,
  runtime off-thread rejection and shutdown admission. Complete Cache and Engine
  lifecycle regressions remain required before V6.1 closes; IC-292's prepared
  batch eligibility remains a separate V6.1 scaling requirement.
- Resolution evidence: each `FAngelscriptEngine` now constructs and owns exactly
  one Runtime Cache service, transitions it from initialization to game-thread
  runtime ownership and closes mutation admission before Engine teardown. The
  service uses a gate distinct from `CompilationLock`, explicit current-token
  nesting, monotonic epochs and self-owned shared-const publication DTOs. Its
  focused prefix passed `3/3` after IC-292 at
  `Saved/Tests/cache-v61-service-after-eligibility-batch/
  20260811_010005_302_7abe3a3a`: two Engine services are isolated; implicit
  nesting, stale tokens, runtime worker-thread entry and shutdown entry are
  rejected; duplicate freeze does not consume an ordinal; one real seven-record
  Clean Capture publishes transaction `1` and survives Engine destruction. The
  final complete Cache regression passed `447/447` at
  `Saved/Tests/cache-v61-final-complete-cache-regression/
  20260811_010053_272_dd500635`.
- Task impact/evidence: new Runtime Cache service files, minimal Engine ownership/
  initialization/shutdown integration, one separate Cache test translation unit
  and this issue. No Store wire version, business `.as`, StaticJIT Provider or
  legacy cache path changes.

## IC-372 — Duplicate-module negative fixture appended from its own TArray element

- Severity/state: V6.1 test-fixture ownership defect / fixed 2026-08-11.
- Exact boundary: the official focused run
  `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache.Service -Label
  cache-v61-service-gate-negative-test -TimeoutMs 600000` passed service
  isolation and stale-token/off-thread/shutdown behavior, then asserted in
  Unreal `TArray::Add` at
  `AngelscriptCacheServiceTests.cpp:178`. The test called
  `Duplicate.Modules.Add(Duplicate.Modules[0])`; growth invalidated the source
  element while copying it. The crash artifact is
  `Saved/Tests/cache-v61-service-gate-negative-test/20260811_004422_358_185da7a4`.
  Runtime freeze code was not entered for this case.
- Decision/resolution: copy the existing self-owned module DTO to a local value,
  then move that value into the array. Keep the duplicate-module Runtime
  validation and atomic latest-publication assertion unchanged.
- Required evidence: the same three-method focused prefix must complete without
  a process crash, report `DuplicateModule`, leave latest publication empty and
  then publish the valid transaction as ordinal `1`.
- Task impact/evidence: one test-only ownership correction and this issue; no
  Runtime, Store, schema, AS source or lifecycle policy change.

## IC-373 — Production source discovery repeated full eligibility preparation per module

- Severity/state: V6.1 scaling/atomicity contract RED / closed 2026-08-11.
- Exact boundary: `FAngelscriptCacheSourceDiscovery::DiscoverProductionSources`
  sorted its modules but then created one fresh read budget and called
  `QueryCurrentExactFastPathEligibility` once per module. Every call recomputed
  and validated the same SourceSnapshot and rebuilt the same preprocess-hook
  indexes, so N modules paid N full preparation passes and could not expose one
  atomic, cumulatively budgeted eligibility result. The dedicated two-method CQTest
  requests one prepared batch, single-query authority parity, deterministic output,
  atomic short-budget failure and a 64-module scaling probe. The intended official
  Development Editor RED
  `Tools\RunBuild.ps1 -Label cache-v61-eligibility-batch-red-build -TimeoutMs
  1800000 -NoXGE` exited `6` at
  `Saved/Build/cache-v61-eligibility-batch-red-build/
  20260811_004948_305_6d1be68a`: the new batch DTO and
  `QueryCurrentExactFastPathEligibilityBatch` entry point did not exist. The
  baseline V5.5 complete Cache run remained `442/442` before this missing-interface
  test was added.
- Decision: preserve the existing one-module query as the semantic authority, but
  split its implementation into reusable preparation and per-module closure work.
  The batch validates the current SourceSnapshot once, sorts and rejects zero or
  duplicate module keys, builds the immutable hook-key/reverse-dependency indexes
  once, and evaluates every module under one cumulative read budget. Candidate
  entries and matching-scope allocations remain temporary until every query
  succeeds; only then are they promoted and published. A failure clears the public
  DTO and releases all temporary resident accounting. Production discovery must
  consume this batch rather than loop the producer-side single query.
- Required evidence: the new focused prefix passes both methods; logs show
  `Prepare=1`, `IndexBuilds=1`, `Queries=64` and deterministic module order. Each
  small-batch entry must match the existing single-query authority, a one-byte-short
  total decoded budget must return `BudgetExceeded` with empty output and zero live
  resident bytes, SourceDiscovery regressions must stay green, and complete Cache
  plus Service regressions are required before V6.1 closes.
- Resolution evidence: the semantic archive now exposes an atomic producer-side
  batch. It validates the SourceSnapshot once, builds hook-key and reverse-hook
  indexes once, evaluates sorted unique modules under one cumulative Budget and
  holds entries/matching scopes in temporary reservations until all queries
  succeed. Production SourceDiscovery consumes that batch. Focused batch tests
  passed `2/2` at
  `Saved/Tests/cache-v61-eligibility-batch-test1/
  20260811_005752_583_78022a20`; the 64-module row logged `Prepare=1`,
  `IndexBuilds=1`, `Queries=64`, `DecodedBytes=405440`, peak resident `18368`
  and `ElapsedMs=0.206`. The one-byte-short run returned `BudgetExceeded` with
  empty output and zero live resident accounting. ProductionSourceDiscovery
  passed `12/12` at
  `Saved/Tests/cache-v61-eligibility-production-discovery/
  20260811_005836_411_5dd1ca03`; the unchanged single-query SourceInterface
  authority passed `43/43` at
  `Saved/Tests/cache-v61-eligibility-single-authority-regression/
  20260811_005912_395_95067cfd`; complete Cache passed `447/447` at the artifact
  recorded under IC-371.
- Task impact/evidence: one Runtime semantic-query refactor, production discovery
  routing, a separate Cache test translation unit and this issue. No SourceIndex
  wire schema, stable identity, business `.as`, Engine lifecycle or StaticJIT
  provider change.

## IC-374 — Timed-out build wrapper left a child UBT overlapping the immediate retry

- Severity/state: local verification orchestration / resolved 2026-08-11.
- Exact boundary: the first invocation of
  `Tools\RunBuild.ps1 -Label cache-v61-eligibility-batch-build1 -TimeoutMs
  1800000 -NoXGE` was itself launched through a five-second shell wait, which
  terminated the wrapper before it could return while its child UBT continued.
  The immediate second invocation used the same target and overlapped link output.
  C++ compilation completed, but both Runtime and Test import-library links failed
  with `LNK1181` while opening their own output `.lib` at
  `Saved/Build/cache-v61-eligibility-batch-build1/
  20260811_005642_243_244d99db`. The abandoned wrapper artifact is the incomplete
  sibling `20260811_005632_493_3bd0c7d0`; no matching UBT/link process remained
  after the failed retry.
- Decision/resolution: never impose a short process timeout around the official
  long-running wrapper. Let the command continue in a yielded execution cell and
  poll that cell; after confirming no matching process remains, rerun under a new
  label with the wrapper's engine serialization guard. Preserve both artifacts as
  verification-history evidence and do not delete intermediates.
- Required evidence: the serialized official rerun completes compilation and link,
  after which the focused batch CQTest determines product correctness. A repeated
  linker-output conflict would require separate diagnosis rather than another
  immediate retry.
- Task impact/evidence: OpenSpec issue and corrected command orchestration only; no
  Cache, test, Engine, AS source, intermediate-file or build-script change.

## IC-375 — Lifecycle publication fixture reused one global enum name across modules

- Severity/state: V6.2 test-fixture naming defect / fixed 2026-08-11.
- Exact boundary: the new lifecycle publication CQTest intentionally compiles
  two real Clean Capture modules in one isolated full Engine so `Current` and
  `PendingColdStart` can own different immutable source snapshots. Its first
  run declared `ECacheLifecycleMode` in both modules. ClassGenerator correctly
  rejected the second global enum as already owned by the first module, so both
  methods failed before the service state transition at
  `Saved/Tests/cache-v62-lifecycle-publication-test1/
  20260811_011848_654_b644d44a`. This was not a lifecycle-slot failure.
- Decision/resolution: keep the two real modules and complete compile/
  ClassGenerator/Clean Capture path, but derive the enum and function identifiers
  from each test module's already unique stable name. Do not weaken duplicate
  declaration validation and do not replace the second capture with fabricated
  records.
- Required evidence: the same two-method prefix must compile two distinct
  seven-record graphs, then prove independent Current/Pending slots, full
  promotion, failure atomicity and non-consuming transaction ordinals.
  `Angelscript.TestModule.Cache.LifecyclePublication` passed `2/2` at
  `Saved/Tests/cache-v62-lifecycle-publication-test2/
  20260811_011959_851_03fa9d61`; promotion logged `CurrentTx=3 Pending=0`, and
  the invalid freeze preserved pending transaction `2` before the next valid
  soft Current became transaction `3`.
- Task impact/evidence: one test-only symbol naming correction plus this issue.
  The intended missing-state RED remains the official Development Editor build
  `Saved/Build/cache-v62-lifecycle-publication-red2-build/
  20260811_011753_000_91bb88b6`; the Runtime/Test GREEN build is
  `Saved/Build/cache-v62-lifecycle-publication-fixture-fix-build/
  20260811_011943_638_bd247bee`. No cache wire format, ClassGenerator behavior,
  business `.as` source or production declaration uniqueness rule changed.

## IC-376 — Editor lifecycle had no single production Environment Profile builder

- Severity/state: V6.2 production identity gap / resolved 2026-08-11.
- Exact boundary: Compatibility, Context and Profile hash primitives existed, but
  production Editor initial compile/reload had no single builder for the actual
  engine properties, compile/preprocessor settings, target/configuration and
  logical source mounts. Tests could hand-assemble arbitrary strings, allowing
  future lifecycle call sites to disagree about the same environment or to leak
  relocatable absolute host paths into persistent identity. The intended official
  RED is `Saved/Build/cache-v62-environment-profile-red2-build/
  20260811_012452_854_b342d21a`: the dedicated test requested
  `Cache/AngelscriptCacheEnvironmentProfile.h`, which did not exist.
- Decision/resolution: add one Runtime-owned production profile builder, distinct
  from the pre-existing application-symbol `FAngelscriptCacheEnvironmentIdentity`.
  Compatibility covers versioned Cache/record/VM codecs, product/fork lineage,
  UE major/minor and machine ABI. Context covers all current AS Engine properties,
  canonical compile/preprocessor options, target/configuration and logical source
  root kind/mount only. Absolute source-root paths are discovery inputs but never
  profile identity. The builder emits the same canonical options/Profile into
  Clean Capture and production SourceDiscovery so lifecycle integration cannot
  fork those authorities.
- Required evidence: two independently initialized full Engines and relocated host
  roots with identical logical mounts must produce identical Compatibility,
  Context, Profile and compile options; changing an effective compiler option or
  logical mount must change Context/Profile while preserving Compatibility.
- Resolution evidence: after correcting implementation-only compile mistakes in
  the first GREEN attempt (record archive class name, ANSI platform conversion and
  key-wrapper comparisons), the official build passed at
  `Saved/Build/cache-v62-environment-profile-green-build2/
  20260811_012734_560_8995334c`. The focused
  `Angelscript.TestModule.Cache.EnvironmentIdentity` prefix passed `2/2`, failed/
  skipped `0/0`, at `Saved/Tests/cache-v62-environment-profile-test1/
  20260811_012753_338_01df7898`. The logs prove relocated roots retained Profile
  `c302fd986049999e851ecb6bfd3c5ebb5321166b5682190fa7ae768dced3e648`, while
  the option and logical-mount mutations produced distinct Context/Profile values.
- Task impact/evidence: one Runtime production-profile translation unit, one
  focused Cache test translation unit and this issue. No cache wire schema,
  business `.as`, StaticJIT Provider, Editor lifecycle publication or legacy cache
  path changed; V6.2 remains open until normal compile/reload invokes the service.

## IC-377 — Short outer tool waits detached otherwise valid official build wrappers

- Severity/state: local verification orchestration / resolved 2026-08-11.
- Exact boundary: while adding the production Editor lifecycle test, two official
  `Tools\RunBuild.ps1` invocations were launched with an outer execution-tool wait
  far shorter than the wrapper/build timeout. The outer invocation returned before
  the child UBT finished. The later diagnostic occurrence is preserved at
  `Saved/Build/cache-v62-typeschema-diagnostics-build1/
  20260811_014932_853_d91c2940`: its orphaned UBT compiled and linked successfully,
  but the wrapper could not finish its report, so it is not counted as formal GREEN
  evidence. Earlier `cache-v62-editor-lifecycle-red-build` attempts had the same
  orchestration defect and cannot be used as the intended behavior RED.
- Decision/resolution: wrapper `-TimeoutMs` controls the actual process lifetime;
  the execution tool must use a long command timeout plus a yielded cell that is
  polled to completion. Never retry a target until a read-only process audit proves
  the prior UBT/compiler/link children have exited. Preserve incomplete artifacts
  instead of deleting or relabelling them.
- Required evidence: a later full official wrapper must return its own final exit
  status and metadata under a distinct label before any build success claim. The
  complete wrapper build passed at
  `Saved/Build/cache-v62-typeschema-property-diagnostics-build1/
  20260811_015119_095_88930bc9`; the final cold-property correction build passed at
  `Saved/Build/cache-v62-editor-lifecycle-cold-property-fix-build1/
  20260811_015330_778_a5707032`.
- Task impact/evidence: command orchestration and this issue only. No Runtime,
  test, build-script, Cache schema, AS source or intermediate-file cleanup change.

## IC-378 — PIE soft reload leaked installed-UClass state into the cold candidate

- Severity/state: V6.2 lifecycle/cold-schema correctness defect / fixed
  2026-08-11.
- Exact boundary: the first expanded production-lifecycle run passed initial
  publication but failed the intentional compile-error and PIE structural cases at
  `Saved/Tests/cache-v62-editor-lifecycle-expanded-test1/
  20260811_014517_714_fac2bf12`. The compile-error assertions were semantically
  correct but had not registered expected UE log errors. After fixing that fixture,
  the PIE candidate still failed TypeSchema serialization with generic
  `InvalidQualifierCombination`. A new C++ diagnostic serializer narrowed this to
  `Field=OrderedProperty Primary=1`; the focused diagnostic run at
  `Saved/Tests/cache-v62-editor-lifecycle-property-diagnostics-test1/
  20260811_015145_666_89548407` reported `Property=ExtraValue TypeKind=1
  Qualifiers=0x0 Storage=1 Offset=52 Size=4 Alignment=4 Flags=0x1e`.
- Root cause: ClassGenerator soft reload deliberately sets
  `FAngelscriptPropertyDesc::bHasUnrealProperty=false` for a newly declared
  property because the currently installed PIE UClass cannot gain that FProperty.
  The remaining descriptor flags still describe its valid future reflection shape.
  Clean Capture incorrectly treated that live-installed bit as cold-start schema
  authority, producing Blueprint/edit flags without `HasUnrealProperty` and
  correctly tripping the TypeSchema invariant.
- Decision/resolution: do not weaken the TypeSchema invariant. Every descriptor in
  `FAngelscriptClassDesc::Properties` is the authoritative explicit or GC-required
  FProperty declaration for a clean/cold build; use descriptor presence for the
  persisted `HasUnrealProperty` flag. Keep the mutable descriptor bit as live
  ClassGenerator state only. Add `SerializeTypeSchemaWithDiagnostics` and make
  Clean Capture failures include the stable field coordinate plus bounded property
  layout/flag context, so future live C++ diagnostics identify the precise row.
  Register the deliberately generated compiler errors as expected test output;
  last-good assertions remain unchanged.
- Required evidence: initial compile publishes Current; invalid full reload retains
  the exact Current DTO and active ScriptModule; PIE structural soft reload publishes
  a distinct PendingColdStart without replacing Current; the following full reload
  promotes the same new source snapshot and clears Pending. The focused structural
  method passed at
  `Saved/Tests/cache-v62-editor-lifecycle-cold-property-fix-test1/
  20260811_015347_280_23225e93` with `Tx1 Current -> Tx2 Pending -> Tx3 Current`.
  The complete EditorLifecycle prefix passed `3/3` at
  `Saved/Tests/cache-v62-editor-lifecycle-green-test2/
  20260811_015431_384_b07ec6cd`; LifecyclePublication passed `2/2` at
  `Saved/Tests/cache-v62-lifecycle-publication-regression-test1/
  20260811_015518_357_51294345`; EnvironmentIdentity passed `2/2` at
  `Saved/Tests/cache-v62-environment-identity-regression-test1/
  20260811_015559_701_a86029f8`. The complete Cache prefix passed `454/454`,
  failed/not-run `0/0`, at
  `Saved/Tests/cache-v62-final-complete-cache-regression/
  20260811_015846_712_b29b54a9`, closing V6.2.
- Task impact/evidence: one production cold-schema authority correction, one
  reusable C++ TypeSchema diagnostic entry point, richer capture failure context,
  one separate Editor lifecycle test file and this issue. No wire-version bump,
  legacy cache path, business `.as`, StaticJIT Provider or live UClass mutation.

## IC-379 — Diagnostics test helper collided with RenderCore's Freeze namespace

- Severity/state: V6.3 test compile naming defect / fixed 2026-08-11.
- Exact boundary: after the intended missing-interface RED, the first C++
  diagnostics GREEN build compiled and linked the new Runtime diagnostics files but
  failed the separate test translation unit because its local helper `Freeze(...)`
  was ambiguous with RenderCore's global `namespace Freeze`. The official artifact
  is `Saved/Build/cache-v63-cpp-diagnostics-green-build1/
  20260811_021134_661_694def5d`; no Runtime diagnostic error was reported.
- Decision/resolution: rename only the test helper to `FreezePublication`, matching
  its operation and avoiding engine-wide symbols. Do not hide the RenderCore
  namespace, qualify unrelated headers or rename the production service method.
- Required evidence: the official build must compile/link Runtime and Test, and the
  focused diagnostics prefix must exercise both empty and real published snapshots.
  The build passed at `Saved/Build/cache-v63-cpp-diagnostics-green-build2/
  20260811_021209_960_db233cbb`; `Angelscript.TestModule.Cache.Diagnostics` passed
  `2/2` at `Saved/Tests/cache-v63-cpp-diagnostics-test1/
  20260811_021226_411_f6bf74f7`.
- Task impact/evidence: one test-local symbol rename and this issue. No Cache DTO,
  JSON schema, Store, Engine lifecycle, AS source or public API behavior changed.

## IC-380 — Shutdown settings test used CQTest strict equality for a double

- Severity/state: V6.3 test compile defect / fixed 2026-08-11.
- Exact boundary: UHT and Runtime compilation accepted the new default-config
  settings and Engine shutdown integration, but the first intended GREEN build
  failed only because CQTest deliberately rejects strict `AreEqual` for floating
  values. The official artifact is `Saved/Build/
  cache-v63-settings-shutdown-green-build1/
  20260811_023441_104_21c6c3d8`.
- Decision/resolution: keep the production default at `5.0` seconds and change the
  test assertion to `IsNear(..., 0.0001)`. Do not weaken CQTest's floating-point
  comparison rule or encode the timeout as an integer merely for the test.
- Required evidence: the corrected official build passed at `Saved/Build/
  cache-v63-settings-shutdown-green-build2/
  20260811_023729_008_f87ee55e`.
- Task impact/evidence: test assertion only. No settings value, shutdown behavior,
  cache schema, Store transaction or production timing semantics changed.

## IC-381 — Shutdown test retained a raw Service pointer past Engine teardown

- Severity/state: V6.3 test lifecycle crash / fixed 2026-08-11.
- Exact boundary: the first settings/shutdown run reached the real production
  shutdown flush and logged `CurrentCommit=2`, then crashed because the test
  dereferenced its raw `FAngelscriptCacheService*` after
  `FAngelscriptEngine::Shutdown()` had correctly reset the Engine-owned Service.
  The crash artifact is `Saved/Tests/cache-v63-settings-shutdown-test1/
  20260811_023748_958_da75e05a/Automation.log`.
- Decision/resolution: preserve production lifetime ownership. Capture only the
  immutable generation/stable coordinates needed by the assertion before
  shutdown, then reopen and validate the persisted Current pointer from disk after
  shutdown. Do not extend Service lifetime or make Engine shutdown retain a stale
  diagnostics object for test convenience.
- Required evidence: the corrected build passed at `Saved/Build/
  cache-v63-settings-shutdown-test-lifetime-fix-build1/
  20260811_023903_205_c3ad0259`; the focused settings/shutdown prefix then passed
  `2/2`, failed/skipped `0/0`, at `Saved/Tests/
  cache-v63-settings-shutdown-test2/
  20260811_023924_670_5f56bc34`.
- Task impact/evidence: one test-lifetime correction and this issue record. No
  Engine/Service ownership, shutdown order, cache data or public API was changed.

## IC-382 — Diagnostic API forward declaration disagreed with Engine's struct tag

- Severity/state: V6.3 C++ compile declaration defect / fixed 2026-08-11.
- Exact boundary: after the intended missing-API RED, the first GREEN build passed
  UHT and reached Runtime/Test compilation, then MSVC C4099 rejected the new
  `class FAngelscriptEngine;` declaration because the authoritative Engine type is
  declared as `struct FAngelscriptEngine`. The artifact is `Saved/Build/
  cache-v63-debug-api-green-build1/
  20260811_024701_875_639c416d`.
- Decision/resolution: match the existing Runtime-wide forward-declaration pattern
  and change only the tag to `struct`. Do not include the large Engine header in the
  public diagnostics header merely to hide an incorrect declaration.
- Required evidence: the corrected official build passed at `Saved/Build/
  cache-v63-debug-api-green-build2/
  20260811_024811_892_09db3e49`; the focused DebugApi prefix passed `2/2`,
  failed/skipped `0/0`, at `Saved/Tests/cache-v63-debug-api-test1/
  20260811_024834_179_21aa0921`.
- Task impact/evidence: one declaration-tag correction and this issue record. No
  diagnostic schema, Engine layout, cache lifecycle or public behavior changed.

## IC-383 — Python test wrapper deadlocked when RED failures filled stderr

- Severity/state: V6.3 diagnostic test-infrastructure deadlock / fixed
  2026-08-11.
- Exact boundary: two new session-correlation RED tests caused
  `Tools/RunCacheV2DumpTests.ps1` to exceed both 120-second and 300-second outer
  limits at `Saved/Tests/cache-v63-python-session-correlation-red1` and
  `Saved/Tests/cache-v63-python-session-correlation-red2` without emitting
  unittest lines. Running the same complete 18-test command directly completed in
  `0.265s` with exactly the two expected missing-argument failures.
- Root cause/decision: the wrapper synchronously drained redirected stdout to EOF
  before reading stderr. Verbose unittest failures filled the stderr pipe, so the
  child waited for a reader while the parent waited for child/stdout completion.
  Start `ReadToEndAsync()` on both streams before `WaitForExit()` and retrieve both
  results afterward. Do not reduce unittest verbosity, truncate failures or rely on
  larger OS pipe buffers.
- Required evidence: with only the wrapper fix applied, the real RED returned in
  `0.261s` and reported exactly `18` tests / `2` expected failures at
  `Saved/Tests/cache-v63-python-session-correlation-red3`. After implementing
  correlation, the same wrapper completed normally with `18/18 PASS` at
  `Saved/Tests/cache-v63-python-session-correlation-green1`.
- Task impact/evidence: one repository-wrapper concurrency fix, two Python
  correlation tests and this issue. Cache files, C++ diagnostic schema, runtime
  selection and Store semantics were not changed by the wrapper fix.

## IC-384 — Status-file test used the wrong FStringOutputDevice header

- Severity/state: V6.3 test compile dependency defect / fixed 2026-08-11.
- Exact boundary: the first status-file RED build failed before exercising the
  intended console behavior because the new test included `Misc/OutputDevice.h`
  while `FStringOutputDevice` is declared by `Misc/StringOutputDevice.h`. The
  artifact is `Saved/Build/cache-v63-status-json-file-red-build1/
  20260811_030307_075_2a8a2a28`.
- Decision/resolution: follow the existing Actor test pattern and include the
  specific `Misc/StringOutputDevice.h`; do not add a local output-device test
  double or broaden Runtime includes.
- Required evidence: the corrected test-only build passed at `Saved/Build/
  cache-v63-status-json-file-red-build2/
  20260811_030331_623_bd857186`, after which the focused prefix reached the real
  behavior RED (`2/3 PASS`, file load failed because `Json=` was unsupported) at
  `Saved/Tests/cache-v63-status-json-file-red-test1/
  20260811_030350_557_dcdf2fe7`. The GREEN build/test passed at `Saved/Build/
  cache-v63-status-json-file-green-build1/
  20260811_030509_809_e594a287` and `Saved/Tests/
  cache-v63-status-json-file-green-test1/
  20260811_030523_929_dd396a76` (`3/3`).
- Task impact/evidence: one test include correction and this issue record. No
  Runtime behavior changed as part of the correction.

## IC-385 — UE 5.8 has no `Misc/LexFromString.h` include path

- Severity/state: V6.3 Runtime compile dependency defect / fixed 2026-08-11.
- Exact boundary: after the intended missing-Flush-API RED, the first GREEN build
  reached Runtime compilation and failed only because the new console adapter
  included `Misc/LexFromString.h`. UE 5.8 declares `LexTryParseString` through
  `Containers/UnrealString.h.inl`, already provided by this translation unit's
  Core include chain; the requested `Misc` header does not exist. The artifact is
  `Saved/Build/cache-v63-flush-api-green-build1/
  20260811_032449_224_9a80781d`.
- Decision/resolution: follow existing Runtime callers and remove the nonexistent
  include while retaining `LexTryParseString` for strict positive finite timeout
  parsing. Do not replace typed parsing with permissive `Atod`, add a local parser,
  or add an Engine-private header dependency.
- Required evidence: the corrected official build passed at `Saved/Build/
  cache-v63-flush-api-green-build2/
  20260811_032527_791_d362b2cf`; after centralizing root resolution, the final
  build remained GREEN at `Saved/Build/cache-v63-flush-api-refactor-build1/
  20260811_032658_223_1165bcca`, and the focused FlushApi prefix passed `2/2`,
  failed/skipped `0/0`, at `Saved/Tests/cache-v63-flush-api-refactor-test1/
  20260811_032719_218_56a82f12`.
- Task impact/evidence: one include correction and this issue record. The public
  Flush result, Store transaction, timeout validation and Engine lifecycle
  semantics were unchanged by the correction.

## IC-386 — Outer shell timeout orphaned the first complete Cache rerun

- Severity/state: V6.3 verification invocation defect / fixed 2026-08-11.
- Exact boundary: `Tools/RunTests.ps1` was correctly given
  `-TimeoutMs 1800000`, but its enclosing tool invocation was mistakenly limited
  to 120 seconds. The outer PowerShell was terminated after about 124 seconds,
  leaving only its redirected-stdout `UnrealEditor-Cmd.exe` child. The partial
  artifact is `Saved/Tests/cache-v63-flush-api-full-regression1/
  20260811_032857_205_551f05f1`; no report `index.json` was produced.
- Root cause/decision: the parent/child timeout budgets were inconsistent. The
  orphan's parent PID no longer existed and `Automation.log` stopped growing at
  03:30:56, so continuing to wait could not yield wrapper evidence. After matching
  PID 61660's executable and command line to that exact Cache run, only that
  orphan was terminated. Future long UE invocations use an outer timeout at least
  as large as the repository wrapper's timeout.
- Required evidence: the same official wrapper/prefix reran normally at
  `Saved/Tests/cache-v63-flush-api-full-regression2/
  20260811_033522_317_2e00baa7`. It completed in 470281 ms with process/wrapper
  exit `0/0`, `465/465 PASS`, failed/not-run `0/0` (`404` ordinary successes and
  `61` successes with expected warnings).
- Task impact/evidence: verification orchestration and this issue record only. No
  production code, Cache Store, test expectation or timeout setting was changed.

## IC-387 — Explain test constructed an UE 5.8 BLAKE3 hash from a dynamic array

- Severity/state: V6.3 test compile defect / fixed 2026-08-11.
- Exact boundary: the intended typed-Explain RED build also failed at the new
  test's `MakeHash()` helper because UE 5.8's `FBlake3Hash` constructor accepts
  its fixed `ByteArray` or a hexadecimal string view, not `TArray<uint8>`. The
  same artifact also contains the intended missing Explain DTO/API errors:
  `Saved/Build/cache-v63-typed-explain-red1/
  20260811_040137_025_7a0bbff0`.
- Decision/resolution: use the engine's exact `FBlake3Hash::ByteArray` fixture
  type, matching existing artifact-identity tests. Do not hash the bytes into a
  different value or add a production conversion API for test convenience.
- Required evidence: after the fixture correction and typed Explain
  implementation, the official build passed at `Saved/Build/
  cache-v63-typed-explain-green-build1/
  20260811_040430_583_eeb04d8d`; the dedicated Explain prefix passed `2/2` at
  `Saved/Tests/cache-v63-typed-explain-green-test1/
  20260811_040505_858_43b14720`.
- Task impact/evidence: one test-local fixed-array correction and this issue.
  Stable identity, persisted bytes, trace filtering and production hashing were
  not changed by the correction.

## IC-388 — Python dump wrapper does not expose the UE wrapper's `-Label` option

- Severity/state: V6.3 verification invocation defect / fixed 2026-08-11.
- Exact boundary: the first Python regression invocation copied the UE test
  wrapper convention and passed `-Label`; `RunCacheV2DumpTests.ps1` correctly
  rejected the unknown parameter before starting Python. No test or tool code
  executed and no output artifact was created by that invocation.
- Decision/resolution: use the wrapper's documented `-OutputRoot` parameter to
  give the run a stable evidence directory. Do not add a duplicate alias merely
  to hide an incorrect command, and do not bypass the repository wrapper.
- Required evidence: `Tools\RunCacheV2DumpTests.ps1 -OutputRoot
  Saved\Tests\cache-v63-debug-tools-python-regression1` completed with `20/20
  PASS` in `0.328s`; the output directory contains the wrapper log and summary.
  A later verification command repeated the same invalid `-Label` assumption and
  was again rejected before Python started; immediately rerunning with
  `-OutputRoot Saved\Tests\cache-v63-debug-tools-python-regression2` passed the
  same `20/20` methods in `0.336s`. This recurrence reinforces that the wrapper
  intentionally has one output-path contract rather than UE-style labels.
- Task impact/evidence: verification command and this issue only. Python decoder,
  C++ DTO, Cache Store and source files were unchanged.

## IC-389 — Runtime-reload UHT surface exceeded the build wrapper's first-pass timeout

- Severity/state: V6.3 verification capacity issue / fixed
  2026-08-11.
- Exact boundary: adding the Blueprint-reflected runtime-reload DTO invalidated
  the Editor target's UHT makefile and scheduled `103` compile/link actions. The
  official `Tools/RunBuild.ps1 -Label cache-v63-packaged-reload-compile1`
  invocation reached `78/103` actions before its configured `180000 ms` inner
  timeout terminated the process tree. The artifact is `Saved/Build/
  cache-v63-packaged-reload-compile1/20260811_041849_963_b80d544d`.
- Decision/resolution: treat this as an incomplete build, not a compile failure.
  The log contains no C++/UHT errors, Runtime was already linked, and the next
  official invocation will reuse completed outputs. Do not bypass the wrapper or
  claim GREEN from partial artifacts.
- Required evidence: the incremental retry passed at `Saved/Build/
  cache-v63-packaged-reload-compile2/20260811_042214_804_02c5aa92`; the later
  reflected API build passed at `Saved/Build/cache-v63-packaged-reload-api-build1/
  20260811_043302_521_82371614`. The expanded packaged-runtime behavior prefix
  passed `6/6` at `Saved/Tests/cache-v63-packaged-reload-expanded-test1/
  20260811_043443_474_bf2d7497`, and the C++/Blueprint API prefix passed `2/2` at
  `Saved/Tests/cache-v63-runtime-reload-api-test1/
  20260811_043535_137_169f5f9b`.
- Task impact/evidence: build orchestration and this issue record only; no API,
  runtime policy or test expectation is being weakened to fit the timeout.

## IC-390 — First packaged-reload test command used the wrong wrapper parameter

- Severity/state: V6.3 verification invocation defect / fixed 2026-08-11.
- Exact boundary: the first focused invocation passed `-Filter` to
  `Tools/RunTests.ps1`; PowerShell rejected it because this repository wrapper
  requires `-TestPrefix`. No Unreal process started and no test artifact was
  created.
- Decision/resolution: rerun through the same official wrapper with
  `-TestPrefix Angelscript.TestModule.Cache.PackagedRuntimeReload`. Do not add a
  wrapper alias merely to conceal an incorrect command.
- Required evidence: the corrected focused wrapper reached the real packaged
  policy RED at `Saved/Tests/cache-v63-packaged-reload-behavior1/
  20260811_042313_901_e0cbff0`; after the policy correction the strict prefix
  passed `3/3` at `Saved/Tests/cache-v63-packaged-reload-strict-test1/
  20260811_042755_021_4e127e2c`, and the final expanded prefix passed `6/6` at the
  IC-389 artifact above.
- Task impact/evidence: verification command and this issue record only; no
  production or test code changed.

## IC-391 — Existing PIE soft reload activates AS code for suggested full reloads

- Severity/state: V6.3 packaged Runtime policy mismatch / fixed
  2026-08-11.
- Exact boundary: the first corrected focused run passed default-disabled and
  code-body reload, but the structural-property case returned
  `ECompileResult::PartiallyHandled`. Existing PIE semantics swap in the new AS
  module, retain the old Unreal class layout, queue a later full reload and
  correctly publish Cache V2 `PendingColdStart`. The new packaged adapter
  therefore reported `AppliedCodeOnly` instead of `RequiresRestart`. Artifact:
  `Saved/Tests/cache-v63-packaged-reload-behavior1/
  20260811_042313_901_e0cbff0f`, totals `2/3 PASS`.
- Decision/resolution: add an explicit compile option used only by packaged
  Runtime reload to reject `FullReloadSuggested` before module swap. Existing
  Editor/PIE semantics stay unchanged. The candidate remains eligible for
  `PendingColdStart`, while `Current` and executable old code remain untouched.
  Do not merely remap `PartiallyHandled` after activation.
- Required evidence: the strict-policy build passed at `Saved/Build/
  cache-v63-packaged-reload-strict-build1/20260811_042501_254_b1bfbbae` and the
  strict focused prefix passed `3/3` at `Saved/Tests/
  cache-v63-packaged-reload-strict-test1/20260811_042755_021_4e127e2c`. The test
  proves `RequiresRestart`, unchanged `Answer()`, unchanged Current and a valid
  `PendingColdStart`. The final seven-scenario prefix, including deletion and
  compile failure, passed `7/7` at `Saved/Tests/
  cache-v63-packaged-runtime-reload-regression1/
  20260811_050008_712_d6ea10d5`.
- Task impact/evidence: a narrow compile-policy branch plus its packaged caller;
  no AS source syntax, Editor watcher behavior or ordinary SoftReload behavior
  changes.

## IC-392 — First compile-failure focused run inherited a ten-second outer timeout

- Severity/state: V6.3 verification invocation defect / fixed 2026-08-11.
- Exact boundary: the first focused packaged compile-failure invocation gave the
  repository test wrapper a 600-second timeout but left the enclosing shell at its
  ten-second default. The shell terminated before UE Automation could report a
  result. That interrupted invocation is not Runtime evidence.
- Decision/resolution: keep the official wrapper timeout and give the enclosing
  tool call the same 600-second budget. Do not interpret an outer orchestration
  kill as compile failure, and do not lower the test's Engine initialization work.
- Required evidence: after correcting both timeout layers and then correcting the
  independent expected-diagnostic issue IC-393, the focused method passed at
  `Saved/Tests/cache-v63-packaged-reload-compile-failure-focused1/
  20260811_044238_375_5e068ca0`; the complete packaged prefix later passed `7/7`
  at the IC-391 final artifact.
- Task impact/evidence: verification orchestration and this issue record only. No
  production, test semantics, cache state or package policy changed.

## IC-393 — Compile-failure test treated a literal parser diagnostic as a regex

- Severity/state: V6.3 test expectation defect / fixed 2026-08-11.
- Exact boundary: two seven-scenario packaged runs correctly returned
  `CompileFailed`, retained Current/last-good and emitted the four expected
  diagnostics, but the test's regex-style expected error used the literal text
  `Expected ')' or ','`. The parentheses were regex syntax, so the runner reported
  an unmet expectation even though the Runtime behavior was correct. Artifacts:
  `Saved/Tests/cache-v63-packaged-reload-compile-failure-test2` and
  `Saved/Tests/cache-v63-packaged-reload-compile-failure-test3`, each `6/7`.
- Decision/resolution: use CQTest's `AddExpectedErrorPlain` for the literal file,
  parser-token and hot-reload diagnostics. Do not weaken counts, suppress compiler
  diagnostics or change the AS parser message merely to satisfy the test.
- Required evidence: the corrected build passed at `Saved/Build/
  cache-v63-compile-failure-test-build3/20260811_044220_981_700c8956`; the focused
  method passed at the IC-392 artifact and the complete packaged prefix passed
  `7/7` at the IC-391 final artifact.
- Task impact/evidence: expected-error matching and this issue only. Runtime reload
  outcome, Current/Pending publications, compiler policy and executable last-good
  code were unchanged.

## IC-394 — Initial ForceClean test fixture was outside the clean-capture subset

- Severity/state: V6.3 test-fixture admission defect / fixed 2026-08-11.
- Exact boundary: the first MaintenanceApi run passed Verify/Compact and command
  registration but failed before testing ForceClean because its module contained
  only one free function. Current clean capture requires one admitted root class or
  enum, so no Current publication existed at the precondition assertion. Artifact:
  `Saved/Tests/cache-v63-force-clean-api-test1/
  20260811_045736_745_73fae8f0`, totals `2/3`.
- Decision/resolution: make the inline test module representative by adding one
  simple root UObject class while retaining the free function. Do not widen clean
  capture eligibility or bypass the immutable publication precondition for a
  maintenance API test.
- Required evidence: the fixture-only build passed at `Saved/Build/
  cache-v63-force-clean-fixture-build2/20260811_045900_941_8134d5d3`; the corrected
  prefix passed `3/3` at `Saved/Tests/cache-v63-force-clean-api-test2/
  20260811_045922_069_a14b5238`. The later compile-failure extension passed `4/4`
  at `Saved/Tests/cache-v63-force-clean-failure-test1/
  20260811_051250_642_666e1d8e`, proving typed failure, unchanged Current and
  executable last-good behavior.
- Task impact/evidence: inline test source, one execution helper and this issue.
  No project/business `.as`, capture admission rule, Store format or ForceClean
  production policy was changed.

## IC-395 — First V6.4 GREEN build shadowed an existing restore-route local

- Severity/state: V6.4 C++ compile naming defect / fixed 2026-08-11.
- Exact boundary: the first implementation introduced a second `ExistingRoute`
  local inside the already long restore/route-publication function. MSVC rejected
  the redeclaration before link or Automation, so no Runtime behavior executed.
  The failed artifact is `Saved/Build/cache-v64-function-route-green1`.
- Decision/resolution: rename the new local for the exact role it represents rather
  than splitting or weakening the ownership checks merely to avoid the collision.
  Stable-key lookup, Engine ownership and snapshot publication semantics were not
  changed by the rename.
- Required evidence: the corrected full-header build passed at `Saved/Build/
  cache-v64-function-route-green2/20260811_054033_934_4949716e`.
- Task impact/evidence: one local identifier and this issue only. No persisted wire,
  StableFunctionKey authority, Engine ownership rule or test oracle changed.

## IC-396 — Initial V6.4 syntax-failure oracle expected the wrong parser wording

- Severity/state: V6.4 test expected-diagnostic defect / fixed 2026-08-11.
- Exact boundary: the route behavior was ready, but the failed-reload method used a
  generic syntax message that this maintained parser does not emit. The real output
  includes the fixture path, `Expected data type`, `Instead found '<end of file>'`
  and the HotReload failure line. The mismatch was only in expected diagnostics;
  it did not show a route or last-good failure.
- Decision/resolution: match the maintained parser's exact literal diagnostics with
  `AddExpectedErrorPlain`. Do not suppress diagnostics, alter parser wording or
  loosen the requirement that the failed reload preserve the same snapshot.
- Required evidence: `Saved/Tests/cache-v64-function-route-focused4/
  20260811_054610_515_9a3c9464` passed the complete focused prefix `4/4`.
- Task impact/evidence: one inline negative-test expectation and this issue. Runtime
  compile, route publication and Store code were unchanged.

## IC-397 — Fresh restore executed correctly but initially omitted its stable route

- Severity/state: V6.4 restore integration gap / fixed 2026-08-11.
- Exact boundary: the first unified route rebuild enumerated normal compiler
  metadata. A graph-restored function was active and executable, but that metadata
  path could not authoritatively rederive the restored invocation identity, so
  FreshEngineRestore passed only `1/4` at `Saved/Tests/
  cache-v64-fresh-restore-regression1/20260811_054710_217_0ca51d0e`.
- Decision/resolution: merge the already graph-validated restore DTO into the
  transient route snapshot only after proving current Engine ownership, active
  module membership, current numeric-ID resolution and full StableFunctionKey
  equality. Do not persist FunctionIds/pointers or invent identity from incomplete
  compiler metadata.
- Required evidence: the corrected build passed at `Saved/Build/
  cache-v64-restore-route-fix-build2/20260811_055022_171_c9de10a7`; FreshEngineRestore
  then passed `4/4` at `Saved/Tests/cache-v64-fresh-restore-regression2/
  20260811_055039_000_c80cb9e6`, and ExactWarmRestore passed `4/4` at `Saved/Tests/
  cache-v64-exact-warm-regression1/20260811_055141_827_f2076ad4`.
- Task impact/evidence: transient restore-to-route handoff, restore coverage and this
  issue. Cache records, Generation identity and persisted numeric-ID policy remain
  unchanged.

## IC-398 — Public script-function interface does not expose the internal JIT pointer

- Severity/state: V6.4 C++ interface-layer compile defect / fixed 2026-08-11.
- Exact boundary: the first restore-route fix read `jitFunction` through
  `asIScriptFunction*`, but that field is internal to `asCScriptFunction`. MSVC
  rejected the access in `AngelscriptCacheRestore.cpp`; artifact `Saved/Build/
  cache-v64-restore-route-fix-build1/20260811_054838_100_11ce410b`.
- Decision/resolution: perform the internal cast only after the route candidate has
  passed Engine/module/function ownership checks, then read the transient JIT field
  solely to classify the current route as VM or Native. The pointer never enters a
  persisted record or diagnostic event.
- Required evidence: the corrected build passed at the IC-397 build artifact and
  its FreshEngineRestore/ExactWarmRestore regressions both passed `4/4`.
- Task impact/evidence: current-route classification implementation and this issue.
  No AS public API, provider ABI or cache identity was widened.

## IC-399 — Normal compile routes initially lacked graph-verified content/profile

- Severity/state: V6.4 semantic/diagnostic integration gap / fixed 2026-08-11.
- Exact boundary: the first route snapshot had the correct StableFunctionKey and VM
  target but normal compile publication did not carry the fully validated
  FunctionBody content/profile identity or emit a real `StableRoute` event. The
  intended RED passed `2/4` at `Saved/Tests/cache-v64-verified-route-red-test1/
  20260811_055648_944_506be554`; failures were exactly normal identity and body-
  reload identity/trace expectations.
- Decision/resolution: after the sole complete clean graph validates, extract a
  sorted pointer-free `FAngelscriptFunctionArtifactIdentity` list from graph-
  reachable FunctionBody records. Join it to current Engine routes by the full
  StableFunctionKey, publish it as a nonpersisted live DTO and emit bounded
  pointer-free `StableRoute` events. Do not add another identity algorithm or
  persist the derived list as a new record.
- Required evidence: the implementation build passed at `Saved/Build/
  cache-v64-verified-route-green-build1/20260811_055905_345_cb8323f9`; the focused
  prefix passed `4/4` at `Saved/Tests/cache-v64-verified-route-green-test1/
  20260811_060040_657_c6aaf2f0`, and FreshEngineRestore remained `4/4` at
  `Saved/Tests/cache-v64-verified-route-fresh-restore1/
  20260811_060227_426_05ca588c`.
- Task impact/evidence: clean-capture validated handoff, immutable route DTO,
  decision trace and their focused tests. Persisted record schema and graph
  authority were not changed.

## IC-400 — New real StableRoute event invalidated one hard-coded trace count

- Severity/state: V6.4 existing-test expectation drift / fixed 2026-08-11.
- Exact boundary: the first final Cache regression passed `486/487` at `Saved/Tests/
  cache-v64-final-full-regression1/20260811_060402_214_e9467f81`. The only failure,
  `BoundedTraceEvictsOldestPublicationAndStatusJsonUsesSameDto`, assumed initial
  compile emitted exactly one event. V6.4 correctly adds one real StableRoute event,
  so the bounded journal evicted `2` rather than the hard-coded `1`.
- Decision/resolution: derive inserted-event, eviction and ordinal expectations from
  the captured pre-copy snapshot. Retain exact bounded-journal checks while allowing
  production integration to emit the newly required route event.
- Required evidence: the expectation-fix build passed at `Saved/Build/
  cache-v64-trace-expectation-fix-build1/20260811_061323_704_7b99f85d`; DecisionTrace
  passed `3/3` at `Saved/Tests/cache-v64-trace-expectation-fix-test1/
  20260811_061342_614_8c17266d`; the final complete Cache prefix passed `487/487`,
  failed/not-run `0/0`, at `Saved/Tests/cache-v64-final-full-regression2/
  20260811_061428_230_16b5d5f7`.
- Task impact/evidence: one baseline-relative trace test and this issue. Journal
  capacity, eviction policy, StableRoute production emission and Status JSON were
  unchanged.

## IC-401 — Initial V6.5 wording overlapped the sibling Provider/Live Coding ownership

- Severity/state: V6.5 architecture/scope ambiguity / fixed in OpenSpec 2026-08-11.
- Exact boundary: the original V6.5 wording could be read as requiring this Cache
  change to implement provider discovery, manifest/ABI matching and the Live Coding
  state machine already owned by sibling OpenSpec
  `refactor-as-static-jit-external-module`. That would create two routing authorities
  and couple VM cache validity to provider lifecycle.
- Decision/resolution: this change owns the stable function identity, immutable
  per-Engine route snapshot and a narrow safe-point refresh seam. Tests inject
  already-selected success/miss/departure/failure outcomes and prove Cache
  invariance. The sibling change remains the only owner of provider ABI/catalog
  matching and Live Coding orchestration.
- Required evidence: the refined `tasks.md`, `implementation-plan.md` and
  `traceability.md` name that ownership boundary; StaticJITIsolation passed `3/3`
  and the complete Cache prefix passed `490/490` at the V6.5 artifacts recorded in
  `verification.md`.
- Task impact/evidence: V6.5 design, tests and one Cache-owned Engine seam only. No
  provider manifest, generated project module, provider ABI or Live Coding state
  was introduced in this change.

## IC-402 — The first V6.5 RED used a nonexistent Manager include

- Severity/state: V6.5 test-scaffolding compile defect / fixed 2026-08-11.
- Exact boundary: the first test-only RED included
  `Core/AngelscriptManager.h`, but the real manager API is exposed through the
  existing Engine/test headers. Compilation therefore stopped before reaching the
  intended missing route-refresh API. Artifact: `Saved/Build/
  cache-v65-staticjit-isolation-red1/20260811_063230_117_a9578206`.
- Decision/resolution: remove the imagined include and copy the include/configuration
  pattern from existing Cache Engine tests. Do not add a forwarding production
  header solely to satisfy a test typo.
- Required evidence: after the remaining test-scaffold corrections in IC-403, the
  clean RED reached only the intended missing API at `Saved/Build/
  cache-v65-staticjit-isolation-red3/20260811_063430_812_9c86e6db`.
- Task impact/evidence: one new test source include only; no Runtime or public API
  behavior changed.

## IC-403 — The second V6.5 RED assumed CQTest helpers that do not exist

- Severity/state: V6.5 test-scaffolding/API-assumption defect / fixed 2026-08-11.
- Exact boundary: the second RED used an imagined
  `FAngelscriptTestFullEngineConfig`, called matcher/assertion helpers as static
  functions and supplied unsupported extra message arguments. The same build also
  exposed the genuinely missing target method, so its mixed diagnostics were not a
  clean TDD boundary. Artifact: `Saved/Build/
  cache-v65-staticjit-isolation-red2/20260811_063319_441_10957ea2`.
- Decision/resolution: instantiate the actual `FAngelscriptEngineConfig`, declare
  the same test dependencies used by neighboring Cache tests, keep helper predicates
  boolean-only and use the supported matcher signatures. Do not expand the CQTest
  framework or production API for local syntax convenience.
- Required evidence: the third RED failed only at four calls to the missing
  `RefreshFunctionRouteSnapshotAfterStaticJITChange`; the first GREEN build then
  passed at `Saved/Build/cache-v65-staticjit-isolation-green1/
  20260811_063533_767_d263e6e0`, and the final focused prefix passed `3/3`.
- Task impact/evidence: V6.5 test scaffolding and this record only. The intended
  route isolation assertions were retained.

## IC-404 — Broad StaticJIT regression lacked the matched local AOT artifact pair

- Severity/state: V6.5 verification-environment prerequisite / open for the later
  StaticJIT/package acceptance workflow; not a Cache behavior failure 2026-08-11.
- Exact boundary: `RunTests.ps1 -TestPrefix Angelscript.TestModule.StaticJIT` at
  `Saved/Tests/cache-v65-staticjit-existing-regression1/
  20260811_064446_735_b9179b30` reported `19` passes and `11` failures. Every failure
  had the same pre-oracle diagnostic: local
  `StaticJIT/AOT/Generated/StaticJITAotFixture.Cache` was absent, so the generated
  `.jit.cpp/.jit.hpp` and cache could not be treated as a matched build pair. No
  failing report named route refresh, StableFunctionKey, cache publication or VM
  fallback behavior.
- Decision/resolution: preserve the run as honest incomplete compatibility evidence:
  all `19` runnable existing StaticJIT tests passed; do not claim the `11` missing-
  fixture tests as either V6.5 regressions or passes. Do not synthesize or regenerate
  the legacy AOT cache through the generic Cache verification path. Resolve/re-run
  under the repository's dedicated StaticJIT setup/acceptance workflow when that
  sibling/package evidence is executed.
- Required evidence: report entries for all `11` failures explicitly name the same
  absent local cache prerequisite. Independently, StaticJITIsolation passed `3/3`,
  FunctionRouteSnapshot `4/4`, DecisionTrace `3/3`, and complete Cache `490/490`.
- Task impact/evidence: verification ledger and later sibling/package acceptance.
  No V6.5 production code or Cache test oracle was weakened to hide the missing
  fixture.

## IC-405 — V7.1 began with the intended missing legacy-cutover inspection API

- Severity/state: expected TDD API boundary / closed 2026-08-11.
- Exact boundary: the first `AngelscriptCacheLegacyCutoverTests.cpp` build could
  not include `Cache/AngelscriptCacheLegacyCutover.h`, proving no production API
  yet existed to inspect and explicitly reject legacy cache filenames. Artifact:
  `Saved/Build/cache-v71-legacy-cutover-red1/
  20260811_070126_349_5ef1ec2c`.
- Decision/resolution: add an existence-only scanner that reports fixed legacy
  names and independent `Binds.Cache` presence. It must never open, hash, decode or
  migrate an old payload, and it cannot become Cache V2 selection authority.
- Required evidence: corrected build plus final LegacyCutover `4/4` evidence is
  recorded under V7.1/V7.2 in `verification.md`.
- Task impact/evidence: V7.1 production diagnostic and focused tests only.

## IC-406 — The first V7.1 GREEN attempt contained two local compile defects

- Severity/state: implementation compile defect / fixed 2026-08-11.
- Exact boundary: `Saved/Build/cache-v71-legacy-inspection-green1/
  20260811_070222_937_3cbc3a60` used `Algo::Unique` without its owning include and
  referred to a diagnostic DTO field as `TransactionId` instead of the actual
  `TransactionOrdinal`. These errors were local to the new implementation/test and
  prevented execution of the intended behavior oracle.
- Decision/resolution: include `Algo/Unique.h` explicitly and use the actual stable
  transaction coordinate. Do not add aliases or weaken the DTO schema to hide a
  caller typo.
- Required evidence: `cache-v71-legacy-inspection-green2` built successfully and
  the initial focused inspection prefix passed `3/3`.
- Task impact/evidence: V7.1 scanner/test source only; no wire or cache identity
  changed.

## IC-407 — The legacy production flags remained reachable at the V7.2 RED gate

- Severity/state: expected cutover behavior failure / closed 2026-08-11.
- Exact boundary: after the rejection scanner existed, the focused suite passed
  `3/4`; only `LegacyProductionSelectionFlagsAreAbsent` failed because the old
  generation/ignore/skip-JIT configuration fields still existed. Artifact:
  `Saved/Tests/cache-v72-legacy-flags-red-test1/
  20260811_070428_153_954f4a4e`.
- Decision/resolution: remove normal startup reader/writer/generator/forced-exit
  selection in one pass. Retain and explicitly rename only the sibling StaticJIT
  diagnostic/AOT compatibility bridge, with a per-file inventory.
- Required evidence: the V7.2 production build, LegacyCutover `4/4`, NativeForms
  `2/2`, EngineIsolation `14/14` and static reference classification are recorded
  in `verification.md` and `staticjit-compatibility-bridge-inventory.md`.
- Task impact/evidence: V7.2 direct cutover plus package pre-generation removal.

## IC-408 — The specified process-level C++ cache report was absent

- Severity/state: V6.3/V7.3 diagnostics integration gap / fixed 2026-08-11.
- Exact boundary: package-smoke design and benchmark evidence require
  `-as-cache-report=<absolute-json-path>`, but Runtime only exposed live capture and
  `as.Cache.Status Json=...`. Searching production code found no command-line parse
  or shutdown writer, so real Development/Shipping launches would have lacked a
  deterministic per-process C++ evidence file.
- Decision/resolution: parse the explicit report path into per-Engine config,
  validate an absolute `.json` target, serialize the existing pointer-free DTO after
  bounded shutdown flush, and return/log typed `ReportPathInvalid` or
  `ReportWriteFailed` errors. The report is an observer and never controls cache
  selection/publication. Python may correlate or present it offline.
- Required evidence: intended RED and successful builds plus SettingsAndShutdown
  `3/3` are recorded in `verification.md`; `cache-v2-debuggability.md` retains the
  C++/Python shared-boundary rule.
- Task impact/evidence: closes the C++ process-report prerequisite for V7.3/V7.6;
  no persisted Cache V2 wire bytes changed.

## IC-409 — The first process-report test observed the live API after Service teardown

- Severity/state: V7.3 test-oracle lifetime defect / fixed 2026-08-11.
- Exact boundary: the first focused run wrote the requested report successfully but
  failed `1/3` because the test called `CaptureAngelscriptCacheDiagnosticJson` after
  `FAngelscriptEngine::Shutdown()` had reset `CacheService`. Artifact:
  `Saved/Tests/cache-v73-process-report-green1/
  20260811_072417_888_180785b7`. This was not a report-write failure; the log showed
  the exact output path before the unsupported post-shutdown live query.
- Decision/resolution: keep the production write at the last valid boundary after
  Service shutdown-flush transition and before Service reset. The test now validates
  persisted schema, `ShuttingDown`, a real Current publication and numeric-ID
  absence; existing live API/console tests continue to prove byte equality while
  Service is alive.
- Required evidence: final focused SettingsAndShutdown passed `3/3` at the V7.3
  artifact recorded in `verification.md`.
- Task impact/evidence: one focused test correction; production report timing was
  retained.

## IC-410 — Route rebuild formatted stale dependency signature metadata after full reload

- Severity/state: V7.4 reproducible HotReload access violation / fixed and closed
  2026-08-11.
- Exact boundary: the complete HotReload prefix crashed in
  `ProviderStructFullReloadRetargetsConsumerFunctionParameter` after the provider
  struct was structurally replaced but before the consumer module was recompiled.
  The new V6.4 route rebuild enumerated every active function and called
  `GetDeclaration()` on the retained consumer function. Its parameter type still
  crossed the dependency reference-update lifetime, so `asCDataType::Format()`
  dereferenced released `asCTypeInfo` state and raised access violation `0x38`.
  Call stack: `asCDataType::Format -> asCScriptFunction::GetDeclaration ->
  TryBuildFunctionKey -> RebuildFunctionRouteSnapshot -> CompileModules`.
  Artifact: `Saved/Tests/cache-v74-hotreload-regression1/
  20260811_074515_815_f7892144`; process/wrapper exit `3/1`, no completed report,
  crash after all preceding HotReload tests had passed.
- Decision/resolution: route rebuild must distinguish modules compiled in this
  transaction from retained modules whose dependency artifacts were invalidated.
  Rebuilt functions derive fresh keys from authoritative new compiler metadata.
  Unchanged retained functions reuse the previous snapshot's owned stable key and
  canonical declaration without traversing live signature types. A dependency-
  invalidated retained route keeps only stable identity, clears verified artifact
  content/profile and selects VM until authoritative recompile. A retained module
  with neither safe previous identity nor new compiler authority is omitted rather
  than speculatively formatted.
- Required evidence: rebuild/link; focused HotReload Dependency regression including
  the exact crashing method; FunctionRouteSnapshot/StaticJIT isolation regression;
  then complete HotReload and complete Cache prefixes. All passed: build
  `Saved/Build/cache-v74-route-hotreload-fix-build1/
  20260811_075047_292_c9c0c4b4`; Dependency `2/2` at `Saved/Tests/
  cache-v74-route-hotreload-fix-focused1/
  20260811_075424_590_0c689a26`; FunctionRouteSnapshot `4/4`, StaticJITIsolation
  `3/3` and DecisionTrace `3/3` at the V7.4 artifacts recorded in
  `verification.md`; complete HotReload `122/122` and complete Cache `495/495` at
  `Saved/Tests/cache-v74-route-hotreload-fix-full-hotreload1/
  20260811_075729_149_d1a61a50` and `Saved/Tests/
  cache-v74-route-hotreload-fix-full-cache1/
  20260811_075950_441_9711ddf6`. The dedicated generated-AOT StaticJIT workflow
  also passed `30/30` at `Saved/Tests/cache-v74-staticjit-aot_04_tests/
  20260811_080942_712_e895fedd`.
- Task impact/evidence: V7.4 plus the V6.4 route publication lifecycle. No persisted
  record identity, source invalidation or Store wire changes.

## IC-411 — The first real-PIE fixture bypassed production source discovery

- Severity/state: V7.5 test-path defect / fixed 2026-08-11.
- Exact boundary: the first `AngelscriptCachePIELifecycleTests.cpp` revision used
  the in-memory `CompileScriptModule`/`CompileModuleWithResult` helper. That helper
  intentionally compiles a caller-supplied module without the production
  SourceIndex and `FAngelscriptCacheCompileCaptureContext`, so the successful
  compiler result could not publish Cache V2 `Current`. Both tests failed before
  PIE at their initial `Current.IsValid()` assertions. Command:
  `Tools/RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache.PIE -Label
  cache-v75-real-pie-test1 -TimeoutMs 1200000`; UE 5.8 Editor/NullRHI artifact:
  `Saved/Tests/cache-v75-real-pie-test1/
  20260811_081939_647_6f51dec6`, `0/2`, process/wrapper `255/1`.
- Decision/resolution: use a physical, guarded
  `Saved/Automation/AngelscriptCachePIE/<guid>/Script` root, create an isolated
  full test Engine whose project root points there, then drive the production
  `InitialCompile`, file-change queue and `CheckForHotReload` paths. Keep the
  Engine/scope alive across latent PIE commands and never modify repository script
  sources.
- Required evidence: the replacement harness built at `Saved/Build/
  cache-v75-real-pie-production-path-build1/
  20260811_082449_123_51384ef4`; the next run reached the production
  `CaptureAngelscriptCleanCompiledModule` shape classifier for both physical
  modules, proving the bypass was removed. Final behavioral GREEN belongs to
  IC-412/V7.5.
- Task impact/evidence: V7.5 test harness only. No Runtime cache authority or wire
  behavior changed to accommodate the failed helper.

## IC-412 — The first production-path PIE fixture used a reflected class method outside the admitted vertical

- Severity/state: V7.5 fixture/capability-boundary defect / fix in validation
  2026-08-11.
- Exact boundary: both physical LevelScriptActor modules declared
  `UFUNCTION() int GetValue()`. The implemented root-UClass capture vertical
  already captures non-reflected class methods and their FunctionBody/stable
  FunctionKey, but deliberately rejects a nonempty
  `FAngelscriptClassDesc::Methods` reflection table. Production capture therefore
  returned typed `NotCacheable` with `The class is outside the first root-UClass
  primitive capture shape`; both tests again stopped at the initial `Current`
  assertion before PIE. Command label
  `cache-v75-real-pie-production-path-test1`; UE 5.8 Editor/NullRHI artifact:
  `Saved/Tests/cache-v75-real-pie-production-path-test1/
  20260811_082613_402_d9100fa4`, Automation log failures at test-source lines
  `568` and `428`. The outer command host timed out after five seconds while the
  spawned Editor continued to a normal automation failure, so no wrapper summary
  was synthesized; the exact completed test results and typed capture messages are
  preserved in `Automation.log`.
- Decision/resolution: retain a real PIE LevelScriptActor, but make `GetValue` a
  normal non-reflected AS class method. Invoke it on the actual PIE actor through
  the live AS type/context (`Prepare`, `SetObject`, `Execute`) instead of a generated
  UFunction thunk. Keep `UPROPERTY AddedValue` as the structural reflection change,
  so the same test still proves body-only live behavior, stable route identity,
  compile-failure last-good, structural PendingColdStart and post-PIE promotion.
  Do not widen production UFunction capture merely to fit a test fixture.
- Required evidence: rebuild; focused `Angelscript.TestModule.Cache.PIE` `2/2`;
  then affected EditorLifecycle/PIESession and Cache regression prefixes. If the
  non-reflected VM call exposes a real production defect, preserve it under the
  next issue ID rather than weakening the behavioral assertions.
- Task impact/evidence: V7.5 fixture invocation boundary. Stable identity, record
  schema and production capture admission remain unchanged.

## IC-413 — Actor preprocessing added a generated Spawn signature outside the root stable-type table

- Severity/state: V7.5 fixture/admitted-type-boundary defect / fix in validation
  2026-08-11.
- Exact boundary: after IC-412 removed UFunction reflection, capture advanced into
  the complete module function table and rejected the preprocessor-generated
  `Spawn(const FVector&inout, const FRotator&inout, const FName&inout, bool,
  ULevel)` helper. The current root-class stable data-type adapter does not yet
  admit those environment parameter forms, so both Actor modules returned typed
  `NotCacheable` before publication. Command:
  `Tools/RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache.PIE -Label
  cache-v75-real-pie-vm-method-test1 -TimeoutMs 1200000`; UE 5.8
  Editor/NullRHI artifact: `Saved/Tests/cache-v75-real-pie-vm-method-test1/
  20260811_083241_177_251dbd35`, `0/2`, process/wrapper `255/1`.
- Decision/resolution: V7.5 does not opportunistically expand FVector/FRotator/
  FName/ULevel function-type capture merely to support an Actor convenience
  helper. Use a normal editor map and create an AS `UObject` instance whose outer
  is the real PIE world. Keep that instance strongly alive only for the PIE
  session and execute the cached non-reflected method on it across body, invalid
  and structural reloads. Reset the strong reference before PIE teardown. The
  actor/generated-Spawn shape remains an explicit future capture-admission gap and
  must not be mislabeled corrupt.
- Required evidence: rebuild; focused real PIE `2/2`; C++ stage/session JSON must
  show Current/Pending/route transitions, and live VM results must show
  `710 -> 720 -> 720 -> 730`, followed by reflected `AddedValue` only after
  post-PIE promotion.
- Task impact/evidence: V7.5 fixture only. No wire, stable key, environment symbol
  or production type-mapping rule changes.

## IC-414 — The invalid-edit PIE oracle expected diagnostics from a different parser recovery path

- Severity/state: V7.5 test-oracle diagnostic mismatch / fix in validation
  2026-08-11.
- Exact boundary: the first UObject-based run passed the full cold/warm test and
  advanced the mutation test through initial `Current`, real PIE execution, body
  publication `Tx=2` and last-good execution after invalid source. The parser
  diagnosed the deliberately incomplete method as `Expected method or property`
  and `Instead found reserved keyword 'int'`; the test expected `Expected data
  type` and end-of-file wording, leaving exactly those two real errors unconsumed.
  Artifact: `Saved/Tests/cache-v75-real-pie-uobject-test1/
  20260811_083722_537_b6be4eec`, `1/2`, process/wrapper `255/1`.
- Decision/resolution: match the exact stable parser diagnostics emitted by this
  fixture. Retain all last-good publication and VM-result assertions. IC-415
  records the follow-up correction after the next run proved that the filename
  and final hot-reload summary are also error records in this path.
- Required evidence: rebuilt focused run must reach structural Pending/Promote and
  pass `2/2`; no production change is justified by an expected-error string.
- Task impact/evidence: one V7.5 test diagnostic oracle only. The run already
  proves `CurrentTx=2` survived the failed source and live behavior remained 720.

## IC-415 — The corrected parser oracle still omitted two wrapper-level Error records

- Severity/state: V7.5 test-oracle expected-error accounting / fixed and real PIE
  GREEN 2026-08-11.
- Exact boundary: after IC-414 consumed the two exact parser diagnostics, the
  second UObject-based run again passed the complete cold/warm test and advanced
  the mutation test through `710 -> 720 -> 720`. CQTest then rejected two
  unconsumed Error records emitted around the same failed source: the
  `ASCachePIEMutation.as:` location record and `Hot reload failed due to script
  compile errors. Keeping all old script code.` summary. Artifact:
  `Saved/Tests/cache-v75-real-pie-uobject-test2/
  20260811_083936_488_51dcd6af`, `1/2`, process/wrapper `255/1`. The two parser
  records were consumed successfully, confirming that this is expected-error
  accounting rather than a cache lifecycle failure.
- Decision/resolution: consume all four actual Error records exactly once: source
  location, `Expected method or property`, reserved-keyword recovery and final
  hot-reload last-good summary. Do not use an unbounded count, do not suppress the
  log category and do not weaken `Current`, `PendingColdStart`, route identity or
  live VM-result assertions.
- Required evidence: rebuild and focused
  `Angelscript.TestModule.Cache.PIE` `2/2`, reaching the structural
  PendingColdStart and post-PIE promotion stages. Preserve the C++ stage/session
  JSON and `710 -> 720 -> 720 -> 730` behavioral evidence.
- Task impact/evidence: V7.5 test oracle only; no production cache, compiler,
  hot-reload or wire behavior changed.
- Final evidence: `Saved/Tests/cache-v75-real-pie-uobject-test3/
  20260811_084252_350_6349dea2`, real UE 5.8 Editor/NullRHI PIE `2/2`.

## IC-416 — One unsupported module erased every eligible module from a production capture

- Severity/state: core production publication isolation defect / intended RED,
  fixed and focused GREEN 2026-08-11.
- Exact boundary: `FAngelscriptEngine::CompileModules` builds a deterministic
  active-module candidate list, but appends an output slot before each capture and
  executes `PublicationInput.Modules.Reset(); break;` on the first failed
  `CaptureAngelscriptCleanCompiledModule`. A normal `NotCacheable` module therefore
  prevents every independently eligible module from reaching Current and the
  Store. This is reproducible in the real project because ordinary modules exceed
  the intentionally narrow enum/root-class capture vertical; code inspection also
  shows the result depends on canonical module ordering. The defect violates the
  SourceIndex per-scope ineligibility and module-atomic publication contract: one
  module must be all-or-nothing, but unrelated modules must remain usable.
- Decision/resolution: capture into a local module artifact, append only on
  success, continue after a typed per-module failure, and freeze whenever at least
  one module succeeded. Preserve the complete authoritative SourceIndex in every
  successful module, retain deterministic ordering, and leave compile/activation
  behavior fail-soft. Record bounded typed skip diagnostics for C++ online tools;
  Python will observe the resulting Manifest subset and shared SourceIndex rather
  than becoming a second selection authority.
- Required evidence: an intended production-path RED with one admitted module and
  one valid but unsupported two-enum module; build; focused MultiModuleGeneration
  GREEN proving both modules stay active while Current contains only the admitted
  module; complete lifecycle/Cache regressions; real project startup showing a
  partial Current instead of a batch reset.
- Task impact/evidence: reopens the production completeness of V3.3/V6.2 and is a
  prerequisite for honest V7.5-V7.7 acceptance. No persisted record/wire change is
  required merely to isolate capture failures.
- RED/GREEN evidence: intended RED
  `Saved/Tests/cache-ic416-partial-capture-red-test2/
  20260811_085306_440_83f8540d`, `1/2`; GREEN
  `Saved/Tests/cache-ic416-partial-capture-green-test1/
  20260811_085649_663_c2e769ad`, `2/2`; stable-keyed trace GREEN
  `Saved/Tests/cache-ic416-partial-trace-green-test1/
  20260811_090048_542_52fb7ea7`, `2/2`. Real host startup recorded
  `Candidates=37 Captured=1 Skipped=36` instead of resetting the batch.

## IC-417 — The production InitialCompile path does not consume the exact-start coordinator

- Severity/state: critical second-launch functionality gap / intended RED, fixed
  for the admitted production vertical and regression GREEN 2026-08-11.
- Exact boundary: `RestoreAngelscriptCacheExactStartup` is referenced only by its
  focused tests; `FAngelscriptEngine::InitialCompile` always creates the
  preprocessor, discovers source through it and calls `CompileModules`. The helper
  itself also requires exactly one persisted and one discovered module. Therefore
  the current real Editor/game second launch cannot achieve the specified zero
  preprocess/parse/compiler exact hit even though the Store, graph restore and
  single-module coordinator are independently tested.
- Decision/resolution: connect production startup to Saved-only Store selection,
  direct source discovery, candidate validation and multi-module atomic restore
  before frontend work. Generalize the coordinator beyond its one-module test
  vertical, treat unsupported/ineligible modules as safe misses, and compile the
  authoritative miss closure without duplicating restored modules. Publication,
  route rebuilding, counters and C++/Python diagnostics must expose the actual
  mixed result.
- Required evidence: focused production cold/flush/new-engine warm tests using
  two or more modules; unchanged second launch reports zero frontend/compiler work
  for every eligible restored module and no redundant generation; mixed eligible/
  ineligible fallback remains behaviorally complete; then real Editor and packaged
  multi-launch evidence.
- Task impact/evidence: reopens V3.5 production integration and blocks V7.6. The
  existing helper tests remain valid component evidence but are not sufficient
  production acceptance.
- RED/GREEN evidence: production RED build/test
  `Saved/Build/cache-ic417-production-warm-red-build1/
  20260811_090904_583_1decb950` and
  `Saved/Tests/cache-ic417-production-warm-red-test1/
  20260811_090947_622_3187fdca`, `0/1`. Initial production GREEN
  `Saved/Tests/cache-ic417-production-warm-green-test1/
  20260811_091834_697_f6b738aa`, `1/1`; restored Current/provenance GREEN
  `Saved/Tests/cache-ic417-restored-current-test1/
  20260811_092232_394_25e45f69`, `1/1`; changed-source fallback GREEN
  `Saved/Tests/cache-ic417-changed-fallback-test1/
  20260811_092453_010_df4ab71f`, `2/2`; pre-atomic adjacent set
  `Saved/Tests/cache-ic417-adjacent-test1/
  20260811_092625_677_5fac45ad`, `18/18`. IC-422 later replaces sequential
  activation with the required complete-batch authority.

## IC-418 — The first IC-416 fixture hit DebugSourceMismatch before the intended batch boundary

- Severity/state: focused RED fixture/intermediate graph anomaly / isolated from
  IC-416 on 2026-08-11; root-cause follow-up remains required if reproducible.
- Exact boundary: the first mixed-module fixture named its admitted source
  `Eligible.as`. Both modules compiled and remained active, but capture of that
  admitted enum/function module failed graph validation with
  `DebugSourceMismatch` (`Error=62`, ModuleGraph, ModuleSnapshot offset `108`)
  before the later two-enum module was examined. Artifact:
  `Saved/Tests/cache-ic416-partial-capture-red-test1/
  20260811_084945_141_292ceca4`, `1/2`, process/wrapper `255/1`. This result still
  proves the current batch produced no Current, but is not the clean IC-416 RED
  because no earlier successful artifact was available for the reset to erase.
- Decision/resolution: make IC-416 use the already-proven `First.as` admitted shape
  from the adjacent two-module generation test, ordered before `Unsupported.as`,
  so its RED must specifically show a successful first capture erased by the
  second module's typed `NotCacheable`. Retain this anomaly in the ledger and
  reproduce it independently after the batch fix; do not widen or suppress debug
  validation to force the intended test.
- Required evidence: rebuilt intended RED with a `First` capture followed by an
  `Unsupported` failure and no Current; IC-416 GREEN after isolation. A later
  single-/mixed-module reproduction decides whether this was order/global test
  state or a source-coordinate defect.
- Task impact/evidence: test-fixture precision plus possible DebugSidecar/source
  coordinate follow-up; no wire or validation rule changed.

## IC-419 — The IC-416 trace assertion compared a typed profile wrapper directly

- Severity/state: test-only compile correction / fixed 2026-08-11.
- Exact boundary: after IC-416 was behaviorally GREEN, its new bounded-decision
  assertion compared two `FAngelscriptArtifactProfileKey` wrappers with `==`.
  That type deliberately exposes equality through its full-width `Hash`, so MSVC
  rejected `AngelscriptCacheMultiModuleGenerationTests.cpp:290` with `C2678`.
  The same build also prompted a lifetime audit of a log-only ModuleKey string.
  Artifact: `Saved/Build/cache-ic416-partial-trace-build1/
  20260811_085920_574_efd7499e`, UBT/process `1/6`.
- Decision/resolution: compare `Profile.Hash` values, matching all persisted and
  diagnostic identity authorities. Own the formatted ModuleKey in an `FString`
  for the complete `UE_LOG` call rather than retaining a pointer to a temporary.
- Required evidence: rebuild/link and focused MultiModuleGeneration `2/2`,
  including the stable-keyed `NotCacheable` trace assertion.
- Task impact/evidence: test/log lifetime correction only; no Cache identity,
  capture selection or wire semantics changed.
- Final evidence: `Saved/Tests/cache-ic416-partial-trace-green-test1/
  20260811_090048_542_52fb7ea7`, `2/2`.

## IC-420 — Exact-start activation was live but Current omitted persisted provenance

- Severity/state: production online-observability and redundant-write defect /
  fixed and focused GREEN 2026-08-11.
- Exact boundary: the first production `InitialCompile()` exact-start integration
  restored both modules with zero frontend work, but the Cache service had no
  immutable `Current` publication describing that live state. C++ status/session
  JSON therefore could not say that the Engine was restored from Store or name
  its persisted Generation, and an explicit/shutdown flush could attempt to
  republish already-persisted content. VM activation alone was not sufficient
  lifecycle or debugging evidence.
- Decision/resolution: reconstruct the successful-publication DTO from the
  already validated Generation graph after complete activation, add
  `bRestoredFromStore` plus `PersistedGenerationId` provenance, freeze it into
  Current under the existing startup mutation token, and make flush a no-op for
  a restored publication. Bump the diagnostic/publication DTO schema to `2`;
  record adoption as `SuccessfulPublication/Reused/ExactStartup` so the actual
  validation/activation remains the sole `StartupRestore` decision.
- Required evidence: production two-module cold/flush/new-Engine warm test must
  show `bLoadedIncrementalCache`, frontend event count `0`, Current provenance
  equal to the Store Generation, diagnostic JSON containing both fields, explicit
  warm flush with no commit, and byte-identical Store file count/digest. GREEN:
  build `Saved/Build/cache-ic417-restored-current-build1/
  20260811_092201_542_ee4c6233`; test
  `Saved/Tests/cache-ic417-restored-current-test1/
  20260811_092232_394_25e45f69`, `1/1`.
- Task impact/evidence: closes the online status and redundant-publication part of
  V3.5/V6.3 for the admitted exact-start vertical. This is a diagnostic DTO schema
  change, not a persisted Manifest/Pack wire change.

## IC-421 — Python session correlation needed explicit schema-2 restored provenance

- Severity/state: offline debug-schema compatibility gap / fixed and GREEN
  2026-08-11.
- Exact boundary: after IC-420 moved C++ diagnostic/publication snapshots to
  schema `2`, the Python reader accepted only session schema `1`, and its live to
  persisted correlation fixture did not prove `restoredFromStore` or
  `persistedGenerationId`. A C++-only schema bump would have broken the promised
  shared C++/Python debugging boundary.
- Decision/resolution: accept session schema `1` and `2` in the read-only Python
  decoder, keep existing v1 compatibility, and upgrade the correlation fixture to
  a schema-2 publication carrying restored provenance. Python remains an offline
  observer and does not gain startup selection authority.
- Required evidence: `Tools/RunCacheV2DumpTests.ps1` must pass all dump, diff,
  explain, corruption and C++-session correlation cases. GREEN:
  `Saved/Tests/cache-v2-dump/20260811_093336_434`, `20/20`.
- Task impact/evidence: closes the schema-evolution portion of V6.3; no C++
  restore, Store selection or persisted record semantics changed.

## IC-422 — Multi-module exact restore still activated modules one at a time

- Severity/state: critical activation-atomicity gap / intended RED reproduced,
  batch staging/commit implemented, adjacent restore and final real PIE GREEN
  2026-08-11.
- Exact boundary: exact-start now preflights the complete current/persisted module
  set and every known supported record shape, but then calls the single-module
  restorer in Manifest order. That restorer runs ClassGenerator setup,
  `SwapInModules`, reload, route publication and import resolution immediately.
  If module N fails during VM restore, finalization or ClassGenerator after an
  earlier module was activated, the fresh Engine can contain a partial cache
  generation. `InitialCompile()` currently detects this and refuses an unsafe
  compile fallback, which is fail-closed but is not the specified atomic restore.
- Decision/resolution: split restore into side-effect-bounded per-module
  preparation and one batch activation. Prepare every staging VM module,
  descriptor and stable route first; on any failure discard every prepared
  staging module and publish nothing. Run PreGenerate/ClassGenerator setup once
  for the complete batch, call `SwapInModules` once, perform one reload, publish
  all `ModulesByScriptModule` entries and one immutable route snapshot together,
  then adopt Current. Keep the single-module public helper as a wrapper over the
  same batch authority. Add a narrow restore fault injector that can reject the
  second prepared module before commit, following the existing Store fault-
  injection pattern; it must not alter production behavior when absent.
- Required evidence: an intended RED proving the current sequential implementation
  leaves module one active after a deterministic second-module late failure;
  GREEN proving zero active modules/enums/routes, no Current and no displaced
  modules after the same fault; successful two-module restore still executes both
  functions and publishes one combined route snapshot; single-module restore and
  production `InitialCompile()` regressions remain GREEN.
- RED/GREEN evidence: sequential RED build
  `Saved/Build/cache-ic422-atomic-red-build2/
  20260811_094329_355_e4b5fc64`; focused RED
  `Saved/Tests/cache-ic422-atomic-red-test1/
  20260811_094534_958_188a69dd`, `0/1`, where the second prepared-module fault
  observed one already active module and production emitted the fatal partial-
  mutation diagnostic. Batch GREEN build
  `Saved/Build/cache-ic422-atomic-green-build1/
  20260811_095012_555_f659e1b4`; focused GREEN
  `Saved/Tests/cache-ic422-atomic-green-test1/
  20260811_095038_797_6fc3a03e`, `1/1`, with `ActiveAtFault=0`,
  `RoutesAtFault=0`, safe normal-compile fallback `FrontendEvents=6` and live
  values `801/802`.
- Task impact/evidence: reopens the atomic wording of V3.4/V3.5 and is required
  before final V7.5/V7.6 acceptance. It does not expand the admitted enum/global-
  function record shape or change persisted wire formats.
- Final adjacent evidence: production warm `4/4` at
  `Saved/Tests/cache-ic422-production-regression1/
  20260811_095137_629_651b27e1`; restore/rollback/route set `12/12` at
  `Saved/Tests/cache-ic422-restore-adjacent1/
  20260811_095246_015_19d4cd8d`; strengthened two-module success `1/1` at
  `Saved/Tests/cache-ic422-batch-success-test1/
  20260811_095513_735_c3fb79ce`; final Cache PIE + EditorLifecycle + HotReload
  PIESession `12/12` at `Saved/Tests/cache-v75-atomic-final-pie1/
  20260811_095843_675_c70c54a4`.

## IC-423 — A partial persisted Generation must miss before activation

- Severity/state: production fallback acceptance gap / test added and GREEN
  2026-08-11.
- Exact boundary: IC-416 intentionally permits a successful publication to
  contain only independently cacheable modules while SourceIndex still describes
  the complete discovery. A later startup must not restore that subset when the
  current executable module set is larger; otherwise the Engine would mix one
  cached module with absent modules before the normal compiler runs.
- Decision/resolution: retain exact-start's complete module-set equality as a
  pre-mutation gate. A partial Store generation returns typed
  `ModuleSetMismatch`, production `InitialCompile()` compiles every discovered
  module, and the next publication may again retain only independently eligible
  artifacts without affecting live behavior.
- Required evidence: focused production test with one admitted module and one
  valid unsupported module; cold Current contains one module, warm discovery sees
  two, exact-start misses before activation, both live modules are normal compile
  results, function behavior is `702`, and Current still contains only the
  admitted module. GREEN: build
  `Saved/Build/cache-ic417-partial-fallback-build1/
  20260811_093214_729_2eb8fd28`; test
  `Saved/Tests/cache-ic417-partial-fallback-test1/
  20260811_093236_611_2da1345c`, production prefix `3/3`.
- Task impact/evidence: closes the partial-publication fallback half of IC-416 and
  V3.5; IC-422 remains the separate unexpected late-failure atomicity requirement.

## IC-424 — The first per-Engine restore injector wiring crossed Engine encapsulation

- Severity/state: test-seam compile correction / fixed and rebuilt 2026-08-11.
- Exact boundary: the transaction-local injector was correctly stored in
  `FAngelscriptEngineDependencies`, but the file-private production exact-start
  coordinator attempted to read `Engine.Dependencies` directly. MSVC rejected
  `AngelscriptEngine.cpp:2859` with C2248 because the Engine owns that member
  privately. Artifact: `Saved/Build/cache-ic422-atomic-red-build1/
  20260811_094101_741_430837d0`, UBT/process `1/6`.
- Decision/resolution: retain private dependency ownership and expose only a
  `WITH_ANGELSCRIPT_UNITTESTS` read-only accessor returning the caller-owned
  restore injector. Do not make the complete dependency aggregate public and do
  not introduce a process-global test hook.
- Required evidence: rebuild/link, then the focused IC-422 method must execute and
  fail for the intended partial-activation assertions rather than at compile.
- Task impact/evidence: test support only; no production behavior, wire format or
  public shipping surface changes.
- Final evidence: `Saved/Build/cache-ic422-atomic-red-build2/
  20260811_094329_355_e4b5fc64` linked the intended RED seam; IC-422's focused RED
  then executed at runtime.

## IC-425 — Package-smoke evidence lagged diagnostic schema and normative assertions

- Severity/state: V7.6 acceptance-tool gap / open 2026-08-11.
- Exact boundary: `FAngelscriptCacheDiagnosticSnapshot` and successful-publication
  DTOs moved to schema `2` in IC-420, while
  `Tools/Shared/AngelscriptCachePackageSmoke.psm1` and its PowerShell self-test
  still require top-level schema `1`. A real warm package report would therefore
  be rejected before its restored provenance could be examined. The scenario
  checker also proves only process exit and `sourceSnapshot` transitions. That is
  weaker than `as-cooked-packaging-runtime/spec.md`, which requires an exact warm
  restore with zero frontend work, stable-generation recovery, record-level
  FunctionBody-only change evidence, and structural-record closure evidence.
- Decision/resolution: keep the C++ session report as online observation and the
  Python Cache V2 decoder/diff as offline persisted-record observation. Upgrade
  the package reader to accept explicitly supported schemas `1` and `2`, require
  schema-2 provenance for V7.6, enable bounded startup decision tracing before
  Engine initialization, and correlate every launch with its actual Store. Add a
  structural unchanged-warm launch. Compare persisted generations by semantic
  record owner so a body edit must change the fixture FunctionBody while retaining
  its TypeSchema and ModuleState identities; a structural edit must change the
  expected ModuleInterface/TypeSchema closure. Do not infer these properties from
  source hashes or logs alone, and do not give PowerShell/Python cache-selection
  authority.
- Required evidence: PowerShell helper RED/GREEN for schema evolution and
  provenance/trace assertions; Python dump tests remain GREEN; real Development
  and Shipping package matrices produce complete per-launch reports, Store
  dumps/diffs and nonzero invalid-source exits. Each warm report must identify the
  persisted Generation and a successful exact StartupRestore, and its Store must
  correlate exactly with the C++ publication.
- Task impact/evidence: V7.6 remains open until both configurations satisfy the
  strengthened matrix. This changes diagnostic/test orchestration only unless a
  missing pre-initialization trace or frontend-counter seam is proven; persisted
  Manifest/Pack selection and wire formats remain unchanged.

## IC-426 — The first trace GREEN build exceeded the wrapper's default timeout

- Severity/state: verification-infrastructure timeout / fixed 2026-08-11.
- Exact boundary: adding two reflected `FAngelscriptEngineConfig` fields changed a
  public Runtime header, so UHT regenerated 14 files and UBT scheduled 103 build
  actions. `Tools/RunBuild.ps1 -Label cache-ic425-trace-green-build1` used its
  default `TimeoutMs=180000` and terminated the process tree after `183055ms`, at
  approximately action `39/103`. The log contains warnings but no compile/link
  error before termination. Artifact: `Saved/Build/
  cache-ic425-trace-green-build1/20260811_100930_087_c81c9b82`, wrapper exit `2`,
  process exit `124`.
- Decision/resolution: retain the official wrapper and rerun serially in the same
  worktree with an explicit timeout large enough for the header-driven rebuild.
  Do not bypass UBT, launch tests against a partially linked binary, or classify
  timeout as Runtime correctness evidence.
- Required evidence: the rerun must link successfully, then the focused
  SettingsAndShutdown prefix and PowerShell package-helper self-test must pass.
- Task impact/evidence: V7.6 stays open. No source behavior or cache schema is
  changed to accommodate the timeout; final resolution will record the successful
  artifact and duration for future wrapper sizing.
- Final evidence: the official rerun with `-TimeoutMs 600000` rebuilt/linked all
  remaining `64/64` actions in `80339ms`, wrapper/process `0/0`, at
  `Saved/Build/cache-ic425-trace-green-build2/
  20260811_101303_001_aadc89f0`. The strengthened SettingsAndShutdown prefix then
  passed `4/4` at `Saved/Tests/cache-ic425-trace-green-test1/
  20260811_101435_672_a1fced77`; the PowerShell helper self-test also passed.

## IC-427 — Development package exposed Editor-only metadata reads in Runtime

- Severity/state: packaged Runtime compile blocker / Development compile boundary
  fixed 2026-08-11; independent Shipping evidence remains part of open V7.6.
- Exact boundary: the first real V7.6 command,
  `Tools/RunAngelscriptCachePackageSmoke.ps1 -Configuration Development -Label
  cache-v76-development1 -TimeoutMs 3600000`, reached the non-editor Game target
  and failed in `Dump/AngelscriptOfflineSymbolMetadata.cpp`. That Runtime source
  unconditionally reads `UClass::ClassGeneratedBy`, `FProperty::GetMetaData` and
  `UFunction::GetMetaData`, members unavailable when `WITH_EDITORONLY_DATA=0`.
  Editor builds and automation therefore did not cover the package compile
  boundary. Artifact: `Saved/CachePackage/
  cache-v76-development1-Development/20260811_102129_188_f5e80d4f`; RunUAT/UBT
  exit `6`, package wrapper `1`, no archive layout or launch phase.
- Decision/resolution: keep offline metadata projection in the Runtime module but
  guard only the Editor-only provenance/metadata observations with
  `WITH_EDITORONLY_DATA`. Non-editor builds retain type-based soft-resource
  fallback and omit unavailable Blueprint-generator flags rather than inventing
  metadata. Do not add Runtime dependencies on UnrealEd/BlueprintGraph.
- Required evidence: Development Game target compiles through the maintained
  package wrapper, followed by the real launch matrix. Shipping must compile the
  same guarded path independently.
- Task impact/evidence: V7.6 remains open, but the second maintained package run
  built the Development Game target and entered Cook, proving this exact compile
  blocker is removed. The later Cook failure is separately owned by IC-429 and is
  not Cache restore evidence. Artifact: `Saved/CachePackage/
  cache-v76-development2-Development/20260811_102455_217_0116972d`; package log
  `Package/Package/cache-v76-development2-Development-package/
  20260811_102455_635_f4c388d8/Package.log`.

## IC-428 — Zero-phase package failure could not serialize its own summary

- Severity/state: package-smoke failure-reporting defect / fixed 2026-08-11.
- Exact boundary: after IC-427 caused packaging to fail before any launch phase,
  the runner's `finally` block evaluated `Phases = @($phaseRecords)` where
  `phaseRecords` is an empty `System.Collections.Generic.List[object]`. Windows
  PowerShell raises `Argument types do not match` for that enumeration, masking
  the original failure and preventing `Summary.json`/`RunMetadata.json` from
  being written. A direct shell reproduction with an empty generic list produces
  the same exception, while `@($list.ToArray())` succeeds with count zero.
- Decision/resolution: materialize the generic list through `ToArray()` at the
  JSON DTO boundary. Preserve the original failure string and always emit a
  deterministic zero-phase failed summary.
- Required evidence: a focused zero-list reproduction and package-helper syntax/
  self-tests pass; rerunning a real package failure or success must leave readable
  Summary/RunMetadata rather than throwing from `finally`.
- Task impact/evidence: diagnostics/orchestration only; no Runtime, Store or
  persisted wire behavior changes. The direct empty-list reproduction and helper
  syntax/self-tests pass. The second real Development run failed before launch yet
  still wrote readable `Summary.json` and `RunMetadata.json` with `PhaseCount=0`,
  `Phases=[]`, and the original `RunPackage failed` message at `Saved/CachePackage/
  cache-v76-development2-Development/20260811_102455_217_0116972d`.

## IC-429 — Cook used XGE shader workers even when deterministic local packaging was required

- Severity/state: external Cook executor blocker / fixed and real Cook GREEN
  2026-08-11.
- Exact boundary: the second real Development package built the Game target and
  completed Cook work (`LogCook: Done!`, all `6905/6905` distributed shader jobs
  completed), but `UnrealEditor-Cmd` exited `1` because XGE's named-pipe threads
  emitted the handled ensure `GetShadowIndex() == 0`. The unique warning/error
  summary contains no non-`LogOutputDevice` errors: its reported `17 error(s)` are
  repeated lines from the same XGEController/XGEControlWorker ensure stacks. RunUAT
  then mapped the commandlet exit to `Error_UnknownCookFailure`/`25`. Artifact:
  `Saved/CachePackage/cache-v76-development2-Development/
  20260811_102455_217_0116972d`; exact package log under `Package/Package/
  cache-v76-development2-Development-package/
  20260811_102455_635_f4c388d8/Package.log`.
- Decision/resolution: give the maintained package wrapper a first-class `-NoXGE`
  mode and use it for the Cache package matrix. It must pass UAT `-noxge` for the
  C++ build executor **and** pass `-noxgeshadercompile` through
  `-AdditionalCookerOptions` to the Cook commandlet; UAT's `-noxge` alone does not
  disable `XGEController` shader compilation. Build the final argument list in one
  pure helper used by production and tests, preserve extra arguments, and record
  the selected mode in package metadata. Do not suppress handled ensures or edit
  installed UE/XGE code.
- Required evidence: a PowerShell RED must show that current package argument
  construction cannot express the paired UAT/Cook contract; GREEN must assert
  both arguments, unchanged default behavior, extra-argument preservation and
  production wrapper delegation. The next real Development package log must show
  `-noxgeshadercompile` on the commandlet line, no XGE controller initialization,
  no named-pipe ensure, and progress beyond Cook into the launch matrix.
- Task impact/evidence: this is a V7.6 execution prerequisite, not a Cache schema,
  selection or restore change. Any Cache capture/restore warning revealed after
  Cook succeeds receives a new issue and must not be attributed to IC-429.
- RED/GREEN evidence: the focused PowerShell RED failed because
  `New-AngelscriptPackageRunnerArguments` did not exist. The minimal production
  implementation now owns the UAT argument list, `RunPackage.ps1` delegates to it
  and records `NoXGE`, and the Cache package runner opts in explicitly. The focused
  helper GREEN passes default-mode, paired `-noxge` plus
  `-AdditionalCookerOptions=-noxgeshadercompile`, caller-extra preservation and
  production-delegation assertions. The real `cache-v76-development3-noxge`
  package then completed Build/Cook/Stage/Archive with RunUAT exit `0` in about
  `41s`. Its log contains three command/parameter occurrences of
  `-noxgeshadercompile`, zero `Initialized XGE controller`, zero `Using XGE
  Controller for shader compilation`, zero handled ensures, and `BUILD
  SUCCESSFUL`. The subsequent failure belongs to IC-430's package-layout reader.

## IC-430 — Package layout discovery interpreted the archive's parent `Saved` as packaged content

- Severity/state: package-smoke layout prerequisite / fixed and real launch
  reached Runtime Cache capture 2026-08-11.
- Exact boundary: IC-429's real Development rerun completed Build/Cook/Stage/
  Archive with RunUAT exit `0`, but `Resolve-AngelscriptPackagedExecutable`
  returned zero candidates. Its exclusion predicate inspected each absolute path
  and rejects any `\\Saved\\` segment. Because the maintained runner intentionally
  writes the whole disposable archive below worktree `Saved/CachePackage`, every
  real archive member was rejected before package-relative layout was considered.
  The archive also contains the normal pair `Windows/AngelscriptProject.exe` and
  `Windows/AngelscriptProject/Binaries/Win64/AngelscriptProject.exe`; recursive
  basename matching would become ambiguous after merely fixing the absolute-path
  bug. Artifact: `Saved/CachePackage/cache-v76-development3-noxge-Development/
  20260811_103508_163_9b73e608`.
- Decision/resolution: evaluate Pak/UFS/Saved exclusions only against a path
  proven relative to the disposable archive root. Resolve the executable from the
  canonical platform-root launcher (one directory below Archive), not by recursive
  basename search that also selects its nested implementation binary. Continue to
  require exactly one canonical launcher and one loose package-relative Script
  root; do not weaken containment checks or scan outside the archive.
- Required evidence: a PowerShell RED fixture whose archive itself is under a
  `Saved/CachePackage/.../Archive` parent and contains both real executable levels
  must fail with the existing zero-candidate behavior. GREEN must select only the
  root launcher, still reject two root launchers, exclude Script trees under
  package-relative Pak/UFS/Saved, and pass the complete helper suite. Reuse the
  successfully archived Development package with `-SkipPackage` and require the
  real launch matrix to progress beyond layout validation.
- Task impact/evidence: V7.6 remains open; this changes only disposable package
  discovery. It does not change staged source policy, Runtime selection, Store or
  persisted formats. The focused RED now fails exactly with `found 0: <none>` on
  the Saved-parent fixture.
- GREEN evidence: package exclusions now operate on a containment-checked path
  relative to Archive, and executable discovery examines only platform-root
  launchers. The focused helper suite passes with a Saved-parent archive, both the
  canonical root launcher and nested implementation binary, deliberate duplicate
  root-launcher rejection, and Pak/UFS/Saved Script exclusions. Reusing the exact
  successful Development archive with `-SkipPackage` selected
  `Archive/Windows/AngelscriptProject.exe`, found the one loose Script root,
  launched the packaged process and reached cold Cache capture/publication. The
  process-report failure after shutdown is separately owned by IC-431.

## IC-431 — An uninitialized subsystem-owned Engine overwrote the primary process report at exit

- Severity/state: process-observation ownership defect / fixed in C++ and real
  packaged process 2026-08-11.
- Exact boundary: the first real packaged cold process compiled, published Tx=1,
  flushed Current successfully and wrote the requested schema-2 report. A second
  `FAngelscriptEngine` then logged an empty shutdown flush and wrote the same path,
  leaving `lastTransactionOrdinal=0` and `current.present=false`. The subsystem
  owns an inline default-constructed `FAngelscriptEngine`; template/CDO or other
  never-initialized instances still parse process-wide `-as-cache-report`, create
  a Cache service in their constructor, and `Shutdown()` currently flushes/reports
  without requiring `Engine != nullptr`. Artifact/log/report: `Saved/CachePackage/
  cache-v76-development3-noxge-Development/20260811_103508_163_9b73e608/
  Archive/Windows/AngelscriptProject/Saved/CachePackageSmoke/{Logs,Reports}/
  01-cold.{log,json}`.
- Decision/resolution: automatic Store flush and process-report publication are
  lifecycle privileges of an Engine that actually initialized its AS engine.
  Capture that fact before shutdown mutation; an uninitialized host may close its
  private empty Cache service but must not touch Store or a process-level report.
  Preserve idempotent repeated shutdown and keep explicit diagnostic APIs usable
  for callers that intentionally inspect an uninitialized test service.
- Required evidence: a focused C++ RED writes a sentinel process report, constructs
  an Engine with the same report override but never initializes it, calls shutdown
  and proves the sentinel is currently overwritten. GREEN must preserve the file;
  the existing initialized shutdown Store/report tests must remain GREEN. Rebuild,
  rerun the focused SettingsAndShutdown prefix, then resume the same Development
  archive and require the cold report to retain Tx=1/Current after process exit.
- Task impact/evidence: this strengthens V6.3 diagnostics/lifecycle ownership and
  is required by V7.6 correlation. It does not change report schema, Store format,
  selection or restore behavior. Complex module capture rejection is a separate
  next issue once the authoritative cold report is retained.
- RED/GREEN evidence: official build
  `Saved/Build/cache-ic431-report-owner-red-build1/
  20260811_104048_582_4ed2055b` linked the new owner test. The focused RED at
  `Saved/Tests/cache-ic431-report-owner-red-test1/
  20260811_104127_002_72460acd` was exactly `4/5`: only the new method failed and
  logged the uninitialized Engine writing the sentinel path. Shutdown now captures
  whether an AS Engine existed before mutation and permits automatic Store flush/
  report only for that owner. Official GREEN build
  `Saved/Build/cache-ic431-report-owner-green-build1/
  20260811_104233_424_5825a52e` succeeded, and the focused GREEN at
  `Saved/Tests/cache-ic431-report-owner-green-test1/
  20260811_104304_961_e5d19ff4` passed `5/5`. IC-431 remains open until a newly
  packaged binary retains the primary cold report after real process shutdown.
  The new `cache-v76-development4-report-owner` Development package did so: its
  final `01-cold.json` retains schema `2`, Tx=`1`, `current.present=true`, one
  persisted module and `restoredFromStore=false`. The next failure is the offline
  decoder mismatch owned by IC-432.

## IC-432 — Python Dump modeled canonical byte-array lengths as `uint32` while C++ writes `uint64`

- Severity/state: offline real-Store decoder defect / fixed in Python regressions
  and proven read-only against the exact packaged Store 2026-08-11.
- Exact boundary: the first authoritative packaged cold report and Store are
  valid and C++ reports 11 persisted records/9252 canonical payload bytes, but
  `cache_v2_dump.py --generation Current` exits `2` with
  `COUNT_TOO_LARGE: Dependency count exceeds limit`. C++
  `FAngelscriptArtifactCanonicalWriter::WriteByteArray` writes a little-endian
  `uint64` length, and the C++ FunctionBody/DebugSidecar readers consume that
  contract. Python `Reader.byte_array()` reads only `u32`; its test `_byte_array`
  helper also emits `u32`, so synthetic writer and reader agreed with each other
  while disagreeing with production. The extra four high-length bytes shift the
  VM payload and dependency-count cursor in every real FunctionBody.
- Decision/resolution: C++ persisted bytes are authoritative and remain unchanged.
  Change the offline reader and fixture builder to the canonical `uint64` length,
  retain the existing bounded size check, and add a direct payload test whose
  bytes are constructed independently with `_u64`. Do not downgrade a failed
  payload summary to success or skip record decoding in the package matrix.
- Required evidence: the direct C++-width payload test must fail against the old
  Python reader, then the entire Python suite must pass with the corrected width.
  Run the tool read-only against the exact packaged cold Store and require `ok`,
  integrity success, one selected Generation and C++ session correlation. Run a
  fresh Development matrix so its cold baseline is not contaminated by the
  partially completed earlier archive.
- Task impact/evidence: this repairs V6.3/V7.6 observability only; no Runtime,
  Store schema, content hashes, selection or restore semantics change. Artifact:
  `Saved/CachePackage/cache-v76-development4-report-owner-Development/
  20260811_104406_673_43fc0e1f`.
- RED/GREEN evidence: the independent `uint64` payload regression failed against
  the former `u32` reader with `COUNT_TOO_LARGE` while the former synthetic tests
  still agreed with their incorrect fixture writer. `Reader.byte_array()` and the
  fixture helper now use the canonical `uint64`; the only first-rerun differences
  were the expected FunctionBody raw size plus derived record, ModuleSnapshot,
  Pack, Generation and pointer hashes. After reviewing those exact semantic
  differences and updating both deterministic goldens, the maintained wrapper
  passed `21/21` at `Saved/Tests/cache-v2-dump/
  cache-ic432-python-u64-green2`.
- Real-Store evidence: the corrected tool returned exit `0` and `ok=true` when
  reading the exact package above with `--generation Current --session-report
  Reports/01-cold.json`. It selected one Generation
  `5db033b13642e4fdc3b2a0c8fc67c52b9b5ee31db2df7ed43301f4b8861e0766`,
  decoded all 11 records (three FunctionBody and three DebugSidecar records), and
  reported `generation_id_matches=true`, `manifest_pack_links_match=true`, Pack
  identity true, Current pointer checksum true and every record identity true.
  Both present C++ publications (`Current` and `LatestSuccessful`, Tx=1) correlated
  to that Generation with exact matches and zero mismatches; the absent
  `PendingColdStart` correctly had no candidate. IC-432 is therefore closed; the
  next fresh Development warm launch owns any complex-module admission/restore
  gap and receives IC-433 rather than weakening the dump decoder.

## IC-433 — Module-graph debug membership binary-searched SourceIndex in the wrong canonical order

- Severity/state: real packaged unchanged-warm restore blocker / false membership
  fixed in C++ and removed from a fresh Development package 2026-08-11; the
  remaining incomplete module-shape coverage is split to IC-434.
- Exact boundary: the fresh maintained wrapper command
  `Tools/RunAngelscriptCachePackageSmoke.ps1 -Configuration Development -Label
  cache-v76-development5-python-u64 -TimeoutMs 3600000` completed Build/Cook/
  Stage/Archive and the cold process, but its unchanged second process compiled
  again instead of restoring. Cold capture admitted only 1 of 11 candidate modules;
  four otherwise capturable modules (`Game.CacheSmoke.CachePackageSmoke`,
  `Tests.Test_ActorLifecycle`, `Tests.Test_MathNamespace` and
  `Tests.Test_SystemUtils`) failed graph validation identically with `Error=62
  (DebugSourceMismatch), Class=5, Kind=7, Stage=5, Offset=108`. Offset 108 is the
  first DebugSidecar `SourceFileKey`, not the Sources container, proving the debug
  payload and sidecar agree but graph membership incorrectly says that key is
  absent. Six additional modules remain explicitly `NotCacheable` and will be
  owned by a subsequent issue after this false rejection is removed. Artifact:
  `Saved/CachePackage/cache-v76-development5-python-u64-Development/
  20260811_105355_778_6118560f`; summary failure is `Scenario 'Warm' expected
  Current to be restored from Store.`
- Root cause: `FAngelscriptCachedSourceIndex::Files` is canonically ordered by
  `SourceKind`, MountKey, ProviderKey, logical path and only finally SourceFileKey
  (`CompareSourceFile`). `SourceIndexContainsFile` instead performs a binary
  search as if the same array were ordered primarily by SourceFileKey. That search
  is valid only accidentally for some small/order-compatible fixtures; the real
  eleven-file index contains each rejected debug key but returns false for most of
  them. This is a validator lookup-authority bug, not a missing debug source, source
  hash change or reason to weaken graph validation.
- Decision/resolution: keep SourceIndex canonical wire order unchanged. Replace
  the invalid search with one lookup whose algorithm matches the actual order;
  for the bounded per-module graph validation path, a deterministic linear
  membership scan is sufficient and allocation-free unless measurement later
  justifies a separately built key index. Add a multi-file graph regression whose
  canonical SourceIndex order deliberately differs from SourceFileKey order and
  whose DebugSidecar references an existing non-key-sorted file; it must RED on
  the current binary search and GREEN after the lookup correction. Preserve the
  existing missing-file rejection test.
- Required evidence: focused C++ RED/GREEN through the official build/test
  wrappers, then a fresh Development package cold launch must remove all four
  `DebugSourceMismatch` rejections. The following unchanged launch may still miss
  because the six explicitly unsupported module shapes prevent a complete batch;
  that outcome must be recorded separately rather than treating this false-
  membership fix as full V7.6 completion.
- Task impact/evidence: this repairs V1.4 graph correctness exposed by V7.6 and
  changes no persisted bytes, stable identity, source selection or invalidation
  policy. V7.6 remains open.
- RED/GREEN evidence: official RED build
  `Saved/Build/cache-ic433-source-order-red-build1/
  20260811_110014_429_b4e9f03e` linked the 16-file regression. The first attempted
  method-only Automation prefix matched no CQTest entry and executed nothing; the
  correct class prefix RED at `Saved/Tests/cache-ic433-source-order-red-test2/
  20260811_110135_262_c3a6ec2a` was exactly `12/13`, with only
  `DebugSourcesRequireExactCodecRowsAndSourceIndexMembership` failing its new
  existing-file success assertion. `SourceIndexContainsFile` now performs an
  allocation-free scan over the actual canonical array, while the test retains
  the missing-file case. Official GREEN build
  `Saved/Build/cache-ic433-source-order-green-build1/
  20260811_110229_540_76331e95` succeeded and the same complete class prefix at
  `Saved/Tests/cache-ic433-source-order-green-test1/
  20260811_110252_388_f4878ec3` passed `13/13`. IC-433 remains open only for the
  required fresh Development package proof that the four real false rejections
  disappear.
- Real package GREEN evidence: the fresh maintained command with the fixed Game
  binary, label `cache-v76-development6-source-order`, completed package/cold and
  advanced capture from `1/11` to `5/11`; neither cold nor unchanged-warm logs
  contain a `Compile capture rejected module` or `DebugSourceMismatch`. All four
  formerly rejected modules are present in the five-module publication. Artifact:
  `Saved/CachePackage/cache-v76-development6-source-order-Development/
  20260811_110450_868_03ef8515`. The warm selector reused and integrity-validated
  Generation `a8ff7a54e697347395685f91fa1df2abf009490205edca622e255195c0c213fe`,
  then correctly missed with typed ExactStartup reason `9` (`ModuleSetMismatch`)
  because the persisted five-module set cannot stand in for the discovered
  eleven-module Engine. This proves IC-433 without weakening atomic batch restore;
  IC-434 owns the six remaining explicit `NotCacheable` shapes.

## IC-434 — Exact startup cannot restore while clean capture admits only narrow enum/root-class shapes

- Severity/state: core real-project module coverage blocker / Development package
  RED with exact unsupported shapes captured, design/implementation open
  2026-08-11.
- Exact boundary: after IC-433 removed all false graph rejections, the fresh cold
  process discovered 11 source modules but published only five complete module
  graphs. Six modules returned the intentional clean-capture `NotCacheable` result:
  `Game.Example_Actor` reports `The class is outside the first root-UClass
  primitive capture shape`; `Tests.Test_Enums`, `Tests.Test_GameplayTags`,
  `Tests.Test_Handles`, `Tests.Test_Inheritance` and
  `Tests.Test_ReflectedScriptSuites` all report `Clean capture currently requires
  exactly one source and either one enum or one root class, with no delegate,
  import or post-init declarations`. The unchanged process first reused the valid
  Store Generation, then typed-missed with `ExactStartup::ModuleSetMismatch`
  because five persisted module snapshots cannot atomically replace the current
  eleven-module Engine; it correctly fell back to normal compilation and published
  another five-module Generation. Artifact: `Saved/CachePackage/
  cache-v76-development6-source-order-Development/
  20260811_110450_868_03ef8515`.
- Observability evidence: the isolated package launch now passes
  `-LogCmds="Angelscript Verbose"`; its PowerShell helper first RED because no
  detailed-log argument existed and then passed after adding it. The full
  `Saved/Logs/AngelscriptProject*.log` therefore retains every skipped module and
  exact `CaptureResult.Detail` while normal game/editor logging defaults remain
  unchanged. The copied phase log intentionally contains only stdout and is not
  the authority for Verbose entries.
- Decision/resolution: do not relax `ModuleSetMismatch`, publish a fake complete
  generation, remove real package source modules, or declare skipped modules
  acceptable. Expand the maintained-fork/Runtime capture and restore model to the
  actual module forms in this package. First inventory each module's authoritative
  AS/descriptor/VM shape and group gaps by semantic capability (multiple or mixed
  declarations, methods/inheritance, handles/environment reference types,
  delegates/imports/post-init, reflected members), then add the smallest complete
  record/restore seams that cover those groups. A module is admitted only when its
  complete declaration/type/state/function/debug graph can round-trip and execute
  in a fresh Engine; uncertainty remains `NotCacheable` until supported, but final
  V7.6 requires the full discovered package set.
- Required evidence: add focused RED/GREEN integration tests for every distinct
  shape found in the six modules, including two-Engine restore and observable
  execution/class/type checks. Run affected Cache prefixes and a full Runtime/Test
  build, then a fresh Development cold launch must publish `11/11` and the
  unchanged launch must restore all 11 with zero preprocess, parse, module-compiler
  and function-compiler calls and no redundant Generation. Only then continue the
  edit/invalid/structural phases.
- First vertical RED evidence: the new isolated two-Engine test
  `Angelscript.TestModule.Cache.GlobalFunctionOnlyRestore` compiles a module with
  zero types and two executable global functions, requires pointer-free capture,
  generation validation, fresh-Engine restore, stable-route publication and
  observed results `41/42`. Official build artifact
  `Saved/Build/cache-ic434-global-only-red-build1/
  20260811_111313_672_fc9f2f5e` succeeded. The focused RED artifact
  `Saved/Tests/cache-ic434-global-only-red-test1/
  20260811_111424_826_94c8168d` is exactly `0/1`; its only failure is capture
  error `NotCacheable` with the current one-enum-or-root-class guard. This fixes
  the intended production boundary before implementation and represents the four
  real global-only package modules without editing their checked-in AS sources.
- First vertical GREEN evidence: capture now models the enum as optional instead
  of synthesizing a fake type, and restore consumes every validated global
  FunctionBody/DebugSidecar pair, materializes zero-or-one enum, checks route
  uniqueness, then publishes the module's complete route array in the existing
  atomic batch commit. Official product build
  `Saved/Build/cache-ic434-global-only-green-build1/
  20260811_112055_564_384f3d1a` succeeded. The first test attempt at
  `Saved/Tests/cache-ic434-global-only-green-test1/
  20260811_112114_329_b30bfb29` proved capture `8` records and restore
  `0 types / 2 functions` but failed only because CQTest cannot stringify
  `FAngelscriptHash256` for `AreNotEqual`; no product assertion failed. After the
  test used an explicit boolean hash inequality, official build
  `Saved/Build/cache-ic434-global-only-green-build2/
  20260811_112214_596_17dc8fcd` succeeded and focused artifact
  `Saved/Tests/cache-ic434-global-only-green-test2/
  20260811_112236_437_bde3f42d` passed `1/1`, executing both restored functions
  as `41/42` in a fresh Engine and resolving two distinct stable routes.
- Adjacent regression evidence: the generalized route-array restore preserves
  the previous enum/function path, producer destruction, independent Engine
  routes and late-failure rollback at
  `Saved/Tests/cache-ic434-global-only-regression-fresh-restore1/
  20260811_112333_219_68175b2b` (`4/4`); exact unchanged startup and relocation at
  `Saved/Tests/cache-ic434-global-only-regression-exact-warm1/
  20260811_112437_929_5aafd5d1` (`4/4`); and deduplicated multi-module/partial
  publication at
  `Saved/Tests/cache-ic434-global-only-regression-multi-module1/
  20260811_112537_678_74730e1c` (`2/2`).
- Real package evidence after the first vertical: maintained Development command
  label `cache-v76-development7-global-only` rebuilt the Game target, cooked,
  staged and archived successfully, then advanced complete capture from `5/11`
  to `9/11`. Artifact:
  `Saved/CachePackage/cache-v76-development7-global-only-Development/
  20260811_112626_387_2e0947e7`. Only `Game.Example_Actor` remains outside the
  method-bearing root-class shape and `Tests.Test_ReflectedScriptSuites` remains a
  multi-class shape. The unchanged launch reused the valid persisted Generation
  `899327e169bae99b5019fe954cf10cdcc29a104cedad46b829340ed5955c0d81`, typed-
  missed with ExactStartup reason `9` because the nine-module set is not the
  discovered eleven-module set, then safely compiled and published nine again.
  This is the expected intermediate RED, not warm-restore completion.
- Second vertical RED evidence: the independent test
  `Angelscript.TestModule.Cache.RootClassRestore` fixes the next acceptance shape
  as one `UObject`-rooted script class carrying a reflected integer property, one
  script-only method, one reflected `UFUNCTION`, a cross-method/property
  dependency and an observable defaulted result of `42`.  The producer Engine is
  destroyed before generation validation; a separate isolated full Engine must
  restore the type/function graph, recreate the UClass/UProperty/UFunction,
  construct a UObject and execute the reflected entry point.  Official build
  `Saved/Build/cache-ic434-root-class-red-build1/
  20260811_113915_801_337c7387` succeeded.  The focused RED artifact
  `Saved/Tests/cache-ic434-root-class-red-test1/
  20260811_113936_679_3e04b6de` is exactly `0/1`: preprocessing, compilation and
  ClassGenerator succeeded, then capture alone returned `NotCacheable` with
  `The class is outside the first root-UClass primitive capture shape`.  This
  proves the missing reflected-method admission before any Runtime or maintained-
  fork class materializer is added.
- Task impact/evidence: reopens the practical completeness assumption behind
  V3.4/V3.5/V5.5 for real module shapes while V7.6 remains open. It does not change
  the accepted stable-key, semantic-record or atomic-activation architecture; the
  implementation may extend any maintained AngelScript fork seam under the
  existing OpenSpec scope guard.

## IC-437 — Cold opaque validation assumes the selected script class already exists

- Severity/state: fresh-Engine class-function restore blocker / reproduced and
  open 2026-08-11.
- Exact boundary: IC-436 graph closure made the focused root-class producer
  capture fully green as `13` pointer-free, graph-validated records.  Official
  build `Saved/Build/cache-ic436-root-class-graph-build1/
  20260811_115522_527_31b7b180` succeeded.  Focused artifact
  `Saved/Tests/cache-ic436-root-class-graph-test1/
  20260811_115546_608_d2c3309c` remains exactly `0/1`, but now logs capture
  `Error=0 Records=13 GraphRecords=13` before failing only in the independent
  consumer Engine: `Object type 'UCacheV2RestoredRootObject' doesn't exist`,
  restore `Error=3 Stage=2`, nested `OpaquePayloadMalformed Error=45 Kind=5
  Stage=4 Offset=51`, and maintained artifact reader detail `result=-1
  expected=97 read=51 stream=51 stage=3 error=1 new=1`.  The consumer graph's
  opaque function-body validation invokes the detached artifact reader before
  the selected TypeSchema has materialized its script object type, violating
  the specified cold-hit condition that no selected-module live type exists.
- Decision/resolution: do not precompile source or precreate unvalidated product
  objects merely to satisfy opaque validation.  Separate pointer-free execution
  payload structural/relocation validation from the later skeleton-aware commit:
  graph validation must exhaust and validate the artifact without looking up a
  selected-module live type, while materialization creates all type/function
  skeletons first and then uses the existing exact-function commit path.  Any
  maintained-fork seam added for this must remain bounded, non-executing and
  mutation-free during validation.
- Required evidence: the same consumer graph reaches Runtime materialization
  with zero selected-module types on entry; corrupt/truncated function-artifact
  tests retain exact failure stages/offsets; the later skeleton commit restores
  all four bodies and executes the reflected result as `42`.
- Task impact/evidence: blocks IC-434 class materialization and V7.6.  It does
  not permit moving TypeSchema creation ahead of graph validation or weakening
  opaque payload integrity.

## IC-436 — Module graph still rejects reconstructible object method authorities

- Severity/state: root-class exact-restore blocker / reproduced and open
  2026-08-11.
- Exact boundary: after the IC-434 root-class capture admitted reflected methods
  and populated exact `OrderedMethods`, `VirtualFunctionTable`, grouped behavior
  slots, explicit `OrderedUFunctionMembers`, declaration flags/metadata and
  declaration dependencies, official build
  `Saved/Build/cache-ic434-root-class-capture-build1/
  20260811_115005_745_68c1c337` succeeded.  Focused artifact
  `Saved/Tests/cache-ic434-root-class-capture-test1/
  20260811_115024_373_7ddcd478` remained exactly `0/1`, but advanced from the
  capture admission error to graph evidence `Error=50 MissingCoverage`,
  `Class=5 GraphOrOwnership`, `Kind=7 ModuleSnapshot`, `Stage=5 ModuleGraph`,
  `Offset=68`.  Coverage logging proves one type/schema and all four required
  function declarations/bodies exist.  Source tracing identifies the stale
  `bGraphSupportedObjectType` predicate in
  `AngelscriptCacheModuleGraph.cpp`: it accepts an object only when methods,
  VFT, behavior slots and reflected-member rows are all empty even though the
  sole TypeSchema decoder already admits and locally validates those explicit
  reconstructible authorities.
- Decision/resolution: do not weaken or skip graph validation and do not erase
  the four tables.  Extend ModuleSnapshot graph closure to resolve every method,
  VFT, script/environment behavior and reflected member against the one
  ModuleInterface declaration/environment authority, including exact entity,
  owner, ABI, local/inherited role and ordinal relationships required by the
  TypeSchema spec.  The old empty-only predicate is removed only when the
  represented coordinates have graph coverage.
- Required evidence: the same independent root-class test must pass local and
  module-graph validation and reach the next restore/materialization boundary;
  existing TypeSchema graph/malformed tests remain green.  Later GREEN requires
  the fresh Engine to reproduce method/VFT/behavior/reflection tables and invoke
  the restored UFunction as `42`.
- Task impact/evidence: reopens the runtime completeness assumption behind
  V3.4/V3.5 and blocks V7.6 exact startup, without changing stable-key or wire
  authority.  It is the graph half of IC-434's first class-bearing vertical.

## IC-435 — Packaged delegate bindings emit reserved type names as parameter names

- Severity/state: independent packaged startup binding error / reproducible and
  open 2026-08-11; not attributed to Cache V2.
- Exact boundary: every real Development package launch used for IC-433/IC-434
  logs twelve `RegisterObjectMethod(... asINVALID_DECLARATION)` errors for the
  test delegate families `FTestDynamicDelegateFloat`,
  `FTestDynamicDelegateInt64`, their out forms, and corresponding multicast
  forms. Generated declarations include `void Execute(float32 float)`,
  `void Execute(int64 int64)`, `ExecuteIfBound` equivalents and `Broadcast`
  equivalents. The parser rejects the second token because `float` and `int64`
  are reserved type keywords when reused as parameter identifiers. Latest
  authoritative reproduction is the cold and unchanged logs beneath
  `Saved/CachePackage/cache-v76-development7-global-only-Development/
  20260811_112626_387_2e0947e7/Archive/Windows/AngelscriptProject/Saved/Logs`.
- Decision/resolution: keep this separate from IC-434's module graph work and do
  not weaken packaged-log acceptance. Trace whether the invalid name originates
  in reflected test declarations, generated binding metadata or the common AS
  declaration-name sanitizer; fix the single owning conversion path so all
  generated callable declarations receive legal deterministic parameter names.
  Do not special-case these twelve delegate types or suppress registration
  errors.
- Required evidence: source/generated-output trace to one owner; focused RED/GREEN
  covering `float`, `int64`, out and multicast declarations; official build and
  binding prefix; then a fresh packaged launch with zero matching
  `asINVALID_DECLARATION` rows and no lost delegate registrations.
- Task impact/evidence: no Cache V2 record, identity, selection or invalidation
  semantics should change. IC-435 is required for clean final Development and
  Shipping startup evidence but must not delay the next IC-434 class-shape RED.

## IC-438 — Pointer-free relocation evidence must not make function-content identities recursive

- Severity/state: cold-validation format boundary / reproduced during IC-437
  implementation and in progress 2026-08-11.
- Exact boundary: the maintained VM artifact can produce exact instruction/
  operand symbol-use coordinates only while its owner types and referenced
  symbols are live. Persisting those stable relocation rows is the selected
  fix for IC-437, but naively hashing the complete envelope as the function's
  execution-content identity makes a caller's content hash include the callee's
  expected content hash. Mutual recursion would then require circular hashes,
  and even an acyclic caller would retain the callee's pre-envelope rather than
  final identity during one-pass capture.
- Decision/resolution: execution codec `5` is a canonical two-layer envelope.
  Its pointer-free outer layer stores the stable ordered relocation manifest;
  its inner layer remains the maintained-fork VM artifact. The FunctionBody
  execution-content identity hashes only the inner VM artifact, while the
  ordinary canonical FunctionBody record ID protects every byte of the outer
  manifest and inner payload together. Cold graph validation decodes the outer
  layer without selected-module live objects and returns the inner execution
  hash plus stable relocations. After all type/function skeletons exist, restore
  deep-validates the inner artifact against the current Engine, regenerates its
  relocations and requires exact equality with the persisted manifest before
  committing executable state. The manifest is evidence, not a second symbol-
  selection authority.
- Required evidence: existing global-function and relocation/dependency tests
  remain green under codec `5`; the root-class consumer graph succeeds before
  any selected type exists; corrupt envelope, inner artifact and manifest
  mismatch each fail closed; recursive/cross-function content identity remains
  deterministic; later skeleton commit restores the reflected result `42`.
- Task impact/evidence: implements the pointer-free half of IC-437 and supplies
  the stable relocation/debug surface requested for StaticJIT and cache dump
  tooling. It does not relax graph dependency-subset checks or permit legacy
  codec fallback; old cache compatibility is explicitly out of scope.

## IC-439 — Fresh restore used empty resolvers for UE code-root environment authorities

- Severity/state: cold root-class graph blocker / reproduced and implementation
  in progress 2026-08-11.
- Exact boundary: codec `5` moved the independent consumer past IC-437's live-
  type opaque parse. Official build
  `Saved/Build/cache-ic438-execution-envelope-build2/
  20260811_121143_488_3c4afeab` succeeded and global-function cold restore
  remained `1/1` at
  `Saved/Tests/cache-ic438-global-regression2/
  20260811_121157_976_f502fd13`. The root-class run at
  `Saved/Tests/cache-ic438-root-class-envelope1/
  20260811_121242_464_1a009d37` then failed later in current resolution with
  `CurrentSymbolMissing Error=64 Stage=6 Offset=1745`. Replacing only the empty
  symbol resolver with the AS environment resolver did not change the result.
  Added failure diagnostics at
  `Saved/Tests/cache-ic438-root-class-diagnostics1/
  20260811_121650_550_66e35675` identified the exact missing authority as
  `EnvironmentSymbol / EnvironmentAbi`, stable key
  `7d8191b3...431087c`: the reflected C++ code root captured for the script
  class, which the producer's private resolver knew but the consumer's empty
  symbol/layout resolvers could never reproduce.
- Decision/resolution: make code-root identity and layout current-Engine
  authorities, not clean-capture-local test knowledge. The shared environment
  identity derives the same path/superclass ABI reference for a `UClass`; the
  Engine symbol resolver considers registered AS environment types/functions
  plus reflected code roots; and a shared layout resolver supplies the current
  `UClass::GetPropertiesSize()` boundary, registered shadow-type alignment and
  environment type storage. Restore uses these resolvers before materialization.
  Selected script declarations remain graph-local and are never looked up as
  pre-existing current symbols.
- Required evidence: root-class graph validation must advance beyond stage `6`
  with no current-symbol/layout warning; code-root ABI or boundary mutation must
  still reject; existing environment identity/layout tests and global cold
  restore remain green; final class skeleton execution still returns `42`.
- Task impact/evidence: closes a producer/consumer authority asymmetry needed by
  IC-437 and later derived classes. It does not introduce source preprocessing,
  dependency propagation or a second identity scheme.

## IC-440 — Class restore must publish every current-ID declaration before decoding bodies

- Severity/state: class materialization correctness boundary / reproduced from
  the IC-439 root-class RED and implementation in progress 2026-08-11.
- Exact boundary: after the current-Engine environment resolvers made the full
  thirteen-record root-class graph valid, restore reached the deliberately
  narrow enum/global-function gate and rejected the class at stage `3` with
  `The optional cached type is not a reconstructible enum` in
  `Saved/Tests/cache-ic439-root-class-code-root1/20260811_122052_173_ae801301`.
  Simply decoding each member as a detached function and publishing it
  immediately is not a valid extension: method bytecode can refer to another
  method that has not yet been assigned a current Engine function id, while
  recursion and mutual recursion make every per-function ordering incomplete.
  The maintained VM full-reader, builder and StaticJIT precompiled loader all
  establish declarations and ownership before translating executable bodies.
- Decision/resolution: materialize the script object-type skeleton first, then
  allocate and register an empty current-ID `asCScriptFunction` skeleton for
  every cached member declaration. Reconstruct the type's ordered methods,
  method table, VFT, constructors/factories and behavior slots from stable
  FunctionKeys while those skeletons are empty. Only after every referenced
  numeric id exists may the function codec validate the pointer-free relocation
  manifest and atomically commit each detached donor body into its matching
  skeleton. ClassGenerator descriptors are reconstructed from the same live
  skeletons; stable FunctionKey remains the persistent identity and numeric VM
  ids remain fresh-Engine implementation details. Do not introduce a second
  StaticJIT mapping table or a dependency on function restore order.
- Required evidence: the existing isolated producer/consumer root-class test
  restores one property plus reflected and script-only methods and returns
  `42`; add recursive/cross-method coverage before widening to multiple classes;
  corrupted owner, signature, VFT or behavior references fail before activation;
  existing global cold restore remains green; diagnostics dump both stable keys
  and assigned current numeric ids.
- Task impact/evidence: this replaces the temporary enum/global-only gate with
  the first class materializer slice and is the shared declaration-publication
  seam needed by the sibling StaticJIT OpenSpec. It does not yet admit derived
  script classes, interfaces, delegates, imports, mutable globals or post-init
  actions, and it does not weaken graph validation or source-free cold restore.
- Implementation evidence update 2026-08-11: official Development Editor build
  `Tools/RunBuild.ps1 -Label cache-ic440-class-skeleton-build1 -ExtraArgs
  '-NoHotReloadFromIDE' -TimeoutMs 1800000` failed at compile-only integration
  boundaries in `Saved/Build/cache-ic440-class-skeleton-build1/
  20260811_124312_925_7f5905df`: the new code passed a
  `TOptional<FString>` itself to `TCHAR_TO_UTF8` and used UE `TArray`'s
  `IsValidIndex` name on VM `asCArray`. Both are local API-shape errors; use
  `GetValue()` and an explicit `GetLength()` bounds check. No VM ownership or
  persisted-format decision changed.

## IC-441 — Root-function capture dropped normalized read-only primitive qualifiers

- Severity/state: stable declaration reconstruction blocker / reproduced by the
  first IC-440 runtime and fixed in source 2026-08-11, GREEN evidence pending.
- Exact boundary: official Development build
  `cache-ic440-class-skeleton-build2` succeeded at
  `Saved/Build/cache-ic440-class-skeleton-build2/
  20260811_124354_277_35f96048`. The isolated root-class run
  `Tools/RunTests.ps1 -TestPrefix
  'Angelscript.TestModule.Cache.RootClassRestore' -Label
  cache-ic440-root-class-skeleton1 -TimeoutMs 600000` then advanced through
  class graph validation and type materialization but failed at stage `4` in
  `Saved/Tests/cache-ic440-root-class-skeleton1/
  20260811_124417_268_89f8f2c3`: cached declaration
  `int ScriptOnlyAdd(const int)` reconstructed without the normalized
  read-only bit. AngelScript represents that `const` on the `asCDataType` even
  for primitive by-value parameters; root capture persisted `Reference` but
  omitted `IsObjectConst()` in its primitive branch.
- Decision/resolution: persist the existing `ObjectConst` cached datatype
  qualifier for primitive function return/parameter types exactly as is already
  done for script/environment object types, and restore it through
  `asCDataType::MakeReadOnly`. Do not invent a parameter-only const flag and do
  not weaken canonical declaration equality. The name `ObjectConst` is legacy,
  but its established archive meaning is the VM datatype's read-only bit.
- Required evidence: the same root class must build an identical declaration
  skeleton, restore all four bodies and return `42`; semantic archive/graph
  tests must accept and hash the existing qualifier; a negative qualifier
  mutation must continue to invalidate declaration ABI rather than reaching
  activation.
- Task impact/evidence: no record layout or codec version changes because
  `ObjectConst` is already inside the known datatype qualifier mask. Newly
  captured generations become semantically complete; old cache compatibility
  is explicitly out of scope for this development-phase plugin.
- Implementation evidence update 2026-08-11: build
  `cache-ic441-readonly-qualifier-build1` passed at
  `Saved/Build/cache-ic441-readonly-qualifier-build1/
  20260811_124613_026_71dbe222`. The next root run
  `cache-ic441-root-class-readonly1` failed earlier during producer capture at
  `Saved/Tests/cache-ic441-root-class-readonly1/
  20260811_124630_136_0e8a104d` with semantic error `31`
  (`InvalidQualifierCombination`): both normal and exact module-interface
  validators still allowed only `Reference` on primitive datatypes. Align those
  two validators with the maintained VM by allowing `Reference | ObjectConst`
  while continuing to reject primitive handles, auto and unknown flags. The
  TypeSchema property-layout validator remains independently strict; this
  correction applies to canonical VM datatype semantics, not object storage.
- Compile follow-up: official build
  `cache-ic441-primitive-validation-build2` failed in
  `Saved/Build/cache-ic441-primitive-validation-build2/
  20260811_124817_843_42955024` because the new per-primitive allowed-mask
  constant required an explicit braced `case` scope in both normal and exact
  validators. This is a local C++ lifetime rule; braces were added with no
  semantic change.

## IC-442 — Generated invocation kinds were incorrectly collapsed into the public GeneratedFunction trait

- Severity/state: class function-skeleton ABI blocker / reproduced by the first
  post-IC-441 root-class body commit and implementation in progress 2026-08-11.
- Exact boundary: primitive datatype archive regression passed `13/13` at
  `Saved/Tests/cache-ic441-archive-primitives1/
  20260811_125036_386_4320c238`, but the isolated root-class run
  `Tools/RunTests.ps1 -TestPrefix
  'Angelscript.TestModule.Cache.RootClassRestore' -Label
  cache-ic441-root-class-readonly2 -TimeoutMs 600000` failed during atomic
  commit in `Saved/Tests/cache-ic441-root-class-readonly2/
  20260811_125234_372_0bda8290`. Engine, module, object type, function type and
  canonical declaration all matched, while the cached generated default
  constructor carried VM traits `0x02000001` and its reconstructed skeleton
  carried `0x00040001`. Maintained-fork evidence identifies these as
  `Constructor | UnsafeDuringConstruction` versus
  `Constructor | GeneratedFunction`: clean capture had forcibly mapped every
  generated invocation kind to the unrelated public `GeneratedFunction`
  declaration flag, and restore had no canonical representation for the
  remaining VM function traits. A later IC-444 diagnostic proved that
  constructor/destructor bits likewise cannot be inferred from invocation
  kind, so those two bits are also explicit members of the canonical trait
  vocabulary.
- Decision/resolution: invocation origin and function traits remain orthogonal.
  `GeneratedDefaultConstructor`, `GeneratedDefaultDestructor` and
  `InitDefaults` stay explicit invocation kinds and no longer synthesize the
  `GeneratedFunction` flag. Extend the canonical declaration-trait vocabulary
  to represent every maintained-fork script-function trait that can affect
  compilation, lookup, diagnostics or execution, including
  `UnsafeDuringConstruction`, `DefaultsOnly`, `Explicit`, editor/callability,
  discard, temporary-object, property/mixin/local/shared and related flags.
  Capture these semantic flags from `asSFunctionTraits`, include them in the
  existing declaration traits hash/module ABI, and rebuild the exact current
  VM trait set before creating any function skeleton. Constructor/destructor
  bits continue to derive from invocation kind, so the cache does not persist
  transient numeric FunctionIds or raw VM object pointers. IC-444 supersedes
  the earlier statement that constructor/destructor bits derive from
  invocation kind: invocation role and the exact VM trait set are independent
  persisted semantics.
- Required evidence: the generated default constructor must reconstruct as
  `0x02000001` and the root-class method must execute to `42`; generated default
  destructor and init-defaults skeletons must also pass exact atomic commit;
  archive validation must accept every newly known semantic bit and reject an
  unknown bit; an actual `GeneratedFunction` decorator must remain distinct
  from a generated invocation kind; global cold restore and declaration-hash
  determinism remain green.
- Task impact/evidence: this intentionally changes newly produced module-
  interface trait hashes and therefore invalidates earlier development caches;
  old cache compatibility is out of scope. It strengthens the same canonical
  declaration and stable FunctionKey/StaticJIT seam instead of adding a second
  VM-trait side table or weakening atomic body-commit checks.
- Implementation evidence update 2026-08-11: official Development Editor
  build `cache-ic442-function-traits-build1` passed at
  `Saved/Build/cache-ic442-function-traits-build1/
  20260811_130001_396_a8794f5b`. Root-class run
  `cache-ic442-root-class-traits1` advanced beyond exact constructor-trait
  comparison and into stable relocation validation, proving the original
  `0x02000001`/`0x00040001` blocker is closed; final root-class GREEN remains
  pending the newly exposed IC-443 function-symbol authority.

## IC-443 — Root-class restore omitted a current identity for a function-body relocation target

- Severity/state: cold function-relocation blocker / reproduced after IC-442
  and under investigation 2026-08-11.
- Exact boundary: `Tools/RunTests.ps1 -TestPrefix
  'Angelscript.TestModule.Cache.RootClassRestore' -Label
  cache-ic442-root-class-traits1 -TimeoutMs 600000` failed at opaque-codec
  stage `5` in `Saved/Tests/cache-ic442-root-class-traits1/
  20260811_130042_880_5974a578`. The generated default constructor passed
  signature and exact-trait comparison, then its third symbol-use row
  (`asFUNCTION_ARTIFACT_SYMBOL_FUNCTION_SIGNATURE`, numeric kind `3`) could
  not resolve to one current stable identity. The pointer-free manifest and
  declared dependency were already graph-valid, so the asymmetry is in the
  newly materialized Engine surface rather than the persisted candidate set.
- Decision/resolution: first expose the rejected current function's canonical
  declaration, namespace, module ownership, invocation kind, type owner and
  traits in codec diagnostics. Then reconstruct the missing derived/current
  declaration at the declaration-publication phase (before any body decode),
  or correct its current stable-identity adapter if the declaration already
  exists. Do not match by numeric FunctionId, skip a relocation, or accept the
  producer's pointer. Generated `StaticClass`, factory and environment helper
  functions remain candidates until the diagnostic identifies the exact row.
- Required evidence: the diagnostic must name the unresolved current function;
  the repaired declaration must resolve to the same persisted stable target and
  exact ABI; root-class restore must proceed through all relocation rows and
  execute `ReflectedValue()` as `42`; a missing or ambiguous helper declaration
  must still fail before body commit.
- Task impact/evidence: this tests whether IC-440's "all declarations first"
  invariant includes compiler/ClassGenerator-derived functions in addition to
  the four persisted executable bodies. Any derived declaration remains keyed
  through its owning TypeKey and must be visible to the sibling StaticJIT seam;
  it is not promoted to an independently cached user function unless its own
  execution body requires that representation.
- Diagnostic update 2026-08-11: official build
  `cache-ic443-symbol-diagnostics-build1` passed, and rerun
  `cache-ic443-symbol-diagnostics1` at
  `Saved/Tests/cache-ic443-symbol-diagnostics1/
  20260811_130346_841_341d4d69` identified the row exactly as the generated
  default constructor itself: declaration `UCacheV2RestoredRootObject()`,
  current module, invocation `6`, correct `objectType`, traits `0x02000001`,
  but null `artifactOwnerType`; stable-key construction therefore failed with
  `Function type owner cannot resolve to one local stable TypeKey`. Restore must
  set the semantic owner on every type-owned skeleton, including global-shaped
  factories, just as `asCBuilder::BuildArtifactInvocation` does. No derived
  `StaticClass` declaration is implicated by this row.

## IC-444 — Detached root-function traits drift after relocation despite exact encoded traits

- Severity/state: maintained-fork atomic-commit blocker / reproduced after the
  IC-443 owner fix and under investigation 2026-08-11.
- Exact boundary: official build `cache-ic443-function-owner-build1` passed.
  Root run `cache-ic443-function-owner1` at
  `Saved/Tests/cache-ic443-function-owner1/
  20260811_130508_367_9fcd55d3` advanced through the previously failing stable
  self-reference relocation, then `CommitFunctionArtifactToExisting` rejected
  the donor. Engine/module/function type/script data/object type/namespace and
  signature all matched, while the detached donor carried `0x02000000` and the
  current skeleton carried `0x02000001`: only `asTRAIT_CONSTRUCTOR` was absent.
  Earlier runs proved the producer artifact can carry the bit, so the remaining
  uncertainty is whether the current stream encoded it or the detached reader
  loses it during symbol-table translation/runtime-state application.
- Decision/resolution: extend the maintained reader's bounded diagnostics with
  the decoded root-trait value, then compare encoded root traits, post-read donor
  traits and current skeleton traits at the atomic boundary. If the stream value
  is exact, restore the reader invariant so relocation cannot mutate the root
  traits; if the stream is already missing the bit, repair producer selection/
  encoding. Do not copy target traits onto the donor without first proving the
  opaque artifact declared the same semantics, and do not weaken exact commit.
- Required evidence: diagnostics must show all three trait values; generated
  constructor/destructor/init-defaults artifacts preserve their exact root
  traits through detached translation; a mutated encoded trait still fails
  before publication; the root class ultimately executes to `42`.
- Task impact/evidence: the added decoded value is diagnostic-only and is never
  persisted as a second cache field. The fix belongs to the maintained-fork
  artifact boundary because that layer owns root function reconstruction.
- Diagnostic/resolution update 2026-08-11: official Development Editor build
  `cache-ic444-root-traits-diagnostics-build1` reached UBT
  `Result: Succeeded` at
  `Saved/Build/cache-ic444-root-traits-diagnostics-build1/
  20260811_130847_759_05f7f105` (the outer command cell timed out before the
  wrapper finalized its summary, while the already-started UBT process
  completed normally). Root run `cache-ic444-root-traits-diagnostics1` at
  `Saved/Tests/cache-ic444-root-traits-diagnostics1/
  20260811_130945_587_11cdb317` reported
  `EncodedRootTraits=0x02000000`, `ArtifactTraits=0x02000000` and
  `TargetTraits=0x02000001`. The detached reader is therefore exact; the
  reconstructed skeleton was wrong because it synthesized
  `asTRAIT_CONSTRUCTOR` from invocation kind `6`. The canonical declaration
  trait flags now explicitly include `Constructor` and `Destructor`, clean
  capture maps the original VM bits, and skeleton creation rebuilds only those
  captured bits. Invocation kind continues to define stable entity identity
  and calling role, but no longer guesses either trait. This preserves exact
  atomic commit and intentionally changes the development-era declaration ABI;
  old-cache compatibility remains out of scope. GREEN verification is pending.
- GREEN evidence update 2026-08-11: official Development Editor build
  `cache-ic444-explicit-constructor-traits-build1` passed at
  `Saved/Build/cache-ic444-explicit-constructor-traits-build1/
  20260811_131325_706_db4317d5`. The isolated root-class run
  `cache-ic444-explicit-constructor-traits1` passed `1/1` at
  `Saved/Tests/cache-ic444-explicit-constructor-traits1/
  20260811_131405_151_4e9ef1b3`: clean capture produced 13/13 graph-valid
  records, cold restore reached publication stage `7`, atomically restored one
  module, one script type and four current-engine function routes, and the
  restored reflected method executed to the expected value `42`. This closes
  the single-root-class vertical; multi-type declaration and dependency
  publication remain separate follow-up scope rather than being inferred from
  this GREEN.

## IC-445 — Class cold capture is still hard-limited to one root type

- Severity/state: real module-shape blocker / focused RED established and
  collection-oriented refactor in progress 2026-08-11.
- Exact boundary: official Development Editor build
  `cache-ic445-inherited-class-red-build1` passed at
  `Saved/Build/cache-ic445-inherited-class-red-build1/
  20260811_131714_580_8f13e7d2`. The new independent automation prefix
  `Angelscript.TestModule.Cache.InheritedClassRestore` then failed `0/1` at
  `Saved/Tests/cache-ic445-inherited-class-red1/
  20260811_131735_628_889e4fe7`. A normal compile successfully produced two
  class descriptors for one source module (script UObject base plus script
  derived class), but clean capture returned `NotCacheable` before producing
  records because `CaptureAngelscriptCleanCompiledModuleImpl` admits only
  `Classes.Num()==1`. This is an explicit implementation limit, not a parser,
  ClassGenerator or fixture failure.
- Decision/resolution: replace the root-class-specialized capture state with a
  deterministic per-type collection inside one module transaction. SourceIndex,
  ModuleInterface, ModuleState and ModuleSnapshot remain single module-level
  authorities; each script type contributes one declaration, TypeSchema,
  property set, function set, dependency resolver entries and derived helpers.
  Build all TypeKeys/declaration ABIs before mapping any datatype, then capture
  base-to-derived layout/declaration dependencies without using numeric type or
  FunctionIds. Do not invoke the one-class transaction repeatedly or publish a
  separate cache module per class.
- Required evidence: capture and graph validation contain exactly two keyed
  TypeSchemas; restore materializes both types before bodies, recreates the
  script UClass parent relation, restores every function route without key
  collisions, and invoking the derived reflected function dispatches the
  restored base method to return `42`. The single-root-class `1/1` and global
  cold restore regressions must remain green.
- Task impact/evidence: this is the first direct proof that the Cache V2 model
  handles real class/type dependencies rather than only a root-class slice. It
  is also a prerequisite for useful debug dependency chains: the C++/Python
  diagnostics must later show each TypeKey, its parent TypeKey or environment
  code root, and the functions/properties owned by it.

## IC-446 — The live status schema exposes record counts but not the semantic identities needed to diagnose restore and route failures

- Severity/state: production debuggability and cross-launch diagnosis gap /
  closed for the schema-3 C++/Python implementation and focused regression
  boundary on 2026-08-11; real process-session evidence remains V7.7.
- Exact boundary: the existing `FAngelscriptCacheDiagnosticSnapshot` schema 2
  reports compatibility/context/profile/source coordinates and per-module
  record-kind counts, while `FAngelscriptCacheDecisionEvent` schema 1 reports
  only a generic reason code and optional function/hash coordinates. It omits
  canonical module names, declaration/type/property ownership, type relations,
  function source/input/content coordinates, semantic dependencies, current
  VM/Native route inventory, and the structured validation class/stage/error/
  record-kind/byte-offset already present in a rejected exact-start result.
  The Python session correlator consequently compares generation-level
  coordinates and ModuleKeys only; it does not compare ModuleSnapshot RecordIds
  or verify that each live stable function route exists with the same persisted
  execution/debug/profile identity. IC-442 through IC-445 therefore required
  temporary hand-written logs even though the cache already owned the required
  pointer-free semantic data.
- Decision/resolution: widen the shared diagnostic schema instead of adding
  another logger. The C++ producer will decode only its already-frozen canonical
  publication records through the production bounded record decoder and emit a
  deterministic stable symbol catalog plus typed decode failures. The Engine-
  aware capture boundary will attach a pointer-free copy of the immutable
  StableFunctionKey route snapshot, excluding current pointers and numeric
  FunctionIds. Decision events will carry optional structured validation
  coordinates and one bounded human detail for context. Python will accept the
  new schema, correlate exact ModuleSnapshot RecordIds and live routes against
  persisted FunctionBody identities, and render the richer offline declaration/
  type/function inventory. Diagnostics remain observers and never feed cache
  selection, validation, restore or StaticJIT routing.
- Required evidence: a focused C++ test must prove deterministic module,
  declaration, type, function, dependency and VM/Native route JSON with no
  pointer or `FunctionId` leakage; a validation-event test must preserve typed
  class/stage/error/kind/offset and truncate bounded detail deterministically.
  Python tests must accept schema 3, identify an exact symbol/route correlation,
  name a ModuleSnapshot or function-content mismatch, preserve structured
  failures and remain read-only. The official Python wrapper, focused C++
  prefixes and the single-root-class cold restore regression must stay green.
- Task impact/evidence: this supersedes the narrower interpretation of checked
  V6.3 debug closure without changing cache wire formats or old-cache policy.
  Final Editor/PIE and Development/Shipping multi-launch evidence must attach
  both the Engine-native session JSON and Python correlation output so a future
  failure can be diagnosed without rebuilding an ad-hoc instrumented binary.
  The contract and field map are frozen in `v6.6-diagnostic-schema3.md`.
  TDD evidence is:
  - C++ missing-schema RED build
    `Saved/Build/cache-ic446-diagnostic-schema-red-build1/20260811_133153_118_eeb13d80`;
  - the first GREEN build attempt entered compilation and found the UE 5.8
    strong-enum `FString::LeftInline` call mismatch in
    `Saved/Build/cache-ic446-diagnostic-schema-green-build1/20260811_134126_783_c51545f9/UBT.log`;
    the corrected official build is
    `Saved/Build/cache-ic446-diagnostic-schema-green-build2/20260811_134227_460_46bbf834`;
  - focused C++ diagnostics `3/3` GREEN at
    `Saved/Tests/cache-ic446-diagnostic-schema-green1/20260811_134243_682_680f7e5b`;
    the final field-completeness review added layout inputs, property storage/
    access and type-kind payloads, rebuilt GREEN at
    `Saved/Build/cache-ic446-diagnostic-schema-final-build3/20260811_135832_063_64875438`
    and reran diagnostics `3/3` at
    `Saved/Tests/cache-ic446-diagnostic-schema-final2/20260811_135852_802_81cac248`;
  - Python schema-3 route-correlation RED `21/22` at
    `Saved/Tests/cache-ic446-python-schema3-red1`, followed by the final
    schema/correlation/full-semantic decoder suite `24/24` GREEN at
    `Saved/Tests/cache-ic446-python-debug-green3`;
  - unchanged reflected-root cold restore `1/1` GREEN at
    `Saved/Tests/cache-ic446-root-class-regression1/20260811_135340_062_076e9424`,
    status/console/Blueprint debug API `3/3` GREEN at
    `Saved/Tests/cache-ic446-debug-api-regression1/20260811_135423_418_9e361a9e`,
    and explain API `2/2` GREEN at
    `Saved/Tests/cache-ic446-explain-regression1/20260811_135504_550_0002ba24`.

## IC-447 — The Python TypeSchema v1 decoder accepted a truncated prefix as a successful semantic summary

- Severity/state: offline diagnostic-integrity gap / reproduced by a dedicated
  semantic test and closed on 2026-08-11.
- Exact boundary: `cache_v2_format.py` previously read only the TypeSchema common
  header and returned `decoder_scope: common-header-v1` without consuming the
  remainder. The frozen Python fixture itself stopped immediately after the
  metadata/relation/layout-input counts. It therefore was not a physically
  complete TypeSchema v1 record, yet the dump called it a decoded supported
  schema. The same shallowness prevented inspection of inheritance, property
  layout, method/VFT/behavior slots and Unreal reflection members—the exact data
  needed to diagnose the retained inherited-class restore RED.
- Decision/resolution: make the offline decoder exact for supported
  ModuleInterface v1 and TypeSchema v1 instead of adding more header peeks. The
  TypeSchema decoder now consumes layout inputs/expectations, properties,
  methods, VFT, behavior slots, kind payloads, reflection members and semantic
  dependencies, validates bounded counts/known enums/optional tags, and requires
  end-of-record. ModuleInterface now consumes declarations, parameter types,
  slots, imports and dependencies under the same rule. Opaque VM/initializer/
  debug payloads remain hash/size/codec summaries; the Runtime remains the
  derived-hash/current-ABI/whole-graph authority.
- Required evidence: a separate Python semantic-decoder test file must prove a
  nontrivial class with base relation, layout input, property, method, VFT,
  behavior, UClass/UFUNCTION reflection and dependency plus a function
  declaration with parameter and slot. The repository golden must use a complete
  TypeSchema v1 wire and the entire read-only wrapper suite must remain green.
- Task impact/evidence: dedicated RED was `22/23` at
  `Saved/Tests/cache-ic446-python-type-schema-red1`; semantic tests then passed
  `2/2`, and the final wrapper is `24/24` GREEN at
  `Saved/Tests/cache-ic446-python-debug-green3`. The updated golden RecordIds are
  intentional because the previous truncated TypeSchema payload was replaced by
  a complete v1 payload. No Runtime cache wire or selection behavior changed.

## IC-448 — The graph model supports many TypeSchemas but clean capture and live restore still enforce a single root class

- Severity/state: core multi-class cold-restore architecture gap / reproduced by
  the retained inherited-class RED and closed for the base/derived vertical on
  2026-08-11; broader class/property/interface matrices remain final acceptance
  work rather than a reason to reopen the single-class whitelist.
- Exact boundary: `FAngelscriptCachedModuleSnapshot::TypeSchemas`, graph
  validation and diagnostics already model an ordered set of stable TypeKeys,
  but `CaptureRootClassPrimitiveVertical` rejects `Module->Classes.Num() != 1`
  and constructs one local `TypeDeclaration`/`TypeSchema`. The live restore path
  independently rejects `Graph.GetTypeOrdinals().Num() > 1`, resolves every
  function against that one owner, and materializes only one root UClass. A
  valid module containing a script base class and script-derived class therefore
  fails before records are published even though the producer VM exposes the
  complete `derivedFrom`, code-root, layout, method, behavior and VFT state.
- Decision/resolution: promote the primitive vertical to an atomic same-module class graph,
  not a derived-class special case. Capture class authorities in deterministic
  base-before-derived order, give every declaration/function/property its exact
  stable owner, encode script-super plus native code/shadow-root relations and
  layout inputs, and publish all TypeSchema links in one ModuleSnapshot only
  after the complete graph validates. Restore must first resolve and validate
  all cached type owners, then create type skeletons base-before-derived, then
  create all owned function skeletons, wire inherited/local method, VFT and
  behavior slots, restore opaque bodies, reconstruct descriptors and activate
  routes atomically. Numeric FunctionIds and live pointers remain process-local.
- Required evidence: keep
  `Angelscript.TestModule.Cache.InheritedClassRestore` as the TDD RED; GREEN must
  restore two class descriptors into a fresh isolated Engine, preserve the
  derived VM `derivedFrom`/shadow/code-root/layout and VFT ownership, expose no
  stable-route collision, and execute the reflected derived function through
  its restored base call to return `42`. The root-class restore and focused
  graph/diagnostic suites must remain green. A rejected or injected mid-graph
  failure must leave no module, type or function route active.
- Task impact/evidence: the RED is
  `Saved/Tests/cache-ic445-inherited-diagnostics1/20260811_132040_302_cb8dfa4e`;
  its exact failure is the capture-side one-class whitelist at
  `AngelscriptCacheCleanCapture.cpp:1875`, while the corresponding independent
  restore whitelist is at `AngelscriptCacheRestore.cpp:1543`. The schema-3 C++
  and Python diagnostics completed under IC-446/IC-447 will be used to compare
  both TypeKeys, relations, layout inputs, record links and final routes during
  GREEN rather than adding test-only runtime logging. Capture now publishes the
  complete same-module graph only after exact graph validation. Restore resolves
  type owners first, orders local bases before derived types, materializes one
  live type and descriptor per TypeKey, filters function skeleton creation by
  exact owner, reconstructs local/inherited method and VFT slots, and chooses
  opaque restore-into-existing per function rather than through one module-wide
  `LiveClassType` switch. The first official build passed at
  `Saved/Build/cache-ic448-multiclass-restore-build1/20260811_143823_812_32285bd0`.
  The retained fresh-engine test is `1/1` GREEN at
  `Saved/Tests/cache-ic448-multiclass-restore-test1/20260811_143846_902_da335667`:
  capture reports 2 classes/6 functions/18 graph records; atomic restore reports
  2 types/6 routes; the restored derived UClass has the restored base UClass as
  its super and its reflected method executes the restored base call to return
  `42`.

## IC-449 — A hard function-content dependency replaced the signature edge required by detached relocation

- Severity/state: stable relocation semantic mismatch / reproduced by the first
  IC-448 class-graph capture and closed in the maintained AS builder on
  2026-08-11.
- Exact boundary: when `bValueDependenciesAreHard` was true,
  `asCBuilder::MarkDependency(asCScriptFunction*)` recorded only
  `FUNCTION_CONTENT` and replaced the ordinary `SIGNATURE` dependency. The
  detached artifact writer still emits a function relocation, whose stable
  authority necessarily requires the target FunctionKey plus declaration ABI.
  The class-graph derived factory calls its base constructor/function under the
  hard-value policy, so capture produced `FunctionContent/ScriptFunction` for
  the exact key while opaque validation correctly requested
  `Signature/ScriptFunction` and rejected byte offset 115. The earlier
  hypothesis that this was only a generated-factory TypeKey precedence problem
  was disproved by the new bounded codec detail, which printed the expected and
  all declared kind/reference/key tuples.
- Decision: a callable use always records `SIGNATURE`; hard-value compilation
  additionally records `FUNCTION_CONTENT`. The two edges are distinct inputs:
  ABI controls relocation and implementation content controls incremental
  invalidation. Keep the derived zero-argument factory-to-TypeKey precedence
  consistent between the Runtime resolver and opaque codec, but do not replace
  an ordinary callable's signature edge, weaken relocation validation or
  special-case the test function. This fix belongs in the maintained AS builder
  because it is the authoritative successful-compile dependency capture point.
- Required evidence: the inherited-class capture must publish both signature and
  content edges for its hard callable dependency and pass the opaque execution
  envelope; a focused compiler dependency test must prove hard function use
  retains both edges. The existing single-root constructor/factory restore and
  function-artifact codec regressions must remain green.
- Task impact/evidence: first TypeSchema-shape RED was
  `Saved/Tests/cache-ic448-class-graph-capture-test1/20260811_141346_637_8fd9e4d7`;
  after fixing its derived CodeRoot optional boundary, the exact factory
  relocation RED is
  `Saved/Tests/cache-ic448-class-graph-capture-test2/20260811_141530_711_56555ea8`.
  The improved codec detail at
  `Saved/Tests/cache-ic449-relocation-candidates-test1/20260811_142049_618_7d5591db`
  proved that key `146187...55ec4` had declared `FunctionContent` but no
  `Signature`, correcting the initial attribution before the implementation was
  finalized. `asCBuilder::MarkDependency(asCScriptFunction*)` now always records
  the signature edge and additionally records function content under the hard-
  value policy. The maintained-fork fix and multi-class restore compiled at
  `Saved/Build/cache-ic448-multiclass-restore-build1/20260811_143823_812_32285bd0`,
  and the formerly rejected derived factory/constructor envelope is part of the
  `1/1` GREEN inherited-class result at
  `Saved/Tests/cache-ic448-multiclass-restore-test1/20260811_143846_902_da335667`.
  `AngelscriptCacheGeneratedDependencyCaptureTests` now asserts both edges for
  the generated derived constructor. The dedicated test build is GREEN at
  `Saved/Build/cache-ic449-hard-call-dependency-build1/20260811_144035_419_6eec681f`
  and the focused `1/1` wrapper run is GREEN at
  `Saved/Tests/cache-ic449-hard-call-dependency-test1/20260811_144102_083_08687442`;
  its retained log prints `Signature/Function` and `FunctionContent/Function`
  for the same generated base-constructor target.

## IC-450 — The direct corruption regression cannot validate the captured Answer artifact in its isolated consumer

- Severity/state: focused VM-artifact test-layer mismatch / reproduced and closed
  during the post-IC-448/IC-449 omission audit on 2026-08-11; no production codec
  regression was present.
- Exact boundary: `FunctionArtifactCorruption.RuntimeStateCorruptionRejectsAtomicallyThenCompiles`
  captures a valid root-class module and the producer graph accepts its `Answer`
  execution envelope, but the test's direct `asCReader::ValidateFunctionArtifact`
  call in a second isolated Engine returns failure before runtime-state offsets
  are exposed. The log currently proves an 800-byte artifact and three typed
  producer dependencies but omits the reader result/stage/bytes/error flags, so
  it cannot yet distinguish a missing live symbol, stream-shape mismatch or an
  obsolete test-helper assumption. This test bypasses the production codec and
  must not be weakened merely because the inherited-class vertical is GREEN.
- Decision/resolution: retain the complete low-level reader diagnostics. The
  captured bytes were the Cache V2 execution envelope, while the test passed them
  directly to the maintained reader as if they were a raw VM artifact. The test
  now writes and validates an independent raw artifact, applies every mutation to
  that raw suffix inside the execution envelope, updates the envelope length and
  recomputes the enclosing execution hash. Production continues to validate the
  envelope and raw artifact at their respective layers; no validation was weakened.
- Required evidence: the unchanged eight-mutation matrix must again validate the
  baseline, reject every mutation atomically, invoke the compiler fallback once
  and execute `Answer()==42`. Function-artifact codec, generated dependency,
  single-root and inherited-class regressions must remain GREEN.
- Task impact/evidence: official RED is
  `Saved/Tests/cache-ic449-function-artifact-regression1/20260811_144346_770_1f4b7ef8`;
  it fails at the baseline-valid assertion with all runtime offsets left at
  `MAX_uint32`. The diagnostic rerun at
  `Saved/Tests/cache-ic450-reader-diagnostics-test1/20260811_144608_742_d8886573`
  identified reader stage `2`, read result `3` and the complete `800`-byte input,
  proving the layer mismatch. The envelope-aware repair compiled at
  `Saved/Build/cache-ic450-envelope-aware-corruption-build1/20260811_145011_746_2c4da205`
  and the unchanged eight-mutation matrix is `1/1` GREEN at
  `Saved/Tests/cache-ic450-envelope-aware-corruption-test1/20260811_145101_255_38671081`;
  every mutation is rejected with a typed diagnostic, compiler fallback occurs
  exactly once and the fallback function returns `42`.

## IC-451 — Same-module reflected class properties are outside the class-graph capture type table

- Severity/state: common multi-class UPROPERTY coverage gap / reproduced by a
  dedicated mutually-referencing class test and closed on 2026-08-11.
- Exact boundary: class-graph function declarations already route script data
  types through `FClassGraphTypeAuthority`, but property capture only tries a
  primitive mapper followed by the environment-type mapper. A valid pair of
  reflected classes whose object properties reference each other therefore
  compiles normally yet clean capture returns `NotCacheable` before any records
  are published. Restore also previously created properties in the same pass as
  types, which would make a valid cross-reference depend on TypeKey order.
- Decision: represent a same-module UClass property as a stable ScriptType
  reference to its exact TypeKey/declaration ABI and a Declaration dependency;
  object-handle storage remains governed by the property's own storage-layout
  hash. Restore is explicitly two-phase: create every type skeleton first, then
  materialize all property data types, then functions/method/VFT/behaviour state.
  Do not serialize a live UClass pointer, numeric type id or name-only link.
- Required evidence: a focused test with bidirectional UPROPERTY references must
  capture, graph-validate and restore into a fresh Engine independent of TypeKey
  order; both restored `FObjectProperty::PropertyClass` pointers must target the
  corresponding restored UClasses, and a restored UFUNCTION dereference must
  execute and return `42`. Existing root/inherited/diagnostic/corruption tests
  remain GREEN.
- Task impact/evidence: initial official build is GREEN at
  `Saved/Build/cache-class-graph-property-restore-build1/20260811_145445_352_d89aeafe`;
  the intended behavior RED is
  `Saved/Tests/cache-class-graph-property-restore-test1/20260811_145523_306_91cbe99e`,
  whose exact capture detail is `A class-graph property is outside the stable
  primitive/environment value table`. The first stable-type mapper build passed
  at `Saved/Build/cache-ic451-script-property-capture-build1/20260811_145657_967_5b99c354`;
  it advanced to the independent dependency-closure RED at
  `Saved/Tests/cache-ic451-script-property-capture-test1/20260811_145717_721_a0ea42ca`.
  After IC-452 corrected the handle-specific dependency and slot authority, the
  fresh-engine vertical is `1/1` GREEN at
  `Saved/Tests/cache-ic451-handle-layout-test1/20260811_150723_798_d892c672`:
  capture publishes 20 records for 2 types/7 functions, restore publishes 2 new
  UClasses/7 routes, both reflected `FObjectProperty::PropertyClass` links resolve
  to the corresponding restored class, and the restored UFUNCTION returns `42`.

## IC-452 — Object-handle properties were treated as inline target layouts

- Severity/state: structural invalidation precision and property-layout capture
  defect / reproduced by IC-451 and closed on 2026-08-11.
- Exact boundary: TypeSchema dependency closure required `ValueLayout` for every
  ScriptType/EnvironmentType property even when `StorageKind=ObjectHandle`, which
  creates false target-layout edges and makes mutually referencing classes form a
  bogus layout cycle. Independently, clean capture used
  `asCDataType::GetSizeInMemoryBytes()` for an object-handle property; for the
  reflected script class in the RED it returned target object size `64`, while the
  actual slot at offset `48` is the profile-owned 8-byte handle and the containing
  class size is `56`. The TypeSchema replay correctly rejected this impossible
  `48 + 64 > 56` shape.
- Decision/resolution: an inline object/value keeps a `ValueLayout` dependency.
  An object handle uses the versioned Compatibility/Profile handle-slot size and
  alignment, while its target is checked only as `Declaration` for ScriptType or
  `EnvironmentAbi` for EnvironmentType. This retains stable target identity/ABI
  validation without invalidating the holder for unrelated target instance-layout
  changes or requiring a cyclic target-layout graph. Both class-graph and root-
  class capture now use the same handle layout helper. TypeSchema cross-field
  derivation and required-dependency validation distinguish the two storage routes.
- Required evidence: exact producer positives for ScriptType/EnvironmentType
  handles, negatives proving a replacement ValueLayout edge is MissingCoverage,
  the exhaustive storage/type/qualifier matrix, and the bidirectional reflected
  class restore must all pass. Diagnostics must print type name, total size,
  alignment, base boundary and every property offset/size/alignment/storage when
  a captured TypeSchema cannot serialize.
- Task impact/evidence: the first dependency rule advanced capture but the official
  layout RED at
  `Saved/Tests/cache-ic451-layout-diagnostics-test1/20260811_150557_898_9dfdb485`
  reports `Type=UCacheV2GraphPropertyLeft size=56 alignment=8 base-boundary=48`
  and `[Right offset=48 size=64 alignment=8 storage=2]`, providing the exact root
  cause rather than a generic qualifier failure. The corrected build is GREEN at
  `Saved/Build/cache-ic451-handle-layout-build1/20260811_150706_880_1152445a`,
  the real two-class restore is GREEN under IC-451, and the complete TypeSchema
  prefix is `67/67` GREEN at
  `Saved/Tests/cache-ic451-typeschema-regression1/20260811_150819_498_25f0c884`.
  The focused ScriptType/EnvironmentType handle unit cases compiled at
  `Saved/Build/cache-ic452-handle-dependency-unit-build1/20260811_151225_517_b418f1b3`
  and are `2/2` GREEN at
  `Saved/Tests/cache-ic452-handle-dependency-unit-test1/20260811_151243_575_4412d2a0`.

## IC-453 — Multi-level virtual overrides lost the original VFT declaration-family owner

- Severity/state: stable-function/VFT topology defect / reproduced by the first
  three-level class-graph vertical and closed on 2026-08-11.
- Exact boundary: a Base/Middle/Leaf module compiles and executes normally, but
  clean capture followed by graph validation rejects the TypeSchema at its
  `TypeKind` coordinate. The live topology shows `Compute` was introduced by
  Base, `Compute_Implementation` occupies VFT slot 1 and is implemented by
  Middle/Leaf in turn. Capture currently assigns a `VirtualOverride` slot's
  `DeclaringOwner` from the immediate base slot's live implementing function.
  Leaf therefore records Middle as the declaration owner even though the stable
  virtual family was introduced by Base. The former graph admission rule also
  assumed inherited methods were a positional suffix, while the maintained VM
  stores local methods first and inherited methods later in a class-specific
  order.
- Decision: method inheritance is matched by stable function key, declaration
  owner and declaration ABI, never by array position. A virtual slot's
  `DeclaringOwner` is the immutable owner that introduced the VFT family and is
  inherited from the direct base's cached slot; `ImplementingOwner` continues to
  name the class whose function currently fills that slot. Do not create a new
  stable function family merely because another intermediate class overrides it.
- Required evidence: the dedicated Base/Middle/Leaf test must capture and restore
  all three UClasses into a fresh Engine, preserve both VM `derivedFrom` links,
  compare every method/VFT owner and ordinal, and execute the leaf reflected call
  through two override levels with result `51`. The existing one-level inherited-
  class restore plus focused ModuleGraph/TypeSchema prefixes must remain GREEN.
- Task impact/evidence: the first behavior RED is
  `Saved/Tests/cache-class-graph-inheritance-test1/20260811_151645_039_e623522a`.
  Stable-key method matching compiled at
  `Saved/Build/cache-ic453-method-topology-build1/20260811_151852_059_cf0c0181`
  but retained the TypeSchema rejection at
  `Saved/Tests/cache-ic453-method-topology-test1/20260811_151908_739_e4b41ed2`.
  The retained topology diagnostics at
  `Saved/Tests/cache-ic453-topology-diagnostics-test1/20260811_152031_679_75225635`
  show Base slot 1 implemented by Base, Middle slot 1 by Middle and Leaf slot 1
  by Leaf while all three belong to the Base declaration family. After IC-454
  and IC-455 closed the independent execution-layer defects, the unchanged
  three-level test is `1/1` GREEN at
  `Saved/Tests/cache-ic455-reflection-name-green-test1/20260811_154710_838_58f3c867`:
  all 35 records validate, 3 types/14 routes restore, both `derivedFrom` links
  and every VFT ordinal/owner compare exactly, and the two-level override call
  returns `51`.

## IC-454 — Restored bytecode still treated preprocessor StaticName indices as Engine-stable

- Severity/state: fresh-Engine execution crash / reproduced and closed on
  2026-08-11.
- Exact boundary: after IC-453, the Base/Middle/Leaf artifact captures 35 records
  and atomically restores 3 types/14 functions, but the first reflected
  BlueprintEvent dispatch asserts in `FAngelscriptEngine::GetStaticName(0)`
  because the consumer Engine owns an empty `StaticNames` table. The
  preprocessor currently lowers both `n"Name"` and generated event wrapper names
  to `__STATIC_NAME(<producer Engine index>)`; the maintained function artifact
  correctly preserves the integer literal, but that literal is neither a stable
  identity nor sufficient to reconstruct its FName in another Engine.
- Decision: do not add the producer's whole StaticNames array to the cache and do
  not require identical registration order. Lower each static-name expression to
  a call carrying both the numeric index as a same-Engine fast-path hint and the
  canonical string as the authority. The runtime resolver returns the indexed
  value only when it matches that canonical name; otherwise it constructs the
  canonical FName value without mutating or depending on the old table. The
  maintained artifact already serializes string constants by value, so the cache
  remains pointer/index independent and mixed hit/miss module order is safe.
- Required evidence: preprocessor tests must prove duplicate names retain the
  existing index fast path while every lowered call carries exact escaped
  canonical text; normal compile/execute remains GREEN. A dedicated fresh-Engine
  cache test must restore arbitrary duplicate/distinct `n"..."` literals and
  execute their equality behavior. IC-453's generated BlueprintEvent wrapper
  must then dispatch across Base/Middle/Leaf and return `51`, and existing root/
  inherited cache restore regressions must remain GREEN.
- Task impact/evidence: capture/restore success followed by the original pointer-
  ownership test correction is recorded at
  `Saved/Tests/cache-ic453-vft-family-test1/20260811_152413_154_b5f71666`.
  The exact execution crash is
  `Saved/Tests/cache-ic453-three-level-green1/20260811_152619_114_995e1a2f`;
  its call stack reaches `FAngelscriptEngine::GetStaticName` with index 0 while
  the array has size 0, through the restored `ReflectedValue` UFUNCTION. The
  canonical-name lowering/resolve change compiled at
  `Saved/Build/cache-ic454-canonical-static-name-build1/20260811_153247_274_6b2bf68f`;
  normal preprocessing/execute is `1/1` GREEN at
  `Saved/Tests/cache-ic454-name-literal-preprocessor-test1/20260811_153508_176_7f6b4d29`,
  and the generated BlueprintEvent fresh-Engine control is GREEN as part of
  `Saved/Tests/cache-ic455-reflection-name-green-test1/20260811_154710_838_58f3c867`.
  The dedicated test first exposed IC-456, then passed with conflicting producer/
  consumer values at both numeric indices at
  `Saved/Tests/cache-ic456-global-dependency-test1/20260811_161239_282_b4c817d8`.
  The final adjacent set, including the missing-dependency fail-closed control,
  global-only/class-graph restore and complete Preprocessor.Literals prefix, is
  `11/11` GREEN at
  `Saved/Tests/cache-ic457-adjacent-green1/20260811_161741_078_c00fc7a3`.

## IC-455 — TypeSchema lost the distinction between UE reflection names and AS implementation names

- Severity/state: reflected class-graph execution failure and cache-schema gap /
  reproduced and closed on 2026-08-11.
- Exact boundary: the same three-level artifact captured/restored all VM topology,
  but `BuildClassDescriptor` rebuilt both `FunctionName` and `ScriptFunctionName`
  from the declaration canonical name. For BlueprintEvent/BlueprintOverride the
  live authoritative tuple is `FunctionName=Compute`, optional
  `OriginalFunctionName=Compute`, and
  `ScriptFunctionName=Compute_Implementation`. The cache stored only the target
  declaration, so all restored descriptors became `Compute_Implementation` and
  Base/Middle/Leaf all failed `FindFunctionByName("Compute")`.
- Decision/resolution: TypeSchema payload v2 persists the exact post-analysis UE
  reflection name, optional analysis-original name, and AS implementation name on
  every ordered reflected-function member. Capture copies the producer descriptor
  tuple; local validation gives each string an exact captured coordinate; graph
  validation requires the script name to match the resolved declaration; restore
  recreates the tuple exactly. Content hashing, bounded decode/allocation budgets,
  C++ JSON diagnostics and Python semantic dump all include the names. Runtime
  intentionally rejects the old TypeSchema version so the generation is rebuilt;
  the read-only Python debugger can still inspect v1 records.
- Required evidence: distinct-name round trip and missing-required-name negatives,
  all allocation one-short/fault/coordinate tests, Python v2 semantic dump, and
  Base/Middle/Leaf normal UClass lookup plus most-derived dispatch must pass. Do
  not infer the UE name by stripping `_Implementation`, because parent event and
  display-name mapping can make that derivation non-authoritative.
- Task impact/evidence: the non-crashing RED is
  `Saved/Tests/cache-ic455-reflection-name-red-test1/20260811_154052_467_d2415af2`;
  it logs all restored descriptors as `Compute_Implementation` and all three UE
  lookups as missing. The v2 contract build is GREEN at
  `Saved/Build/cache-ic455-reflection-name-contract-build1/20260811_154631_454_d62f1440`.
  The three-level behavior is `1/1` GREEN at
  `Saved/Tests/cache-ic455-reflection-name-green-test1/20260811_154710_838_58f3c867`.
  The expanded TypeSchema authority is `69/69` GREEN at
  `Saved/Tests/cache-ic455-typeschema-v2-regression4/20260811_155937_623_a08862b7`,
  covering 56 named allocation sites and captured coordinates 0..43. The Python
  debugger is `24/24` GREEN at
  `Saved/Tests/cache-ic455-python-dump-v2-test2`.

## IC-456 — Global-function restore rejected every non-empty validated dependency set

- Severity/state: fresh-Engine restore admission defect / reproduced and closed
  on 2026-08-11.
- Exact boundary: the dedicated IC-454 fixture compiles a primitive-return,
  zero-parameter global function containing duplicate/distinct `n"..."`
  literals. Clean capture and the sole module-graph validator accept the complete
  six-record artifact, including the registered `FName`/`__STATIC_NAME` callable
  dependencies and semantic relocation table. Fresh-Engine restore rejects it
  before VM attachment at RestoreFunctions stage 5 because the global-function
  branch additionally requires `FunctionBody.ActualDependencies.IsEmpty()`.
  Class-owned functions already pass validated non-empty dependency sets to the
  same function-artifact codec, and the maintained reader resolves registered
  current-Engine functions/types/string constants before translating bytecode.
- Decision/resolution: do not special-case `StaticName` or erase its dependency
  records. Remove only the obsolete empty-dependency admission restriction for
  the already-supported primitive-return/zero-parameter global declaration. The
  sole graph, execution-envelope relocation validation and private maintained-VM
  reader remain the authorities for dependency kind/key/ABI/content and current
  symbol resolution. Any unresolved or mismatched callable must continue to fail
  closed before activation with zero routes.
- Required evidence: the unchanged IC-454 fixture must restore with intentionally
  conflicting producer/consumer numeric name indices, execute to `454`, and leave
  the consumer StaticNames table unchanged. Retain a negative global-function
  dependency corruption/current-symbol mismatch regression or prove an existing
  exact graph/relocation case covers the broadened branch, then rerun the adjacent
  global-only and class-graph restore prefixes.
- Task impact/evidence: the dedicated test compiled through the complete
  Development Editor target at
  `Saved/Build/cache-ic454-static-name-dedicated-build1/20260811_160846_656_49c41b05`
  (`32/32` actions). Its intended behavior RED is `0/1` at
  `Saved/Tests/cache-ic454-static-name-dedicated-test1/20260811_161002_588_2b2e1df5`:
  capture reports `Error=0 Records=6 GraphRecords=6`, producer indices are
  Alpha=`1`/Beta=`2`, the consumer owns conflicting values at both indices, and
  restore reports `Error=4 Stage=5 Types=0 Functions=0` with detail
  `A FunctionBody is not supported by the selected type materializer`. Removing
  only the obsolete empty-dependency gate compiled at
  `Saved/Build/cache-ic456-global-dependency-build1/20260811_161224_116_153e08fe`
  (`6/6` actions), and the unchanged test is `1/1` GREEN at
  `Saved/Tests/cache-ic456-global-dependency-test1/20260811_161239_282_b4c817d8`:
  restore publishes 0 types/1 route, execution returns `454`, and the consumer
  StaticNames count remains `3`. The final `11/11` adjacent evidence is recorded
  under IC-454/IC-457.

## IC-457 — Relocation negative asserted a retired codec-detail sentence

- Severity/state: adjacent regression-test expectation drift / independently
  reproduced and closed on 2026-08-11.
- Exact boundary: after IC-456, the existing missing-dependency fixture still
  rejects during capture with `GraphValidationFailed`, typed
  `RelocationDependencyMismatch` (`Error=47`), validation class/kind/stage/offset,
  zero validated graph records and zero promoted output. Its only failing
  assertion requires the former codec-local sentence `no declared stable
  dependency`. Relocation-subset authority has since moved into the sole module
  graph, which intentionally returns the frozen typed result and exact captured
  coordinate rather than depending on a presentation sentence from an inner
  validator.
- Decision/resolution: retain assertions on the frozen capture error, typed graph
  error and atomic empty outputs; remove the obsolete human-sentence assertion.
  Do not reintroduce duplicate validation or couple correctness to presentation
  text. C++/Python diagnostics map Error 47 to the stable name
  `RelocationDependencyMismatch`.
- Required evidence: the focused relocation prefix must pass unchanged production
  behavior, and the IC-456 adjacent regression must retain both this negative and
  the new non-empty-dependency positive.
- Task impact/evidence: the combined adjacent run is `3/4` at
  `Saved/Tests/cache-ic456-adjacent-regression1/20260811_161340_249_2b48bd10`;
  StaticName, global-only and three-level class restore pass, while this test logs
  `Error=8 GraphRecords=0 OutputRecords=0 Detail=... Error=47 Class=5 Kind=7 Stage=5 Offset=440`.
  The same single stale assertion reproduces `0/1` at
  `Saved/Tests/cache-ic457-relocation-detail-repro1/20260811_161558_303_95fd09be`.
  The corrected test-only expectation compiled at
  `Saved/Build/cache-ic457-relocation-test-build1/20260811_161721_846_340a11d1`
  (`5/5` actions); the final combined positive/negative and literal regression is
  `11/11` GREEN at
  `Saved/Tests/cache-ic457-adjacent-green1/20260811_161741_078_c00fc7a3`.

## IC-458 — V3.11 diagnostic passed TObjectPtr to the checked `%p` formatter

- Severity/state: test-fixture compile error / reproduced and closed on
  2026-08-11 before behavior execution.
- Exact boundary: the first V3.11 translation unit logs reflected input/return
  `PropertyClass` values with `%p`. UE 5.8 exposes those members as
  `TObjectPtr<UClass>`, and the compile-time checked formatter correctly rejects
  them as non-pointer arguments. No Runtime or Cache path executes.
- Decision/resolution: keep the diagnostic and pass each explicit `.Get()` raw
  observer pointer. Do not weaken checked formatting or change reflected storage.
- Required evidence: the complete Development Editor target must compile before
  the V3.11 behavior RED/GREEN is interpreted.
- Task impact/evidence: the compile-only RED is
  `Saved/Build/cache-v311-cross-class-signature-build1/20260811_162233_926_d84f9b78`;
  UBT reports C7595 at the V3.11 reflection-signature log and no production error.
  The explicit raw observer pointers compile through the complete target at
  `Saved/Build/cache-v311-cross-class-signature-build2/20260811_162314_255_2e1b929c`
  (`5/5` actions).

## IC-459 — Reflected execution helper observed a second non-return parameter

- Severity/state: V3.11 reflected-call boundary / reproduced and closed on
  2026-08-11.
- Exact boundary: clean capture/restore and every pointer-ownership assertion are
  GREEN: 16 records restore 2 types/5 routes; the restored `asCScriptFunction`
  input and return `asCDataType` both point to the consumer Peer type; the
  reflected Input and Return `FObjectProperty::PropertyClass` both point to the
  consumer Peer UClass. The final `FFunctionInvoker` call rejects before entering
  AS because it enumerates two `CPF_Parm` non-return fields while the script
  declaration has one explicit `Input`. Full inventory proved producer
  `Input, ReturnValue` versus consumer `Input, Input, ReturnValue`. The duplicate
  was not a hidden parameter: `BuildClassDescriptor()` populated cached
  `Function->Arguments`, then normal `FAngelscriptClassGenerator::Analyze()`
  appended the same live-VM parameter again.
- Decision/resolution: preserve the normal descriptor contract. Cache restore
  reconstructs the VM skeleton with canonical parameter types, names, passing
  modes and defaults, but leaves `Function->Arguments` empty; ClassGenerator is
  the single authority that derives reflected argument descriptors. This matches
  both clean preprocessing and the existing dependency-recompile path, which
  explicitly resets copied arguments before analysis. Do not reset inside the
  general analyzer, ignore duplicate fields in the invoker, or keep two competing
  cached/derived representations.
- Required evidence: producer and consumer parameter inventories must match, all
  object-class pointers must be consumer-owned after restore, and the restored
  UFunction must return the exact consumer Peer instance.
- Task impact/evidence: behavior RED is `0/1` at
  `Saved/Tests/cache-v311-cross-class-signature-test1/20260811_162335_838_8f400ea5`.
  The logs prove the VM and reflection type-pointer assertions before the helper
  reports `Function 'EchoPeer' should receive ... 2, but it was 1`. The corrected
  Runtime plus exact producer/consumer inventory test builds through the complete
  Development Editor target at
  `Saved/Build/cache-ic459-single-owner-arguments-build1/20260811_163150_036_9b6df509`
  (`10/10` actions). The focused behavior is `1/1` GREEN at
  `Saved/Tests/cache-ic459-single-owner-arguments-test1/20260811_163220_751_8be326e8`;
  the consumer has exactly `Input, ReturnValue` with matching flags/classes and
  returns the exact Peer object. Class-graph signature/property/inheritance,
  global-only and StaticName adjacency is `5/5` GREEN at
  `Saved/Tests/cache-ic459-adjacent-regression1/20260811_163319_462_bccda204`.

## IC-460 — V3.12 descriptor observer required a mutable lookup receiver

- Severity/state: test-fixture compile error / reproduced and closed on
  2026-08-11.
- Exact boundary: the new reflection-surface translation unit declared its
  snapshot helper receiver as `const FAngelscriptClassDesc&`, but the established
  `GetMethod()` and `GetProperty()` lookup APIs have no const overload. UBT stops
  before linking or executing Cache Runtime behavior.
- Decision/resolution: make only the test observer receiver mutable. The helper
  copies descriptor values and performs no mutation; adding unrelated Runtime
  const overloads is outside V3.12 and would widen the production diff without
  improving the cache contract.
- Required evidence: the complete Development Editor target must build before
  any reflection-surface behavior result is interpreted.
- Task impact/evidence: build RED is
  `Saved/Build/cache-v312-reflection-surface-build1/20260811_164039_853_7f00dc56`;
  UBT reports C2662/C2663 only at the three const-qualified descriptor lookups.
  The corrected Development Editor build is `4/4` GREEN at
  `Saved/Build/cache-ic460-reflection-surface-build2/20260811_164121_693_3db0ba23`;
  the later unsupported-shape addition also builds `4/4` at
  `Saved/Build/cache-v312-unsupported-reflection-build1/20260811_164343_613_1769c10a`.
  The complete V3.12 contract is `2/2` GREEN at
  `Saved/Tests/cache-v312-reflection-contract-test2/20260811_164406_516_ab218430`,
  and six adjacent restore families plus V3.12 are `7/7` GREEN at
  `Saved/Tests/cache-v312-adjacent-regression1/20260811_164456_041_38066073`.

## IC-461 — V3.14 first build was denied by the shared XGE concurrency ceiling

- Severity/state: build-infrastructure contention / reproduced and closed on
  2026-08-11.
- Exact boundary: `Tools/RunBuild.ps1 -Label
  cache-v314-declaration-order-build1 -TimeoutMs 1800000` reaches UBT/XGE but
  XGE returns `Maximum number of concurrent builds reached` before compiling any
  V3.14 translation unit. There is no C++ diagnostic and this run is not feature
  RED evidence.
- Decision/resolution: keep the official wrapper and retry this local test-only
  build with `-NoXGE`. Do not change source or infer an Engine-output conflict
  unless the deterministic local executor produces such evidence.
- Required evidence: a Development Editor build must reach and compile the new
  translation unit; close this issue only after that build returns a source
  diagnostic or GREEN result.
- Task impact/evidence: the infrastructure-only attempt is
  `Saved/Build/cache-v314-declaration-order-build1/
  20260811_170620_921_1d05618f`; process exit is `6`, wrapper exit is `1`, and
  elapsed time is 4.6 seconds. The same official wrapper with `-NoXGE` compiled
  and linked all `18/18` actions at `Saved/Build/
  cache-ic461-declaration-order-noxge-build2/
  20260811_170646_138_e2d3ede1`, proving no source or shared-Engine-output defect.

## IC-462 — ModuleInterface RecordId inherits sibling source declaration order

- Severity/state: P0 stable-identity behavior / reproduced and closed on
  2026-08-11.
- Exact boundary: two isolated Full Engines compile the same named module with
  the same two mutually referencing reflected classes and eight stable functions,
  changing only whether Alpha or Beta is declared first. Both captures succeed as
  22-record graphs with the exact same ModuleKey, but their ModuleInterface
  RecordIds are respectively
  `6a68228b3ef45b80a2b366baca18551c9fa8da9272d691e3414a3911d1a6d943` and
  `d77f99f9f836d29f16383076b2fa86d0064b6d4b54596b0f43530f67402b217a`.
- Root cause: class-graph clean capture currently selects the first ready entry
  from `Module->Classes` and enumerates `ScriptModule->scriptFunctions` directly.
  It assigns ModuleInterface `Declaration` and `Function` slot ordinals during
  those source/compiler-order traversals. `PrepareModuleInterface` later sorts the
  declaration set by declaration authority and StableKey, but intentionally does
  not rewrite the embedded semantic slot ordinals. The stable declarations are
  therefore equal while the StableKey-to-slot mapping, InterfaceAbi and RecordId
  still inherit the unrelated sibling source order.
- Consumer audit: live class restore does not consume ModuleInterface declaration
  or function slot ordinals. TypeSchema independently owns and restores exact
  property, ordered-method, VFT and behavior ordinals; ModuleState independently
  owns global storage/initializer order. Module graph validation resolves
  declarations by StableKey and uses only the canonical declaration array ordinal
  as a decoded-record coordinate. Diagnostics and captured-offset lookup are the
  remaining readers of ModuleInterface declaration/function slots.
- Decision/resolution: make the class-graph producer's semantic sequence
  deterministic without globally rewriting the frozen wire format. Select each
  ready base-before-derived class by case-sensitive namespace/name authority, so
  unrelated sibling order is canonical while inheritance remains a prerequisite.
  Then stable-sort captured functions by that canonical owner order, preserving
  the compiler's relative order inside each class, and assign Function slots only
  after that grouping. Do not sort TypeSchema property/method/VFT/behavior rows,
  weaken the test, or change generic ModuleInterface serialization.
- Required evidence: focused RED retained; after repair, opposite-order captures
  must preserve ModuleInterface, each TypeSchema, ModuleState, stable function
  execution coordinates and restored cross-links, while only source/debug-linked
  records and Engine-local numeric ids may differ. Complete adjacent regressions
  must remain GREEN.
- Task impact/evidence: focused behavior RED is `0/1` at
  `Saved/Tests/cache-v314-declaration-order-test1/
  20260811_171001_478_b942c11b`; failure is the explicit ModuleInterface RecordId
  equality assertion, not a crash, capture rejection or restore failure. The
  corrected Development Editor build is `4/4` GREEN at `Saved/Build/
  cache-ic462-declaration-order-fix-build2/20260811_171917_127_2c3d8656`.
  Focused behavior is `1/1` GREEN at `Saved/Tests/
  cache-ic462-declaration-order-fix-test2/20260811_172131_657_8aa2fcd0`:
  Interface=`6f239bf8493d31abc23320e3403c75f99a38d42da0a59c83364c9f490dd1d5f8`,
  State=`ce0832e902f9d7079de2f103e22c7e0c8979ecb2a1fc0b2c2a824f9981603802`,
  both consumers restore 2 types/8 routes and execute `28/14`. The eight adjacent
  restore/rollback methods plus V3.14 are `9/9` GREEN at `Saved/Tests/
  cache-v314-adjacent-regression1/20260811_172243_716_bf94f918`.

## IC-463 — First IC-462 repair build was cancelled by the orchestration timeout

- Severity/state: test-execution configuration / reproduced and closed on
  2026-08-11.
- Exact boundary: the official `Tools/RunBuild.ps1` wrapper was given its correct
  internal `-TimeoutMs 1800000`, but the outer command host was accidentally given
  a one-second timeout. It terminated the wrapper immediately after UBT launch;
  Build.log and captured stdout are both zero bytes and no compiler result exists.
- Decision/resolution: retain the report as non-feature evidence and rerun the
  unchanged official wrapper with an outer wait window long enough for UBT. Do not
  edit source or classify the cancellation as RED.
- Required evidence: a subsequent wrapper report must contain the completed UBT
  action/result inventory before V3.14 behavior is executed.
- Task impact/evidence: the cancelled run is `Saved/Build/
  cache-ic462-declaration-order-fix-build1/20260811_171843_949_bed090e8`;
  `Build.log` is zero bytes and the only usable artifact is launch metadata.

## IC-464 — V6.1 publication test retained the pre-provenance schema literal

- Severity/state: broad-regression test contract / focused and complete-prefix
  repair verified on 2026-08-11.
- Exact boundary: the latest complete `Angelscript.TestModule.Cache` run reaches
  `SuccessfulCompileArtifactsFreezeInsideGateAndOutliveEngine`; production capture
  and freeze both succeed (`Records=7`, `Transaction=1`, `Modules=1`), then line
  210 expects literal publication SchemaVersion `1` and receives `2`.
- Root cause: IC-420/IC-421 intentionally advanced
  `FAngelscriptCacheSuccessfulPublicationDto::CurrentSchemaVersion` to `2` for
  `restoredFromStore` and `persistedGenerationId` online provenance. The older V6.1
  lifetime test still asserted the original magic literal; no other Cache test
  contains this stale publication-schema assertion. The production DTO and its
  consumers consistently name schema 2, so reverting Runtime would remove required
  V7.5 diagnostics and is incorrect.
- Decision/resolution: compare the frozen DTO against
  `FAngelscriptCacheSuccessfulPublicationDto::CurrentSchemaVersion`, preserving the
  test's lifetime/immutability purpose across explicit append-only schema advances.
  Do not weaken transaction, module, record or post-Engine-lifetime assertions.
- Required evidence: build the test-only correction, run the focused
  Cache.Service prefix and rerun the complete Cache prefix with zero
  failures/skips/not-run.
- Task impact/evidence: first failure is in `Saved/Tests/
  cache-v314-full-regression1/20260811_172912_262_b61b3bee`; the completed run is
  `513/518` with exactly five failures and no skips/not-run. The assertion now
  names `FAngelscriptCacheSuccessfulPublicationDto::CurrentSchemaVersion`; no
  Runtime source or persisted format is changed. Cache Service passed `4/4` at
  `Saved/Tests/cache-ic464-publication-schema-focused1/
  20260811_175816_941_d1086291`; the final complete prefix is included below.

## IC-465 — declaration-trait frozen-wire test stopped at the original nine bits

- Severity/state: broad-regression frozen-contract coverage / focused and
  complete-prefix repair verified on 2026-08-11.
- Exact boundary: `Archive.Primitives.WireEnumsFlagsAndValidationClassesAreFrozen`
  still enumerates only `Pure` through `Generated` and expects `KnownMask=0x1ff`,
  while the maintained declaration model now defines 30 explicit single-bit
  traits through `Destructor` and publishes `KnownMask=0x3fffffff`. The failure is
  line 262 of `AngelscriptCacheArchivePrimitiveTests.cpp`; all earlier primitive
  enum and flag assertions pass.
- Root cause: later declaration-surface work added `Shared`, `External`,
  `Property`, constructor/destructor and Unreal-facing traits to the frozen wire
  enum, but this primitive golden retained its original nine-entry table. Merely
  replacing the final mask literal would leave the 21 new bit assignments
  unguarded.
- Decision/resolution: extend the frozen array to every declared trait in numeric
  order, retain the per-entry `1u << Index` assertion, and freeze the complete
  mask as `0x3fffffff`. Do not renumber Runtime flags or weaken the bit-level
  contract.
- Required evidence: Development Editor build, focused Archive.Primitives run,
  and the complete Cache prefix with no failures/skips/not-run.
- Task impact/evidence: reproduced in `Saved/Tests/
  cache-v314-full-regression1/20260811_172912_262_b61b3bee`, one of exactly five
  failures in the completed `513/518` run. The repaired class-prefix run is
  `Saved/Tests/cache-ic465-trait-flags-focused2/
  20260811_175636_877_22cc6aa1`, `13/13 PASS`.

## IC-466 — stronger graph validation invalidated the late-rollback corruption fixture

- Severity/state: broad-regression rollback-fixture semantics / focused and
  complete-prefix repair verified on 2026-08-11.
- Exact boundary: `FreshEngineRestore.LateArtifactFailureLeavesFreshEngineUnchanged`
  mutates an encoded DebugSidecar after capture and expects VM restore to fail at
  `VmRestoreFailed/RestoreFunctions`. Current consumer graph validation correctly
  rejects the changed opaque payload first with Error 46 at graph validation,
  before any Engine mutation is attempted.
- Root cause: the fixture predates opaque payload hash/graph validation. Its
  byte-level mutation no longer reaches the late transactional boundary that the
  test is named to prove; changing the expected result to the early rejection
  would silently delete late rollback coverage.
- Decision/resolution: preserve early corruption rejection and replace this
  fixture with the production `IAngelscriptCacheRestoreFaultInjector` seam at
  `AfterModulePrepared`. Assert `ActivationFailed/FinalizeModule`, prove the
  injector observed the intended module, then retain all existing checks that the
  pre-existing module, enum and route remain unchanged and no candidate state
  leaks. Do not weaken graph validation.
- Required evidence: Development Editor build, focused FreshEngineRestore method,
  adjacent rollback tests, and the complete Cache prefix with no failures.
- Task impact/evidence: reproduced in `Saved/Tests/
  cache-v314-full-regression1/20260811_172912_262_b61b3bee`; actual error/stage is
  `Consumer graph validation failed: Error=46 Kind=7 Stage=5 Offset=68`.
  The production fault-injection replacement is verified by `Saved/Tests/
  cache-ic466-late-rollback-focused1/20260811_175712_760_6fe9982f`, `4/4 PASS`;
  the target method reports `ActivationFailed/FinalizeModule`, injection ordinal
  zero, unchanged active route/module state and authoritative fallback result 42.

## IC-467 — invocation-family parity stored raw VM bytes under execution-envelope v5

- Severity/state: broad-regression production-shaped test fixture / raw-versus-
  envelope repair and the subsequently exposed IC-470/IC-472 production defects
  verified through the complete prefix on 2026-08-11.
- Exact boundary: all 19 candidates in
  `InvocationFamilyParity.ForcedCleanAndCachedArtifactsMatchAcrossTwoEngines`
  return `REJECTED_CORRUPT` with `Artifact restore failed: Error=6 Offset=12` and
  fall back to the compiler. The shared default read budget is 512 MiB and the
  artifacts are small, so actual batch exhaustion is contradicted by the inputs.
- Root cause: `WriteExecutionArtifact` returns the maintained-fork raw
  `asCWriter::WriteFunctionArtifact` blob, but the test writes those bytes directly
  to `CanonicalExecutionPayload` while declaring
  `FAngelscriptFunctionArtifactCodec::ExecutionCodecVersion == 5`. Production
  capture has wrapped raw bytes with `EncodeExecutionArtifact` since execution
  envelope v5. At byte offset 12 the envelope reader therefore interprets a raw
  VM field as `RelocationCount`; its attempted reserve is reported as
  `BudgetExceeded`. No production budget has actually been consumed to its cap.
- Decision/resolution: retain the raw blob separately for exact VM-state parity,
  capture the stable semantic dependencies observed by each compiled function,
  pass raw bytes through the production `EncodeExecutionArtifact`, and persist
  the returned inner execution-content hash. On the consumer, re-encode the
  restored raw blob with the same stable dependencies and assert both raw VM
  parity and canonical envelope parity. Do not enlarge the budget or allow raw
  payloads under codec v5.
- Required evidence: Development Editor build; focused InvocationFamilyParity
  must restore all 19 candidates without compiler invocation, preserve different
  producer/consumer numeric FunctionIds, and execute the same behavior; then the
  complete Cache prefix must be green.
- Task impact/evidence: reproduced in `Saved/Tests/
  cache-v314-full-regression1/20260811_172912_262_b61b3bee`; the consistent first-
  candidate offset and direct comparison with production capture establish the
  format-boundary root cause. Final 19-artifact parity and broad evidence are
  recorded under IC-472.

## IC-468 — value-layout mismatch test retained the superseded diagnostic phrase

- Severity/state: broad-regression diagnostic assertion / focused and
  complete-prefix repair verified on 2026-08-11.
- Exact boundary:
  `SymbolDependencyValidation.ValueLayoutRelocationRequiresExactStableDependency`
  still receives the required `RelocationDependencyMismatch` and an empty
  relocation set. Its only failing assertion expects the old phrase
  `has no declared stable dependency`; the current diagnostic says the symbol use
  `expects dependency 5/2/<type-key> but declared 1 [6/5/<property-key>]`.
- Root cause: relocation diagnostics were intentionally expanded to include the
  expected dependency coordinate and a bounded inventory of declared candidates,
  but this test froze obsolete prose rather than the semantic coordinates.
- Decision/resolution: assert the stable diagnostic structure and both exact
  expected/declared coordinates (`expects dependency`, `but declared 1`, the
  TypeKey and the PropertyKey). Retain the typed error and empty-relocation
  assertions. Do not revert the more useful Runtime diagnostic.
- Required evidence: Development Editor build, focused
  SymbolDependencyValidation method and complete Cache prefix with no failures.
- Task impact/evidence: reproduced in `Saved/Tests/
  cache-v314-full-regression1/20260811_172912_262_b61b3bee`, one of exactly five
  failures in the completed `513/518` run. The repaired class-prefix run is
  `Saved/Tests/cache-ic468-value-layout-diagnostic-focused1/
  20260811_175902_791_bc41e56c`, `6/6 PASS`.

## IC-469 — first IC-465 focused selector matched no registered Automation test

- Severity/state: test-execution selector / reproduced and closed on 2026-08-11.
- Exact boundary: the official wrapper launched Editor-Cmd successfully, discovered
  11005 tests, then the method-qualified target
  `Angelscript.TestModule.Cache.Archive.Primitives.WireEnumsFlagsAndValidationClassesAreFrozen`
  matched none and exited 255. No test body ran and this is not feature RED.
- Root cause: this CQTest registration exposes the class prefix as the stable
  runner selection boundary; the report's class/method display path is not a
  guaranteed independently selectable full Automation ID.
- Decision/resolution: retain the no-match report as execution evidence and run
  the source-declared class prefix `Angelscript.TestModule.Cache.Archive.Primitives`.
  Use the corresponding source-declared class prefixes for the other four repairs
  instead of assuming report display-name concatenation.
- Required evidence: each corrected class-prefix run must discover and execute at
  least one method and report explicit pass/fail counts.
- Task impact/evidence: no-match report is `Saved/Tests/
  cache-ic465-trait-flags-focused1/20260811_175531_615_eec342e5`; process exit 255,
  wrapper exit 1, and the log explicitly says `No automation tests matched`.

## IC-470 — value-type owned functions omit their intrinsic owner layout dependency

- Severity/state: P0 function-artifact dependency closure / production repair
  built and verified across every invocation family plus the complete prefix on
  2026-08-11.
- Exact boundary: after IC-467 routes the invocation-family fixture through the
  real execution-envelope encoder, the first value-type method
  `int FExecutableGeneratedValue::Read()` is rejected. The raw artifact reports a
  type-layout symbol use for stable type
  `ac775872...9877c41`; the declared dependency set contains the same owner only
  as `Declaration` plus its property as `PropertyLayout`, so validation returns
  Error 47 at offset 92.
- Root cause: `CaptureSuccessfulActualDependencies` already recognizes the
  function owner as an intrinsic root-signature input and synthesizes an owner
  `Declaration` dependency. For `asOBJ_VALUE` owners, the detached artifact root
  also encodes the concrete owner layout, but the bridge does not synthesize the
  corresponding `VALUE_LAYOUT` dependency when the compiler body reports only
  property-layout edges. The opaque codec correctly refuses to reinterpret a
  declaration fingerprint as a layout fingerprint.
- Decision/resolution: at the same bridge boundary that adds intrinsic owner
  declaration input, add an intrinsic owner `VALUE_LAYOUT` input only when
  `artifactOwnerType->GetFlags() & asOBJ_VALUE`. Resolve and canonicalize it
  through the existing production dependency resolver. Do not add layout
  dependencies to reference-class methods, coerce dependency kinds, or bypass the
  envelope relocation check.
- Required evidence: rebuild; focused InvocationFamilyParity must encode and
  restore all invocation families with no compiler fallback, and the existing
  symbol/dependency negative tests plus complete Cache prefix must remain green.
- Task impact/evidence: production-shaped RED is `0/1` at `Saved/Tests/
  cache-ic467-invocation-envelope-focused1/20260811_175958_347_bd456006`.
  This refines IC-467: raw/envelope confusion was the original broad failure, and
  the corrected fixture then exposed a distinct dependency-closure defect rather
  than a budget problem. After the repair, `Saved/Tests/
  cache-ic470-value-owner-layout-focused2/20260811_180219_144_7a96366e`
  restores all 16 non-Factory artifacts without compiler invocation; its only
  three fallbacks are the independent Factory ordering defect in IC-472.

## IC-471 — IC-470 bridge repair dereferences a formerly forward-declared type

- Severity/state: local production build/include boundary / reproduced, fixed and
  rebuilt on 2026-08-11.
- Exact boundary: the first IC-470 Development Editor build stops in
  `AngelscriptCacheCompilerBridge.cpp:399` with C2027 because `asCTypeInfo` is
  incomplete when the new intrinsic-owner rule calls `GetFlags()`.
- Root cause: this translation unit previously passed `asCTypeInfo*` through
  resolver descriptors without dereferencing it, so `as_scriptfunction.h`'s
  forward declaration was sufficient. IC-470 legitimately needs the maintained-
  fork type interface.
- Decision/resolution: include `as_typeinfo.h` in the bridge implementation only.
  Do not add a public-header dependency or cast through an unrelated concrete
  object type.
- Required evidence: the unchanged official Development Editor target must
  compile and link before rerunning IC-470 behavior.
- Task impact/evidence: build RED is `Saved/Build/
  cache-ic470-value-owner-layout-build1/20260811_180132_523_00ad3e9a`; UBT ran one
  compile action, reported only C2027, and never linked or ran behavior.

  The include-only repair is verified by `Saved/Build/
  cache-ic471-value-owner-layout-build2/20260811_180205_716_b1ea4973`, `4/4 PASS`.

## IC-472 — Factory restore observes constructor functions before artifact identity initialization

- Severity/state: P0 order-independent stable FunctionKey and Fresh Engine
  restore / declaration-time repair, focused parity, adjacent and complete-prefix
  regressions verified on 2026-08-11.
- Exact boundary: the corrected
  `InvocationFamilyParity.ForcedCleanAndCachedArtifactsMatchAcrossTwoEngines`
  restores 16 of 19 persisted artifacts directly. Exactly three reference-class
  Factory artifacts are rejected and fall back to compilation. Each Factory raw
  artifact contains a function-signature relocation to its constructor behavior;
  while the Factory restore callback runs, that current-Engine constructor has
  the right local module, `objectType` and declaration but still reports
  `artifactInvocationKind=INVALID` and `artifactOwnerType=null`. Consequently
  `TryBuildFunctionKey` cannot produce the stable identity declared by the donor.
- Root cause: `BuildCompileCode()` deliberately processes the `factories` array
  before `CompileFunctions()`. Builder registration already stores the semantic
  invocation kind in `sFunctionDescription`, but copies it to the public
  `asCScriptFunction` only in `BeginBuildArtifactCompile()`. Stable identity of a
  referenced function therefore depends on whether that function's compiler/
  restore callback happened earlier, which violates Fresh Engine order
  independence and would also make StaticJIT routing sensitive to callback order.
- Decision/resolution: initialize each newly declared local script function's
  artifact invocation kind and semantic owner at declaration/registration time,
  including generated and explicit constructors, destructors, methods,
  `InitDefaults` and global-shaped Factory functions. Retain
  `BeginBuildArtifactCompile()` as the assertion/finalization boundary for the
  same identity and canonical source slice. Do not collapse constructor
  references to type-only dependencies and do not teach the codec a
  declaration-specific fallback; both would discard function-granular identity
  required by StaticJIT and hide other forward-reference orderings.
- Required evidence: add an explicit lifecycle assertion that a Factory restore
  callback can build the stable key of its constructor before the constructor's
  own callback; rebuild; rerun InvocationFamilyParity with all 19 artifacts
  restored and zero compiler fallbacks; run stable-symbol, dependency-negative
  and complete Cache prefixes with no failures/skips/not-run.
- Task impact/evidence: `Saved/Tests/
  cache-ic470-value-owner-layout-focused2/20260811_180219_144_7a96366e` reports
  the three exact failures. Diagnostics show symbol-use kind 3 and declarations
  `FParityLeaf()`, `FGeneratedParityOwner()` and `ExplicitParityOwner()` with
  `module=current`, valid `objectType`, invocation zero, no artifact owner and
  key failure `Function has no stable cacheable invocation kind`. The explicit
  lifecycle RED is `Saved/Tests/cache-ic472-forward-reference-lifecycle-red1/
  20260811_181008_247_b3b81e3d`, `0/1`: all three Factory probes report kind zero,
  owner mismatch and no stable key. The maintained-fork repair builds at
  `Saved/Build/cache-ic472-declaration-identity-green-build1/
  20260811_181214_344_cc9a0bb4`, `4/4 PASS`. Focused GREEN is `Saved/Tests/
  cache-ic472-forward-reference-green1/20260811_181229_493_3a8ebe91`, `1/1`:
  all 19 artifacts restore without compiler invocation; raw execution, v5
  envelope, debug payload, complete VM-state hash, stable key and observable
  destructor/return behavior are identical across producer and consumer Engines.
  Stable identity/dependency adjacency passed `10/10` at `Saved/Tests/
  cache-ic472-adjacent-regression1/20260811_181346_495_cafada93`. The authoritative
  complete Cache prefix passed `518/518` (`432` Success plus `86`
  SuccessWithWarnings), failed/not-run/in-process `0/0/0`, at `Saved/Tests/
  cache-v314-full-regression2/20260811_181500_343_270718d5`.

## IC-473 — lifecycle test referenced a non-exported maintained-fork cast helper

- Severity/state: test-only DLL link boundary / reproduced, fixed and rebuilt on
  2026-08-11.
- Exact boundary: the first IC-472 lifecycle-assertion build compiles the changed
  `AngelscriptTest` unity translation unit, then its DLL link fails with LNK2019
  for `CastToObjectType(asCTypeInfo*)` referenced by `RestoreArtifact`. No Runtime
  behavior or test body executes.
- Root cause: `CastToObjectType` is a maintained-fork internal helper available
  to Runtime translation units but is not exported from `AngelscriptRuntime` for
  a separate UE test-module DLL to link. Including `as_objecttype.h` makes its
  declaration visible but does not change the DLL boundary.
- Decision/resolution: the Factory callback contract already guarantees that
  `Function->artifactOwnerType` is the object type that the Factory constructs;
  use an explicit test-local `static_cast<const asCObjectType*>` under that
  contract. Do not export an internal cast helper or widen Runtime API solely for
  a white-box assertion.
- Required evidence: the unchanged Development Editor target must link, then the
  new lifecycle assertion must run and reproduce the pre-fix metadata failure.
- Task impact/evidence: official wrapper label
  `cache-ic472-forward-reference-red-build1`; artifact `Saved/Build/
  cache-ic472-forward-reference-red-build1/
  20260811_180909_785_3166325d`; four actions were scheduled, compilation and
  import-library link passed, and the DLL link stopped only on LNK2019/LNK1120.
  The corrected test module builds and links at `Saved/Build/
  cache-ic473-forward-reference-red-build2/
  20260811_180946_768_4b334d5b`, `4/4 PASS`, before the intentional behavior RED.

## IC-474 — package smoke lagged Runtime diagnostic schema and retained prior-run evidence

- Severity/state: final-acceptance tooling and cold-start evidence integrity /
  both helper defects reproduced and repaired with focused RED/GREEN self-tests
  on 2026-08-11; Development cold scenario is GREEN and the warm scenario now
  reaches the separate IC-475 Runtime gap.
- Exact boundary: the first real Development package build/cook/stage/archive
  completed successfully and its packaged executable performed a normal cold
  compile, captured nine of eleven eligible modules, published transaction one,
  flushed with Error 0 and wrote `01-cold.json`. The wrapper then rejected that
  valid report with `Unsupported Cache V2 process report schema '3'`. A second
  inspection showed that `-SkipPackage` reused the exact prior Archive as
  intended but did not remove its previous `Saved/CachePackageSmoke`; rerunning
  unchanged would therefore classify the prior persisted store as scenario
  `01-cold` and invalidate the launch oracle.
- Root cause: C++
  `FAngelscriptCacheDiagnosticSnapshot::CurrentSchemaVersion` and the Python dump
  reader both support schema 3, including stable `functionRoutes`, while the
  independently authored PowerShell report reader still hard-coded schemas 1/2.
  The package runner also treated build-product reuse and smoke-evidence reuse as
  the same operation even though its seven-scenario matrix requires a fresh
  Store at entry.
- Decision/resolution: accept diagnostic schemas 1/2/3 in the PowerShell reader,
  require the schema-3 `functionRoutes` envelope and retain rejection of unknown
  future schemas; Python remains the deep per-route/session-to-store validator.
  Add one explicit evidence reset that may delete only a non-reparse-point
  directory named exactly `Saved/CachePackageSmoke` below the disposable Archive.
  Call it after package-layout validation and before scenario one, so
  `-SkipPackage` reuses only the packaged binaries and loose Script baseline.
  Reject the Archive root, outside paths, sibling Saved content, files and
  reparse points rather than broadening destructive authority.
- Required evidence: focused helper test must fail first on schema 3 and on the
  missing reset API, then pass with schema 1/2/3 compatibility, incomplete-v3
  rejection, idempotent bounded cleanup and sibling preservation. Reuse the
  exact successfully packaged Development run root and complete all seven cold/
  warm/edit/invalid/restored/structural scenarios, including Python session
  correlation, before running Shipping.
- Task impact/evidence: the package/runtime-success but wrapper-failure report is
  `Saved/CachePackage/cache-v76-real-Development/
  20260811_183513_864_f2ccf611/Summary.json`; its `01-cold.json` is schema 3 and
  contains Current plus 79 records, nine modules and stable function routes.
  Schema RED failed exactly at line 663 of the old reader; reset RED failed
  exactly because `Reset-AngelscriptCacheSmokeEvidence` did not exist. The focused
  GREEN command is `Tools/Diagnostics/TestAngelscriptCachePackageSmoke.ps1`,
  process exit 0 with `AngelScript Cache package-smoke helper self-tests passed`.
  Reusing the packaged archive after bounded evidence reset completed `01-cold`,
  including PowerShell schema-3 checks and Python Current/LatestSuccessful Store
  correlation, before `02-unchanged-warm` exposed IC-475. This issue changes only
  disposable validation orchestration; no packaged Cache Runtime or Store format
  was altered.

## IC-475 — real warm launch exposed missing production per-function compiler reuse

- Severity/state: P0 production Cache V2 closure gap / open 2026-08-11; exposed by
  the first real Development unchanged-warm launch after IC-474 made the package
  oracle trustworthy.
- Exact boundary: cold launch captured nine of eleven discovered modules and
  published Generation
  `67226cfdcd28741843f2284981b3da1e11d729e210f46761d9ad817ae326b6d6`,
  source snapshot
  `65f41e02bb2610f5f47fab24f003377b886f81ada32b2f5c636210e2c0b06c3b`,
  79 diagnostic records and 56 stable routes. Two real modules were explicitly
  `NotCacheable`. The unchanged launch selected that exact persisted Generation,
  then exact-start restore safely returned `ExactStartup/ModuleSetMismatch(9)`
  with detail `The current and persisted exact-start module sets differ` because
  the current set still contained all eleven modules. It fell back to normal
  compilation, recaptured nine modules and reported `restoredFromStore=false`, so
  the package runner correctly failed `Scenario 'Warm' expected Current to be
  restored from Store.`
- Root cause: exact startup deliberately restores and activates only a complete
  module set. After that atomic fast path misses, production `InitialCompile()`
  preprocesses the sources and passes only
  `FAngelscriptCacheCompileCaptureContext` into `CompileModules()` for post-compile
  capture/publication. Repository-wide call-site inspection finds
  `SetBuildArtifactRestoreCallback` and
  `SetBuildArtifactCompileResultCallback` installed only by Cache test code (plus
  maintained-fork forwarding); `AngelscriptRuntime` never installs them during a
  real compile. `FAngelscriptCacheCompilerBridge::TryRestoreFunctionFromValidatedGraph`
  is implemented, but no production path supplies it with the selected persisted
  graph. V5.4/V5.5 therefore prove component behavior and maintained-VM parity,
  not the required `InitialCompile()` production closure.
- Decision: retain strict exact full-generation activation, graph validation and
  the package warm assertion. Do not hide the failure by deleting/isolation-staging
  the two complex scripts, treating a normal recompile as a warm hit, or activating
  a partial module set. Add V5.6 to carry one selected graph-validated Generation
  beyond exact-start miss, construct the current declaration/type/module-state
  authorities needed for source/input validation at the correct compiler phase,
  and install per-module builder restore/compile-result callbacks. Restored hits
  and compiled misses must still produce one complete atomic active/publication
  result. The precise pre-function authority split must be designed before code;
  current Clean Capture derives part of that authority only after compilation.
- Required evidence: first add a production integration RED through real
  `InitialCompile()`/`CompileModules()` rather than directly attaching callbacks
  in the test. Its persisted candidate must be partial or source-changed, observe
  at least one unchanged pre-compiler restore and one normal compile miss, retain
  clean-versus-cached VM/behavior parity, publish the complete module set atomically
  and emit typed hit/miss counts. Then rerun focused Cache/HotReload/StaticJIT,
  Editor/PIE and the unchanged Development warm scenario before Shipping.
- Task impact/evidence: adds unchecked V5.6 and corrects mechanical progress from
  `51/53` to `51/54`; V7.6 and V7.7 remain unchecked. Package evidence is
  `Saved/CachePackage/cache-v76-real-Development/
  20260811_183513_864_f2ccf611/Summary.json`, with scenario reports under
  `Archive/Windows/AngelscriptProject/Saved/CachePackageSmoke/Reports/`.
  `01-cold.json` is valid cold/publication evidence; `02-unchanged-warm.json` is
  the authoritative Runtime RED. A secondary diagnostic gap was also observed:
  `CleanCapture/NotCacheable` events omit the existing capture-detail string, so
  the exact reason for the two skipped modules is not visible at normal report
  verbosity. That observability repair may accompany V5.6 but cannot substitute
  for production reuse.
- TDD update 2026-08-11: the new production-only method
  `PartialPersistedGenerationRestoresEligibleFunctionDuringInitialCompile` builds
  and links, cold-publishes one of two current modules, opens the same persisted
  Generation in a new Engine, reaches typed exact `ModuleSetMismatch`, recompiles
  safely and executes both values `901/902`. It then fails at the sole wished-for
  production boundary because no `FunctionLookup/Restored` event exists. Official
  RED is `0/1` at `Saved/Tests/cache-v56-production-reuse-red-test1/
  20260811_190501_808_57dcc346`; exact assertion is line 204 of
  `AngelscriptCacheProductionCompilerReuseTests.cpp`. This is now the V5.6 Slice 1
  authority; no direct callback is installed by the test.
- GREEN update 2026-08-11: Slice 2 retains the selected immutable read session
  only after a zero-activation `ModuleSetMismatch`, passes it through the normal
  `CompileModules` transaction, and installs graph-validated per-module callbacks
  after `BuildLayoutFunctions` and before stage 3. The unchanged complete source
  snapshot is the conservative current-authority proof for this slice. The full
  Development Editor build passed 105 actions at `Saved/Build/
  cache-v56-production-reuse-green-build1/
  20260811_191302_827_020780d8`; the formerly RED production method is `1/1` at
  `Saved/Tests/cache-v56-production-reuse-green-test1/
  20260811_191544_967_beeb8116`, with a typed restored event tied to Generation
  `cd0408db093f5b70e11649af3faf629c536be2b948a69be19ce75bdf57b75d55`
  and correct current values `901/902`. IC-475 remains open until Slice 3 proves
  changed-source mixed reuse and complete republishing.
- Slice 3 TDD update 2026-08-11: the production prefix now contains the second
  real `InitialCompile()` method
  `BodyOnlyEditRestoresUnchangedFunctionAndCompilesChangedFunctionDuringInitialCompile`.
  It cold-publishes one admitted module containing two functions, rewrites only
  one body, starts a fresh Engine and proves the current functions execute as
  `1001/2002` under a new SourceSnapshot. The typed exact-start event is
  `DirectInputMismatch`, while the unchanged function has no
  `FunctionLookup/Restored` event. Official RED is total/pass/fail/skip
  `2/1/1/0` at `Saved/Tests/cache-v56-bodyedit-red-test1/
  20260811_192219_981_49441350`; the sole failure is the wished-for unchanged
  hit at test line 388. The preceding test-only Development build passed `4/4`
  actions at `Saved/Build/cache-v56-bodyedit-red-build1/
  20260811_192159_355_948d4777`. This narrows the remaining IC-475 boundary:
  production currently retains a reuse context only for `ModuleSetMismatch`, and
  its module preparation accepts only complete SourceSnapshot equality; changed
  source therefore cannot yet supply current pre-compile authorities.

## IC-476 — V5.6 RED fixture used a runtime string with UE checked Printf

- Severity/state: test compile frontier / reproduced and corrected 2026-08-11;
  no production source was changed.
- Exact boundary: the first official V5.6 RED build reached the new
  `AngelscriptCacheProductionCompilerReuseTests.cpp` translation unit and failed
  at both `FString::Printf(*Template, ...)` calls with C2664. UE 5.8's checked
  formatting overload requires a compile-time format-string authority and does
  not accept the normalized runtime `FString` returned by `ASTEST_AS`.
- Decision/resolution: keep `ASTEST_AS` normalization and the per-test unique
  symbol suffix, but replace every literal `%s` token with the unique suffix via
  case-sensitive `FString::Replace`. Do not bypass checked formatting with an
  unsafe variadic API or remove isolation from the fixture.
- Required evidence: the unchanged Development Editor target must compile and
  link the new test, then the focused Automation method must execute and fail only
  because production emits no `FunctionLookup/Restored` event.
- Task impact/evidence: official wrapper label
  `cache-v56-production-reuse-red-build1`; artifact `Saved/Build/
  cache-v56-production-reuse-red-build1/
  20260811_190402_413_df2cba6d`; UBT scheduled four actions and stopped only at
  the new test's two checked-format call sites. The corrected build and production
  behavior evidence are now recorded under IC-475.

## IC-477 — V5.6 bridge draft referenced a nonexistent ModuleDesc header

- Severity/state: compile-preflight integration defect / detected by source review
  and corrected before the first GREEN build on 2026-08-11.
- Exact boundary: the initial `AngelscriptCacheCompileReuse.cpp` draft included
  `Core/AngelscriptModuleDesc.h`, but `FAngelscriptModuleDesc` is defined in the
  existing `Core/AngelscriptEngine.h`; no standalone ModuleDesc header exists. The
  same review confirmed that `asSBuildArtifactCompileResult::function` does exist,
  but added a null guard before deriving a StableFunctionKey.
- Decision/resolution: include the authoritative existing Engine header rather
  than create a duplicate type header or move unrelated declarations during V5.6.
  Keep the compile-result observer fail-closed when the maintained callback ever
  supplies no function.
- Required evidence: the official Development Editor wrapper must discover the new
  runtime translation unit, compile and link the complete target, followed by the
  real production-path Automation method.
- Task impact/evidence: no failed build artifact was produced because the invalid
  include was removed during preflight. `cache-v56-production-reuse-green-build1`
  then completed 105/105 actions at `Saved/Build/
  cache-v56-production-reuse-green-build1/
  20260811_191302_827_020780d8`; the focused test passed `1/1` at `Saved/Tests/
  cache-v56-production-reuse-green-test1/
  20260811_191544_967_beeb8116`. No task was added or closed.

## IC-478 — pre-compile enum authority cannot require ClassGenerator output pointers

- Severity/state: V5.6 current-authority phase-order defect / reproduced,
  root-caused, corrected and focused-verified on 2026-08-11.
- Exact boundary: `cache-v56-bodyedit-green-build1` compiled and linked, but the
  body-edit production method remained RED because
  `BuildAngelscriptCacheCurrentModuleAuthority` compared the preprocessor-owned
  `FAngelscriptEnumDesc::ScriptType` with the staging module's current enum. At the
  required hook point—after `BuildLayoutFunctions`, before stage 3 and before
  ClassGenerator—the descriptor pointer is still null. Runtime emitted the exact
  typed preparation detail `The enum descriptor and current compiled AS enum
  authority disagree`; no callback was installed and the unchanged function was
  compiled.
- Root cause/evidence: repository tracing finds the sole normal-compile assignment
  at `AngelscriptClassGenerator_Analyze.cpp:1617`, after function compilation and
  during ClassGenerator analysis. `FAngelscriptEnumDesc::Enum` is likewise a
  generated reflection output. The current `asCModule::GetEnumByIndex` object is
  already authoritative at the pre-compile boundary; the descriptor can validate
  canonical name and declaration intent but cannot provide post-ClassGenerator
  pointers yet.
- Decision/resolution: preserve the ownership check by requiring the descriptor's
  `EnumName` to equal the current AS enum name case-sensitively. Derive the admitted
  TypeSchema reflection kind from the presence of the enum descriptor, which is the
  declaration that ClassGenerator will materialize, rather than from a not-yet-
  assigned `UEnum*`. Do not move the callback later, synthesize ClassGenerator
  output early, or drop semantic name validation.
- Required evidence: rerun the same focused production prefix. It must prepare the
  changed-source authority, restore only the unchanged StableFunctionKey, compile
  only the changed key and retain `1001/2002` behavior. Then run authority/Clean
  Capture determinism regressions to prove pre- and post-compile enum schemas agree.
- Task impact/evidence: build succeeded 6/6 at `Saved/Build/
  cache-v56-bodyedit-green-build1/20260811_192936_617_f464a593`; failed test report
  is `Saved/Tests/cache-v56-bodyedit-green-test1/
  20260811_193001_204_e21012ad`, total/pass/fail/skip `2/1/1/0`, process/wrapper
  exit `255/1`. The phase-corrected build then succeeded 4/4 at `Saved/Build/
  cache-v56-bodyedit-green-build2/20260811_193206_238_bc12cbf6`; the unchanged
  focused command passed `2/2/0/0` at `Saved/Tests/
  cache-v56-bodyedit-green-test2/20260811_193224_024_f34526db`. The body-edit
  method restored the unchanged StableFunctionKey, compiled the changed key,
  executed `1001/2002`, and published the current one-module Generation. This is
  a resolved repair inside V5.6, not a new checklist task.

## IC-479 — root-class authority passed an optional declaration field as a mapper output reference

- Severity/state: V5.6 implementation compile defect / reproduced, root-caused,
  corrected and verified on 2026-08-11.
- Exact boundary: the first root-class GREEN build reached the new shared
  authority implementation and failed at
  `AngelscriptCacheCurrentModuleAuthority.cpp:746` with C2664. The phase-correct
  type mapper accepts `FAngelscriptCachedDataType&`, while
  `FAngelscriptCachedDeclaration::DeclaredType` is intentionally
  `TOptional<FAngelscriptCachedDataType>` because not every declaration owns a
  declared type. The test translation unit compiled; no runtime or Store path ran.
- Root cause/evidence: the existing post-compile root-class authority path maps
  into a local concrete `FAngelscriptCachedDataType` and only assigns the optional
  after successful validation. The new pre-compile path incorrectly tried to use
  the optional itself as that out parameter. Official failed build evidence is
  `Saved/Build/cache-v56-class-bodyedit-green-build1/
  20260811_194917_354_ccb599ce`, process/wrapper exit `6/1`; UBT scheduled seven
  actions and the sole reported compiler error is the incompatible fourth
  argument.
- Decision/resolution: follow the existing authority pattern exactly: map the
  function return type into a local concrete value, fail closed on mapping error,
  then move the validated value into `Declaration.DeclaredType`. Do not weaken the
  semantic DTO by changing `DeclaredType` from optional and do not make the mapper
  accept an optional output.
- Verification: the immediate corrected build passed 5/5 at `Saved/Build/
  cache-v56-class-bodyedit-green-build2/20260811_195009_071_bb3b2883`. The later
  maintained-builder rebuild passed 32/32 at `Saved/Build/
  cache-v56-class-bodyedit-green-build3/
  20260811_195247_870_9fc1c403`, and the focused runtime proof passed `1/1/0/0`
  at `Saved/Tests/cache-v56-class-bodyedit-green-test2/
  20260811_195331_681_6bc99df3` with the unchanged method restored and changed
  method compiled.
- Task impact: correction remains inside V5.6 Slice 3 and adds no checklist item.

## IC-480 — generated class invocations had no canonical source authority before the restore hook

- Severity/state: V5.6 maintained-builder phase-order gap / reproduced,
  root-caused, corrected and verified on 2026-08-11.
- Exact boundary: after IC-479's build correction, the root-class production test
  still failed `1/0/1/0`. The current-authority producer reached the staging class
  but rejected its generated default constructor with
  `Staging function UCacheProductionClass...() has no stable invocation/source
  authority`. The diagnostic dump proves zero FunctionLookup events while both
  reflected methods execute current values `1101/2102` and the complete current
  Generation publishes normally.
- Root cause/evidence: the maintained builder already assigns stable invocation
  kind/owner when generated default constructor, destructor and factory functions
  are registered. Their canonical source slice, however, is retained on the
  `asCScriptFunction` only inside `BeginBuildArtifactCompile`, after the host must
  have built current ModuleInterface/TypeSchema authority and installed the restore
  callback. The same `sFunctionDescription`/`sFactoryDescription` tables already
  contain script, class node, function and owner before stage 3; delaying the
  canonical slice is therefore an API phase-order gap, not missing source data.
  Evidence is `Saved/Tests/cache-v56-class-bodyedit-green-test1/
  20260811_195030_462_0b7a17ba`, process/wrapper exit `255/1`.
- Decision/resolution: add a semantic-only builder preparation pass at the end of
  successful `BuildLayoutFunctions()`. It constructs the same finalized
  `asSBuildArtifactInvocation` coordinates used later by stage 3 and retains kind,
  owner and canonical source on each scheduled function, but does not emit a
  callback, capture dependencies, restore bytecode or invoke the compiler.
  `BeginBuildArtifactCompile` reuses the same retention helper, so pre-compile and
  compiler-time authority cannot drift. Do not move the host callback after stage
  3 and do not synthesize source text in Unreal-side Cache code.
- Verification: the maintained-fork build passed 32/32 with process/wrapper exit
  `0/0` at `Saved/Build/cache-v56-class-bodyedit-green-build3/
  20260811_195247_870_9fc1c403`. The unchanged root-class command passed `1/1/0/0`
  at `Saved/Tests/cache-v56-class-bodyedit-green-test2/
  20260811_195331_681_6bc99df3`. Its 17-event pre-assert dump reaches graph-owned
  function lookup, restores unchanged key
  `54539df0049fbc418b2235d2ba1825a7d43501f119b29110728983a4fc449b77`,
  compiles edited key
  `52dd6aaabe3bee92bd1bffb11e5791102ee2c8d1d77a3a33ea5f0c816bd8f6d7`
  and preserves reflected execution `1101/2102`. Adjacent invocation-family parity
  and Clean Capture tests remain acceptance work, not an unresolved IC-480 defect.
- Task impact: maintained AngelScript source is explicitly in scope. This remains
  a V5.6 Slice 3 repair and adds no checklist item.

## IC-481 — changed-source root-class authority rejected otherwise stable local properties

- Severity/state: V5.6 production authority capability gap / reproduced,
  root-caused and corrected on 2026-08-11; focused publication follow-up exposed
  IC-482 rather than an IC-481 authority failure.
- Exact boundary: the new two-Full-Engine property test reaches production
  `InitialCompile()` for both generations and reports
  `Current pre-compile authority rejected module: Error=2 Detail=The first current
  root-class authority slice admits no local properties`. No FunctionLookup
  restore/compile events are installed, so the sole assertion failure is the absent
  unchanged-method Restored event at test line 407.
- Root cause/evidence: `BuildRootClassMethodAuthority` contains an explicit
  `ScriptType->localProperties.GetLength() != 0 || !ClassDesc->Properties.IsEmpty()`
  fail-closed guard and builds neither property declarations nor ordered property
  schemas. This is not a source-identity, ClassGenerator or layout instability:
  both Engines produce identical ModuleKey, TypeKey, PropertyKey and VM/reflected
  offset `48`; defaults remain `31/31`, reflected execution is `1131/2132`, and
  both transactions publish one module. Evidence is `Saved/Tests/
  cache-v56-class-property-red-test1/
  20260811_200356_014_8b219a26`, total/pass/fail/skip `1/0/1/0`; test-only build
  11/11 is `Saved/Build/cache-v56-class-property-red-build1/
  20260811_200333_717_94bcb914`.
- Decision: construct current property authority exclusively from the staging
  `asCObjectProperty` table and preprocessor `FAngelscriptPropertyDesc` metadata,
  using the same primitive/environment type mapping, stable PropertyKey,
  declaration/trait/reflection hashes, storage layout, PropertyLayoutFingerprint
  and TypeSchema dependency rules as Clean Capture. Never copy candidate property
  declarations/layouts into current authority and never ignore a property dependency
  merely to obtain a function hit. Unsupported property shapes remain typed safe
  misses.
- Required evidence: the unchanged test must emit graph-owned FunctionLookup
  events, restore the property-reading unchanged method, compile the edited method,
  preserve identical property identity/layout/defaults and current behavior
  `1131/2132`, and publish the complete current Generation. Adjacent method-only
  production reuse must remain GREEN; later shared-producer refactoring must prove
  Clean Capture/current authority semantic equality rather than retaining two
  drifting implementations.
- Task impact: correction remains V5.6 Slice 3; no new checklist item. The class-
  graph/inheritance vertical and Slice 4 remain downstream.

## IC-482 — restored functions lost stable dependency provenance before next-generation capture

- Severity/state: V5.6 cross-generation publication defect / reproduced,
  root-caused and corrected for the two-Engine root-class property vertical on
  2026-08-11; third-generation and broad-regression acceptance pending.
- Exact boundary: after IC-481's property authority implementation, the property-
  bearing two-Full-Engine test now reaches the desired production hybrid result:
  the unchanged property-reading method is `Restored`, the edited method is
  `Compiled`, VM/reflection offsets are `48/48`, defaults are `31/31`, and current
  reflected execution is `1131/2132`. Post-ClassGenerator Clean Capture then
  rejects the restored method with
  `Function int ReadUnchanged() stable execution envelope failed: Error=47
  Class=5 Kind=5 Stage=4 Offset=149`; `Error=47` is
  `RelocationDependencyMismatch`. The transaction therefore publishes zero
  current modules and the sole assertion failure moves to the required complete-
  publication check at test line 423.
- Reproduction/evidence: the official build command
  `Tools\RunBuild.ps1 -Label cache-v56-class-property-green-build1 -NoXGE`
  passed with process/wrapper exit `0/0` at `Saved/Build/
  cache-v56-class-property-green-build1/
  20260811_200747_296_cdf883ff`. The official focused command
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassPropertyCompilerReuse" -Label
  cache-v56-class-property-green-test1 -TimeoutMs 600000` is reproducible as
  total/pass/fail/skip `1/0/1/0`, process/wrapper exit `255/1`, at
  `Saved/Tests/cache-v56-class-property-green-test1/
  20260811_200803_957_63fca948`. Its 17-event dump records one restored stable
  method, one compiled edited method and a rejected Clean Capture with
  `PublishedModules=0`.
- Root cause/evidence: a normal compiler invocation populates the current
  `asCScriptFunction::scriptData->artifactDependencies` with Engine-local pointer
  observations. The maintained restore path intentionally preserves only the
  current canonical source and clears the donor's `artifactDependencies` before
  committing restored VM state (`as_restore.cpp`); cached stable dependencies must
  never be replayed as raw pointers. `TryRestoreFunctionFromValidatedGraph` has
  already graph-validated the selected body's pointer-free `ActualDependencies`
  and matched them against current declaration/type/layout/state authority before
  returning `Restored`, but `FAngelscriptCacheCompileReuseContext` discards that
  provenance. Post-compile Clean Capture consequently sees only the intrinsic
  owner dependency while the restored VM relocation stream still contains the
  property-layout relocation, so exact relocation/dependency validation correctly
  fails.
- Decision: on a successful `Restored` result only, retain a bounded pointer-free
  copy of that selected body's canonical `ActualDependencies` in the compile-
  transaction context, keyed by stable ModuleKey plus FunctionKey. Expose it
  through a narrow read-only dependency-source interface whose lifetime ends with
  the compile transaction. Clean Capture uses this source only for functions
  actually restored in that transaction; compiler-invoked functions continue to
  derive dependencies from current compiler observations. It must canonicalize the
  carried list, re-resolve `FunctionInputDigest` against the complete current
  interface/type/state/function authority, and validate the raw VM relocation
  stream against those current stable dependencies before encoding or publishing.
  Do not synthesize `asSBuildArtifactDependency` pointers, weaken
  `RelocationDependencyMismatch`, trust candidate data before current-input match,
  or attach UE cache DTOs to maintained AngelScript function objects.
- Required evidence: the existing property test must pass without weakening its
  current-publication assertion; the resulting generation must be flushable and
  reopenable. A subsequent third full Engine must consume that newly published
  generation and restore the unchanged property-reading method, proving that
  restore-after-restore remains closed across generations. Method-only/global
  hybrid tests and complete Cache regressions must remain GREEN, and diagnostics
  must identify whether Clean Capture used compiler-observed or graph-carried
  dependency provenance.
- Correction/evidence: a successful bridge lookup now returns only the selected
  body's pointer-free dependency list; the compile-reuse context stores it under
  ModuleKey plus FunctionKey behind a transaction-local lock and implements a
  read-only dependency-source interface. All Clean Capture verticals consult that
  source only for functions actually restored; they canonicalize the list, run
  normal current-input resolution and validate the current raw VM relocation
  stream before publication. Compiled functions retain compiler-observed
  dependencies. The affected official build passed with process/wrapper `0/0` at
  `Saved/Build/cache-v56-restored-deps-green-build1/
  20260811_201933_516_dfc27246`. The unchanged focused command passed `1/1/0/0`,
  process/wrapper `0/0`, at `Saved/Tests/
  cache-v56-restored-deps-green-test1/
  20260811_202009_776_cc91d84c`: the second transaction records
  `GraphCarriedDependencyFunctions=1`, captures one module with zero skips,
  publishes a non-restored current SourceSnapshot, and preserves restore/compile
  split plus `31/31`, `48/48`, `1131/2132` behavior.
- Task impact: this remains inside V5.6 Slice 3/4 and adds no mechanical checklist
  item. Class-graph/inheritance work starts only after the complete root-class
  generation can be published and consumed again.

## IC-483 — unchanged third Engine falls back from exact startup because one generated invocation is absent from the published graph

- Severity/state: V5.6 repeated-startup coverage/diagnostic gap / reproduced,
  root-caused and corrected with focused verification on 2026-08-11; broad
  regression and package acceptance remain pending.
- Exact boundary: after the IC-482 two-Engine GREEN is explicitly flushed, a
  third complete Engine starts with byte-identical source and selects that new
  persisted Generation. Exact startup emits typed reason `10` with detail
  `A persisted module is outside the executable exact-start restore vertical`.
  Normal production compile reuse then restores four functions from the selected
  Generation, reports one stable FunctionKey miss, invokes the compiler only for
  that missing generated function, captures one module with zero skips and four
  graph-carried dependency sets, and publishes the same SourceSnapshot again.
  Property/type/module identity, offsets `48/48`, defaults `31/31` and reflected
  behavior `1131/2132` remain correct; only the test's required whole-Generation
  exact-restore assertion fails.
- Reproduction/evidence: official build
  `Tools\RunBuild.ps1 -Label cache-v56-third-generation-build1 -NoXGE` passed
  process/wrapper `0/0` at `Saved/Build/cache-v56-third-generation-build1/
  20260811_202402_720_1821afd8`. Official focused command
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassPropertyCompilerReuse" -Label
  cache-v56-third-generation-test1 -TimeoutMs 600000` is total/pass/fail/skip
  `1/0/1/0`, process/wrapper `255/1`, at `Saved/Tests/
  cache-v56-third-generation-test1/
  20260811_202421_618_6bd5c57a`. The third trace has 14 events, four
  `FunctionLookup/Restored`, one `FunctionKeyMiss` followed by one `Compiled`, and
  `GraphCarriedDependencyFunctions=4`; failure is the absent exact-start Restored
  event at test line 546.
- Current diagnostic gap: the FunctionLookup event identifies the missing stable
  key (`ce1ac92c392e620f861621aa5be156e528794362d67fd3277064c18443c4b11c` in
  this run) but omits invocation kind and canonical declaration. This prevents the
  trace alone from distinguishing a constructor, factory, destructor or user
  method and must be corrected as part of V5.6 bounded hybrid diagnostics.
- Root cause/direct evidence: bounded FunctionLookup detail now includes invocation
  kind, generated bit and canonical declaration. The official diagnostic rerun at
  `Saved/Tests/cache-v56-ic483-diagnostic-test1/
  20260811_202725_894_670ff324` names the persistent miss exactly as
  `InvocationKind=1 Generated=0 Declaration=UClass StaticClass()`. The live
  function still carries `asTRAIT_GENERATED_FUNCTION`; the builder invocation's
  generated bit is false because this helper is emitted into the preprocessed
  module surface rather than synthesized by that individual compile call. Both
  root-class and class-graph Clean Capture deliberately exclude the helper from
  public FunctionBody records and instead register it with
  `AddDerivedStaticClassFunction`, paired with `__StaticType_*`, as a type-owned
  ClassGenerator derivation. Candidate absence is therefore intentional; the
  erroneous behavior is classifying that intentional derivation as an unexplained
  `FunctionKeyMiss` rather than a typed `NotCacheable` compiler fallback.
- Decision boundary: do not relabel an unexplained compile as a valid exact hit.
  First map the key to the current invocation/declaration and compare builder
  callback coverage against the FunctionBody links actually published by the
  second transaction. V3.5 deliberately restricts whole-Generation exact startup
  to its frozen enum-plus-primitive-global vertical, so a reflected class module
  is expected to report typed `ModuleIneligible` and continue through bounded
  V5.6 hybrid reuse. If an invocation is part of that hybrid executable closure,
  give it stable capture/restore coverage; only an explicitly derived or
  unsupported invocation may become a typed `NotCacheable` fallback.
- Selected correction: identify only the exact generated-trait, ownerless global
  `UClass StaticClass()` helper at the production callback adapter and return
  `NotCacheable` before candidate lookup, with detail that it is reconstructed
  from current TypeSchema/ClassGenerator authority. Keep its stable FunctionKey
  in the decision event so the paired compile-result event is auditable. Do not
  persist a duplicate public FunctionBody, collapse ordinary user `StaticClass`
  calls, or generalize the exemption to constructors/factories/destructors.
- Required evidence: a pre-assert diagnostic names every restored/missed generated
  invocation, the published graph and current callback set have explainable exact
  coverage, and the third complete Engine either performs a real exact restore or
  has an explicit spec-approved typed non-cacheable boundary. In both cases no
  unexplained FunctionKey miss remains and a fourth repeat must not accumulate
  additional generated-function misses.
- Correction/evidence: the callback adapter now classifies only the exact
  generated-trait, ownerless `UClass StaticClass()` helper as typed
  `NotCacheable`; its detail states that current TypeSchema/ClassGenerator
  authority reconstructs it, and the paired compiler-result event retains the
  same stable FunctionKey. The corrected Runtime/Test build passed with
  process/wrapper `0/0` at `Saved/Build/cache-v56-ic483-green-build2/
  20260811_203104_595_1317d31f`. The unchanged focused command passed
  `1/1/0/0`, process/wrapper `0/0`, at `Saved/Tests/
  cache-v56-ic483-green-test1/20260811_203125_690_a9ffe86b`. The third complete
  Engine selects the warm Generation and identical SourceSnapshot, reports the
  expected exact-start `ModuleIneligible`, restores all four persisted function
  bodies (including both user methods), classifies and compiles exactly one
  derived `StaticClass` helper, has zero unexplained `FunctionKeyMiss`, carries
  four graph dependency sets into a complete one-module publication, and
  preserves offsets `48/48`, defaults `31/31` and behavior `1131/2132`.
- Task impact: remains within V5.6 Slice 3/4 and adds no mechanical checklist item;
  class-graph/inheritance widening waits until this same-source root-class closure
  is understood.

## IC-484 — third-generation acceptance test used an unavailable TArray predicate count and omitted the lookup-status declaration

- Severity/state: focused-test compile defect / reproduced, root-caused and
  corrected with official build/test verification on 2026-08-11.
- Exact boundary/evidence: official build
  `Tools\RunBuild.ps1 -Label cache-v56-ic483-green-build1 -NoXGE` failed with
  process/wrapper `6/1` at `Saved/Build/cache-v56-ic483-green-build1/
  20260811_203022_850_faccb179`. Runtime compiled and linked, while
  `AngelscriptCacheProductionClassPropertyCompilerReuseTests.cpp` failed because
  UE 5.8 `TArray` has no `CountByPredicate` member and the test did not include the
  header declaring `EAngelscriptCacheFunctionCandidateLookupStatus`.
- Decision/correction: use a simple explicit loop for the bounded trace count and
  include `AngelscriptCacheCompilerBridge.h`; do not add a generic test helper,
  change product behavior or replace the typed reason with a magic integer.
- Required evidence: the same official build label successor compiles Runtime and
  Test, followed by the unchanged IC-483 focused behavioral RED/GREEN command.
- Correction/evidence: `cache-v56-ic483-green-build2` passed at
  `Saved/Build/cache-v56-ic483-green-build2/
  20260811_203104_595_1317d31f`, followed by focused `1/1/0/0` at
  `Saved/Tests/cache-v56-ic483-green-test1/
  20260811_203125_690_a9ffe86b`; no production behavior was changed by this
  test-only correction.
- Task impact: test-only repair inside V5.6; no new checklist item or persisted
  schema/API change.

## IC-485 — production class-graph RED fixture used incompatible FStringView and CQTest runner types

- Severity/state: test-only compile defect / reproduced, root-caused and corrected
  with official successor build on 2026-08-11.
- Exact boundary/evidence: adding the standalone
  `AngelscriptCacheProductionClassGraphCompilerReuseTests.cpp` invalidated the UBT
  makefile and the official command `Tools\RunBuild.ps1 -Label
  cache-v56-class-graph-red-build1 -TimeoutMs 1800000 -NoXGE` failed with
  process/wrapper `6/1` at `Saved/Build/cache-v56-class-graph-red-build1/
  20260811_203957_352_d3022e7f`. The fixture passed `FStringView` directly to the
  `FString::Equals(const FString&)` overload and named a nonexistent unparameterized
  `CQTest::TTestRunner`; the generated test owns `TTestRunner<FNoDiscardAsserter>`.
- Decision/correction: materialize the bounded class-name view as an owned
  `FString`, and accept the shared `FAutomationTestBase&` interface in execution
  and trace helpers. Do not expose the generated runner template or add a
  cache-specific testing API merely to satisfy these helpers.
- Required evidence: the successor official build must compile the new test before
  its runtime result can be treated as the class-graph production RED.
- Correction/evidence: `Tools\RunBuild.ps1 -Label
  cache-v56-class-graph-red-build2 -TimeoutMs 1800000 -NoXGE` passed all seven
  actions with process/wrapper `0/0` at `Saved/Build/
  cache-v56-class-graph-red-build2/20260811_204112_365_705682ed`.
- Task impact: test-only repair inside V5.6; no cache schema, wire or production
  behavior change.

## IC-486 — adaptive non-unity compilation exposed a missing direct AngelScript API include in environment profiling

- Severity/state: Runtime include-hygiene defect / reproduced, root-caused and
  corrected with adaptive non-unity successor build on 2026-08-11.
- Exact boundary/evidence: the same official build compiled a newly separated
  adaptive unity set and failed `AngelscriptCacheEnvironmentProfile.cpp` because
  `asEP_LAST_PROPERTY`, `asEEngineProp` and the complete `asIScriptEngine` API were
  available only through a prior unity neighbor. The file directly enumerates
  engine properties and calls `GetEngineProperty`, so `AngelscriptEngine.h`'s
  forward declaration is insufficient.
- Decision/correction: include the maintained public wrapper
  `Core/AngelscriptInclude.h` directly in the owning translation unit. Do not
  forward-declare public enum constants, include a private maintained-fork header
  or rely on unity ordering.
- Required evidence: the same successor build must compile the separated Runtime
  unit, followed by the focused production class-graph test.
- Correction/evidence: the separated Runtime unit and linked Runtime/Test DLLs
  passed in `cache-v56-class-graph-red-build2`, process/wrapper `0/0`, at
  `Saved/Build/cache-v56-class-graph-red-build2/
  20260811_204112_365_705682ed`.
- Task impact: compile hygiene inside existing Cache V2 environment profiling; no
  runtime, persisted or checklist semantic change.

## IC-487 — initial class generation does not apply the derived local default in the production inheritance fixture

- Severity/state: cache-independent ClassGenerator baseline/fixture assumption /
  reproduced and isolated on 2026-08-11; retained as an explicit parity
  observation while the cache test proceeds with reflected execution values.
- Exact boundary/evidence: the first focused class-graph run reached normal source
  discovery, preprocess, compile, ClassGenerator and object construction, but the
  derived instance held `DerivedValue=0` rather than the fixture's inline
  initializer value `13`; the base value was initialized. The assertion failed at
  line 405 before the test could inspect the intended hybrid-reuse boundary.
  Evidence is total/pass/fail/skip `1/0/1/0`, process/wrapper `255/1`, at
  `Saved/Tests/cache-v56-class-graph-red-test1/
  20260811_204134_431_3bd27e49`.
- Follow-up evidence/root cause boundary: changing the fixture to the plugin's
  explicit `default Property = Value;` syntax did not change the cold result:
  `BaseValue=7`, `DerivedValue=0`. At the same time the IC-488 correction let cold
  Clean Capture publish and flush one complete module, proving this observation
  occurs before and independently of cache restore. Evidence is
  `Saved/Tests/cache-v56-class-graph-red-test2/
  20260811_204455_090_487d7e33`, `1/0/1/0` solely at the early default assertion.
- Second follow-up: after the fixture assigned explicit execution values, the next
  run observed cold derived default `0` but warm derived default `13`, even though
  warm current authority rejected the entire multi-class module and restored zero
  functions. The variation is therefore lifecycle/ClassGenerator behavior, not a
  Cache V2 hit or stale artifact. Evidence is `Saved/Tests/
  cache-v56-class-graph-red-test3/
  20260811_204650_226_944f9eaf`.
- Decision/correction: preserve and log each Engine's default observation without
  asserting equality, then assign `7/13` through the generated reflected properties
  before invoking cached/compiled methods. This keeps property layout, inheritance,
  relocation and execution coverage real without making Cache V2 responsible for
  an independent initial ClassGenerator default behavior. Do not silently assert
  that the defaults are stable or edit production scripts.
- Required evidence: all three Engine generations must execute the explicitly
  assigned state as cold `1020/131`, warm and third `1020/132`; a separate
  ClassGenerator change may own default initialization consistency later if
  desired.
- Task impact: test-fixture boundary only; no production AS file or cache runtime
  behavior is changed.

## IC-488 — class-graph Clean Capture encoded the code-root boundary instead of the complete script-base size

- Severity/state: V5.6 class-graph TypeSchema producer defect / reproduced,
  root-caused and cold-publication corrected on 2026-08-11; focused hybrid and
  broad verification pending.
- Exact boundary/evidence: the same cold Engine compiled and generated the two-
  class graph but rejected its complete publication with
  `InvalidQualifierCombination` (`Error=31`, TypeSchema `Field=15`,
  `LayoutExpectation`) for the derived type. The derived staging type reported
  semantic size/alignment `64/8`, VM `basePropertyOffset=48`, inherited base type
  size `56`, and local `DerivedValue` at offset `56`. Clean Capture used the VM's
  code-root boundary `48` as `BasePropertyBoundary` while its own BaseType layout
  input correctly contributed `56`; TypeSchema replay and restore therefore
  rejected the internally contradictory record.
- Decision/correction: for a same-module derived class, encode the complete live
  base type size as `BasePropertyBoundary`; retain `basePropertyOffset` only for a
  root script class over its native code root. Keep the existing TypeSchema replay
  and restore equality checks strict and keep BaseType layout input unchanged.
- Required evidence: cold class-graph Clean Capture must serialize and publish the
  module; existing class-graph capture/restore suites must remain GREEN; only then
  may the second Engine expose the planned current-authority RED.
- Correction evidence: the official correction build passed seven actions at
  `Saved/Build/cache-v56-class-graph-red-build3/
  20260811_204435_589_72cf077f`. The next focused run captured `Candidates=1
  Captured=1 Skipped=0`, published one complete cold module and flushed it
  successfully before the independent IC-487 assertion stopped the test.
- Task impact: production TypeSchema capture correction within V5.6. It changes no
  wire layout or schema version because it fixes the semantic value of an existing
  field.

## IC-489 — production current authority rejected the complete same-module inheritance graph before function lookup

- Severity/state: V5.6 production class-graph reuse gap / authoritative RED
  reproduced, root-caused and focused GREEN on 2026-08-11; adjacent and broad
  regressions pending.
- Exact boundary/evidence: after IC-488, the cold Full Engine captures, publishes
  and flushes the complete two-class module. The changed-source second Full Engine
  compiles the current source, materializes the expected base/derived UClass graph,
  exposes both reflected properties, and executes explicitly assigned state as
  `1020/132`. Before stage 3, production reuse reports
  `Current pre-compile authority rejected module: Error=2 Detail=Current module
  authority currently admits zero-or-one enum with global functions and no class,
  delegate, import or post-init declarations`; zero functions are restored, then
  normal compilation and complete current publication succeed.
- Reproduction/evidence: official build `cache-v56-class-graph-red-build4` passed
  four actions with process/wrapper `0/0` at `Saved/Build/
  cache-v56-class-graph-red-build4/20260811_204628_320_abb2d60c`. Focused command
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassGraphCompilerReuse" -Label
  cache-v56-class-graph-red-test3 -TimeoutMs 600000` is total/pass/fail/skip
  `1/0/1/0`, process/wrapper `255/1`, at `Saved/Tests/
  cache-v56-class-graph-red-test3/20260811_204650_226_944f9eaf`. That run stopped
  at an IC-487 default-parity assertion before the intended restore assertions,
  but the typed authority rejection and zero-restored boundary are already direct
  Runtime evidence; a fixture-only successor will expose the same boundary at the
  exact FunctionLookup assertions.
- Decision: extend the phase-correct current semantic authority producer to the
  same class-graph vertical already admitted by Clean Capture: topological
  same-module base relations, complete base-size layout boundary, local properties,
  reflected method metadata, inherited/local method and VFT ownership, generated
  behaviors and StaticClass derivations. Derive exclusively from staging VM plus
  preprocessor descriptors; do not use later UClass/UFunction outputs, candidate
  TypeSchema as current authority, source-text classification or module-wide blind
  restore.
- Required evidence: a fixture-only rerun must fail only at missing Restored
  events; the correction must restore unchanged base/override/derived methods,
  compile only the edited method, execute `Super::` and reflected values, publish
  the complete changed Generation, and let a third Engine consume it with zero
  unexplained FunctionKey misses. Existing class-graph capture/restore tests and
  root-class production tests must remain GREEN.
- Correction: `BuildAngelscriptCacheCurrentModuleAuthority()` now routes modules
  with two or more classes through a dedicated phase-correct graph producer. It
  finds unique staging VM types from preprocessor descriptors, orders them
  base-before-derived, derives complete base-size/property/layout authority,
  reconstructs local/inherited method and VFT ownership, reflected member
  coordinates, generated behaviors, ModuleInterface/ModuleState and stable
  type/property/function references. It does not read candidate TypeSchema as
  current authority and does not require the later UClass/UFunction outputs.
- Correction evidence: official adaptive non-unity build
  `Tools/RunBuild.ps1 -Label cache-v56-class-graph-green-build1 -TimeoutMs
  1800000 -NoXGE` passed four actions with process/wrapper `0/0` at
  `Saved/Build/cache-v56-class-graph-green-build1/
  20260811_210151_995_94bd243b`. Official focused command
  `Tools/RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassGraphCompilerReuse" -Label
  cache-v56-class-graph-green-test1 -TimeoutMs 600000` passed total/pass/fail/
  skip `1/1/0/0`, process/wrapper `0/0`, at `Saved/Tests/
  cache-v56-class-graph-green-test1/
  20260811_210208_843_e91246b7`.
- Behavioral evidence: the changed-source second Engine kept module/type/property
  identities and VM/reflection offsets `48/48/56/56`, executed `1020/132`,
  restored all four expected unchanged base/override/derived functions
  (`Restored=1111`) and compiled only the edited `ReadChanged` body. It published
  the complete changed Generation. The byte-identical third Engine restored every
  persisted ordinary/generated artifact, classified the two current
  `StaticClass()` helpers as typed `NotCacheable` before compiling them, reported
  `UnknownMisses=0`, published one complete module and executed `1020/132`.
- Task impact: this is the planned V5.6 class-graph/inheritance authority closure;
  no new checklist item or wire/schema version is added.

## IC-490 — bounded decision events could not prove production hybrid reuse after the transaction ended

- Severity/state: V5.6 diagnostic/package-acceptance gap / C++ and Python REDs
  reproduced, production summary plus package oracle GREEN on 2026-08-11;
  cross-feature and real package reruns remain pending.
- Exact boundary: production already emitted typed per-function `FunctionLookup`
  events, but `FAngelscriptCacheCompileReuseContext` retained no typed aggregate
  and its lifetime ended with `InitialCompile()`. The live/session JSON therefore
  could not report the selected candidate Generation, candidate-module count or
  restored/compiled/not-cacheable/rejected counts when tracing was disabled or
  older events were evicted. The Development package helper consequently knew
  only `restoredFromStore=false` and could not distinguish a real hybrid warm run
  from a plain full fallback compile. Separately, the production Clean Capture
  skip event copied the typed error code but omitted its already available
  `CaptureResult.Detail`, hiding why partial Generations omitted modules.
- RED evidence: the new separate C++ test translation unit failed the official
  build only on the missing DTO/snapshot/service members at `Saved/Build/
  cache-v56-function-reuse-diagnostics-red-build1/
  20260811_213131_112_525f2bf2`. The separate Python tests failed `24/26` GREEN,
  one failure plus one error, because schema 4 was rejected and no
  `functionReuse` coordinate validation existed at `Saved/Tests/
  cache-v56-function-reuse-python-red1`. The package helper self-test then
  rejected schema 4 exactly at `Read-AngelscriptCacheReport` before the wished-
  for exact-or-hybrid oracle could run.
- Decision: keep per-function events as bounded explain detail, but make the
  compile-reuse transaction own a lock-protected pointer-free run summary.
  Publish its immutable value once after authoritative `CompileModules()` returns
  and clear it at the start of each initial compile. Diagnostic schema 4 carries
  `candidateGenerationId`, `candidateModuleCount`, `restoredFunctionCount`,
  `compiledMissCount`, `notCacheableCount` and `rejectedCorruptCount`; the
  aggregate remains available independently of decision-trace capacity. Do not
  persist the summary in Cache records and do not derive it from numeric
  FunctionIds or process pointers. Copy Clean Capture's bounded detail into the
  existing typed event.
- Package decision: unchanged warm acceptance is exactly one of (a) exact whole-
  Generation restore, or (b) schema-4 hybrid proof with the expected candidate
  Generation and at least one restored function plus typed compiled/unsupported
  work. Zero restored functions remain a hard failure. Body and structural edit
  scenarios use the same oracle together with their required SourceSnapshot
  transition, so plain recompilation cannot masquerade as incremental success.
- Required evidence: C++ must prove absent/published/reset schema values and a
  real two-Engine partial/body-edit path must populate candidate/restored/compiled
  counts from the maintained callbacks. Python must validate/render full stable
  coordinates and reject malformed ones. PowerShell must accept exact and hybrid
  schema-4 reports, reject zero-restored fallback and reject Clean Capture failures
  without detail. Complete Cache and cross-feature/package gates must remain
  GREEN before V5.6 closes.
- GREEN evidence: official build `cache-v56-function-reuse-detail-green-build3`
  passed `4/4`, process/wrapper `0/0`, at `Saved/Build/
  cache-v56-function-reuse-detail-green-build3/
  20260811_214138_453_1fbe37b2`. The separate DTO tests passed `2/2` at
  `Saved/Tests/cache-v56-function-reuse-diagnostics-green-test1/
  20260811_213751_122_e976e441`. The real production partial/body-edit tests
  passed `2/2` at `Saved/Tests/cache-v56-function-reuse-detail-green-test3/
  20260811_214158_583_d23e73a2`, including stable candidate equality, nonzero
  restored counts, body-edit compiler-miss count and nonempty production Clean
  Capture detail. Python passed `26/26` at `Saved/Tests/
  cache-v56-function-reuse-python-green3`; the package helper self-test exits 0
  and covers exact, hybrid, plain-fallback rejection, schema shape and capture
  detail.
- Task impact: this implements the planned V5.6 Slice 4 diagnostic and reader
  surface. V5.6 remains unchecked until the latest Cache/HotReload/StaticJIT/
  Editor/PIE and Development package gates pass; no extra checklist item is added.

## IC-491 — unattended packaged startup compile failure opened an interactive modal and outlived the smoke wrapper

- Severity/state: V7.6 Development invalid-source acceptance blocker / modal,
  timeout and status corrections are GREEN; final Cache-lifecycle ordering is
  focused GREEN on 2026-08-12 and awaits a fresh package rerun.
- Exact command/evidence: `Tools\RunAngelscriptCachePackageSmoke.ps1
  -Configuration Development -Label cache-v76-schema4-development1 -TimeoutMs
  3600000` produced a new package successfully in `131329 ms` beneath
  `Saved/CachePackage/cache-v76-schema4-development1-Development/
  20260811_221010_689_b043ffc8`, then completed reports plus Python dumps for
  `01-cold`, `02-unchanged-warm` and `03-one-body-edit`. The outer run exhausted
  its one-hour deadline during `04-invalid-source`, returned `124`, and could not
  reach its finally block to write Summary/RunMetadata.
- Production-reuse evidence retained from the incomplete run: schema-4 unchanged
  warm selected cold Generation
  `67226cfdcd28741843f2284981b3da1e11d729e210f46761d9ad817ae326b6d6`,
  prepared nine candidate modules, restored 19 functions, compiled four misses,
  classified four functions NotCacheable and rejected zero corrupt artifacts.
  The body edit selected the same candidate, changed SourceSnapshot, restored 18
  functions, compiled five misses, classified four NotCacheable and rejected zero
  corrupt artifacts. Both reports passed the package oracle and Python Store/
  session correlation before scenario four began.
- Root cause: the invalid fixture reached the intended startup compile error at
  `22:13:17`, but the desktop branch of `FAngelscriptEngine` startup error handling
  checks only Slate initialization. It ignores `FApp::IsUnattended()` and opens
  `FSlateApplication::AddModalWindow` even though the packaged process was launched
  with `-unattended`. Startup therefore never reached
  `-ExecCmds=as.Cache.Flush,quit`, wrote no `04-invalid-source.json`, and remained
  alive after the timed-out wrapper was terminated. The exact orphan command line
  was verified and only that packaged process tree was stopped. A separately
  abandoned serial-All Cache worker was also identified by its old label and
  stopped; current CoarseDynamic All workers were preserved.
- Decision: preserve the interactive Editor retry window, but make unattended
  startup failure a first-class noninteractive branch before any Slate modal.
  That branch must retain diagnostics, publish the requested Cache process report,
  request a deterministic nonzero exit and never wait for hot reload/user input.
  Do not merely enlarge the smoke timeout or weaken the invalid-source scenario.
  The process runner must also terminate an exact timed-out child process tree so
  wrapper timeout cannot leak packaged processes.
- Required evidence: add a focused RED around the startup-failure policy before
  production code; prove interactive Editor remains retry-capable while unattended
  mode selects report-and-exit. Add/extend package-helper timeout self-tests for
  exact child cleanup. Build through `Tools\RunBuild.ps1`, run focused C++/helper
  tests, then resume this exact archive with the guarded `-SkipPackage` path and
  complete scenarios 01-07 from a freshly reset evidence root. Finally rerun a
  fresh Development package before Shipping acceptance.
- RED evidence: a separate test translation unit,
  `AngelscriptStartupCompileFailurePolicyTests.cpp`, was added before production
  changes. Official build `cache-v76-unattended-policy-red-build1` failed only on
  the intentionally missing `bIsUnattended`,
  `EAngelscriptStartupCompileFailureResponse` and
  `ResolveAngelscriptStartupCompileFailureResponse` surface at `Saved/Build/
  cache-v76-unattended-policy-red-build1/
  20260811_232424_069_70838993`; process/final exit was `6/1`. The three methods
  distinguish unattended exit, retained interactive Editor retry, and commandlet/
  explicit-exit/no-window exit.
- Policy GREEN evidence: Runtime config now captures `FApp::IsUnattended()` and
  `InitialCompile()` consumes the pure response policy before any Slate modal.
  Unattended selects a graceful exit request so normal Engine shutdown can flush
  and write the requested report; commandlet/explicit-exit retain immediate exit,
  and interactive Editor retains modal retry. Official build passed `106/106`
  actions with process/final exit `0/0` at `Saved/Build/
  cache-v76-unattended-policy-green-build1/
  20260811_232607_691_bc5cf1f8`. The focused Automation prefix passed `3/3/0/0`,
  process/final `0/0`, at `Saved/Tests/
  cache-v76-unattended-policy-green-test1/
  20260811_233001_783_6fa8c571`.
- Runner RED/GREEN evidence: the package-helper self-test first failed only
  because the wished-for per-launch timeout resolver did not exist. The helper
  now caps one packaged launch at `300000 ms`, always subtracts `30000 ms` outer
  cleanup headroom, rejects a deadline that cannot reserve that headroom, and the
  production scenario loop consumes it. Existing `Invoke-StreamingProcess`
  remains responsible for exact root-PID process-tree termination. The helper
  self-test then passed with exit 0 through
  `Tools/Diagnostics/TestAngelscriptCachePackageSmoke.ps1`.
- First fresh-package correction evidence: Development run
  `cache-v76-schema4-development2` rebuilt/cooked/staged/archived in about 124.5s
  and reached invalid source without a modal at `Saved/CachePackage/
  cache-v76-schema4-development2-Development/
  20260811_233244_274_34a142c0`. Scenario 04 logged graceful unattended exit,
  executed normal Engine pre-exit, flushed CacheV2 and wrote
  `04-invalid-source.json`; the entire runner returned in `180747 ms` with no
  orphan. Its remaining RED was precise: `RequestExit(false)` maps a graceful
  Windows request to status 0, so the package oracle rejected the invalid launch
  as unexpectedly successful before scenarios 05-07.
- Exit-status RED/GREEN: a fourth focused method was added first and the official
  build failed only on the missing typed exit-request policy at `Saved/Build/
  cache-v76-unattended-status-red-build1/
  20260811_233633_284_e7ddda59`, process/final `6/1`. Production now calls
  `RequestExitWithStatus`; unattended resolves to `force=false,status=3`, while
  forced noninteractive paths retain `force=true,status=3`. Official GREEN build
  passed 106 actions, process/final `0/0`, at `Saved/Build/
  cache-v76-unattended-status-green-build1/
  20260811_233707_159_7275065d`; the focused policy prefix passed `4/4/0/0` at
  `Saved/Tests/cache-v76-unattended-status-green-test1/
  20260811_233923_892_02fb8184`.
- UE exit-code constraint and final policy correction: with independent Zen
  running, `cache-v76-schema4-development4` completed package creation and again
  reached scenario 04 at `Saved/CachePackage/
  cache-v76-schema4-development4-Development/
  20260811_234413_252_ff5067b3`. Runtime logged
  `Requesting graceful exit with status 3`, wrote the report and returned quickly,
  but the observed code was still 0. Directly launching the nested real game
  binary (`04-direct-inner.*`) also returned 0, excluding the outer bootstrap.
  UE 5.8 source proves `RequestExitWithStatus(false, 3)` posts a Windows quit
  message while `GuardedMain()` retains `EngineInit()`'s zero `ErrorLevel`.
- Revised decision: a plugin cannot propagate a graceful nonzero return through
  that engine boundary. Failed startup never owns a publishable Generation and
  the prior last-good Store is already durable, so the unattended path must first
  synchronously emit the explicitly requested diagnostic report through the same
  writer used at normal shutdown, then force `RequestExitWithStatus(true, 3)`.
  This retains observable diagnostics and deterministic failure without a modal;
  interactive Editor still uses retry.
- Forced-report RED/GREEN: the focused test first failed on the missing
  `bWriteRequestedDiagnosticReportBeforeExit` contract at `Saved/Build/
  cache-v76-forced-report-red-build1/
  20260811_234915_004_8d5ae837`, process/final `6/1`. The official 106-action
  build then passed at `Saved/Build/cache-v76-forced-report-green-build1/
  20260811_235031_736_dccdaab9`. Four policy methods passed `4/4/0/0` at
  `Saved/Tests/cache-v76-forced-report-green-test1/
  20260811_235208_959_109ff0e9`, and the package-helper self-test remained GREEN.
- Forced-report package RED: fresh Development run
  `cache-v76-schema4-development5` rebuilt/cooked/staged/archived and completed
  cold, unchanged-warm and body-edit scenarios at `Saved/CachePackage/
  cache-v76-schema4-development5-Development/
  20260811_235318_845_3c6497e7`. Invalid source wrote the requested schema-4
  report, logged an immediate status-3 exit and returned without a modal or
  orphan. The package oracle then isolated one remaining defect: the report had
  `mutationPhaseName=InitializingAnyThread`, so it was not a complete shutdown
  report. The runner completed in `170548 ms` with a structured RED summary.
- Lifecycle-order decision: `FAngelscriptCacheService::BeginEngineShutdown()` is
  an idempotent lock-protected phase assignment only. It neither freezes nor
  flushes nor publishes a Generation, and is already called by the destructor.
  The startup-failure path may therefore call it before the synchronous report,
  then force status 3; the disk Store remains the previous last-good version.
- Lifecycle-order RED/GREEN: the fourth method was extended first and official
  build `cache-v76-shutdown-report-order-red-build1` failed only because
  `bBeginCacheShutdownBeforeDiagnosticReport` did not exist, at `Saved/Build/
  cache-v76-shutdown-report-order-red-build1/
  20260811_235821_109_3cc5d6e7`, process/final `6/1`. Production now carries the
  explicit ordering field and calls `BeginEngineShutdown()` before the requested
  report. The official 106-action build passed at `Saved/Build/
  cache-v76-shutdown-report-order-green-build1/
  20260811_235847_540_78013b1d`. The focused policy prefix passed `4/4/0/0` at
  `Saved/Tests/cache-v76-shutdown-report-order-green-test1/
  20260812_000043_082_75d98ada`, and the package-helper self-test remains GREEN.
- Task impact: V5.6 remains unchecked even though real Development unchanged/body
  hybrid reuse is now directly proven; V7.6 remains unchecked until invalid,
  restored-last-good and both structural scenarios complete. No Cache wire/schema
  change is implied.

## IC-492 — parallel All exposed pre-existing Standalone fixture line-ending rejection

- Severity/state: broad-suite baseline failure outside CacheV2 runtime / reproduced
  and isolated on 2026-08-11; final parallel All attribution complete.
- Exact command/evidence: the official full runner was started as
  `Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy CoarseDynamic
  -TestModuleWorkers 4 -MaxParallelLight 4 -MaxParallelHeavy 4 -LabelPrefix
  cache-v56-schema4-all-parallel1 -TimeoutMs 3600000 -ContinueOnFail` without
  `-Fast` or exclusions. Its Standalone entry completed at `Saved/StandaloneTests/
  cache-v56-schema4-all-parallel1_02_Standalone/
  20260811_230524_813_e4c6ee41` with total/pass/fail `19/14/5`, raw CTest exit 8.
- Exact boundary: `UECliEndToEnd`, `OfflineContract`, `UEAnalysis`, `Corpus` and
  `Benchmarks` all converge on `manifest must use LF line endings`. The Standalone
  build and fourteen other CTests passed, including the package test. No CacheV2
  UE test has reported a failure from this result, and the CoarseDynamic runner
  continues other entries because `-ContinueOnFail` is active.
- Final suite attribution: `ParallelSuiteSummary.json` beneath `Saved/Tests/
  cache-v56-schema4-all-parallel1_20260811_230523` records 37 shards, 36 passed
  shards, one failed Standalone shard, aggregated total/pass/fail
  `2959/2954/5` and wall duration `1073425 ms`. Every Unreal Automation shard is
  GREEN, including Cache `525/525`, Editor `83/83`, HotReload `122/122`,
  StaticJIT `30/30` and AngelScriptSDK `691/691`.
- Decision: treat this as one shared fixture/checkout line-ending baseline issue,
  not five Cache regressions. Preserve the raw Standalone report, then establish
  whether the same fixtures fail on the maintained branch baseline before any
  scoped correction. Do not normalize unrelated files opportunistically while
  Cache production code is still under acceptance.
- Required evidence: inspect the exact manifest bytes and repository attributes
  read-only;
  if a correction becomes necessary, reproduce through the dedicated Standalone
  wrapper and keep that work distinct from CacheV2 acceptance.
- Task impact: this prevents the broad `All` run from being called fully GREEN,
  but does not invalidate the already GREEN complete Cache, HotReload, generated-
  AOT StaticJIT or Editor/PIE gates. It adds no Cache checklist item until baseline
  attribution proves a Cache-owned dependency.

## IC-493 — transient Cook-owned Zen exited before UAT Stage consumed its oplog

- Severity/state: package-infrastructure interruption outside CacheV2 / reproduced,
  root-caused and locally recovered on 2026-08-11; fresh package rerun pending.
- Exact command/evidence: fresh Development attempt
  `cache-v76-schema4-development3` built the game target and completed Cook, but
  `RunUAT BuildCookRun` failed before Stage/Archive at `Saved/CachePackage/
  cache-v76-schema4-development3-Development/
  20260811_234041_382_6f0b9965`. Its package log shows Zen initially healthy on
  `[::1]:8558`, Cook wrote and flushed the Windows oplog, then UAT's following
  oplog read was connection-refused. Process/final package exit was `1/1`; no
  packaged scenario launched.
- Exact boundary/root cause: no persistent `ZenServer` Windows service was
  installed. The Cook process launched `zenserver.exe` with
  `--owner-pid=<CookPid>`, so that transient server exited with Cook while UAT
  Stage still needed the just-produced oplog. This is neither an AS compile
  failure nor a Cache Store/report failure.
- Decision: do not change Cache code, cook settings or package assertions. Use
  the UE-shipped non-installing `zen.exe up -p 8558` to keep one user-mode Zen
  instance alive across Build/Cook/Stage/Archive, verify it with `zen.exe ps`,
  rerun the same official package wrapper, then stop it normally after the
  Development/Shipping matrix. Do not install a persistent Windows service.
- Recovery evidence: `zen.exe up -p 8558` returned successfully and
  `zen.exe ps` identified one server on port 8558, PID 105856, without an
  owner-pid lifetime argument.
- Recovery confirmation: the following `development4` package completed UAT and
  reached live scenarios, so the cross-Cook/Stage Zen lifetime correction is
  effective. Its scenario failure belongs to IC-491's UE exit-code iteration,
  not Zen.
- Task impact: development3 is infrastructure RED and provides no scenario
  acceptance. IC-491 and V7.6 remain open; the next fresh successful package is
  authoritative.

## IC-494 — package oracle conflated final persisted Generation with hybrid reuse candidate

- Severity/state: V7.6 package-test false rejection / reproduced, specified and
  helper-level TDD GREEN on 2026-08-12; archive scenario rerun pending.
- Exact command/evidence: fresh Development6 at `Saved/CachePackage/
  cache-v76-schema4-development6-Development/
  20260812_000259_158_0c22d163` completed UAT and proved scenario 04 fully GREEN:
  exit 3, no timeout/modal/orphan, schema 4 and `ShuttingDown`. Scenario 05 then
  produced Current with the Baseline SourceSnapshot and deterministic Baseline
  Generation A while its valid function-reuse candidate was the most recent
  successful body-edit Generation B (`18` restored, `5` compiled misses). The
  helper rejected B because one expected-ID parameter was also being used for A.
- Specification boundary: `design.md` fixes V1 to the single Current historical
  candidate and explicitly adds no candidate-history file/database. Generation A
  may remain inspectable in immutable Store history, but candidate selection after
  body edit/invalid source correctly starts from Current/last-good B. Searching
  arbitrary historical generations would expand Runtime scope and is not needed
  for correctness.
- Decision: retain the strong two-coordinate oracle. Add
  `ExpectedHybridCandidateGenerationId` for function-level reuse and keep
  `ExpectedPersistedGenerationId` for exact whole-Generation restore. Python dump
  selection continues to verify the final Current independently. Scenario 05
  therefore requires persisted/final A and hybrid candidate B; neither assertion
  is weakened.
- TDD evidence: package-helper self-test first failed only because the new hybrid
  candidate parameter did not exist. The helper now validates it independently,
  includes a wrong-candidate rejection, and
  `Tools/Diagnostics/TestAngelscriptCachePackageSmoke.ps1` passes. Runner
  scenarios 02/03/05/06/07 now supply explicit exact and/or hybrid expectations.
- Required evidence/task impact: rerun all seven launches from the exact
  Development6 archive with `-SkipPackage`; then run a fresh Shipping package.
  IC-494 changes only test orchestration, not Cache wire/runtime behavior. V5.6
  and V7.6 remain open until the remaining real scenarios pass.
- GREEN closure: official `-SkipPackage` rerun
  `cache-v76-schema4-development6-resume1` reset the Development6 archive's
  isolated evidence root and passed all seven launches in `97613 ms`, exit 0.
  Baseline A, body B and structural C were distinct deterministic Generations;
  invalid exited 3 and retained B; restored source used candidate B but published
  A; structural warm reused C. Every report was schema 4 / `ShuttingDown` and
  every Python dump/session correlation passed.
- Task impact after rerun: V5.6 is now closed by real `InitialCompile()` package
  evidence together with the already GREEN complete Cache, HotReload, generated-
  AOT StaticJIT and Editor/PIE gates. V7.6 remains open only for the fresh
  Shipping matrix.

## IC-495 — plugin copy of unversioned serialization omitted UE 5.8 Shipping check guard

- Severity/state: V7.6 Shipping compile blocker outside CacheV2 / exact official
  UE parity fix applied on 2026-08-12; fresh Shipping rerun pending.
- Exact command/evidence: `Tools\RunAngelscriptCachePackageSmoke.ps1
  -Configuration Shipping -Label cache-v76-schema4-shipping1 -TimeoutMs 3600000`
  failed during the first Shipping target build at `Saved/CachePackage/
  cache-v76-schema4-shipping1-Shipping/
  20260812_001204_698_6d497846`. UBT compiled 53 actions and failed only at
  `Core/UnversionedPropertySerialization.cpp:715` because `SchemaEnd` was not
  declared; package exit `6/1`, no Cook or Cache process launch.
- Root cause/baseline: the iterator declares and initializes `SchemaEnd` only
  under `DO_CHECK || USING_CODE_ANALYSIS`, but the plugin fork left its
  `check(SchemaIt != SchemaEnd)` reference unconditional. Shipping removes the
  member while the check macro still compiles/type-checks its expression. The UE
  5.8 Engine authority at the same method wraps the check in the matching `#if`;
  the plugin's earlier 5.8 adaptation omitted that guard.
- Decision: match the UE 5.8 source exactly by guarding only the check. Do not
  retain an unused Shipping member and do not change iterator/serialization
  behavior. The configuration-specific Shipping build is the RED/GREEN proof;
  a C++ runtime unit would not exercise preprocessor absence.
- Required evidence/task impact: rerun the full official Shipping package matrix.
  This source fix is within the maintained plugin fork but independent of Cache
  wire/runtime semantics. V7.6 remains open until all seven Shipping launches
  pass.

## IC-496 — five runtime Engine accessors were defined inside the automation-test macro

- Severity/state: V7.6 Shipping link blocker / root-caused and source-corrected on
  2026-08-12; fresh Shipping link/package rerun pending.
- Exact command/evidence: Shipping2 at `Saved/CachePackage/
  cache-v76-schema4-shipping2-Shipping/
  20260812_001503_049_d535ca1b` passed the IC-495 translation unit, then failed
  linking `AngelscriptProject-Win64-Shipping.exe`. Five unresolved symbols were
  `FAngelscriptEngine::{GetTypeDatabase,GetBindState,GetToStringList,
  GetBindDatabase,GetBlueprintEventSignatureRegistry}`; package exit `6/1`, no
  Cook or scenario launch.
- Root cause: all five declarations and owned members are unconditional runtime
  state and unconditional Shipping callers exist, but their `.cpp` definitions
  were accidentally placed after `#if WITH_DEV_AUTOMATION_TESTS` together with
  actual test helpers. Editor/Development test builds hid the ownership error.
- Decision: move only the five runtime accessor definitions above the macro;
  retain pooled-context/count/config test helpers inside it. Do not remove
  Shipping callers, add process-global fallbacks or duplicate state.
- Required evidence/task impact: the next Shipping target link is the direct
  GREEN proof, followed by the full seven-launch matrix. This repairs the
  per-engine state ownership boundary used by Cache and normal bindings but does
  not alter wire data or accessor semantics. V7.6 remains open.

## IC-497 — Shipping compiles out ExecCmds used by the package-smoke exit protocol

- Severity/state: V7.6 Shipping launch blocker / fixed and full rebuilt Shipping
  matrix GREEN on 2026-08-12.
- Exact command/evidence: Shipping3 at `Saved/CachePackage/
  cache-v76-schema4-shipping3-Shipping/
  20260812_001618_177_815ba987` compiled, linked, cooked, staged, archived and
  passed loose-layout validation. UAT completed in `78126 ms`. Its first cold
  packaged launch then ran for the bounded `300000 ms`, wrote no Cache Store or
  process report, and was terminated with its exact PID tree. Summary duration
  was `382062 ms`, phase count zero; no orphan remained.
- Root cause/boundary: the harness used
  `-ExecCmds=as.Cache.Flush,quit`, but UE Shipping compiles out Exec command-line
  execution. UE's `-seconds`/benchmark exit parsing is also excluded by the
  Shipping build guard, so changing generic command spelling or increasing the
  timeout cannot close the lifecycle. Runtime/AS startup had no observable
  completion protocol and Shipping logging was suppressed.
- Decision: add one explicit `-as-cache-exit-after-startup` acceptance hook.
  Runtime captures it in `FAngelscriptEngineConfig` and requests a graceful exit
  only after successful InitialCompile, Cache transition to RuntimeGameThread,
  reload priming and initial-compile delegate broadcast. Normal Engine shutdown
  remains the sole Cache flush/report path. Failed InitialCompile bypasses this
  hook and retains IC-491's diagnostic status-3 path. The package helper removes
  its ExecCmds dependency rather than keeping two protocols.
- TDD evidence: helper self-test first failed because the Shipping-safe argument
  was absent. The first C++ authoring attempt failed on an incorrect include and
  is not behavior evidence. Trustworthy official RED
  `cache-v76-package-smoke-exit-red-build2` failed only on the missing config and
  pure policy API at `Saved/Build/cache-v76-package-smoke-exit-red-build2/
  20260812_002520_426_d90f5fe7`, process/final `6/1`.
- Focused GREEN: helper now requires the new flag and forbids the old ExecCmds.
  Official 106-action build passed at `Saved/Build/
  cache-v76-package-smoke-exit-green-build1/
  20260812_002602_677_6c47d37e`; independent prefix
  `Angelscript.TestModule.Cache.PackageSmokeExitPolicy` passed `1/1/0/0` at
  `Saved/Tests/cache-v76-package-smoke-exit-green-test1/
  20260812_002743_135_5bf052ae`.
- Final GREEN evidence: the fresh official Shipping4 run at `Saved/CachePackage/
  cache-v76-schema4-shipping4-Shipping/
  20260812_002908_845_b0d46d29` compiled, linked, cooked, staged and archived the
  corrected source, then passed all seven real executable launches. Final
  `Summary.json` records status Passed, exit 0, phase count 7 and duration
  `227499 ms`; no launch timed out. Cold/warm Baseline retained source
  `d96bfaa8...41929` and Generation `cad76a6b...1f7`; one-body edit published
  `2b84b1fa...6e17c` / `be94901a...8ee`; invalid source exited 3 in `2992 ms`
  without publication and retained the body-edit Generation; restored Baseline
  returned to the original Generation; structural cold/warm retained
  `1e0c321d...b8981` / `cf83875f...1c163`. Every report is schema 4 at phase
  `ShuttingDown`, and every Python dump integrity/session correlation passed.
- Task impact: this explicit test/debug lifecycle hook remains outside normal game
  auto-exit behavior. Together with the Development seven-launch matrix, it
  closes V7.6.

## IC-498 — production Pack preparation did not schedule the specified bounded workers

- Severity/state: V7.7 functional/performance gap / fixed with focused C++ and
  real Development package evidence on 2026-08-12.
- Exact boundary: `FAngelscriptCacheService::FlushPublicationToStore()` creates a
  default 64 MiB `FAngelscriptCachePackPolicy`, and
  `PrepareAngelscriptCacheColdGeneration()` unconditionally calls the serial
  `BuildAngelscriptCachePacks()`. The existing
  `AggregateAngelscriptCachePreparedRecordCompletions(..., BoundedParallel, ...)`
  validates arbitrary completion ordinals and canonicalizes their order, but it
  does not launch tasks or perform compression/Pack assembly concurrently.
  Therefore an immediate V7.7 serial/parallel timing table would compare labels,
  not implementations.
- Decision: keep Engine mutation serialized and add a bounded execution policy
  only around immutable record validation/hash/compression and independent Pack
  assembly. Completion order remains irrelevant because records are canonicalized
  first and result slots retain canonical Pack-group ordinals. The normal Runtime
  policy is bounded parallel; forced serial remains available for parity tests and
  benchmark command-line overrides. Pack target and worker count become explicit
  writer policy, not Compatibility/Profile identity.
- Required evidence/task impact: add a separate C++ test file proving worker
  bounds, actual task execution, serial/parallel byte-for-byte Pack/Manifest/
  Generation equality, failure clearing and 4/16/64 MiB grouping. Then build,
  run the focused prefix, generate real raw benchmark rows and rerun production
  package/Cache regressions. V7.7 stays open until this is GREEN and documented.
- Resolution evidence: `AngelscriptCacheParallelPackPreparationTests.cpp` proves
  actual non-caller worker execution, configured worker bounds, failure output
  clearing and serial/parallel byte-identical Pack bytes, indexes and IDs. Its
  seventeen 1 MiB records produce exactly 5/2/1 Packs at 4/16/64 MiB.
  `AngelscriptCacheWriterPolicyTests.cpp` proves production defaults, overrides,
  clamps, forced serial and Service policy ownership. The official 106-action
  build is `Saved/Build/cache-v77-writer-policy-green-build1/
  20260812_004755_958_6ebdd738`; the combined focused prefix passed `6/6/0/0`
  at `Saved/Tests/cache-v77-writer-parallel-green-test1/
  20260812_004931_819_965c666d`. The freshly built Development archive below
  also completed all seven production launches with the bounded-parallel
  default. Final benchmark and broad regression remain V7.7 acceptance, not a
  reopening of this implementation gap.

## IC-499 — benchmark ModuleState fixture initially used an unsupported mutable global

- Severity/state: V7.7 package-fixture error / exact Development RED then fixed
  and same freshly built Archive matrix GREEN on 2026-08-12.
- Exact boundary/evidence: the official `cache-v77-parallel-development1`
  build/cook/stage/archive succeeded at `Saved/CachePackage/
  cache-v77-parallel-development1-Development/
  20260812_005543_023_59f48f29`, but cold launch exited 3 because generated
  `CachePackageSmoke.as` declared `int CachePackageSmokeGlobal = 10` and the
  production preprocessor rejected mutable global variables. No Current was
  published; the startup-failure report/exit policy behaved correctly.
- Decision: retain the ModuleState mutation scenario but use supported
  `const int CachePackageSmokeGlobal = 10/20` initializer variants. This still
  changes the module's persisted global/initializer state without inventing a
  test-only language capability or touching project/business scripts.
- Required evidence/task impact: helper self-tests and all seven launches must
  pass against the exact freshly built Archive via `-SkipPackage` before it may
  feed V7.7 benchmark rows. This is fixture-only and does not reopen Runtime
  schema or writer policy.
- Resolution evidence: the corrected `const int` fixture passed helper
  validation and the exact archive rerun `cache-v77-parallel-development1-resume1`
  at `Saved/CachePackage/cache-v77-parallel-development1-Development/
  20260812_005543_023_59f48f29`. `Summary.json` records Passed, exit 0,
  `7/7` phases and `90098 ms`: cold/warm retain Generation `10bcfebe...14f2d`,
  body edit publishes `9c3ba002...2831`, invalid source exits 3 without
  replacing that generation, restored baseline returns to the original
  Generation, and structural cold/warm retain `bd299a95...97fb`. Every enabled
  report and Python dump/session correlation succeeded. This exact archive is
  the V7.7 benchmark input.

## IC-500 — benchmark collector indexed an optional Summary trace event as mandatory

- Severity/state: V7.7 evidence-tool bug / fixed and complete benchmark GREEN on
  2026-08-12.
- Exact boundary/evidence: the first `cache-v77-real1` cold packaged launch
  succeeded, published Generation `10bcfebe...14f2d`, and Python validated the
  real Store/session report. The collector then indexed element zero of an empty
  `LifecycleFlush` event selection. Summary mode intentionally writes schema-4
  aggregate JSON without enabling the bounded decision journal, so an empty
  trace is valid.
- Decision: treat lifecycle trace timing as nullable. External process duration,
  physical Manifest/Pack sizes, stable generation/source coordinates and
  aggregate function reuse remain available in Summary mode; only Verbose mode
  is expected to contain the bounded event sequence. The first correction also
  exposed PowerShell's pipeline unrolling of an empty array-valued `if`
  expression to `$null`; the collector now initializes the candidate variable as
  an explicit array before optional assignment.
- Required evidence/task impact: regenerate all rows in a fresh isolated
  benchmark root and retain no partial row as evidence. This changes only the
  collector and does not alter Runtime diagnostics or Cache authority.
- Resolution evidence: the accepted `cache-v77-real4` run completed all 61
  launches and emitted `56/56` rows with exit 0. Summary mode correctly records
  nullable lifecycle timing; Verbose records 93 trace events and a finite flush
  timing. Accepted evidence is copied under `benchmarks/cache-v77-real4-*`.

## IC-501 — one-module report was scalarized before aggregate collection

- Severity/state: V7.7 evidence-tool bug / fixed and complete benchmark GREEN on
  2026-08-12.
- Exact boundary/evidence: `cache-v77-real3` passed the IC-500 frontier and
  completed multiple real packaged launches, Store publications, schema-4
  reports and Python dumps. It then failed from
  `Invoke-BenchmarkLaunch` while collecting `globalCount`: PowerShell unrolled
  `$modules = if (...) { @(...) }` into a single `PSCustomObject` for the
  one-module package fixture, and strict-mode access to `$modules.Count` failed.
  The Runtime launch and cache validation were successful; the partial rows are
  not accepted as benchmark evidence.
- Decision: initialize `$modules` as an explicit empty array and assign
  `@($report.current.modules)` in a separate statement. This preserves array
  shape for zero, one and many modules and matches the earlier optional-trace
  correction. The remaining collector uses explicit arrays at every `.Count`
  boundary.
- Required evidence/task impact: rerun the complete 56-row/61-launch benchmark
  in a new isolated cache/output root, retain only the complete result, and add
  its raw/summary/context artifacts under `benchmarks/`. This is an evidence
  collector correction only; Cache Runtime bytes and publication semantics are
  unchanged.
- Resolution evidence: `cache-v77-real4` completed `61/61` package processes and
  `56/56` recorded rows without scalarization. It contains 14 groups with one
  warmup and three measured rows each; result, context, plan, raw and summary
  files are preserved under `benchmarks/`.

## IC-502 — Windows checkout rewrote strict Standalone wire fixtures to CRLF

- Severity/state: final parallel-All baseline failure outside Cache Runtime /
  fixed with focused Standalone `19/19` on 2026-08-12; final parallel-All rerun
  pending.
- Exact boundary/evidence: the official parallel All result at `Saved/Tests/
  cache-v56-schema4-all-parallel1_20260811_230523` scheduled 37 shards and every
  UE Automation shard passed. Its Standalone shard passed `14/19` and five CTests
  failed from the same `manifest must use LF line endings` contract at
  `Saved/StandaloneTests/cache-v56-schema4-all-parallel1_02_Standalone/
  20260811_230524_813_e4c6ee41`. The tracked offline producer fixtures contained
  CRLF in the worktree. System Git config has `core.autocrlf=true`, while the
  plugin had no `.gitattributes` rule for these strict wire inputs.
- Decision: add a narrow plugin `.gitattributes` rule forcing LF for only
  `Standalone/Tests/Fixtures/OfflineContract/**/*.json` and `*.jsonl`, and
  normalize the four non-empty frozen fixture files. Do not weaken the parser's
  canonical LF contract and do not globally change developer Git settings or
  unrelated source line endings. Post-edit byte inspection reports zero CRLF;
  both `symbols.jsonl` remain exactly 991 bytes with their manifest-declared
  SHA-256 `20a1fc62...8d1`.
- Required evidence/task impact: run the official `Standalone` suite and then
  the final parallel `All` suite. This closes the one known non-Cache shard
  failure needed for an actually green full-suite claim; it changes no Cache
  code, format, or package result.
- Focused GREEN: official `Tools\RunTestSuite.ps1 -Suite Standalone` passed all
  `19/19`, process/final `0/0`, at `Saved/StandaloneTests/
  cache-v77-standalone-lf-green1_01_Standalone/
  20260812_012428_389_852180ab`. All five CTests that previously stopped at the
  manifest line-ending check now pass. Final CoarseDynamic All remains the broad
  regression gate.

## IC-503 — tiny package benchmark does not show a warm-start or parallel speedup

- Severity/state: V7.7 performance observation, not a correctness failure /
  measured and documented on 2026-08-12; representative-corpus tuning deferred.
- Exact evidence: accepted `cache-v77-real4` uses 38 staged loose sources and a
  32,691-byte single Pack. Cold median is `11093 ms`; unchanged warm median is
  `14055 ms` (+26.7%). The warm schema-4 report consistently records eight
  candidate modules, 18 restored functions, four compiled misses, four typed
  NotCacheable functions and zero corrupt rejections. At 4/16/64 MiB, parallel
  process medians are respectively +0.40%, +1.45% and +0.60% versus serial.
- Interpretation/decision: this fixture is a correctness and determinism matrix,
  not a representative startup-performance corpus. Hybrid reuse still pays
  source/declaration validation and unsupported-family compile cost; one tiny
  Pack cannot amortize worker scheduling. Keep the accepted requirement of no
  machine-time threshold and do not claim a speedup. Retain the conservative
  64 MiB/four-worker production default because the 17 MiB C++ test proves real
  grouping/parallel work, but require larger-project measurements and stage
  timings before adding a small-work serial heuristic or retuning defaults.
- Task impact: V7.7 may close on semantic parity, integrity, diagnostics and
  complete evidence; startup performance optimization is explicitly not
  declared complete by these rows. The limitation and exact figures are in
  `benchmarks/cache-v77-real4-analysis.md` and both user guides.

## IC-504 — Debugger test port allocator collided during four-slot parallel All

- Severity/state: final parallel-All infrastructure failure outside Cache
  Runtime / fixed and final parallel-All GREEN on 2026-08-12.
- Exact boundary/evidence: the current official four-slot CoarseDynamic run
  `cache-v77-final-all-parallel1` completed the Debugger shard `37/38`; only
  `Angelscript.TestModule.Debugger.Smoke.FAngelscriptDebuggerSmokeTests.
  BreakFiltersRoundtrip` failed at `Saved/Tests/
  cache-v77-final-all-parallel1_29_Debugger/
  20260812_014650_316_45d57925`. Its setup selected port `36820`,
  `FTcpSocketBuilder` reported `Failed to create the socket FTcpListener server
  as configured`, yet the DebugServer constructor logged the requested endpoint
  as listening. The client then waited the full 45-second test timeout for a
  `DebugServerVersion` response. The immediately following handshake test bound
  `36821` and passed. Nine other completed UE shards and Standalone were green
  when this failure was discovered.
- Root cause/decision: the test-only allocator gives every process only a
  100-port bucket selected by `ProcessId % 100`; concurrent editor processes can
  therefore select the same bucket, and session initialization does not reject
  an inactive listener. Make listener readiness observable, fail fast on an
  explicit occupied port and make automatic test-session allocation retry a
  fresh candidate instead of returning a nominally initialized dead server.
  Preserve the normal Runtime configured-port contract; this correction is for
  deterministic parallel test infrastructure, not Cache format or authority.
- Required evidence/task impact: add a focused occupied-port regression, build
  the affected Runtime/Test modules, rerun the focused test and complete
  Debugger prefix, then rerun the official four-slot parallel `All`. Keep V7.7
  unchecked until the replacement aggregate is wholly green. The first test
  build at `Saved/Build/cache-v77-debugger-port-red-build1/
  20260812_015953_780_9369107f` stopped before behavior execution because UE
  5.8 `FSocket::GetAddress` returns `void`; the fixture now calls it separately
  and validates the resulting concrete port. That compile-only fixture error is
  retained here and is not accepted as the intended behavior RED. The corrected
  behavior RED is `Saved/Tests/cache-v77-debugger-port-behavior-red1/
  20260812_020048_192_053ad164` (`0/1`): the occupied listener was logged, but
  `Initialize` incorrectly returned true. After the Runtime/session correction,
  `cache-v77-debugger-port-focused-green1` reached the desired false return but
  remained red solely because the first diagnostic severity was Error. Final
  semantics retain the diagnostic as a Warning, with no expected-error masking,
  so a transient failed automatic candidate does not poison an otherwise
  successful retry.
- Resolution evidence: `FAngelscriptDebugServer::IsListening()` now exposes the
  actual listener state and no longer logs a requested endpoint as successfully
  listening when socket creation failed. Explicit occupied ports fail Session
  initialization immediately; automatic allocation retries at most 32 fresh
  candidates. Final build is GREEN at `Saved/Build/
  cache-v77-debugger-port-final-build1/
  20260812_020443_761_ba77f60e`; the independent occupied-port test is `1/1` at
  `Saved/Tests/cache-v77-debugger-port-final-focused1/
  20260812_020501_182_e7d7928f`, and the complete Debugger prefix is `39/39` at
  `Saved/Tests/cache-v77-debugger-port-complete-green1/
  20260812_020539_162_80ecede7`. The second All then hit two real candidate
  collisions and recovered to Debugger `39/39`; the authoritative third All
  passed all 37 tasks and `2971/2971` tests at `Saved/Tests/
  cache-v77-final-all-parallel3_20260812_022730`.

## IC-505 — parallel editors raced on the shared AssetRegistry cache writer

- Severity/state: second final parallel-All infrastructure failure outside
  Cache Runtime / fixed and final parallel-All GREEN on 2026-08-12.
- Exact boundary/evidence: `cache-v77-final-all-parallel2` reached 24 completed UE
  shards with `2309/2310` before the only failure was identified as Compiler
  `RuntimeCompileFailureReportsBuilderDiagnostics` at `Saved/Tests/
  cache-v77-final-all-parallel2_08_Compiler/
  20260812_022028_923_d6ad6418`. The test's own compile-failure diagnostics
  completed, but UE concurrently tried to rename the shared project file
  `Intermediate/CachedAssetRegistry/CachedAssetRegistry_0.ref.tmp` and emitted a
  `LogFileManager` Error (OS error 2). The failure is unrelated to AS compilation
  assertions and can land on whichever test is active during the shared write.
- Root cause/decision: `ExecutionSlot` isolates wrapper locks and test output but
  all four Editor processes still write the same UE AssetRegistry cache root.
  Forward UE's supported `-NoAssetRegistryCacheWrite` switch to every parallel
  UnrealAutomation shard. Parallel workers may read the preexisting cache but
  cannot race on publication; typed non-Unreal entries remain unchanged.
- Required evidence/task impact: add a dry-run self-test proving the switch is
  forwarded, obtain RED before changing the runner, pass the runner self-tests,
  rerun the complete Compiler prefix, and run a fresh four-slot parallel All.
  Keep the current aggregate as failure evidence and V7.7 unchecked.
- Resolution evidence: `RunTestSuiteParallelSelfTests.ps1` first failed its new
  `ParallelUnrealShardsDisableSharedAssetRegistryCacheWrites` assertion, then all
  three self-tests passed after the runner appended
  `-ExtraArgs -NoAssetRegistryCacheWrite` only to UnrealAutomation commands and
  only after all wrapper-owned parameters. The exact flag is visible in the
  focused process command line; complete Compiler passed `81/81` at
  `Saved/Tests/cache-v77-asset-registry-compiler-green1/
  20260812_022610_572_0c09cec9`. The authoritative third All then passed
  Compiler `81/81` and aggregate `2971/2971`; every UE shard carried the switch
  and the aggregate logs contain zero `CachedAssetRegistry` move errors at
  `Saved/Tests/cache-v77-final-all-parallel3_20260812_022730`.

## IC-506 — main integration exposed bind-state API drift and a Unity include leak

- Severity/state: final dual-repository integration failure / fixed by plugin
  main merge `c52af6c` plus explicit-include follow-up `02d05ab` on 2026-08-12;
  merged-parent acceptance remains covered by the final build and parallel
  `All` rerun.
- Exact boundary/evidence: merging plugin change commit `a66b7af` into the newer
  plugin `main` produced content conflicts in `Bind_FName.cpp`,
  `AngelscriptEngine.cpp/.h`, `AngelscriptOfflineSymbolMetadata.cpp`,
  `StaticJITBinds.cpp` and `GlobalContainerCycleBoundedTests.cpp`. The first
  merged build, `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs
  1800000`, failed at `Saved/Build/build/
  20260812_030904_512_e7c20c22`: `AngelscriptSubsystem.cpp` used
  `FAngelscriptBind::PrepareForEngineInitialization` without directly including
  `AngelscriptBinds.h` (`C2653`/`C3861`).
- Root cause/decision: main had moved BindDatabase, documentation and StaticJIT
  NativeForm ownership onto each Engine while the Cache branch renamed the
  legacy precompiled-data switch to the narrower
  `bCollectStaticJITCompatibilityBinds`. The resolution keeps main's per-Engine
  ownership and direct-bind architecture, routes all NativeForm collection
  through the new compatibility switch, and keeps Cache V2 stable-name
  resolution. The Subsystem compile error was a pre-existing direct-include
  omission hidden by prior Unity grouping; the Cache translation units changed
  that grouping and exposed it. Do not restore the removed global NativeForm
  table or the broad legacy `bGeneratePrecompiledData` field.
- Resolution evidence/task impact: main's newly added DirectBind and StaticJIT
  tests now set `bCollectStaticJITCompatibilityBinds`; the Subsystem explicitly
  includes `AngelscriptBinds.h`. The identical build command then passed at
  `Saved/Build/build/20260812_031118_567_8b196316`. The plugin merge commit is
  `c52af6c7973c9485370289a17a6de2d48565d896`; the verified include correction
  is `02d05ab6e4aad0e5b3b384f2cc9252be732f145f`. Final parent-main build and
  tiered-parallel `All` remain the acceptance evidence for the combined tree.

## IC-507 — newer main renamed the explicit bind phase and changed an UE 5.8 value-type return

- Severity/state: merged-main test-contract drift outside Cache Runtime / source
  expectations corrected and final aggregate GREEN on 2026-08-12.
- Exact boundary/evidence: the first authoritative run against merged parent
  `main`, `Saved/Tests/cache-v2-merged-main-all_20260812_031708/
  ParallelSuiteSummary.json`, completed all 37 shards but reported `3047/3058`
  with eleven failures. GAS, GameplayTags and Dump still expected semantic bind
  phase `ManualBindings`, while newer production commits publish
  `ExplicitBindings`. `AngelscriptValueTypeParityBindingsTests` also expected
  `FMatrix::TransformPosition` to return `FVector`, but the UE 5.8 production
  surface and the existing Matrix binding test correctly expose `FVector4`.
- Decision: update only the stale architecture/value-shape assertions; do not
  add compatibility aliases for the obsolete phase name and do not change the
  production matrix binding to satisfy an outdated fixture. This project is in
  plugin development and the change explicitly does not require old-cache or
  old-test compatibility.
- Resolution evidence/task impact: the combined tree passed Dump `13/13` at
  `Saved/Tests/
  cache-v2-repair-dump/20260812_035158_850_79d1c90f` and Bindings `281/281` at
  `Saved/Tests/cache-v2-repair-bindings/20260812_034742_899_c144f584`. The exact
  GAS correction passed `1/1` at `Saved/Tests/cache-v2-repair-gas-exact1/
  20260812_035739_032_7d6b697e`; GameplayTags passed `1/1` at `Saved/Tests/
  cache-v2-repair-gameplay-tags-exact1/20260812_035817_114_ad00efed`.
  The replacement All then passed GAS `252/252`, GameplayTags `15/15`, Dump
  `13/13`, Bindings `281/281` and aggregate `3090/3090` at `Saved/Tests/
  cache-v2-merged-main-all-final_20260812_040301`.

## IC-508 — newer binding refactors hid exact-engine support and valid overloads

- Severity/state: merged-main Runtime integration regressions outside the Cache
  record/store implementation / fixed with focused and final aggregate GREEN on
  2026-08-12.
- Exact boundary/evidence: the same merged-main aggregate exposed three Engine,
  two FunctionLibraries and two Functional failures. Newer main had accidentally
  stopped using the supplied Engine/TypeDatabase in `Helper_FunctionSignature`,
  treated any same-name reflected function as already bound, omitted the simple
  `USceneComponent::SetRelativeRotation(FRotator)` supplement, and only generated
  the legacy location/rotation static Spawn helper for script-defined Actor
  classes. These failures were not reproducible on the isolated Cache branch;
  they arise from integrating Cache V2's explicit per-Engine ownership with
  later main binding work.
- Decision: preserve exact target Engine/TypeDatabase authority; compare complete
  semantic callable shape before suppressing a duplicate; apply reflected
  metadata to an exact pre-existing manual/native declaration; restore the
  simple SceneComponent overload; and generate a second typed Actor Spawn helper
  forwarding the complete `FTransform + FActorSpawnParameters` contract. Do not
  reintroduce global type state or same-name-only suppression.
- Resolution evidence/task impact: the unified official repair build passed all
  `116/116` actions at `Saved/Build/cache-v2-merged-main-repair-build1/
  20260812_034354_530_7f55048e`. Engine passed `130/130` at `Saved/Tests/
  cache-v2-repair-engine/20260812_034742_899_52d1df5f`; Bindings passed
  `281/281`. The first repair reduced Functional from two failures to one and
  logged result code `30`, proving the remaining assertion read location before
  deferred construction completed on a rootless fixture. The corrected fixture
  declares a root component, finishes with the explicit transform, retains the
  permanent stage-code log and passed `1/1` with result code `1` at `Saved/Tests/
  cache-v2-repair-functional-exact3/20260812_035911_801_c5ae875a`.
  FunctionLibraries' second direct-native duplicate path now decorates the exact
  existing function and passed `1/1` at `Saved/Tests/
  cache-v2-repair-function-libraries-exact2/20260812_035508_032_8f56420f`.
  Final incremental build passed at `Saved/Build/
  cache-v2-merged-main-repair-build3/20260812_035852_178_05cdb786`; the
  replacement All passed Engine `130/130`, Functional `128/128`,
  FunctionLibraries `56/56`, Bindings `281/281` and aggregate `3090/3090`.

## IC-509 — StaticJIT AOT fixture cache predates the merged binding surface

- Severity/state: generated-artifact compatibility failure, not a Cache V2
  corruption / regenerated and GREEN on 2026-08-12.
- Exact boundary/evidence: the merged-main StaticJIT shard terminated in
  `FAngelscriptPrecompiledData` while resolving a null stored function reference.
  The ignored local `StaticJITAotFixture.Cache` was generated on 2026-07-27,
  before the newer main binding surface, while the tracked generated JIT header
  reflects newer source. The project documents the cache and generated source as
  one matched pair.
- Decision: do not weaken the precompiled-data assertion or add fallback lookup
  for a known mismatched test artifact. Run `Tools\RunStaticJITTests.ps1`, whose
  supported sequence rebuilds the baseline, regenerates AOT data, rebuilds the
  generated target and executes the complete StaticJIT prefix. Commit only
  genuine tracked regenerated source; the local `.Cache` remains ignored.
- Resolution evidence/task impact: `Tools\RunStaticJITTests.ps1 -LabelPrefix
  cache-v2-repair-staticjit` passed baseline build, generation commandlet and
  generated build with exit 0 at `Saved/Build/
  cache-v2-repair-staticjit_01_baseline_build`, `Saved/StaticJIT/Preflight/
  Commandlet/cache-v2-repair-staticjit_02_generate` and `Saved/Build/
  cache-v2-repair-staticjit_03_generated_build`. Its complete prefix passed
  `32/32` at `Saved/Tests/cache-v2-repair-staticjit_04_tests/
  20260812_040043_325_26d3a9dc`. The tracked generated JIT header changed only
  regenerated references/property verification identity and is committed with
  the repair. Final All independently passed StaticJIT `32/32` and aggregate
  `3090/3090`.

## IC-510 — ordinary focused-test wrappers intentionally serialize a worktree

- Severity/state: validation-orchestration observation / handled by using the
  supported parallel suite entry point.
- Exact boundary/evidence: after the first focused processes had been launched
  simultaneously, later `RunTests.ps1` invocations for GAS and GameplayTags
  returned `[error] Another build or test command is already running for this
  worktree.` The ordinary wrapper owns a worktree mutex; simultaneous success
  from a start-time race is not a supported scheduling contract.
- Decision: do not bypass the mutex. Use `RunTestSuiteParallel.ps1` for official
  parallel full-suite execution because it owns session-slot and shard
  orchestration; use ordinary focused wrappers sequentially when a custom prefix
  is not represented as a suite shard. Continue forwarding
  `-NoAssetRegistryCacheWrite` through the supported parallel runner.
- Resolution evidence/task impact: supported sequential focused runs passed GAS
  and GameplayTags `1/1` each. The official parallel runner then scheduled all
  37 tasks over four slots, dynamically refilled each slot, passed GAS
  `252/252`, GameplayTags `15/15` and aggregate `3090/3090`. The opportunistic
  focused launch is retained only as the discovery record, not acceptance.

The next issue ID is IC-511. Append an issue here when it affects current work;
also preserve discovery order even when fixed in the same session. Each issue must
record severity/state, exact boundary, decision, required evidence and task impact.
Build/test/PIE/package failures include the wrapper command, label, artifact path,
configuration, baseline reproducibility and resolution. Store faults also record
the injected stage and committed pointer state; performance issues link raw rows
under `benchmarks/`.
