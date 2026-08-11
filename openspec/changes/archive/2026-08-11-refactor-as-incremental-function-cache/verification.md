# Current Verification Ledger

This is a concise index of accepted evidence and open frontiers. It does not turn
compile success into behavior success. The full historical log is preserved at
`history/pre-refactor-2026-08-09/verification.md` with SHA-256
`5C5F47A837C4F7A8438A4F09B3142B71EB356FCCACCCEA3327465858E4B7F2FB`.

## Evidence levels

| Level | What it proves | What it does not prove |
|---|---|---|
| Exact SHA/shape | The reviewed bytes/candidate are identifiable. | Compilation or behavior. |
| SingleFile complete-TU compile | C++ syntax, includes and declarations for that TU. | Link, Automation, production-path behavior. |
| Module build/link | Required symbols and module linkage exist. | The named semantic behavior. |
| Focused Automation | The named tests executed and passed. | Unrelated integration or real environment behavior. |
| Integration prefix | Real upstream/downstream production paths work in the test host. | PIE or packaged process lifecycle. |
| Real PIE/package acceptance | The named Editor or executable sessions work. | Scenarios/configurations not run. |

An assertion/crash, missing unrelated header, unresolved symbol or build-tool
failure is not behavioral RED. A reviewed SHA that is edited becomes a new,
unreviewed candidate.

## Accepted/frozen evidence index

| Boundary | Evidence state | Current authority |
|---|---|---|
| Stable identities/profiles | Behavior GREEN baseline | `identity-golden-vectors.md`, A1–A2 and archived full log. |
| Record envelope/common archive | Behavior GREEN baseline | `archive-format-vectors.md`, `record-wire-v1.md`, A3–A4 and archived full log. |
| TypeSchema representative RED | Approved exact B1 candidate | SHA `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`; 467,181 bytes, 10,678 LF, 55 methods, final LF; fresh TU compile and independent 0C/0I/0M review. |
| Remaining record coordinates/C++ shape | Approved RED/complete-TU compile | Test SHA `77C56BC6D8264A7BC93EF4BF7830CDBE36BCB383CC6ECF8C7339F23E0655CEE0`; declaration SHA `31ADE29770453A4E6AA5029176C5A9F4BF028919798CDAFE737EC2467AEA9E1C`. |
| Candidate Budget | Approved exact source boundary | See archived tasks 2.5a.1 and full verification details. |
| Canonical retained allocator | Approved exact source boundary | See archived tasks 2.5a.2; candidate binding/behavior remains B4/B10. |
| Manifest/Pack wire and RED | Frozen plus independent 0C/0I/0M | Test `E763DD3285BD257CBBC7F9E08EE9B3C33893F8C3FFC732DBACF984FD680EB92E`, wire `E36722A99A05D2AE2C4452F01016E6FD6243A8EDCAD34C232A36F182C37E1779`, authority `913DF562A0958DC3BE60DDA258571A8A06114CD7403DB48AA92855CC9847B7E0`. |

## Paused compile frontiers

These paths are evidence artifacts, not task completions.

| Label/path | Result | Exact interpretation |
|---|---|---|
| `Saved/Build/ic138-producer-red-test-tu/20260809_000333_595_2349ae33/` | SingleFile compile exit 0 | The paused TypeSchema test TU compiles; its current exact SHA still requires B1 freeze/review. |
| `Saved/Build/ic138-producer-red-link/20260809_000350_244_1ad1e48d/` | Full link exit 1 | Automation was not reached: Manifest header is absent and `FDecodedRecordCodecBridge::TryDecodeTypeSchema` is unresolved. |
| `Saved/Build/cache-decoded-factory-observer-tu15/20260808_235612_351_d4f02462/` | SingleFile compile exit 0 | Factory nested-observer repair compiles only. |
| `Saved/Build/cache-canonical-observer-compat-tu/20260808_235625_855_c63efc7a/` | SingleFile compile exit 0 | Supporting semantic-record observer compatibility compiles only. |
| `Saved/Build/cache-decoded-declaration-after-probe-tu/20260809_000135_208_ec3cd562/` | SingleFile compile frontier | Decoded declaration/probe surface compiles; no factory behavior is inferred. |
| `Saved/Build/cache-source-interface-after-probe-tu/20260809_000143_342_214681fb/` | SingleFile compile frontier | Source-interface consumer declaration compiles; unified migration is still B8. |
| `Saved/Build/cache-manifest-pack-repaired-red-tu/20260808_234148_544_45e29957/` | Intended missing-header RED | Only `Cache/AngelscriptCacheManifestPack.h` is absent at the approved declaration boundary; no production GREEN is claimed. |

The first full-link row is also the concrete IC-145 evidence-order boundary:
process exit 6 / wrapper exit 1 after 52,238 ms, with a C1083 on the C2-owned
Manifest header and an LNK2019/LNK1120 on the B5–B7-owned private TypeSchema bridge.
B3 source/TU compilation may proceed, but focused producer Automation is deferred
until both real prerequisites link; no placeholder, test gate or stale executable
may convert this infrastructure failure into semantic evidence.

## B1 TypeSchema RED candidate audit — 2026-08-09

### Environment and command correction

- The worktree project is associated with Unreal Engine `5.8`; `AgentConfig.ini`
  resolves `EngineRoot` to `C:\Program Files\Epic Games\UE_5.8`, and that
  installation reports UE `5.8.0`, changelist `55116800`. The stale UE 5.7 label
  in the first B1 packet was corrected before compiling; this is IC-142 and does
  not change Cache V2 behavior or authorize a repository-wide version rewrite.
- The first nested `powershell.exe -File ... -- -SingleFile=...` spelling exited
  before UBT because Windows PowerShell treated the bare `--` as an empty wrapper
  parameter name. It created no UBT artifact and is not RED evidence. B1 now calls
  the project wrapper in the current shell with its explicit `-ExtraArgs` array;
  this command-boundary correction is IC-143.

### Fresh complete-TU compile

```powershell
$TypeSchemaTestTu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp').Path
& .\Tools\RunBuild.ps1 -Label cache-b1-typeschema-red-tu `
  -TimeoutMs 1800000 -NoXGE `
  -ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

- Artifact:
  `Saved/Build/cache-b1-typeschema-red-tu/20260809_010843_164_0d3abd53/`.
- Wrapper/process exit `0`; duration `10059` ms; target
  `AngelscriptProjectEditor Win64 Development`; UE 5.8; `-NoEngineChanges` and
  `-NoXGE` active.
- `Build.log` contains exactly one build action:
  `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp`, followed by
  `Result: Succeeded`. This is complete-TU compile evidence only; it is not link
  or behavioral GREEN.
- `RunMetadata.json` records the exact absolute `-SingleFile` path and
  `-NoHotReloadFromIDE`; no intended UBT argument was lost at the wrapper boundary.
- The candidate remained byte-identical after compilation: SHA-256
  `A6EE78A19AC83A6F93AB86AD2072BF7E0758C0B699436D46D396DCAEB19CE66A`,
  `466853` bytes, `10671` LF, zero CRLF, `55` `TEST_METHOD` declarations and a
  final LF.

### IC-139 independent literal recomputation

A separate read-only reviewer independently rebuilt both canonical byte streams
from the frozen authority and computed BLAKE3 without calling project hash helpers,
Unreal `FBlake3`, `ComputeLayoutInputHash` or `ComputeEnumAuthorityHash`. The local
BLAKE3 implementation first matched the public empty-input and `abc` vectors.
The reviewed candidate SHA was identical at the beginning and end.

| Domain/vector | Canonical bytes | Frozen/independent digest | Result |
|---|---:|---|---|
| Layout baseline, alignment `8` | 124 | `19903c25b6a2d207614125561a1285221a021062c8219ba41c85a84b89abd04c` | PASS |
| Layout mutation, alignment `16` | 124 | `c36d242e8b167abedfad69a23577d0651e9e0edab2118d95dcccd448b67a9ac7` | PASS |
| Enum baseline, `Ready=MAX_int32` | 194 | `bc379827084ce82a8635f56600fae4de208534bf92a6d229ab0fa3688fce58e1` | PASS |
| Enum mutation, `Ready=MIN_int32` | 194 | `ef456bfeaf07d858e493bd128c2f90534a225bf716854b62113ff14d3d5053ad` | PASS |

The Layout streams differ only in the `AlignmentContribution` field. The Enum
streams differ only in the signed `Ready.Value` field. Domain separation,
field/optional ordering, signed-int32 bit preservation and metadata placement all
matched the frozen authority. The reviewer noted only a future non-blocking
coverage opportunity: each non-empty metadata array in these vectors contains one
entry, so a separate reverse-input-order multi-entry vector would strengthen the
metadata-sort regression without changing IC-139's PASS result.

The whole-file IC-138/IC-139 semantic review remains open below this evidence; the
literal recomputation alone cannot approve B1 or close IC-138.

### First whole-file review and IC-144 amendment

The exact `A6EE78A1...` whole-file review is retained at
`reviews/b1-typeschema-red-review-A6EE78A1.md`, SHA-256
`53BE748441E3F836826F1C4884A9DD6A8587C714298D34FC014091C5CBA74BCE`.
It returned **NEEDS FIXES — 0 Critical / 1 Important / 0 Minor**. The accepted
parts were the four independently recomputed IC-139 literals, real producer entry,
exact result tuple, sentinel clearing, physical before/after immutable-input proof,
resolver independence, independent raw offset scanner and frozen diagnostic/
precedence structure.

The Important finding was precise: the normal-producer method had two
`UnknownEnumValue` cases but no `UnknownFlags` producer case; all unknown high-bit
fixtures went through the hostile physical writer and decoder. Because IC-138
explicitly requires producer results spanning unknown enum/flag, B1 could not
freeze that predecessor SHA. This is IC-144, not a waiver into B2: B1 needs one
representative while B2 still owns exhaustive canonical-local coverage.

The candidate was amended only by adding a valid Class baseline with
`TypeSemanticFlags |= 0x100u`, recomputing its derived hashes and passing it to the
real producer helper with expected `UnknownFlags`. No Runtime, frozen authority,
test-local semantic validator or test-local wire/hash oracle was added.

Fresh amended complete-TU evidence:

- Candidate SHA-256:
  `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`;
  467,181 bytes, 10,678 LF, zero CRLF, 55 `TEST_METHOD` declarations and final LF.
- Artifact:
  `Saved/Build/cache-b1-typeschema-red-tu-rereview/20260809_012321_011_77e2f449/`.
- Wrapper/process exit `0`, duration `9837` ms; UE 5.8, Win64 Development,
  `-NoEngineChanges`, `-NoXGE`, exact absolute `-SingleFile` and
  `-NoHotReloadFromIDE` recorded in `RunMetadata.json`.
- `Build.log`: exactly `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp`,
  `Result: Succeeded`.

At that point this was complete-TU compile evidence only; approval remained open
until the fresh exact-SHA result recorded immediately below.

### B1 final close evidence

- Final fresh compile artifact:
  `Saved/Build/cache-b1-typeschema-red-tu-final/20260809_013727_047_f66a7ff2/`.
  Wrapper/process exit `0`, duration `9799` ms, exactly one
  `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp`, and
  `Result: Succeeded`. `RunMetadata.json` records the exact worktree candidate,
  UE 5.8, Win64 Development, `-NoEngineChanges`, `-NoXGE`,
  `-NoHotReloadFromIDE` and no timeout.
- Post-compile candidate identity: SHA-256
  `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`,
  467,181 bytes, 10,678 LF, zero CR/CRLF, 55 `TEST_METHOD` declarations and final
  LF.
- Final exact-SHA report:
  `reviews/b1-typeschema-red-review-183B7AF5.md`, SHA-256
  `09EAAB56B73EDA7A85F0631EB5E0C8DE5479E7F49F2BFAEFA72B3E910D63DBD2`;
  verdict **APPROVE — 0 Critical / 0 Important / 0 Minor**. It re-read the complete
  candidate, reconstructed the predecessor by removing only the seven-line IC-144
  amendment, independently recomputed all four IC-139 literals, and rechecked the
  production source plus four frozen authorities at their unchanged SHAs.
- Strict OpenSpec validation after the close evidence: valid, exit zero.
- Controlled workspace inventory: excluding this OpenSpec directory and the parent
  submodule gitlink, the parent plus plugin still expose 46 changed/untracked file
  rows. `workspace-source-manifest-b1.txt` freezes status, logical path, byte size
  and SHA-256 for every row; file SHA-256
  `209EDFF7C2CBFFF8E33D485A30DE2F411D9376C0FE46BE1E0E74291E6919349C`,
  6,929 bytes, normalized 46-row body SHA-256
  `6AC6473E6D8A1128CD68B68523F3D0CC4F805883D42D02EBD091215B694A1B19`.
  The independent B1 report proves that deleting only the seven-line, 328-byte
  IC-144 amendment reconstructs predecessor candidate SHA `A6EE78A1...`; this
  explicit manifest becomes the repeatable baseline for subsequent B2 source
  deltas.
- Focused Automation: deliberately not claimed by B1. IC-145 records the real
  missing-header/unresolved-bridge link prerequisites; B2/B3 behavior evidence may
  not substitute that infrastructure failure for returned semantic RED/GREEN.

B1 is therefore Approved RED at the exact evidence level above. It proves the
representative producer contract and literal authority, not exhaustive B2 producer
coverage, production-validator GREEN, decoder/factory behavior or full module link.

### B1 ledger and workspace revalidation

- `openspec status --change refactor-as-incremental-function-cache --json`:
  schema `spec-driven`, 4/4 artifacts done.
- `openspec validate refactor-as-incremental-function-cache --strict`: valid, exit
  zero after B1 close and B2 packet materialization.
- Current checklist structure: 60 task IDs, 60 unique, zero duplicate groups;
  9 completed including B1. This is a mechanical ledger fact, not overall feature
  completion.
- Non-history Markdown scan: 39 files, zero broken relative Markdown links.
- Parent and plugin `git diff --check`: exit zero. Git printed existing line-ending
  conversion warnings for unrelated tracked files; no whitespace error was
  reported.
- Focused touched-file scan: 12 source/current-record/review files, zero unexpected
  trailing whitespace and zero missing final LF. Four two-space Markdown hard
  breaks at the date/review-mode lines of the two immutable review reports are
  intentional and included in their reviewed report SHAs.
- Fresh regeneration of the 46 source rows in `(Scope, Path)` order is byte-for-
  byte equal to `workspace-source-manifest-b1.txt`; zero row or order differences,
  normalized body SHA-256
  `6AC6473E6D8A1128CD68B68523F3D0CC4F805883D42D02EBD091215B694A1B19`.

## B2 Slice 1 normal-producer authority — 2026-08-09

### Scope and evidence ceiling

Slice 1 added only the narrow normal-success/immutable-input helper and the first
two of B2's eleven scenario methods:

- `NormalProducerCanonicalizesEverySetLikeFieldWithoutMutatingInput`; and
- `NormalProducerRejectsHeaderStringsAndTypeFlagRulesAtomically`.

The complete immutable source comparison is plugin Git blob
`8e7088c158da1514bec3a5d5eb12f918cca2f131` (approved B1) to
`a3d759ef3b95429f4837ab991763ffc58083836f` (approved Slice-1 fix-2). No Runtime,
decoder, physical writer, other test, registration or API file belongs to that
blob range. B2 remains unchecked: the evidence below is exact test authority and
complete-TU compilation, not an executed focused RED. IC-145 still prevents a
truthful module link until the real B5–B7 private decoder bridge and C2 Manifest
declaration land.

### Candidate and review chronology

| Boundary | Candidate SHA-256 / blob | Compile artifact | Independent result |
|---|---|---|---|
| Initial Slice 1 | `069D4B7B11110E4C2A9A7FBC2A74CF3CECCF55C0E271AC4046C4DCDC22E1C738` / `d956ecae61097cf811aae84cf6f509c2c8b26ffd` | `Saved/Build/cache-b2-typeschema-producer-red-slice1-tu/20260809_020019_093_8bb87627` | NOT APPROVED, 0C/2I/0M: self-confirming direct-interface expected payload and duplicate B1 Class witnesses. Report SHA-256 `1F823A12C2BD4FC9948B0F0973FEC8D6769296AEF97CE4A20D066FA992D3620D`. |
| Fix 1 | `D4F022FA56C012DB325A0F1E11C84ACD5ED9FF4BD10B1BABD5E493CC0F972D15` / `f029d9930dd39e6c4ca3a7b23ba5c2ee88c75019` | `Saved/Build/cache-b2-typeschema-producer-red-slice1-fix1-tu/20260809_020948_398_82c4ab8f` | NOT APPROVED, 0C/1I/0M: duplicate rows closed, but reversed full-payload inequality remained contaminated by differing stored TypeLayoutHash values. Report SHA-256 `E3C5CAB4C1FA8047AB694ABEE030D61A8FBFB8EC68F97BA834BDBF534A325977`. |
| Fix 2, final | `3A16BF271B718B80E1AFF401B549D89DC7CF64391DD5BE7A7F5724F18946C942` / `a3d759ef3b95429f4837ab991763ffc58083836f` | `Saved/Build/cache-b2-typeschema-producer-red-slice1-fix2-tu/20260809_022947_475_6f860f1a` | APPROVED, 0C/0I/0M. Report SHA-256 `BDBC0B91B17F0A46D8D17E634B6AFC431DE2F9700AF608C2FB9E49EE26E4458D`. |

Every artifact records UE 5.8, the absolute candidate `-SingleFile`,
`-NoHotReloadFromIDE`, `-NoXGE`, no timeout, wrapper/process exit zero, exactly one
`[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp` action, `Result:
Succeeded` and no compiler diagnostics. Durations were respectively `9843`,
`10087` and `9596` ms. These are complete-TU compile checks only.

The final file has `501923` bytes, `11367` LF, zero CRLF/bare CR, `57`
`TEST_METHOD` declarations and a final LF. Candidate SHA at the beginning and end
of the final review was identical. `git diff --check` exits zero for both the
complete B1-to-fix2 range and the fix1-to-fix2 repair range.

### Direct-interface authority and closed findings

The final asymmetric valid Interface fixture stores ordinal `0 -> f2/f3` and
ordinal `1 -> e2/e3`, while dependencies use the frozen canonical comparator.
Normal serialization plus independently frozen stored TypeLayoutHash
`dd58ac98186a58c34b2decc1d15c7842f5c4e61e512515d205caba9c63e04dfd`
proves that copy/canonicalize/validate does not target-sort the direct-interface
subsection before validation. The exact produced payload must then have `479`
bytes and common TypeSchema RecordId ContentHash
`1048a8e8b3e5833e6e600776e93f319fde7281879e8a4ae0bde5ec39effc080d`,
which commits final writer output and catches writer-only reordering.

The literal authority is preserved at
`reviews/b2-slice1-direct-interface-golden-recomputation.md`, SHA-256
`C7C28D74D8204E8AB371022A5615A955FB3D3508CB34B2B9E0E531CA2AD9A1E8`.
It records the full payload, record domain and three concordant independent
recomputations. Two supporting reports have SHA-256
`2DE295AF46D0AC94FBC3FF691A13D61611A3C4D6804DA56554081DF7CE299DF3`
and `8D40D6FEFD066603BCB0696D0E50054DA16005230922D548DBA155EBD70EE2EE`.
None derives the expected literal through normal/physical TypeSchema
serialization, a decoder, scanner, patcher, project TypeSchema hash helper or a
test-side serializer.

Final disposition:

- IC-147 closed: the first self-confirming same-producer expectation is gone;
- IC-148 remains closed: duplicate B1 Class flag rows remain absent; and
- IC-149 closed: the hash-contaminated two-payload inequality is gone and exact
  independent final-output authority now covers the writer boundary.

The implementation report, including both repair addenda, has SHA-256
`7DF4B33E0633D1F64D94512CFA3FCEB3C8085F1F8DE3F3DF97EE51724A406D8A`.
The next executable producer slice is KindPayload/Enum/Callable/Typedef, including
IC-146; neither this approval nor its literals authorize B3 Runtime edits before
the deferred returned-result RED runs.

Post-close record validation:

- `openspec validate refactor-as-incremental-function-cache --strict`: valid,
  exit zero;
- parent and plugin `git diff --check`: exit zero; Git emitted only existing
  line-ending conversion warnings for unrelated tracked files;
- 40 non-history Markdown files, zero broken relative Markdown links;
- 60 current task IDs, 60 unique and zero duplicate groups; this remains a
  structural ledger check rather than feature completion;
- 49 total change Markdown files, with eight trailing-space lines: two retained
  pre-existing lines in `source-module-decoder-migration-audit.md` and the two
  intentional Markdown hard-break header lines in each of the immutable B1
  reviews and the Slice-1 golden recomputation attachment; and
- final test candidate remained SHA-256 `3A16BF27...C942` with 57 methods after
  all OpenSpec updates.

### B2 Slice 2 authority materialization

Before editing the Slice-1-approved candidate, a fresh read-only audit mapped the
KindPayload/Callable/Typedef/Enum obligations to exact existing fixtures, frozen
errors, representable DTO mutations and retained B1/Slice-1 coverage. Report:
`.superpowers/sdd/b2-slice-2-authority-audit.md`, SHA-256
`6DF3B491600F6AF1794CC20AB704BF606D0EE004ADCEF7D517F5FA06FDC6539D`.

The executable packet freezes one new scenario method with 19 previously missing
presence rows, five callable rows, six Typedef rows and three Enum rows. It
explicitly retains rather than duplicates two B1 presence rows, B1 ordinal/name
rows, Slice-1 Enum metadata rows and existing legal descriptor positives. Raw
invalid bools and out-of-range signed Enum values are excluded because their DTO
fields cannot represent those wire faults. The audit also records IC-150–IC-152:
zero callable ABI misclassification, primitive-only Typedef gaps and incomplete
Enum ordinal/name replay. No source, build, Automation or Runtime change was made
by the audit; the test candidate remained exact SHA-256 `3A16BF27...C942`.

### B2 Slice 2 exact candidate and review

Slice 2 adds only
`NormalProducerRejectsKindPayloadEnumCallableAndTypedefRulesAtomically` to the
owned TypeSchema test TU. The immutable plugin blob range is approved Slice-1
`a3d759ef3b95429f4837ab991763ffc58083836f` to Slice-2
`64478db37c4dfb8613b3b5f1d5aba501eb8f4cc0`: one file, 227 insertions, zero
deletions, exactly one new `TEST_METHOD`, and clean `git diff --check`.

The final candidate is SHA-256
`6408703A2A3DD6E981D92FAC97EAC20B0D85ACDD4F3CE13425D1F8A2EBD905F5`,
513,810 bytes, 11,594 LF, zero CRLF/bare CR, 58 methods and final LF. It contains
one local `FNoDiscardAsserter`, one `bPassed` aggregate and one final fatal
matcher. The row inventory is exact:

- 19 new KindPayload presence rows plus two retained B1 rows exhaust the seven
  TypeKinds × three optional arms exactly once;
- five callable rows separate zero key from zero ABI for Delegate/Funcdef and
  freeze Funcdef multicast IC-146;
- six DTO-representable Typedef rows cover Void, well-formed Auto, ScriptType,
  ObjectHandle, Reference and nonempty subtype array; and
- three Enum rows cover legal MIN/MAX numeric aliasing, empty name and stale
  EnumAuthorityHash, while B1/Slice 1 continue to own ordinal/name/metadata rows.

All 32 new negatives use the real normal-producer failure/atomic-output/
immutable-input helper with literal results. The one positive uses the normal
success helper. No Runtime, decoder, physical semantic oracle, test-side
validator/hash/serializer, trace, resolver, engine fixture or registration
shortcut is in the immutable delta. Raw invalid bool and out-of-range Enum values
remain wire-only because the producer DTO exposes C++ `bool` and `int32`.

Fresh compile evidence:

- artifact
  `Saved/Build/cache-b2-typeschema-producer-red-slice2-tu/20260809_025005_186_0a1e42ad/`;
- UE 5.8, exact absolute `-SingleFile`, `-NoXGE`,
  `-NoHotReloadFromIDE`, no timeout, wrapper/process exit `0/0`;
- exactly `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp`,
  `Result: Succeeded`, no compiler/linker warning/error/fatal diagnostics; and
- wrapper duration 9,534 ms; UBT 9.13 seconds.

Implementation report SHA-256:
`C26FB62E33A3A47FBD856792885D938F7980A8240C30C326B38D58305DDCB4F5`.
Fresh independent review `.superpowers/sdd/b2-slice-2-review.md`, SHA-256
`D1EB6F393C1AE1ABF903CCE72FDD967C0CE6E18EF8B59263A67DFAE57A9034C5`,
returned **APPROVED — 0 Critical / 0 Important / 0 Minor** after reviewing the
complete immutable blob diff, every fixture/precedence route and the exact build
artifact. Candidate SHA before and after review was identical.

The implementer initially reported the computed Git hash without persisting the
object. Root's first immutable comparison therefore returned `bad object`. Root
wrote the exact unchanged file bytes to the plugin submodule object database with
`git hash-object -w`; the resulting blob matched the reported hash. This changed
no working-tree, index, commit, branch or parent gitlink state. Review packages
must use the plugin object database for plugin blobs rather than the parent object
database.

This closes Slice-2 test authority/compile review only. IC-146 and IC-150–IC-152
remain behavior-open, IC-145 still defers the focused returned-result RED, and B2
remains unchecked.

## B2 Slice 3 authority correction review — rejected executable mismatch

The read-only Slice-3 audit is
`.superpowers/sdd/b2-slice-3-authority-audit.md`, SHA-256
`F576A7C5252D72EB79154EF8AA9AC7855EF896CE4291C93BD85CD062662F0E9A`.
It identified the missing exact local pairing result and proposed the Relations /
LayoutInputs obligation inventory. Root corrected three authority points before
new producer assertions: an individually valid stored BaseType/CodeRoot target
mismatch is `InvalidQualifierCombination`; forbidden nonzero relation cardinality
is `InvalidPresence` rather than `ConflictingKey`; and live Compose capture
NotCacheable is distinct from explicit DTO/payload validation.

Correction attachment
`reviews/b2-slice3-authority-correction.md` was initially SHA-256
`E0A2D85DC1170E913267BAE016FF72CF632C8C10B1D0D96D615A7709BED5B47E`.
The independent review
`reviews/b2-slice3-authority-correction-review.md`, SHA-256
`FDC924CF0B95E0D677FFEE722072E943228A8D836766CF297450F6F2AEFB53F4`,
returned **NOT APPROVED — 0 Critical / 1 Important / 0 Minor**. It accepted the
four normative decisions as coherent but proved the existing executable decoder
fixture `RelationKindsFormsCardinalitiesAndReferenceKindsAreCartesian` already
shared the audit's cardinality defect: its count-two non-interface branch expects
`ConflictingKey` even for forbidden Compose, contradicting the corrected
`InvalidPresence` authority.

IC-154 is therefore reopened. The correction attachment and current ledgers now
acknowledge the inherited fixture defect. The next evidence unit is a narrow
test-only repair from exact Slice-2 SHA
`6408703A2A3DD6E981D92FAC97EAC20B0D85ACDD4F3CE13425D1F8A2EBD905F5`,
followed by complete-TU compilation, exact-SHA review and a fresh authority
rereview. No Slice-3 producer source, Runtime source, focused Automation or
behavior claim is permitted in that repair.

### IC-154 repair approved — combined authority rereview pending

The narrow repair changed only the existing decoder Cartesian method by adding a
literal form/kind permission switch and restricting its count-two
`ConflictingKey` branch to allowed non-ImplementedInterface coordinates. The
immutable plugin blob range is Slice-2
`64478db37c4dfb8613b3b5f1d5aba501eb8f4cc0` to candidate
`4164f9f66e8f89915d13ae3dc25c131822925b1e`: 28 insertions, zero deletions.
Root persisted the exact unchanged candidate bytes to the plugin object database;
this changed no working bytes, index, commit, branch or parent gitlink.

Candidate SHA-256 is
`AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`,
514,861 bytes, 11,622 LF, zero CRLF/bare CR, final LF and 58 methods. Both planned
Slice-3 producer method names remain absent. Implementer report
`.superpowers/sdd/b2-slice3-decoder-cardinality-repair-report.md` has SHA-256
`D7AE5DE22DE03227B4FEA88C75C9983C2A8902959B18179BA0B2CC1F3E6FDE62`.

Fresh complete-TU compile artifact:
`Saved/Build/cache-b2-slice3-decoder-cardinality-authority-repair-tu/20260809_031909_287_9b3b7e4a/`.
It records exactly `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp`,
`Result: Succeeded`, `TimedOut=false`, UBT/wrapper exit `0/0`, 9,247 ms and no
compiler/linker diagnostic. This is compile authority only. Independent exact-SHA
review `.superpowers/sdd/b2-slice3-decoder-cardinality-repair-review.md`, SHA-256
`26C5D7F40B22928380C130732FAA2779C0F4B6A85A0456E64D97FDA63B3B22C8`,
returned **APPROVED — 0 Critical / 0 Important / 0 Minor**. It independently
enumerated all 495 cells as 167 success/None, 208 InvalidPresence, 110
WrongReferenceKind and 10 ConflictingKey with zero mismatch, confirmed Compose
cannot reach ConflictingKey, and verified candidate SHA at review start/end.

This approves the isolated executable-authority repair. IC-154 remains pending
only until a fresh combined IC-153–IC-155 authority rereview confirms the amended
normative documents and repaired exact fixture agree. It remains compile authority,
not focused behavior or B2/B3 completion.

### Fresh combined IC-153–IC-155 authority rereview

Fresh rereview
`reviews/b2-slice3-authority-correction-rereview.md`, SHA-256
`02C09AAD8C242E83BF455E8B934BB07D52646BCC30B12B31F077E6D6A8C2DCC3`,
returned **APPROVED — 0 Critical / 0 Important / 0 Minor**. It verified the five
frozen authority inputs at unchanged start/end hashes, the repaired plugin blob
and current complete-TU SHA, the full 495-cell distribution with zero mismatch,
the exact pairing error/offset, local-versus-graph ownership, Compose
capture/archive split and complete validation precedence. It also reran strict
OpenSpec and parent/plugin diff checks at exit zero.

IC-153 and IC-154 are therefore closed; IC-155 remains closed. Slice 3
Relations/LayoutInputs normal-producer authoring may be materialized from exact
SHA `AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`.
The evidence ceiling is unchanged: no focused Automation, linked-module behavior,
B2 completion, B3 permission or Runtime correctness is claimed.

During Slice-3 materialization, IC-156 corrected a non-normative audit count: its
LayoutInput table explicitly contains 13 legal baselines even though the prose
called them 12. The current packet enumerates those 13 rows and treats the audit's
old `53`/`188` minimum-call totals as superseded bookkeeping; authority coverage is
checked by explicit coordinates and exact-SHA review. No wire/error decision or
source byte changed for IC-156.

### B2 Slice-3 packet pre-implementation review

Independent read-only packet review
`.superpowers/sdd/b2-slice-3-packet-review.md`, SHA-256
`4FF6199681488950001F9C3F9EF6E8BE1D7A7B510305EAC27CC09789B30E4453`,
returned **NOT APPROVED — 0 Critical / 5 Important / 2 Minor** while the test TU
remained exact SHA `AA41A0AD...6813` and unedited. The relation table, ownership,
starting identity and compile boundary were sound; IC-157–IC-162 record the
required corrections for nine no-finalize rows, 13/5 baseline accounting, the
missing derived BaseType case, 12 optional masks, eight exact pairing rows,
unsigned overflow and single-input wrong-role fixtures.

The corrected exact inventory is 195 Relations calls and 100 LayoutInputs calls,
295 new normal-producer calls total. No implementation is released until both
packet copies contain those literal coordinates and a fresh read-only packet
rereview returns 0 Critical / 0 Important.

Fresh corrected-packet rereview
`.superpowers/sdd/b2-slice-3-packet-rereview.md`, SHA-256
`D7EFFB20EC2F8232732865FEB7D76D65A5047D7455AE2C9D1B993CB7081F54D9`,
returned **APPROVED — 0 Critical / 0 Important / 0 Minor** and explicitly released
the implementer. Corrected brief SHA-256
`7483C7CC55D652A495A123349983756ED610B078E1C573069E6FDCC36800FB05`,
implementation-plan SHA-256
`75952B3AA8BAB269270036C04BFCAE003C2AC035172146E7C6C935E5862EBD40`
and starting TU SHA `AA41A0AD...6813` were identical at review start/end. Strict
OpenSpec and parent/plugin diff checks passed. This closes IC-157–IC-162 packet
authority only; implementation/compile/exact-SHA source review remains open.

IC-163 records the handoff race: root first observed interim report SHA
`06B980...2081` before reviewer FINAL. The implementer recomputed the report,
stopped before editing and caused release to be revoked. Reviewer FINAL froze
`D7EFF...F54D9`; brief, plan and TU hashes stayed exact throughout. No source or
Git state changed during the aborted release.

### IC-164 first Slice-3 compile attempt

Exact artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice3-tu/20260809_042152_347_e5b34b99/`
records `TimedOut=false`, process/wrapper exit `6/1`, exactly one
`[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp` and two C3487
diagnostics at candidate lines 7472/7486. Both local find lambdas returned an
`int32` index on success and the anonymous-enum `INDEX_NONE` on failure, so auto
return deduction failed. No link or Automation was attempted. IC-164 permits only
explicit `-> int32` annotations on those lambdas followed by the same complete-TU
wrapper rerun; the 295-row inventory must remain unchanged.

### B2 Slice-3 authored candidate, compile repair and immutable freeze

The two approved packet methods were authored as an insertion-only change:
`NormalProducerRejectsRelationRulesAtomically` begins at current line 6876 and
`NormalProducerRejectsLayoutInputRolesAndPairingAtomically` begins at current
line 7343; the next pre-existing method begins at line 7961. The exact inserted
span is therefore 1,085 LF lines. The final complete TU is 556,261 bytes, 12,707
LF, zero CR, final LF present and 60 `TEST_METHOD` definitions. Its SHA-256 is
`3CC1A95A748106A05291CD0DE8D7B57ABCE61E807A8F89E2F4F204D6B23D2338`.

The first exact wrapper artifact remains at
`Saved/Build/cache-b2-typeschema-producer-red-slice3-tu/20260809_042152_347_e5b34b99/`.
It reached exactly one `[1/1] Compile [x64]
AngelscriptCacheTypeSchemaTests.cpp` action and failed with only C3487 at the
method-local `FindInputIndex` and `FindRelationIndex` lambdas because automatic
return deduction mixed `int32` indexes with UE's anonymous-enum `INDEX_NONE`.
Only explicit `-> int32` return types were added.

The fresh exact rerun artifact is
`Saved/Build/cache-b2-typeschema-producer-red-slice3-tu/20260809_042228_503_9dce9428/`.
Its `RunMetadata.json` records `TimedOut=false`, `ProcessExitCode=0`,
`ExitCode=0` and duration 9,106 ms. `Build.log` and `UBT.log` each contain exactly
one `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp` plus
`Result: Succeeded`, with no compiler warning/error/fatal or linker diagnostic.
This closes IC-164 as a compile-local issue.

The implementation report is
`.superpowers/sdd/b2-slice-3-report.md`, SHA-256
`718EF10929C5E0D6F851773E0E1FF41FE717298313CCFA4867D5BF6C39025730`.
Before independent review, the primary agent reconstructed the predecessor only
in memory by removing current lines 6876–7960. The bytes independently reproduced
the approved predecessor SHA-256
`AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`
and blob `4164f9f66e8f89915d13ae3dc25c131822925b1e`. It materialized that byte stream
and the unchanged candidate blob `653f8b05ad7a398f151690d44647571aa50380e9` in the plugin object database.
Candidate SHA before and after remained exact. Object-to-object `git diff`
reports one file, 1,085 insertions and zero deletions. This closes IC-165 and
provides a real immutable review boundary without staging, committing or updating
the parent gitlink.

The independent exact-candidate review ran from review brief
`.superpowers/sdd/b2-slice-3-review-brief.md`, SHA-256
`1041C8500C585FBDF313DEFA3CAC146A2F0449AEDCDAFD6E4BF9E1F22F361E0A`.
The reviewer sent FINAL only after all report writes were complete, explicitly
closing the IC-163 handoff race. Final report
`.superpowers/sdd/b2-slice-3-review.md` has SHA-256
`F3D0874865042668BAB4ABBFB8F1AF65F567918C5EF688395D176A82D908BB16`,
20,901 bytes and 442 LF lines. Verdict is **APPROVED — 0 Critical / 0 Important /
0 Minor**, with RELEASE tied only to candidate SHA
`3CC1A95A...D2338` / blob `653f8b05...80e9` over predecessor blob
`4164f9f6...25b1e`.

The review read the complete +1085/-0 blob diff and independently reconciled
Relations as `11 × 5 × 3 + 30 = 195`, LayoutInputs as
`13+3+5+34+3+8+12+3+3+6+4+5+1 = 100`, total 295. It approved every IC-157–IC-162
disposition and IC-164's two-return-annotation repair, verified start/end candidate
SHA equality, both readable blobs, all failed/success artifact hashes, strict
OpenSpec and parent/plugin whitespace gates, and unchanged branch/HEAD/index
gitlink state. Slice 3 is therefore approved source-inventory and complete-TU
compile authority. It is not linked focused Automation, returned-result RED,
producer behavior, B2 completion, B3 permission or Runtime correctness; IC-145
remains in force.

### B2 Slice-4 read-only research and authority decisions

The strict read-only research report
`.superpowers/sdd/b2-slice-4-research.md` was finalized before packet
materialization at SHA-256
`18045B2ABB5ED44B13B787CF3EFD85C932ED3F34B9F7DF01C6926A9E0E064237`,
26,034 bytes, 499 LF, zero CR and final LF present. It edited no Runtime,
OpenSpec, test TU or Git state. The approved Slice-3 source remained exact SHA
`3CC1A95A...D2338` throughout.

The research independently mapped four review regions: A owner/datatype envelope
45 core calls plus two raw-primitive decision rows; B exact
StorageKind×DataTypeKind×qualifier matrix 512 calls; C flags/replication 69 calls;
and D layout/replay 32 calls. The contradiction-free core is 83 legal + 575
negative = 658 calls.

IC-166 resolves the stale-hash ownership conflict by treating the five-hash list
as a whole-B2 exactly-once inventory. Approved Slices 2 and 3 retain Enum and
LayoutInput hash failures; Slice 6 owns both property hashes and final
TypeLayoutHash. Slice 4 therefore adds no stale stored-hash call and uses only
legal recomputation plus an unequal-fingerprint assertion for a self-consistent
wrong offset.

IC-167 freezes the two out-of-domain PrimitiveType values `13/255` as literal
`UnknownEnumValue` normal-producer failures, while known sentinel `0` remains
`InvalidPresence`. This follows `record-wire-v1.md`'s unknown-enum rule rather
than current producer behavior. The final ready-packet inventory is therefore
83 legal + 577 negative = **660 normal-producer calls**. IC-167 remains open as
a behavior mismatch until the eventual focused B3 GREEN; the expected literals
and Slice-4 packet allocation are now frozen.

The resulting HOLD packet is materialized in implementation-plan section 14,
SHA-256
`1900823269B6FA17CBBB01BC570FE1E50251BDD0605F9BD1082AA4BAA375FCB3`, and
`.superpowers/sdd/b2-slice-4-brief.md`, SHA-256
`1FE4407B618CE9DA5AA6869BFCEB70DF3CEE158268976F2ABF1518BC552A091B`.
It requires one method, four sequential source/compile checkpoints A/B/C/D, a
mechanical 512-cell seen ledger that cannot choose expectations, exact
47/512/69/32 and 83/577/660 counters, and final independent exact-source review.
The packet is not an implementation release until its independent review sends
FINAL with zero Critical and zero Important findings.

Packet-review assignment
`.superpowers/sdd/b2-slice-4-packet-review-brief.md` has SHA-256
`D1F98F688BBA17E6646E0A831FE25ECB62F1159C562A46DDED4389377FB0256A`.
At assignment, the TypeSchema TU remained exact SHA `3CC1A95A...D2338`; strict
OpenSpec validation and parent/plugin diff checks passed. No Slice-4 test source,
Runtime or Git state was changed during materialization.

The first full packet review is
`.superpowers/sdd/b2-slice-4-packet-review.md`, immutable SHA-256
`33C76F83B584DB63B8BEAC29606690BF1DFDFA41D4B9874B54E5B4BBE6417BE5`,
19,806 bytes and 397 LF. It returned **REJECTED — 0 Critical / 1 Important / 0
Minor; HOLD**. All A/B/D arithmetic, IC-166/167, finalization, ownership,
checkpoint and IC-145 boundaries passed. Region C exposed IC-168: the plan named
UStruct Skip as owner-forbidden even though frozen authority and the positive
mask list allow `0x00801`; Config `0x08001` is the required negative. The rejected
report remains historical evidence.

The repair changes only that plan word to Config and expands the brief's UStruct
negative wording to exact masks `0x00401`, `0x04401` with nonempty metadata and
`0x08001`. Region C remains 50/19/69 and the total remains 83/577/660. No test TU,
Runtime or normative artifact changed. Fresh immutable input hashes and rereview
evidence are: corrected plan SHA-256
`64112D126F1CD83E30BED9D95FD2C81F1D27DB678857132D00A875695832E178`,
corrected brief SHA-256
`8BBEBC6114493C1416590CC737DBB04AF12844F1183AF0AEAAB166EF7090EFB8`,
and fresh-rereview assignment SHA-256
`DE8CAD70564EA55C5320BF8552EF61F0B008F4321C45BFD3B0DBB7397AD6B9DE`.
The TypeSchema TU remained exact `3CC1A95A...D2338`; implementation stays HOLD
until rereviewer FINAL.

The first fresh rereview report
`.superpowers/sdd/b2-slice-4-packet-rereview.md` is immutable SHA-256
`1D53F5D252676561329B407766DC5524474A7BACA4D4369EFCB4D940A557BFA0`,
17,306 bytes and 358 LF. It returned **REJECTED — 0 Critical / 1 Important / 0
Minor; HOLD**. IC-168's exact plan/brief repair, Region C and the entire
83/577/660 packet passed. IC-169 was the sole finding: the candidate brief still
pinned rejected plan SHA `190082...FCB3` although the actual corrected plan was
`64112D...E178`, and the brief itself required stopping on any mismatch.

The IC-169 repair changes only that immutable-input pin to the actual corrected
plan SHA. Plan, research, audit, normative authority and TypeSchema test TU stay
unchanged. A new brief SHA and second fresh-rereview assignment are recorded at
the next gate; no implementation is released by this repair alone.

The final brief is SHA-256
`AB52CFD98E6C3970CE73691AD1D11ED8B6A8505C6EAD23B2E4C058AE6A48C4AB`;
the second fresh-rereview assignment is SHA-256
`756F56165B810DFFC885BECD4D7DBB3BD27F81E5A2CC2CCD11223A69BA6020B9`.
Final report `.superpowers/sdd/b2-slice-4-packet-rereview2.md` is immutable
SHA-256 `9FBDB7EDFD503709BC20343383216205BAC825A5C7E131A1FFDA6486753FD547`,
17,800 bytes and 373 LF. Verdict is **APPROVED — 0 Critical / 0 Important / 0
Minor; RELEASE this exact packet**.

The final review independently re-proved IC-168/169 by exact in-memory rollback,
all input hashes at start/end, IC-166/167, A/B/C/D arithmetic
47/512/69/32, grand total 83/577/660, matrix partitions, non-oracular seen ledger,
finalization/precedence, prior-slice nonduplication, checkpoint commands and the
IC-145 evidence ceiling. TypeSchema TU remained exact
`3CC1A95A...D2338` / blob `653f8b05...80e9`, 60 methods and Slice-4 method
absent. Region A only is now released; Regions B–D remain held behind their
sequential source/compile checkpoints.

## B2 Slice 4 Region A first implementation and IC-170 review — 2026-08-09

The first Region-A candidate added the sole complete
`NormalProducerRejectsPropertyStorageFlagsAndLayoutReplayAtomically` method and
froze SHA-256
`F55D1B975B1E13A6A1AE536DBACB7C1B4EF91288774B02B98D746164FD9D683E`,
read-only blob ID `67dc7676d8044634682729db242f38462ea9f54d`, 569,205 bytes,
13,017 LF, zero CR, final LF and 61 methods. Removing its sole 310-line insertion
in memory reproduced approved Slice-3 SHA-256
`3CC1A95A748106A05291CD0DE8D7B57ABCE61E807A8F89E2F4F204D6B23D2338`
and blob `653f8b05ad7a398f151690d44647571aa50380e9`, proving +310/-0 with
all predecessor bytes unchanged. The candidate mechanically contained exactly
7 success and 40 negative normal-producer calls, one `LocalAssert`, one
`bPassed`, one final fatal assertion, and no Region-B/C/D scaffold.

The complete-TU artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice4-a-tu/20260809_054713_556_404516b4`
records `TimedOut=false`, process/wrapper `0/0`, and exactly one successful
`[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp` in each text log with
zero compiler diagnostics. This is compile/source evidence only through IC-145.
Implementation report `.superpowers/sdd/b2-slice-4-report.md` is SHA-256
`0D3278DF0B2BD8F8B4D1E99FC8D8B35AA85E970B7061FB71280928DE804EF246`.

Independent exact-source report
`.superpowers/sdd/b2-slice-4-region-a-review.md`, SHA-256
`CD8DCCB9C16293894C9B4AF7C8C4CAEA89BA775065C94E6AC92BA43360ECDB9C`,
returned **REJECTED — 0 Critical / 1 Important / 0 Minor; HOLD**. IC-170 is the
sole finding: both intended Auto payload rows changed the Kind but omitted the
required Auto qualifier bit, so earlier Kind/bit agreement could produce the same
`InvalidQualifierCombination` literal and mask the named payload faults. The
repair must add that bit to both rows without re-finalization, retain 7/40/47,
rerun the complete TU and receive fresh exact-source approval. Region B remains
held.

IC-170 then changed only the two affected fixtures. Each received the exact
two-line assignment of `EAngelscriptCachedTypeQualifierFlags::Auto`; neither was
re-finalized. The first fixture now has a legal Auto envelope plus only its
non-Invalid Primitive payload fault, and the second has a legal Auto envelope
plus only its present TypeReference fault. Literal errors remain
`InvalidQualifierCombination`, and Region A remains 7 success / 40 negative / 47
total.

The repaired TU is SHA-256
`B3DA117B83CF89D92A1BB64B40DE58548465065717B29F56F594F9F0A5DD1711`,
read-only blob `8da8550bab9144bda65ba872712f571da829d579`, 569,449 bytes,
13,021 LF, zero CR, final LF and 61 methods. Relative to the rejected candidate
the repair is exactly +4/-0 and +244 bytes. Removing the two identical two-line
insertions in memory reconstructs `F55D1B...D683E` / `67dc767...f54d` exactly;
removing the complete repaired 314-line method reconstructs approved Slice 3
`3CC1A95A...D2338` / `653f8b05...80e9` exactly.

Repair report `.superpowers/sdd/b2-slice-4-region-a-repair-report.md` is SHA-256
`A567CFD0FB9ED2D328D13E50D307BD763398CD1087E4D9D9B96B2BAA2F96747E`.
Refreshed complete-TU artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice4-a-tu/20260809_060210_936_daa912b4`
records `TimedOut=false`, process/wrapper `0/0`, exactly one target-TU compile and
one success result in each text log, and zero compiler diagnostics.

Fresh exact-source report
`.superpowers/sdd/b2-slice-4-region-a-rereview.md`, SHA-256
`A647CBFCFA6B87D8149CF2788C31862B116A59273F301659A7BE5C46C270ACCA`,
12,207 bytes and 259 LF, returned **APPROVED — 0 Critical / 0 Important / 0
Minor; RELEASE repaired Region A**. It independently re-proved the repair-only
delta, both predecessor reconstructions, isolated Auto faults, complete 7/40/47
inventory, absence of Regions B–D, refreshed artifact and IC-145 ceiling. Region
B may now be explicitly released from exact repaired SHA `B3DA117B...D1711`;
Regions C/D, linked Automation, a B2-completion claim and B3 remain held.

## B2 Slice 4 Region B source/compile checkpoint — 2026-08-09

Region B extended the same sole Slice-4 test method with the complete
`StorageKind {InlineValue,ObjectHandle} × DataTypeKind
{Primitive,ScriptType,EnvironmentType,Auto} × QualifierMask {0x00..0x3f}`
matrix. The candidate is SHA-256
`C0F26A2B938426A2825D9A58E4EF0522078CB9586596C81115904AD1EA259B1A`,
read-only blob `728905e31cc114f2245455079a0af46b55f4c783`, 588,078 bytes,
13,424 LF, zero CR, final LF and 61 methods. Removing the 403-line Region-B block
and restoring the sole former final-context line reconstructs approved Region A
`B3DA117B...D1711` / `8da8550b...d579` exactly, proving a controlled
+404/-1 and +18,629-byte delta.

Actual-source enumeration found exactly 21 explicit legal rows and 25 fixed
failure partitions. The latter generate exact group counts
`63/62/62/64` and `64/56/56/64`, 491 failures total. The union with the 21
successes covers all 512 coordinates exactly once with zero duplicate, missing or
declared/generated partition mismatch. The `Seen[2][4][64]` ledger only marks and
counts; it cannot select an expectation. Eight common-envelope baselines use the
frozen V1 ObjectHandle layout where applicable; successes re-finalize their actual
mask, while failures preserve prior hashes and always pass literal
`InvalidQualifierCombination`. Region A remains 7/40/47, Region B is 21/491/512,
and the combined checkpoint is 28/531/559. Regions C/D remain absent.

Implementation report `.superpowers/sdd/b2-slice-4-region-b-report.md` is
SHA-256 `4E23C2D19876F5037CF008FA63A6EDC8411BCDB8E8447C178B9A923E5FA868D8`.
Complete-TU artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice4-b-tu/20260809_062722_000_6e8e12ef`
records `TimedOut=false`, process/wrapper `0/0`, exactly one target compile and
one success result in each text log, and zero diagnostics.

Independent exact-source report `.superpowers/sdd/b2-slice-4-region-b-review.md`,
SHA-256 `E5956A6BD00A258CDCE7E572416FAC615F7746D9D5B6DF7548BDF786715F7CEC`,
15,492 bytes and 347 LF, returned **APPROVED — 0 Critical / 0 Important / 0
Minor; RELEASE Region B**. It independently re-proved ancestry, all coordinate
sets and partitions, non-oracular ledger use, finalizer/layout discipline,
counter closure, Region-C/D absence, the exact artifact and IC-145 ceiling.
Region C may now be explicitly released from SHA `C0F26A2B...59B1A`; Region D,
linked Automation, a B2-completion claim and B3 remain held.

## B2 Slice 4 Region C source/compile checkpoint — 2026-08-09

Region C added the frozen property flags, replication condition, metadata and
owner matrix to the same sole method. Candidate SHA-256 is
`5E9A47438D73F936B7C998E7CD329502F9A9E9F6444EE7AC7796F8267999EC5F`,
read-only blob `f90fba90fda283578613a4769809fc76af9ecb9f`, 598,091 bytes,
13,651 LF, zero CR, final LF and 61 methods. Removing its 227-line block and
restoring the former final-context line reconstructs approved Region B
`C0F26A2B...59B1A` / `728905e3...c783` exactly, proving +228/-1 and a
+10,013-byte delta.

The exact 50 positives are 18 ordinary-UClass masks, conditions `1..15` on
closed `0x00401`, 16 UStruct masks, and one non-RepNotify
`ReplicatedUsing` metadata row. The 19 negatives split exactly into 2
`UnknownFlags`, 2 `UnknownEnumValue`, 7 `InvalidPresence` and 8
`InvalidQualifierCombination`. IC-168 remains explicit: UStruct `0x00801` is a
legal positive; the UStruct negatives are only `0x00401`, closed
`0x04401` plus metadata and Config `0x08001`. All 50 positives and seven
closed owner-prohibition rows finalize; the twelve malformed common/field rows
retain baseline hashes. Region A/B inventories stay unchanged, Region C is
50/19/69, and the combined checkpoint is 78/550/628. Region D is absent.

Implementation report `.superpowers/sdd/b2-slice-4-region-c-report.md` is
SHA-256 `80C33348DA7419A28F32845C22580CEBBCDDA08F68D54DA983351C5837BD68D0`.
Complete-TU artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice4-c-tu/20260809_064641_622_ca0a9a7d`
records `TimedOut=false`, process/wrapper `0/0`, exactly one target compile and
one success result per text log, and zero diagnostics.

Independent exact-source report `.superpowers/sdd/b2-slice-4-region-c-review.md`,
SHA-256 `D6E68253B9D931EE58C1CD78B5354573360C2EEB7F8903B7A2C497698BD1BEEB`,
15,686 bytes and 346 LF, returned **APPROVED — 0 Critical / 0 Important / 0
Minor; RELEASE Region C**. It independently re-proved ancestry, every positive
and negative coordinate, IC-168, first-error/finalizer discipline, counter
closure, Region-D absence, the exact artifact and IC-145 ceiling. Region D may
now be explicitly released from SHA `5E9A4743...9EC5F`; linked Automation, a
B2-completion claim and B3 remain held.

## B2 Slice 4 Region D and final exact-blob authority — 2026-08-09

Region D completed the same sole Slice-4 method with five legal layout controls
and 27 literal layout/replay/range failures. Final candidate SHA-256 is
`9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`,
read-only blob `0e0c8dcbc06a7b41ac56e679900cd6f4200afcc0`, 614,741 bytes,
14,005 LF, zero CR, final LF and 61 methods. Removing the 354-line Region-D block
and restoring the former final-context line reconstructs approved Region C
`5E9A4743...9EC5F` / `f90fba90...ecb9f` exactly, proving +355/-1 and a
+16,650-byte delta.

Region D is exactly 5 successes and 27 failures grouped 6 aggregate alignment,
7 layout/boundary, 4 cursor/tail, 5 storage scalar and 5 checked arithmetic. The
literal split is 17 `InvalidQualifierCombination` and 10 `Overflow`. The aligned
wrong-cursor witness changes final offset 8 to 12 while terminal size remains 16,
legally re-finalizes, and separately proves unequal property fingerprint and
TypeLayoutHash without corrupting a stored hash. All 27 negatives and three
mutated legal controls explicitly finalize; the other two legal fixtures arrive
builder-finalized.

Primary precompile review found IC-171 before any D wrapper: the first candidate
stored terminal SemanticSize above INT32 and could duplicate an earlier scalar
range fault. Its SHA/blob was `867B6453...17ECB` / `07e6921f...ddee60`.
Changing only that stored size to `MAX_int32` is one line, -12 bytes and zero LF;
inverse replacement reconstructs the first candidate exactly. The final fixture
has cursor `MAX_int32`, aggregate alignment 8 and stored size `MAX_int32`, so
terminal `AlignUp` itself crosses INT32.

Implementation report `.superpowers/sdd/b2-slice-4-region-d-report.md` is
SHA-256 `379F717EC3404CD89ADEB3585BD0ED6ED9B3ED1EDDE5D918FE307B02D3FCBAF7`.
Complete-TU artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice4-d-tu/20260809_070957_972_ad87c6c3`
records `TimedOut=false`, process/wrapper `0/0`, one target compile and one
success result per text log, and zero diagnostics.

Final independent report `.superpowers/sdd/b2-slice-4-final-review.md`, SHA-256
`FB9CC81BDAF70A4F4650030886499FF4038BDE96D4A29BAF95800C5E21E9212A`,
21,673 bytes and 459 LF, returned **APPROVED — 0 Critical / 0 Important / 0
Minor; RELEASE exact final Slice-4 source/compile authority**. Removing the unique
1,298-line method reconstructs approved Slice 3
`3CC1A95A...D2338` / `653f8b05...80e9` exactly, proving Slice 4 is a pure
+1298/-0 and +58,480-byte insertion. The final method has one declaration, one
`LocalAssert`, one `bPassed` and one final fatal assertion. Its exact inventory is
A 7/40/47, B 21/491/512, C 50/19/69 and D 5/27/32, totaling 83 success,
577 negative and 660 normal-producer calls. All A/B/C review identities and all
four 0/0 TU artifacts remain exact. No dynamic oracle, decoder/physical patch,
resolver, stale hash, second method, link or Automation evidence exists. Slice 4
is closed only at source/compile authority; B2, focused behavioral RED and B3
remain open through IC-145.

## OpenSpec-only refactor baseline

Before the current document refactor, the canonical manifest of all changed or
untracked files outside this OpenSpec directory contained 46 paths and had SHA-256
`1CBB69F56FD8839E097187A43AF30E3A6A9990F67413511D078C3CA4E987CE0D`.
The plugin status text had SHA-256
`6E6AF95D06A866F98ED6D882CA03B3DC8805690626FD38DDCE79A20210B5D1F5`.

R1 may close only after recording all of the following here:

- strict OpenSpec validation result;
- current non-history relative Markdown link scan;
- current task-ID uniqueness scan;
- archived-file SHA/size verification against `history/index.md`;
- `git diff --check` result;
- recomputed non-OpenSpec canonical manifest equal to the baseline above; and
- plugin status text hash equal to the baseline above.

### R1 final evidence — 2026-08-09

- `openspec status --change refactor-as-incremental-function-cache`: schema
  `spec-driven`, 4/4 required artifacts complete.
- `openspec validate refactor-as-incremental-function-cache --strict`: valid, exit
  zero.
- Current task scan: 60 IDs, 60 unique, zero duplicate groups. The count is a
  structural check, not a feature-progress percentage.
- Current execution-document reference scan: all actual relative Markdown links
  and backtick document references resolve after treating the single archived
  original-path cell in `history/index.md` as historical metadata rather than a
  current target.
- Archive recheck: all seven indexed files match the exact SHA-256 and byte size in
  `history/index.md`; zero mismatches.
- `git diff --check` in the parent and `Plugins/Angelscript` repositories: both exit
  zero. The eleven new/current execution documents have zero trailing-whitespace or
  missing-final-LF findings. Two pre-existing trailing-space lines remain in the
  untouched frozen attachment `source-module-decoder-migration-audit.md`.
- Recomputed non-OpenSpec source manifest: 46 rows, SHA-256
  `1CBB69F56FD8839E097187A43AF30E3A6A9990F67413511D078C3CA4E987CE0D`,
  exact baseline match.
- Recomputed plugin status text SHA-256:
  `6E6AF95D06A866F98ED6D882CA03B3DC8805690626FD38DDCE79A20210B5D1F5`,
  exact baseline match.
- Independent read-only review first reported 0 Critical / 2 Important / 0 Minor:
  two nonexistent future paths and a backlog-versus-ready-packet wording conflict.
  After correcting real plugin paths, materialization rules, the complete B1 packet
  and the B/C critical-path diagram, the independent regression review returned
  0 Critical / 0 Important / 0 Minor.

No Runtime/Test implementation, build, Automation, PIE or package execution was
performed for R1; this was deliberately an OpenSpec-only refactor. Existing
compile/frontier evidence retains exactly its prior evidence level.

The R1 digest is historical equality evidence for that completed document-only
reset. IC-144 now intentionally changes one of the 46 non-OpenSpec files,
`AngelscriptCacheTypeSchemaTests.cpp`. Therefore later B1 verification compares a
controlled file-level delta against R1 and freezes a new snapshot; it must not
claim the old content digest still matches after a legitimate test edit.

## Future milestone evidence gates

| Milestone | Minimum close evidence |
|---|---|
| B | Complete record/factory/graph focused Automation plus affected common archive regression, exact reviewed shared-safety SHAs and non-test seam scan. |
| C | Archive/PackFormat/Manifest focused Automation proving all deterministic orders and reachability through B. |
| D | Focused Store fault/recovery/concurrency Automation with exact committed slot states. |
| E | Integration proof for zero-work exact warm restore and controlled one-body recompilation using the real compiler/VM path. |
| F | Lifecycle integration and real PIE acceptance for code-only and structural transitions; StaticJIT routing isolation. |
| G | Full Cache/affected prefixes, real PIE, real Development and Shipping multi-launch matrices, benchmark rows and final project validation. |

## B2 Slice 5 read-only research hold — 2026-08-09

- Research: `.superpowers/sdd/b2-slice-5-research.md`, SHA-256
  `FE79C93FFD9F924D77FB257DD51A4F4A234189022D732B81EE2D2A9FEDFBBAED`,
  34,456 bytes, 643 LF, zero CR, final LF.
- Frozen test TU remained SHA-256
  `9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`,
  614,741 bytes, 14,005 LF, zero CR, 61 methods and final LF.
- Frozen producer remained SHA-256
  `DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`.
- Mechanical represented-coordinate candidates are 121 Method/VFT calls
  (20 success/101 negative) and 1,967 Behavior calls
  (110 success/1,857 negative), total 2,088 (130/1,958).
- IC-182 later superseded those totals for packet purposes: the research used
  seven TypeKind empty baselines, whereas the released authority requires eleven
  legal TypeKind+Reflection-form empty baselines. The old figures remain exact
  historical research output but are not a ready-packet inventory.
- Result: HOLD. No ready packet, build, Automation, source edit, Runtime edit or
  B2/B3 claim. The research first exposed IC-172–IC-176; two proposal reviews
  subsequently exposed IC-177–IC-180. All require reviewed authority correction
  first.
- Initial correction proposal SHA-256
  `31491B8837618B5B7957AEDE0C8EA9DB230707A253F86455B01E3D6E80370A98`
  received independent 0 Critical / 6 Important / 1 Minor HOLD. The repaired
  proposal SHA-256
  `429B182728277F7362BD72AC1AAAA52BCE17B4B0055AE33CD58D16DF61C47558`,
  19,270 bytes, 377 LF, zero CR and final LF received independent 0 Critical /
  2 Important / 1 Minor HOLD. Its review is preserved at
  `reviews/b2-slice5-authority-correction-proposal-rereview.md`.
- The second review found no new flaw in IC-172/173, duplicate-key/error-order,
  all-nonhash finalization or the statics inventory. It rejected nonexistent
  array-container capture names (IC-179), double ownership of the Behavior
  optional-owner phase (IC-180), and one stale “available form” phrase.
- The proposal-only repair now freezes exact existing captured fields/indices and
  a `Reflection` fallback only for form-selected missing rows; audits ordinary
  UClass, UStruct and other non-statics forms; and gives the optional owner one
  active-value phase plus one later tag-shape phase. Its new exact identity is
  SHA-256 `D48D94CF54288A09E12400AAA830A0063285D9AAE23D7E7F55E9DE9C746C18E1`,
  23,066 bytes, 432 LF, zero CR and final LF.
- Fresh independent final review
  `reviews/b2-slice5-authority-correction-proposal-final-review.md` returned
  **RELEASE — 0 Critical / 0 Important / 1 Minor**. It independently verified
  actual captured-field representability across all forms, the optional-owner
  phase split, no-look-ahead, prior accepted decisions and every frozen source
  boundary. Its one Minor requires the normative patch to state that a second
  singleton Relation/LayoutInput is already `DuplicateKey`/`ConflictingKey` in
  the field-local pass and never reaches `ReflectionFormClosure`.
- Authority-patch authoring is now released. Runtime/test source, a Slice-5 ready
  packet, linked Automation, B2 completion and B3 remain held pending a separately
  reviewed exact authority patch and packet.

## B2 Slice 5 exact authority-patch candidate — 2026-08-09

- Packet `b2-slice5-authority-patch.md` is SHA-256
  `88B55F94470919BB5A01F151CF2F5653AB31D95686E9A463297D0C9D02EA31A3`,
  6,423 bytes, 115 LF, zero CR and final LF.
- Normative `type-schema-matrix-v1.md` candidate is
  `AB9B294C293C7929EE92CA61DF44DDF5827C94666705AF7E57A67B87421B8CD8`,
  101,739 bytes, 1,698 LF, zero CR and final LF.
- Normative `type-layout-authority-v1.md` candidate is
  `0F336B77A01AABA5C4A05B807126974770EB159C0CFB3C18D97061DA48A406B7`,
  55,287 bytes, 933 LF, zero CR and final LF.
- Normative `record-wire-v1-remaining.md` candidate is
  `A2BAD67CD937CB8FCF039FED1FB53BD8B471AD7D24EE2DF323A1F9CC14A8D1CE`,
  104,469 bytes, 2,141 LF, zero CR and final LF.
- Non-normative `producer-b2-coverage-audit.md` candidate is
  `C972C1C1F9E99FA0872BA549376E5B610BDDEE0B4A86AFBFD96EBC0004693C59`,
  21,792 bytes, 484 LF, zero CR and final LF.
- The patch transcribes the released local/graph split, no-look-ahead closure,
  exact array phases, existing captured coordinates, all-nonhash finalization and
  graph-owned default-constructor truth. It incorporates IC-181 by routing second
  singleton rows to field-local duplicate/conflict, not closure.
- Self-audit exposed IC-182: seven TypeKind empty baselines do not cover the eleven
  legal TypeKind+Reflection forms. The old 121/1967/2088 research totals are
  historical only; no replacement total is frozen before packet rematerialization.
- Strict OpenSpec validation, parent/plugin diff check and frozen source SHA checks
  pass. No build, Automation, PIE or package work was run. The exact four-file
  authority patch entered independent review; source remained held.
- Independent atomic review
  `reviews/b2-slice5-authority-patch-review.md` returned **HOLD — 0 Critical /
  1 Important / 0 Minor**. IC-183 found that the matrix assigned DTO-derived
  Dependency set equality to graph while the local-order section, both
  co-normative authorities, producer audit and approved B1 expectations assign it
  to local cross-field validation. Packet `88B55F...31A3` and its four identities
  are rejected; a repaired exact packet requires fresh review.

### IC-183 repaired authority candidate

- Repaired packet `b2-slice5-authority-patch.md` is SHA-256
  `32E72EE160E5E6E1ABB57B9533840037E17A896EECA13B3289F08EE8142CC2D8`,
  7,620 bytes, 134 LF, zero CR and final LF.
- Repaired `type-schema-matrix-v1.md` is
  `79D2CEED017F3052998F31F9B89F20C75B164339889D0BB006DA1BFD6D81BB11`,
  102,842 bytes, 1,714 LF, zero CR and final LF.
- Repaired `type-layout-authority-v1.md` is
  `DA934BD10A4A0821C8BFD0B028938AA2E1EC65769CCCDBF3E1FCCE6B7A229687`,
  55,779 bytes, 940 LF, zero CR and final LF.
- Repaired `record-wire-v1-remaining.md` is
  `8E290B464AD2F6B885E94DC66E302C07E35EBA9CAA4E9EB0092E7973B8812CD9`,
  105,231 bytes, 2,152 LF, zero CR and final LF.
- Repaired non-normative `producer-b2-coverage-audit.md` is
  `8E9E92F5487F47CB5FBBAF5887745B692075A9F55D1FA43C8121702D32838E38`,
  22,222 bytes, 491 LF, zero CR and final LF.
- IC-183 now assigns Dependency shape/order/duplicate to the field-local pass;
  DTO-derived exact set equality to later local cross-field validation with
  `MissingCoverage`/`UnexpectedRecord`; and target existence/entity/actual owner/
  module/ABI plus record/declaration coverage to graph. Missing-row diagnostics
  use the physical Dependencies-array/enclosing-field error offset without
  inventing a public captured coordinate; extra rows use indexed `Dependency`.
- Strict OpenSpec validation, parent/plugin diff checks and frozen source SHA
  checks pass. This is a fresh candidate awaiting review, not an approval.
- Fresh rereview
  `reviews/b2-slice5-authority-patch-rereview.md` returned **HOLD — 0 Critical /
  1 Important / 0 Minor**. IC-183 remained incomplete in three old clauses:
  forbidden extra dependency kinds still said graph; immutable property checks
  still said graph exact ValueLayout dependency coverage; and both TS-SCR-19 rows
  still named graph dependency-coverage indexes. Packet `32E72E...C2D8` is
  rejected and requires another exact repair/review cycle.

### IC-183 repair 2 candidate

- Packet `b2-slice5-authority-patch.md` is SHA-256
  `0C978C15083B81EDCDF298881238C1CEEA2F4D92FB4A6CDB3D785D0B37E8A144`,
  8,176 bytes, 144 LF, zero CR and final LF.
- `type-schema-matrix-v1.md` is
  `206BA8D6D163419A8535DFFA2F16E5B346E244BC9170D9DAF3D9E060951B0B12`,
  102,941 bytes, 1,715 LF, zero CR and final LF. Forbidden extra common
  Dependency kinds now explicitly return local `UnexpectedRecord`; TS-SCR-19 is
  Dependency-target graph resolution.
- `type-layout-authority-v1.md` is
  `21B84C112EC4B8C2E85FBBF80B155914F689C337F555BC55A83D5C38D398057C`,
  56,150 bytes, 944 LF, zero CR and final LF. Its immutable graph section now
  begins from already-proven local pairing/storage/dependency-set facts and only
  resolves targets/linked authorities; TS-SCR-19 no longer owns set coverage.
- `record-wire-v1-remaining.md` remains exact
  `8E290B464AD2F6B885E94DC66E302C07E35EBA9CAA4E9EB0092E7973B8812CD9`,
  105,231 bytes/2,152 LF; `producer-b2-coverage-audit.md` remains exact
  `8E9E92F5487F47CB5FBBAF5887745B692075A9F55D1FA43C8121702D32838E38`,
  22,222 bytes/491 LF. Both already expressed the corrected split.
- Strict validation and diff checks pass. Repair 2 is unapproved pending fresh
  atomic rereview; source hashes remain frozen.
- Final review `reviews/b2-slice5-authority-patch-final-review.md` returned
  **RELEASE — 0 Critical / 0 Important / 0 Minor** for exact packet
  `0C978C...A144`. It mechanically swept every remaining Dependency coverage/
  extra/TS-SCR-19/graph clause and confirmed one semantic owner, then rechecked
  every packet question, IC-181/182, finalizer/Slice-6 boundaries, strict
  validation and frozen source hashes. Only ready-packet rematerialization is now
  authorized; C++ remains held.
- `openspec validate refactor-as-incremental-function-cache --strict
  --no-interactive`: valid, exit zero after recording the initial hold.
- Parent and plugin `git diff --check`: both exit zero; output contains only the
  previously known unrelated LF-to-CRLF working-copy warnings.

## B2 Slice 5 ready-packet candidate and repair — 2026-08-09

- Initial `b2-slice5-ready-packet.md` candidate was SHA-256
  `A06F117FF4556C01D9E78EB380736D32F0DBEEBA1287780C080FBF22D92C3FD7`,
  30,805 bytes, 648 LF, zero CR and final LF. Independent exact-file review
  returned 0 Critical / 3 Important / 3 Minor, HOLD. The immutable rejected
  review is `reviews/b2-slice5-ready-packet-review-A06F117F.md`.
- Repair 1 was SHA-256
  `9E3222C92135C01BE4A8712BE26D9F982BD49C386AAD8764CAD3C4E607F38A6D`,
  34,822 bytes, 701 LF, zero CR and final LF. Two independent exact-file reviews
  both returned 0 Critical / 2 Important / 1 Minor, HOLD. Their records are
  `reviews/b2-slice5-ready-packet-rereview-9E3222C9.md` and
  `reviews/b2-slice5-ready-packet-rereview-9E3222C9-secondary.md`.
- The final repair-2 packet is SHA-256
  `2B51C3601888B53DABDFB2C021605138113DF937773C2450DA653C43D47AF625`,
  36,113 bytes, 713 LF, zero CR and final LF.
- Immutable inputs remain test TU
  `9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`,
  Runtime producer
  `DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`
  and DTO/header
  `CE9BF77DE6C4AD969ADC7E3F8754FBBE78C7ADDAEA15D1F9E9EB818C3426FDD7`.
- Three independent read-only audits confirmed the eleven legal forms, exact
  existing source coordinates, local/graph and Dependency/finalizer boundaries.
  The first mechanical audit projected 2,092 by adding four empty successes to
  the historical ledger. A fresh adversarial audit rejected that projection:
  the old 19-row focused subtotal summed to 21, omitted per-kind ordinal rows,
  four owner/ordinal winners, script-copy no-peer failures and Environment-copy
  anti-alias controls, and duplicated singleton overflow already present in the
  cardinality-two product. This discovery is IC-184.
- The candidate's new normal-producer ledger is:

  ```text
  Method/VFT producer       121 =  20 success +  101 failure
  Behavior producer        1994 = 118 success + 1876 failure
  -------------------------------------------------------
  Slice-5 producer total   2115 = 138 success + 1977 failure
  ```

- Behavior is exactly 1,930 form/product calls plus 64 focused calls. The focused
  partition is 16 non-Construct gaps, 17 duplicate-ordinal rows, one within-group
  reorder, one group disorder, eight script-copy alias failures, two additional
  owner-precedence rows, four Environment-copy anti-alias successes, target/raw/
  count rows, one cross-role alias success and one explicit abstract-Class
  constructor-group success. Three ordinal-winning owner pairs are embedded in
  named ListConstruct/AddRef/Release per-kind gap rows. Fourteen singleton `0,1`
  overflows and Environment-copy no-peer successes are cited from the represented
  product rather than duplicated.
- Existing-test repair ledger is separate: five failure-to-success replacements;
  four retained failure error/coordinate repairs; two Class count physical-row
  coordinate repairs; delete 952 decoder ghost calls and add eleven real-form
  empties (net -941); and add five decoder owner/ordinal-coordinate scenarios.
- IC-185 records that the current decoder Cartesian's broad Declaration/
  EnvironmentAbi removal can erase non-Behavior dependencies. Candidate fixture
  rules require exact reachability-preserving dependency closure, canonical sort
  and final TypeLayoutHash regeneration after every non-hash mutation.
- Rejected-review IC-186–188 are repaired in the new exact packet: decoder owner
  presence uses the released `BehaviorDeclaringOwner` coordinate, all five paired
  decoder cases freeze physical PrimaryIndex, a static companion-recipe table
  closes Class/Destruct/copy/Delegate state without an expected-value oracle, and
  the only allowed PowerShell wrapper no longer uses backslash-escaped quotes.
- The three Minor findings are also repaired: internal section links are real, the
  IC-173 replacement test name is exact, and TemplateCallback uses a wire-valid
  ScriptFunction/nonzero-owner gap setup without claiming a legal target arm.
- Both repair-1 reviewers independently found IC-189/190. Six represented
  owner-absent Script Copy cells could copy their absent owner into an earlier
  Construct/Factory peer, so the peer would fail before the primary coordinate.
  The focused Class CopyFactory no-peer mutation could also leave counts at `1/0`
  and return count `InvalidPresence` before alias `InvalidQualifierCombination`.
- Repair 2 gives exact alias peers only to owner-present-nonzero primaries, gives
  owner-absent primaries no invalid earlier alias peer, and removes both exact
  Factory and its solely balancing Construct for CopyFactory no-peer, preserving
  `0/0`. It also narrows the Section-6 subject to the Behavior producer and
  repaired decoder only.
- Two independent final exact-file reviews both returned 0 Critical / 0 Important
  / 0 Minor, RELEASE:

  ```text
  primary   reviews/b2-slice5-ready-packet-final-review.md
            SHA B7CF20870BB8D26E8B85ABCBA65D000B400B7E589319DA20BF283E1ACD27A119
            3,742 bytes / 91 LF / 0 CR / final LF

  secondary reviews/b2-slice5-ready-packet-final-review-secondary.md
            SHA 0B5E420B093C0578076CFD4D94BFFBFEAB061A934A28C739664A92CE4CB4CA23
            1,440 bytes / 35 LF / 0 CR / final LF
  ```

- RELEASE is scoped to future source authoring in the one frozen test TU. It is
  not source evidence, compile evidence, focused behavior, B2 completion or B3
  permission.
- Evidence ceiling: candidate packet only. No C++ source, build, Automation, PIE,
  package or Git operation was performed during packet release. Source authoring
  is now authorized only under the packet checkpoints.

Exact commands, discovered/executed counts, exit codes and artifact paths are
appended when executed. Planned commands are not evidence.

## B2 Slice 5 source and complete-TU compile — 2026-08-09

- Current test TU SHA-256
  `18A55226D0786BC0C9C7E120492D55A9DB487CBC0070A1612BE3AB1BE356D5F9`;
  read-only Git content hash `40100ff6fc04d6c296ac43edae66d6333261b8c6`;
  680,701 bytes, 15,693 LF, zero CR, final LF and 63 `TEST_METHOD`s.
- Source arithmetic is frozen at Method/VFT `121 = 20 success + 101 failure`,
  Behavior form/product `1930 = 112 + 1818`, focused Behavior `64 = 6 + 58`,
  total Behavior `1994 = 118 + 1876`, and Slice-5 producer
  `2115 = 138 + 1977`.
- The static Behavior table mechanically recounts as 45 cells: 28 Script, 17
  Environment and 101 success coordinates. The repaired Behavior decoder region
  contains zero dynamic `bExpected`, malformed-ordinal helper, broad role reset or
  zero-cardinality ghost loop.
- First exact wrapper run:
  `Tools\RunBuild.ps1 -Label cache-b2-typeschema-producer-red-slice5-tu
  -TimeoutMs 1800000 -NoXGE -ExtraArgs
  @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')`.
  Artifact
  `Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/20260809_102901_365_9387a66e`
  failed compilation with C2838/C2065 because the test used nonexistent wire enum
  member `BehaviorDeclaringOwner`. IC-191 records the exact logical-to-wire mapping.
- After mapping the logical owner capture to
  `BehaviorDeclaringOwnerOptionalTag`, same primary row and secondary `1`, the
  same wrapper/label succeeded. Artifact
  `Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/20260809_103033_382_7db8e595`;
  one action compiled `AngelscriptCacheTypeSchemaTests.cpp`, process exit `0`,
  wrapper exit `0`.
- `git -C Plugins/Angelscript diff --check` exits zero. Source SHA, bytes, line
  endings, method count and balanced braces were rechecked after compilation.
- Evidence ceiling: complete single-TU compile and main-thread mechanical source
  audit only. No link, Automation behavior, B2 completion, B3 Runtime behavior,
  PIE or package evidence was claimed at that historical checkpoint. IC-145 then
  required the decoder/Manifest link frontier; the following section records its
  later closure and the first truthful focused behavior.

## B5 physical GREEN and first linked B2/B6 RED — 2026-08-09

- The historical evidence ceiling above was crossed by a complete Runtime/Test
  link at
  `Saved/Build/cache-b5-b7-c2-linked-frontier/20260809_105449_324_a3d8c373`.
  The Manifest/Pack files in that build are declarations plus error-returning link
  stubs only; no C2 behavior is claimed.
- The first exact method command omitted the CQTest class segment and discovered
  zero tests at
  `Saved/Tests/cache-b5-typeschema-physical-red/20260809_105534_514_b8713857`.
  This is IC-192 and is explicitly not RED/GREEN evidence. Correct exact names use
  `Angelscript.TestModule.Cache.Archive.TypeSchema.FAngelscriptCacheTypeSchemaTests.<Method>`.
- `AllSeventeenBehaviorKindsUseRepresentedNonemptyRowsAndElevenEmptyForms`
  discovered/executed one method and failed through returned assertion mismatches
  at
  `Saved/Tests/cache-b5-behavior-kinds-red/20260809_105855_049_5c3939e3`.
  This is trustworthy B6 RED for the missing Behavior local validator.
- `PhysicalExhaustionAndTrailingDataPrecedeSemanticHashes` passed 1/1 at
  `Saved/Tests/cache-b5-physical-exhaustion-red/20260809_110006_698_930666d2`;
  `TypeSchemaCapturedCoordinateMatrixZeroThroughThirtyEightIsExactAndFree` passed
  1/1 at
  `Saved/Tests/cache-b5-captured-coordinate-red/20260809_110047_628_4bd48a10`.
- The first truncation-boundary run failed only its byte offset at
  `Saved/Tests/cache-b5-truncation-boundaries/20260809_110124_776_8297df8a`.
  After IC-193, Runtime TU and linked builds passed at
  `Saved/Build/cache-b5-truncation-offset-runtime-tu/20260809_110310_515_e49cbe1f`
  and
  `Saved/Build/cache-b5-truncation-offset-linked/20260809_110323_979_b263ea97`.
  A rerun exposed IC-194; after the array classification repair, linked build
  `Saved/Build/cache-b5-array-truncation-linked/20260809_110535_826_a8d2b5a5`
  and exact test
  `Saved/Tests/cache-b5-truncation-boundaries-green-2/20260809_110557_312_8091027b`
  passed 1/1.
- The raw enum/tag method crashed at
  `Saved/Tests/cache-b5-raw-domains-red/20260809_110735_609_f0ec2a6d`.
  A temporary diagnostic build/run at
  `Saved/Build/cache-b5-raw-span-diagnostic-linked/20260809_110932_426_9bb35446`
  and
  `Saved/Tests/cache-b5-raw-span-diagnostic/20260809_110952_966_52959757`
  isolated independent field `67`, Primary `0`, missing Secondary. The diagnostic
  edit was reverted before the permanent `(Property 0, Node 0)` test-only repair.
  Final linked build
  `Saved/Build/cache-b5-raw-coordinate-authority-linked/20260809_111213_253_ca0338bb`
  and exact run
  `Saved/Tests/cache-b5-raw-domains-after-coordinate-fix/20260809_111228_730_e026fdb4`
  passed 1/1.
- The five-method B5 focus passed total `5`, passed `5`, failed `0`, skipped `0`
  at
  `Saved/Tests/cache-b5-physical-focused-green/20260809_111346_019_36ca749b`.
  Methods cover raw domains, the independent raw scanner, all captured coordinates,
  every one-byte truncation boundary and physical/trailing-data precedence.
- Corrected test source identity is SHA-256
  `2ACBD5E2005141805586D2D04FFE815E72B564F38FAE203D9C92D8810023E5EB`,
  Git blob `1d9709a896e1b493b08fdbeeb94d740a7a0dbec7`, 680,785 bytes,
  15,695 LF, zero CR, final LF and 63 methods. The prior SHA
  `18A552...D5F9` remains historical and is superseded by IC-195.
- `NormalProducerRejectsBehaviorGroupsOwnersFlagsAndAliasesAtomically` executed
  through the linked product and returned total `1`, passed `0`, failed `1`,
  skipped `0` at
  `Saved/Tests/cache-b2-behavior-producer-red/20260809_111447_046_077c5b75`.
  This is trustworthy B2 Behavior RED, but B2 remains open until the entire eleven-
  method `NormalProducer...` prefix executes.
- Evidence ceiling: B5 focused Behavior GREEN, B6 Behavior RED and one B2 Behavior-
  producer RED. No B2/B3/B6/B7/C2 completion, Store, PIE, package or Shipping
  acceptance is claimed.

## B2 complete mixed RED and shared B3/B6 Behavior GREEN — 2026-08-09

- The first complete linked producer run exposed three test-authority crashes,
  not legitimate semantic RED: invalid metadata invoked the valid-fixture
  finalizer, seven array mutations self-aliased their source element, and the
  test-only physical writer dereferenced an intentionally absent union arm.
  IC-198/199 preserve the exact failures and linked repairs. After those repairs,
  the then-materialized nine methods produced a stable `0/9` RED at
  `Saved/Tests/cache-b2-typeschema-normal-producer-red-4/20260809_112858_084_e909c532`.
- IC-197 reconciled source with the eleven-method audit. The exact prefix at
  `Saved/Tests/cache-b2-eleven-normal-producer-red/20260809_113425_474_134b2368`
  discovered `11`, passed `1`, failed `10`, skipped `0`; no failure was a crash,
  check, unresolved symbol or timeout. B2 is complete at this trustworthy mixed
  RED boundary.
- A sole shared Behavior validator was then added. Initial producer Behavior
  GREEN was reached at
  `Saved/Tests/cache-b3-behavior-producer-focused-2/20260809_114125_015_c285a3ce`,
  but decoder diagnostics still guessed `KindPayload` byte `362`. IC-200 added an
  optional internal failure coordinate without changing the resolver-free public
  producer signature.
- Exact-coordinate runs then exposed and repaired Environment-owner precedence,
  a statics test conflict with the already-frozen first-physical-row rule and the
  distinction between detection row and proving row. The decoder Behavior product
  passed at
  `Saved/Tests/cache-b6-behavior-product-green/20260809_115259_085_64aeb7d9`;
  all four focused decoder methods passed at
  `Saved/Tests/cache-b6-behavior-four-method-green/20260809_115600_913_d9cd757e`.
- IC-203 subsequently split the implementation into field-local and cross-field
  phases. Field-local Behavior validation performs no Reflection look-ahead;
  statics/cardinality/count/alias/flag closure runs after Dependencies field-local
  validation. This exposed IC-204: Copy ABI mismatch is necessarily the earlier
  Dependency `ConflictingKey`, not an alias-closure error. After the test-authority
  correction, the combined four decoder methods plus normal producer Behavior
  method passed `5/5`, failed `0`, skipped `0` at
  `Saved/Tests/cache-b3-b6-behavior-phase-split-green-2/20260809_120235_410_1be0ff56`.
  Its linked build is
  `Saved/Build/cache-b3-b6-dependency-before-alias-linked/20260809_120215_108_6bcca30a`.
- The complete producer prefix after this first B3 family reports `11` total,
  `2` passed, `9` failed and `0` skipped at
  `Saved/Tests/cache-b3-normal-producer-progress/20260809_115708_767_537ef85e`.
  The two GREEN methods are Behavior and frozen-hash/resolver independence; the
  remaining nine failures are the truthful B3 implementation backlog.
- B5 was rerun after shared-validator and coordinate changes. The exact five-method
  set remains `5/5` GREEN at
  `Saved/Tests/cache-b5-physical-regression-green/20260809_115744_789_776dd23c`.
- Source identities at this pre-Dependency-split evidence point are Runtime SHA
  `BC2841B44A965EEA97F15F3990CA0E53BF2129FBE0A8C23F64755ACE0DD87976`
  (108,998 bytes / 3,440 LF) and test SHA
  `65071FEA1089383B835CD14826D042F3DBD7E177473B0CA123D79932D97C9D16`,
  Git blob `57fd2b0fce3268fd088588aac25f0527ed79ab67`, 687,925 bytes,
  15,832 LF, zero CR, final LF and 65 methods.
- Evidence ceiling: B2 and B5 are complete. B3/B6 are Behavior-slice GREEN only;
  the other nine producer families, exact decoder coordinates/checkpoints, B7,
  C2 behavior, Store, Editor/PIE, packaging and Shipping remain incomplete.

## B3 Header/String/TypeSemanticFlags producer GREEN — 2026-08-09

- The next shared-producer family adds frozen payload-version, nonzero stable-key,
  TypeKind, canonical-string and exact per-kind TypeSemanticFlags validation in
  `ValidateProducerShape`. Type flags reject unknown bits, missing required bits,
  forbidden bits, `Abstract|Final`, `ValueType|ReferenceType`, and constructor /
  destructor behavior mismatch without consulting a resolver.
- The first exact method run at
  `Saved/Tests/cache-b3-header-flags-focused-red/20260809_120658_149_86e24771`
  was legitimate Runtime RED. After the Runtime matrix was added, the remaining
  mismatches were test-observation faults recorded as IC-205: three ineffective
  embedded-NUL fixtures, the malformed-TypeKind physical trace arm, and a
  Delegate negative that inherited Construct from its complete baseline.
- The final linked repair is
  `Saved/Build/cache-b3-header-flags-fixture-fix2-linked/20260809_121449_770_bbe0d936`:
  seven UBT actions compiled and linked Runtime and Test, process/wrapper exit
  `0/0`. The exact focused method then passed `1/1`, failed `0`, skipped `0` at
  `Saved/Tests/cache-b3-header-flags-focused-green-3/20260809_121508_408_8012ea2b`.
- The complete eleven-method producer prefix at
  `Saved/Tests/cache-b3-normal-producer-progress-header-flags/20260809_121545_510_187f063f`
  reports total `11`, passed `3`, failed `8`, skipped `0`. Behavior,
  Header/String/TypeSemanticFlags and frozen-hash/resolver-independence are GREEN;
  the other eight methods are the truthful B3 backlog.
- Because the Runtime test-only physical scanner changed only its malformed
  unknown-discriminator observation path, the full B5 five-method set was rerun.
  `Saved/Tests/cache-b5-physical-after-unknown-kind-green/20260809_121630_317_2699ef2d`
  reports `5/5` PASS, zero failed/skipped.
- Current source identities are Runtime SHA
  `C91EEA8E22F17537AFEC54ED992B5B847E881A660D4626A5E2678751D5582803`,
  Git blob `826279fee38ed2e5f6cf0a95d2fa86b64ef99be8`, 112,132 bytes,
  3,526 LF, zero CR and final LF; test SHA
  `7EA1B759F2424D617D9E4F0CB25E003E326E483F50F2A4EBA8FAD304C022FAB0`,
  Git blob `116fec63b48348dc1e0ebc44d6ba9308950b7cb0`, 688,447 bytes,
  15,845 LF, zero CR, final LF and 65 methods.
- Evidence ceiling: this advances B3 by one producer family. Header/flag decoder
  coordinate/checkpoint behavior is still B6 work; eight producer families, B7,
  B4/B8 onward, C2 behavior, Store, Editor/PIE, packaging and Shipping remain
  incomplete.

## B3/B6 shared Relations GREEN — 2026-08-09

- Runtime now has one shared Relations rule owner split into field-local and
  post-Dependencies cross-field passes. It validates relation kind/reference,
  canonical rows, duplicate targets, interface ordinals, the eleven-form
  cardinality matrix and the ordinary-`UClass` Shadow/Code coordinate without a
  producer resolver.
- The focused producer method covers `195` calls. The final log records
  `matrix=165`, `focused=30`, `wrong-reference=16`, `total=195`.
- The decoder product covers all `11 forms x 5 relation kinds x 3 cardinalities x
  3 reference kinds = 495` cells. Its final log records `167` expected-success
  cells and `328` expected-failure cells. Each failure assertion retains
  form/kind/cardinality/reference plus actual error/stage/offset context, but the
  passing run emits only aggregate lines.
- IC-206 records why two intermediate cells correctly failed earlier in
  Dependencies: the fixture used an incomplete comparator and then created a
  Statics-only duplicate environment target. Both were test-only repairs; Runtime
  phase order and canonical dependency semantics were preserved.
- The final five-method producer/decoder set reports `5/5 PASS` at
  `Saved/Tests/cache-b3-b6-relations-structured-green/20260809_125251_480_9d10a235`.
  Its linked build is
  `Saved/Build/cache-b6-relations-structured-logs-linked/20260809_125232_234_9d8fb5ae`.
- The full eleven-method producer prefix now reports `4/11 PASS`, seven expected
  implementation failures, at
  `Saved/Tests/cache-b3-normal-producer-progress-relations/20260809_124905_758_a5c519a1`.
- The correct historical Behavior set remains `5/5 PASS` at
  `Saved/Tests/cache-b3-b6-behavior-after-relations-green-2/20260809_125105_450_15079206`.
  An earlier `4/5` command mistakenly included the future Method/VFT method and is
  explicitly not a Behavior regression.
- The first B5 rerun outlived a five-second tool-parent timeout and independently
  wrote five UE successes plus `Report/index.json`. The identical standard rerun
  completed its wrapper and reports `5/5 PASS` at
  `Saved/Tests/cache-b5-physical-after-relations-green-2/20260809_125645_939_761a4a12`.
- Current identities are Runtime SHA
  `8B61282B213D1D2E90587AADF9275CA1C8B18BD56C51018F7205C7E131C729F4`,
  Git blob `e91d019243cc7b685d4f552d747dd462a07a8a43`, 121,834 bytes,
  3,814 LF; test SHA
  `BE7188DA18DF1BB4FCEC811A3F5F2344BD101157C2C9BC2F42E389980B4682B5`,
  Git blob `1258600c7616566f4ccf2a7759754fe9693d7355`, 691,742 bytes,
  15,928 LF, zero CR, final LF and 65 methods.
- Evidence ceiling: Relations advances B3/B6 but does not close either task.
  `LayoutInputs` and the other six producer families, B7 derived hashes, C2
  behavior, Store, Editor/PIE, packaging and Shipping remain incomplete.

## B3/B6 shared LayoutInputs GREEN — 2026-08-09

- The trustworthy producer RED at
  `Saved/Tests/cache-b3-layoutinputs-focused-red/20260809_130126_064_0201a885`
  executed all `100` scenarios and failed normally; no crash, check, timeout or
  unresolved symbol was counted as RED.
- Shared Runtime validation now covers raw roles, stable reference kinds,
  contribution masks, range/alignment, row hashes, canonical singleton rows,
  form-role presence and Relation pairing. Producer and decoder share the same
  rules and optional logical failure coordinate.
- IC-207 preserves two Dependency-precedence corrections and exact decoder
  coordinate corrections. Final producer logging records all `100` calls;
  decoder logging records `36` role/mask/target/missing cells, `5` focused
  presence cells and `11` exact form/pair/order/hash failures.
- IC-208 preserves a test-only `TArray` self-alias assertion. The crash artifact
  is not semantic evidence; the local-copy repair passed the exact method.
- The final LayoutInputs set passed `4/4` at
  `Saved/Tests/cache-b3-b6-layoutinputs-structured-final/20260809_132735_879_327c67af`.
  Its producer log reports:
  `legal=13 raw-kind=3 missing=5 extra=34 wrong-role=3 pairing=6
  dependency-precedence=2 optional-mask=12 zero-key=3 missing-abi=3
  wrong-reference=6 invalid-alignment=4 overflow=5 stale-hash=1 total=100`.
- The first combined old-slice regression was `14/15`; IC-209 proves this was an
  old Relations Cartesian fixture containing new LayoutInput co-faults. Two
  exploratory Runtime phase changes were rejected and reverted. After the
  malformed fixture was made hash-self-consistent with at most one role-valid
  LayoutInput companion, the exact Relations method again covered all `495`
  cells (`167` success / `328` expected failure) at
  `Saved/Tests/cache-b6-relations-isolated-layout-fixture-green/20260809_132624_956_445b1450`.
- The full Relations five, Behavior five and B5 physical five regression passed
  `15/15`, failed `0`, skipped `0` at
  `Saved/Tests/cache-b3-b5-b6-after-layoutinputs-regression-final/20260809_132701_941_ccd52550`.
- The current eleven-method producer prefix reports `6/11 PASS`, five expected
  implementation failures and zero skipped at
  `Saved/Tests/cache-b3-normal-producer-progress-layoutinputs-final/20260809_132853_348_ee69f1be`.
  The remaining methods are Dependency, KindPayload/Enum/Callable/Typedef,
  Method/VFT, Property/LayoutReplay and Reflection.
- Current source identities are Runtime SHA
  `958BA18F5F867AD0E2938FADAF5CB1BC4F71B8A9E531E25E890EAC8E48B8D76F`,
  Git blob `0183b8de3a73eb889c15edf3ac623232793ffd00`, 133,627 bytes,
  4,173 LF, zero CR and final LF; test SHA
  `3E458B206CD01E539FB8A1D22A80D498BDDE496F7DE4D1B0526B732444E29CEC`,
  Git blob `fe94a1b077448ce4eb9269ee502dba00d831d27f`, 703,160 bytes,
  16,196 LF, zero CR, final LF and 66 methods.
- Evidence ceiling: LayoutInputs advances B3/B6 but closes neither. B7
  current-layout/property/enum/final-hash behavior, C2, Store, Editor/PIE,
  packaging and Shipping remain incomplete.

## V0 vertical execution OpenSpec refactor — 2026-08-09

Scope and evidence ceiling:

- This is OpenSpec/documentation evidence only. It changes no Runtime/Test source,
  stable identity, wire byte, error number, ownership, publication or StaticJIT
  Provider contract and supplies no new Cache behavior/build/test claim.
- `vertical-execution-refactor-2026-08-09.md` records the accepted actual-needs
  composition: module source/declaration authority, function-level identity and
  compiler reuse, module-atomic activation and per-function StaticJIT routes.
- `design.md` and the incremental delta spec now distinguish directly observable
  source/action inputs from bounded persisted preprocess-derived candidates. A
  candidate mismatch runs the existing authoritative preprocessor; exact lookup
  does not rerun it to reconstruct the dependency graph.
- The final per-function `FunctionInputDigest` hit requirement remains. Forced-
  clean compilation is documented only as fallback and clean-vs-cached oracle.

Historical preservation evidence:

| Archived file | SHA-256 | Bytes | Result |
|---|---|---:|---|
| `history/pre-vertical-refactor-2026-08-09/implementation-plan.md` | `78CCD84C37479370D4D32F6503C0906F6F7847C2495502E09CE4973360F4B8CE` | 65,592 | Byte-equal copy verified before root rewrite. |
| `history/pre-vertical-refactor-2026-08-09/tasks.md` | `9C4777B28E76E32CB2C29B44018EC579987B8C90E6D848AA235F39DCFD54CCD4` | 13,492 | Byte-equal copy verified before root rewrite. |
| `history/pre-vertical-refactor-2026-08-09/status.md` | `1BF9E0A0AD6F0787192B98C8A5B76589543867ACEE1519DC9E44C75205B30EE2` | 28,686 | Byte-equal copy verified before root rewrite. |

Validation evidence:

```text
openspec status --change refactor-as-incremental-function-cache
    Schema: spec-driven
    Progress: 4/4 artifacts complete

openspec validate refactor-as-incremental-function-cache --strict
    exit 0
    Change 'refactor-as-incremental-function-cache' is valid
```

A separate exact-path check confirmed the vertical decision, current plan/tasks/
status/traceability, both affected delta specs, sibling StaticJIT design and the
new history README all exist. The archive hashes above were recomputed and matched.

Final key document identities after the V0 close:

- vertical decision: `F994E48CBE1E3EF63F2A0D3550B7CFDE7EE6184E36D6E4AC012FB0ED6F5EC11F`;
- design: `8996617025F88FC492A4A7439E3300932E7A3069CDF58DC71B515689BE518B45`;
- implementation plan: `0F0F67EE4A6FF0CCA818F0DFE7DEEAD4D4AE4B82B5E697151AA8D024100DC04E`;
- tasks: `906CAFDC8EFA98E4E6D628F7337413BCF4ACFE22AA3BA9ACCBCB3E188F1F80A3`;
- status: `F8C04EB0AD8C6752EFC4992DD6F18C1ED6DB6DE9E2D662038B2800DCBF707E2A`;
- incremental delta spec: `8C1A8CD2DDF10D337B9E948A077FA62BAB92A85F990FDA1040398ACD9BC9C4EE`.

V0.3 is therefore documentation GREEN. V1.1 remains the next Runtime/Test task:
build the split Dependency test TU, execute its intended RED and implement the thin
shared five-kind closure. No Runtime evidence is inferred from V0.

## V1.1 exact TypeSchema Dependency closure GREEN — 2026-08-09

Implementation boundary:

- `ValidateDependencyCrossFieldClosure` derives exactly `Inheritance`,
  `ValueLayout`, `Declaration`, `Signature` and `EnvironmentAbi` from the decoded
  TypeSchema DTO. It linearly scans existing arrays, recursively visits property
  data types and allocates no dependency index or graph database.
- Relations and LayoutInputs reuse the same stored target coordinate; methods, VFT,
  reflected functions and script-owned behaviors share Declaration coordinates;
  callable payloads use Signature; environment relations/layout inputs/behaviors use
  EnvironmentAbi. Module target existence/ownership/ABI resolution remains outside
  this local pass.
- A missing row returns `MissingCoverage` at the captured Dependencies array-count
  offset. An extra row returns `UnexpectedRecord` at its indexed physical Dependency
  row. A stored row with the same kind/reference/key but different ABI returns
  `ConflictingKey`.

Build and focused behavior evidence:

- Initial full linked implementation build:
  `Saved/Build/cache-v11-dependency-closure-linked/20260809_150004_480_dc1a4691`,
  `21/21` UBT actions, Runtime/Test DLLs linked, process/wrapper `0/0`.
- IC-212 fixture repair build:
  `Saved/Build/cache-v11-dependency-fixture-alias-fix-linked/20260809_150224_507_84dd3381`,
  `4/4` actions, `0/0`.
- Producer focused GREEN:
  `Saved/Tests/cache-v11-dependency-producer-green-2/20260809_150242_568_606a7080`,
  total `1`, passed `1`, failed/skipped `0`; log totals are
  `legal=4 structural=4 missing=6 extra=2 total=16`.
- IC-213 coordinate repair build:
  `Saved/Build/cache-v11-dependency-decoder-coordinate-fix-linked/20260809_150414_143_c42f51cc`,
  `4/4` actions, `0/0`.
- Decoder focused GREEN:
  `Saved/Tests/cache-v11-dependency-decoder-green-2/20260809_150428_828_96482e94`,
  total `1`, passed `1`, failed/skipped `0`; log totals are
  `required=5 excluded=6 total=11`.

Diagnostic broad-prefix evidence and ceiling:

- `Saved/Tests/cache-v11-typeschema-regression/20260809_150512_262_37013fb7`
  is not a pass artifact. It exposed IC-214 fixture synchronization debt and ended
  at the static serialization `check` on line 4883, so no complete report totals
  exist. It is retained because it proves the exact closure is now reached by old
  fixtures and identifies the next V1.2 repair boundary.
- V1.1 is GREEN only for exact local Dependency set equality and its linked
  producer/decoder surface. Remaining TypeSchema rules, record codecs, graph,
  real-module capture, Pack/Store, Editor/PIE, packaging and Shipping remain open.

## V1.2 Method/VFT local family GREEN — 2026-08-09

- Trustworthy current RED:
  `Saved/Tests/cache-v12-method-vft-red-current/20260809_150951_210_470de67f`;
  the exact method executed and failed normally across its producer call table.
- Runtime now validates OrderedMethods and VirtualFunctionTable independently:
  raw enum domain; active FunctionKey/ABI/required owners; contiguous ordinal and
  complete-row ordering; TypeKind/reflection role presence; self/nonself owner
  shapes; and per-array duplicate FunctionKey. The same key may still occur once
  in each array because the VM structures are distinct.
- First linked implementation:
  `Saved/Build/cache-v12-method-vft-linked/20260809_151229_389_4e308b06`, `4/4`
  actions and `0/0` process/wrapper. Its focused run isolated IC-215 to four
  row-reorder classifications.
- Final linked repair:
  `Saved/Build/cache-v12-method-vft-order-fix-linked/20260809_151341_950_6550f3c5`,
  `4/4` actions and `0/0`.
- Final focused behavior:
  `Saved/Tests/cache-v12-method-vft-green-2/20260809_151353_838_c537f546`, total
  `1`, passed `1`, failed/skipped `0`. Source assertions cover `121` calls:
  `20` success and `101` failure controls.
- Evidence ceiling: this is one V1.2 family. KindPayload/Reflection,
  Property/Layout replay, remaining decoder-coordinate regressions, record codecs,
  graph and all persistent/runtime lifecycle stages remain open.

## V1.2 KindPayload local family GREEN — 2026-08-09

- Trustworthy current producer RED:
  `Saved/Tests/cache-v12-kindpayload-red-current/20260809_151521_913_78bbf65b`,
  total `1`, passed `0`, failed `1`. It isolated callable ABI classification,
  Funcdef multicast and primitive-only Typedef gaps while selected/inactive arm
  presence already matched.
- The shared producer/decoder local path now requires nonzero callable key and ABI
  with distinct errors, forbids Funcdef multicast, and admits only an unqualified
  non-Void primitive Typedef with no subtype rows.
- First linked implementation:
  `Saved/Build/cache-v12-kindpayload-linked/20260809_152249_816_61c6d939`, `4/4`
  actions and process/wrapper `0/0`.
- Final producer behavior at the current source:
  `Saved/Tests/cache-v12-kindpayload-green-final/20260809_153103_544_3cd8dd93`,
  total `1`, passed `1`, failed/skipped `0`.
- Selected-arm regression:
  `Saved/Tests/cache-v12-kindpayload-seven-kinds-regression/20260809_152349_199_61c02c56`,
  total `1`, passed `1`, failed/skipped `0`.
- IC-217 then closed the retained Enum replay boundary. The first decoder run
  `Saved/Tests/cache-v12-kindpayload-enum-regression/20260809_152425_719_8d34757c`
  was RED. The intermediate run
  `Saved/Tests/cache-v12-kindpayload-enum-green-1/20260809_152831_493_cf08559d`
  reduced to the missing EnumAuthorityHash coordinate. Final linked repair:
  `Saved/Build/cache-v12-kindpayload-enum-coordinate-linked/20260809_152922_342_59c42037`,
  `4/4` actions and process/wrapper `0/0`; final decoder
  `Saved/Tests/cache-v12-kindpayload-enum-green-2/20260809_152935_082_d2a1374a`,
  total `1`, passed `1`, failed/skipped `0`.
- Current Runtime identity is SHA-256
  `1242CEE38BE76397A12C1E63452C2CD2A06B53FF24B1802D461C38247D30C93B`,
  Git blob `8b8bc91bbc270eb9b6394cc858e6a4c11ecc774a`, `157078` bytes and
  `4866` lines.
- Evidence ceiling: KindPayload is GREEN for the focused producer, selected-arm
  and retained Enum decoder surfaces. The adjacent Typedef/Funcdef regression is
  deliberately not claimed GREEN: it reaches open IC-218 fixed descriptor layout.
  Reflection, Property/Layout, record codecs, graph, Store, warm restore and real
  runtime lifecycle remain open.

## V1.2 fixed descriptors and Property/Layout producer GREEN — 2026-08-09

- IC-218 fixed descriptor implementation linked at
  `Saved/Build/cache-v12-descriptor-layout-linked/20260809_153910_182_97116e37`,
  `4/4` actions and process/wrapper `0/0`. The focused Typedef/Funcdef method is
  `1/1` GREEN at
  `Saved/Tests/cache-v12-descriptor-layout-green-1/20260809_153924_766_b14d04d6`;
  prior KindPayload and Enum tests remained `1/1` GREEN independently.
- The dedicated Property/Layout RED is
  `Saved/Tests/cache-v12-property-layout-red-current/20260809_154212_391_e846f174`.
  It executed normally rather than crashing and exposed the missing owner,
  datatype/storage/qualifier, UE flag/replication and layout-replay behavior.
- Runtime now validates property ordinals, active stable keys/names, DataType and
  storage domains, the exact `2 × 4 × 64` qualifier/storage partition, bounded
  storage scalars and stored ends, StorageLayoutHash, access/flags/replication,
  canonical metadata and PropertyLayoutFingerprint. Cross-field validation then
  applies owner/reflection allowlists and checked Base/header/property cursor,
  exact aggregate alignment, offsets and terminal tail padding without an AS
  Engine, resolver or file dependency analysis.
- Final linked Runtime/Test build:
  `Saved/Build/cache-v12-property-layout-linked-2/20260809_155726_224_028bfcd3`,
  `8/8` actions, process/wrapper `0/0`.
- Final focused behavior:
  `Saved/Tests/cache-v12-property-layout-green-2/20260809_155744_084_8110f9c5`,
  total `1`, passed `1`, failed/skipped `0`. The method's independent ledger is
  `83` success, `577` negative and `660` total normal-producer calls.
- The intermediate RED and adjacent regression exposed two IC-214 fixture repairs:
  changed Script/Environment property types needed exact `ValueLayout`
  Dependencies, and a hostile Funcdef property needed its owner-sensitive
  PropertyLayoutFingerprint recomputed so the intended form error could win.
  Final fixture relink:
  `Saved/Build/cache-v12-property-layout-fixture-linked/20260809_155954_533_96b81045`,
  `5/5`; final KindPayload/Enum/Typedef-Funcdef regression:
  `Saved/Tests/cache-v12-property-layout-adjacent-regressions-green/20260809_160013_730_1114065a`,
  total `3`, passed `3`, failed/skipped `0`.
- Current Runtime identity is SHA-256
  `6747334397259279FC9D6B87B7D33C4DDEB7E533587CF4C2E3765AC464BBDB94`,
  Git blob `3db467febc1d9c92f513d6604795bb9aca198f3e`, `5378` lines. Current historical
  test TU identity is SHA-256
  `3AFF49838AD7388D038AD48E1332C12C4AA9A6AED9984798A61C77056BD4BA39`,
  Git blob `1c66bb723f81cde882159c06036b9aa14a244ffa`, `16148` lines.
- Evidence ceiling: this closes focused producer Property/Layout and fixed
  descriptor behavior only. Reflection form closure, broad decoder-coordinate
  regression, record codecs/factory/graph, Store, warm restore, Editor/PIE and
  packaged Development/Shipping remain open.

## V1.2 Reflection form/member closure GREEN — 2026-08-09

- Trustworthy RED:
  `Saved/Tests/cache-v12-reflection-red-after-property/20260809_160222_169_044869f4`
  discovered and executed exactly the focused producer method, then failed first
  on a present-empty ordinary-UClass ConfigName. Earlier Property/Layout cases in
  the same method had already passed, so this was a Reflection-specific boundary.
- Runtime now validates ReflectionKind and known/unknown ClassReflectionFlags,
  present nonempty optional strings, explicit ordered UFunction membership,
  contiguous/member order, ScriptFunction target keys/ABI and duplicate target
  keys. The post-Dependencies closure admits only the frozen TypeKind+Reflection
  forms; enforces ordinary Abstract/Super parity; discriminates synthetic statics
  bidirectionally; enforces statics semantic/array/layout/name/member rules;
  requires ordinary StaticClassGlobalName; and keeps Interface/Enum normalized
  layouts fail-closed. Membership is never inferred from nonzero UFUNCTION flags.
- Exact intrinsic Reflection diagnostics append two public captured fields without
  renumbering the old contract: `ReflectionKind=39` and
  `ClassReflectionFlags=40`. The decoded-record alternative stores both as scalar
  optionals, so the existing allocation-family ledger does not gain an array or
  scratch allocation site. Top-level Reflection remains the coordinate for
  form-selected missing rows; indexed UFunction failures use the retained member
  or target row.
- Final linked build:
  `Saved/Build/cache-v12-reflection-property-fixture-linked-2/20260809_163620_976_a19159bf`,
  `5/5` actions, process/wrapper `0/0`. Earlier linked Runtime/header/coordinate
  builds are retained in IC-220/IC-221 for failure chronology.
- Final focused behavior:
  - producer `1/1` GREEN:
    `Saved/Tests/cache-v12-reflection-producer-green-final/20260809_163903_920_04e6649c`;
  - TypeKind/reflection forms and optional strings `2/2` GREEN:
    `Saved/Tests/cache-v12-reflection-form-prefix-green/20260809_162846_644_c86afefe`;
  - all known class-reflection masks across ordinary root/derived, abstract parity,
    statics and UStruct `1/1` GREEN:
    `Saved/Tests/cache-v12-reflection-classmask-green-2/20260809_162253_447_68548931`;
  - ordinary/statics/UStruct independent shape rules `1/1` GREEN:
    `Saved/Tests/cache-v12-reflection-shapes-green-2/20260809_162634_626_ce2df191`;
  - reflected UFunction ordinal/reorder/target shape `1/1` GREEN:
    `Saved/Tests/cache-v12-reflection-members-2/20260809_162709_029_f6337cd7`;
  - public captured-coordinate `0..40` exact/surplus/allocation-free lookup `1/1`
    GREEN:
    `Saved/Tests/cache-v12-reflection-coordinate-matrix-green/20260809_163143_532_75c89f20`.
- Adjacent regression evidence remains independent and GREEN:
  - Property/Layout 660-call producer `1/1`:
    `Saved/Tests/cache-v12-reflection-property-regression-green-2/20260809_163638_609_952dc5ca`;
  - KindPayload producer `1/1`:
    `Saved/Tests/cache-v12-reflection-kindpayload-regression/20260809_163717_204_07f7a6a7`;
  - Enum authority `1/1`:
    `Saved/Tests/cache-v12-reflection-enum-regression/20260809_163755_754_e36582d5`;
  - Typedef/Funcdef descriptor/property rules `1/1`:
    `Saved/Tests/cache-v12-reflection-descriptor-regression/20260809_163830_753_af4eb8df`.
- Diagnostic artifacts not counted as passes:
  - the `+`-joined exact-prefix runner invocation selected zero tests:
    `Saved/Tests/cache-v12-reflection-exhaustive-regression-1/20260809_160821_796_4a3705ab`;
  - the full TypeSchema prefix exposed unfinished families/fixture debt and reached
    an existing static setup `check`:
    `Saved/Tests/cache-v12-reflection-typeschema-full-1/20260809_160914_484_e0d2e07b`;
  - the broader unknown-bit method now passes the new Reflection coordinate but
    stops at open IC-221 PropertySemanticFlags precision (`530` expected versus
    OrderedProperty fallback `427`):
    `Saved/Tests/cache-v12-reflection-unknownflags-green/20260809_163218_355_eb029e45`.
- Current identities: Runtime TypeSchema cpp SHA-256
  `7438E1C8B47456A46A44EEB6E549497C20E46F1967E507F0B4580A3FDCDDE0AD`,
  Git blob `bfee5db23c016d6dbbaba5c7c306d3bd85c53ab3`, `190877` bytes,
  `5773` lines; TypeSchema header SHA-256
  `5B917AC8C9989CEEF6FEF16D89DDB9ADE3DAF6366D10CA672877FF929E6AD7A2`;
  decoded-record cpp/header SHA-256
  `D59EA5EDBA32E6A421FBC2BF1A1FDEC1DE2DA1637C6981B0017A99C455D55DC3` /
  `9479738E771804153F7A790F4D8E792701D6571075B13861F63DB42A8DC0C056`;
  test TU SHA-256
  `7682DD84C37D7CE56648A5F5DCBDEBCD76831155EF5ECF05418A97492967F82B`,
  Git blob `dde095a489930a674ceca167ffc1333367090119`, `702785` bytes,
  `16191` lines.
- Evidence ceiling: IC-220 closes record-local Reflection semantics only. IC-221
  subfield-coordinate breadth, declaration owner/entity graph resolution, record
  codecs/factory, ModuleSnapshot, Store, warm restore, compiler attachment,
  Editor/PIE lifecycle and packaged Development/Shipping remain open.

## V1.3 DebugSidecar remaining-record codec RED — 2026-08-09

- Test-first source:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheRemainingRecordCodecTests.cpp`
  adds one focused desired-behavior method for canonical DebugSidecar production,
  RecordId construction, sole-factory decode, exact wire offsets, typed immutable
  access and one aggregate Budget promotion.
- Full target RED:
  `Saved/Build/cache-v13-debugsidecar-red/20260809_165443_633_749c63df`.
  UE 5.8 Development `AngelscriptProjectEditor` reached the new test TU and failed
  only because `FAngelscriptCacheRemainingRecordArchive`,
  `TryBuildLogicalSectionKey` and `SerializeDebugSidecar` do not yet exist. UBT
  process exit was `6`; wrapper exit was `1`.
- RED interpretation: this is the intended missing-behavior failure. It proves the
  declaration-only DTO/factory surface cannot satisfy V1.3 by itself; no GREEN or
  runtime behavior is claimed yet.

### First DebugSidecar GREEN

- Full UE 5.8 Development Editor link:
  `Saved/Build/cache-v13-debugsidecar-green-attempt-1/20260809_165900_174_bce8b948`,
  `12/12` actions, process/wrapper `0/0`.
- Focused Automation:
  `Saved/Tests/cache-v13-debugsidecar-focused-attempt-1/20260809_165927_611_9530401b`,
  total `1`, passed `1`, failed/skipped `0`. The runner used
  `UnrealEditor-Cmd.exe`, NullRHI and a full engine initialization; it is not a GUI
  Editor Cache lifecycle or cold/warm launch test.
- Behavior proven: one canonical DebugSidecar serializes to exactly `191` bytes,
  recomputes a DebugSidecar RecordId, decodes through the sole immutable factory,
  exposes only the DebugSidecar alternative, retains the exact fixture field
  offsets, and leaves `TemporaryResidentDecodedBytes=0` with total equal to
  retained resident bytes after the single promotion.
- Post-GREEN audit found IC-223: a semantic-only inline offset scratch array could
  spill beyond four sources without Budget charge. It has been removed in source;
  this first artifact predates that refactor and is not its regression evidence.

### Scratch-free DebugSidecar and ModuleSnapshot GREEN

- IC-223 regression build:
  `Saved/Build/cache-v13-debugsidecar-scratch-free-linked/20260809_170237_024_7d2f919b`,
  `4/4`; focused test:
  `Saved/Tests/cache-v13-debugsidecar-scratch-free-green/20260809_170252_850_37a2e695`,
  `1/1`. The semantic pass now reads exact source offsets directly from the
  candidate-charged captured-offset array and owns no spillable scratch copy.
- ModuleSnapshot TDD RED:
  `Saved/Build/cache-v13-modulesnapshot-red/20260809_170435_131_f36124bd`.
  The full Editor target reached the new test TU and failed only because
  `SerializeModuleSnapshot` was intentionally absent; process/wrapper exit was
  `6/1`.
- ModuleSnapshot linked GREEN:
  `Saved/Build/cache-v13-modulesnapshot-green-attempt-1/20260809_170842_448_f54fd5ab`,
  `10/10`, process/wrapper `0/0`; combined focused Automation:
  `Saved/Tests/cache-v13-modulesnapshot-focused-attempt-1/20260809_170905_999_69ffc0bd`,
  total `2`, passed `2`, failed/skipped `0`.
- ModuleSnapshot behavior proven: the one-type/one-body fixture serializes to
  exactly `304` bytes; all required module/type/function links round-trip through
  the same immutable factory; every public `0..24` occurrence used by the fixture
  resolves to its exact byte; and the complete candidate promotes with zero
  temporary bytes left. Header offsets are in-controller fixed storage while type
  and function link offsets use two independently preflighted arrays, so the
  decoder never grows and replaces one retained offsets allocation mid-record.
- Evidence ceiling: record-local graph links are validated for key presence,
  redundant module ownership, linked record kind and canonical set shape only.
  Referenced-record existence, coverage and cross-record equality remain V1.4.

### FunctionBody compile RED

- Test-first source: the same remaining-record codec TU adds
  `FunctionBodyRoundTripsExecutionIdentityAndOptionalDebugLink`, requiring the
  frozen V1 field order, an exact `310`-byte zero-dependency/present-sidecar
  fixture, locally recomputed execution hash, typed DebugSidecar RecordId, exact
  captured occurrence offsets and aggregate promotion through the sole factory.
- Full Editor-target RED:
  `Saved/Build/cache-v13-functionbody-red/20260809_171137_521_eda0e024`.
  UE 5.8 Development compilation reached the new method and failed only because
  `FAngelscriptCacheRemainingRecordArchive::SerializeFunctionBody` is absent;
  UBT/wrapper exit was `6/1`.
- RED interpretation: the intended missing producer API is now independently
  observable. No FunctionBody GREEN, graph validation, opaque-codec validation,
  compiler attachment, Store or Editor cold/warm behavior is claimed by it.

### FunctionBody GREEN and debug-absence identity

- First linked FunctionBody build:
  `Saved/Build/cache-v13-functionbody-green-attempt-1/20260809_172234_113_f0f66ec3`,
  `12/12`, process/wrapper `0/0`; first remaining-record run:
  `Saved/Tests/cache-v13-functionbody-focused-green-attempt-1/20260809_172304_894_1a16834f`,
  total `3`, passed `3`, failed/skipped `0`.
- The normative shared `BuildFunctionDebugAbsentHash(ProfileKey)` API then received
  a deliberate golden-vector RED at
  `Saved/Tests/cache-v13-debug-absence-golden-red/20260809_172546_372_e9e58246`.
  The only failure was the placeholder expectation; the logged frozen values were
  Editor `99bb2d1ff43783d9e797ad35d5607db87ca8e13a09446a0c03f725adcdc7ccc0`
  and Shipping `24c6faa88ee73a59682e8e4513c425b97c33c887c639fd4d90f9861cb91707e9`.
- Final linked build:
  `Saved/Build/cache-v13-functionbody-dependency-absence-linked/20260809_172627_054_33820903`,
  `4/4`; combined remaining-record plus exact identity-vector run:
  `Saved/Tests/cache-v13-functionbody-dependency-absence-green/20260809_172650_214_a4a65f89`,
  total `5`, passed `5`, failed/skipped `0`.
- Behavior proven: present and absent sidecar shapes; exact `310`/`443` byte wires;
  local execution-hash recomputation; profile-specific absence distinct from an
  empty present-debug payload; canonical dependency sorting; exact optional
  occurrence lookup; byte-identical reserialization; one/two reference counts;
  and `BudgetExceeded` at byte `344` with candidate temporary bytes rolled back.
- Evidence ceiling: the VM execution payload remains locally opaque as required.
  Reachable codec invocation, declaration/invocation agreement, dependency
  resolution and DebugSidecar profile/content/source equality remain V1.4.

### Empty ModuleState TDD boundary

- Test-first source adds
  `EmptyModuleStateRoundTripsThroughSoleFactoryWithExactTopLevelOffsets` and calls
  the previously absent `ComputeModuleStateInputHash` and `SerializeModuleState`
  APIs.
- Full Editor-target RED:
  `Saved/Build/cache-v13-modulestate-empty-red/20260809_173025_142_2b6c63e6`.
  Compilation reached the new test and failed only on those two missing APIs;
  UBT/wrapper exit was `6/1`.
- Linked GREEN:
  `Saved/Build/cache-v13-modulestate-empty-green-attempt-1/20260809_173447_638_18b4276d`,
  `10/10` actions. Focused Automation:
  `Saved/Tests/cache-v13-modulestate-empty-focused-green/20260809_173513_934_4c38af0c`,
  total `5`, passed `5`, failed/skipped `0`.
- Behavior proven: the empty DTO computes a domain-separated StateInputHash,
  serializes to exactly `124` bytes, decodes through the sole factory, exposes all
  ten exact top-level coordinates, consumes zero stable references and promotes
  with temporary candidate bytes returned to zero.
- Evidence ceiling: `ValidateEmptyModuleState` intentionally rejects every
  non-empty global/hard-value/initializer/action/post-init/dependency collection.
  Nested captured-offset ownership, semantic validation and representative state
  capture are not implemented. IC-225 must be closed before a non-empty fixture
  can establish the GlobalStorage fingerprint contract.

### IC-225 GlobalStorage content and ModuleInterface ABI separation

- The public dependency matrix test was changed first so kind `7`
  GlobalStorage requires a present nonzero content fingerprint. The corrected
  class-level invocation produced the intended RED at
  `Saved/Tests/cache-ic225-presence-red-class/20260809_174710_095_e9cb9bd4`,
  `AngelscriptCacheArchivePrimitiveTests.cpp:495`.
- An independent SourceInterface method requires three facts in one production
  path: GlobalStorage content is admitted; changing only that content preserves
  InterfaceAbi; changing the stable target's ExpectedAbi changes InterfaceAbi.
  Its intended RED is
  `Saved/Tests/cache-ic225-interface-abi-red/20260809_174751_885_9024d4b7`,
  total `1`, failed `1`, at line `3847` because the old presence matrix rejected
  the first content-bearing row.
- Production now treats GlobalStorage as content-bearing in SemanticRecords,
  TypeSchema and remaining-record validators, while
  `DependencyContributesToInterfaceAbi` independently selects ABI-bearing kinds.
- Full UE 5.8 Development Editor link:
  `Saved/Build/cache-ic225-global-storage-green-attempt-1/20260809_174907_150_133df63c`,
  `6/6`, process/wrapper `0/0`.
- Exact presence GREEN:
  `Saved/Tests/cache-ic225-presence-green/20260809_174920_425_40ddc55d`,
  total `1`, passed `1`; exact ABI-isolation GREEN:
  `Saved/Tests/cache-ic225-interface-abi-green/20260809_174955_876_86a8dc23`,
  total `1`, passed `1`.
- Verification boundary: the first attempted method prefix omitted CQTest's
  generated class segment and matched no tests; IC-226 records that invocation
  defect. The class-level RED also exposed the independent IC-227 allocator test
  failure, so the broad primitive class is not claimed GREEN.

### IC-228 u64 remaining-record byte payload primitive

- Frozen common wire says byte payloads use a `u64` count, while the private
  remaining-record `FWriter` and the two implemented decoders used the generic
  `u32` array primitive. Existing exact expectations were changed first from
  `191/310/443` to `195/314/447`, including every downstream FunctionBody field
  coordinate and the bounded-reference failure offset.
- Test-first linked Editor build:
  `Saved/Build/cache-ic228-byte-payload-red-linked/20260809_175542_547_b299bc1b`,
  `4/4`. Intended family RED:
  `Saved/Tests/cache-ic228-byte-payload-red/20260809_175601_571_69156f1c`,
  total `5`, passed `2`, failed `3`; the failures were exactly DebugSidecar and
  the two FunctionBody cases containing opaque byte payloads, while empty
  ModuleState and ModuleSnapshot remained GREEN.
- Production now writes byte payload length with `WriteUInt64` and reads it with
  one dedicated `ReadByteArrayCountAndReserve` that checks the u64 count against
  configured element Budget, `int32` owning-container representation, remaining
  physical bytes and the same pre-allocation decoded charge sink. Strings and
  semantic arrays remain u32; artifact identity hash streams are unchanged.
- Final linked Editor build:
  `Saved/Build/cache-ic228-byte-payload-green-linked/20260809_175723_269_843f16b5`,
  `9/9`, process/wrapper `0/0`; complete RemainingRecordCodec Automation:
  `Saved/Tests/cache-ic228-byte-payload-green/20260809_175745_478_bbb3f93f`,
  total `5`, passed `5`, failed/skipped `0`.

### Representative non-empty ModuleState test-first frontier

- A dedicated `AngelscriptCacheModuleStateCodecTests.cpp` now contains the first
  representative non-empty ModuleState fixture. It exercises one global, hard
  value, initializer, initialization action, post-init function and five
  canonical dependencies, and freezes the expected `1075`-byte wire, exact
  nested captured offsets and bounded stable-reference count.
- Fresh official Editor-target RED:
  `Saved/Build/cache-v13-modulestate-representative-red/20260809_180402_045_138d55bf`.
  Runtime compiled and linked; the test module then failed only on the three
  intentionally absent producer APIs:
  `ComputeGlobalStorageLayoutFingerprint`,
  `ComputeGlobalConstantHardValueHash` and
  `ComputeInitializerExecutionHash`. UBT/wrapper exits were `6/1`.
- RED interpretation: the test fixture is compiler-reachable and the next
  production boundary is exact. Non-empty ModuleState serialization, decode,
  local semantic validation and nested captured-offset ownership are not GREEN;
  no Editor Cache V2 lifecycle behavior is implied by this compile-only RED.

### Representative non-empty ModuleState GREEN — 2026-08-09

- The three public local hash helpers linked first at
  `Saved/Build/cache-v13-modulestate-hash-apis-linked/20260809_181346_201_c9aff717`
  (`11/11` actions). The same compiled test then produced the intended runtime RED
  at `Saved/Tests/cache-v13-modulestate-nonempty-serialize-red/20260809_181412_457_79ac83b6`:
  total `1`, failed `1`, at the former empty-only serializer guard.
- Full non-empty producer/private-decoder implementation linked at
  `Saved/Build/cache-v13-modulestate-full-codec-build-attempt-1/20260809_182641_574_1af6cddd`,
  `5/5` actions. The representative positive method then passed `1/1` at
  `Saved/Tests/cache-v13-modulestate-full-codec-test-attempt-1/20260809_182706_435_d6b079aa`.
  Its diagnostic ledger reports `1075` canonical bytes, one global and five
  dependencies, nine consumed stable references and `6289` retained decoded bytes.
- A separate `AngelscriptCacheModuleStateValidationTests.cpp` keeps new validation
  behavior out of the historical large TypeSchema TU. Its first linked run at
  `Saved/Tests/cache-v13-modulestate-validation-red/20260809_183022_969_3ff344dd`
  passed `3/4`; only the deliberate public-helper invalid-input method failed,
  exposing IC-229. After the shared local validation fix, the final combined
  `Angelscript.TestModule.Cache.Archive.ModuleState` prefix at
  `Saved/Tests/cache-v13-modulestate-focused-green/20260809_183154_140_bfbdfafb`
  passed `5/5`, failed/not-run `0`, process/wrapper `0/0` in `25.731` seconds.
- Behavior proven: all six ModuleState collections round-trip through the sole
  implemented factory alternative; producer insertion order canonicalizes to
  identical bytes; every nested fixture occurrence has an allocation-free exact
  captured coordinate; a nested hash mutation reports that exact byte; trailing
  physical data wins before semantic derived-hash validation; public local hash
  helpers fail closed for malformed DTOs; candidate temporary decoded bytes return
  to zero after the one immutable promotion.
- Evidence ceiling: local uniqueness checks still require a final bounded-complexity
  audit, the negative matrix is representative rather than exhaustive, and the
  record cannot yet prove referenced declaration ownership, keyed coverage or
  EnumAuthority value recomputation. Those are the sole graph authority in V1.4.
  SourceIndex/ModuleInterface factory migration, real clean-module capture, Store,
  warm restore, GUI Editor lifecycle, PIE and package behavior remain open.

## V1.3 SourceIndex/ModuleInterface sole-factory RED — 2026-08-09

- Test-first source:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheSourceInterfaceFactoryTests.cpp`
  adds one focused method with legal minimal SourceIndex and ModuleInterface
  payloads. It requires declared RecordId recomputation, the correct typed const
  accessor, wrong-alternative null access, exact top-level/nested zero-capable
  captured coordinates and one candidate-to-retained Budget promotion for each
  kind.
- The new TU is present in UBT's generated `Module.AngelscriptTest.19.cpp` and
  linked into the current Editor target. The first outer one-second command timed
  out while its UBT child continued, so the later gather artifact is metadata-only
  and is not used as compile evidence; the generated unity/object timestamps and
  successful test discovery prove the method is linked.
- Intended runtime RED:
  `Saved/Tests/cache-v13-source-interface-factory-red/20260809_184227_184_99401c73`,
  total `1`, failed `1`, skipped `0`, at
  `AngelscriptCacheSourceInterfaceFactoryTests.cpp:87`. The test reached the first
  SourceIndex factory success assertion; the current factory still returns its
  explicit `UnexpectedRecord` default for SourceIndex/ModuleInterface. There was
  no crash or helper `check` at the missing-behavior boundary.
- RED interpretation: record-specific serializers still produce valid canonical
  bytes, but the two transitional owning decoders are not an acceptable substitute
  for the sole seven-kind immutable factory. No graph, real module, Store or Editor
  lifecycle behavior is implied.

## V1.3 SourceIndex/ModuleInterface minimal sole-factory GREEN — 2026-08-09

- SourceIndex was first added to the immutable factory and exact captured-offset
  lookup. The full Editor target linked at
  `Saved/Build/cache-v13-source-index-factory-build-attempt-2/20260809_185133_834_7865fc65`
  (`5/5`). The following test run proved every SourceIndex assertion had passed,
  then terminated while constructing an invalid ModuleInterface fixture with an
  unused namespace:
  `Saved/Tests/cache-v13-source-index-factory-intermediate-red/20260809_185147_435_dd36d6ce`.
- IC-230 corrected that fixture without weakening producer validation. The
  corrected target linked at
  `Saved/Build/cache-v13-source-index-factory-linked-fixture-fix/20260809_185259_387_ddc42674`
  (`4/4`), and the rerun produced the intended ordinary ModuleInterface assertion
  RED at line `110`:
  `Saved/Tests/cache-v13-source-index-factory-green-module-interface-red/20260809_185315_946_693ae544`.
- ModuleInterface was then added to the same factory, including retained recursive
  offsets for declarations, canonical data types and their subtype trees,
  parameters, metadata, slots, imports and dependencies. The complete UE 5.8
  Development Editor target passed at
  `Saved/Build/cache-v13-module-interface-factory-build-attempt-1/20260809_185757_474_a35ac144`,
  `13/13` actions, process/wrapper exit `0/0`.
- Final focused Automation:
  `Saved/Tests/cache-v13-source-interface-factory-minimal-green-attempt-1/20260809_185822_378_b92b2f0e`,
  total `1`, passed `1`, failed/skipped `0`, process/wrapper `0/0`.
- Behavior proven: all seven record-kind tags now have a reachable branch through
  `FAngelscriptDecodedCacheRecord::TryDecode`; minimal legal SourceIndex and
  ModuleInterface payloads return the correct typed alternative, reject the wrong
  typed accessor, expose asserted top-level/zero-capable coordinates, preserve
  declared RecordIds and complete one candidate-to-retained Budget promotion with
  candidate temporary bytes returned to zero.
- Evidence ceiling: these are minimal empty/narrow fixtures. Representative nested
  payloads, exhaustive exact diagnostic coordinates, one-byte-short Budget,
  reference-count ownership, handle-copy lifetime, removal of transitional public
  record-specific decoders and the sole graph authority remain open under IC-231,
  IC-232 and V1.4. This evidence does not imply Store, warm restore, Editor GUI,
  PIE, StaticJIT routing or packaged behavior.

## IC-231 common-token exact-fast-path and handle lifetime — 2026-08-09

- A test-first method changed the intended query boundary to
  `QueryExactFastPathEligibility(const FAngelscriptDecodedCacheRecord&, ...)` and
  supplied a decoded ModuleInterface token. The official Editor target produced
  the intended compile RED at
  `Saved/Build/cache-ic231-query-common-token-compile-red/20260809_190746_962_82207746`:
  the test could not convert the common token to the still-required
  `FAngelscriptValidatedSourceIndex` parameter.
- The common-token overload now resets output, checks the actual decoded record
  kind before the module key, emits exact `WrongRecordKind / GraphOrOwnership /
  ModuleGraph / actual-kind / offset 0`, obtains the immutable SourceIndex
  alternative and delegates to the existing canonical query. The old overload is
  retained only as a migration bridge and therefore IC-231 remains open.
- The first linked attempt exposed IC-233 in the historical compile-time API
  assertion:
  `Saved/Build/cache-ic231-query-common-token-green-attempt-1/20260809_190851_515_dc0772b9`.
  After making that old-overload assertion explicit, the complete target passed
  at
  `Saved/Build/cache-ic231-query-common-token-green-attempt-2/20260809_190929_398_5f2a1562`
  (`4/4`) and the initial two-method prefix passed `2/2` at
  `Saved/Tests/cache-ic231-query-common-token-green/20260809_190947_224_39a40b40`.
- A third method then copied the immutable SourceIndex handle, released the
  original optional and executed one eligible exact-fast-path query. The current
  UE 5.8 Development Editor target passed at
  `Saved/Build/cache-ic231-copied-handle-green-attempt-1/20260809_191558_515_38f1d0b7`,
  `4/4` actions with process/wrapper `0/0`. The complete focused prefix passed at
  `Saved/Tests/cache-ic231-copied-handle-green/20260809_191618_730_13b0b101`,
  total `3`, passed `3`, failed/skipped `0`, process/wrapper `0/0`.
- Behavior proven at this boundary: actual wrong-kind precedence and result
  coordinates are exact; rejection leaves every query Budget counter at zero;
  one copied common handle retains its SourceIndex value; a successful query
  charges decoded/scratch work and returns resident/temporary bytes to zero.
  Representative nested records, old decoder removal, exact nested diagnostics,
  graph validation, Store, warm restore and Editor GUI lifecycle remain unproven.

## IC-232 first nested semantic-coordinate slice — 2026-08-09

- A separate
  `AngelscriptCacheSourceInterfaceCapturedOffsetTests.cpp` keeps new exact-offset
  behavior out of the historical large SourceInterface TU. Its first two cases
  mutate canonical payload bytes only after a good common-factory decode ties the
  coordinate to the expected scalar value: provider capability flags keep an
  optional Version fingerprint while clearing its capability bit, and the first
  function parameter ordinal changes from `0` to `1`. Each mutation recomputes
  the declared RecordId so local semantics, rather than RecordId mismatch, is the
  deciding layer.
- The test-first UE 5.8 Development Editor target linked at
  `Saved/Build/cache-ic232-nested-offsets-red-linked/20260809_192109_982_19d17456`,
  `6/6` actions with process/wrapper `0/0`. The intended Automation RED at
  `Saved/Tests/cache-ic232-nested-offsets-red/20260809_192131_980_fcece6f2`
  discovered both methods and failed exactly both offset assertions: SourceIndex
  expected nested byte `250` but received Providers count byte `52`; ModuleInterface
  expected nested byte `293` but received Declarations count byte `92`.
- Production extracted the public captured-coordinate traversal into private
  storage lookup authorities and lends those authorities to semantic preparation
  through allocation-free opaque views. The semantic layer cannot inspect the
  private storage layout or rescan payload bytes, and no second nested offset table
  was added. The provider capability and declaration-parameter ordinal checks now
  select their exact occurrence before returning the existing semantic error.
- The complete target passed at
  `Saved/Build/cache-ic232-nested-offsets-green-attempt-1/20260809_192449_321_79ca5fe1`,
  `13/13` actions, process/wrapper `0/0`. The same focused prefix passed at
  `Saved/Tests/cache-ic232-nested-offsets-green-attempt-1/20260809_192512_241_3ae0062e`,
  total `2`, passed `2`, failed/skipped `0`, process/wrapper `0/0`.
- Evidence ceiling: this proves one SourceIndex nested presence error and one
  ModuleInterface nested ordinal error, exact output reset and zero remaining
  temporary candidate bytes. It does not close IC-232's remaining option, mount,
  hook, file, input, edge, ineligible-scope, declaration datatype/metadata/slot,
  import and dependency coordinates, nor its short-Budget and physical-precedence
  matrix.

## IC-232 derived-key/hash/slot coordinate expansion — 2026-08-09

- The SourceIndex fixture now contains one provider, mount, preprocess hook,
  source file, preprocessor input and source edge. One table mutates the stored
  key of every row after a good common-factory decode and declared RecordId
  recomputation. The ModuleInterface fixture now also contains one function
  declaration with a parameter, metadata and declaration slot, one import and
  one hard-value dependency; its table mutates Declaration StableKey,
  SignatureHash, TraitsHash, ImportKey, declaration-slot ordinal and import-slot
  ordinal.
- The test-first target linked at
  `Saved/Build/cache-ic232-derived-coordinates-red-linked/20260809_192917_183_20287cd5`,
  `4/4` actions, process/wrapper `0/0`. The intended RED at
  `Saved/Tests/cache-ic232-derived-coordinates-red/20260809_192936_858_85607733`
  had total `4`, passed `2`, failed `2`: the two earlier exact cases remained
  GREEN, while both new table methods failed. The first Source mutation expected
  MountKey byte `52` but received Mounts count byte `48`. The first Module
  mutation expected DeclarationStableKey byte `110` but received byte `303`,
  demonstrating a more dangerous stale semantic cursor left by the preceding
  parameter validation rather than merely a parent offset.
- Production collection loops now retain the current row index and select
  ProviderKey, MountKey, HookKey, FileSourceFileKey, InputKey or EdgeKey before
  their derived-key calculation. Declaration validation likewise selects the
  StableKey before identity recomputation and splits the formerly combined
  SignatureHash/TraitsHash mismatch so each stored hash reports itself. Slot
  ordinal prechecks use per-kind expected ordinals for declarations and the
  single required Import ordinal; ImportKey selects its own field before
  recomputation. All selections borrow the same private captured store view.
- The implementation linked at
  `Saved/Build/cache-ic232-derived-coordinates-green-attempt-1/20260809_193239_664_ed026cf0`,
  `4/4` actions, process/wrapper `0/0`. The full focused prefix passed at
  `Saved/Tests/cache-ic232-derived-coordinates-green-attempt-1/20260809_193251_595_795aa712`,
  total `4`, passed `4`, failed/skipped `0`, process/wrapper `0/0`.
- Evidence ceiling: the two table methods contain twelve internal mutations, but
  CQTest counts methods rather than internal rows. They prove the named derived
  keys/hashes/slots and catch stale-cursor reuse; they do not yet prove every
  scalar, option, presence, recursive datatype, metadata, reference, graph,
  canonical-order or Budget/physical-precedence route required to close IC-232.

## IC-231 broad SourceInterface migration diagnostic — 2026-08-09

- The historical SourceInterface tests now compile against Test-module-only
  adapters backed by `FAngelscriptDecodedCacheRecord::TryDecode`; the Runtime
  allocation-capture hook also accepts the common immutable record. The complete
  UE 5.8 Development Editor target passed at
  `Saved/Build/cache-ic231-test-migration-green-attempt-1/20260809_193820_405_9590cb9`,
  `13/13` actions with process/wrapper `0/0`.
- The official broad prefix run is
  `Saved/Tests/cache-ic231-test-migration-broad-attempt-1/20260809_193844_659_50791bc1`.
  It discovered `37` methods: `35` passed, `2` failed, none skipped; the test
  process exited `255` and the wrapper exited `1`.
- `DecodedSemanticFailuresRetainRecordKindAndEnclosingFieldOffset` retained an
  obsolete collection-parent assertion. It expected the Mounts count coordinate
  `151`, while the sole Factory returned exact nested MountKey coordinate `155`.
  This is intended IC-232 behavior and the assertion must be updated to the
  exact occurrence, not production weakened to its parent.
- `EligibilityResultChargesActualOwnedCapacitiesAndRejectsOneByteShort` failed at
  fixture line `3648`: its bounded scan could not find a `TArray<TCHAR>` reserve
  capacity larger than the requested capacity under UE 5.8. It did not construct
  the record or call Cache Runtime. IC-234 tracks a portable replacement that
  still proves actual retained-capacity accounting and one-byte-short rejection.
- All new methods under `SourceInterfaceFactory` and
  `SourceInterfaceCapturedOffsets` passed in the same broad run. IC-231 remains
  open until both fixture/assertion repairs are GREEN and the old Runtime owning
  token/record-specific decoder/query overloads are physically removed with zero
  references.

## IC-231/IC-232 SourceInterface migration GREEN — 2026-08-09

- Replacing allocator-slack discovery with a fixed five-scope fixture linked at
  `Saved/Build/cache-ic231-broad-fixture-fix-build-attempt-1/20260809_194500_584_b83b3960`.
  The historical class run at
  `Saved/Tests/cache-ic231-broad-fixture-fix-focused-attempt-1/20260809_194523_217_ace14921`
  was `29/30`: the capacity/Budget method passed and only the progressively
  tightened semantic-coordinate method remained RED.
- Tightening MountKey (`151 -> 155`) and DeclarationStableKey (`102 -> 110`)
  exposed a third intended RED: the noncanonical declaration case returned stale
  declaration cursor byte `32`. The first exact-order implementation then exposed
  the incorrectly early exact-only slot check as `OrdinalGap=32` instead of
  `NonCanonicalOrder=23`.
- Production now selects the second wire declaration occurrence for declaration
  order failure. Slot ordinals are collected with stable wire-sequence identity
  and validated by slot kind after declaration/import canonical order; duplicate
  ordinals select the second equal wire occurrence and gaps select the actual
  noncontiguous occurrence. Declaration SignatureHash/TraitsHash validation stays
  in the local declaration phase, before owner validation, because slot ordinals
  do not participate in those hashes.
- The affected exact semantic method passed `1/1` at
  `Saved/Tests/cache-ic232-slot-phase-exact-attempt-3/20260809_195206_804_feae7be3`.
  A first broad run then caught local-hash/owner phase regression (`36/37`) at
  `Saved/Tests/cache-ic231-source-interface-broad-green-attempt-1/20260809_195243_172_c67280c7`;
  the final split restored it.
- Final pre-removal evidence is the complete UE 5.8 Development Editor target at
  `Saved/Build/cache-ic232-slot-phase-exact-build-attempt-4/20260809_195435_353_c20cb7cf`
  and the broad prefix at
  `Saved/Tests/cache-ic231-source-interface-broad-green-attempt-2/20260809_195448_341_b7ca8c98`:
  total `37`, passed `37`, failed/skipped `0`, process/wrapper `0/0`.
- Evidence ceiling: this closes IC-234 and the named order/slot/hash phase slice.
  IC-231 still requires physical removal and zero references for the old Runtime
  owning token/deserializers/query overload. IC-232 still requires the remaining
  scalar/options/presence/datatype/metadata/reference/physical/Budget matrix.

## IC-231 sole SourceIndex/ModuleInterface decoder closure — 2026-08-09

- Removed the transitional public `FAngelscriptValidatedSourceIndex`, public
  `DeserializeSourceIndex`/`DeserializeModuleInterface`, validated-token
  `QueryExactFastPathEligibility` overload and test-only
  `DeserializeSourceIndexForTests`. Their private
  `DeserializeSourceIndexInternal`, `ReadSourceIndexPayload` and
  `ReadModuleInterfacePayload` paths were removed with them.
- The authoritative read path is now only
  `FAngelscriptDecodedCacheRecord::TryDecode` ->
  `FDecodedRecordCodecBridge::TryDecodeSourceIndex/TryDecodeModuleInterface` ->
  the captured readers. Serialization and test-gated preserving-order writers
  remain because they cannot publish decoded Runtime state.
- A read-only search over `Plugins/Angelscript/Source` for
  `FAngelscriptValidatedSourceIndex`, both record-specific deserialize names,
  `DeserializeSourceIndexForTests` and both old whole-record reader names returned
  zero references. The retained-path search found only the common Factory bridge,
  captured readers and common-token eligibility query.
- The complete UE 5.8 `AngelscriptProjectEditor Win64 Development` target rebuilt
  Runtime and Test DLLs successfully at
  `Saved/Build/cache-ic231-old-decoder-removal-build-attempt-1/20260809_200152_369_0b946304`:
  `13/13` actions, process/wrapper `0/0`.
- The complete
  `Angelscript.TestModule.Cache.Archive.SourceInterface` prefix then passed at
  `Saved/Tests/cache-ic231-old-decoder-removal-tests-attempt-1/20260809_200226_338_f82c8cd2`:
  total `37`, passed `37`, failed/skipped `0`, process/wrapper `0/0`.
- Evidence ceiling: IC-231 is closed. IC-232 and V1.3 remain open because the
  shallow top-level offset structs still coexist internally with the retained
  exact store, and the full scalar/options/presence/datatype/metadata/reference,
  physical-precedence and Budget matrices have not yet been proved.

## IC-232 sole captured-offset authority refactor — 2026-08-09

- Deleted `FSourceIndexReadOffsets` and `FModuleInterfaceReadOffsets` rather than
  retaining them as a compatibility bridge. A Runtime-source search for either
  type or `ReadOffsets` now returns zero references.
- Captured readers set the physical decoder's enclosing-field cursor directly
  from the current wire position and simultaneously write that position to the
  typed captured store. They no longer copy the same offsets into a second
  top-level struct.
- `PrepareSourceIndex` and `PrepareModuleInterface` now accept only the borrowed
  lookup view over the candidate's captured store. Top-level fallback selections
  use their typed coordinates (`PayloadSchemaVersion`, collection counts,
  `SourceSnapshot`, `InterfaceAbi`) and nested selections continue through the
  same store. Serialization/hash preparation receives no view and therefore keeps
  offset zero for producer-side semantic failures, as before.
- The complete Development Editor target compiled and linked at
  `Saved/Build/cache-ic232-single-offset-authority-build-attempt-1/20260809_200719_041_e051f77e`
  (`4/4`, process/wrapper `0/0`). The complete SourceInterface prefix remained
  `37/37` GREEN at
  `Saved/Tests/cache-ic232-single-offset-authority-tests-attempt-1/20260809_200731_450_5686fc81`.
- Evidence ceiling: this closes the second-offset-model implementation finding,
  not IC-232. Exhaustive coordinate/index coverage, remaining semantic routing,
  physical precedence and AR-SCR-SI/MI retained-allocation rows remain open.

## IC-232 coordinate contract and scalar/reference routing expansion — 2026-08-09

- `CapturedCoordinateEnumsAndEveryIndexShapeAreFrozen` lists every append-only
  SourceIndex field `0..89` and ModuleInterface field `0..88` in contiguous
  compile-time arrays. Against representative decoded records it checks the
  applicable primary/secondary/tertiary index shape for every value, plus wrong
  token kind, invalid/unknown field, missing required index, unused supplied
  index and every out-of-range index. The initial characterization linked at
  `Saved/Build/cache-ic232-coordinate-contract-red-build-attempt-1/20260809_201405_624_611dac17`
  and passed `1/1` at
  `Saved/Tests/cache-ic232-coordinate-contract-red-attempt-1/20260809_201423_984_2614b2d8`.
  Despite the historical label, this was GREEN characterization, not an intended
  RED and is not counted as one.
- Source scalar/reference/ordinal routing then used a one-fault table for
  Discovery FilterFlags, Mount provider/root fingerprint, Hook affected scope,
  File raw hash, Input target/value, Edge from/ordinal and ineligible-scope
  key/fingerprint. The intended RED at
  `Saved/Tests/cache-ic232-source-semantic-routing-red/20260809_201815_705_1917dd61`
  failed the first row because exact byte `40` still returned parent byte `36`.
  After selecting each field and wire-indexed edge occurrence from the sole
  captured store, the complete target linked at
  `Saved/Build/cache-ic232-source-semantic-routing-green-build-attempt-1/20260809_202013_939_512aaa21`
  and the table passed `1/1` at
  `Saved/Tests/cache-ic232-source-semantic-routing-green-attempt-1/20260809_202027_944_cf74f40d`.
- ModuleInterface next covered declared/parameter DataType qualifier flags,
  parameter traits, declaration Reflection flags, Import target module/key/ABI,
  and Dependency target key/ABI/content. The intended RED linked through the
  official Development Editor wrapper at
  `Saved/Build/cache-ic232-module-semantic-routing-red-build/20260809_202412_814_b89db718`
  and failed `0/1` at
  `Saved/Tests/cache-ic232-module-semantic-routing-red/20260809_202439_496_5fb22a6f`:
  the first nested failure returned declaration parent byte `102` instead of
  exact qualifier byte `291`.
- Root cause was architectural rather than a missing single selector. Captured
  DataType, Parameter, Import and Dependency readers performed semantic checks
  while the complete coordinate store was still being built, so the decoder
  could only use its enclosing collection cursor. They now perform physical
  wire/tag/bounds/reference-budget work only; `PrepareModuleInterface` performs
  nested semantic checks after capture and selects each recursive node/reference
  field from the immutable store. Serialization retains its offset-free semantic
  validation behavior.
- That split linked at
  `Saved/Build/cache-ic232-module-semantic-routing-green-build-attempt-1/20260809_202934_162_1f24b4c9`
  (`4/4`, process/wrapper `0/0`), and the same table passed `1/1` at
  `Saved/Tests/cache-ic232-module-semantic-routing-green-attempt-1/20260809_202949_669_1b298a98`.
- The first complete SourceInterface run at
  `Saved/Tests/cache-ic232-module-semantic-routing-sourceinterface-broad/20260809_203024_132_feb75fde`
  was diagnostic `39/40`, not GREEN. The only failure was the historical
  `NestedSemanticReadFailuresUseCapturedEnclosingFieldOffsets`, which still
  required parent offsets for six nested semantic mutations and therefore
  contradicted the frozen exact-routing table; all new and other historical
  behavior passed.
- IC-236 migrated that method without deleting a case: exact DataType qualifier,
  parameter trait, Import ABI, dependency presence/ABI/content coordinates are
  asserted, while the invalid optional physical tag still reports its own tag
  byte. The test-only change linked at
  `Saved/Build/cache-ic232-exact-nested-regression-build-attempt-1/20260809_203328_448_b1492ba2`
  (`4/4`), passed focused `1/1` at
  `Saved/Tests/cache-ic232-exact-nested-regression-green-attempt-1/20260809_203348_116_bae78983`,
  and the complete SourceInterface prefix passed `40/40`, failed/skipped `0`,
  process/wrapper `0/0` at
  `Saved/Tests/cache-ic232-exact-nested-sourceinterface-green-attempt-1/20260809_203426_964_3ff46014`.
- Evidence ceiling: enum/index-shape coverage and the named scalar/reference
  families are GREEN. IC-232 remains open for present/absent optional value
  breadth, duplicate/order smallest-second-occurrence routing, physical failure
  precedence, and exact/one-byte-short AR-SCR-SI/MI retained allocation and
  promotion Budget matrices. V1.4 graph validation, real-module capture, Store,
  warm restore, Editor GUI/PIE and package behavior are not implied.

## IC-232 duplicate/order and physical precedence closure — 2026-08-09

- Production validators now return the exact first proving physical occurrence
  for Discovery/Mount options, Source providers/hooks/files/inputs/edges/ineligible
  scopes, Module namespaces, identity traits, metadata, slots, declarations,
  imports and dependencies. Duplicate selection keeps the smallest second wire
  occurrence and does not add a second semantic payload scan.
- Unit-test-gated physical writers form malformed duplicate/order payloads without
  creating a second trusted production decoder. Optional-tag corruption covers 11
  Source and 6 Module presence fields; a later physical invalid tag wins over an
  earlier semantic mutation because the full physical read must finish before
  semantic replay.
- The first method filter at
  `Saved/Tests/cache-ic232-duplicate-order-focused-attempt-1/20260809_205347_829_1ce588fe`
  matched zero tests because it omitted the CQTest class segment. It is invalid
  evidence, not a feature failure. The first class-prefix run at
  `Saved/Tests/cache-ic232-duplicate-order-captured-prefix-attempt-1/20260809_205428_974_e28b845a`
  crashed in the invalid IC-237 fixture before the target assertion.
- After the fixture repair, the duplicate/order method passed `1/1` at
  `Saved/Tests/cache-ic232-duplicate-order-focused-attempt-2/20260809_205636_336_2b8c76f1`.
  The optional/physical-precedence method passed `1/1` at
  `Saved/Tests/cache-ic232-optional-physical-precedence-focused-attempt-1/20260809_205835_808_cc069d68`.
- The Runtime/Test changes linked through the complete Development Editor target
  at
  `Saved/Build/cache-ic232-optional-physical-precedence-build-attempt-1/20260809_205811_751_eb5b4d83`.
  The complete SourceInterface prefix then passed `42/42`, failed/skipped `0`,
  process/wrapper `0/0` at
  `Saved/Tests/cache-ic232-order-physical-sourceinterface-broad-attempt-1/20260809_205913_397_71dcfedd`.

## IC-232 retained allocation and rollback closure — 2026-08-09

- A test-first compile RED at
  `Saved/Build/cache-ic232-allocation-origin-red-build-attempt-1/20260809_210700_847_02009798`
  proved the public unit-test allocation event did not expose its already-known
  physical `FieldOffset`. Adding that observation-only field and copying the
  canonical allocation event value linked the full Editor target at
  `Saved/Build/cache-ic232-allocation-origin-green-build-attempt-1/20260809_210721_095_774ec2aa`.
- The first executing matrix at
  `Saved/Tests/cache-ic232-allocation-origin-focused-attempt-1/20260809_210748_724_404173ef`
  correctly exposed IC-238: SourceIndex retained bytes were `5766`, while
  monotonic TotalDecoded/combined peak included `3024` bytes of validation scratch.
  The second diagnostic at
  `Saved/Tests/cache-ic232-allocation-origin-focused-attempt-2/20260809_210927_178_cdf1118e`
  identified the second Module namespace string at byte `90`, which the initial
  index-zero-only coordinate inventory had omitted.
- The corrected matrix distinguishes final retained, monotonic total and
  combined-live peak. It proves exact total/resident limits, each dimension one
  byte short, actual requested/reserved/allocated capacity relationships, exact
  physical origin for every event, and atomic output/temp rollback after injected
  failure at every accepted allocation. Its final build is
  `Saved/Build/cache-ic232-allocation-origin-green-build-attempt-3/20260809_211054_436_392431ff`.
- The focused method passed `1/1`, process/wrapper `0/0` at
  `Saved/Tests/cache-ic232-allocation-origin-focused-attempt-3/20260809_211115_576_fbdc7ec1`.
  Logged inventories are SourceIndex `1256` payload bytes / `29` allocations /
  `5766` retained bytes and ModuleInterface `777` / `36` / `5357`.
- The complete SourceInterface prefix passed `43/43`, failed/skipped `0`,
  process/wrapper `0/0` at
  `Saved/Tests/cache-ic232-allocation-sourceinterface-broad-attempt-1/20260809_211152_055_b8b0acbb`.
- Evidence ceiling: IC-232's SourceIndex/ModuleInterface captured-coordinate,
  physical-precedence and practical retained-allocation boundary is closed. The
  shared canonical TypeSchema matrix remains the allocator-mechanism breadth
  authority; an empty/one/slack/many Cartesian product for every semantic DTO is
  explicitly not required. `ValidateModuleSnapshotGraph`, real module capture,
  Store, warm restore, StaticJIT, Editor GUI/PIE and package behavior remain open.

## V1.4 minimal ModuleSnapshot graph vertical — 2026-08-09

- A test-first API compile at
  `Saved/Build/cache-v14-minimal-graph-api-red-build-attempt-1/20260809_211905_941_bf90fb57`
  failed because graph context/resolver/output types were only forward declarations;
  this is the intended RED proving the test named the missing public boundary.
- The first production build exposed IC-239 and IC-240 at
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-1/20260809_212409_236_0324e39d`;
  the isolated DLL-linkage reproduction is
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-2/20260809_212742_020_42c5ca6c`.
  Both are preserved as diagnostic evidence rather than counted as GREEN.
- The complete UE 5.8 Development Editor target passed through the official
  wrapper at
  `Saved/Build/cache-v14-minimal-graph-green-build-attempt-3/20260809_212814_296_20b997b0`.
- The focused prefix passed `2/2`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-minimal-graph-focused-attempt-1/20260809_212839_711_485e22f4`.
  It proves that the minimal reachable graph publishes exactly the requested
  ModuleSnapshot, ModuleInterface and ModuleState; SourceIndex remains context-only;
  ContextMismatch and a missing linked child atomically clear a previously
  published output.
- Evidence ceiling: this is the first graph traversal/promotion vertical. It does
  not prove TypeSchema coverage, declarations/bodies/debug, globals/initializers,
  enum authority, dependencies/current resolvers, opaque payloads, a real compiled
  module, Store, warm restore, StaticJIT, GUI Editor, PIE or packages. V1.4 remains
  open.

## V1.4 simple TypeSchema exact-coverage vertical — 2026-08-09

- The new behavior compiled before production changes at
  `Saved/Build/cache-v14-type-coverage-red-build-attempt-1/20260809_213419_440_0b3a04ce`.
  Its intended RED then ran `4` tests, retained the original `2` GREEN methods and
  failed the `2` new methods at
  `Saved/Tests/cache-v14-type-coverage-red-attempt-1/20260809_213441_649_9323f364`:
  a required linked type could not publish, and a missing child was incorrectly
  preempted by `UnexpectedRecord`.
- Production now follows linked TypeSchema children before exact declaration-set
  comparison, merge-walks canonical full TypeKeys, verifies same-module ownership
  plus kind/namespace/name/declaration identity, and publishes a sorted owning
  `{TypeKey, TypeSchemaRecordOrdinal}` table. Scratch and retained capacities use
  the caller's shared graph Budget; failure remains atomic.
- IC-241's first production compile failure is preserved at
  `Saved/Build/cache-v14-type-coverage-green-build-attempt-1/20260809_213715_154_24b10436`.
  The complete target passed after the contained-hash ordering repair at
  `Saved/Build/cache-v14-type-coverage-green-build-attempt-2/20260809_213734_025_f3b1c3ee`.
- The same focused prefix passed `4/4`, failed/skipped `0`, process/wrapper `0/0`,
  at
  `Saved/Tests/cache-v14-type-coverage-green-attempt-1/20260809_213752_171_f5f6c5e4`.
  It covers successful simple Class publication, exact type ordinal, missing linked
  record, missing required schema, extra undeclared schema and temporary-scratch
  cleanup.
- Evidence ceiling: complex relations, properties, methods/VFT/behaviors,
  reflection, enum/typedef/funcdef/delegate forms and current numeric layout are
  deliberately still rejected. Function/debug/state/dependency/opaque phases and
  all later lifecycle milestones also remain open.

## V1.4 FunctionBody graph RED frontier — 2026-08-09

- The new FunctionBody graph fixtures and assertions linked through the complete
  UE 5.8 Development Editor target at
  `Saved/Build/cache-v14-function-graph-red-build-attempt-1/20260809_214654_282_82d8cfbf`.
- The focused ModuleSnapshotGraph prefix then ran `6` tests at
  `Saved/Tests/cache-v14-function-graph-red-attempt-1/20260809_214920_496_07821a9b`.
  The existing minimal graph and simple TypeSchema methods remained `4/4` GREEN;
  the two new FunctionBody methods failed for the intended missing production
  behavior, with failed/skipped `2/0` and process/wrapper `255/1`.
- The RED names the next production slice precisely: resolve required FunctionBody
  links before coverage, compare declarations against stable FunctionKeys and ABI,
  validate invocation kind plus opaque payload hash, publish stable function/opaque
  ordinals, and make every failure roll back the whole graph candidate and its
  shared retained-allocation transaction. It is not an Editor-GUI, PIE, Store,
  warm-restore, StaticJIT or package result.

## V1.4 FunctionBody graph and atomic opaque candidate GREEN — 2026-08-09

- The first production build preserved at
  `Saved/Build/cache-v14-function-graph-green-build-attempt-1/20260809_220056_276_4956e476`
  failed only because UE treats the new inner `LinkOrdinal` shadow as an error.
  Renaming the function-body coordinate linked the complete UE 5.8 Development
  Editor target at
  `Saved/Build/cache-v14-function-graph-green-build-attempt-2/20260809_220123_516_f09024eb`.
- The focused graph prefix passed `6/6`, failed/skipped `0`, process/wrapper `0/0`,
  at
  `Saved/Tests/cache-v14-function-graph-green-attempt-1/20260809_220147_654_baccea2e`.
  It proves missing child before codec, exact required/forbidden body coverage,
  stable FunctionKey publication, declaration ABI, invocation kind, profile and
  opaque execution-hash checks, body/summary/owner ordinals and atomic failure.
- The retained-summary budget fixture linked at
  `Saved/Build/cache-ic242-candidate-budget-build-attempt-1/20260809_220449_278_a0205e8a`.
  The complete prefix then passed `7/7`, failed/skipped `0`, process/wrapper `0/0`,
  at
  `Saved/Tests/cache-ic242-candidate-budget-attempt-1/20260809_220516_248_38e1ca3a`.
  Logged allocator evidence is `696` decoded-delta, `468` retained-delta, `8305`
  absolute peak-live and `56` codec-owned summary slack bytes. Both exact limits
  pass; total and resident limits one byte short fail; a post-codec ABI mismatch
  releases the shared candidate, publishes no graph and restores temporary/live
  resident accounting to the decoded-token baseline. This closes IC-242.
- Evidence ceiling: this vertical deliberately rejects nonempty relocations/
  ActualDependencies and present DebugSidecar after step-1 reachability/codec work.
  Initializer codecs, exact Debug ownership/source equality, complete dependency
  closure, rich TypeSchemas/ModuleState, current resolvers, real compiled modules,
  Store, cold/warm/edit, StaticJIT, GUI Editor, PIE and packages remain open.

## V1.4 DebugSidecar owner/hash vertical — 2026-08-09

- Debug success and failure fixtures linked before production support at
  `Saved/Build/cache-v14-debug-graph-red-build-attempt-1/20260809_220856_585_9a9fe036`.
  The focused prefix preserved the existing `7/7` methods and failed only the
  two new Debug methods at
  `Saved/Tests/cache-v14-debug-graph-red-attempt-1/20260809_220915_776_42b0a269`.
- Production now follows body-owned optional DebugSidecar links before any opaque
  call, invokes FunctionExecution before Debug in link/owner order, retains Debug
  after all FunctionBody records, and publishes body/debug record and summary
  ordinals through the same candidate transaction. Step 8 checks FunctionKey,
  Profile, body-to-sidecar DebugHash, codec hash, zero Debug relocations/owned
  bytes, exact source-summary equality and SourceIndex file membership.
- The complete UE 5.8 Development Editor target linked at
  `Saved/Build/cache-v14-debug-graph-green-build-attempt-1/20260809_221105_083_76434cf6`.
  The focused prefix passed `9/9`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-debug-graph-green-attempt-1/20260809_221127_486_65ce4e6e`.
  This covers present/absent child reachability, successful empty-source Debug
  publication, wrong function owner, wrong profile, body/sidecar hash conflict,
  codec hash conflict and atomic rollback.
- Evidence ceiling: nonempty exact source rows and duplicate sidecar ownership are
  the next Debug cases. Initializer/state/enum, nonempty Function relocations and
  dependency/current-resolver closure, rich TypeSchema and every later lifecycle
  milestone remain open.

## V1.4 DebugSidecar exact nonempty source rows — 2026-08-09

- Extending the graph fixture from an empty SourceIndex to one real provider,
  mount and file first exposed IC-243 before production graph validation. The
  diagnostic run is preserved at
  `Saved/Tests/cache-v14-debug-source-diagnostic-attempt-1/20260809_221723_571_7271386f`:
  SourceIndex failed closed with `DerivedHashMismatch` because the fixture's
  ProviderKey input omitted `IdentityFingerprint`.
- The fixture repair linked through the complete UE 5.8 Development Editor target
  at
  `Saved/Build/cache-v14-debug-source-fixture-fix-build-attempt-1/20260809_222106_018_9751d49e`.
  A first method-only wrapper attempt at
  `Saved/Tests/cache-v14-debug-source-fixture-fix-focused-attempt-1/20260809_222134_959_30df4c71`
  discovered zero tests because CQTest registers the class coordinate between the
  declared prefix and method; it is discovery evidence, not behavioral evidence.
- The discoverable class prefix then passed `10/10`, failed/skipped `0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-debug-source-fixture-fix-prefix-attempt-1/20260809_222214_335_b30d6a12`.
  It proves that a nonempty codec-owned Debug source row is charged through the
  shared candidate, exactly equals the immutable sidecar row and references a
  SourceIndex file. Missing SourceIndex membership and a codec that omits the row
  both reject atomically with an empty output graph and no temporary ownership.
- Evidence ceiling: duplicate sidecar ownership remains the next Debug graph case.
  Initializer/state/enum, nonempty Function relocations and dependency/current
  resolution, rich TypeSchema, real compiled-module capture and all Store/lifecycle
  milestones remain open.

## V1.4 sole DebugSidecar ownership — 2026-08-09

- A two-function fixture sharing one DebugSidecar linked through the complete
  Editor target at
  `Saved/Build/cache-v14-duplicate-debug-owner-red-build-attempt-1/20260809_222849_053_0ab30be6`.
  The graph prefix preserved the prior `10/10` methods and failed only the new
  ownership method at
  `Saved/Tests/cache-v14-duplicate-debug-owner-red-attempt-1/20260809_222913_680_3bd04101`:
  production returned the later `DebugLinkMismatch(54)` instead of the required
  `DuplicateDebugOwner(53)`.
- Production now builds a separately budgeted, allocator-exact sorted
  `{DebugRecordId, BodyLinkOrdinal}` scratch index. It marks later owners without
  pairwise scanning, retains/calls each unique sidecar once in owning-body order,
  and reports the duplicate at step 8 before comparing that later body's Debug
  FunctionKey. Candidate reachability, record ordinals and opaque summaries no
  longer duplicate a shared invalid sidecar.
- The complete UE 5.8 Development Editor target passed at
  `Saved/Build/cache-v14-duplicate-debug-owner-green-build-attempt-1/20260809_223319_557_ad19857a`.
  The full graph prefix passed `11/11`, failed/skipped `0`, process/wrapper `0/0`,
  at
  `Saved/Tests/cache-v14-duplicate-debug-owner-green-attempt-1/20260809_223337_281_0edfa899`.
  The duplicate fixture made exactly three codec calls—two distinct execution
  bodies and one unique Debug payload—then cleared a previously published graph
  with `DuplicateDebugOwner` and released all temporary ownership.
- Evidence ceiling: this closes the frozen Debug ownership/source cases for the
  current graph surface. ModuleState globals/initializers and enum authority are
  now the next V1.4 vertical; dependencies/current resolution, richer TypeSchema,
  real-module capture and later Store/lifecycle milestones remain open.

## V1.4 default ModuleState global coverage — 2026-08-09

- A default primitive-global fixture linked before graph support at
  `Saved/Build/cache-v14-default-global-red-build-attempt-1/20260809_223758_449_3c8f1877`.
  The prefix preserved the previous `11/11` methods and failed only the new
  ModuleState method at
  `Saved/Tests/cache-v14-default-global-red-attempt-1/20260809_223822_781_3b1ba2fd`.
- Production now indexes all ModuleInterface Global declarations and ModuleState
  OrderedGlobals by full stable GlobalKey, merge-compares exact coverage, verifies
  GlobalVariable kind, namespace/name, recursive data type and trait mask, and
  publishes a sorted owning `GlobalKey -> ModuleStateGlobalOrdinal` table. Both
  declaration scratch and retained ordinal capacity are charged before reserve.
  This vertical accepts the exact `Default + Cleanup::None` lifecycle and keeps
  PureConstant, VM initializer and owned cleanup forms fail-closed for their next
  dedicated coverage.
- The complete UE 5.8 Development Editor target passed at
  `Saved/Build/cache-v14-default-global-green-build-attempt-1/20260809_224145_945_e0a5a5e1`.
  The graph prefix passed `12/12`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-default-global-green-attempt-1/20260809_224206_465_e7fecb65`.
  It proves successful ordinal publication plus atomic missing, undeclared and
  shape-mismatched global rejection with temporary ownership restored to zero.
- Evidence ceiling: HardValues, EnumAuthority, initializer units/actions,
  post-init, state dependencies and cleanup policies remain open. This result is
  not yet a real compiled-module, Store, warm/edit, StaticJIT or lifecycle result.

## V1.4 module initializer ownership and opaque order — 2026-08-09

- The focused fixture first added a compiler-generated, module-owned, zero-parameter
  `void` initializer declaration, one ModuleState initializer unit and one
  `ExecuteInitializer` action. The complete UE 5.8 Development Editor target
  linked before production support at
  `Saved/Build/cache-v14-module-initializer-red-build-attempt-1/20260809_225022_122_4ba41baf`.
- The graph prefix then retained the preceding `12/12` methods and failed only the
  new initializer method at
  `Saved/Tests/cache-v14-module-initializer-red-attempt-1/20260809_225045_372_ac765fda`.
  Production returned the deliberate `MissingCoverage` frontier before the first
  initializer codec call; this is behavioral RED, not a compile-only artifact.
- Production now constructs one allocator-exact action-to-unit scratch map, walks
  initializer codecs exactly once in ascending `ExecuteInitializer.ActionOrdinal`
  before FunctionBody and Debug codecs, shifts later summary ordinals by the
  initializer count, and publishes sorted
  `{InitializerKey, UnitOrdinal, ExecuteActionOrdinal, SummaryOrdinal}` plus opaque
  owner indexes in the same atomic candidate transaction. Step 5 merge-compares
  initializer declarations and units by the complete stable FunctionKey and checks
  the frozen module-owner, Generated-only callable shape, forbidden FunctionBody,
  action target ABI and validated opaque hash.
- The corrected production/test sources linked through the complete target at
  `Saved/Build/cache-v14-module-initializer-green-build-attempt-1/20260809_225627_159_1c975c56`.
  The same graph prefix passed `13/13`, failed/skipped `0`, process/wrapper `0/0`,
  at
  `Saved/Tests/cache-v14-module-initializer-green-attempt-1/20260809_225651_695_c5ccee44`.
  The new method proves one successful initializer codec call and stable ordinal,
  plus atomic missing-unit, undeclared-unit, wrong-action-ABI and wrong-codec-hash
  rejection with temporary ownership restored to zero.
- Evidence ceiling: this vertical accepts only the zero-dependency module
  initializer. Global `VmInitializer`, PureConstant/HardValue, DefaultConstructGlobal
  cleanup actions, initializer relocations/owned bytes, post-init and state
  dependency closure remain fail-closed. It does not prove real compiler capture,
  disk Pack/Manifest, cold/warm/edit restore, StaticJIT attachment, GUI Editor, PIE
  or packaged behavior.

## V1.4 external FunctionBody dependency/relocation/current-symbol vertical — 2026-08-09

- The new focused fixture models one external `EnvironmentSymbol` actual
  dependency, an optional matching or mismatching relocation emitted by the opaque
  execution codec, and a deterministic current-symbol resolver. The first complete
  target build exposed the fixture-only CQTest capture error IC-245 at
  `Saved/Build/cache-v14-dependency-red-build-attempt-1/20260809_231312_818_01e6e818`;
  after explicitly capturing the test instance, the target linked at
  `Saved/Build/cache-v14-dependency-red-build-attempt-2/20260809_231452_790_0c27f0f8`.
- The focused prefix then failed both new methods for the intended missing Runtime
  behavior at
  `Saved/Tests/cache-v14-dependency-red-attempt-1/20260809_231523_094_7decf730`:
  total/passed/failed/skipped were `2/0/2/0`, process/wrapper `255/1`, and the
  graph still returned the old unsupported-dependency error `47` before either
  relocation subset or current-symbol validation.
- Production step 7 now treats FunctionExecution relocations as an exact subset
  of the owning FunctionBody's canonical ActualDependencies. It binary-searches
  the immutable dependency table and compares dependency/reference kinds, the
  complete StableKey, expected ABI, and optional expected content/value hash.
  Dependencies without operand relocations remain legal; a relocation not backed
  by an exactly matching actual dependency fails at `OpaquePayload` with
  `RelocationDependencyMismatch` before any current resolver call.
- Production step 10 now walks external Script/Environment dependencies in
  function-body/dependency order, memoizes current-symbol lookups by
  `{ReferenceKind, StableKey}`, and applies the frozen order: missing symbol,
  incompatible ABI/storage kind, then required content presence/hash. Failures are
  typed as `CurrentSymbolMissing`, `CurrentAbiMismatch` or
  `CurrentContentMismatch`, report `CurrentResolver`, and leave the output graph
  empty with the candidate transaction releasing all temporary bytes.
- Two implementation builds preserved IC-246's C4456 naming diagnostic at
  `Saved/Build/cache-v14-dependency-green-build-attempt-1/20260809_232141_056_e3a96620`
  and
  `Saved/Build/cache-v14-dependency-green-build-attempt-2/20260809_232227_347_a81091ce`.
  The uniquely targeted rename linked the complete UE 5.8 Development Editor
  target at
  `Saved/Build/cache-v14-dependency-green-build-attempt-3/20260809_232309_502_a6838b23`.
- The focused dependency prefix passed `2/2`, failed/skipped `0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v14-dependency-green-attempt-1/20260809_232327_298_53874c5f`.
  It proves matching relocation success, a no-relocation actual dependency,
  relocation mismatch precedence/no resolver call, missing/wrong-ABI/wrong-content
  current results, one resolver call per case and atomic rollback.
- The established ModuleSnapshotGraph regression independently passed `13/13`,
  failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-dependency-graph-regression-attempt-1/20260809_232711_164_fac2afc2`.
- Evidence ceiling: this is only the FunctionBody external-current vertical.
  Selected-module Script references deliberately fail closed until step 9 can
  resolve them exclusively from the immutable selected graph with zero current
  resolver calls. Interface/TypeSchema/ModuleState/action dependency closure,
  current type-layout resolution, duplicate-reference memo evidence, exact
  current storage-kind and source/profile precedence cases remain open. It is not
  real compiler capture, Store, cold/warm/edit, StaticJIT, GUI Editor, PIE or
  package evidence.

## V1.4 selected-module ScriptFunction dependency closure — 2026-08-09

- The first selected-module fixture linked before production support at
  `Saved/Build/cache-v14-local-function-dependency-red-build-attempt-1/20260809_233330_415_2629f264`.
  The focused prefix found three methods, retained the preceding two GREEN cases,
  and failed only the new graph-closed method at
  `Saved/Tests/cache-v14-local-function-dependency-red-attempt-1/20260809_233356_033_74a3a6de`:
  total/passed/failed/skipped `3/2/1/0`, process/wrapper `255/1`.
- Production now performs the first real step-9 dependency closure. A selected-
  module `ScriptFunction` StableKey is found in the sorted declaration index,
  its expected ABI is compared with the immutable declaration `SignatureHash`,
  and an optional explicit content expectation is compared with the linked
  FunctionBody execution hash. The row is skipped at step 10 and never reaches
  `CurrentSymbols`.
- The complete UE 5.8 Development Editor target linked at
  `Saved/Build/cache-v14-local-function-dependency-green-build-attempt-1/20260809_233539_999_96f6240f`.
  The focused dependency prefix passed `3/3`, failed/skipped `0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v14-local-function-dependency-green-attempt-1/20260809_233558_558_9b6d684c`.
  The valid local dependency made exactly one opaque-codec call and zero current-
  symbol calls. A wrong local function ABI paired with wrong selected source and
  profile still failed first as `GraphAbiMismatch/ModuleGraph`, with zero resolver
  calls, empty output and zero temporary resident ownership.
- The established ModuleSnapshotGraph prefix independently passed `13/13`,
  failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-local-function-dependency-graph-regression-attempt-1/20260809_233841_325_096c80aa`.
- Evidence ceiling: only FunctionBody-owned selected-module `ScriptFunction` rows
  are graph-closed. ScriptType/Global/Property/Import, Interface/TypeSchema/
  ModuleState/action owners, initializer content authority, complete cross-record
  current-symbol ordering and CurrentLayouts remain open.

## V1.4 ModuleInterface dependency/current-memo participation — 2026-08-09

- The focused fixture moved the same legal external `EnvironmentSymbol` row into
  `ModuleInterface.Dependencies`, then duplicated it exactly across Interface and
  FunctionBody to exercise cross-owner memoization. The complete target linked
  before production support at
  `Saved/Build/cache-v14-interface-dependency-red-build-attempt-1/20260809_234103_073_efe62d5e`.
  The focused prefix retained the preceding `3/3` cases and failed only the new
  method at
  `Saved/Tests/cache-v14-interface-dependency-red-attempt-1/20260809_234124_861_c7dfa3b9`:
  production still rejected every non-empty Interface dependency before invoking
  the current resolver.
- Production now feeds Interface dependencies through the same step-9 immutable
  checker before FunctionBody dependencies, includes both owners in the bounded
  step-10 candidate count, and walks them in that same deterministic owner order.
  One sorted `{ReferenceKind, StableKey}` memo is shared across both walks. Exact
  duplicate witnesses therefore make one current lookup, while a wrong current
  ABI reported from the Interface owner remains `CurrentAbiMismatch/CurrentResolver`
  and atomically clears the candidate graph.
- The complete UE 5.8 Development Editor target linked at
  `Saved/Build/cache-v14-interface-dependency-green-build-attempt-1/20260809_234431_004_6643c788`.
  The dependency prefix passed `4/4`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-interface-dependency-green-attempt-1/20260809_234450_228_de5fc0f1`.
  The established ModuleSnapshotGraph prefix independently passed `13/13`,
  failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-interface-dependency-graph-regression-attempt-1/20260809_234536_554_97d68ed5`.
- Evidence ceiling: Interface imports and unsupported local ScriptType/Global/
  Property/Import rows remain fail-closed; TypeSchema, ModuleState, initializer
  and action dependency owners plus CurrentLayouts remain open. This is still an
  in-memory graph result, not real compiler capture, disk Store, lifecycle or
  packaged evidence.

## V1.4 first CurrentLayouts CodeRoot vertical — 2026-08-10

- A new independently compiled test file constructs a locally valid root UClass
  TypeSchema with exact ShadowSuper/CodeSuper relations, one external CodeRoot
  LayoutInput and its derived EnvironmentAbi dependency. The complete UE 5.8
  Development Editor target linked before production graph support at
  `Saved/Build/cache-v14-current-layout-red-build-attempt-1/20260809_235435_642_8f75308d`.
- The focused prefix found two methods and produced the intended behavioral RED
  at
  `Saved/Tests/cache-v14-current-layout-red-attempt-1/20260809_235455_510_e13d5055`:
  total/passed/failed/skipped `2/0/2/0`, process/wrapper `255/1`. Both methods
  reached the old graph-only TypeSchema gate and failed before either current
  resolver, rather than failing fixture serialization or discovery.
- Production now admits graph-locally exact externally rooted Class/Struct shells
  while keeping properties, methods, VFT, behavior, enum/callable/typedef payloads
  and reflected function membership fail-closed. TypeSchema dependencies execute
  after Interface dependencies in the same bounded current-symbol memo. A second,
  separately budgeted sorted memo resolves
  `{InputKind, ReferenceKind, StableKey}` exactly once, validates the raw role
  shape, applies the stored consumer presence mask, recomputes LayoutInputHash and
  compares the stored contributions without consulting a live selected-module
  type.
- The complete target linked after production support at
  `Saved/Build/cache-v14-current-layout-green-build-attempt-1/20260809_235854_823_9de93dd9`.
  The focused prefix passed `2/2`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-current-layout-green-attempt-1/20260809_235914_413_850e43ed`.
  Its observable logs prove success used exactly one Environment current-symbol
  call, one TypeLayoutInput call, zero DataTypeLayout calls and zero opaque calls.
  Missing layout returned `CurrentSymbolMissing/CurrentResolver`; wrong boundary,
  wrong alignment and missing required raw alignment returned
  `CurrentAbiMismatch/CurrentResolver`; every case cleared a previously published
  graph and restored temporary resident ownership to zero.
- The established ModuleSnapshotGraph prefix independently remained `13/13` at
  `Saved/Tests/cache-v14-current-layout-graph-regression-attempt-1/20260809_235951_589_c25b5a8c`,
  and the dependency/current-symbol prefix remained `4/4` at
  `Saved/Tests/cache-v14-current-layout-dependency-regression-attempt-1/20260810_000024_900_4281c906`.
- Evidence ceiling: this closes only external CodeRoot/StructHeader-style layout
  input plumbing. Selected-module BaseType/value-layout DAGs, consumer-mask reuse
  across repeated inputs, primitive/ObjectHandle profile constants,
  `ResolveDataTypeLayout` for external/environment properties and complete rich
  TypeSchema declaration ownership remain open. It is not real compiler capture,
  Store, lifecycle, Editor GUI, PIE or package evidence.

## V1.4 property declaration and DataType layout vertical — 2026-08-10

- The same independent layout fixture added two richer root-UClass transactions:
  one exact type-owned primitive property and one exact type-owned external
  EnvironmentType property. Both create stable PropertyKey declarations in
  ModuleInterface, matching TypeSchema rows, storage hashes/fingerprints and
  terminal class layouts. The complete target linked before graph support at
  `Saved/Build/cache-v14-property-layout-red-build-attempt-1/20260810_000529_846_cdf95483`.
- The focused prefix preserved the earlier two CodeRoot methods and produced the
  intended `4/2/2/0` behavioral RED at
  `Saved/Tests/cache-v14-property-layout-red-attempt-1/20260810_000551_381_f16c10c5`:
  both new property methods stopped at the old property-empty graph frontier;
  discovery, producer serialization, factory decode and local layout replay had
  already succeeded.
- Production now indexes Property declarations by full stable PropertyKey inside
  the graph scratch transaction, requires exact owning TypeKey/module/name/
  CanonicalDataType/access/reflection/metadata agreement, and rejects missing or
  unused property authority before current eligibility. Primitive and ObjectHandle
  storage compare only against `GetV1BuildLayoutConstants`; no resolver can repair
  a stored contradiction. External inline Script/Environment types use a separate
  bounded memo keyed by the complete recursive CanonicalDataType plus StorageKind.
  Memo entries borrow immutable DTO pointers, so nested types are not copied and
  no hidden unbudgeted subtype allocation is introduced. The resolver receives
  the allocation-free prospective local TypeSchema view.
- The complete target linked at
  `Saved/Build/cache-v14-property-layout-green-build-attempt-1/20260810_001026_023_bac8e629`.
  The focused prefix passed `4/4`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-property-layout-green-attempt-1/20260810_001044_656_46885c7a`.
  Logs prove the primitive route makes zero DataType calls and rejects a stored
  size/alignment mismatch as `CurrentAbiMismatch`; the EnvironmentType route
  makes two current-symbol calls, one CodeRoot input call and one DataType call,
  then reports missing as `CurrentSymbolMissing` and kind/size/alignment mismatch
  as `CurrentAbiMismatch`, always at `CurrentResolver` with an empty graph and
  zero temporary resident bytes.
- The established graph prefix remained `13/13` at
  `Saved/Tests/cache-v14-property-layout-graph-regression-attempt-1/20260810_001121_901_9d0088c3`,
  and dependency/current-symbol remained `4/4` at
  `Saved/Tests/cache-v14-property-layout-dependency-regression-attempt-1/20260810_001154_853_a2e38286`.
- Evidence ceiling: selected-module BaseType and inline ScriptType graph closure,
  ObjectHandle focused evidence, repeated DataType memo reuse, nested environment
  recipes consuming LocalLayouts, method/VFT/behavior/reflection breadth and enum
  authority remain open. This is still in-memory graph eligibility, not compiler
  capture, Store or lifecycle evidence.

## V1.4 selected-module BaseType layout DAG vertical — 2026-08-10

- A new two-TypeSchema fixture links an unreflected local base class and a derived
  UClass through the exact shared ScriptType coordinate used by the Base relation,
  BaseType LayoutInput and Inheritance dependency. The complete target first
  linked at
  `Saved/Build/cache-v14-local-base-layout-red-build-attempt-1/20260810_002032_830_b53f2e1c`.
  The focused prefix then produced the intended `6/4/2/0` behavioral RED at
  `Saved/Tests/cache-v14-local-base-layout-red-attempt-1/20260810_002107_022_4a4c918d`:
  the four established methods stayed GREEN while both local-base methods reached
  the old TypeSchema graph gate and returned `MissingCoverage`.
- Before production work, the same negative method was expanded with a two-node
  base cycle. The target linked at
  `Saved/Build/cache-v14-local-base-cycle-red-build-attempt-1/20260810_002254_457_d0495790`
  and the expanded RED remained exactly `6/4/2/0` at
  `Saved/Tests/cache-v14-local-base-cycle-red-attempt-1/20260810_002315_197_d1494c7b`.
  All three negative variants—wrong declaration ABI, wrong numeric base layout
  and a cycle—still returned the old `MissingCoverage`, proving the new assertions
  were not accidentally satisfied by fixture-local serialization or decoding.
- Production now admits only selected-module ScriptType Base relations,
  BaseType LayoutInputs and their selected-module semantic dependencies at this
  frontier. The immutable dependency pass binary-searches the required Type
  declaration and compares the persisted ExpectedAbi with its ModuleInterface
  SignatureHash. A separate exactly budgeted scratch block binary-searches linked
  TypeSchema ordinals, compares BaseType boundary/alignment with the target
  SemanticSize/SemanticAlignment, and executes an iterative three-color traversal
  over the one-base-per-type graph. It allocates no recursion stack and returns
  `GraphAbiMismatch/ModuleGraph` for unresolved authority, numeric disagreement,
  self-cycle or multi-node cycle before source/profile/current eligibility.
- The complete UE 5.8 Development Editor target linked after production support at
  `Saved/Build/cache-v14-local-base-layout-green-build-attempt-1/20260810_002605_404_45330052`.
  The focused prefix passed `6/6`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-local-base-layout-green-attempt-1/20260810_002623_430_7ac3a132`.
  The positive log proves two selected-module TypeSchemas publish while BaseType
  makes zero current calls; only the UClass CodeRoot produces symbol/input counts
  `1/1`, with DataType count `0`. Each negative log proves
  `GraphAbiMismatch/ModuleGraph`, current counts `0/0/0`, empty output and zero
  temporary resident bytes even though selected source/profile were deliberately
  wrong.
- The established ModuleSnapshotGraph prefix independently remained `13/13` at
  `Saved/Tests/cache-v14-local-base-graph-regression-attempt-1/20260810_002709_861_03175343`,
  and dependency/current-symbol remained `4/4` at
  `Saved/Tests/cache-v14-local-base-dependency-regression-attempt-1/20260810_002742_715_1b47fc04`.
- Current scoped SHA-256 values after this vertical are
  `EE6667A944DC6A6BC39D06C6B68FE76469957598A543D76FA78DBE3C6AFB0D58`
  for `AngelscriptCacheModuleGraph.cpp` and
  `A1FB2BBDC33AFC57E9CC365D1DB8E7147BAFC2336E537493367E2F51CFB07137`
  for `AngelscriptCacheModuleGraphLayoutTests.cpp`.
- Evidence ceiling: selected-module inline-value ScriptType property closure,
  combined Base/by-value DAG traversal, ObjectHandle focused evidence, repeated
  DataType memo reuse, methods/VFT/behavior/reflection breadth, enum authority and
  real compiler capture remain open. No Store, lifecycle, GUI Editor, PIE or
  package behavior is proven by this in-memory graph vertical.

## V1.4 selected-module inline ScriptType and combined type DAG vertical — 2026-08-10

- The independent layout fixture added a local value `Struct`, a local container
  `Struct` with a direct InlineValue ScriptType property, exact Type/Property
  ModuleInterface declarations and matching TypeSchema storage/layout records.
  The complete UE 5.8 Development Editor target linked before production support
  at
  `Saved/Build/cache-v14-local-value-layout-red-build-attempt-1/20260810_003359_458_8774b4d3`.
- The focused prefix produced the intended `8/7/1/0` behavioral RED at
  `Saved/Tests/cache-v14-local-value-layout-red-attempt-1/20260810_003420_263_5b0fceca`.
  The valid local InlineValue route and wrong declaration ABI already exercised
  prior generic ScriptType authority, but the wrong stored size and two-node
  by-value cycle reached the deliberately invalid source state and returned
  `SourceSnapshotMismatch(42)`. This isolated the missing numeric target-layout
  comparison and combined DAG rather than fixture serialization or discovery.
- Production replaced the Base-only color walk with one exactly budgeted local
  type graph. Its edges are selected-module BaseType relations plus direct
  InlineValue ScriptType properties. Every target is binary-searched in the
  linked TypeSchema set; a Base target must be a Class and match its stored
  boundary/alignment, while an inline value target must carry ValueType semantics
  and match property storage size/alignment. Edge count is bounded by both
  `MaxArrayElements` and `MaxReferencesAndRelocations`; edge storage, adjacency
  starts, indegrees and the iterative queue are explicitly reserved and charged.
  Kahn traversal rejects self-, multi-node and mixed-edge cycles without recursion.
- The first GREEN target linked at
  `Saved/Build/cache-v14-local-value-layout-green-build-attempt-1/20260810_003747_537_12256e12`
  and the focused prefix passed `8/8`, failed/skipped `0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v14-local-value-layout-green-attempt-1/20260810_003805_196_da493abe`.
  After the explicit edge-count guard was added, the final target linked at
  `Saved/Build/cache-v14-local-value-layout-final-build-attempt-1/20260810_003958_606_d0f8de79`
  and the final focused result remained `8/8` at
  `Saved/Tests/cache-v14-local-value-layout-final-attempt-1/20260810_004017_987_79643fd3`.
- The positive log proves both local TypeSchemas publish with current-symbol,
  TypeLayoutInput and DataTypeLayout counts `0/0/0`. Wrong target ABI, wrong
  stored storage and the local value cycle report `GraphAbiMismatch/ModuleGraph`
  before deliberately invalid source/profile/current state, clear prior output and
  restore temporary resident ownership to zero.
- The established ModuleSnapshotGraph prefix independently remained `13/13` at
  `Saved/Tests/cache-v14-local-value-final-graph-regression-attempt-1/20260810_004052_802_de645600`,
  and dependency/current-symbol remained `4/4` at
  `Saved/Tests/cache-v14-local-value-final-dependency-regression-attempt-1/20260810_004126_521_b19e9a0b`.
- Current scoped SHA-256 values after this vertical are
  `33F317309D6719EB232D37450CA228C0C2CBC9C8073B7227D554B0E5594597A5`
  for `AngelscriptCacheModuleGraph.cpp` and
  `267A9BE84F07EC1DD3059D903C70F13A24013A593416854D574022BD9A5E0178`
  for `AngelscriptCacheModuleGraphLayoutTests.cpp`.
- Evidence ceiling: this closes direct local ScriptType value storage and cycle
  validation only. ObjectHandle focused evidence, repeated DataType memo reuse,
  nested environment recipes consuming prospective local layouts, methods/VFT/
  behaviors/reflection/enum authority, ModuleState and real compiler capture
  remain open. No Store, lifecycle, GUI Editor, PIE or package behavior is proven.

## V2.1 deterministic Pack, Manifest and Generation data plane — 2026-08-10

- The first correctly targeted RED was
  `Saved/Tests/cache-v21-pack-format-red-attempt-1/20260810_004701_684_8364c458`.
  It reached the frozen behavior suite but terminated when a shared generation
  fixture hard-asserted the deliberately stubbed Pack builder; this is preserved
  as IC-248 rather than treated as a Runtime crash or partial result.
- The first real Pack implementation linked at
  `Saved/Build/cache-v21-pack-core-green-build-attempt-1/20260810_005454_796_87012178`.
  Its complete prefix reached `13/26` at
  `Saved/Tests/cache-v21-pack-core-mixed-attempt-1/20260810_005518_063_19132525`:
  exact empty/mixed byte goldens, PackId/GenerationId, raw-versus-semantic
  identity, deterministic completion aggregation, payload-only storage, physical
  header/range/codec rules and read-budget ordering were already GREEN; generation
  decode and reachability remained deliberately unimplemented.
- Guarded exact reachability then linked at
  `Saved/Build/cache-v21-reachability-green-build-attempt-1/20260810_010159_607_97912f99`.
  The complete prefix reached `18/26` at
  `Saved/Tests/cache-v21-reachability-green-attempt-1/20260810_010231_005_2add145b`:
  all missing/wrong-kind root/child/debug, SourceSnapshot, unreachable-kind and
  module-root ownership cases passed. IC-249 and IC-250 record four malformed
  fixtures that changed complete Pack bytes without preserving earlier frozen
  location/PackId invariants; production fail-fast precedence was retained and
  the fixtures were isolated.
- Production now decodes the exact `UEASCV2M` stream, checks injected count/byte/
  Pack limits before pack access, derives and validates the profile, enforces
  canonical root/index order and exact EOF, validates the complete GenerationId,
  loads each distinct Pack exactly once per attempt, validates every complete Pack
  and selected location, decodes selected semantic records under one cumulative
  Budget, computes exact record reachability, verifies embedded SourceSnapshot and
  ModuleKey ownership, and publishes `FAngelscriptValidatedGeneration` only after
  every stage succeeds. Writer codec offsets were aligned with the frozen 122-byte
  manifest-location stream (`Codec +89`, `RawChecksum +90`).
- The complete UE 5.8 Development Editor target linked at
  `Saved/Build/cache-v21-generation-green-build-attempt-1/20260810_011225_276_8bf1fc48`
  (`7/7` actions, process/final `0/0`). The final official command
  `Tools\\RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache.PackFormat
  -Label cache-v21-generation-green-attempt-1 -TimeoutMs 600000` passed `26/26`,
  failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v21-generation-green-attempt-1/20260810_011249_433_048e522c`.
  It proves exact byte goldens, forward/reverse/random scheduling determinism,
  None/Zlib physical identity, all frozen malformed precedence, MaxGenerationPacks
  before source access, one cumulative five-counter boundary and every exact
  reachability family.
- Current scoped SHA-256 values are
  `A031A629EF4EC689E2743D7B3A1B1D981C3D7383330717501AEA891C1CFB2835`
  for `AngelscriptCacheManifestPack.cpp` (`66,705` bytes / `1,991` lines) and
  `9429EDAF5F2B3D4A616A0B808065E84F4454A41E133C6D8C7A0B5555723CFCAC`
  for `AngelscriptCacheManifestPackTests.cpp` (`129,410` bytes / `2,840` lines).
- Evidence ceiling: V2.1 is an in-memory Pack/Manifest/Generation closure. It does
  not yet prove immutable Saved Store I/O, Current/Previous/Pending publication,
  real AngelScript compiler/VM capture or restore, cold/warm/edit behavior,
  StaticJIT attachment, GUI Editor/PIE shutdown refresh, Python dump, Development
  or Shipping packaged multi-launch behavior.

## V2.1 post-GREEN atomicity and complete pre-allocation Budget closure — 2026-08-10

- IC-251 began from a post-`26/26` source audit rather than an existing test
  failure. The generation reader was validating the same complete Pack once per
  selected record and each record factory promoted independently before exact
  generation reachability. The intended late-`UnexpectedRecord` RED at
  `Saved/Tests/cache-v21-ic251-red-attempt-1/20260810_011839_331_a7476d97`
  proved that a failed generation retained decoded ownership. The first GREEN
  compile identified only the missing test-build friendship at
  `Saved/Build/cache-v21-ic251-green-build-attempt-1/20260810_012142_218_f3779b18`;
  the corrected complete target linked at
  `Saved/Build/cache-v21-ic251-green-build-attempt-2/20260810_012220_667_3b5a488b`.
  Focused behavior passed `1/1` at
  `Saved/Tests/cache-v21-ic251-green-attempt-1/20260810_012246_170_af0c7a7f`
  and the then-complete PackFormat prefix passed `26/26` at
  `Saved/Tests/cache-v21-ic251-final-attempt-1/20260810_012320_017_f0d7ee62`.
  Module and SourceInterface regressions passed `30/30` and `43/43` at
  `Saved/Tests/cache-v21-ic251-module-regression-attempt-1/20260810_012707_664_ed85ef7e`
  and
  `Saved/Tests/cache-v21-ic251-source-interface-regression-attempt-1/20260810_012744_427_98eeb7b9`.
  Generation now validates every distinct Pack exactly once and decodes every
  selected record into one batch candidate promoted only after exact reachability.
- IC-252 then proved Manifest roots/locations/sorted and distinct PackId arrays,
  plus returned Pack indexes, were allocated before the one Budget accounted for
  them. The new focused source linked at
  `Saved/Build/cache-v21-ic252-red-build-attempt-1/20260810_013235_297_819f0310`
  and failed the intended first exact Pack-index assertion at
  `Saved/Tests/cache-v21-ic252-red-attempt-1/20260810_013254_404_e20374cb`.
  Production linked at
  `Saved/Build/cache-v21-ic252-green-build-attempt-1/20260810_013830_558_f328c1b8`
  and the focused exact/one-short method passed `1/1` at
  `Saved/Tests/cache-v21-ic252-green-attempt-1/20260810_013849_273_29653429`.
  The first complete rerun at
  `Saved/Tests/cache-v21-ic252-packformat-final-attempt-1/20260810_013924_677_e3106f7c`
  was `25/27`: two old assertions correctly observed the newly charged 96-byte
  temporary Pack index but still expected raw-only accounting. After changing
  those fixtures to assert the index-plus-raw live peak, the test-only correction
  linked at
  `Saved/Build/cache-v21-ic252-regression-fixture-build-attempt-1/20260810_014041_061_7f5544e6`
  and PackFormat passed `27/27` at
  `Saved/Tests/cache-v21-ic252-packformat-final-attempt-2/20260810_014059_588_c31faf0c`.
  Budget, Module, SourceInterface and DecodedRecordDeclaration independently
  passed `16/16`, `30/30`, `43/43` and `1/1` at the IC-252 artifacts recorded in
  `implementation-issues.md`.
- IC-253 found the remaining Zlib reader scratch: variable-output canonical
  recompression allocated outside Budget and its equality expression copied the
  complete stored view. The focused source linked at
  `Saved/Build/cache-v21-ic253-red-build-attempt-1/20260810_014747_959_4fc4a9f9`
  and failed the intended combined `PackIndex + RawSize + StoredSize` assertion
  at `Saved/Tests/cache-v21-ic253-red-attempt-1/20260810_014808_639_19d31f3d`.
  The fixed-output reader codec, exact StoredSize reservation, allocation-free
  comparison and enqueue-time reachability deduplication linked at
  `Saved/Build/cache-v21-ic253-green-build-attempt-1/20260810_014948_242_7bf97904`.
  Focused behavior passed `1/1` at
  `Saved/Tests/cache-v21-ic253-green-attempt-1/20260810_015008_928_80417c20`;
  the final complete PackFormat prefix passed `27/27`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v21-ic253-packformat-final-attempt-1/20260810_015042_611_77e41215`.
- The first broader `Angelscript.TestModule.Cache` run at
  `Saved/Tests/cache-v21-complete-cache-regression-attempt-1/20260810_015123_950_0a79dbc9`
  discovered `244` methods, started `167`, completed `149` successes and `17`
  ordinary failures—one existing IC-227 Archive.Primitives allocator witness and
  `16` TypeSchema/IC-214 failures—then terminated on the pre-existing TypeSchema
  fixture assertion recorded as IC-254. It is not a PackFormat regression—the final
  `27/27` PackFormat, `16/16` Budget, `30/30` Module, `43/43` SourceInterface and
  `1/1` DecodedRecordDeclaration scoped runs are GREEN—but it is authoritative
  evidence that V1.6 and real clean-module capture remain open.
- IC-254 fixture diagnosis first failed exactly fixture `44`, family `11`, variant
  `3`, cardinality `21`, with local `ConflictingKey` at
  `Saved/Tests/cache-ic254-ts-scr-diagnostic-attempt-1/20260810_015929_078_856bc219`.
  The generated ImplementedInterface key range collided with its owning Class
  TypeKey at index `17`; moving that test-only range preserved the required
  allocation cardinality and kept production self-inheritance validation intact.
  The repair linked at
  `Saved/Build/cache-ic254-ts-scr-fixture-green-build-attempt-1/20260810_020125_432_b23141e0`
  and the permanent diagnostic passed `1/1`, covering all `45/45` representative
  fixtures, at
  `Saved/Tests/cache-ic254-ts-scr-fixture-green-attempt-1/20260810_020141_909_849e9447`.
  The full TypeSchema class now completes without assertion at
  `Saved/Tests/cache-ic254-typeschema-regression-attempt-1/20260810_020225_238_f552cad5`:
  total `66`, passed `48`, failed `18`, skipped `0`. This is a complete diagnostic
  baseline, not GREEN; two TS-SCR failures became visible only because the former
  static initialization crash no longer truncates the class.
- Current scoped source identities are:

  ```text
  AngelscriptCacheTypes.h             4B06DADB5409940DB408654504F812879E7D0D2F9E4F5809AD3FD09807B39762
                                       27,026 bytes / 852 lines
  AngelscriptCacheDecodedRecord.h     F1D562C038C4966424187BEFBA91F91BC7BA8B16FC03FCA4D4360B23571E0AC6
                                       29,593 bytes / 904 lines
  AngelscriptCacheDecodedRecord.cpp   92E8EC6912E876BC9594137DB4391CA716F2AFD9BC0FF33985DC921FE78CA4BC
                                       42,519 bytes / 1,446 lines
  AngelscriptCacheManifestPack.h      82B2FBCC71E4E950E7B0159C179F4A77FD10E6795152E7B0365CDA033ECA8107
                                        8,087 bytes / 249 lines
  AngelscriptCacheManifestPack.cpp    ACCDD377D00E95B96E712DE53F7A29F05E50C9C24000FC2CC2D6552D88924AA3
                                       72,722 bytes / 2,170 lines
  AngelscriptCacheManifestPackTests.cpp
                                      CEBCCD4EF42C9EE9119369756BB693F2C3BF662ABB03A95F6592DAB5C811F9F0
                                      138,603 bytes / 3,034 lines
  ```
- Final V2.1 evidence ceiling remains in-memory data-plane behavior only. V2.2
  Saved Store, V1/real compiler capture, cold/warm/edit activation, StaticJIT,
  Editor/PIE/shutdown refresh, Python dump and packaged multi-launch are not
  claimed by this closure.

## V1 TypeSchema and TS-SCR exact-allocation closure — 2026-08-10

- The TypeSchema hard-assert baseline was first converted into the permanent
  `45/45` representative-fixture serializability diagnostic. Its family-11
  self-inheritance collision was repaired without weakening production
  validation, after which the full class completed at `48/66` and exposed all
  remaining ordinary failures instead of terminating the process.
- IC-254/IC-255 then closed producer/decoder semantic mismatches, dependency
  fixture completeness, actual intrusive-controller accounting, exact
  ten-coordinate flat-header reservation, secondary-index chronology and stable
  reference relocation prefixes. The ten-versus-nine reserve defect has an
  intended `5/11` RED at
  `Saved/Tests/cache-ic255-flat-header-growth-red-attempt-1/20260810_025125_562_87b33ba6`.
- The final family-8 audit removed both locally forbidden TemplateCallback rows
  and restored the omitted ScriptFunction and EnvironmentSymbol ReleaseRefs rows.
  The resulting authority contains 78 unique valid cases rather than preserving
  the accidental intermediate count of 77. TS-SCR passed `11/11` at
  `Saved/Tests/cache-ic255-reference-authority-green-attempt-1/20260810_030043_067_a3eb367f`.
- The complete current TypeSchema prefix passed `67/67`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-ic255-typeschema-full-green-attempt-2/20260810_030403_223_eb384cce`.
  Its final Development Editor build passed at
  `Saved/Build/cache-ic255-public-factory-controller-green-build-attempt-1/20260810_030304_668_3b3f9425`.
- Evidence ceiling: this proves the current TypeSchema producer/decoder and
  hostile-input allocation matrix, not the complete Cache prefix, real clean-
  compiled module capture, Saved Store or runtime lifecycle. Those gates remain
  open and are not inferred from the TypeSchema result.

## V1 complete Cache Archive regression gate — 2026-08-10

- The first post-TypeSchema complete run discovered the current `245` methods and
  passed `244`; the sole failure was the historical IC-227 requirement that the
  UE allocator expose an extra whole-element slack boundary for
  `FAngelscriptCachedDataType`. Artifact:
  `Saved/Tests/cache-ic255-complete-cache-regression-attempt-1/20260810_030614_106_9a1deb05`.
- UE 5.8 legitimately returned exact reserve capacity for that large element
  across the searched range. The corrected test retains the TCHAR real-slack
  witness and validates the typed exact-reserve branch with the same independent
  charge, actual allocation equality, event chronology and total/resident
  one-byte-short failures. The focused method passed `1/1` at
  `Saved/Tests/cache-ic227-allocator-portability-green-attempt-1/20260810_030844_814_01c9b869`;
  Archive.Primitives passed `13/13` at
  `Saved/Tests/cache-ic227-archive-primitives-green-attempt-1/20260810_030925_600_439a1b33`.
- The authoritative complete Cache prefix then passed `245/245`, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v1-complete-cache-green-attempt-1/20260810_030957_530_7bdf5872`.
  The linked UE 5.8 Development Editor build is
  `Saved/Build/cache-ic227-allocator-portability-green-build-attempt-1/20260810_030822_915_5ba5414a`.
- Evidence ceiling: all currently registered Cache Archive/module-artifact tests
  are GREEN. V1.4/V1.5 still require the complete real clean-compiled module
  transaction; no Saved Store, compiler/VM attachment, cold/warm/edit lifecycle,
  Editor/PIE or package behavior is inferred from this result.

## V2.2 Saved Store namespace first slice — 2026-08-10

- A new dedicated `Angelscript.TestModule.Cache.Store` file fixes the public
  atomic-file seam and exact full-width namespace/final-path contract without
  adding more cases to the large TypeSchema test source.
- The intended missing-API RED is
  `Saved/Build/cache-v2-store-paths-red-attempt-1/20260810_031738_249_27e83ecf`.
  After the first link, runtime execution exposed and then closed IC-256 rather
  than treating the build as sufficient evidence.
- The corrected Development Editor build passed at
  `Saved/Build/cache-v2-store-paths-green-build-attempt-2/20260810_032216_588_a64e17a4`;
  the focused Store prefix passed `1/1`, failed/skipped `0/0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v2-store-paths-green-attempt-2/20260810_032232_335_847b4f99`.
- Evidence ceiling: canonical base -> exact compatibility/context namespace,
  `Packs`, `Generations`, three pointer filenames and full-hash Pack/Manifest
  final names only. Default/override selection, strict temp names, production
  filesystem operations and immutable installation remain open V2.2 work.

## V2.2 immutable Pack and Manifest publication seam — 2026-08-10

- Default and relative-override root selection, canonical WriterToken parsing and
  the five same-directory temp-name forms are now executable tests rather than
  document-only rules. The Store never accepts abbreviated compatibility,
  context, Pack or Generation identities in final paths.
- An existing identical Pack is reopened, fully validated and byte-compared
  without mutation. A missing Pack follows write/flush/close -> reopen -> complete
  validation -> no-replace rename -> `Packs` directory sync -> final reopen and
  complete revalidation. A corrupt reopened temp fails before rename and removes
  only its own exact temp through the injectable seam. IC-257 records the narrow
  cleanup-boundary correction.
- A missing Manifest follows the analogous immutable flow, but both its temp and
  final validation also reopen every referenced Pack from the final `Packs`
  directory. IC-258 records why the first runtime attempt terminated in fixture
  construction and why production validation was retained unchanged.
- The current Development Editor build passed at
  `Saved/Build/cache-v2-store-manifest-fixture-green-build-attempt-1/20260810_034610_467_120aa967`.
  The complete Store prefix passed `9/9`, failed/skipped `0/0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v2-store-manifest-install-green-attempt-2/20260810_034634_256_49d26b31`.
- Evidence ceiling: this proves deterministic Store control flow against the
  injected atomic-file seam. No production platform file implementation, real
  directory durability, pointer/lock/rebase protocol, reader pinning, startup
  restore or lifecycle integration is inferred from it.

## V2.2 production Win64 Saved Store closure — 2026-08-10

- The production factory now supplies a Win64 atomic-file implementation using
  `CREATE_NEW` temp creation, complete writes plus `FlushFileBuffers`, physical
  reopen/read, `MoveFileExW(MOVEFILE_WRITE_THROUGH)` for no-replace immutable
  rename, `MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH` for pointer
  replacement, and exact pointer/temp deletion. It rejects non-fixed volumes and
  resolves the nearest existing parent through the OS before rebuilding missing
  descendants, so root identity includes junction/symlink resolution.
- IC-259 added the missing first-launch directory operation. Starting below a
  genuinely absent `FirstLaunch/CacheV2`, Store creates Base, Namespace, Packs and
  Generations, then re-canonicalizes all authoritative descendants. The intended
  missing-API RED is
  `Saved/Build/cache-v2-store-first-launch-directories-red-attempt-1/20260810_035423_192_10ec3f0b`;
  its GREEN build is
  `Saved/Build/cache-v2-store-first-launch-directories-green-build-attempt-1/20260810_035625_962_60732ecb`.
- The physical Saved tests first passed `3/3` at
  `Saved/Tests/cache-v2-store-first-launch-directories-green-attempt-1/20260810_035648_039_a73d5ea2`.
  They then passed `4/4` after installing a real valid Pack plus its referencing
  Manifest, reopening both physical finals, repeating both put-if-absent calls as
  unchanged reuse and proving no `.tmp.` residue:
  `Saved/Tests/cache-v2-store-real-generation-green-attempt-1/20260810_035834_725_528314e3`.
- The combined injected/physical Store prefix passed `13/13` at
  `Saved/Tests/cache-v2-store-v22-complete-green-attempt-1/20260810_035909_690_48032542`.
  The complete Cache prefix passed `258/258`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v2-store-v22-full-cache-green-attempt-1/20260810_035954_026_4c7d56d2`.
- Evidence ceiling: V2.2 is GREEN for the currently validated Win64 product
  target. Linux/macOS atomic-file implementations, namespace locking, pointer
  wire/control flow, rebase, pinned readers, real compiled generation capture,
  startup activation, Editor/PIE and packages remain separate open gates.

## V2.3 fixed Pointer wire first slice — 2026-08-10

- Pointer schema 1 now has executable coverage for exact `UEASCV2C` magic,
  little-endian schema, filename-kind byte, zero reserved bytes, nonzero full
  GenerationId, direct BLAKE3 checksum, exact EOF and invalid-output reset. The
  complete Current value is additionally frozen as one independent 80-byte
  hexadecimal golden.
- IC-260 records why the first runtime attempt was a CQTest conversion Ensure
  rather than a serializer mismatch. The corrected comparison passed `3/3` at
  `Saved/Tests/cache-v2-store-pointer-wire-diagnostic-attempt-1/20260810_041109_480_f9700514`.
- The intended hard-coded-golden RED passed `2/3` and exposed the exact complete
  wire at
  `Saved/Tests/cache-v2-store-pointer-golden-red-attempt-1/20260810_041248_309_6af2652d`.
  The frozen-golden Development Editor build passed at
  `Saved/Build/cache-v2-store-pointer-golden-green-build-attempt-1/20260810_041332_597_580435e3`;
  the same Pointer prefix then passed `3/3`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v2-store-pointer-golden-green-attempt-1/20260810_041350_418_886c8be2`.
- Evidence ceiling: only in-memory Pointer encoding/decoding is GREEN. V2.3
  remains open for the namespace lock, physical old-or-new pointer publication,
  reread/rebase, injected failure/commit-state matrix and concurrent processes.

## V2.3 writer lock, pointer publication and rebase control plane — 2026-08-10

- The canonical namespace lock name is now the domain-separated full-width hash
  of the normalized namespace identity. Acquisition is cancellation-aware and
  deadline-bounded in at most 100 ms wait slices, with exact `LockTimeout` and
  `Cancelled` results before mutation. The injectable lock control flow passed
  `4/4` at
  `Saved/Tests/cache-v2-store-lock-control-green-attempt-1/20260810_042020_131_57dcf090`.
  The production system-wide lock and real competing-thread timeout/reacquire
  path passed as part of `5/5` StoreDisk tests at
  `Saved/Tests/cache-v2-store-production-lock-green-attempt-1/20260810_042229_022_65490f03`.
- All three pointer kinds now have independent exact 80-byte schema-1 goldens.
  `PublishAngelscriptCachePointers()` validates its temporary wire by reopening
  it, commits Previous before Current, treats successful Current replacement as
  the commit point, rereads Current after an indeterminate replace, preserves the
  committed state across a later directory-sync/cancellation failure, and keeps
  PendingColdStart isolated from Current/Previous rotation. The publication
  matrix first passed `8/8` at
  `Saved/Tests/cache-v2-store-pointer-publication-green-attempt-1/20260810_042800_536_315e2380`;
  all pointer goldens/publication cases passed `11/11` at
  `Saved/Tests/cache-v2-store-all-pointer-goldens-green-attempt-1/20260810_043116_309_b74b5c5b`.
- `ReadAngelscriptCachePointerSlot()` now distinguishes physically absent slots
  from malformed present slots, returns the exact pointer-stage error, and
  clears output on every failure. The complete pointer prefix passed `12/12` at
  `Saved/Tests/cache-v2-store-pointer-reread-green-attempt-1/20260810_043410_940_afa5caf7`.
- The pure locked-rebase decision now distinguishes unchanged observed bases,
  semantic no-op generations whose only difference is Pack placement, changed
  source/profile coordinates requiring authoritative caller revalidation, and
  same-source semantic conflicts. Its intended missing-API RED is
  `Saved/Build/cache-v2-store-rebase-decision-red-attempt-1/20260810_043606_216_55a42795`.
  The linked Development Editor GREEN is
  `Saved/Build/cache-v2-store-rebase-decision-green-build-attempt-1/20260810_044237_709_751463ad`;
  the focused StoreRebase prefix passed `6/6`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v2-store-rebase-decision-green-attempt-1/20260810_044256_185_715dc8df`.
- Evidence ceiling: these are the Store control-plane primitives, not the full
  V2.3 writer transaction. The locked physical reread still needs to open and
  completely validate the selected Manifest plus every referenced Pack before
  rebase; the high-level transaction must connect immutable installation,
  lock/reread/rebase and pointer publication; stale-temp ownership, abandoned
  writer recovery, concurrent no-op/conflict behavior and the complete injected
  fault matrix remain open. Reader handle pinning and cumulative Budget are V2.4.

## V2.3 locked generation reread and composed writer transaction — 2026-08-10

- `ReadAndValidateAngelscriptCacheGenerationUnderLock()` now makes namespace-lock
  ownership explicit in its API, reads the selected Manifest once, reads every
  distinct referenced Pack once, delegates all archive meaning to the sole
  `ValidateAngelscriptCacheGeneration()` authority, preserves exact nested
  validation diagnostics and clears output atomically on every failure. IC-261
  preserves the mixed fixture build and the clean missing-API RED. The GREEN
  Development Editor build is
  `Saved/Build/cache-v2-store-generation-read-green-build-attempt-1/20260810_044911_534_fec73331`;
  the focused prefix passed `5/5`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v2-store-generation-read-green-attempt-1/20260810_044928_760_3e9bd764`.
- `PublishAngelscriptCacheGeneration()` composes request validation, bounded lock
  acquisition, first-launch directories, selected-slot reread, complete
  generation validation, rebase classification, immutable Pack/Manifest install
  and Current/Previous or Pending pointer publication. Exact Current reuse is a
  fully validated write-free no-op; different-source concurrent change returns
  `NeedsSourceRevalidation` before file mutation.
- IC-262's focused RED proved that the first composition incorrectly blocked a
  new source-validated publication when old Current content was corrupt. The
  corrected rule treats an unchanged observed-but-invalid Current as a
  non-reusable base, preserves an existing valid Previous, and publishes the new
  Current without rotating corruption. The fix built at
  `Saved/Build/cache-v2-store-corrupt-current-repair-green-build-attempt-1/20260810_050004_387_cd699be7`;
  the five transaction methods passed at
  `Saved/Tests/cache-v2-store-corrupt-current-repair-green-attempt-1/20260810_050020_222_b0579c7f`.
- The production Win64 path published two real generations through the system-
  wide lock and physical atomic-file implementation, rotated the first into
  Previous, reacquired the lock, reopened/validated both complete generations,
  repeated the winner as a write-free no-op and left zero temporary files. The
  linked build is
  `Saved/Build/cache-v2-store-physical-transaction-build-attempt-1/20260810_050202_908_eb3b368a`;
  StoreDisk passed `6/6` at
  `Saved/Tests/cache-v2-store-physical-transaction-attempt-1/20260810_050220_017_61b8fadc`.
- The complete composed Store prefix passed `47/47`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v2-store-v23-transaction-regression-attempt-1/20260810_050700_720_23dda09a`.
  The complete Cache prefix passed `292/292`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v2-store-v23-full-cache-regression-attempt-1/20260810_050737_676_b3935c7b`.
- IC-263 extends this into an all-physical-root snapshot. Every publication now
  reads Current, Previous and Pending pointers in fixed order under the same lock,
  fully validates each distinct referenced Generation before the first write, and
  reuses one validation result when multiple slots point to the same full
  GenerationId. The intended all-root RED was `5/6`; its GREEN was `6/6` at
  `Saved/Tests/cache-v2-store-all-roots-green-attempt-1/20260810_051643_472_c86cb75e`.
  The explicit duplicate-root RED was `6/7`; full-ID deduplication then passed
  `7/7` at
  `Saved/Tests/cache-v2-store-duplicate-roots-green-attempt-1/20260810_051914_374_fcec274c`.
- After all-root composition, the complete Store prefix passed `49/49`, failed/
  skipped `0/0`, at
  `Saved/Tests/cache-v2-store-all-roots-regression-attempt-1/20260810_051953_912_edd8910b`;
  the complete Cache prefix passed `294/294`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v2-store-all-roots-full-cache-regression-attempt-1/20260810_052027_889_4a57adb1`.
- Evidence ceiling: V2.3 is still open. The writer must clean only strictly
  recognized stale temps, enforce the writer pack-count limit, and pass every
  deterministic fault/cancellation/indeterminate-commit and same-source
  concurrency/abandoned-writer recovery case. Pinned read sessions, cumulative
  open budget and compaction remain V2.4; real cold module generation remains
  V2.5.

## V2.3 strict crash-temp cleanup and writer integration — 2026-08-10

- Runtime now enumerates only direct non-directory basenames in the exact
  Namespace, Packs and Generations directories after acquiring the namespace
  lock. It completes all three enumerations before the first removal, accepts
  only the five frozen final-name-plus-canonical-WriterToken forms, sorts and
  deduplicates exact candidate paths, and never uses a recursive glob or age
  heuristic. Invalid, final, wrong-directory and nested names remain untouched.
- The first focused implementation run exposed IC-264 in the test double rather
  than the parser: a case-insensitive `TMap` collapsed a lowercase valid Pack
  temp with its uppercase-invalid sibling. The corrected case-sensitive fixture
  passed `2/2` at
  `Saved/Tests/cache-v2-store-stale-temp-fixture-green-attempt-1/20260810_053202_488_fc38f86b`.
  The production Win64 filesystem/lock test passed inside `StoreDisk 7/7` at
  `Saved/Tests/cache-v2-store-stale-temp-disk-attempt-1/20260810_053754_972_5b145538`.
- The composed publisher test first failed as intended because the old Pack temp
  remained after a successful generation publication:
  `Saved/Tests/cache-v2-store-stale-temp-publisher-red-attempt-1/20260810_053947_834_c2f21925`.
  `PublishAngelscriptCacheGeneration()` now invokes cleanup after directory
  validation and before reading Current, Previous or Pending. The same method
  passed at
  `Saved/Tests/cache-v2-store-stale-temp-publisher-green-attempt-1/20260810_054137_617_de2a108f`.
- A stale-temp delete failure is best-effort and non-fatal because temp names are
  never reader inputs. Publication continues, leaves the undeleted temp intact
  and emits only numeric Store Error/Stage/PathCategory/platform code without an
  absolute path. IC-265 records the expected-log correction; the transaction
  prefix passed `9/9` with zero warning/error report entries at
  `Saved/Tests/cache-v2-store-stale-temp-transaction-attempt-2/20260810_054437_221_3e4ebf9b`.
- The complete affected Store prefix passed `54/54`, failed/skipped/warnings
  `0/0/0`, at
  `Saved/Tests/cache-v2-store-stale-temp-store-regression-attempt-1/20260810_054523_493_fac16646`.
  The complete Cache prefix passed `299/299`, failed/skipped/warnings `0/0/0`, at
  `Saved/Tests/cache-v2-store-stale-temp-cache-regression-attempt-1/20260810_054558_128_2e579d21`.
- The writer-side Pack-count gate now delegates to the same canonical Manifest
  value validator used by encode/decode, with the caller's actual limits. The
  intended transaction RED returned at `ManifestTemp` only after Store calls,
  proving the missing preflight:
  `Saved/Tests/cache-v2-store-pack-limit-red-attempt-1/20260810_055108_604_1403a492`.
  The shared validation entry and Store preflight built at
  `Saved/Build/cache-v2-store-pack-limit-green-build-attempt-1/20260810_055232_378_9a585629`.
  The transaction prefix then passed `11/11` at
  `Saved/Tests/cache-v2-store-pack-limit-green-attempt-1/20260810_055255_799_38105387`:
  two distinct PackIds with limit one return `ContentValidationFailed` at Store
  `SessionPin`, nested `BudgetExceeded/ManifestDecode` at byte `181`, before lock
  or filesystem calls; one Pack with the same positive limit commits normally.
- After the Pack-count gate, the Store prefix passed `56/56` at
  `Saved/Tests/cache-v2-store-pack-limit-store-regression-attempt-1/20260810_055335_546_a453b0e9`
  and the complete Cache prefix passed `301/301` at
  `Saved/Tests/cache-v2-store-pack-limit-cache-regression-attempt-1/20260810_055409_704_4cfc3f84`;
  both had failed/skipped/warnings `0/0/0`.
- Evidence ceiling: stale-temp cleanup and the writer MaxGenerationPacks gate are
  now GREEN for the composed writer and current production Win64 target, but
  V2.3 remains open for the complete fault/cancellation and indeterminate-commit
  matrix and concurrent/abandoned-writer recovery. Pinned read sessions and
  compaction remain V2.4.

## V2.3 transaction failure and concurrent-winner closure — 2026-08-10

- Five high-level transaction cases now freeze the publication state beyond the
  lower-level immutable/pointer seams: cancellation after Pack commit leaves only
  an orphan immutable Pack; Manifest write failure removes only its own temp;
  Manifest directory-sync failure leaves complete orphan Pack+Manifest finals but
  no pointer; failed Current replacement preserves old Current while new finals
  remain orphaned; and an indeterminate replacement that actually installed the
  new pointer rereads the slot and reports `CurrentCommitted`. The linked build is
  `Saved/Build/cache-v2-store-transaction-fault-matrix-build-attempt-1/20260810_055822_711_ebae325d`;
  the then-16-method transaction prefix passed at
  `Saved/Tests/cache-v2-store-transaction-fault-matrix-attempt-1/20260810_055843_374_70d51e04`.
- A valid concurrent Current with the same Compatibility/Context/Profile,
  SourceSnapshot, keyed roots and exact Manifest RecordId set but a distinct
  physical Pack/Generation layout is accepted as the winner. The losing publisher
  returns a write-free `NotCommitted` no-op, reports the concurrent GenerationId
  before/after, leaves its own prepared Pack/Manifest absent, and does not rotate
  Previous. This built at
  `Saved/Build/cache-v2-store-concurrent-semantic-build-attempt-1/20260810_060058_981_2f7c48c0`
  and the focused method passed `1/1`, warnings/errors `0/0`, at
  `Saved/Tests/cache-v2-store-concurrent-semantic-attempt-1/20260810_060116_725_7ed839df`.
- The complete composed transaction then passed `17/17`, failed/skipped/warnings
  `0/0/0`, at
  `Saved/Tests/cache-v2-store-transaction-fault-concurrency-regression-attempt-1/20260810_060545_953_9bf3bb9c`.
  The affected Store prefix passed `62/62` at
  `Saved/Tests/cache-v2-store-v23-final-regression-attempt-1/20260810_060633_788_d0143acc`,
  and the complete Cache prefix passed `307/307` at
  `Saved/Tests/cache-v2-v23-final-regression-attempt-1/20260810_060707_065_21b4eee1`;
  both had failed/skipped/warnings `0/0/0` and process/wrapper exit `0/0`.
- V2.3 is GREEN at its declared namespace-lock, all-root reread/rebase and
  old-or-new Current/Previous/Pending publication boundary. This does not consume
  V2.4: immutable handle pinning, cumulative selection Budget and explicit
  compaction remain unimplemented. It also does not consume V2.6: exhaustive
  execution at every named fault point, concurrent pinned readers/writers and
  later real multi-process/package evidence remain required there.

## V2.4 production immutable pinned-handle seam — 2026-08-10

- The first read-session RED added an independent
  `AngelscriptCacheStoreReadSessionTests.cpp` instead of expanding the already
  large transaction or TypeSchema files. It required a persistent immutable-file
  handle and failed to compile only because
  `IAngelscriptCachePinnedFileHandle`/`OpenReadPinned` did not exist:
  `Saved/Build/cache-v2-store-pinned-handle-red-attempt-1/20260810_061301_824_5c66e10b`.
- Runtime now exposes a narrow pinned-file interface. The Win64 production file
  seam opens with `FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE`, records
  the exact open-time size, owns the native handle until session release, and
  performs complete reads from that same handle. Writer-only test doubles inherit
  an explicit unsupported default instead of receiving broad test-only pin logic.
- The GREEN test writes object A, pins it, unlinks its final path while the handle
  stays open, installs object B at the same path, then proves the pinned handle
  still reads A while `ReopenReadAll` observes B. The Development Editor build is
  `Saved/Build/cache-v2-store-pinned-handle-green-build-attempt-1/20260810_061407_043_1f836017`;
  the focused production test passed `1/1`, failed/skipped/warnings `0/0/0`, at
  `Saved/Tests/cache-v2-store-pinned-handle-green-attempt-1/20260810_061424_553_5621724c`.
- Evidence ceiling: this proves the required platform primitive, not the complete
  V2.4 session. Manifest-first bounded Pack discovery, every distinct Pack handle
  pinned before releasing the namespace lock, validation solely through those
  handles, one cumulative Budget across fallback candidates, session-owned
  lifetime and compaction/deferred-delete behavior remain open.

## V2.4 pinned generation session and cumulative candidate Budget — 2026-08-10

- The session-level API RED published one real Current generation and required
  `OpenBestAngelscriptCacheReadSession`, the selection coordinates and a session
  owning the validated generation/Budget/handles. The Development build failed
  only because those production types and entry point did not exist:
  `Saved/Build/cache-v2-store-read-session-api-red-attempt-1/20260810_061635_593_792b0492`.
- Manifest validation now has one private move-only Prepare/Complete transaction.
  Prepare performs the existing canonical Manifest decode exactly once and keeps
  its Budget reservations plus sorted distinct PackIds. The Store pins the
  Manifest and every distinct Pack under the namespace lock, releases that lock,
  reads Pack bytes only through the retained handles, then Complete reuses the
  same decoded Manifest for Pack/record/reachability validation. The public
  one-shot `ValidateAngelscriptCacheGeneration` delegates through the same two
  phases, so no second decoder or alternate Manifest authority was introduced.
- IC-266 records two MSVC DLL-linkage build failures caused by making the exported
  open function also a private-constructor friend. A non-exported internal factory
  now owns construction, and the production/API build passed at
  `Saved/Build/cache-v2-store-read-session-green-build-attempt-3/20260810_062225_263_e3c282dd`.
  The first production handle plus Current-session methods passed `2/2` at
  `Saved/Tests/cache-v2-store-read-session-green-attempt-1/20260810_062245_825_96f65add`.
- The expanded independent matrix proves: Pack reads occur after namespace unlock;
  an ineligible Current is rejected after Manifest coordinates without opening its
  Pack and then Previous is selected; released candidate reservations do not refund
  the attempt's total decoded Budget; a limit one byte below the measured combined
  attempt returns nested `BudgetExceeded` instead of succeeding through a reset;
  and `MaxGenerationPacks=1` rejects a two-Pack Manifest at `SessionPin` with zero
  Pack handle opens. IC-267 records the isolated fixture field-name correction.
  The matrix build passed at
  `Saved/Build/cache-v2-store-read-session-matrix-build-attempt-2/20260810_062620_859_1d311eb7`
  and the focused prefix passed `6/6`, failed/skipped/warnings `0/0/0`, at
  `Saved/Tests/cache-v2-store-read-session-matrix-attempt-1/20260810_062638_286_ed2c5cad`.
- After the Manifest validator split, the complete Store prefix passed `68/68` at
  `Saved/Tests/cache-v2-store-read-session-regression-attempt-1/20260810_062721_343_dfebae1e`
  and the complete Cache prefix passed `313/313` at
  `Saved/Tests/cache-v2-read-session-regression-attempt-1/20260810_062754_815_70cbbcad`;
  both had failed/skipped/warnings `0/0/0` and process/wrapper exit `0/0`.
- Evidence ceiling: Current/Previous pinned selection and cumulative attempt Budget
  are GREEN. PendingColdStart exclusion versus fresh-cold eligibility, redundant
  Pending cleanup after promotion, physical-root retention, explicit two-phase
  compaction, deferred pinned-reader deletion and intervening-writer remark/sweep
  remain required before V2.4 can close.

## V2.4 Pending selection and post-promotion cleanup — 2026-08-10

- The focused TDD method starts with Pending selecting the generation being
  promoted to Current. The test-only build passed at
  `Saved/Build/cache-v2-pending-promotion-red-build-attempt-1/20260810_063353_798_19f5320e`.
  IC-268 preserves the first zero-match runner invocation; the corrected full
  CQTest path executed `1/1` and failed only because Pending remained after the
  Current commit at
  `Saved/Tests/cache-v2-pending-promotion-red-attempt-2/20260810_063454_914_9c392ecb`.
- `PublishAngelscriptCachePointers()` now completes the normal Current replace and
  directory sync, rereads Pending while the same namespace lock is still held,
  and removes it only when it still selects the promoted full GenerationId. The
  removal is followed by another directory sync. Cancellation is not consulted
  after Current's commit point, and neither removal nor its sync can downgrade or
  roll back `CurrentCommitted`.
- The Runtime fix built at
  `Saved/Build/cache-v2-pending-promotion-green-build-attempt-1/20260810_063559_810_66a17b4b`;
  the identical focused method then passed `1/1` at
  `Saved/Tests/cache-v2-pending-promotion-green-attempt-1/20260810_063620_964_bb849844`.
- Companion pointer-publication coverage proves a different/newer Pending
  Generation is preserved, matching-Pending removal occurs strictly after the
  Current replace, `PointerRemoveFailed` retains the pointer and reports
  `CurrentCommitted`, and post-removal `DirectorySyncFailed` reports the same
  committed state with Pending already absent. IC-269 preserves the one stale
  four-call expectation exposed by the first class rerun.
- Read-session coverage separately proves an already-active selection performs
  only Current and Previous attempts and never opens a Pending Manifest/Pack,
  while a caller explicitly marked fresh/cold eligible reaches the third
  candidate and returns a pinned Pending session. Thus a PIE/ordinary soft reload
  cannot accidentally activate the cold structural candidate.
- The companion matrix build passed at
  `Saved/Build/cache-v2-pending-selection-matrix-build-attempt-1/20260810_063915_608_affc9b8f`.
  The complete Store prefix passed `74/74`, failed/skipped `0/0`, process/wrapper
  exit `0/0`, at
  `Saved/Tests/cache-v2-pending-selection-store-regression-attempt-1/20260810_063937_534_cbb2837a`.
  The complete Cache prefix passed `319/319` with the same clean result at
  `Saved/Tests/cache-v2-pending-selection-cache-regression-attempt-1/20260810_064013_415_c0f71eef`.
- Evidence ceiling: pinned Current/Previous/Pending selection, fresh-versus-active
  exclusion, matching promotion cleanup and committed cleanup-failure semantics
  are GREEN. V2.4 remains open for physical-root retention and the explicit
  two-phase compaction/GC protocol, including re-mark after an intervening writer
  and deletion deferral for pinned readers.

## V2.4 explicit compaction authority and Phase A rewrite — 2026-08-10

- The first API RED required an explicit nonzero Profile+SourceSnapshot authority,
  a production compaction entry point and a final-immutable deletion seam. The
  Development Editor build failed only because those interfaces were absent at
  `Saved/Build/cache-v2-compaction-authority-red-attempt-1/20260810_064734_315_0f38ee0c`.
  The minimal authority gate and seam then built at
  `Saved/Build/cache-v2-compaction-authority-green-build-attempt-1/20260810_064946_278_180df064`;
  the exact missing-authority method passed `1/1` at
  `Saved/Tests/cache-v2-compaction-authority-green-attempt-1/20260810_065003_983_4ec45315`.
- The Phase A RED installed one valid generation whose physical Pack also held an
  unreachable extra record. It required compaction to rebuild only the rooted
  semantic union, publish a distinct Current generation, preserve every old/new
  immutable object, release/reacquire the namespace lock, and then report a
  committed cancellation before Phase B. The linked test failed only because the
  implementation still returned the Phase B `UnsupportedPlatformAtomicity`
  placeholder at
  `Saved/Tests/cache-v2-compaction-phase-a-red-attempt-1/20260810_065400_548_b41a5187`.
- Runtime now performs Phase A under the namespace lock: it reads/deduplicates all
  three physical slots, fully validates each retained generation through the
  caller's cumulative Budget, removes only an authority-ineligible Pending,
  rebuilds the reachable union with the supplied Pack policy, installs replacement
  immutable objects, and rewrites Previous/Pending/Current in same-slot order.
  It deletes no final Pack or Manifest before releasing and reacquiring the lock.
- The implementation compiled at
  `Saved/Build/cache-v2-compaction-phase-a-green-build-attempt-1/20260810_070301_303_c85c23e2`.
  IC-268 preserves the first address-only zero-match run. The corrected exact
  Phase A method passed `1/1` at
  `Saved/Tests/cache-v2-compaction-phase-a-green-attempt-2/20260810_070410_277_e2cac4fe`,
  and the complete independent StoreCompaction class passed `2/2`, failed/skipped
  `0/0`, process/wrapper exit `0/0`, at
  `Saved/Tests/cache-v2-compaction-phase-a-class-green-attempt-1/20260810_070453_308_e4e3c559`.
- Evidence ceiling: this is Phase A only. IC-270 remains open. Phase B must still
  reread and mark all current physical roots after reacquiring the lock, preserve
  an intervening writer, filter exact direct-child final names, sweep unmarked
  Packs/Manifests, classify pinned sharing refusal as committed `DeleteDeferred`,
  retry later, and prove the production Win64 behavior before V2.4 can close.

## V2.4 compaction Phase B and lifetime closure — 2026-08-10

- The first Phase B mark/sweep RED linked at
  `Saved/Build/cache-v2-compaction-phase-b-sweep-red-build-attempt-1/20260810_070909_309_52095971`
  and executed at
  `Saved/Tests/cache-v2-compaction-phase-b-sweep-red-attempt-1/20260810_070926_757_28b4c8ee`.
  It failed because the compactor still returned its deliberate Phase B
  placeholder instead of re-marking and sweeping after lock reacquisition.
- Runtime Phase B now rereads Current, Previous and Pending after reacquiring the
  namespace lock, fully prepares each distinct retained Manifest under the same
  cumulative Budget, marks its Manifest and referenced Packs, accepts only strict
  direct-child `<lower-full-hash>.aspack`/`.asmanifest` finals, removes only
  unmarked objects through `RemoveFinalImmutable`, and directory-syncs immediately
  after every successful deletion. The basic method passed `1/1` at
  `Saved/Tests/cache-v2-compaction-phase-b-sweep-green-attempt-2/20260810_071820_372_9711199e`.
- The concurrency/deferred pair passed `2/2` at
  `Saved/Tests/cache-v2-compaction-phase-b-concurrency-deferred-green-attempt-1/20260810_072309_714_4f889ea6`.
  A new Pending published between Phase A and B is reread and retained. One
  sharing refusal reports committed `DeleteDeferred`, does not stop deletion of
  other orphans, and succeeds on a later explicit retry.
- The all-three-root/ineligible-Pending pair passed `2/2` at
  `Saved/Tests/cache-v2-compaction-phase-a-three-root-green-attempt-1/20260810_072604_997_4230a77d`.
  Distinct Current/Previous/Pending inputs become one deterministic three-record
  union and are switched in Previous, Pending, Current order. A source/profile-
  ineligible Pending is removed and synced before retained-root switching.
- Cancellation and directory-sync failure passed `2/2` at
  `Saved/Tests/cache-v2-compaction-phase-b-cancel-sync-green-attempt-1/20260810_072823_820_5fc030b1`.
  A completed deletion remains durable before cancellation, and a later sync
  failure reports `CompactionSweep` with `CompactionCommitted`; neither rolls back
  the already-published Phase A roots.
- The pointer-mixture/indeterminate-replace/production-pinned group passed `3/3`
  at
  `Saved/Tests/cache-v2-compaction-phase-a-mixture-pinned-green-attempt-1/20260810_073041_307_5a7216c6`.
  A same-slot switch failure leaves a valid old/new pointer mixture and suppresses
  Phase B; an installed-but-failed final replace is reread and reported committed;
  the production delete-sharing handle stays bound to old bytes after the final
  path is unlinked and reused.
- IC-273's focused RED proved duplicate physical pointers were decoded three
  times at
  `Saved/Tests/cache-v2-compaction-phase-b-dedup-red-attempt-1/20260810_073333_774_355b9c91`.
  Phase B retains three physical pointer reads but now marks each distinct
  GenerationId exactly once. The correction built at
  `Saved/Build/cache-v2-compaction-phase-b-dedup-green-build-attempt-1/20260810_073434_041_8bdace32`
  and the identical method passed `1/1` at
  `Saved/Tests/cache-v2-compaction-phase-b-dedup-green-attempt-1/20260810_073455_131_2d42e274`.
- Final V2.4 verification is clean: StoreCompaction passed `12/12`, failed/skipped
  `0/0`, at
  `Saved/Tests/cache-v2-compaction-phase-ab-class-green-attempt-2/20260810_073602_447_9ad50457`;
  Store passed `86/86` at
  `Saved/Tests/cache-v2-compaction-phase-ab-store-regression-attempt-1/20260810_073635_836_6007f818`;
  the complete Cache prefix passed `331/331` at
  `Saved/Tests/cache-v2-compaction-phase-ab-cache-regression-attempt-1/20260810_073710_751_f947eed3`.
  All three wrappers and engine processes exited `0`; their `Summary.json` files
  report zero failed and zero skipped tests.
- V2.4 is closed at the pinned lifetime and explicit startup-external GC boundary.
  This does not prove V2.5 real compiler capture/cold publication, V2.6 exhaustive
  fault and concurrent-reader/writer coverage, warm restoration, Editor/PIE
  integration or packaged-runtime behavior.

## V2.5 clean-capture and real cold-generation RED — 2026-08-10

- Added one Runtime-integration CQTest at
  `Angelscript.TestModule.Cache.ColdGeneration.NormalCompilePublishesAndFreshSessionReopensStableCompleteGeneration`.
  It uses the normal isolated-full-engine `BuildModule` path twice for one enum
  plus one primitive global function, requires byte-identical pointer-free output
  with exactly one of all seven record kinds, publishes the result through the
  production Pack/Manifest/Store APIs, and reopens it through a new pinned read
  session. It does not construct a synthetic semantic-record fixture.
- Official RED command:
  `Tools\RunBuild.ps1 -Label cache-v2-cold-generation-red -TimeoutMs 180000`.
  The build failed with wrapper exit `1` / process exit `6` only at
  `AngelscriptCacheColdGenerationTests.cpp(1,1)` because the wished-for production
  header `Cache/AngelscriptCacheCleanCapture.h` does not yet exist. Evidence is at
  `Saved/Build/cache-v2-cold-generation-red/20260810_080356_168_b90266b6`.
- This RED proves IC-274's missing production compile-to-record/generation seam.
  It does not yet prove capture correctness, Pack publication, fresh-session
  reopen, restore, incremental reuse, Editor/PIE behavior or packaged startup.

## V2.5 first real cold generation and IC-275 identity correction — 2026-08-10

- The first executable run of the real normal-compile test found one test and
  failed before record production at
  `Saved/Tests/cache-v2-cold-generation-discovery-attempt-2/20260810_082745_495_e10e3597`.
  The normal module exposed the canonical rooted virtual path
  `/Angelscript/Game/ASCacheV2ColdGeneration.as`; clean capture incorrectly passed
  that path and Game's intentionally empty mount name into the mount-relative
  artifact identity builder. `Automation.log` reports `Error=2`, `Records=0` and
  `The module identity cannot be normalized`. IC-275 records the complete API-
  boundary root cause.
- Clean capture now derives the explicit logical mount `Game` and uses only the
  mount-relative `ASCacheV2ColdGeneration.as` coordinate for ModuleKey,
  provider-configuration and SourceIndex mount construction. The identity builder
  still rejects slash-rooted, drive-qualified, UNC and logical-root-escaping input;
  no absolute source path enters identity or payload.
- The official Development Editor build passed with wrapper/process exit `0/0`
  at
  `Saved/Build/cache-v2-cold-generation-ic275-green-build-attempt-1/20260810_083404_499_78cb42fa`.
  The identical class prefix then passed `1/1`, failed/skipped `0/0`, with both
  exits `0`, at
  `Saved/Tests/cache-v2-cold-generation-ic275-green-attempt-1/20260810_083420_661_1fc9425c`.
- The GREEN log is behavioral evidence, not just a return-code assertion: two
  isolated full `FAngelscriptEngine` instances normally compile the same enum and
  primitive global function and independently emit byte-identical sets containing
  exactly SourceIndex, ModuleInterface, TypeSchema, ModuleState, FunctionBody,
  DebugSidecar and ModuleSnapshot. Generation preparation emits one Pack and seven
  reachable records, production Store publication commits Current, and a new
  pinned read session reopens the identical Generation with one pinned Pack and
  2641 stored bytes.
- Evidence ceiling: this closes IC-275 and proves the first V2.5 cold publication/
  reopen path. It does not yet prove semantic graph decode/reconstruction in a
  second engine, unsupported/malformed fail-closed coverage, V2.6 fault and
  concurrent-reader/writer breadth, unchanged warm restore, Editor/PIE lifecycle,
  or Development/Shipping packages.
- The complete Cache regression then passed `332/332`, failed/skipped `0/0`, with
  wrapper/process exit `0/0`, at
  `Saved/Tests/cache-v2-cold-generation-v25-cache-regression-attempt-1/20260810_083850_433_7e572aed`.
  This includes the new real cold-generation method plus the established Archive,
  semantic record, TypeSchema, ModuleGraph, Manifest/Pack, Store, pointer,
  read-session and compaction coverage. V2.5 is therefore checked complete at its
  stated publication/reopen boundary; V1.4/V1.5 and V2.6 remain independently
  open at the stricter semantic-graph and exhaustive-fault boundaries.

## V1.4/V1.5 real clean-capture graph happy path — 2026-08-10

- Added the production function-artifact codec and made clean capture decode its
  exact emitted payloads through `FAngelscriptDecodedCacheRecordBatch` before
  crossing the sole `ValidateModuleSnapshotGraph` authority. The graph uses the
  maintained-fork detached execution validator, the versioned DebugSidecar
  validator and fail-closed no-external resolvers for this dependency-free first
  vertical. Capture returns no records on graph failure.
- The first runtime attempt reached the opaque FunctionBody validator but failed
  at the exact-length gate. Bounded maintained-fork diagnostics at
  `Saved/Tests/cache-v2-function-artifact-stage-diagnostic-attempt-1/20260810_090031_438_b2758820`
  proved `expected=37 read=31 stream=37 stage=8 error=0 new=1`: the function parsed
  and the stream consumed all bytes, while `asCReader::ReadString` omitted the
  six-byte function name from `bytesRead`. The accounting-only correction built
  at
  `Saved/Build/cache-v2-function-artifact-byte-count-green-build-attempt-1/20260810_090131_029_cb507c7b`
  and the next run advanced beyond opaque validation.
- The next RED reported `MissingCoverage` at TypeSchema offset `68` even though
  type/function keys matched exactly. This is the TypeKind field: the local
  TypeSchema decoder fully validated the simple Enum, while the graph supported
  only Class/Struct/Interface. Narrow admission for the no-relations/no-layout/
  no-method simple Enum form built at
  `Saved/Build/cache-v2-enum-graph-coverage-green-build-attempt-1/20260810_090730_099_30bd61f0`;
  the next runtime run passed the graph and reached only the capture postcondition.
- The final postcondition defect was ownership, not reachability. SourceIndex is
  generation/context authority consumed by graph validation but is deliberately
  not a ModuleSnapshot-owned graph ordinal. Clean capture now proves exact
  coverage by traversing all decoded records: exactly one external SourceIndex
  plus every other record found through the sole graph. It reports the observed
  count rather than requiring a synthetic constant.
- Official Development Editor build passed with wrapper/process exit `0/0` at
  `Saved/Build/cache-v2-complete-graph-context-coverage-green-build-attempt-1/20260810_090912_969_1ba4b673`.
  The identical focused method passed `1/1`, failed/skipped `0/0`, wrapper/process
  exit `0/0`, at
  `Saved/Tests/cache-v2-complete-graph-context-coverage-green-attempt-2/20260810_091116_709_c8599729`.
  Its log proves two isolated full-engine normal compiles each report
  `Records=7 GraphRecords=7`, emit byte-identical artifacts, prepare one Pack,
  publish Current and reopen seven records from the same Generation through a
  fresh pinned session.
- Evidence ceiling: this closes the real clean-capture/factory/graph happy path,
  but does not yet close IC-276 or V1.4/V1.5. Explicit corrupt/truncated execution
  and debug artifacts still must be rejected at the production opaque/graph
  boundary with empty returned capture/graph state. The enum change also still
  needs its affected focused ModuleGraph regression, followed by the complete
  Cache prefix. V2.6, warm restore, incremental reuse, Editor/PIE and packaged
  runtime remain unverified.

## IC-280 opaque artifact atomic-promotion RED — 2026-08-10

- Added the separate Runtime-integration class
  `Angelscript.TestModule.Cache.CleanCaptureOpaqueValidation`. It starts from a
  normal full-engine compile/capture, changes only the inner execution or debug
  opaque bytes, recomputes the surrounding semantic hash, RecordId and
  ModuleSnapshot link chain, and asks the wished-for production validation/
  promotion boundary to reject truncated and corrupt variants. Output is seeded
  with non-empty candidate data so a missing reset cannot pass accidentally.
- Official RED command:
  `Tools\\RunBuild.ps1 -Label cache-v2-opaque-atomic-promotion-red-attempt-1
  -TimeoutMs 180000`. The Development Editor build failed with wrapper/process
  exit `1/6` only because
  `ValidateAndPromoteAngelscriptCleanCompiledModuleArtifacts` is absent; C3861 is
  at the new test line 362. Evidence is at
  `Saved/Build/cache-v2-opaque-atomic-promotion-red-attempt-1/20260810_092220_271_dad54890`.
- This RED proves a reusable atomic promotion seam is missing. It is not evidence
  that the existing happy-path codec/graph failed, and no Runtime source changed
  before the RED.

## IC-280 first runtime GREEN attempt and IC-281 side-effect RED — 2026-08-10

- The atomic promotion API and normal-capture routing built successfully with
  wrapper/process exit `0/0` at
  `Saved/Build/cache-v2-opaque-atomic-promotion-green-build-attempt-1/20260810_092325_077_014db2b3`.
- The first focused run at
  `Saved/Tests/cache-v2-opaque-atomic-promotion-green-attempt-1/20260810_092346_320_1e78bb72`
  executed two methods: Debug passed and Execution failed, for `1/2` total.
  Both debug mutations returned `GraphValidationFailed`, `GraphRecords=0`,
  `OutputRecords=0`, DebugSidecar kind and OpaqueCodec stage. Both execution
  mutations produced the same atomic structural result with FunctionBody kind and
  OpaqueCodec stage.
- Execution failed only because detached `asCReader::Error` additionally sent the
  expected malformed-input diagnostics to the engine as global Error messages;
  Automation treats those log events as test errors. IC-281 records the traced
  message-routing root cause. This is a real production validation side effect,
  not a test assertion mismatch, so the test remains unchanged.

## V1.4/V1.5 malformed opaque closure and complete Cache GREEN — 2026-08-10

- `ValidateAndPromoteAngelscriptCleanCompiledModuleArtifacts` is now the one
  production atomic boundary for a pointer-free candidate. It resets output,
  executes the existing exact decoder/production opaque validator/sole module
  graph, and moves the complete candidate to output only after success. Normal
  `CaptureAngelscriptCleanCompiledModule` routes through this same operation; no
  test callback, alternate graph or alternate serializer exists.
- The maintained-fork `asCReader::Error` now suppresses only the global engine
  message while detached function-artifact validation is active. It still records
  error/stage/byte diagnostics and destroys half-created functions. Ordinary
  whole-module bytecode restoration preserves its prior message behavior.
- Official Development Editor build passed with wrapper/process exit `0/0` at
  `Saved/Build/cache-v2-detached-validation-quiet-green-build-attempt-1/20260810_092533_584_bb262966`.
- The focused opaque class passed `2/2`, failed/skipped `0/0`, wrapper/process
  exit `0/0`, at
  `Saved/Tests/cache-v2-detached-validation-quiet-green-attempt-1/20260810_092545_012_02e8db04`.
  Its four locally self-consistent malicious graphs prove:
  - truncated execution: FunctionBody kind, OpaqueCodec stage, offset `36`, zero
    graph records and zero output records;
  - corrupt execution magic: FunctionBody kind, OpaqueCodec stage, offset `1`,
    zero graph records and zero output records;
  - truncated debug: DebugSidecar kind, OpaqueCodec stage, offset `157`, zero graph
    records and zero output records;
  - corrupt debug magic: DebugSidecar kind, OpaqueCodec stage, offset `0`, zero
    graph records and zero output records.
- Normal capture/publication remained GREEN `1/1` at
  `Saved/Tests/cache-v2-opaque-promotion-coldgeneration-regression-attempt-1/20260810_092648_436_9bda5521`.
  Both isolated captures still report `Records=7 GraphRecords=7`, the Generation
  contains one Pack, and the fresh pinned session reopens all seven records.
- The affected `Angelscript.TestModule.Cache.Archive.Module` aggregation passed
  `30/30`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v2-opaque-promotion-module-graph-regression-attempt-1/20260810_092726_150_48b5068d`.
- The complete Cache prefix passed `334/334`, failed/skipped `0/0`, wrapper/process
  exit `0/0`, at
  `Saved/Tests/cache-v2-opaque-promotion-complete-cache-regression-attempt-1/20260810_092759_316_85a24db8`.
  This raises the previous `332/332` baseline by exactly the two new production
  opaque/atomic methods.
- V1 exit evidence is now complete at the supported representative vertical:
  sole factory/graph, two-engine stable capture, typed private-VM rejection before
  attach, atomic empty output, full Runtime/Test build and complete Cache/Archive
  regressions. Unsupported/unrepresentable forms remain fail-closed. This does not
  prove V2.6's exhaustive Store fault/concurrency matrix, V3 warm restore, V4/V5
  incremental compiler reuse, V6 Editor/PIE lifecycle or V7 packaged startup.

## V2.6 exact Store checkpoint audit and RED — 2026-08-10

- Added `v2.6-store-evidence-audit.md`, mapping every frozen required Store/crash
  bullet to current tests. The audit confirms V2.3/V2.4 already cover the Store
  operations, rebase rules, locks, Pack limits, pinned sessions, Pending and
  compaction, but do not expose the twelve exact named process-stop boundaries.
  It also separates simulated changed-root rebase tests from the still-missing
  actual concurrent publisher and live pinned-reader/writer compositions.
- Added the separate production-disk test class
  `Angelscript.TestModule.Cache.StoreFaultInjection`. It requests all five
  immutable checkpoints, all five Current/Previous checkpoints and both Pending
  checkpoints; every case asserts crash-visible state and then requires a new
  publisher to recover through normal cleanup/full reread.
- Official RED command:
  `Tools\\RunBuild.ps1 -Label cache-v26-fault-checkpoint-api-red-attempt-1
  -TimeoutMs 1800000 -NoXGE`. The Development Editor build failed with wrapper/
  process exit `1/6` at
  `Saved/Build/cache-v26-fault-checkpoint-api-red-attempt-1/20260810_094151_509_d35fd5b7`.
  The first compiler error is the missing
  `IAngelscriptCacheStoreFaultInjector`, followed by the missing exact enum,
  distinct result and publication argument. This is the intended missing-API
  RED; no production source changed before it.

## V2.6 exact crash checkpoints, recovery and real-thread concurrency GREEN — 2026-08-10

- Runtime now owns the exact append-only
  `EAngelscriptCacheStoreFaultPoint` names and one optional
  transaction-local `IAngelscriptCacheStoreFaultInjector`. The pointer is never
  retained globally and does not enter any persisted bytes or identity. Pack,
  Manifest and pointer publication route through this one object. A requested
  stop returns `FaultInjected=22`, leaves process-stop-visible disk state and
  reports the exact pre/post-commit state.
- The first production implementation compile attempt found two local wiring
  defects only: the optional argument was patched onto the ReadSession
  declaration instead of the publisher declaration, and the new test used a
  nonexistent `TArray::Count` member. That non-GREEN artifact is preserved at
  `Saved/Build/cache-v26-fault-checkpoint-green-build-attempt-1/20260810_094459_034_0bba3367`.
  The corrected Development Editor build passed with wrapper/process exit `0/0`
  at
  `Saved/Build/cache-v26-fault-checkpoint-green-build-attempt-2/20260810_094550_021_8c6a4ed6`.
- `StoreFaultInjection` passed `3/3`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v26-fault-checkpoint-green-attempt-1/20260810_094615_473_4fbc6148`.
  Its grouped loops executed every exact point once:
  - before Pack write: no temp/final/pointer;
  - after Pack flush: one Pack temp;
  - after Pack rename: only the complete Pack final;
  - after Manifest flush: complete Pack final plus one Manifest temp;
  - after Manifest rename: complete Pack and Manifest finals, no pointer;
  - after all pointer temps and before Previous: old Current, two temps;
  - after Previous and before Current: old Current, Previous equal to old
    Current, one Current temp;
  - after Current: new Current, old Previous, zero temps,
    `CurrentCommitted`;
  - before Pending: active Current/Previous unchanged, one Pending temp; and
  - after Pending: active Current/Previous unchanged, selected Pending, zero
    temps, `PendingCommitted`.
  Every one of the twelve cases then invoked a new normal writer which cleaned
  only recognized stale temps, reread physical roots and finished with the
  intended valid Current/Pending and zero temps.
- The first concurrency test build found only a test-private name collision with
  UE 5.8's global `FScopedEvent`; no Runtime change was needed. That artifact is
  `Saved/Build/cache-v26-store-concurrency-build-attempt-1/20260810_094909_375_71bf0d02`.
  Renaming the pool wrapper built at
  `Saved/Build/cache-v26-store-concurrency-build-attempt-2/20260810_094948_848_9f8ba3d1`.
- `StoreConcurrency` passed `2/2`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v26-store-concurrency-attempt-1/20260810_095009_844_093f6527`.
  Two actual publisher threads released from one barrier against the same
  production namespace produced exactly one `CurrentCommitted` and one fully
  validated write-free `NotCommitted` no-op, with no Previous or temp residue.
  In the reader/writer case, a writer paused at `AfterPointerTempsFlush` while
  holding the namespace lock; an already-open production pinned session continued
  to expose only the old Generation. After release/commit it still exposed old,
  while a newly opened session selected the new Current; temp count was zero.
- Complete Store passed `91/91`, failed/skipped `0/0`, wrapper/process exit
  `0/0`, at
  `Saved/Tests/cache-v26-complete-store-regression-attempt-1/20260810_095050_630_e8a352bd`.
  Complete Cache passed `339/339`, failed/skipped `0/0`, wrapper/process exit
  `0/0`, at
  `Saved/Tests/cache-v26-complete-cache-regression-attempt-1/20260810_095129_212_ebbfbd81`.
  V2.6 is GREEN. Multi-process, GUI Editor, PIE and packaged launches remain the
  later V6/V7 acceptance boundary, not inferred from NullRHI Automation.

## V2.7 standalone Python Cache V2 dump TDD and GREEN — 2026-08-10

- The official wrapper missing-module RED is
  `Saved/Tests/cache-v27-python-red-attempt-2`: exit `1`, structured wrapper
  summary present, first Python error `ModuleNotFoundError: cache_v2_dump`. The
  earlier attempt exposed IC-283's PowerShell stderr transport defect and is not
  the clean behavioral RED.
- The first implementation run at
  `Saved/Tests/cache-v27-python-implementation-attempt-1` executed nine tests:
  seven functional/integrity/filter/corruption tests passed; the only two errors
  were the intentionally not-yet-frozen `valid_root.json` and `valid_root.txt`.
  No parser, hash, link, mutation or exit-code assertion failed.
- The final dependency-free/optionally-accelerated BLAKE3 and wire reader accept
  the existing C++ empty Pack, minimum Manifest and Zlib Pack frozen bytes with
  their exact PackId/GenerationId/RawChecksum/RecordId. The Python suite also
  asserts a deterministic 4097-byte tree vector. Existing C++ Cache tests remain
  the authority for the writer's golden bytes; the Python suite is the sole
  authority for dump-tool behavior.
- Final Python test command:
  `Tools\RunCacheV2DumpTests.ps1 -OutputRoot
  Saved/Tests/cache-v27-python-corruption-attempt-1`. Result `13/13 PASS`,
  wrapper/process `0/0`, zero failures/errors/skips. It covers deterministic
  text/JSON goldens, root/Manifest/Pack input, generation/module/kind/stable-key
  filters, None/Zlib, exact hashes/links/sizes, opaque VM metadata, pointer/Pack/
  Manifest-range corruption, structured CLI errors and before/after file
  snapshots proving no mutation.
- Official Development Editor build:
  `Tools\RunBuild.ps1 -Label cache-v27-python-contract-build -LogRoot
  Saved/Build/cache-v27-python-contract-build -SerializeByEngine`. Wrapper/
  process `0/0` at
  `Saved/Build/cache-v27-python-contract-build/Build/cache-v27-python-contract-build/20260810_101313_339_6b0f2fb1`.
- A temporary focused UE `PythonDumpContract` method passed `1/1`, but review
  found that it only recomputed the same BLAKE3 vector and never executed Python
  or the dump reader. It was removed as redundant; its historical run is not
  retained as V2.7 acceptance authority (IC-285).
- After removing that method and renaming the Python tree-vector test to describe
  its actual ownership, `Tools\RunCacheV2DumpTests.ps1 -OutputRoot
  Saved/Tests/cache-v27-python-test-ownership-correction-2` passed `13/13` with
  wrapper/process `0/0`.
- Complete Cache command:
  `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache -Label
  cache-v27-complete-cache-regression -OutputRoot
  Saved/Tests/cache-v27-complete-cache-regression-attempt-1 -Fast`. Result
  `340/340 PASS`, failed/skipped `0/0`, wrapper/process `0/0`, at
  `Saved/Tests/cache-v27-complete-cache-regression-attempt-1/Tests/cache-v27-complete-cache-regression/20260810_101706_460_0b57c06b`.
- The tool itself launches no Unreal process and performs no Store write/repair.
  The UE processes above are test/build evidence only. Complete Runtime semantic
  graph validation remains authoritative; this generic diagnostic decoder labels
  unsupported summaries unavailable and never decodes opaque VM/initializer/
  debug payloads without a matching versioned decoder.
- V2.7 is GREEN. V3 DirectSourceInputs/exact warm restore is next; no Editor GUI,
  PIE, Development game or Shipping package acceptance is inferred.

## V3.1 DirectSourceInputs TDD — 2026-08-10

- The official Development Editor RED command was
  `Tools\RunBuild.ps1 -Label cache-v31-direct-source-red -LogRoot
  Saved/Build/cache-v31-direct-source-red-attempt-1 -SerializeByEngine
  -TimeoutMs 1800000`. It failed in the new independent
  `AngelscriptCacheDirectSourcePlannerTests.cpp` at its first include because
  `Cache/AngelscriptCacheSourcePlanner.h` did not exist. The exact artifact is
  `Saved/Build/cache-v31-direct-source-red-attempt-1/Build/cache-v31-direct-source-red/20260810_103553_967_8803a3a0`.
  This is the intended missing-production-surface RED; no unrelated compile error
  was introduced.
- After adding the Runtime planner and direct-projection digest, the official
  Development Editor build passed wrapper/process `0/0` at
  `Saved/Build/cache-v31-direct-source-build-attempt-1/Build/cache-v31-direct-source-build/20260810_104037_855_80882d77`.
- The first focused behavior attempt at
  `Saved/Tests/cache-v31-direct-source-attempt-1` did not launch Automation. It
  was blocked by another project's live UE 5.8 Build.bat lock and is recorded as
  IC-286; it is neither RED nor GREEN behavior evidence.
- After the external owner exited naturally, the first real behavior run reached
  all five then-current tests at
  `Saved/Tests/cache-v31-direct-source-attempt-2/Tests/cache-v31-direct-source/20260810_104606_207_0e2f938f`.
  It was an intended diagnostic RED at `0/5`: every input failed validation error
  `18` because the first NUL guard treated FString's storage terminator as logical
  content. IC-287 records the root cause and the initially invalid `AppendChar(0)`
  hostile fixture.
- The logical-length scan compiled wrapper/process `0/0` at
  `Saved/Build/cache-v31-direct-source-nul-fix-build-attempt-1/Build/cache-v31-direct-source-nul-fix-build/20260810_104728_597_78fa529e`;
  the five-method focused class then passed `5/5` at
  `Saved/Tests/cache-v31-direct-source-attempt-3/Tests/cache-v31-direct-source/20260810_104743_332_16c57872`.
- Hardening tests deliberately restored RED twice. The first seven-method run was
  `5/7` at
  `Saved/Tests/cache-v31-direct-source-hardening-red-attempt-1/Tests/cache-v31-direct-source-hardening-red/20260810_104939_901_aa6b4bf2`,
  exposing an empty raw option-key admission and the unfrozen V1 golden. The
  split ten-method run was `5/10` at
  `Saved/Tests/cache-v31-direct-source-hardening-split-red-attempt-1/Tests/cache-v31-direct-source-hardening-split-red/20260810_105123_094_855c6e53`,
  additionally proving that all authority strings and Mount/direct options did
  not yet share their aggregate budgets and that `AppendChar(0)` was not a valid
  embedded-NUL fixture.
- Production now rejects an empty raw option key before `compiler:`/
  `preprocessor:` namespacing, scans NUL only inside `[0, Len)`, shares string and
  option budgets across the complete direct input, and constructs the hostile
  fixture by inserting a zero code unit into the logical character array. The V1
  direct digest is frozen as
  `a0344dacb06ef4c92ec9a8a413d1bbcca7a4814d80ad2d1f1b2bac4157202197`.
  The final Development Editor build passed wrapper/process `0/0` at
  `Saved/Build/cache-v31-direct-source-hardening-build-attempt-1/Build/cache-v31-direct-source-hardening-build/20260810_105313_491_3387f22c`.
- The final focused prefix passed `10/10`, failed/skipped `0/0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v31-direct-source-final-attempt-1/Tests/cache-v31-direct-source-final/20260810_105400_230_45940d2d`.
- The authoritative complete Cache prefix then passed `349/349`, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v31-complete-cache-regression-attempt-1/Tests/cache-v31-complete-cache-regression/20260810_105834_737_ac33983e`.
  This count is the previous expected `339` after removal of the redundant Python
  ownership UE test plus the ten V3.1 methods. V3.1 is GREEN only at the
  direct-input/canonical-digest boundary; dependency-candidate validation,
  production source discovery and warm restore remain V3.2–V3.5.

## V3.2 persisted dependency candidate TDD — 2026-08-10

- The independent `AngelscriptCacheDependencyCandidateTests.cpp` was added before
  production API. The official Development Editor RED command was
  `Tools\RunBuild.ps1 -Label cache-v32-dependency-candidate-red -LogRoot
  Saved/Build/cache-v32-dependency-candidate-red-attempt-1 -SerializeByEngine
  -TimeoutMs 1800000`. It failed only in the new test translation unit because
  `FAngelscriptCacheObservedDependencyInput`, candidate limits/result/match types,
  `BuildPersistedDependencyCandidate` and
  `ValidatePersistedDependencyCandidate` did not exist. The artifact is
  `Saved/Build/cache-v32-dependency-candidate-red-attempt-1/Build/cache-v32-dependency-candidate-red/20260810_110740_213_6cf3fdf5`.
- The minimal Runtime implementation compiled and linked wrapper/process `0/0`
  at
  `Saved/Build/cache-v32-dependency-candidate-build-attempt-1/Build/cache-v32-dependency-candidate-build/20260810_110934_678_9543fae9`.
  It preflights input/edge/observation/string bounds, validates the direct plan,
  appends captured dependency rows through the sole SourceIndex canonicalizer,
  distinguishes normal direct/unavailable/dependency misses from malformed data,
  and publishes a rebuilt SourceIndex only after exact SourceSnapshot equality.
  The observation input is a bounded table, not a callback, so this planner layer
  contains no path that can invoke preprocessing.
- The first focused behavior attempt at
  `Saved/Tests/cache-v32-dependency-candidate-attempt-1/Tests/cache-v32-dependency-candidate/20260810_110957_217_b60050a3`
  exited `3` without a report after entering the first method. IC-288 traces this
  to a test-only generated file incorrectly mounted through a `BuiltInDisk`
  provider; the existing SourceIndex authority correctly rejected it and the
  fixture helper's `check` terminated Editor-Cmd. This run is not V3.2 behavior
  RED/GREEN evidence.
- The typed `Generated` provider/Mount fixture correction compiled wrapper/
  process `0/0` at
  `Saved/Build/cache-v32-generated-fixture-fix-build-attempt-1/Build/cache-v32-generated-fixture-fix-build/20260810_111145_921_db49bb79`.
  No production validation rule was weakened.
- The focused prefix then passed `8/8`, failed/skipped `0/0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v32-dependency-candidate-attempt-2/Tests/cache-v32-dependency-candidate/20260810_111406_005_d85903c5`.
  It covers canonical/order-independent capture, exact atomic rebuild, direct
  mismatch before observation comparison, missing and changed observations as
  normal misses, corrupt candidate/duplicate observation rejection, configured
  bounds plus missing edge targets, and an exact zero-dependency candidate.
- The authoritative complete Cache prefix passed `357/357`, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v32-complete-cache-regression-attempt-1/Tests/cache-v32-complete-cache-regression/20260810_111543_110_4cef0ceb`.
  This is the V3.1 `349` baseline plus eight V3.2 methods. V3.2 is GREEN only at
  the bounded candidate composition/validation boundary; V3.3 still owns the
  production construction of direct inputs and candidate-scoped current
  observations from real source/providers/options.

## V3.3 production source discovery TDD — 2026-08-10

- Two independent test files were added before production API:
  `AngelscriptCacheProductionSourceDiscoveryTests.cpp` covers real provider
  discovery, deterministic Game/Plugin/Memory inventory, add/delete/rename,
  cross-provider logical-path collision, module-local ineligibility and atomic
  read/encoding failure; `AngelscriptCacheDependencyObservationTests.cpp`
  covers the six current dependency target shapes without preprocessing.
- The official Development Editor RED command was
  `Tools/RunBuild.ps1 -Label cache-v33-production-discovery-red -TimeoutMs
  180000`. It failed only in those two new translation units at their first
  include because `Cache/AngelscriptCacheSourceDiscovery.h` did not exist. The
  exact artifact is
  `Saved/Build/cache-v33-production-discovery-red/20260810_113315_285_df92ce0e`.
  This is the intended missing-production-surface RED. V3.3 remains in progress.
- The first normal implementation build was refused before C++ by saturated XGE
  capacity (IC-289). The local `-NoXGE` retry then completed 93/108 actions
  without compiler errors but reached the 180-second wrapper deadline (IC-290).
  The official incremental retry
  `Tools/RunBuild.ps1 -Label
  cache-v33-production-discovery-build-noxge-600s -TimeoutMs 600000 -NoXGE`
  completed the remaining 14 actions and linked Runtime/Test with process/wrapper
  `0/0` at
  `Saved/Build/cache-v33-production-discovery-build-noxge-600s/20260810_114443_692_d4b057a4`.
- The first production-discovery behavior run passed its then-current `5/5`,
  failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v33-production-source-discovery-attempt-1/Tests/cache-v33-production-source-discovery/20260810_114607_274_3befb2c0`.
- The independent candidate-scoped observation prefix passed `2/2`,
  failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v33-dependency-observation-attempt-1/Tests/cache-v33-dependency-observation/20260810_114646_767_e7fa17f5`.
  It resolves all six current target forms from the direct projection and treats
  a deleted target or missing option as unavailable without invoking preprocessing.
- Exact built-in-disk bytes, module-scoped and legacy-global hook eligibility
  hardening compiled and linked with process/wrapper `0/0` at
  `Saved/Build/cache-v33-source-discovery-hardening-build/20260810_114937_432_6cee1362`.
- The hardened production-discovery prefix passed `8/8`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v33-production-source-discovery-attempt-2/Tests/cache-v33-production-source-discovery-hardened/20260810_114955_817_e02a594f`.
  This is focused evidence only: configured-budget boundaries, the existing
  SourceProvider regression and complete Cache prefix remain before V3.3 closure.
- Four additional production-discovery methods then froze stable module-name
  agreement plus module-name/single-file/aggregate-byte budget behavior. The
  official Development Editor build passed process/wrapper `0/0` at
  `Saved/Build/cache-v33-discovery-coordinate-budget-red/Build/cache-v33-discovery-coordinate-budget-red/20260810_115656_453_1f06cd96`,
  after which the focused behavioral RED was exactly `10/12`, failed `2`,
  skipped `0`, at
  `Saved/Tests/cache-v33-discovery-coordinate-budget-red-attempt-1/Tests/cache-v33-discovery-coordinate-budget-red/20260810_115712_989_305e921f`.
  Only `MismatchedDerivedModuleNameFailsBeforeReading` and
  `ModuleNameBudgetIsTypedBeforeReading` failed; both raw-byte limits already
  passed. IC-291 records the missing coordinate comparison and conflated error
  taxonomy.
- The module-coordinate comparison compiled at
  `Saved/Build/cache-v33-module-coordinate-fix-build/Build/cache-v33-module-coordinate-fix-build/20260810_115834_824_fa21b299`,
  and its exact method passed `1/1` at
  `Saved/Tests/cache-v33-module-coordinate-fix-attempt-1/Tests/cache-v33-module-coordinate-fix/20260810_115848_575_631b84ab`.
  The separate budget-classification fix compiled at
  `Saved/Build/cache-v33-module-budget-fix-build/Build/cache-v33-module-budget-fix-build/20260810_115932_981_1a93f0ec`,
  and its exact method passed `1/1` at
  `Saved/Tests/cache-v33-module-budget-fix-attempt-1/Tests/cache-v33-module-budget-fix/20260810_115946_423_ff99ec9f`.
- The final production-discovery prefix passed `12/12`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v33-production-source-discovery-final-attempt-1/Tests/cache-v33-production-source-discovery-final/20260810_120035_040_b619c37e`.
  A provider-injected module-name mismatch and an oversized module coordinate
  now both fail before source I/O, with distinct structural and budget errors.
- The pre-existing injected-provider/preprocessor compatibility prefix passed
  `4/4`, failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v33-source-provider-regression-attempt-1/Tests/cache-v33-source-provider-regression/20260810_120109_252_964ed9b1`.
- The authoritative complete Cache prefix passed `371/371`, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v33-complete-cache-regression-attempt-1/Tests/cache-v33-complete-cache-regression/20260810_120218_798_9b7954ad`.
  This is the V3.2 `357` baseline plus twelve production-discovery and two
  dependency-observation methods. V3.3 is GREEN at production discovery and
  callback-free current-observation planning only; V3.4 still owns fresh-engine
  restore and V3.5 owns the exact zero-work second launch.
- After recording the implementation and evidence, `openspec validate
  refactor-as-incremental-function-cache --strict` reported the change valid;
  parent and plugin `git diff --check` both exited `0` with only existing
  line-ending conversion warnings. `openspec instructions apply` reports
  `19/43` complete. V3.3 is closed and V3.4 is the active vertical.

## V3.4 fresh-engine restore TDD — 2026-08-10 (in progress)

- The first independent fresh-engine method was added before the production
  restore surface. The official Development Editor RED command was
  `Tools\RunBuild.ps1 -Label cache-v34-fresh-engine-restore-red -TimeoutMs
  600000 -NoXGE`; it failed only because
  `Cache/AngelscriptCacheRestore.h` did not yet exist, at
  `Saved/Build/cache-v34-fresh-engine-restore-red/20260810_121748_108_7ef181c1`.
- The implementation adds an engine-owned restore coordinator, stable live-route
  state, descriptor/index publication and a maintained-fork
  `asCReader::RestoreGlobalFunctionArtifact` adapter. Its first build exposed the
  local C4456 naming defect recorded as IC-295 at
  `Saved/Build/cache-v34-fresh-engine-restore-impl-build-1/20260810_122827_472_9cbd7795`.
  The naming-only correction passed process/wrapper `0/0` at
  `Saved/Build/cache-v34-fresh-engine-restore-impl-build-2/20260810_123025_542_a0af6aaa`.
- The initial in-memory generation proof passed `1/1`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v34-fresh-engine-restore-green-attempt-1/20260810_123054_571_77152844`.
  Engine A was destroyed before Engine B; Engine B published the reconstructed
  module descriptor/enum/route and executed `Answer()==42` through a newly
  allocated numeric FunctionId.
- The method was then strengthened to publish the generation through the real
  atomic Store, commit Current, and reopen a physical Manifest/Pack through a
  pinned `FAngelscriptCacheReadSession`. The test-only change built at
  `Saved/Build/cache-v34-disk-reopen-build/20260810_123543_016_130516ad`.
  One outer 10-second launch was interrupted as IC-296; the corrected official
  invocation passed `1/1`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v34-disk-reopen-green-attempt-2/20260810_123626_188_bbe08ffa`.
  Its diagnostics record PublishError `0`, Current commit `2`, OpenError `0`,
  one pinned Pack, stable key
  `9f130870dac37cf1a51ba292d2826ccbd93735cb91a7b31ac002aa03af658230`,
  current FunctionId `79776` and result `42`.
- The late-failure test lives in the separate
  `AngelscriptCacheFreshEngineRollbackTests.cpp`. It creates a locally/hash/graph-
  consistent DebugSidecar whose one parameter name is incompatible with the
  zero-parameter live function, so detached graph validation succeeds and the
  private apply boundary rejects it. The test compiled at
  `Saved/Build/cache-v34-rollback-test-build-1/20260810_123917_078_9b743fcc`;
  the then-two-method prefix passed `2/2` at
  `Saved/Tests/cache-v34-rollback-green-attempt-1/20260810_123941_084_6819a65f`.
  Rejection is typed as restore error `5`, stage `5`, active module count remains
  zero, no enum/route is published, and an authoritative compile in the same
  Engine still executes `42`.
- Focused route-lifecycle methods were then added. Their official build passed at
  `Saved/Build/cache-v34-route-tests-red-build/20260810_124141_722_b3e60e59`.
  The intended behavioral RED was `3/4`, failed `1`, at
  `Saved/Tests/cache-v34-route-tests-red/20260810_124204_005_7c4b08e9`:
  duplicate activation was safely rejected but reported the active-module guard
  instead of the stable-route conflict. The independent-engine and rollback
  methods passed in the same run.
- Moving the existing stable-route lookup ahead of the module replacement guard
  compiled process/wrapper `0/0` at
  `Saved/Build/cache-v34-route-duplicate-fix-build/20260810_124316_217_90f47dd4`.
  The focused prefix then passed `4/4`, failed/skipped `0/0`, process/wrapper
  `0/0`, at
  `Saved/Tests/cache-v34-route-tests-green/20260810_124331_825_81601c2d`.
  Duplicate Key activation is explicitly rejected without replacing the first
  route; `DiscardModule` removes module/enum/route; two independently initialized
  Engines both allocated numeric ID `79776` but resolved different function
  pointers; a third Engine without the route could not resolve the stable Key.
- IC-294 records the newly exposed production boundary: persisted SourceIndex
  cannot and must not recreate current-machine absolute paths or preprocessor
  scratch. V3.3 discovery must supply a transient current-source view before
  V3.5/V6 HotReload integration; this does not weaken the bounded V3.4 artifact
  transaction.
- The pre-existing cold-generation prefix passed `1/1`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v34-cold-generation-regression/20260810_124604_686_e46df93a`.
  The CleanCapture opaque execution/debug corruption prefix passed `2/2` at
  `Saved/Tests/cache-v34-clean-capture-regression/20260810_124643_084_c9515d8d`.
- The authoritative complete Cache prefix passed `375/375`, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v34-complete-cache-regression/20260810_124733_974_69772c2e`.
  This is the V3.3 `371` baseline plus the four V3.4 fresh restore/rollback/route
  methods.
- After recording the final evidence, `openspec validate
  refactor-as-incremental-function-cache --strict` reported the change valid;
  parent and plugin `git diff --check` both exited `0` with only existing
  line-ending conversion warnings. The corrected installed-CLI query
  `openspec instructions apply --change
  refactor-as-incremental-function-cache` reports `20/43` complete. V3.4 is
  GREEN and V3.5 is now active. No
  V3.5 zero-work startup or production Editor/PIE lifecycle claim is made by the
  V3.4 results.

## V3.5 exact warm startup TDD — 2026-08-10

- The exact-start packet is frozen in `v3.5-exact-warm-startup.md`. It makes the
  new-Engine ownership split explicit: Engine B normally initializes all
  process-local native bindings, databases, properties, namespaces, current
  addresses, contexts and JIT services; Cache V2 reconstructs only pointer-free
  script facts as new live modules/types/functions, new numeric FunctionIds,
  plugin indexes and stable routes. No old Engine pointer, numeric FunctionId,
  native address or preprocessor scratch crosses the generation boundary.
- The independent four-method test class was written before the production
  coordinator. The official Development Editor RED build failed only because
  `Cache/AngelscriptCacheExactStartup.h` did not exist, at
  `Saved/Build/cache-v35-exact-warm-start-red/20260810_130222_430_c692c3b2`.
- The implementation adds the bounded transient current-source projection,
  authoritative SourceIndex clean capture, one-to-one current/persisted source
  validation, current-path projection during restore and the no-compiler/no-Store-
  writer exact-start coordinator. Its first implementation build reached those
  sources and failed only on the wrapper-key comparison recorded as IC-298 at
  `Saved/Build/cache-v35-exact-warm-impl-build-1/20260810_130734_730_c4d10882`.
  Comparing the full 256-bit hash member compiled process/wrapper `0/0` at
  `Saved/Build/cache-v35-exact-warm-impl-build-2/20260810_130813_206_0ffe6832`.
- The first focused behavioral run was intentionally retained as evidence rather
  than hidden: it passed the changed-source and tampered-projection safe-miss
  cases but restored neither unchanged nor relocated source, for `2/4` at
  `Saved/Tests/cache-v35-exact-warm-green-attempt-1/20260810_130833_753_960e1b01`.
  IC-299 records the cause: the legacy logical-path helper prepended `/` to the
  already rooted production mount `/Angelscript/Game`, producing
  `//Angelscript/Game/...` and a pre-mutation projection miss.
- Conditional logical-root normalization compiled at
  `Saved/Build/cache-v35-logical-mount-fix-build/20260810_131002_096_7a88bf11`.
  The first complete focused run then passed `4/4`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v35-exact-warm-green-attempt-2/20260810_131018_357_3f896667`.
  It recorded direct digest
  `190c146b54e818d3e2a89028e2ca1a7a07b080518e51206b1d73125721b34e23`,
  SourceSnapshot
  `8092570e4fa26a7375c317ac8fe250bb6c656f9edca1e3f89cbeadef27dacecc`,
  Generation
  `6aec4825432907291fe903cd4e7dc231a1c031b1835492e9d2990418c15b075a`,
  current Engine FunctionId `79776`, execution result `42`, three physical
  Store files and unchanged Store digest
  `60a47575fc0c95aba24b13655879f9ea162945839612c89ab5284906f9213779`.
- Focused adjacent regressions passed before the final ownership refinement:
  ProductionSourceDiscovery `12/12` at
  `Saved/Tests/cache-v35-source-discovery-regression/20260810_131139_102_75aaeee4`,
  DependencyCandidate `8/8` at
  `Saved/Tests/cache-v35-dependency-candidate-regression/20260810_131217_314_accd4435`,
  CleanCaptureOpaqueValidation `2/2` at
  `Saved/Tests/cache-v35-clean-capture-regression/20260810_131250_938_505313f9`,
  ColdGeneration `1/1` at
  `Saved/Tests/cache-v35-cold-generation-regression/20260810_131329_442_c915bf74`,
  and FreshEngineRestore `4/4` at
  `Saved/Tests/cache-v35-fresh-engine-regression/20260810_131407_911_5d07f479`.
  The then-current complete Cache prefix was `379/379` at
  `Saved/Tests/cache-v35-complete-cache-regression/20260810_131511_541_a6c5d23a`.
- Source discovery was then tightened to release the temporary direct-input raw
  byte copies and move the already bounded working bytes into the transient
  projection. The final official Development Editor build passed process/wrapper
  `0/0` at
  `Saved/Build/cache-v35-final-memory-transfer-build/20260810_131939_595_4a650427`.
  The final ProductionSourceDiscovery prefix passed `12/12`, failed/skipped
  `0/0`, at
  `Saved/Tests/cache-v35-final-source-discovery/20260810_132005_401_4793b37d`.
- The final ExactWarmStartup prefix passed `4/4`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v35-final-exact-warm/20260810_132038_346_5b02677b`.
  Engine A was destroyed before Engine B. On unchanged source, Engine B restored
  one module, one type and one function; the restored `Answer()` returned `42`,
  the stable route resolved its current FunctionId, current absolute source path
  was projected, and `FCodeSection::Code` remained empty. All observed warm
  preprocess/parse/code-compile events, explicit preprocess/parse/module-compiler/
  function-compiler counters and publication attempts were zero. The physical
  Store remained the same three files with the same digest. Changed raw source
  and a tampered transient projection both missed before Engine mutation;
  identical source relocated from SourceA to SourceB retained the direct identity
  and restored with SourceB's current absolute path.
- The final authoritative complete Cache prefix passed `379/379`, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v35-final-complete-cache/20260810_132137_955_1755286f`.
  This is the V3.4 `375` baseline plus the four V3.5 exact-start methods. V3.5 is
  GREEN for the deliberately admitted simple-enum/self-contained-global-function
  vertical only. Classes, properties, inheritance, imports, broader module state,
  production lifecycle wiring, real Editor/PIE and packaged multi-launch remain
  later verticals rather than inferred success.
- After recording the final source frontier and issue resolutions, `openspec
  validate refactor-as-incremental-function-cache --strict` reported the change
  valid. Parent and plugin `git diff --check` both exited `0`, with only the
  pre-existing LF-to-CRLF working-copy warnings. `openspec instructions apply
  --change refactor-as-incremental-function-cache` reports `21/43` complete with
  V3.5 checked and V4.1 first pending. V4 is now active; no Editor/PIE/package
  acceptance is implied by these headless automation results.

## V4.1 changed-module forced-clean TDD — 2026-08-10

- The implementation contract is frozen in
  `v4.1-changed-module-forced-clean.md`. Compile artifact eligibility is now
  orthogonal to `ECompileType`: reload type continues to own soft/full activation
  and class reinstancing, while `Default`/`ForceClean` owns persisted execution-
  artifact reuse. V4.1 keeps changed-source ownership in the existing
  `PerformHotReload` file/dependency closure, `FAngelscriptPreprocessor`, normal
  compiler stages, ClassGenerator and swap transaction.
- Two independent tests were added in the separate
  `AngelscriptCacheChangedModuleOracleTests.cpp`. The official Development Editor
  RED build failed on only the absent compile-policy/options/event fields and
  narrow HotReload test-friend boundary at
  `Saved/Build/cache-v41-forced-clean-red/20260810_133125_283_5a5ba937`.
- The implementation adds `EAngelscriptCompileCachePolicy` plus
  `FAngelscriptCompileOptions`, carries the policy through one compilation context
  and every structured compile event, clears legacy/incremental loaded hints before
  forced-clean assembly, blocks legacy PrecompiledData load/finalization, and also
  clears hints on dependency descriptors cloned by recompile avoidance.
  `PerformHotReload` explicitly selects `ForceClean`; the maintained-fork parser,
  compiler and normal current-process JIT handoff remain unchanged.
- The first implementation build regenerated UHT data and scheduled 99 affected
  actions due to the public `AngelscriptEngine.h` change. It reached `67/99`
  without a compiler error before its short 180-second wrapper deadline at
  `Saved/Build/cache-v41-forced-clean-impl-build-1/20260810_133353_025_7ae0aa15`.
  IC-300 preserves this compile frontier. The 600-second official rerun reused the
  completed objects, compiled/linked the remaining 32 actions, and passed
  process/wrapper `0/0` at
  `Saved/Build/cache-v41-forced-clean-impl-build-2/20260810_133714_877_b72f6b1b`.
- The first focused behavior run passed `2/2`, failed/skipped `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v41-forced-clean-green-attempt-1/20260810_133757_487_fc00e815`.
  The real disk HotReload changed `ChangedModuleOracle.Answer()` from `41` to
  `42`, observed exactly one `PreprocessProcessChunks`, one `CompileModuleParse`
  and one `CompileModuleCompileCode` event, and its compile run reported
  `ForceClean`. The active descriptor retained neither `bLoadedPrecompiledCode`
  nor `bLoadedIncrementalCache`. The second method seeded the incremental hint,
  compiled with explicit `ForceClean`, observed real parse/code stages, cleared
  the hint and executed `Answer()==73`.
- Adjacent structured-compiler and HotReload authorities remain GREEN:
  Compiler Events `7/7` at
  `Saved/Tests/cache-v41-compiler-events-regression/20260810_133858_712_7fe11734`,
  HotReload Dependency `2/2` at
  `Saved/Tests/cache-v41-hotreload-dependency-regression/20260810_133942_950_82cf4f84`,
  HotReload Events `2/2` at
  `Saved/Tests/cache-v41-hotreload-events-regression/20260810_134019_886_f4e732e5`,
  and HotReload ChangeClassification `22/22` at
  `Saved/Tests/cache-v41-hotreload-classification-regression/20260810_134055_253_596a293a`.
  This explicitly covers dependent recompilation plus soft/full structural
  classification rather than inferring compatibility from the new Cache tests.
- The authoritative complete Cache prefix passed `381/381`, failed/skipped
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v41-forced-clean-complete-cache/20260810_134134_892_5078dbcc`.
  This is the V3.5 `379` baseline plus the two V4.1 changed-module oracle methods.
  V4.1 does not yet compare semantic RecordIds, reuse immutable content, publish a
  new generation or perform per-function compiler hits; those remain V4.2–V5.
- The post-recording closure check passed strict OpenSpec validation. Parent and
  plugin `git diff --check` both exited `0` with only the existing LF-to-CRLF
  working-copy warnings. `openspec instructions apply --change
  refactor-as-incremental-function-cache` reported `22/43` complete with V4.2 as
  the first pending task.

## V4.2 semantic RecordId diff TDD — 2026-08-10

- The comparison boundary is frozen in `v4.2-semantic-record-diff.md`. The
  production entry accepts two already graph-validated generations, joins
  ModuleKey/TypeKey/StableFunctionKey owners and only then compares full
  `{RecordKind,BLAKE3-256}` RecordIds. PackId, codec, compressed bytes, offsets,
  Manifest locations, GenerationId, Engine pointers and numeric FunctionIds are
  not inputs. Compatibility/Context/Profile mismatch and impossible post-
  validation mutation are typed atomic failures.
- Seven independent methods were added in the separate
  `AngelscriptCacheSemanticDiffTests.cpp` test TU. The expected official
  Development Editor RED stopped only at the missing
  `Cache/AngelscriptCacheSemanticDiff.h` at
  `Saved/Build/cache-v42-semantic-diff-red/20260810_135341_468_1b3cad17`.
  IC-301 preserves that frontier.
- The first implementation build compiled/linked the new Runtime header/cpp and
  test TU in seven actions with process/wrapper `0/0` at
  `Saved/Build/cache-v42-semantic-diff-impl-build-1/20260810_135821_316_5ba59fe9`.
  Production emits an explicit SourceIndex disposition, one sorted module entry
  with interface/state dispositions and only changed type/body/debug owners, plus
  sorted reused/new/retired sets covering every reachable record including root
  records.
- The first focused behavior run passed the four real edit cases and failed only
  the physical-layout fixture, for `4/5`, at
  `Saved/Tests/cache-v42-semantic-diff-green-attempt-1/20260810_135852_610_c2c9812c`.
  IC-302 records that `ForceZlibForTest` correctly rejects any payload that does
  not become smaller, and the opaque FunctionBody was such a payload. This was a
  fixture assumption, not a semantic-diff or production-code failure.
- The physical-independence fixture now prepares the exact same seven semantic
  records once as an aggregate Pack and once as one-record shards under the same
  None codec. The GenerationIds differ while the semantic result is seven reused,
  zero new and zero retired. The corrected build passed at
  `Saved/Build/cache-v42-semantic-diff-fixture-fix-build/20260810_140103_635_1356eaf7`
  and the five methods passed `5/5` at
  `Saved/Tests/cache-v42-semantic-diff-green-attempt-2/20260810_140131_151_470415fe`.
- Two fail-closed methods were then added. A forged different ArtifactProfile is
  rejected as `IncompatibleGeneration` rather than misclassified as a source
  edit. Removing the ModuleSnapshot handle from a copied public validated value
  returns `MissingRecord` with no SourceIndex ids, modules or record sets exposed.
  The final official build passed process/wrapper `0/0` at
  `Saved/Build/cache-v42-semantic-diff-negative-build/20260810_140315_811_f54c0103`.
  The final focused class passed `7/7`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v42-semantic-diff-final-focused/20260810_140331_856_1467137c`.
- Real edit logs provide the current narrow capture evidence. `return 41` to
  `return 42` retained ModuleInterface, TypeSchema, ModuleState and DebugSidecar,
  yielding four reused plus three new/retired records. An enum value edit changed
  one TypeSchema under the same TypeKey. A leading-line shift changed one
  DebugSidecar and its owning FunctionBody while interface/state/type stayed hits.
  A function rename changed ModuleInterface and reported two body plus two debug
  entries as one removed/one added key, never a false modification.
- Adjacent Pack/Manifest behavior passed `27/27`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v42-packformat-regression/20260810_140440_949_f43b68b6`.
  The authoritative complete Cache prefix passed `388/388` (375 Success plus 13
  Success-with-warning network/environment logs), failed/not-run `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v42-semantic-diff-complete-cache/20260810_140517_451_9c8fc517`.
  This is the V4.1 `381` baseline plus seven V4.2 methods.
- V4.2 does not yet reuse an old physical Pack/location or publish a new Current
  generation; V4.3 consumes `ReusedRecordIds`/`NewRecordIds`. Modified non-empty
  ModuleState and broader class/property/layout/global/initializer capture remain
  the explicit V4.5 widening rather than being inferred from the generic
  RecordId comparator.
- Final recording checks passed: strict OpenSpec validation reported the change
  valid; parent and plugin `git diff --check` exited `0` with only the existing
  LF-to-CRLF working-copy warnings; `openspec instructions apply --change
  refactor-as-incremental-function-cache` reports `23/43` complete with V4.3 as
  the first pending task.

## V4.3 incremental Generation publication TDD — 2026-08-10

- The preparation/publication boundary is frozen in
  `v4.3-incremental-generation-publication.md`. One pure Runtime API consumes the
  pinned validated base plus a validated clean current candidate and computes
  the V4.2 semantic diff internally. It accepts no caller-authored reuse list and
  no duplicate prepared-record input. Only current decoded `NewRecordIds` enter
  new Packs; reused IDs copy exact base Manifest locations; retired IDs are not
  indexed; the resulting Manifest carries the complete current SourceIndex and
  ModuleSnapshot roots.
- Store code and persisted schemas did not change. The existing publisher writes
  only supplied new Packs, then its `PutManifestIfAbsent` path reopens every old
  and new Pack referenced by the complete candidate, invokes the sole complete
  generation validator, and moves the pointer only after success. This keeps one
  lock/rebase/immutable-object/pointer transaction and makes a forged or missing
  retained Pack fail before commit.
- Four independent methods were added in the separate
  `AngelscriptCacheIncrementalGenerationTests.cpp` TU. The expected official
  Development Editor RED stopped only at the absent production header (`C1083`)
  at
  `Saved/Build/cache-v43-incremental-generation-red/20260810_142019_531_68deff97`;
  IC-303 preserves and closes that frontier.
- The first implementation build compiled and linked 36 affected Runtime/Test
  actions with process/wrapper `0/0` at
  `Saved/Build/cache-v43-incremental-generation-impl-build-1/20260810_142328_542_70a41c82`.
  The output is reset before validation, both Manifest values are checked against
  caller limits, semantic views are rebuilt, current decoded RecordIds are
  canonicalized, only new payloads are passed to `BuildPacks`, emitted indexes
  must exactly equal the new set, and the complete mixed Manifest is validated
  and encoded before the candidate is moved to output.
- The focused class passed `4/4`, failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v43-incremental-generation-green-attempt-1/20260810_142451_128_d5b43af2`.
  Its body-only mutation logged `Reused=4 New=3 Retired=3 NewPacks=1` and a
  seven-record complete Manifest. Complete mixed-Pack validation reported no
  semantic difference from the independently prepared full clean-current
  generation.
- Recompiling unchanged source into deliberately different one-record Pack
  shards first produced a different temporary GenerationId. Incremental
  preparation then logged `Reused=7 New=0 Retired=0 NewPacks=0` and reproduced
  the exact aggregate base Manifest bytes and GenerationId, proving physical
  layout cannot force a redundant generation.
- The real disk test published the base, opened a pinned read session, prepared
  the body-only candidate and called the normal Store publisher with only its
  one new Pack. Store committed Current from
  `f1f12f1ed41dee027d9ff88da60c7f9373287dbcc53d2269752f1c15a0f27053`
  to
  `1c0abfe7f86ba9c713da4d58548089ce0228946813a178c395d01401a728140a`.
  Reopened Current was semantically identical to the full clean oracle, while
  the old session still exposed its seven old records and every old Pack file was
  byte-identical before and after publication.
- The negative method forged the first base PackId to zero after validation. The
  preparation returned typed `InvalidBaseManifest` with the underlying exact
  Manifest validation diagnostic and zero Packs, Manifest records, encoded bytes
  or semantic diff arrays in output.
- The authoritative complete Cache prefix passed `392/392` (375 Success plus 17
  Success-with-warning network/environment log carriers), failed/not-run `0/0`,
  process/wrapper `0/0`, at
  `Saved/Tests/cache-v43-incremental-generation-complete-cache/20260810_142605_935_752c2e62`.
  This is the V4.2 `388` baseline plus the four V4.3 methods and covers all prior
  Pack, Store, source, restore, corruption, concurrency and fault-injection
  classes under the Cache prefix.
- V4.3 does not decide dependent-module propagation or widen class/property/
  global/initializer capture. Those remain V4.4 and V4.5. Per-function compiler
  reuse remains V5, and process-local `FAngelscriptEngine` bindings, pointer state
  and numeric FunctionIds remain outside persisted Cache V2 records.
- Final recording checks passed: strict OpenSpec validation reported the change
  valid; parent and plugin `git diff --check` exited `0` with only the existing
  LF-to-CRLF working-copy warnings; `openspec instructions apply --change
  refactor-as-incremental-function-cache` reported `24/43` complete with V4.4 as
  the first pending task.

## V4.4 deterministic dependent-wave and layout-coordinate closure — 2026-08-10

- The Runtime now owns one pure `FAngelscriptCacheDependencyPropagation` planner
  over a complete `FAngelscriptValidatedGeneration`. It first performs the V4.2
  self-diff validation, rebuilds typed current authorities from decoded records,
  compares every stored dependency in deterministic module/record order, and
  returns only the next forced-clean module wave. It neither compiles nor
  publishes, mutates no Store/Engine state, parses no `.as`, and does not guess a
  recursive transitive closure. Repeating compile/validate/plan provides the
  A-to-B-to-C fixed point.
- The focused behavior class covers: ABI-only caller reuse after a provider body
  edit; FunctionContent selection; removed target; exact and unavailable
  external resolution; decoded-record order independence; forged-generation
  atomic failure; fixed-point A-to-B-to-C; type/property layout changes;
  HardValue plus initializer content; import target routing; and legal
  declaration-only FunctionContent returning ContentUnavailable. The final run
  is `11/11 PASS`, failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v44-layout-coordinate-green-propagation/20260810_154734_135_5b8dfcef`.
- IC-310 corrected one cross-layer schema contradiction. `Target.ExpectedAbi`
  now always stores the target declaration `SignatureHash`. ValueLayout and
  PropertyLayout require a separate nonzero `ExpectedContentOrValue` containing
  `TypeLayoutHash` and `PropertyLayoutFingerprint` respectively. Therefore a
  declaration edit yields AbiMismatch while a layout-only edit yields
  ContentMismatch. The change was intentionally made without old development
  cache compatibility.
- The intended RED is preserved. The test-only build succeeded at
  `Saved/Build/cache-v44-layout-coordinate-red-build/20260810_154026_494_a6fad054`.
  The primitive prefix then passed `12/13` and failed only the wished-for content
  presence matrix at
  `Saved/Tests/cache-v44-layout-coordinate-red-primitives/20260810_154048_991_8f706d34`;
  the propagation prefix reached the target method and stopped at the old
  FunctionBody presence assertion at
  `Saved/Tests/cache-v44-layout-coordinate-red-propagation/20260810_154124_661_4eb31b00`.
- Production implementation updated all three common semantic validators,
  TypeSchema derived-dependency matching, selected-module immutable graph
  closure, typed authority resolution and the V4.4 planner. The official
  Development Editor implementation build passed at
  `Saved/Build/cache-v44-layout-coordinate-impl-build/20260810_154626_057_731d5c49`.
- Primitive wire/presence validation is `13/13 PASS` at
  `Saved/Tests/cache-v44-layout-coordinate-green-primitives/20260810_154652_291_6408464f`.
  Exact TypeSchema dependency closure is `1/1 PASS` at
  `Saved/Tests/cache-v44-layout-coordinate-green-type-schema-dependency/20260810_154858_610_ffe3c061`,
  and the complete TypeSchema prefix is `67/67 PASS` at
  `Saved/Tests/cache-v44-layout-coordinate-green-type-schema/20260810_154939_654_69d8508e`.
- Selected-module immutable graph coverage now proves exact local ValueLayout and
  PropertyLayout hits plus wrong declaration ABI, wrong numeric layout, value
  cycle and wrong PropertyLayout content, all before any current resolver call.
  The final focused build passed at
  `Saved/Build/cache-v44-property-layout-graph-build/20260810_155220_224_3a957dec`;
  the layout graph prefix is `8/8 PASS` at
  `Saved/Tests/cache-v44-property-layout-graph-green/20260810_155236_613_25b6fe1a`.
- The read-only Python dump remains a test/debug/verification/observation tool,
  never a Runtime recovery dependency. Unsupported record schemas remain opaque;
  malformed fields in a selected supported schema return a structured nonzero
  error; dependency kinds and the independent ABI/content coordinates are
  visible. Final wrapper evidence is `16/16 PASS` at
  `Saved/Tests/cache-v44-layout-coordinate-python-final`. IC-311 records and
  closes one initial wrapper-parameter invocation mistake.
- The authoritative complete Cache prefix passed `403/403`, failed/skipped
  `0/0`, process/wrapper `0/0`, in `213124ms`, at
  `Saved/Tests/cache-v44-layout-coordinate-complete-cache-regression/20260810_155314_432_207700c8`.
  This includes all prior Pack, Store, discovery, exact-warm restore, semantic
  diff, incremental publication, corruption, concurrency and fault-injection
  coverage plus the V4.4 planner methods.
- V4.4 is closed at task `25/43`. V4.5 remains the first pending task and owns
  clean-oracle mutation-family breadth. V5 still owns compiler reuse, V6 owns
  lifecycle/Editor/PIE integration, and real GUI PIE plus Development/Shipping
  multi-launch/package acceptance remain V7 last.

## V4.5 clean-oracle mutation matrix — 2026-08-10

- Real isolated-engine clean compiles cover unchanged, body-only, signature,
  class/property/layout, global-storage, initializer, include/input,
  compile-option and debug-only mutations. The core packet passed `8/8` at
  `Saved/Tests/cache-v45-supported-mutation-matrix-red-green/20260810_165131_671_6d245311`,
  and the remaining input/option rows passed `2/2` at
  `Saved/Tests/cache-v45-input-option-matrix-red/20260810_170409_394_57ddf741`.
- The production-shaped mixed Generation is semantically equal to an
  independently clean current oracle while reusing exact old record locations
  and writing only new content. The focused IncrementalGeneration prefix passed
  `4/4` at
  `Saved/Tests/cache-v45-production-mixed-oracle-test/20260810_171854_451_0f76170f`.
- The complete Cache prefix passed `415/415`, failures/skips `0/0`, at
  `Saved/Tests/cache-v45-complete-regression/20260810_172027_716_69873a57`.
  Strict OpenSpec validation passed; V4.5 is closed.

## V5.1–V5.2 invocation identity and actual dependencies — 2026-08-10

- The maintained builder emits one Unreal-free, kind-tagged descriptor for all
  supported ordinary/generated/factory/public-single/lambda invocation paths.
  Focused coverage passed `3/3` at
  `Saved/Tests/cache-v51-initdefaults-fixture-test/20260810_174916_049_7430e779`.
- Successful compiler transactions retain typed actual dependencies and failed
  transactions retain none. Compiler capture passed `2/2` at
  `Saved/Tests/cache-v52-compiler-dependency-capture-test2/20260810_182407_560_d79b519b`;
  Runtime source/input resolution passed `2/2` at
  `Saved/Tests/cache-v52-function-input-test1/20260810_182450_499_9ecbc9c5`.
- A real production clean capture keeps the same FunctionSourceDigest while a
  referenced global hard value changes from 41 to 42 and changes the resolved
  FunctionInputDigest. It passed `1/1` at
  `Saved/Tests/cache-v52-clean-capture-dependency-green-test2/20260810_183835_489_1874c2c8`.
- Type/property/global current-authority semantics passed `1/1` at
  `Saved/Tests/cache-v52-function-input-authority-test/20260810_184126_428_a05d796f`.
  Direct generated factory/default-constructor/default-destructor/member-
  initialization and derived-base dependency coverage passed `1/1` at
  `Saved/Tests/cache-v52-generated-derived-dependency-test2/20260810_184946_726_5dc2bdca`.
- The authoritative complete Cache regression passed `425/425`, and affected
  AngelScriptSDK Compiler.Builder passed `64/64`, both with zero failures and
  zero not-run methods, at
  `Saved/Tests/cache-v52-complete-regression/20260810_185048_935_dbe431ce` and
  `Saved/Tests/cache-v52-angelscript-sdk-builder-regression/20260810_185541_770_85ca22af`.
- V5.2 is closed. V5.3 remains the first pending task: a pre-compiler lookup must
  validate and attach a complete VM artifact before any Engine mutation, return
  `Restored/Miss/RejectedCorrupt/NotCacheable`, and skip the compiler only for
  `Restored`.

## V5.3 pre-compiler restore hook and atomic VM commit — 2026-08-10

- The contract was driven from a dedicated RED translation unit. The corrected
  official RED build failed only on the missing restore result/callback,
  compiler observation and Runtime bridge APIs at
  `Saved/Build/cache-v53-restore-hook-red-build2/20260810_190852_309_0cb83984`.
- The maintained builder now calls one synchronous restore hook immediately
  before every real `asCCompiler` invocation. Only `Restored` may skip the
  compiler; Miss, RejectedCorrupt and NotCacheable preserve the authoritative
  compile path. A fake `Restored` status with an empty target is independently
  rejected by the builder.
- Execution is reconstructed and relocated into an unpublished donor function,
  the complete debug sidecar is decoded onto the donor, and only then does a
  strict maintained-fork commit swap complete private `scriptData` into the
  already-declared current function. This keeps the current Engine FunctionId
  and prevents corrupt execution or debug bytes from partially mutating the
  target.
- The final official implementation build passed at
  `Saved/Build/cache-v53-restore-hook-hardening-build/20260810_191946_639_ecc6f352`.
  The final focused test passed `3/3` at
  `Saved/Tests/cache-v53-restore-hook-hardening-test/20260810_192006_215_c1ca7642`.
  The real producer/consumer hit logged `CompilerCalls=0`, five restored
  bytecode words, producer/current IDs `79776/79777` and result 42. Miss,
  corrupt execution, corrupt debug with recomputed hashes and status-only fake
  Restored all left target bytecode at zero before normal compilation; the
  public-single path returned NotCacheable without invoking lookup.
- The authoritative complete Cache prefix passed `428/428`, failures/skips
  `0/0`, at
  `Saved/Tests/cache-v53-complete-regression/20260810_192417_808_01a4837a`.
  The affected AngelScriptSDK Compiler.Builder prefix passed `64/64`,
  failures/skips `0/0`, at
  `Saved/Tests/cache-v53-angelscript-sdk-builder-regression/20260810_192933_269_c453da17`.
- V5.3 is closed at task `29/43`. V5.4 is the first pending task and must prove
  one real isolated body edit invokes only the correct compiler closure while
  unchanged functions are actual pre-compiler hits.

## V5.4 isolated body edit and current-Engine function relocation — 2026-08-10

- The initial two-function lookup RED failed at the intended missing graph-open
  and graph-owned lookup APIs during the official build at
  `Saved/Build/cache-v54-function-lookup-red-build/20260810_193629_676_c9dfb006`.
  After those APIs landed, the independent-function form passed `1/1` at
  `Saved/Tests/cache-v54-function-lookup-test1/20260810_194102_296_dbcfe031`.
- The test was then strengthened so unchanged `UnchangedBody()` calls the
  body-edited `ChangedBody()`. The official build passed, and the intended
  behavior RED at
  `Saved/Tests/cache-v54-caller-relocation-red-test/20260810_194430_988_b43a8611`
  failed because the v1 artifact rejected its used-function table. This
  prevents the weaker independent-function test from being treated as final
  relocation evidence.
- Execution codec v2 now appends a bounded semantic used-function signature
  table. The maintained reader resolves it against the current module before
  translating instruction operands and exports exact instruction/operand/
  current-function observations. Runtime derives the current stable function
  key and accepts each relocation only when an exact persisted Signature
  dependency supplies the matching ABI/content coordinates. Numeric FunctionId
  is never persisted; all other symbolic tables remain `NotCacheable`.
- Clean capture now admits the complete bounded set of simple global `int()`
  functions in the enum vertical, captures real compiler-observed dependencies
  for every body and resolves `FunctionInputDigest` from current interface,
  type and state authorities. A callee body-only edit therefore does not change
  the caller's Signature dependency input.
- The first current-authority run correctly remained RED at
  `Saved/Tests/cache-v54-function-relocation-green-test1/20260810_195433_543_4a505bdb`:
  the callback supplied an empty authority set, so unchanged lookup returned
  typed `DependencyMissing` and compiled normally. The focused adapter now
  derives the consumer declarations through public module APIs; a separate
  negative method deliberately omits them and preserves the same typed miss.
- The final main behavior passed `1/1` at
  `Saved/Tests/cache-v54-function-relocation-green-test2/20260810_195823_234_a2735fc1`.
  `ChangedBody` logged SourceChanged, compiler invoked and value 42.
  `UnchangedBody` logged Restored, compiler not invoked, current FunctionId
  79777 and value 43, proving the cached caller invokes the newly compiled
  consumer-Engine callee rather than an old numeric ID or pointer.
- The final focused Function prefix passed `7/7`, failures/skips `0/0`, at
  `Saved/Tests/cache-v54-function-focused-green/20260810_200138_761_61013c78`.
  It includes a locally self-consistent mutation that removes the caller's
  declared stable dependency while retaining its relocation. Graph validation
  rejects it as `RelocationDependencyMismatch` (`Error=47`) at OpaqueCodec,
  with zero validated graph records and zero promoted output.
- The final official Development Editor build passed at
  `Saved/Build/cache-v54-negative-tests-build/20260810_200115_365_ef51eda7`.
  The authoritative complete Cache prefix passed `431/431`, failures/skips
  `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v54-complete-regression/20260810_200235_410_c5c978c7`.
  The affected AngelScriptSDK Compiler.Builder prefix passed `64/64`,
  failures/skips `0/0`, at
  `Saved/Tests/cache-v54-angelscript-sdk-builder-regression/20260810_200751_633_09022f77`.
- IC-338, IC-339 and IC-340 are closed. V5.4 is closed at task `30/43`.
  V5.5 is the first pending task: parity must widen from this admitted global
  caller/callee proof to every supported invocation family and two independent
  engines before lifecycle integration begins.

## V5.5 invocation-family parity — 2026-08-10/11 (closed)

- A new dedicated test translation unit builds one real AS module whose normal
  builder path emits all eight cacheable stable invocation kinds, retains each
  successful compile result and asks the maintained writer for its actual
  FunctionArtifact disposition. No serialized fixture or synthetic invocation
  stands in for VM execution state.
- The first official test run is intentionally RED at
  `Saved/Tests/cache-v55-invocation-family-probe-red/20260810_201814_760_772c5c85`.
  `GlobalFunction` succeeds (`0`, 54 bytes); `Method`, explicit constructor and
  destructor, factory, generated default constructor and destructor, and
  `__InitDefaults` all fail closed as `asNOT_SUPPORTED (-7)` after writing
  partial root-function bytes. This proves V5.5 cannot be closed by reusing the
  V5.4 global-function result.
- IC-341 records the capability gap. The next RED/GREEN slice adds explicit
  writer table diagnostics, then implements stable symbolic adapters from the
  observed table matrix before constructing the two-Engine clean-vs-cached
  equivalence oracle.
- Writer diagnostics classified the seven formerly rejected families by their
  exact type/type-id/function/global/string/property tables. Execution artifact
  v3 now emits and resolves those semantic tables without persisting numeric ids,
  offsets or pointers. The same-Engine writer/reader matrix passed all eight
  invocation families at
  `Saved/Tests/cache-v55-symbol-tables-reader-test1/20260810_202859_914_89a39adf`.
- The two-Engine oracle now creates Engine A, captures 19 real products across all
  eight families, validates behavior (`16`, observed destructor value `4`),
  destroys it, creates Engine B and shifts its numeric FunctionIds before restore.
  The first genuine cross-Engine RED was
  `Saved/Tests/cache-v55-two-engine-parity-red13/20260810_205214_426_4cd1fc28`.
  Assertion-first output initially exposed only RejectedCorrupt, so the test and
  Runtime failure detail were widened before changing behavior.
- The diagnostic rerun at
  `Saved/Tests/cache-v55-special-function-commit-diagnostics-red/20260810_205900_657_815d4913`
  proves ordinary Methods, GlobalFunctions and `InitDefaults` already restore into
  Engine B. All eleven special lifecycle/generated products fail only exact atomic
  commit: every structural/signature comparison is equal, but the detached donor
  lost the target's constructor/destructor/generated/unsafe trait bits. IC-342
  records the format defect and requires an execution codec bump plus an explicit
  root-trait field; V5.5 remains open.
- Execution artifact v4 added the full root trait word while preserving exact
  donor/target validation. The build passed at
  `Saved/Build/cache-v55-function-artifact-v4-root-traits-build1/20260810_210150_598_438a5cc3`;
  the next run restored all 19 products with changed FunctionIds and zero compiler
  calls. It exposed the next real contract gap rather than closing on byte equality:
  the first Factory's complete VM-state hash differed.
- Field-level evidence at
  `Saved/Tests/cache-v55-vm-state-breakdown-red/20260810_210402_428_7b4fa70e`
  isolates the mismatch to derived frame state (`StackNeeded 6/4`, one/zero heap
  object, missing `FParityLeaf` object type at stack position 2). Traits,
  execution bytes and debug bytes are equal. IC-343 requires bounded exact frame
  metadata because the generic reader heuristic cannot recreate compiler-only
  object temporaries; V5.5 remains open.
- Exact ordered frame metadata then made Factory, generated/default and explicit
  lifecycle products VM-equal. The next RED at
  `Saved/Tests/cache-v55-exact-derived-frame-state-test1/20260810_210915_887_b480fdec`
  reached a global function whose sole difference was the debug half of an
  explicit local (`Generated` at program position 1 versus empty/0). IC-344 records
  that DebugSidecar v1 omitted ordinal-aligned local names/declaration positions;
  the debug codec must be widened rather than weakening the complete-state oracle.
- DebugSidecar v2 added exact ordinal-aligned local names and declaration program
  positions. The first complete two-Engine parity run then passed all 19 real
  products across eight invocation families at
  `Saved/Tests/cache-v55-debug-v2-local-variable-table-test1/20260810_211214_776_1b0dc3c0`.
  Engine A was destroyed before Engine B restore; numeric FunctionIds differed,
  compiler calls were zero, and execution bytes, debug bytes, full VM state,
  stable keys and observable behavior were equal.
- Production graph-negative coverage now removes one real dependency, repairs
  FunctionInputDigest/FunctionBody/ModuleSnapshot/RecordIds and then invokes the
  real graph promotion path. PropertyLayout, ScriptType Declaration and Function
  Signature all reject with `RelocationDependencyMismatch`, graph/output zero at
  `Saved/Tests/cache-v55-symbol-dependency-matrix-test1/20260810_213938_482_9080c4a8`.
  The maintained reader also exposes exact ValueLayout use; the dedicated real
  by-value struct artifact accepts both ValueLayout and PropertyLayout and rejects
  the missing ValueLayout edge.
- IC-347 established that mutable user globals are not an admitted language
  shape. The real generated `__StaticType_*` storage and `StaticClass()` helper
  remain TypeSchema-derived implementation artifacts rather than independent
  public Global/Function records. IC-348 normalizes their observations to the
  owning ScriptType Declaration.
- IC-349 added one canonical application-registered environment-type identity
  authority. Its stable key is based on canonical AS type shape/declaration; its
  ABI covers flags, size/alignment, property layout, template subtypes,
  behaviours and enum/typedef/funcdef shape without persisting a TypeId, pointer
  or native address. The maintained compiler now records non-primitive callable
  return/parameter types, clean capture maps external types to EnvironmentAbi,
  and current-Engine/opaque validation use the same authority.
- The final environment bridge build passed at
  `Saved/Build/cache-v55-environment-type-bridge-build3/20260810_220826_919_a15bdf33`.
  SymbolDependencyValidation passed `6/6`, failures/skips `0/0`, at
  `Saved/Tests/cache-v55-environment-type-bridge-test2/20260810_220839_935_d53ec283`.
  The real user `StaticClass()` caller promoted all seven records with exactly one
  `UClass EnvironmentAbi` edge. Removing that edge or the owning Type Declaration
  after repairing all derived bytes independently failed at OpaqueCodec Error 47
  with validated graph/output records both zero. IC-348, IC-349, IC-350 and
  IC-351 are closed; V5.5 remains open for stable identities across every
  invocation owner/kind and the complete corruption/fallback matrix.

- Production Stable FunctionKey construction now validates the semantic owner
  rather than accepting a caller-supplied transient type pointer. The dedicated
  stable-symbol test passed `1/1` at
  `Saved/Tests/cache-v55-stable-symbol-owner-green-test1/20260810_222429_341_89d6fde8`,
  and the complete 19-product/two-Engine parity remained `1/1` at
  `Saved/Tests/cache-v55-stable-symbol-owner-parity-test1/20260810_222503_871_a13593ba`.
- DebugSidecar corruption now includes hash-consistent local-count, local-position,
  malformed UTF-8 and trailing-byte mutations in addition to magic/hash/status
  cases. All leave the target empty, compile exactly once and execute `42`; the
  focused prefix passed `3/3` at
  `Saved/Tests/cache-v55-debug-local-corruption-test1/20260810_222714_507_49367277`.
- The maintained reader now reports exact persisted VM-frame offsets and treats
  an unknown type discriminator as a recoverable read error rather than an
  assertion. Clean root-class capture also admits zero user globals. The final
  object-frame fixture captured seven graph-validated records and two object
  variables, then rejected all eight hash-consistent runtime-state mutations
  atomically before one compiler fallback. It passed `1/1` at
  `Saved/Tests/cache-v55-vm-corruption-test6/20260810_225058_556_4691d275`.
- IC-357 was resolved from measured metadata, not a guessed trait: the synthesized
  zero-argument Factory reports `Invocation=Factory`, equal owner/return type and
  current-module ownership but `Generated=0`. Capture and opaque relocation now
  normalize only that structural signature dependency to the owning Type
  Declaration; real Factory Function Artifacts retain their independent stable
  keys.
- The affected SymbolDependencyValidation, InvocationFamilyParity and
  BuildArtifactRestoreHook prefixes passed `10/10`, failures/skips `0/0`, at
  `Saved/Tests/cache-v55-factory-normalization-focused-regression1/20260810_225148_441_9fcec5b5`.
  The official final Development Editor build passed at
  `Saved/Build/cache-v55-generated-factory-normalization-build2/20260810_225041_001_cea86b83`.
  Complete Cache passed `441/441`, failures/skips `0/0`, at
  `Saved/Tests/cache-v55-complete-regression-after-factory-normalization1/20260810_225322_698_c30f7a4c`;
  affected Compiler.Builder passed `64/64` at
  `Saved/Tests/cache-v55-builder-regression-after-factory-normalization1/20260810_225934_006_a1dce9a8`.
- These results close IC-341–IC-352 and IC-354–IC-357 at their focused
  writer/reader/key/dependency/corruption boundaries. They do **not** yet close
  V5.5: the parity fixture uses the real maintained codecs and hooks but constructs
  the surrounding FunctionBody DTOs directly, while production root-class clean
  capture still rejects reflected methods and publishes exactly one user global
  FunctionBody. IC-359 records the remaining production-graph admission gap.
- Production Clean Capture was subsequently widened to enumerate the complete
  admitted current-module function table. Generated canonical invocation source
  is retained at the maintained builder boundary; intrinsic owner, local script
  function, EnvironmentType and environment function dependencies are normalized
  before serialization and validated by the unchanged strict opaque codec.
- A real inline `FString` member causes the maintained builder—not the test—to
  emit the generated default destructor. Its constructor/destructor references
  use pointer-free EnvironmentSymbol Key+ABI identities, and the production
  current Engine provides the matching function ABI and value layout authorities.
  The all-family production graph passed `1/1` at
  `Saved/Tests/cache-v55-final-production-graph-evidence/20260810_235742_130_edd0c1ca`:
  seventeen generated/default records and fifteen explicit-lifecycle records
  collectively include all eight invocation kinds with unique stable keys.
- The validated production graph then drove the real pre-compiler candidate
  lookup in a fresh Engine. Unchanged source restored with zero compiler calls;
  one edited body compiled only itself; omitted current authority returned typed
  `DependencyMissing`. The prefix passed `2/2` at
  `Saved/Tests/cache-v55-final-validated-graph-lookup-evidence/20260810_235834_804_a721299d`.
- The independent full VM oracle remained `1/1` at
  `Saved/Tests/cache-v55-final-parity-evidence/20260810_235659_719_5a33fb38`:
  Engine A was destroyed before Engine B, all 19 products across eight invocation
  families had shifted FunctionIds, compiler calls were zero, and producer versus
  consumer behavior was `Run=16` with destructor observation `4`.
- The first complete Cache run after widening the production graph was a useful
  regression RED: `15` tests still selected the first FunctionBody or assumed
  exactly seven records at
  `Saved/Tests/cache-v55-final-complete-cache-regression/20260810_235923_352_016f3c55`.
  IC-370 records the correction. The affected tests now locate the exact business
  declaration by canonical name and Stable FunctionKey and use dynamic complete-
  graph counts. Focused results are CleanOracle `10/10`,
  FunctionDependencyIntegration `1/1`, IncrementalGeneration `4/4` and
  SymbolDependencyValidation `6/6` at the four `cache-v55-ic370-*focused1`
  artifacts recorded in IC-370.
- The final official Development Editor build passed at
  `Saved/Build/cache-v55-ic370-stable-target-test-refactor-build1/20260811_001330_634_243255e8`.
  Complete Cache passed `442/442`, failures/skips/not-run `0/0/0`, at
  `Saved/Tests/cache-v55-final-complete-cache-regression-after-ic370/20260811_001818_920_d42cbea4`.
  The distinct UE BuilderIntegration prefix passed `2/2` at
  `Saved/Tests/cache-v55-final-compiler-builder-regression/20260811_002611_964_b1f145b6`,
  while native AngelScriptSDK Compiler.Builder passed `64/64` at
  `Saved/Tests/cache-v55-final-native-sdk-builder-regression/20260811_002706_535_578818cd`.
- V5.5 therefore closes at task `31/43`. Its evidence is intentionally
  compositional: production graph admission, graph-owned fresh-Engine lookup and
  complete two-Engine VM parity each use the real maintained interfaces. V6 is
  the sole owner of the reusable complete Current Authorities service, Engine
  mutation gate, Editor/PIE lifecycle and successful-publication DTO; no parallel
  V5-only lifecycle implementation was added.

## V6.1 per-Engine Cache service, mutation gate and frozen publication DTO — 2026-08-11 (closed)

- The intended interface RED is
  `Saved/Build/cache-v61-service-gate-freeze-red-build/
  20260811_003711_904_a417040d`: the dedicated CQTest requested an Engine-owned
  service, gate and successful-publication DTO, and the official Development
  Editor build failed because `Cache/AngelscriptCacheService.h` did not exist.
- Runtime now creates exactly one `FAngelscriptCacheService` per
  `FAngelscriptEngine`. Its lock is separate from `CompilationLock`; an
  initialization phase admits the owning setup thread, runtime admits the game
  thread, and shutdown closes admission before AS state is released. Same-thread
  reentry requires the current explicit service/epoch/thread token. Stale tokens,
  implicit nesting, runtime worker threads and post-shutdown entry fail without
  mutating service state.
- Freeze accepts only a successful, graph-validated pointer-free Clean Capture
  input while the caller holds the current gate. It validates compatibility,
  context/profile/source coordinates, complete unique module coverage and record
  ownership, then publishes a self-owned shared-const schema-v1 DTO. Invalid or
  duplicate input does not replace latest-good state or consume a transaction
  ordinal. The DTO contains no AS/UE pointers, mutable descriptors or numeric
  FunctionIds and remains readable after its Engine is destroyed.
- The first negative run exposed IC-372 in the test itself: appending
  `Duplicate.Modules[0]` to the same reallocating TArray invalidated the source
  element. The crash is preserved at
  `Saved/Tests/cache-v61-service-gate-negative-test/
  20260811_004422_358_185da7a4`; copying to a local value before the append fixed
  the fixture without changing Runtime validation.
- The service focused prefix passed `3/3`, failures/skips/not-run `0/0/0`, after
  the eligibility refactor at
  `Saved/Tests/cache-v61-service-after-eligibility-batch/
  20260811_010005_302_7abe3a3a`. Its real capture log reports seven validated
  records and its freeze log reports transaction `1`, one module and seven
  records.
- IC-292/IC-373 is closed before lifecycle integration. The intended batch RED is
  `Saved/Build/cache-v61-eligibility-batch-red-build/
  20260811_004948_305_6d1be68a`: the batch DTO and producer entry point were
  missing. The implementation now validates one SourceSnapshot, prepares one
  immutable hook/reverse-hook index pair and runs every sorted unique module under
  one cumulative read budget. Candidate output allocations stay temporary until
  all module queries succeed, so a late budget failure publishes nothing and
  leaves zero live resident/temporary bytes. The existing single-module API is
  still the semantic authority and uses the same internal closure implementation.
- The focused batch prefix passed `2/2` at
  `Saved/Tests/cache-v61-eligibility-batch-test1/
  20260811_005752_583_78022a20`. The 64-module diagnostic row is
  `Prepare=1 IndexBuilds=1 Queries=64 DecodedBytes=405440 PeakResident=18368
  ElapsedMs=0.206`. Small-batch results match one-module authority and an exact
  one-byte-short cumulative limit returns typed `BudgetExceeded`, empty public
  output and zero live accounting.
- Production SourceDiscovery now consumes that batch and passed `12/12` at
  `Saved/Tests/cache-v61-eligibility-production-discovery/
  20260811_005836_411_5dd1ca03`. The overlapping SourceInterface/single-query,
  allocation-capture and immutable-factory regression passed `43/43` at
  `Saved/Tests/cache-v61-eligibility-single-authority-regression/
  20260811_005912_395_95067cfd`.
- The official serialized Development Editor build passed at
  `Saved/Build/cache-v61-eligibility-batch-build2/
  20260811_005746_151_b94ef768`. IC-374 preserves the preceding overlapping-link
  orchestration artifact; it is not product evidence.
- The final complete Cache prefix passed `447/447`, failures/not-run/in-process
  `0/0/0`, at
  `Saved/Tests/cache-v61-final-complete-cache-regression/
  20260811_010053_272_dd500635`. The report contains `398` ordinary successes and
  `49` successes with known log warnings. This is the prior `442` plus three
  Service and two EligibilityBatch methods.
- V6.1 closes at task `32/43`. V6.2 remains the first pending task: it must route
  real Editor initial compile/reload and PIE publication through this service and
  its mutation gate, preserve last-good active state, and distinguish Current
  from PendingColdStart structural changes. The present V6.1 test invokes freeze
  after real production Clean Capture; it does not yet claim that normal Editor
   compilation automatically calls the service.

## V6.2 Editor lifecycle publication — 2026-08-11 (in progress)

- The service now distinguishes three lock-consistent publication slots:
  `Current`, `PendingColdStart` and `LatestSuccessful`. Every valid freeze advances
  Latest; a Current initial/full publication clears Pending, a Current soft
  publication preserves it, and a Pending publication never replaces Current.
  Invalid capture remains atomic and does not consume a transaction ordinal.
- The intended missing-interface RED is
  `Saved/Build/cache-v62-lifecycle-publication-red2-build/
  20260811_011753_000_91bb88b6`. Runtime/Test GREEN linked at
  `Saved/Build/cache-v62-lifecycle-publication-fixture-fix-build/
  20260811_011943_638_bd247bee`. The real compile/ClassGenerator/Clean Capture
  prefix passed `2/2` at
  `Saved/Tests/cache-v62-lifecycle-publication-test2/
  20260811_011959_851_03fa9d61`, proving independent Current/Pending slots, full
  promotion, failure atomicity and non-consuming ordinals. IC-375 records the
  initial duplicate-enum fixture defect.
- IC-376 closes the production Environment Profile prerequisite. The intended RED
  is `Saved/Build/cache-v62-environment-profile-red2-build/
  20260811_012452_854_b342d21a`; the corrected official build passed at
  `Saved/Build/cache-v62-environment-profile-green-build2/
  20260811_012734_560_8995334c`. The focused EnvironmentIdentity prefix passed
  `2/2` at `Saved/Tests/cache-v62-environment-profile-test1/
  20260811_012753_338_01df7898`. It proves stable identity across independent
  Engines and absolute host-root relocation, plus Context/Profile invalidation for
  effective option and logical-mount changes.
- The remaining V6.2 boundary is production invocation: normal Editor initial
  compile and HotReload must build the authoritative source/profile transaction,
  enter the per-Engine mutation gate, freeze after final ClassGenerator/
  reinstancing outcome but before temporary module release, publish structural PIE
  candidates only to PendingColdStart, and preserve Current on compile failure.
  Neither the focused slot test nor the profile test claims this wiring yet.

- Production invocation is now wired through the normal Engine entry points.
  `InitialCompile` and `PerformHotReload` share the same explicit preprocessor
  context with the sole production Environment Profile builder, discover one
  authoritative source candidate, and pass a pointer-free capture context into
  `CompileModules`. Successful initial/full/ordinary soft compilation freezes the
  complete active module set as Current only after ClassGenerator/reinstancing
  decisions; PIE `PartiallyHandled`/structural candidates freeze as
  PendingColdStart; compile or aggregate-capture failure leaves compilation and the
  last-good publication unchanged.
- The intended behavior RED is
  `Saved/Tests/cache-v62-editor-lifecycle-red-test1/
  20260811_013641_607_6b5aee4e`: a normal successful `InitialCompile()` completed
  but the service still reported `Current=0 Pending=0 Latest=0`. The first wired
  method passed at `Saved/Tests/cache-v62-editor-lifecycle-green-test1/
  20260811_014211_012_13f24f78`, publishing transaction `1`, one complete module
  and its authoritative source snapshot without a manual test freeze.
- The expanded run exposed IC-378 rather than a publication-slot defect. New C++
  TypeSchema diagnostics identified the exact new property and showed valid
  offset/size/alignment but a live-installed reflection flag leaking into the cold
  candidate. Persisted cold schema now uses declaration intent while live PIE keeps
  the old UClass unchanged. The final EditorLifecycle prefix passed `3/3`, failed/
  skipped `0/0`, at `Saved/Tests/cache-v62-editor-lifecycle-green-test2/
  20260811_015431_384_b07ec6cd`: failed compilation retained the exact Current and
  active ScriptModule, while structural PIE produced `Tx1 Current -> Tx2 Pending ->
  Tx3 Current` and promoted the same new source snapshot.
- Adjacent regressions remain green: LifecyclePublication `2/2` at
  `Saved/Tests/cache-v62-lifecycle-publication-regression-test1/
  20260811_015518_357_51294345` and EnvironmentIdentity `2/2` at
  `Saved/Tests/cache-v62-environment-identity-regression-test1/
  20260811_015559_701_a86029f8`. The final official build evidence is
  `Saved/Build/cache-v62-editor-lifecycle-cold-property-fix-build1/
  20260811_015330_778_a5707032`. IC-377 records and excludes the incomplete outer-
  wrapper artifacts.
- The complete `Angelscript.TestModule.Cache` prefix passed `454/454`, failed/
  not-run `0/0`, at `Saved/Tests/cache-v62-final-complete-cache-regression/
  20260811_015846_712_b29b54a9`. The report contains `399` ordinary successes and
  `55` successes with warnings/expected diagnostics; all seven EnvironmentIdentity,
  LifecyclePublication and EditorLifecycle methods are present as `Success`.
  V6.2 therefore closes at task `33/43`. V6.3 now owns bounded shutdown flush,
  settings, external APIs and the shared-schema C++/Python diagnostics contract.

## V6.3 shutdown flush, settings, external APIs and diagnostics — 2026-08-11 (in progress)

- The intended first C++ diagnostics interface RED is
  `Saved/Build/cache-v63-cpp-diagnostics-red-build1/
  20260811_020933_960_ec82fe2b`: the new separate CQTest requested
  `Cache/AngelscriptCacheDiagnostics.h`, a per-Service snapshot method and stable
  JSON serializer, none of which existed.
- Runtime now exposes a pointer-free schema-v1 diagnostic snapshot. One lock-
  consistent Service read captures mutation phase, last transaction ordinal and
  immutable Current/PendingColdStart/LatestSuccessful pointers; module/record-kind
  counts and canonical payload bytes are summarized after releasing the gate.
  Deterministic condensed JSON emits full stable keys/hashes, numeric+symbolic enum
  values and decimal-string uint64 values. It deliberately excludes ephemeral
  Service identity, pointers and numeric FunctionIds.
- The corrected official build passed at
  `Saved/Build/cache-v63-cpp-diagnostics-green-build2/
  20260811_021209_960_db233cbb`. The focused C++ diagnostics prefix passed `2/2`,
  failed/skipped `0/0`, at `Saved/Tests/cache-v63-cpp-diagnostics-test1/
  20260811_021226_411_f6bf74f7`; its real Current/Pending report was deterministic,
  4717 characters, transactions `1/2` and seven record-kind rows per module.
  IC-379 records the preceding test-helper namespace collision.
- The existing Unreal-free Python dump baseline remains `16/16` at
  `Saved/Tests/cache-v63-python-dump-baseline1`. This confirms the dual-language
  boundary: C++ captures live Engine state; Python validates and observes persisted
  stores. Correlation/diff/explain extensions, bounded trace, Store publication,
  shutdown flush, settings and console/Blueprint surfaces remain pending, so V6.3
  is not complete.
- Production publication is now convertible as one complete multi-module cold
  Generation rather than one Generation per `.as` module. The intended interface
  RED is `Saved/Build/cache-v63-multi-module-generation-red-build1/
  20260811_021551_693_c90d9251`: the compiler rejected the service's module array
  because only the historical single-module overload existed. The implementation
  retains that overload as a one-element adapter, sorts module snapshots by full
  stable ModuleKey, requires one shared SourceSnapshot/SourceIndex, rejects duplicate
  ModuleKeys and conflicting same-RecordId payloads, deduplicates identical records,
  and promotes output only after Pack and Manifest encoding both succeed.
- The official GREEN build is `Saved/Build/
  cache-v63-multi-module-generation-green-build1/
  20260811_022000_423_ca75765a`. The production-`InitialCompile` focused test passed
  `1/1`, failed/skipped `0/0`, at `Saved/Tests/
  cache-v63-multi-module-generation-test1/
  20260811_022032_590_007960ba`: two independent source modules produced one valid
  Generation with two module snapshots, one Pack, thirteen reachable unique records
  and exactly one deduplicated shared SourceIndex record. Complete Manifest/Pack
  decoding and graph validation succeeded. This closes the complete-publication
  preparation prerequisite, not Store publication or shutdown flush itself.
- The Service-to-Store publication RED is `Saved/Build/
  cache-v63-service-store-flush-red-build1/
  20260811_022412_176_ef4dae99`: a separate real-disk test requested the typed
  lifecycle flush result and Service API, and compilation failed because neither
  existed. Runtime now takes one lock-consistent Current/Pending snapshot, releases
  the Service gate, prepares complete Generations and publishes each lifecycle slot
  through the existing Store transaction. The C++ result retains per-slot
  transaction, preparation error/detail, Store error/stage/commit and GenerationId.
  No discovery, preprocessing, compilation, VM or live Engine pointer enters this
  path.
- The official GREEN build is `Saved/Build/
  cache-v63-service-store-flush-green-build1/
  20260811_022549_500_f1fe9b2d`. The real filesystem test passed `1/1`, failed/
  skipped `0/0`, at `Saved/Tests/cache-v63-service-store-flush-test1/
  20260811_022613_319_623696e3`: first flush committed Current and PendingColdStart,
  both pointers selected the validated Generation, and a second flush returned
  `NotCommitted` for both slots without rewriting them. The synchronous core is
  GREEN; bounded background shutdown ownership, settings and Engine shutdown wiring
  remain pending.
- The bounded-shutdown API RED is `Saved/Build/
  cache-v63-bounded-shutdown-flush-red-build1/
  20260811_022820_902_e6ce8984`: the focused test compiled through the synchronous
  Service/Store surface and failed only because no shutdown-and-wait API existed.
  Runtime now sets `ShuttingDown` and snapshots the immutable lifecycle slots in one
  gate acquisition, runs Store work on a background task without capturing the
  Service, waits only for the configured duration and returns typed `TimedOut` after
  requesting cancellation. A detached timed-out worker is self-owned and retains
  only frozen cache DTOs, its event/result and cancellation flag; no Engine, VM or
  UObject lifetime crosses the boundary.
- The official build passed at `Saved/Build/
  cache-v63-bounded-shutdown-flush-green-build1/
  20260811_023012_293_3974862c`. The expanded real-disk ServiceStoreFlush test passed
  `1/1` at `Saved/Tests/cache-v63-bounded-shutdown-flush-test1/
  20260811_023036_445_d11a8ec0`; its bounded call observed mutation phase `3`
  (`ShuttingDown`) and both already-selected slots returned `NotCommitted`. Settings
  and the `FAngelscriptEngine::Shutdown()` call site were the next slice and are
  recorded below.
- The settings/shutdown interface RED is `Saved/Build/
  cache-v63-settings-shutdown-red-build1/
  20260811_023258_872_a94436fe`: the focused test requested the Cache V2 developer
  settings class and compilation failed because it did not exist. Runtime now owns
  `UAngelscriptCacheSettings` as `Config=Engine, DefaultConfig` with Cache V2
  enabled, packaged runtime reload disabled, a `1.0` second packaged scan interval
  and a `5.0` second bounded shutdown timeout by default.
- `FAngelscriptEngine::Shutdown()` now invokes the bounded Cache V2 flush exactly
  once before AS/Engine state teardown. It resolves the existing Saved-only Store
  root policy, accepts the production `-as-cache-root=` override and an isolated
  engine-config override, and logs typed commit/error outcomes without exposing an
  absolute cache root. Test engines disable persistence by default and opt into a
  real Store only when their fixture supplies an isolated Cache V2 root, preventing
  unrelated engine tests from writing project cache data during teardown.
- IC-380 records a test-only CQTest floating comparison compile failure. The first
  settings/shutdown runtime attempt then proved the production Current publication
  committed before IC-381 exposed a test lifetime error: the test retained a raw
  Service pointer after Engine shutdown correctly destroyed that Engine-owned
  Service. The corrected test captures stable coordinates before shutdown and
  validates only the persisted Store afterward; production ownership was not
  weakened.
- The corrected official build passed at `Saved/Build/
  cache-v63-settings-shutdown-test-lifetime-fix-build1/
  20260811_023903_205_c3ad0259`. The focused settings/shutdown prefix passed `2/2`,
  failed/skipped `0/0`, at `Saved/Tests/cache-v63-settings-shutdown-test2/
  20260811_023924_670_5f56bc34`; the real shutdown log reported
  `CurrentCommit=2`, and reopening the disk Store found the expected Current
  Generation.
- This closes the default settings and real bounded Engine-shutdown publication
  portion only. V6.3 remains open for the console/Blueprint surfaces, bounded
  decision trace/explain chain, Python diff/explain/dependency/correlation, explicit
  packaged-runtime reload behavior and the final focused/full regression pass.
- The shared C++/Blueprint/console status API started with the intended RED at
  `Saved/Build/cache-v63-debug-api-red-build1/
  20260811_024607_585_7b6542c8`: a separate test requested the public diagnostics
  library and compilation failed at the missing header. Runtime now exposes a
  typed explicit-Engine `FAngelscriptCacheDiagnosticJsonResult`, a current-Engine
  resolver, `UAngelscriptCacheDiagnosticsLibrary::GetCacheStatusJson` and the thin
  `as.Cache.Status` console command. All four paths consume the existing pointer-
  free schema-v1 snapshot serializer; none reimplements cache selection or
  validation policy.
- IC-382 records the first GREEN build's forward-declaration tag mismatch. The
  corrected official build passed at `Saved/Build/
  cache-v63-debug-api-green-build2/
  20260811_024811_892_09db3e49`. The focused DebugApi prefix passed `2/2`, failed/
  skipped `0/0`, at `Saved/Tests/cache-v63-debug-api-test1/
  20260811_024834_179_21aa0921`: explicit C++ and Blueprint calls produced byte-
  equal deterministic JSON, missing Engine returned a typed error, the console
  command was registered, and neither `functionId` nor `serviceIdentity` appeared.
- This is the first live C++ debug-tool surface, not completion of all V6.3 APIs.
  Flush/verify/compact/reload and typed explain/trace remain pending. The Python
  tool remains the read-only persisted-store observer and will correlate this C++
  JSON through stable compatibility/context/profile/source/module coordinates.
- Python session correlation began with two focused RED cases. After IC-383 fixed
  the wrapper's redirected-stream deadlock, the official wrapper returned the
  intended result at `Saved/Tests/cache-v63-python-session-correlation-red3`:
  existing `16` tests passed and exactly the `2` new `--session-report` cases failed
  because the option did not exist. Runtime/store fixtures were not modified.
- `cache_v2_dump.py` now accepts one bounded schema-v1 Engine-native session JSON
  and correlates its Current/PendingColdStart/LatestSuccessful publications with
  the already-selected persisted Generations. It compares full compatibility,
  context, profile, source snapshot and sorted stable ModuleKeys, reports an exact
  match or ordered per-field/module-set mismatches, exposes only the report basename
  and remains read-only. It does not infer Engine policy, persist numeric
  FunctionIds or treat diagnostics as cache correctness input.
- The repository Python wrapper now drains stdout/stderr concurrently and therefore
  preserves large RED failure reports instead of deadlocking. The final wrapper run
  passed `18/18` at `Saved/Tests/
  cache-v63-python-session-correlation-green1`; the new cases proved exact live-to-
  disk Generation correlation, explicit source-snapshot mismatch explanation and
  byte-for-byte read-only behavior. The tool README records the new command.
- To make that cross-language path usable without scraping logs, a third DebugApi
  method specified `as.Cache.Status Json=<path>`. IC-384 records the initial test-
  include failure; after correction, the behavior RED reached `2/3 PASS` at
  `Saved/Tests/cache-v63-status-json-file-red-test1/
  20260811_030350_557_dcdf2fe7`, failing exactly because the command rejected the
  argument and no file existed.
- `as.Cache.Status` now prints JSON with no arguments or writes byte-identical JSON
  when passed one `Json=` path. Relative paths resolve below
  `Saved/Angelscript/Diagnostics`; absolute paths are accepted only when they remain
  below Project Saved after normalization. The command creates the containing
  directory, never writes a cache Manifest/Pack, and returns a bounded error for an
  invalid path or failed write. The official build passed at `Saved/Build/
  cache-v63-status-json-file-green-build1/
  20260811_030509_809_e594a287`; DebugApi passed `3/3`, failed/skipped `0/0`, at
  `Saved/Tests/cache-v63-status-json-file-green-test1/
  20260811_030523_929_dd396a76`. The test loaded the generated file and proved it
  was byte-equal to the explicit C++ API JSON consumed by Python correlation.
- The complete `Angelscript.TestModule.Cache` regression then passed `463/463`,
  failed/skipped `0/0`, at `Saved/Tests/
  cache-v63-debug-cross-language-full-regression1/
  20260811_030727_951_1cd94784`. The report contains `408` ordinary successes and
  `55` successes with warnings/expected diagnostics. This freshly covers the new
  DebugApi methods alongside existing archive, identity, clean capture, Store,
  shutdown, restore, incremental compiler, multi-Engine and stable-route tests.
  The independent Python debug-tool suite remains `18/18 PASS` at
  `Saved/Tests/cache-v63-python-session-correlation-green1`.
- This establishes the first end-to-end debug observation bridge—live C++ status
  -> optional JSON file -> Python persisted-Generation correlation—without making
  either diagnostic frontend a cache authority. V6.3 remains in progress because
  typed decision trace/explain, semantic Generation diff/dependency analysis,
  flush/verify/compact/reload frontends and packaged reload policy are not yet all
  implemented or verified.
- The explicit lifecycle-Flush API started with the intended missing-capability
  RED at `Saved/Build/cache-v63-flush-api-red1/
  20260811_032242_029_110b8897`: a new dedicated test file requested
  `FAngelscriptCacheFlushApiResult`, `FlushAngelscriptCacheToStore()` and the
  `as.Cache.Flush` command, and compilation failed because those symbols did not
  exist. The test did not expand the already-large TypeSchema or DebugApi files.
- Runtime now exposes typed explicit/current-Engine Flush entry points. They reject
  missing Engine/Service, disabled project cache, test-isolated persistence,
  invalid timeout and root-selection/Store failures without discovering,
  preprocessing or compiling source. A zero API timeout uses the configured
  shutdown timeout. The console accepts only an optional positive finite
  `Timeout=` and is a thin caller of the same API.
- Shutdown and the public control now share
  `ResolveAngelscriptCacheRequestedBaseRootForEngine()`, so an Engine config
  override, `-as-cache-root=` and the Saved default cannot select different stores
  merely because the flush came from a console command rather than teardown.
  IC-385 records and resolves the only GREEN-build include defect.
- The final official build passed at `Saved/Build/
  cache-v63-flush-api-refactor-build1/
  20260811_032658_223_1165bcca`. The focused prefix passed `2/2`, failed/skipped
  `0/0`, at `Saved/Tests/cache-v63-flush-api-refactor-test1/
  20260811_032719_218_56a82f12`. The first explicit call committed Current with a
  nonzero GenerationId, disk Current reopened to that exact ID, the console's
  second call succeeded idempotently, and a null explicit Engine returned the
  typed `EngineUnavailable` result.
- This closes the explicit C++/console Flush-control portion of V6.3. It does not
  mark the coarse V6.3 checkbox complete: bounded decision trace/explain,
  generation verification/diff/dependency tooling, compaction, packaged reload
  policy and the final complete regressions remain.
- The Python semantic-Generation-diff RED is `Saved/Tests/
  cache-v63-python-generation-diff-red1`: the existing `18` methods passed and
  the one new dedicated-file test failed only because `--diff` was absent.
  `--diff LEFT RIGHT` now loads both pointer/id-selected Generations through the
  existing physical validator and joins records by `{RecordKind, stable semantic
  owner}`. A changed FunctionBody or ModuleSnapshot is therefore `changed`, while
  identical RecordIds remain `unchanged` independent of Pack placement. Unknown
  future payload schemas fall back to exact immutable RecordId rather than a
  guessed owner. The GREEN suite passed `19/19` at `Saved/Tests/
  cache-v63-python-generation-diff-green1` and proved the store byte-for-byte
  unchanged.
- The Python dependency-explain RED is `Saved/Tests/
  cache-v63-python-dependency-explain-red1`: all previous `19` passed and only the
  new `--explain` method failed. The tool now walks already-decoded
  `actual_dependencies` in canonical order, resolves decoded module/type/function
  targets by stable semantic owner, bounds recursion by visited RecordId and marks
  cycles. Undecoded global/property/environment authorities stay explicitly
  unresolved; no source parser or compiler is invoked. The complete Python suite
  passed `20/20` at `Saved/Tests/
  cache-v63-python-dependency-explain-green1`, including a self FunctionContent
  dependency reported as one resolved bounded cycle and read-only file snapshots.
- IC-386 records an invalid outer timeout that interrupted the first attempted
  complete Cache rerun without producing a report. With matching inner/outer
  budgets, the official complete Cache prefix passed `465/465`, failed/not-run
  `0/0`, at `Saved/Tests/cache-v63-flush-api-full-regression2/
  20260811_033522_317_2e00baa7`; process/wrapper exits were `0/0`, with `404`
  ordinary successes and `61` successes carrying expected diagnostics.
- At this checkpoint the C++ live side provides Status JSON/file and explicit
  typed Flush, while Python provides physical verification, stable filters,
  live-report correlation, semantic Generation diff and bounded dependency
  explanation. This follows the accepted capability-based language allocation;
  V6.3 still needs live decision trace/typed explain capture, remaining controls
  and packaged reload policy before its coarse checkbox can close.
- The bounded decision-journal interface started with the intended missing-header
  RED at `Saved/Build/cache-v63-decision-trace-red1/
  20260811_034544_839_d9c0de68`. Runtime now owns a per-Service, default-disabled,
  fixed-capacity journal. Every event is pointer-free and schema-versioned, uses
  stable module/function/record/profile/source coordinates, assigns a monotonic
  event ordinal and evicts the oldest ordinal deterministically. Reconfiguring
  capacity starts a new journal; Disable preserves captured events until Clear.
- The initial trace build passed at `Saved/Build/
  cache-v63-decision-trace-green-build1/
  20260811_035029_986_4d3a958c`. The first focused run passed `2/2` at
  `Saved/Tests/cache-v63-decision-trace-green-test1/
  20260811_035158_591_db77d20b`: three successful publication decisions retained
  ordinals `2,3` at capacity two, reported one eviction, and Status JSON serialized
  the same DTO without `functionId` or `serviceIdentity`. `as.Cache.Trace`
  Enable/Capacity/Clear/Disable used that same Service journal.
- Lifecycle Flush tracing then used a behavioral RED, not a missing-symbol RED.
  The expanded prefix built at `Saved/Build/
  cache-v63-lifecycle-trace-red-build1/
  20260811_035705_944_89fdc13a` and failed exactly one new method (`2/3 PASS`) at
  `Saved/Tests/cache-v63-lifecycle-trace-red-test1/
  20260811_035725_320_897e9e57` because explicit Flush left the journal empty.
  Runtime now emits one event per attempted Current/Pending slot, including the
  lifecycle or Store/CleanCapture reason domain, transaction, stable ModuleKeys,
  Generation coordinate, attempt/success counts and elapsed microseconds. An
  invalid, empty or timed-out operation still emits one bounded operation event.
- The lifecycle-trace build passed at `Saved/Build/
  cache-v63-lifecycle-trace-green-build1/
  20260811_035905_598_38447bea`; the focused prefix passed `3/3` at
  `Saved/Tests/cache-v63-lifecycle-trace-green-test1/
  20260811_035936_125_c5ffb395`. Its real disk Flush event reported `Tx=1`,
  `Outcome=Completed`, `Reason=0`, the exact committed Generation and a nonzero
  measured duration.
- Typed live Explain is a query over this captured immutable journal, not a second
  parser or compiler. IC-387 records the incidental test hash-construction defect
  in the first RED build. The C++ request AND-composes event, transaction, stage,
  stable module/function and RecordId selectors; output is sorted by event ordinal,
  returns typed `InvalidRequest`/`NoMatch`, and reuses the Status/Trace event JSON
  serializer. `as.Cache.Explain` is a thin frontend over the same API.
- The typed-Explain build passed at `Saved/Build/
  cache-v63-typed-explain-green-build1/
  20260811_040430_583_eeb04d8d`; its separate test file passed `2/2` at
  `Saved/Tests/cache-v63-typed-explain-green-test1/
  20260811_040505_858_43b14720`. Adjacent regressions remained GREEN:
  Diagnostics `2/2` at `Saved/Tests/cache-v63-debug-api-regression1/
  20260811_040601_016_d505c3f0`, FlushApi `2/2` at `Saved/Tests/
  cache-v63-flush-trace-regression1/20260811_040637_482_15598df2`, and the
  Python offline diff/explain/correlation suite `20/20` at `Saved/Tests/
  cache-v63-debug-tools-python-regression1` after the IC-388 command correction.
- This closes the first bounded trace plus typed C++ Explain slice. It does not
  claim that startup/function-reuse decisions are all being captured yet: those
  production call sites must emit their own typed events as the real startup
  restore and StableJIT route integration is wired. V6.3 also still owns packaged
  reload policy and remaining Verify/Compact/control acceptance.

### V6.3 packaged reload, persisted maintenance controls and final closure — 2026-08-11

- Packaged Runtime reload is now an explicit Runtime-owned Disabled/Manual/
  Automatic safe-point policy independent of the Editor DirectoryWatcher.
  Blueprint/C++ owns `RequestRuntimeReload()` plus the completion delegate, and
  `as.ReloadScripts` calls the same queue. Body-only edits activate normally;
  deletion and structural UPROPERTY/UFUNCTION/layout changes return
  `RequiresRestart`, retain executable last-good Current and publish only
  `PendingColdStart`; syntax failure returns `CompileFailed` and retains Current
  without publishing Pending. Stable changed-module keys and RuntimeReload trace
  events are derived from immutable publication DTOs rather than numeric
  FunctionIds. IC-389–IC-393 record the build capacity, wrapper, PIE-policy and
  expected-diagnostic corrections.
- Official focused evidence is GREEN: reflected API `2/2` at `Saved/Tests/
  cache-v63-runtime-reload-api-test1/20260811_043535_137_169f5f9b`; the final
  packaged behavior prefix `7/7` at `Saved/Tests/
  cache-v63-packaged-runtime-reload-regression1/
  20260811_050008_712_d6ea10d5`; the standalone compile-failure method at
  `Saved/Tests/cache-v63-packaged-reload-compile-failure-focused1/
  20260811_044238_375_5e068ca0`.
- The C++ maintenance surface now exposes typed `Verify`, `Compact` and
  `ForceClean` APIs plus thin `as.Cache.*` commands. Shallow Verify validates the
  atomic pointer and content-addressed Manifest; deep Verify reuses the production
  pinned Manifest/Pack/record/semantic-graph validator and reports bounded read
  budgets. Compact derives Profile and SourceSnapshot solely from immutable
  Current and calls the existing two-phase rooted compactor. ForceClean selects
  all active modules or one canonical name/full StableModuleKey, then queues their
  actual source sections through the normal HotReload compiler transaction with
  `ForceClean`; it never deletes or edits Store objects directly.
- The intended maintenance missing-API RED is `Saved/Build/
  cache-v63-maintenance-api-red1/20260811_044611_581_a91e9302`; the first GREEN
  build and Verify/Compact prefix are `Saved/Build/
  cache-v63-maintenance-api-build1/20260811_045010_690_f96fd3ad` and
  `Saved/Tests/cache-v63-maintenance-api-test1/
  20260811_045032_249_0655c4e0` (`2/2`). The intended ForceClean missing-API RED
  is `Saved/Build/cache-v63-force-clean-api-red1/
  20260811_045311_009_5797716a`; the implementation build passed at
  `Saved/Build/cache-v63-force-clean-api-build1/
  20260811_045447_057_02b0aaca`.
- IC-394 records the first ForceClean fixture's honest clean-capture rejection.
  After adding one admitted root class, MaintenanceApi passed `3/3` at
  `Saved/Tests/cache-v63-force-clean-api-test2/
  20260811_045922_069_a14b5238`. The later failing-compiler extension built at
  `Saved/Build/cache-v63-force-clean-failure-build1/
  20260811_051233_296_88c5d43b` and passed `4/4` at `Saved/Tests/
  cache-v63-force-clean-failure-test1/20260811_051250_642_666e1d8e`. It proves a
  syntax error returns typed `ForceCleanFailed/CompileFailed`, keeps the exact
  immutable Current pointer, creates no Pending publication and leaves the old
  function executable with result `503`.
- The language allocation has been corrected to the actual capability boundary.
  C++ owns live Engine Status/JSON, trace, Explain, Flush, Verify, Compact,
  ForceClean and RuntimeReload; Python owns read-only persisted dump, physical
  validation, stable filters, semantic generation `--diff`, bounded dependency
  `--explain` and C++ session correlation. There is no duplicate C++
  `as.Cache.Diff`; Python `--diff` is the formal semantic persisted-generation
  comparison. `cache-v2-debuggability.md`, `design.md` and the spec delta now state
  this explicitly. The independent Python wrapper passed `20/20` at
  `Saved/Tests/cache-v63-debug-tools-python-regression2` in `0.336s`.
- The first complete regression after maintenance integration passed `482/482`
  (`416` ordinary, `66` expected-warning successes) at `Saved/Tests/
  cache-v63-final-full-regression1/20260811_050116_051_37095cf2`, process/wrapper
  `0/0`. After adding the explicit ForceClean compile-failure oracle, the final
  complete Cache prefix passed `483/483` (`414` ordinary, `69` expected-warning
  successes), failed/not-run `0/0`, process/wrapper `0/0`, at `Saved/Tests/
  cache-v63-final-full-regression2/20260811_051548_756_cac5af13`. Total Automation
  test duration was `467.2345s`; wrapper duration was `502248ms`.
- V6.3 is therefore behavior-complete and closes at `34/43` tasks. The bounded
  journal currently records real successful-publication, lifecycle-Flush and
  packaged-RuntimeReload call sites. Startup/function-reuse/StableRoute events are
  not fabricated in the debug frontend; they must be emitted when their remaining
  production integration call sites land in V6.4/V6.5/V7. This is an integration
  continuation, not an incomplete diagnostics API contract.

## V6.4 Engine-owned stable FunctionId routes and immutable Native/VM snapshot — 2026-08-11

- TDD began with `AngelscriptCacheFunctionRouteSnapshotTests.cpp`. Its four methods
  require a normal compile to publish one stable VM route, a body-only reload to
  retain StableFunctionKey while changing ExecutionContentHash and snapshot ordinal,
  a failed reload to retain the exact last-good snapshot, and two Engines to reject
  each other's transient numeric FunctionIds. The intended missing-API RED is
  `Saved/Build/cache-v64-function-route-red1/
  20260811_053414_614_7f05987a`.
- Runtime now publishes `FAngelscriptCacheFunctionRouteSnapshot` as an immutable
  `TSharedPtr<const ...>` per Engine. Each sorted entry contains the sole full-width
  StableFunctionKey identity, canonical declaration, current Engine-owned function
  pointer/FunctionId, selected VM/Native route and graph-verification state. Pointers
  and numeric IDs are explicitly transient: the resolver rechecks Engine ownership,
  current ID-to-pointer equality and full key equality on every lookup, and none of
  those transient coordinates enter Store records or diagnostics JSON.
- Accepted normal compile and validated restore both rebuild the snapshot; module
  discard removes stale routes. A failed compile does not publish a new snapshot,
  preserving the exact last-good `TSharedPtr`. Restored routes merge only after
  complete graph validation plus current Engine/module/ID/key provenance. IC-397 and
  IC-398 record the initial missing restored route and the internal JIT-field access
  correction. FreshEngineRestore and ExactWarmRestore passed `4/4` at `Saved/Tests/
  cache-v64-fresh-restore-regression2/20260811_055039_000_c80cb9e6` and `Saved/Tests/
  cache-v64-exact-warm-regression1/20260811_055141_827_f2076ad4`.
- Normal clean capture derives `ValidatedFunctionArtifactIdentities` only from
  graph-reachable FunctionBody records after the complete candidate graph validates.
  The sorted list is a pointer-free live handoff and is recomputed during promotion;
  it is not another persisted record or identity authority. Route publication joins
  it by the full StableFunctionKey. The body-reload test proves key/profile stability,
  changed execution content, a new immutable snapshot and execution result `602`;
  the failed-reload test proves result `603` remains executable from last-good.
- Each verified publication emits a bounded `StableRoute/Published` decision event
  with stable module/function/content/profile coordinates and VM/Native reason. It
  never emits the current pointer or FunctionId. The identity/trace intended RED was
  `2/4` at `Saved/Tests/cache-v64-verified-route-red-test1/
  20260811_055648_944_506be554`; the GREEN build is `Saved/Build/
  cache-v64-verified-route-green-build1/20260811_055905_345_cb8323f9` and the focused
  prefix passed `4/4` at `Saved/Tests/cache-v64-verified-route-green-test1/
  20260811_060040_657_c6aaf2f0`.
- The two-Engine method proves both Engines derive the same StableFunctionKey while
  owning different live function pointers; each numeric ID resolves only through
  its owner. The held prior immutable snapshot is inspected as value data only and
  the test never dereferences an old transient pointer after reload.
- The first full regression was `486/487` at `Saved/Tests/
  cache-v64-final-full-regression1/20260811_060402_214_e9467f81`. IC-400 records the
  sole failure: an older bounded-trace test hard-coded one initial event and did not
  account for the new real StableRoute event. After making its eviction/ordinal
  oracle baseline-relative, DecisionTrace passed `3/3` at `Saved/Tests/
  cache-v64-trace-expectation-fix-test1/20260811_061342_614_8c17266d`.
- Final production build passed at `Saved/Build/cache-v64-final-build1/
  20260811_060345_452_42003482`. The final complete Cache prefix passed `487/487`,
  failed/not-run `0/0`, process/wrapper exit `0/0`, at `Saved/Tests/
  cache-v64-final-full-regression2/20260811_061428_230_16b5d5f7`. Automation duration
  was `481.710327s`; the report contains `Errors=0` and `Warnings=76` expected/non-
  failing warning noise.
- V6.4 is behavior-complete and closes at `35/43` tasks. V6.5 remains the only open
  V6 task: StaticJIT Provider absence/removal/content/profile/ABI/Live-Coding failure
  must alter only affected per-function route selection while valid VM Cache data
  and unrelated routes remain usable.

## V6.5 Cache-owned StaticJIT route isolation — 2026-08-11

- The focused tests were authored first in
  `AngelscriptCacheStaticJITIsolationTests.cpp`. After correcting test-only include
  and CQTest API assumptions (IC-402/IC-403), the clean intended RED was the missing
  production method at all four call sites: `Saved/Build/
  cache-v65-staticjit-isolation-red3/20260811_063430_812_9c86e6db`.
- Runtime now exposes one narrow Engine method,
  `RefreshFunctionRouteSnapshotAfterStaticJITChange(bool)`. The boolean is not a
  Provider matcher: it states whether the sibling-owned integration has already
  applied a validated provider selection at a safe point. `false` retains the exact
  prior route snapshot and returns without a publication. `true` enters the
  per-Engine `RouteRefresh` mutation gate and republishes only the transient route
  snapshot from current live functions. The method never reads provider manifests,
  never performs ABI/catalog matching and never mutates Current, Previous,
  PendingColdStart, LatestSuccessful or Store objects.
- The first implementation build passed at `Saved/Build/
  cache-v65-staticjit-isolation-green1/20260811_063533_767_d263e6e0`. After adding
  per-outcome debug information, the final build passed at `Saved/Build/
  cache-v65-staticjit-isolation-logging-build1/
  20260811_063907_487_d478c09c`.
- `ProviderArrivalAndDepartureRepublishOnlyRoutes` proves that an injected,
  already-validated provider can change function A from VM to Native and its
  departure can restore VM without changing function B's key or any Cache
  publication. `PerFunctionMissOutcomesKeepUnrelatedNativeAndCacheCurrent` covers
  ProviderAbsent, ContentMismatch, ProfileMismatch, EntryAbiMismatch and
  ProviderGenerationMismatch: A stays VM, B stays Native, route ordinal advances
  and the exact lifecycle pointers remain. `FailedLiveCodingOutcomePublishesNothing`
  proves the rejected path keeps even the exact route snapshot pointer.
- The final focused prefix passed `3/3`, failed/skipped `0/0`, at `Saved/Tests/
  cache-v65-staticjit-isolation-focused2/
  20260811_064059_480_cb500973`. Its Automation log records typed human-readable
  lines such as `Outcome=ContentMismatch RouteOrdinal=3 VM=1 Native=1 CurrentTx=1`
  so future failures expose the injected reason, route publication and unchanged
  Cache transaction together.
- Existing route and journal behavior remained GREEN: FunctionRouteSnapshot passed
  `4/4` at `Saved/Tests/cache-v65-function-route-regression1/
  20260811_064146_152_2f9eff3c`; DecisionTrace passed `3/3` at `Saved/Tests/
  cache-v65-decision-trace-regression1/20260811_064355_272_91dc91f3`.
- A broad `Angelscript.TestModule.StaticJIT` compatibility run at `Saved/Tests/
  cache-v65-staticjit-existing-regression1/
  20260811_064446_735_b9179b30` passed all `19` tests that had their required input.
  The other `11` tests all failed before their behavior oracle for the same explicit
  prerequisite: the locally generated matched
  `AOT/Generated/StaticJITAotFixture.Cache` and generated `.jit.cpp/.jit.hpp` pair
  was absent. This is recorded as IC-404 and is not claimed as a V6.5 behavior
  failure or a full StaticJIT pass.
- The final complete Cache prefix passed `490/490`, failed/skipped `0/0`, errors `0`
  and expected/non-failing warnings `79`, at `Saved/Tests/
  cache-v65-final-full-regression1/20260811_064632_370_b1327e7c`. Wrapper/process
  exits were `0/0`; wrapper duration was `529.2s`.
- The read-only Python dump/diff/explain suite passed `20/20` in `0.335s` at
  `Saved/Tests/cache-v2-dump/20260811_065533_724`. This remains independent from C++
  Automation: C++ owns live Engine/Editor/PIE diagnostics and controls, while Python
  owns offline persisted-file observation; both use the same stable schema meanings.
- V6.5 is behavior-complete and closes V6 at `36/43` tasks. Actual StaticJIT Provider
  ABI/catalog selection and its Live Coding state machine remain acceptance evidence
  for sibling OpenSpec `refactor-as-static-jit-external-module`, not an unimplemented
  responsibility hidden inside this cache change.
## V7.1-V7.3 direct cutover, C++ process report and package tooling — 2026-08-11

- The intentional V7.1 missing-API RED is `Saved/Build/
  cache-v71-legacy-cutover-red1/20260811_070126_349_5ef1ec2c`. After the local
  compile corrections in IC-406, the inspection implementation built at
  `Saved/Build/cache-v71-legacy-inspection-green2/
  20260811_070256_979_62c3dc26` and its initial focused prefix passed `3/3` at
  `Saved/Tests/cache-v71-legacy-inspection-focused1/
  20260811_070314_073_3fe29710`.
- The V7.2 production-selection RED built at `Saved/Build/
  cache-v72-legacy-flags-red-build1/20260811_070411_750_90588b7e`; its focused
  run was intentionally `3/4`, with only the old-config-field absence assertion
  failing, at `Saved/Tests/cache-v72-legacy-flags-red-test1/
  20260811_070428_153_954f4a4e`. The direct cutover build then passed at
  `Saved/Build/cache-v72-legacy-production-cutover-build1/
  20260811_071107_673_23a2c860` (`103` actions). Final LegacyCutover passed
  `4/4` at `Saved/Tests/cache-v72-legacy-production-cutover-test1/
  20260811_071242_351_7486152a`.
- The retained sibling transport was regression-checked rather than deleted:
  StaticJIT NativeForms passed `2/2` at `Saved/Tests/
  cache-v72-staticjit-nativeforms-regression1/
  20260811_071320_880_b9a79b58`, and Engine Isolation passed `14/14` at
  `Saved/Tests/cache-v72-engine-isolation-regression1/
  20260811_071404_507_e257a14d`. The per-symbol retention/removal decision is in
  `staticjit-compatibility-bridge-inventory.md`.
- V7.3 integration found that the specified `-as-cache-report` process boundary
  had not actually been implemented (IC-408). The intended field/API RED is
  `Saved/Build/cache-v73-process-report-red1/
  20260811_072144_366_18a75573`. The complete Runtime/test build passed at
  `Saved/Build/cache-v73-process-report-green1/
  20260811_072242_772_9587aced`; after correcting the shutdown-lifetime test
  assumption in IC-409, the final incremental build passed at `Saved/Build/
  cache-v73-process-report-green2/20260811_072544_819_ce2ca03a`.
  `Angelscript.TestModule.Cache.SettingsAndShutdown` then passed `3/3`, failed/
  skipped `0/0`, at `Saved/Tests/cache-v73-process-report-green2/
  20260811_072603_043_33def430`. The report logged a real Current publication,
  `mutationPhaseName=ShuttingDown`, stable schema version `1`, no numeric
  FunctionId and `3322` characters of pointer-free JSON after a committed shutdown
  flush.
- `Tools/Diagnostics/TestAngelscriptCachePackageSmoke.ps1` first failed at the
  intended missing helper module/function boundary, then passed against a temporary
  disposable archive. It covers missing/only-Pak Script, missing `Binds.Cache`,
  rejected `PrecompiledScript.Cache`, rejected packaged `Script/AngelscriptCache`,
  ambiguous executables, escaped mutation paths, fixture scenario bytes, incomplete
  reports and process argument construction. It never writes the workspace Script
  tree.
- The following V7.3 commands all exited `0` without building or launching a real
  package:

  ```powershell
  Tools\Diagnostics\TestAngelscriptCachePackageSmoke.ps1
  Tools\Diagnostics\tests\RunTestSuiteSelfTests.ps1
  Tools\RunTestSuite.ps1 -Suite CachePackage -DryRun
  Tools\RunTestSuite.ps1 -ListSuites
  ```

  The catalog contains exactly `PackageSmoke:Development` and
  `PackageSmoke:Shipping` in `CachePackage`; `All` contains exactly one
  `Angelscript.TestModule.Cache` automation entry and zero `PackageSmoke` entries.
- `Config/DefaultGame.ini` stages `../Script` as NonUFS. `RunPackage.ps1` contains
  no cache-generation pre-step and now treats post-package loose layout validation
  as part of package success. Real archive/executable evidence remains intentionally
  deferred to V7.6.

## V7.4 complete Cache, HotReload and generated-AOT StaticJIT acceptance — 2026-08-11

- The pre-fix complete Cache prefix was already GREEN `495/495` at `Saved/Tests/
  cache-v74-full-regression1/20260811_073601_630_8aba6326`, but the first complete
  HotReload prefix exposed a real access violation at `Saved/Tests/
  cache-v74-hotreload-regression1/20260811_074515_815_f7892144`. It crashed in
  `ProviderStructFullReloadRetargetsConsumerFunctionParameter` with process/wrapper
  exit `3/1` and no completed report. The call stack was `asCDataType::Format ->
  asCScriptFunction::GetDeclaration -> TryBuildFunctionKey ->
  RebuildFunctionRouteSnapshot -> CompileModules`.
- IC-410 records the lifecycle cause and correction. A provider struct had been
  replaced while its consumer module remained live for dependency reference update;
  the V6.4 route refresh formatted that retained function through released old type
  metadata. `RebuildFunctionRouteSnapshot` now distinguishes transaction-rebuilt
  modules from dependency-artifact-invalidated retained modules. Only new compiler
  output derives new declarations/keys; retained modules reuse owned snapshot values,
  and invalidated retained routes clear verified artifact identity and select VM
  until recompile. Persisted Store records, source invalidation and StableFunctionKey
  authority are unchanged.
- The corrected full build passed at `Saved/Build/
  cache-v74-route-hotreload-fix-build1/
  20260811_075047_292_c9c0c4b4` with process/runner exit `0/0` in `121604ms`.
  The exact affected dependency prefix then passed `2/2`, including the previously
  crashing method, at `Saved/Tests/cache-v74-route-hotreload-fix-focused1/
  20260811_075424_590_0c689a26`.
- The three focused cache-side regressions passed without weakening route semantics:
  FunctionRouteSnapshot `4/4` at `Saved/Tests/
  cache-v74-route-hotreload-fix-route-regression1/
  20260811_075510_392_d6393023`; StaticJITIsolation `3/3` at `Saved/Tests/
  cache-v74-route-hotreload-fix-staticjit-regression1/
  20260811_075600_621_3f9292a9`; DecisionTrace `3/3` at `Saved/Tests/
  cache-v74-route-hotreload-fix-trace-regression1/
  20260811_075643_943_8b759aa3`.
- The corrected complete HotReload prefix passed `122/122`, failed/skipped `0/0`,
  process exit `0`, no timeout, in `123779ms` at `Saved/Tests/
  cache-v74-route-hotreload-fix-full-hotreload1/
  20260811_075729_149_d1a61a50`. The corrected complete Cache prefix passed
  `495/495`, failed/skipped `0/0`, process exit `0`, no timeout, in `534543ms` at
  `Saved/Tests/cache-v74-route-hotreload-fix-full-cache1/
  20260811_075950_441_9711ddf6`.
- The dedicated official `Tools/RunStaticJITTests.ps1 -LabelPrefix
  cache-v74-staticjit-aot` workflow resolved IC-404's missing-pair prerequisite by
  performing its baseline build, commandlet AOT generation, generated-source
  rebuild and automation run. The final complete StaticJIT prefix passed `30/30`,
  failed/skipped `0/0`, process/wrapper exit `0/0`, in `81133ms` at `Saved/Tests/
  cache-v74-staticjit-aot_04_tests/20260811_080942_712_e895fedd`.
- V7.4 is therefore GREEN and closes task `40/43`. No real PIE, package or benchmark
  claim is made by these commandlet/Automation results; those remain V7.5-V7.7.

## Production exact startup, real PIE and atomic batch restore — 2026-08-11

- The first real PIE fixture attempts exposed capture-admission and expected-error
  fixture boundaries (IC-412 through IC-415) without weakening production rules.
  The final UE 5.8 Editor/NullRHI PIE prefix passed `2/2` at
  `Saved/Tests/cache-v75-real-pie-uobject-test3/
  20260811_084252_350_6349dea2`. It proves cold/warm Current use and the mutation
  sequence `710 -> 720 -> 720 -> 730`: an invalid edit retains last-good `720`, a
  structural edit during PIE leaves the live session safe while producing
  PendingColdStart, post-PIE full reload promotes it, and the next PIE observes
  `730` plus the new reflected property. Adjacent EditorLifecycle passed `3/3` at
  `Saved/Tests/cache-v75-editor-lifecycle-regression1/
  20260811_084404_605_4dd3b037`; HotReload.PIESession passed `7/7` at
  `Saved/Tests/cache-v75-hotreload-pie-regression1/
  20260811_084449_642_a29ee9da`.
- IC-416 replaced batch reset-on-one-`NotCacheable` with module-local capture
  isolation. The intended RED was `1/2` at `Saved/Tests/
  cache-ic416-partial-capture-red-test2/
  20260811_085306_440_83f8540d`; focused capture and typed trace are GREEN `2/2`
  at `Saved/Tests/cache-ic416-partial-capture-green-test1/
  20260811_085649_663_c2e769ad` and `Saved/Tests/
  cache-ic416-partial-trace-green-test1/
  20260811_090048_542_52fb7ea7`. Real host startup observed
  `Candidates=37 Captured=1 Skipped=36`, proving unsupported modules no longer
  erase independently eligible artifacts.
- IC-417 connected direct discovery, Store selection and exact restore to the
  production `FAngelscriptEngine::InitialCompile()` path before preprocessor
  construction. Its original production RED was `0/1` at `Saved/Tests/
  cache-ic417-production-warm-red-test1/
  20260811_090947_622_3187fdca`. The production prefix subsequently passed `3/3`
  at `Saved/Tests/cache-ic417-partial-fallback-test1/
  20260811_093236_611_2da1345c`: unchanged two-module startup restores with zero
  frontend work and no redundant write; changed source compiles and publishes a
  different Generation; a partial persisted module set returns
  `ModuleSetMismatch` before activation and keeps all live modules complete.
- IC-420/IC-421 add schema-2 online provenance (`restoredFromStore` and
  `persistedGenerationId`) while retaining Python session-schema v1 compatibility.
  The C++ production restore Current/no-op-flush evidence is
  `Saved/Tests/cache-ic417-restored-current-test1/
  20260811_092232_394_25e45f69`, `1/1`. The independent Python dump/diff/explain,
  corruption and C++-session correlation suite passed `20/20` at
  `Saved/Tests/cache-v2-dump/20260811_093336_434`.
- IC-422 then proved that the production coordinator was still sequential below
  its preflight. The deterministic second-prepared-module RED passed build but
  failed behavior `0/1` at `Saved/Tests/cache-ic422-atomic-red-test1/
  20260811_094534_958_188a69dd`: the fault observed one already active module and
  startup emitted the fatal partial-mutation diagnostic. Runtime now prepares every
  VM module, descriptor and verified route off `ActiveModules`, discards the full
  staging set on any failure, and runs one batch PreGenerate/ClassGenerator setup,
  one `SwapInModules`, one reload and one route publication. The same fault is GREEN
  `1/1` at `Saved/Tests/cache-ic422-atomic-green-test1/
  20260811_095038_797_6fc3a03e`, observing `ActiveAtFault=0`, `RoutesAtFault=0`,
  safe normal-compile fallback `FrontendEvents=6`, and live results `801/802`.
- After the batch refactor, the complete production warm prefix passed `4/4` at
  `Saved/Tests/cache-ic422-production-regression1/
  20260811_095137_629_651b27e1`. ExactWarmStartup, FreshEngineRestore,
  FreshEngineRollback and FunctionRouteSnapshot passed together `12/12` at
  `Saved/Tests/cache-ic422-restore-adjacent1/
  20260811_095246_015_19d4cd8d`, demonstrating no staging contamination across
  Engines. The strengthened success oracle passed `1/1` at
  `Saved/Tests/cache-ic422-batch-success-test1/
  20260811_095513_735_c3fb79ce`: `Modules=2`, `Routes=2`, VM values `501/502`,
  frontend events `0`, Store files/digest unchanged and restored Generation
  provenance exact.
- The final IC-422 incremental build passed at `Saved/Build/
  cache-ic422-batch-success-build1/
  20260811_095451_118_b4ce1ed6`. V3.4/V3.5 are now backed by production
  complete-batch evidence rather than the old single-module component inference.
  The final atomic build passed at `Saved/Build/cache-v75-atomic-final-build1/
  20260811_095813_378_5ef638d2`. Cache PIE, Cache EditorLifecycle and HotReload
  PIESession were then rerun together against that binary and passed `12/12`,
  failed/skipped `0/0`, at `Saved/Tests/cache-v75-atomic-final-pie1/
  20260811_095843_675_c70c54a4`. V7.5 is therefore GREEN and closes task `41/43`;
  Development/Shipping multi-launch and performance remain V7.6/V7.7.

## V3.14 declaration-order-independent class-graph identity — 2026-08-11

- `AngelscriptCacheClassGraphDeclarationOrderTests.cpp` captures the same named
  module in two isolated Full Engines with two mutually referencing reflected
  sibling classes in opposite source order. Each capture contains 22 validated
  records, two TypeSchemas and eight stable functions. It compares ModuleKey,
  ModuleInterface, ModuleState, named TypeSchema RecordIds, StableFunctionKeys,
  declarations, declaration ABI, source/input/execution/profile coordinates and
  then restores each graph into an independent fresh Full Engine.
- The intended behavior RED was `0/1` at `Saved/Tests/
  cache-v314-declaration-order-test1/20260811_171001_478_b942c11b`. Both ModuleKeys
  were `e47fa26d9d84a23cefefbce99a3c16d9afd03f020eac5a16c1b51197f2f5da08`,
  but ModuleInterface RecordIds were
  `6a68228b3ef45b80a2b366baca18551c9fa8da9272d691e3414a3911d1a6d943` and
  `d77f99f9f836d29f16383076b2fa86d0064b6d4b54596b0f43530f67402b217a`.
  The failure was exact and non-crashing; all other compared coordinates already
  agreed.
- IC-462 traced the mismatch to class-graph producer ordering, not hashing or the
  generic wire archive. `PrepareModuleInterface` correctly StableKey-sorts the
  declaration set, but embedded Declaration/Function slot ordinals had already
  inherited `Module->Classes` and `ScriptModule->scriptFunctions` traversal.
  TypeSchema independently owns the exact class-local property/method/VFT/behavior
  sequences used by restore, so globally rewriting wire slots was neither required
  nor permitted.
- The corrected producer selects the next ready class by case-sensitive namespace
  and class name while retaining base-before-derived dependency order. It then
  stable-sorts captured functions by canonical owner index, preserving compiler
  relative order within each class, and assigns Function slot ordinals after that
  grouping. No generic serializer, decoder, graph validator, restore path, TypeSchema
  structural order or maintained AS VM format changed.
- The repair's Development Editor build completed all `4/4` actions with process/
  wrapper exit `0/0` at `Saved/Build/cache-ic462-declaration-order-fix-build2/
  20260811_171917_127_2c3d8656`. The preceding
  `cache-ic462-declaration-order-fix-build1/20260811_171843_949_bed090e8` report is
  explicitly non-feature evidence: an outer one-second orchestration timeout killed
  the wrapper before UBT emitted any build bytes (IC-463).
- Corrected focused behavior passed `1/1`, failed/skipped `0/0`, at `Saved/Tests/
  cache-ic462-declaration-order-fix-test2/20260811_172131_657_8aa2fcd0`. Both
  captures now have Interface
  `6f239bf8493d31abc23320e3403c75f99a38d42da0a59c83364c9f490dd1d5f8` and State
  `ce0832e902f9d7079de2f103e22c7e0c8979ecb2a1fc0b2c2a824f9981603802`.
  Each consumer restores two types and eight current-engine routes; Alpha/Beta calls
  return `28/14` in both consumers. Four moved DebugSidecars and exactly their four
  owning FunctionBody RecordIds change, while execution content remains stable.
- Declaration order, reflection surface, cross-class signatures, three-level
  inheritance/VFT, properties, late rollback, StaticName relocation and global-only
  restore passed together `9/9`, failed/skipped `0/0`, process/wrapper exit `0/0`,
  at `Saved/Tests/cache-v314-adjacent-regression1/
  20260811_172243_716_bf94f918`. V3.14 is GREEN and OpenSpec task progress is now
  `51/53`; latest broad acceptance precedes V7.6/V7.7.

## V3.14 complete Cache repair and order-independent function metadata — 2026-08-11

- The first authoritative post-V3.14 Cache prefix completed `513/518` at
  `Saved/Tests/cache-v314-full-regression1/
  20260811_172912_262_b61b3bee`. IC-464 through IC-471 record four stale test
  contracts, one obsolete rollback corruption fixture, the raw-VM-versus-v5-
  envelope fixture error, and the newly exposed intrinsic value-owner layout
  dependency. Focused repairs passed Archive Primitives `13/13`, Fresh Engine
  Restore `4/4`, Cache Service `4/4`, and Symbol Dependency Validation `6/6`.
- Correcting the invocation-family fixture to use the production execution
  envelope exposed IC-472 rather than a read-budget problem. During Factory
  restore, each raw artifact referenced its constructor before that constructor's
  own callback. The builder descriptor knew its invocation kind, but the public
  `asCScriptFunction` still exposed kind zero and no semantic owner. The explicit
  lifecycle RED is `0/1` at `Saved/Tests/
  cache-ic472-forward-reference-lifecycle-red1/
  20260811_181008_247_b3b81e3d`; all three Factory probes independently reported
  the missing declaration-time identity.
- Maintained-fork builder registration now publishes invocation kind and semantic
  owner as declaration metadata for ordinary/generated constructors,
  destructors, methods, globals, Factories, `InitDefaults`, public single
  functions and lambdas. `BeginBuildArtifactCompile` asserts/finalizes that same
  identity and canonical source rather than creating identity as a side effect of
  callback order. No numeric FunctionId, pointer, codec fallback or type-only
  constructor alias was introduced.
- The repair's Development Editor build passed all `4/4` actions at `Saved/Build/
  cache-ic472-declaration-identity-green-build1/
  20260811_181214_344_cc9a0bb4`. InvocationFamilyParity then passed `1/1` at
  `Saved/Tests/cache-ic472-forward-reference-green1/
  20260811_181229_493_3a8ebe91`: all 19 artifacts, including all three Factories,
  restored with zero compiler invocation; raw VM bytes, v5 envelope, debug
  sidecar, complete VM-state hash, StableFunctionKey and executed return/
  destructor behavior matched across isolated producer and consumer Engines.
  InvocationFamilyArtifact, StableSymbolIdentity, CompilerDependencyCapture and
  SymbolDependencyValidation passed together `10/10` at `Saved/Tests/
  cache-ic472-adjacent-regression1/20260811_181346_495_cafada93`.
- The final authoritative complete Cache prefix passed **518/518** (`432` Success
  plus `86` SuccessWithWarnings), failed/not-run/in-process `0/0/0`, process/
  wrapper exit `0/0`, no timeout, at `Saved/Tests/
  cache-v314-full-regression2/20260811_181500_343_270718d5`. This closes the five
  broad failures without weakening graph validation, stable function granularity,
  Fresh Engine rollback or the execution-envelope contract. HotReload and the
  generated-AOT StaticJIT workflow are rerun next because they consume the same
  declaration-time stable identity; V7.6/V7.7 remain the only task checkboxes.
- Post-repair cross-feature acceptance is also GREEN. The complete HotReload
  prefix passed `122/122` (`117` Success plus `5` SuccessWithWarnings), failed/
  not-run/in-process `0/0/0`, at `Saved/Tests/
  cache-v314-postidentity-full-hotreload1/
  20260811_182816_176_3e0e737a`. The official generated-AOT workflow completed
  baseline build, paired artifact generation, generated-source rebuild and the
  complete StaticJIT prefix `30/30` at `Saved/Tests/
  cache-v314-postidentity-staticjit-aot_04_tests/
  20260811_183132_545_50e33813`. Current Cache PIE, Cache EditorLifecycle and
  HotReload PIESession then passed together `12/12` at `Saved/Tests/
  cache-v314-postidentity-editor-pie1/20260811_183316_843_5ae29ff9`, including
  real PIE start/stop, warm Current reuse, body and structural edit policy,
  last-good retention, PendingColdStart and post-PIE promotion. No cross-feature
  failure remains before the deliberately last V7.6/V7.7 package/performance
  matrices.

## IC-474 package-helper repair and IC-475 Development production RED — 2026-08-11

- The first Development build/cook/stage/archive and cold packaged process were
  Runtime-successful, but the PowerShell reader rejected valid diagnostic schema
  3. A focused helper test first reproduced
  `Unsupported Cache V2 process report schema '3'`. A second RED proved that the
  package runner had no bounded way to clear prior `Saved/CachePackageSmoke`
  evidence when reusing packaged binaries with `-SkipPackage`.
- The helper now accepts schemas 1/2/3, requires the schema-3 `functionRoutes`
  envelope, continues rejecting unknown or incomplete schemas, and exposes a
  narrowly guarded reset that may remove only the ordinary non-reparse-point
  `Saved/CachePackageSmoke` directory below the explicit disposable Archive. It
  rejects roots/outside paths/files/reparse points and preserves sibling Saved
  content. `Tools/Diagnostics/TestAngelscriptCachePackageSmoke.ps1` is GREEN with
  process exit `0` and `AngelScript Cache package-smoke helper self-tests passed`.
- The same Development archive was then rerun with `-SkipPackage`; the bounded
  reset made scenario one genuinely cold. `01-cold` passed process, report and
  Python Store/session correlation. It published source snapshot
  `65f41e02bb2610f5f47fab24f003377b886f81ada32b2f5c636210e2c0b06c3b`
  and Generation
  `67226cfdcd28741843f2284981b3da1e11d729e210f46761d9ad817ae326b6d6`
  with nine ModuleSnapshots, 79 diagnostic records and 56 stable function routes.
- `02-unchanged-warm` is the intended new production RED, not acceptance. It
  selected the same source/Generation but exact restore returned
  `ExactStartup/ModuleSetMismatch(9)` with detail `The current and persisted
  exact-start module sets differ`; Current was recaptured by normal compilation
  with `restoredFromStore=false`. The wrapper correctly stopped with
  `Scenario 'Warm' expected Current to be restored from Store.` The run summary is
  `Saved/CachePackage/cache-v76-real-Development/
  20260811_183513_864_f2ccf611/Summary.json`; exact reports are beneath
  `Archive/Windows/AngelscriptProject/Saved/CachePackageSmoke/Reports/`.
- Source inspection establishes the architectural boundary behind the RED:
  production `InitialCompile()` only carries its post-compile capture context into
  `CompileModules()`, while all builder restore/compile-result callback installation
  call sites outside the maintained-fork forwarders are in `AngelscriptTest/Cache`.
  The existing compiler bridge is therefore component-tested but not production-
  connected. This reopens V5 as V5.6 and changes mechanical progress to `51/54`;
  no Shipping or performance result is inferred.

## V5.6 Slice 1 production compiler-reuse RED — 2026-08-11

- A separate CQTest file now owns the production contract:
  `AngelscriptCacheProductionCompilerReuseTests.cpp`. It creates a disposable
  Saved project/source/cache root, starts a scan-free full Engine, compiles one
  admitted enum/function module plus one deliberately unsupported two-enum module,
  flushes the resulting one-module Generation, and starts a second full Engine
  through the normal `InitialCompile()` path. The test never installs a builder
  callback itself.
- The first build exposed only IC-476's test-local UE 5.8 checked-format error at
  `Saved/Build/cache-v56-production-reuse-red-build1/
  20260811_190402_413_df2cba6d`. Replacing normalized runtime format strings with
  case-sensitive token replacement preserved `ASTEST_AS` and symbol isolation.
  The complete Development Editor target then compiled and linked all `4/4`
  actions at `Saved/Build/cache-v56-production-reuse-red-build2/
  20260811_190441_436_273974bb`.
- Focused behavior is the intended `0/1` RED at `Saved/Tests/
  cache-v56-production-reuse-red-test1/
  20260811_190501_808_57dcc346`. Both launches compile and publish safely, the
  exact-start event is `ModuleSetMismatch`, both current modules are active, and
  their functions execute to `901/902`. The only failure is the wished-for
  non-null `FunctionLookup/Restored` event at test line 204. This proves the test
  detects IC-475 through real `InitialCompile()` rather than component plumbing.

## V5.6 Slice 2 production partial-Generation compiler reuse — 2026-08-11

- Production now retains the pinned selected read session only when exact startup
  reports a zero-activation `ModuleSetMismatch`. It passes that immutable candidate
  through the ordinary initial `CompileModules` transaction; exact whole-Generation
  restore remains the earlier atomic fast path and partial modules are never made
  active.
- `CompileModules` prepares eligible current modules after
  `BuildLayoutFunctions()` and before `CompileModule_Code_Stage3()`. For this
  conservative slice, the complete current SourceSnapshot must equal the selected
  Manifest SourceSnapshot. The persisted graph is revalidated against the current
  Engine environment, then exact-source declaration/type/state/function authorities
  feed `FAngelscriptCacheCompilerBridge`; restored and compiled results emit typed,
  pointer-free `FunctionLookup` events.
- Official build command:
  `Tools\RunBuild.ps1 -Label cache-v56-production-reuse-green-build1
  -TimeoutMs 1800000 -NoXGE`. It discovered the new source file and completed all
  105/105 compile/link/metadata actions with process/wrapper exit `0/0` at
  `Saved/Build/cache-v56-production-reuse-green-build1/
  20260811_191302_827_020780d8`.
- Official focused command:
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionCompilerReuse" -Label
  cache-v56-production-reuse-green-test1 -TimeoutMs 600000`. Result is total/pass/
  fail/skip `1/1/0/0`, process/wrapper exit `0/0`, at `Saved/Tests/
  cache-v56-production-reuse-green-test1/
  20260811_191544_967_beeb8116`.
- The same method that was previously `0/1` now cold-publishes one admitted module
  from two current modules, warm-selects Generation
  `cd0408db093f5b70e11649af3faf629c536be2b948a69be19ce75bdf57b75d55`,
  reaches exact `ModuleSetMismatch`, restores the admitted function before its
  compiler closure, normally compiles the unsupported/current-only module, executes
  values `901/902`, and completes normal publication and shutdown flush. Its trace
  contains seven decision events and a non-null restored FunctionKey
  `08b021f9e1b31d585c99f23e6b555a75f9dfd7750ae030f218f34cded62bed34`.
- This evidence closes Slice 2 only. V5.6 remains unchecked at `51/54` until a
  body-only source edit uses newly produced current pre-compile authorities to
  restore unchanged functions, compile the edited function and publish the complete
  new Generation atomically. Broad Cache/HotReload/StaticJIT/Editor/PIE reruns stay
  after that behavior is GREEN.

## V5.6 Slice 3 body-edit production RED — 2026-08-11

- Added one real, non-mocked production method in the existing dedicated
  `AngelscriptCacheProductionCompilerReuseTests.cpp`. One module contains an
  unchanged global function and a second global function whose body changes from
  `return 1002` to `return 2002`; declarations, enum/type surface and compile
  profile remain stable.
- Test-only build command:
  `Tools\RunBuild.ps1 -Label cache-v56-bodyedit-red-build1 -TimeoutMs 1800000
  -NoXGE`. Result is 4/4 actions, process/wrapper exit `0/0`, at
  `Saved/Build/cache-v56-bodyedit-red-build1/
  20260811_192159_355_948d4777`.
- RED command:
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionCompilerReuse" -Label
  cache-v56-bodyedit-red-test1 -TimeoutMs 600000`. Result is total/pass/fail/skip
  `2/1/1/0` at `Saved/Tests/cache-v56-bodyedit-red-test1/
  20260811_192219_981_49441350`; process exit `255`, wrapper exit `1`.
- The Slice 2 partial-Generation method remains GREEN. The new method cold-
  publishes SourceSnapshot
  `8015f080b2c906cea8e3ee4394e1e158e57fe6cb74f73a3fc0e8b9aef50a6003`,
  recompiles the body-edited source into
  `4eb1084113875a1d0e2c5fe8ddf483657c41b1d20ddcf7dc9b8061b623c89d74`,
  executes the current values `1001/2002`, and publishes one current module. Its
  only assertion failure is the intended missing unchanged-function Restored event
  at line 388. Exact startup reports typed `DirectInputMismatch`, confirming the
  selected persisted candidate is currently discarded before per-function reuse.
- This is the authoritative Slice 3 RED. Runtime implementation must retain that
  safe zero-activation candidate, build current pre-compile semantic authorities,
  restore only the unchanged StableFunctionKey, compile the changed key, and keep
  the new SourceSnapshot publication atomic.

### First GREEN attempt — phase-order RED

- Runtime build passed 6/6 at `Saved/Build/
  cache-v56-bodyedit-green-build1/20260811_192936_617_f464a593`.
- Focused production remained `2/1/1/0` at `Saved/Tests/
  cache-v56-bodyedit-green-test1/20260811_193001_204_e21012ad`.
- The new diagnostic boundary reported
  `Current pre-compile authority rejected module ... The enum descriptor and
  current compiled AS enum authority disagree`. Source tracing proves descriptor
  `ScriptType`/`Enum` are ClassGenerator outputs assigned after stage 3, while the
  callback must be installed before stage 3. IC-478 records the phase-correct
  authority correction; this run is not GREEN evidence.

### Second GREEN attempt — mixed body-edit restore/compile GREEN

- The IC-478 correction validates the preprocessor descriptor's canonical enum
  name against the staging `asCModule` enum and derives reflection intent from the
  descriptor declaration. It does not require the later ClassGenerator-owned
  `ScriptType` or `UEnum*` outputs at the pre-function hook.
- Official build command:
  `Tools\RunBuild.ps1 -Label cache-v56-bodyedit-green-build2 -TimeoutMs 1800000
  -NoXGE`. It completed 4/4 actions with process/wrapper exit `0/0` at
  `Saved/Build/cache-v56-bodyedit-green-build2/
  20260811_193206_238_bc12cbf6`.
- Official focused command:
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionCompilerReuse" -Label
  cache-v56-bodyedit-green-test2 -TimeoutMs 600000`. Result is total/pass/fail/
  skip `2/2/0/0`, process/wrapper exit `0/0`, at `Saved/Tests/
  cache-v56-bodyedit-green-test2/20260811_193224_024_f34526db`.
- The body-edit method selected candidate Generation
  `a7d8623143ae8dd440afb6a7528e2498bb9eb4df17e57f51ef3bf5f627aa459e`,
  changed the complete SourceSnapshot from
  `700768788b35ec030b33509452cd043c5d3820f234b0061198e578fcfe8500b7` to
  `0f2906d99682a092785f904d313c43d2f3de3a5379833481c589f32ebbf0296b`,
  restored unchanged StableFunctionKey
  `6c5b34c7d72e731ce6bcbc44cb1f7c942261e8d22843e1d0f50d5e16742d1a2b`,
  compiled changed StableFunctionKey
  `46449c3249d17dfdf3eec5d5524f7b70cb837c5e33efadf653fd060cdb6ab7ba`,
  executed `1001/2002`, and atomically published the complete current one-module
  Generation. The earlier partial-Generation method also remains GREEN.
- This closes the primitive/global body-edit proof for Slice 3. V5.6 remains
  unchecked at `51/54` while the shared current-authority producer is widened to
  every admitted cache vertical and Slice 4 diagnostics/regressions/package
  acceptance remain outstanding.

### Root-class production body-edit RED

- Added a dedicated
  `AngelscriptCacheProductionClassCompilerReuseTests.cpp` rather than extending
  the global production test translation unit. The test uses two independent,
  scan-free Full `FAngelscriptEngine` instances over one temporary disk source
  root. Production source discovery maps that physical root through the normal
  Game logical mount/virtual-path identity; no absolute temporary path becomes a
  ModuleKey or FunctionKey input.
- Cold source contains one reflected root `UObject` class and two `UFUNCTION`
  methods returning `1101/1102`. The cold Engine runs ordinary `InitialCompile()`,
  Clean Capture admits one module and flushes the complete Generation. The source
  changes only the second method body to return `2102`; a fresh Engine then runs
  ordinary `InitialCompile()`, ClassGenerator materializes the class, an instance
  is created through the resulting UClass and both functions execute through
  reflection as `1101/2102`.
- Official build command:
  `Tools\RunBuild.ps1 -Label cache-v56-class-bodyedit-red-build2 -TimeoutMs
  1800000 -NoXGE`. Result is successful link/metadata `2/2`, process/wrapper exit
  `0/0`, at `Saved/Build/cache-v56-class-bodyedit-red-build2/
  20260811_194054_757_b2b97b37`. The immediately preceding label used an
  orchestration wait of one second and was terminated before producing a usable
  wrapper conclusion; it is not a build or implementation failure.
- Official RED command:
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassCompilerReuse" -Label
  cache-v56-class-bodyedit-red-test1 -TimeoutMs 600000`. Result is total/pass/
  fail/skip `1/0/1/0`, process/wrapper exit `255/1`, at `Saved/Tests/
  cache-v56-class-bodyedit-red-test1/20260811_194107_096_ff4da2ae`.
- The exact runtime boundary is typed and expected: current pre-compile authority
  rejects the module as `NotCacheable` because it contains a class. Both Engines,
  cold Store publication, changed-source compile, ClassGenerator, UClass instance,
  reflection calls and current Generation publication succeed. The sole assertion
  failure is line 262: no `FunctionLookup/Restored` event exists for the unchanged
  method. This is the authoritative root-class Slice 3 RED; production must derive
  the current class/type/property/method authority from the staging `asCModule`
  plus preprocessor descriptors before stage 3, without requiring later
  ClassGenerator `ScriptType`/UClass outputs.

### Root-class production body-edit GREEN

- The shared current-authority producer now admits the first reflected root-class
  vertical directly from the staging `asCModule` object type plus preprocessor
  descriptors. It derives type declaration/schema, reflected method declarations,
  generated constructor/factory/destructor invocation identities, VFT ownership
  and module interface/state before ClassGenerator has produced `ScriptType`,
  `UClass*` or `UFunction*` outputs. Unsupported class shapes still fail closed.
- IC-479 was a local C++ DTO mismatch: the new producer passed optional
  `DeclaredType` directly to a concrete type mapper. The correction maps into a
  local `FAngelscriptCachedDataType` and assigns the optional only after success.
  The corrected build passed 5/5 at `Saved/Build/
  cache-v56-class-bodyedit-green-build2/20260811_195009_071_bb3b2883`.
- The next runtime attempt exposed IC-480 rather than a graph mismatch. Generated
  default constructor/factory/destructor functions had stable kind/owner identity,
  but their canonical source was retained only after the host's pre-stage3 restore
  hook. The maintained builder now performs a semantic-only authority preparation
  pass at the end of successful `BuildLayoutFunctions()`. It uses the same helper
  and finalized invocation descriptor as `BeginBuildArtifactCompile`, but emits no
  callback, captures no dependency, restores no bytecode and invokes no compiler.
- The maintained-fork change rebuilt all affected Runtime/Test unity units and
  passed 32/32 actions with process/wrapper exit `0/0` at `Saved/Build/
  cache-v56-class-bodyedit-green-build3/
  20260811_195247_870_9fc1c403`.
- Official focused command:
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassCompilerReuse" -Label
  cache-v56-class-bodyedit-green-test2 -TimeoutMs 600000`. Result is total/pass/
  fail/skip `1/1/0/0`, zero warnings/errors, at `Saved/Tests/
  cache-v56-class-bodyedit-green-test2/
  20260811_195331_681_6bc99df3`.
- The second Full Engine selected candidate Generation
  `5ddae1e727601ffab34167778a4daecb0d30e12ac4df2daf9ac85a7d7a58f11b`,
  changed SourceSnapshot from
  `9817bc7e8b89c23ef079a5f3b7f89b77159a2c9310212915003064595add26ab`
  to `6e0aa99e0e500f72d19e100b5e04651f650d2190af8af6bb1ef9d9788f0b54b1`,
  restored unchanged method key
  `54539df0049fbc418b2235d2ba1825a7d43501f119b29110728983a4fc449b77`,
  compiled edited method key
  `52dd6aaabe3bee92bd1bffb11e5791102ee2c8d1d77a3a33ea5f0c816bd8f6d7`,
  materialized the reflected UClass and executed `1101/2102`. Its pre-assert dump
  contains 17 typed reuse events with ModuleKey, FunctionKey, candidate Generation,
  outcome, reason and detail, so failures remain diagnosable even when an early
  assertion stops the test.
- This closes the method-only root-class body-edit vertical, not all class
  authority. Class properties, class graphs/inheritance, non-primitive method
  types and the Clean Capture/shared-producer convergence still require focused
  RED/GREEN coverage before V5.6 can close. Mechanical progress remains `51/54`.

### Property-bearing root-class production body-edit RED

- Added the separate
  `AngelscriptCacheProductionClassPropertyCompilerReuseTests.cpp`; the existing
  method-only file was not enlarged. Its reflected root class owns
  `UPROPERTY() int StoredValue = 31`. The unchanged UFUNCTION reads that property,
  while the second UFUNCTION changes only its body between Engine generations.
  Consequently a restore is legal only if the current type/property declaration,
  layout and dependency authority all match the cold candidate.
- Official test-only build passed 11/11 with process/wrapper exit `0/0` at
  `Saved/Build/cache-v56-class-property-red-build1/
  20260811_200333_717_94bcb914`.
- Official RED command:
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassPropertyCompilerReuse" -Label
  cache-v56-class-property-red-test1 -TimeoutMs 600000`. Result is total/pass/
  fail/skip `1/0/1/0`, process/wrapper exit `255/1`, at `Saved/Tests/
  cache-v56-class-property-red-test1/
  20260811_200356_014_8b219a26`.
- Both complete Engines, cold Store flush, changed-source compile, ClassGenerator,
  reflected property creation/default initialization, reflected method execution
  and current one-module publication succeed. ModuleKey
  `e4193ae1dfe359d62b50f7fa7eeaf7dccfb7c449414d1a33d2cecbc6eb864fd4`,
  TypeKey `f54a0229ebdc42e444348de4cec690a7e8acc9d432692007d4064c8282a50413`
  and PropertyKey
  `9d10f67754aa616d19c1b0d62c14b5ce3726e2744661334ee3d313829b4ec86b`
  are stable; VM and reflected offsets are both `48`; CDO/instance defaults are
  `31/31`; current method results are `1131/2132`.
- The exact sole behavioral failure is line 407: no unchanged-method Restored
  event. The typed runtime detail is `The first current root-class authority
  slice admits no local properties`; TraceEvents=8, Restored=0, Compiled=0. This
  is IC-481 and is the authoritative property RED. Production must build the same
  property declaration/schema/layout authority as Clean Capture before stage 3;
  it must not bypass the property dependency or restore from candidate type data.

### Property-bearing root-class hybrid publication GREEN

- IC-481's current property authority implementation compiled through the official
  wrapper at `Saved/Build/cache-v56-class-property-green-build1/
  20260811_200747_296_cdf883ff`, process/wrapper `0/0`. Its first focused runtime
  attempt intentionally kept the complete-publication assertion and exposed
  IC-482: restore/compile behavior, offsets, defaults and execution were correct,
  but Clean Capture rejected the restored property's relocation dependency and
  published zero modules. RED evidence is `Saved/Tests/
  cache-v56-class-property-green-test1/
  20260811_200803_957_63fca948`, total/pass/fail/skip `1/0/1/0`, process/wrapper
  `255/1`.
- IC-482 now carries only graph-validated pointer-free dependencies for functions
  actually restored in the current compile transaction. Clean Capture still
  canonicalizes, resolves current input authority and checks the current VM
  relocation stream; no cached dependency is reconstructed as an Engine-local
  pointer and `RelocationDependencyMismatch` remains strict.
- Official correction build:
  `Tools\RunBuild.ps1 -Label cache-v56-restored-deps-green-build1 -NoXGE` passed
  with process/wrapper `0/0` at `Saved/Build/
  cache-v56-restored-deps-green-build1/
  20260811_201933_516_dfc27246`.
- Official focused command:
  `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassPropertyCompilerReuse" -Label
  cache-v56-restored-deps-green-test1 -TimeoutMs 600000` passed `1/1/0/0`,
  process/wrapper `0/0`, at `Saved/Tests/
  cache-v56-restored-deps-green-test1/
  20260811_202009_776_cc91d84c`. The cold batch reports zero carried sets; the
  changed-source hybrid batch reports exactly
  `GraphCarriedDependencyFunctions=1`, `Candidates=1 Captured=1 Skipped=0`, then
  publishes the complete current Generation. The decision trace still contains
  one property-reading method Restored and one edited method Compiled; stable
  module/type/property coordinates, offsets `48/48`, defaults `31/31` and current
  reflected results `1131/2132` all pass.
- This closes the two-Engine publication defect, not V5.6 acceptance. The next
  focused gate is a third full Engine with byte-identical warm source, which must
  select the just-published hybrid Generation and prove that graph-carried
  dependencies remain consumable across another process-shaped Engine lifetime.

### Property-bearing root-class third-Engine production closure GREEN

- The same production fixture now performs three complete Engine lifetimes over
  one physical project root and one dedicated Cache V2 root: cold compile/flush,
  changed-body hybrid compile/flush, then an unchanged third `InitialCompile()`.
  It uses normal source discovery and Game virtual-path identity, the production
  preprocessor/compiler/ClassGenerator path, atomic Store generations, reflected
  object construction and reflected invocation. No cache DTO, mock compiler or
  in-memory donor Engine is substituted for those boundaries.
- The first third-Engine RED exposed IC-483. Whole-Generation exact startup reports
  typed `ModuleIneligible` because the frozen V3.5 exact vertical intentionally
  admits only its enum-plus-primitive-global shape; reflected classes are consumed
  through V5.6 bounded hybrid reuse. The only apparent FunctionKey miss was the
  derived `UClass StaticClass()` helper, which is deliberately reconstructed from
  current TypeSchema/ClassGenerator authority and is not a persisted public
  FunctionBody.
- The production callback now reports that exact helper as typed `NotCacheable`
  with invocation kind, generated trait, canonical declaration and stable key.
  It still compiles the helper from current authority, while ordinary methods and
  generated constructors/factories/destructors remain subject to exact graph
  lookup. No duplicate FunctionBody or broad generated-function exemption was
  introduced.
- Official corrected build passed process/wrapper `0/0` at `Saved/Build/
  cache-v56-ic483-green-build2/20260811_203104_595_1317d31f`. Official focused
  command `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassPropertyCompilerReuse" -Label
  cache-v56-ic483-green-test1 -TimeoutMs 600000` passed total/pass/fail/skip
  `1/1/0/0`, process/wrapper `0/0`, at `Saved/Tests/
  cache-v56-ic483-green-test1/20260811_203125_690_a9ffe86b`.
- The third Engine selected the warm Generation and identical SourceSnapshot,
  restored four persisted functions including both user methods, carried four
  graph-validated dependency sets into Clean Capture, classified/compiled exactly
  one derived `StaticClass` helper and produced zero unexplained
  `FunctionKeyMiss`. It published one complete current module and preserved stable
  module/type/property identities, offsets `48/48`, defaults `31/31` and reflected
  values `1131/2132`.
- This is a process-shaped production-path integration test, but it does not claim
  Editor/PIE or packaged equivalence. Those final layers additionally own engine
  subsystem timing, file-watcher/hot-reload interaction, Cook/staging, writable
  cache location, Development/Shipping configuration and repeated executable
  launch. Class-graph/inheritance authority remains the next focused V5.6 gate.

### Same-module class-graph production compiler reuse GREEN

- The dedicated production fixture now closes IC-489 through three complete
  Engine lifetimes over one physical test project and one on-disk Cache V2 Store.
  It uses normal Game virtual-path source discovery, production
  `InitialCompile()`, preprocessing, maintained builder/compiler callbacks,
  ClassGenerator, reflection, atomic flush and graph-validated dependency carry.
- The phase-correct current-authority producer independently rebuilds the
  base-before-derived declaration/type/property/method/VFT/behavior graph from
  staging VM state and preprocessor descriptors before stage 3. It neither copies
  persisted candidate TypeSchema into current authority nor waits for later
  UClass/UFunction materialization.
- Official build `Tools/RunBuild.ps1 -Label
  cache-v56-class-graph-green-build1 -TimeoutMs 1800000 -NoXGE` passed four
  adaptive non-unity actions, process/wrapper `0/0`, at `Saved/Build/
  cache-v56-class-graph-green-build1/
  20260811_210151_995_94bd243b`.
- Official focused command `Tools/RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.ProductionClassGraphCompilerReuse" -Label
  cache-v56-class-graph-green-test1 -TimeoutMs 600000` passed `1/1/0/0`,
  process/wrapper `0/0`, at `Saved/Tests/
  cache-v56-class-graph-green-test1/
  20260811_210208_843_e91246b7`.
- On the changed-source second Engine, the trace records all four expected
  unchanged base/override/derived functions restored before their compiler
  closures and exactly the edited `ReadChanged` function compiled. Module/type/
  property identities, offsets `48/48/56/56`, complete publication and reflected
  `Super::` execution `1020/132` remain current.
- The unchanged third Engine consumes that new Generation, restores all persisted
  ordinary/generated artifacts, reports only the two intentional typed
  `StaticClass()` `NotCacheable` helpers followed by current compilation, leaves
  `UnknownMisses=0`, republishes one complete module and again executes
  `1020/132`. Adjacent production/class-graph and broad Cache/HotReload/StaticJIT/
  Editor/PIE regressions remain required before V5.6 can close.
- Immediate adjacent production authority coverage passed `3/3/0/0`, process/
  wrapper `0/0`, at `Saved/Tests/cache-v56-class-authority-adjacent1/
  20260811_210448_790_8007b5d4`. This jointly reran the method-only root class,
  property-bearing root class and same-module inheritance production paths.
- The complete `Cache.ClassGraph` restore/capture/rollback family passed
  `7/7/0/0`, process/wrapper `0/0`, at `Saved/Tests/
  cache-v56-class-graph-adjacent1/
  20260811_210632_604_b0fc6b24`. It covers declaration-order stability,
  inheritance, cross-class signatures and properties, reflection contracts and
  injected late-preparation rollback.
- The full `Angelscript.TestModule.Cache` prefix then passed its current discovered
  baseline `523/523`, failed/skipped `0/0`, process/wrapper `0/0`, at
  `Saved/Tests/cache-v56-class-graph-complete-cache1/
  20260811_210811_423_7792b2ec`. Its Automation duration was approximately
  `807.30 s`; the official wrapper duration was approximately `842.00 s`.

### V5.6 schema-4 production function-reuse diagnostics GREEN

- IC-490 was first fixed behind explicit REDs rather than inferred from existing
  decision logs. Official missing-API build evidence is `Saved/Build/
  cache-v56-function-reuse-diagnostics-red-build1/
  20260811_213131_112_525f2bf2`; Python rejected schema 4 and omitted coordinate
  validation at `Saved/Tests/cache-v56-function-reuse-python-red1`.
- `FAngelscriptCacheCompileReuseContext` now owns thread-safe per-run counts and
  publishes one immutable pointer-free summary after production compilation.
  The service resets it at the next initial compile. Diagnostic schema 4 emits
  candidate GenerationId, candidate modules, restored functions, compiled misses,
  not-cacheable functions and rejected-corrupt functions independently of the
  bounded trace. Clean Capture skip events now preserve their bounded detail.
- Official final incremental build passed `4/4`, process/wrapper `0/0`, at
  `Saved/Build/cache-v56-function-reuse-detail-green-build3/
  20260811_214138_453_1fbe37b2`.
- The separate C++ summary/JSON tests passed `2/2/0/0` at `Saved/Tests/
  cache-v56-function-reuse-diagnostics-green-test1/
  20260811_213751_122_e976e441`. They prove deterministic schema 4, absent and
  published/reset states, full stable candidate identity, exact counts and no
  FunctionId/pointer surface.
- Production partial-Generation and body-edit methods passed `2/2/0/0` at
  `Saved/Tests/cache-v56-function-reuse-detail-green-test3/
  20260811_214158_583_d23e73a2`. Summary counts come from real Full Engine
  `InitialCompile()` restore/compiler callbacks: the partial path reports one
  prepared candidate module and a restored function; the body edit reports both
  a restored unchanged function and a compiled miss. The partial path also proves
  its real Clean Capture `NotCacheable` event has nonempty detail.
- The read-only Python dump suite passed `26/26` at `Saved/Tests/
  cache-v56-function-reuse-python-green3`. It validates schema-4 hashes/counts,
  correlates candidate Generation presence in the inspected Store, renders the
  exact aggregate and rejects non-stable coordinates. The package-helper self-test
  exits 0 and proves both exact and hybrid warm modes, zero-restored fallback
  rejection, required schema shape and required Clean Capture detail.
- This closes Slice 4 implementation, but not V5.6 acceptance: the latest
  HotReload, generated-AOT StaticJIT and Editor/PIE regressions plus the real
  Development package matrix remain required.

### V5.6 schema-4 complete Cache regression GREEN

- The first complete Cache prefix after IC-490 ran through the official wrapper:
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label
  cache-v56-schema4-complete-cache1 -TimeoutMs 1800000`.
- The structure report at `Saved/Tests/cache-v56-schema4-complete-cache1/
  20260811_214725_359_47cc403d` proves total/pass/fail/skip `525/525/0/0`,
  process/wrapper exit `0/0`, no timeout, Automation duration `834680 ms` and
  wrapper duration approximately `837.2 s`.
- Both new schema-4 methods were discovered and executed under
  `Angelscript.TestModule.Cache.FunctionReuseDiagnostics`: absent service state
  and published/reset pointer-free summary. The same run retained all prior
  archive, Store, fault-injection, fresh-Engine restore, incremental publication,
  production compiler-reuse, diagnostics and shutdown-lifecycle coverage.
- This is broad Cache regression evidence only. HotReload, generated-AOT
  StaticJIT, combined Editor/PIE and real Development package acceptance remain
  required before V5.6 can close.

### V5.6 schema-4 complete HotReload regression GREEN

- Official command `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.HotReload" -Label
  cache-v56-schema4-full-hotreload1 -TimeoutMs 900000` passed total/pass/fail/
  skip `122/122/0/0`, process/wrapper `0/0`, with no timeout.
- Evidence is `Saved/Tests/cache-v56-schema4-full-hotreload1/
  20260811_220234_137_ce997a2f`; Automation duration was `129084 ms` and the
  wrapper duration was approximately `131.6 s`.
- This refreshes file-change discovery, virtual-source separation, soft/full
  class reload and reinstancing after IC-490. Generated-AOT StaticJIT, combined
  Editor/PIE and the real Development package remain required.

### V5.6 schema-4 generated-AOT StaticJIT regression GREEN

- The dedicated official workflow `Tools\RunStaticJITTests.ps1 -LabelPrefix
  cache-v56-schema4-staticjit-aot1 -BuildTimeoutMs 1800000
  -CommandletTimeoutMs 600000 -TestTimeoutMs 600000` completed all four required
  phases: baseline build, paired AOT commandlet generation, generated-source build
  and complete StaticJIT automation.
- Baseline build is `Saved/Build/cache-v56-schema4-staticjit-aot1_01_baseline_build/
  20260811_220521_508_5ee08d82`; generated-source build is `Saved/Build/
  cache-v56-schema4-staticjit-aot1_03_generated_build/
  20260811_220555_446_8b467df1`. Both exited `0`.
- The final report at `Saved/Tests/cache-v56-schema4-staticjit-aot1_04_tests/
  20260811_220610_129_80592a91` passed total/pass/fail/skip `30/30/0/0`,
  process/wrapper `0/0`, in `83153 ms`. This proves the regenerated AOT/native
  artifacts and stable identity consumers compile and execute after IC-490.
- Combined Editor/PIE and the real Development package remain required.

### V5.6 schema-4 real Editor/PIE regression GREEN

- Official combined command `Tools\RunTests.ps1 -TestPrefix
  "Angelscript.TestModule.Cache.PIE+Angelscript.TestModule.Cache.EditorLifecycle+
  Angelscript.TestModule.HotReload.PIESession" -Label
  cache-v56-schema4-editor-pie1 -TimeoutMs 1200000` discovered and passed all
  `12/12`, failed/skipped `0/0`, process/wrapper `0/0`, without timeout.
- Evidence is `Saved/Tests/cache-v56-schema4-editor-pie1/
  20260811_220825_648_ef942b3d`; Automation duration was `59247 ms` and wrapper
  duration approximately `61.6 s`.
- The same process exercised real PIE start/stop, unchanged warm Current, body
  edit, invalid edit with last-good retention, structural PendingColdStart and
  post-PIE promotion, alongside the existing seven HotReload PIE session cases.
- All post-IC-490 Cache/HotReload/StaticJIT/Editor/PIE regressions are now GREEN.
  The real Development package matrix remains the final V5.6 acceptance gate.

### V5.6/V7.6 fresh Development partial GREEN and unattended invalid-source RED

- Official fresh command `Tools\RunAngelscriptCachePackageSmoke.ps1
  -Configuration Development -Label cache-v76-schema4-development1 -TimeoutMs
  3600000` built/cooked/staged/archived successfully in `131329 ms` at
  `Saved/CachePackage/cache-v76-schema4-development1-Development/
  20260811_221010_689_b043ffc8`.
- `01-cold`, `02-unchanged-warm` and `03-one-body-edit` produced process logs,
  schema-4 reports and Python dumps. Warm selected the cold candidate Generation
  and reported candidate modules/restored/compiled/not-cacheable/rejected
  `9/19/4/4/0`; body edit selected the same candidate with a changed source
  snapshot and reported `9/18/5/4/0`. Both passed the exact-or-hybrid package
  oracle and Python correlation before the fourth launch.
- `04-invalid-source` is a production-shaped RED. Its log ends after startup
  compile diagnostics and `[StartupCompileFailure] Showing startup compile-error
  modal dialog`; no report was written and the one-hour wrapper returned `124`.
  Source inspection proves desktop startup ignores unattended mode before calling
  `AddModalWindow`. IC-491 owns the TDD correction and exact timed-out child cleanup.
- This evidence proves real Development hybrid compiler reuse but cannot close
  V5.6 or V7.6 until invalid/restored/structural scenarios and a fresh full
  Development rerun pass.

### Full All parallel regression: every UE shard GREEN; Standalone fixture baseline RED

- The earlier serial `All` attempt was deliberately stopped and is not evidence.
  The replacement uses the official parallel entry point with no fast mode or
  exclusions: `Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy
  CoarseDynamic -TestModuleWorkers 4 -MaxParallelLight 4 -MaxParallelHeavy 4
  -LabelPrefix cache-v56-schema4-all-parallel1 -TimeoutMs 3600000
  -ContinueOnFail`. Four TestModule workers run concurrently while independent
  entries publish separate reports.
- The Standalone entry at
  `Saved/StandaloneTests/cache-v56-schema4-all-parallel1_02_Standalone/
  20260811_230524_813_e4c6ee41`: total/pass/fail `19/14/5`, process exit 8 and
  wrapper entry exit 1. All five failures share the same strict input rejection,
  `manifest must use LF line endings`; fourteen tests and the Standalone build
  passed.
- Final `ParallelSuiteSummary.json` at `Saved/Tests/
  cache-v56-schema4-all-parallel1_20260811_230523` records 37 shards, 36 passed
  shards, one failed Standalone shard, total/pass/fail `2959/2954/5`, and wall
  duration `1073425 ms` (approximately 17m53s). Every Unreal Automation shard is
  GREEN: Cache `525/525`, Editor `83/83`, HotReload `122/122`, StaticJIT `30/30`,
  AngelScriptSDK `691/691`, and all other configured UE prefixes passed.
- IC-492 records the sole broad-suite failure as a strict Standalone fixture/
  checkout line-ending issue. Therefore this run is complete and fully GREEN for
  UE Automation, but the cross-runner `All` result is correctly retained as RED
  until Standalone's five shared-cause failures are separately resolved or
  baseline-attributed.

### IC-491 startup-failure policy RED to focused GREEN

- The separate test unit was compiled before production changes. Official RED
  build `cache-v76-unattended-policy-red-build1` failed only on the wished-for
  unattended config and response-policy API at `Saved/Build/
  cache-v76-unattended-policy-red-build1/
  20260811_232424_069_70838993`, process/final exit `6/1`.
- Runtime config now captures `FApp::IsUnattended()`. A pure response resolver
  sends unattended, commandlet, explicit-exit and unavailable-window hosts to
  exit; only an interactive host with a real retry window selects the existing
  retry flow. The production `InitialCompile()` branch consumes that result
  before any Slate modal. Unattended uses a graceful request so shutdown can
  flush CacheV2 and write `-as-cache-report`; legacy forced exits remain forced.
- Official GREEN build passed all 106 actions with process/final `0/0` at
  `Saved/Build/cache-v76-unattended-policy-green-build1/
  20260811_232607_691_bc5cf1f8`. Focused prefix
  `Angelscript.TestModule.Cache.StartupCompileFailurePolicy` passed all three
  methods at `Saved/Tests/cache-v76-unattended-policy-green-test1/
  20260811_233001_783_6fa8c571`, total/pass/fail/skip `3/3/0/0`, process/final
  `0/0`.
- This proves policy selection, not the real packaged shutdown/report lifecycle.
  Package-helper timeout containment is separately GREEN: its RED first failed
  on the missing timeout resolver; production now caps each launch at five
  minutes and reserves 30 seconds for exact process-tree cleanup plus final
  metadata. `Tools/Diagnostics/TestAngelscriptCachePackageSmoke.ps1` passes.
  IC-491 remains open for the fresh Development scenarios 01-07.

### IC-491 fresh Development iteration: modal/report GREEN, exit status RED then focused GREEN

- Fresh Development run `cache-v76-schema4-development2` rebuilt the corrected
  runtime at `Saved/CachePackage/cache-v76-schema4-development2-Development/
  20260811_233244_274_34a142c0`. Package duration was about 124.5s; cold, warm
  and one-body-edit again passed and wrote full reports/dumps.
- Invalid source did not open a modal and did not time out. It logged the new
  graceful unattended branch, reached normal Engine pre-exit, performed CacheV2
  shutdown and wrote `04-invalid-source.json`. The runner itself returned after
  `180747 ms` and wrote Summary/RunMetadata. This directly closes the original
  modal, report-loss and orphan-process symptom.
- The run correctly remained RED because plain `RequestExit(false)` produced
  process status 0. A new typed exit-request test was added before correction;
  its official RED is `Saved/Build/cache-v76-unattended-status-red-build1/
  20260811_233633_284_e7ddda59`, process/final `6/1`.
- Production now uses `RequestExitWithStatus(false, 3)` for unattended failure,
  retaining graceful shutdown while making failure deterministic. The 106-action
  official build passed at `Saved/Build/
  cache-v76-unattended-status-green-build1/
  20260811_233707_159_7275065d`; all four policy tests passed at `Saved/Tests/
  cache-v76-unattended-status-green-test1/
  20260811_233923_892_02fb8184`.
- A second fresh package is still required because the development2 executable
  predates the explicit status correction. IC-491 remains open until all seven
  scenarios complete on that rebuilt package.

### Development package infrastructure retry: transient Zen lifetime RED

- `cache-v76-schema4-development3` built the corrected game target and completed
  Cook, but did not reach Stage/Archive or any packaged launch. Evidence is
  `Saved/CachePackage/cache-v76-schema4-development3-Development/
  20260811_234041_382_6f0b9965`, package exit `1/1`.
- The log proves the Cook-owned Zen server was initially healthy and flushed the
  Windows oplog, then exited with its `--owner-pid=<CookPid>` before UAT's next
  Stage-side oplog read. The connection to `[::1]:8558` was therefore refused.
  IC-493 records this as package infrastructure, not Cache acceptance evidence.
- UE's non-installing `zen.exe up -p 8558` now owns a user-mode server across the
  complete UAT lifetime; `zen.exe ps` reports it on port 8558. A fresh official
  package rerun (`development4`) subsequently completed UAT and reached packaged
  scenarios, closing this infrastructure interruption.

### IC-491 UE graceful-status constraint and forced-report policy GREEN

- `cache-v76-schema4-development4` proved the engine logged a graceful request
  with status 3 and wrote `04-invalid-source.json`, yet both the archive launcher
  and a direct nested-binary diagnostic returned 0. UE 5.8 source inspection
  shows the graceful Windows request posts a quit code, but the launch loop
  returns `EngineInit()`'s unchanged zero `ErrorLevel`; the plugin cannot rewrite
  that value.
- The final policy therefore writes the requested Cache diagnostic synchronously
  before `RequestExitWithStatus(true, 3)`. A failed startup has no publishable
  Generation, so no last-good Store update is lost. Interactive Editor continues
  to select its existing retry window.
- RED build `cache-v76-forced-report-red-build1` failed only on the missing typed
  pre-exit-report policy field at `Saved/Build/
  cache-v76-forced-report-red-build1/
  20260811_234915_004_8d5ae837`. GREEN build passed all 106 actions at
  `Saved/Build/cache-v76-forced-report-green-build1/
  20260811_235031_736_dccdaab9`.
- The four focused policy methods passed at `Saved/Tests/
  cache-v76-forced-report-green-test1/
  20260811_235208_959_109ff0e9`; package-helper self-tests also pass. One final
  rebuilt Development package remains required for scenarios 01-07.

### IC-491 Development5 report-phase RED and lifecycle-order focused GREEN

- Fresh run `cache-v76-schema4-development5` completed Build/Cook/Stage/Archive
  and passed cold, unchanged-warm and body-edit at `Saved/CachePackage/
  cache-v76-schema4-development5-Development/
  20260811_235318_845_3c6497e7`. Invalid source wrote schema 4 diagnostics,
  logged `Requesting immediate exit with status 3`, exited without a modal or
  orphan, and advanced the package oracle past its nonzero-status check.
- Its remaining exact RED was report ordering: `04-invalid-source.json` had
  `mutationPhaseName=InitializingAnyThread`, so the package helper correctly
  rejected it as an incomplete shutdown report. The structured run finished in
  `170548 ms`; cold/warm/body reports were preserved.
- Source inspection established that `BeginEngineShutdown()` only locks and sets
  the Cache mutation phase to `ShuttingDown`; it does not freeze, flush or publish
  and is idempotently called by the destructor. Calling it before the synchronous
  failure report therefore completes diagnostics without replacing last-good.
- TDD RED `cache-v76-shutdown-report-order-red-build1` failed only on the missing
  explicit ordering field at `Saved/Build/
  cache-v76-shutdown-report-order-red-build1/
  20260811_235821_109_3cc5d6e7`, process/final `6/1`. Production now carries
  `bBeginCacheShutdownBeforeDiagnosticReport` and performs that transition before
  report emission.
- Official GREEN build passed all 106 actions at `Saved/Build/
  cache-v76-shutdown-report-order-green-build1/
  20260811_235847_540_78013b1d`. Focused policy tests passed `4/4/0/0` at
  `Saved/Tests/cache-v76-shutdown-report-order-green-test1/
  20260812_000043_082_75d98ada`; the package-smoke helper self-test also passes.
  A fresh Development package remains required to prove all scenarios 01-07.

### Development6 scenario 04 GREEN; IC-494 two-coordinate package oracle GREEN

- Fresh `cache-v76-schema4-development6` completed UAT and reached scenario 05 at
  `Saved/CachePackage/cache-v76-schema4-development6-Development/
  20260812_000259_158_0c22d163`. Scenario 04 is now end-to-end GREEN: process
  exit 3, timedOut false, schema 4 report phase `ShuttingDown`, no Current
  publication, persisted Current remained body-edit Generation
  `171df492bcfec2aab09608d7c749c15e1305b0ff78cef59c7ef37a8b65df5f5e`.
- Scenario 05 restored Baseline source and deterministically published Baseline
  Generation `67226cfdcd28741843f2284981b3da1e11d729e210f46761d9ad817ae326b6d6`,
  but correctly selected the single V1 Current/last-good body-edit Generation as
  its hybrid candidate. It restored 18 functions and compiled five misses.
- The previous helper used one expected ID for exact persisted restoration and
  hybrid candidate selection, so it falsely rejected that valid B-to-A flow.
  Helper TDD first failed on the absent
  `ExpectedHybridCandidateGenerationId`; the production helper now separates the
  two coordinates and has an explicit wrong-candidate rejection. Its diagnostic
  self-test passes.
- The exact Development6 archive must now be rerun with `-SkipPackage` to execute
  and validate all seven launches under the corrected oracle. No Runtime binary
  rebuild is needed for that retry because IC-494 changes only PowerShell
  orchestration.

### V5.6/V7.6 Development package matrix GREEN

- Official resume command used the exact freshly built Development6 archive with
  `-SkipPackage`, which resets only its isolated evidence root and runs every
  process again. Final `Summary.json` at `Saved/CachePackage/
  cache-v76-schema4-development6-Development/
  20260812_000259_158_0c22d163` records status Passed, exit 0, phase count 7 and
  duration `97613 ms` under label `cache-v76-schema4-development6-resume1`.
- Cold Baseline published source/Generation A
  `65f41e02...b06c3b` / `67226cfd...26b6d6`; unchanged warm retained A and
  restored 19 functions. Body edit published source/Generation B
  `5f5a870d...66f2c` / `171df492...df5f5e` while restoring 18 functions from A.
- Invalid source exited 3 in `4018 ms`, timedOut false, published no Current and
  retained B on disk. Restoring Baseline selected B as its single-current hybrid
  candidate, restored 18 functions, compiled five misses and deterministically
  returned Current to A; the separate Python dump proved A.
- Structural edit published distinct source/Generation C
  `f2d4e67c...6bfb93` / `21fd7b70...694a5`; the following structural warm launch
  retained C and restored 19 functions. All seven reports are schema 4 with phase
  `ShuttingDown`; all dump integrity and C++ session correlations passed.
- Together with complete Cache `525/525`, HotReload `122/122`, generated-AOT
  StaticJIT `30/30` and real Editor/PIE `12/12`, this closes V5.6 production
  compiler reuse. V7.6 remains open for the fresh Shipping matrix only.

### V7.6 Shipping1 compile RED — IC-495

- Fresh official Shipping command failed before Cook at `Saved/CachePackage/
  cache-v76-schema4-shipping1-Shipping/
  20260812_001204_698_6d497846`, package process/final exit `6/1`.
- The sole compiler error was the plugin fork's unconditional
  `check(SchemaIt != SchemaEnd)` while the member is absent under Shipping
  `DO_CHECK=0`. UE 5.8's authoritative same method wraps that check in
  `#if DO_CHECK || USING_CODE_ANALYSIS`; the plugin now matches it exactly.
- No Cache scenario launched, so Shipping1 is configuration-build RED only. A
  completely fresh Shipping package rerun is required for GREEN evidence.

### V7.6 Shipping2 link RED — IC-496

- Shipping2 at `Saved/CachePackage/cache-v76-schema4-shipping2-Shipping/
  20260812_001503_049_d535ca1b` compiled the corrected serialization unit, then
  failed only while linking five unresolved per-engine accessors; package
  process/final exit `6/1`.
- Their declarations, members and callers are unconditional Runtime surfaces,
  but definitions were accidentally nested inside
  `WITH_DEV_AUTOMATION_TESTS`. The five definitions now sit outside the macro;
  actual test helpers remain guarded.
- No Cook or Cache scenario launched. A fresh Shipping package is the required
  link and end-to-end GREEN evidence.

### V7.6 Shipping3 package GREEN / launch protocol RED — IC-497

- Shipping3 at `Saved/CachePackage/cache-v76-schema4-shipping3-Shipping/
  20260812_001618_177_815ba987` compiled and linked the corrected Runtime, then
  completed Cook/Stage/Archive and loose-layout validation. UAT duration was
  `78126 ms`, proving IC-495 and IC-496 GREEN in Shipping.
- Cold launch produced no Store/report and hit the bounded `300000 ms` per-launch
  timeout; the wrapper terminated only its exact PID tree and wrote a structured
  RED summary (`382062 ms`, phase count zero). Shipping compiles out the harness's
  old ExecCmds exit mechanism, as well as generic seconds/benchmark parsing.
- Helper TDD now requires `-as-cache-exit-after-startup` and rejects the old
  `-ExecCmds=as.Cache.Flush,quit`. Runtime requests graceful success exit only
  after successful InitialCompile, Cache RuntimeGameThread transition, reload
  priming and delegate broadcast; normal shutdown owns flush/report.
- Trustworthy C++ RED is `Saved/Build/
  cache-v76-package-smoke-exit-red-build2/
  20260812_002520_426_d90f5fe7`, which failed only on the missing config/policy
  API. GREEN build passed 106 actions at `Saved/Build/
  cache-v76-package-smoke-exit-green-build1/
  20260812_002602_677_6c47d37e`; the separate focused test passed `1/1/0/0` at
  `Saved/Tests/cache-v76-package-smoke-exit-green-test1/
  20260812_002743_135_5bf052ae`. Helper self-tests pass.
- Shipping3's archive predates the hook. A fresh Shipping package/matrix remains
  required.

### V7.6 Shipping4 and Development/Shipping multi-launch GREEN

- Fresh official command
  `Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Shipping -Label
  cache-v76-schema4-shipping4 -TimeoutMs 3600000` completed at
  `Saved/CachePackage/cache-v76-schema4-shipping4-Shipping/
  20260812_002908_845_b0d46d29`. `Summary.json` records status Passed, exit 0,
  seven phases and total duration `227499 ms`; build/cook/stage/archive and loose
  NonUFS source validation are included in that result.
- All seven real Shipping executable launches completed without timeout. Cold
  Baseline published source/Generation `d96bfaa8...41929` /
  `cad76a6b...1f7`; unchanged warm retained it and restored 19 functions. The
  one-body edit published `2b84b1fa...6e17c` / `be94901a...8ee`, restoring 18
  functions and compiling five misses.
- Invalid source exited with the specified status 3 in `2992 ms`, published no
  Current and retained the body-edit Generation. Restoring Baseline selected the
  retained body-edit Generation for hybrid reuse, restored 18 functions,
  compiled five misses and deterministically returned to the Baseline
  Generation.
- Structural cold published source/Generation `1e0c321d...b8981` /
  `cf83875f...1c163`; structural warm retained it and restored 19 functions.
  Every process report is schema 4 with phase `ShuttingDown`; Python dump
  integrity and C++ session correlation passed for every successful launch.
- The independent Development matrix remains GREEN at `Saved/CachePackage/
  cache-v76-schema4-development6-Development/
  20260812_000259_158_0c22d163` with the same seven-scenario contract, including
  a bounded status-3 invalid launch and last-good preservation. Development and
  Shipping therefore close V7.6 without inferring either configuration from
  Editor/commandlet tests.

### V7.7 bounded-parallel writer focused GREEN

- The production gap was first captured in IC-498: the old completion
  aggregator canonicalized caller-supplied ordinals but launched no tasks, while
  production always invoked serial `BuildAngelscriptCachePacks`.
- `AngelscriptCacheParallelPackPreparationTests.cpp` and
  `AngelscriptCacheWriterPolicyTests.cpp` are separate focused files. Official
  TDD reached a real implementation compile RED at `Saved/Build/
  cache-v77-parallel-pack-core-build1/
  20260812_004355_112_bfd800d0` (`TAtomic::FetchAdd` is unavailable), then passed
  the core build at `Saved/Build/cache-v77-parallel-pack-core-build2/
  20260812_004433_197_c965dfe4` and core tests `3/3` at `Saved/Tests/
  cache-v77-parallel-pack-core-test1/
  20260812_004447_364_004680e6`.
- The writer-policy API RED is `Saved/Build/
  cache-v77-writer-policy-red-build1/
  20260812_004622_516_20e4a382`. Final official build passed UHT plus 106 actions
  at `Saved/Build/cache-v77-writer-policy-green-build1/
  20260812_004755_958_6ebdd738`; the combined prefix passed `6/6/0/0` at
  `Saved/Tests/cache-v77-writer-parallel-green-test1/
  20260812_004931_819_965c666d`.
- Tests prove actual worker-thread compression, configured bounds, invalid-input
  output clearing, copied Service policy, default/override/clamp behavior,
  byte-identical serial/parallel Pack bytes/indexes/IDs and 5/2/1 Pack grouping
  for seventeen 1 MiB records under 4/16/64 MiB targets.

### V7.7 production Development and benchmark GREEN with explicit performance limitation

- A freshly built Development archive containing the bounded-parallel writer is
  `Saved/CachePackage/cache-v77-parallel-development1-Development/
  20260812_005543_023_59f48f29`. After IC-499 corrected the generated fixture
  from an unsupported mutable global to a supported const global, the exact
  archive rerun passed all `7/7` launches in `90098 ms`. Cold/warm/body/invalid/
  restored/structural source and Generation coordinates all satisfy the package
  oracle; invalid source exits 3 without pointer advancement.
- Package-smoke helper self-tests pass after adding type/module-state fixtures,
  diagnostics modes and extra writer arguments. The final current benchmark
  plan-only self-check produced exactly 56 rows under
  `Saved/CacheBenchmark/cache-v77-plan-final1`.
- The accepted real benchmark is `Saved/CacheBenchmark/cache-v77-real4` and its
  package-resident evidence root is recorded in `Result.json`. It returned 0
  after `61/61` package processes, `56/56` recorded rows, 14 warmups, 42
  measured rows and 14 complete groups. Every enabled report is schema 4; every
  Store passed Python integrity and optional session correlation.
- Independent post-run parity joined serial/parallel rows at each target and
  compared generation/source, module/type/function/global counts, canonical
  bytes, Pack count, stored bytes and Manifest bytes. All passed. Each tiny
  target produced the same Generation `10bcfebe...14f2d`, source
  `b802f784...7a59f`, one Pack and 32691 stored bytes.
- The figures are deliberately not a speedup claim. Cold median is `11093 ms`
  and unchanged warm is `14055 ms` (+26.7%) with 18 restored functions, four
  compiled misses and four typed NotCacheable functions. Parallel is 0.40% to
  1.45% slower than serial for the single tiny Pack. Summary/Verbose are 0.07%/
  0.22% above diagnostics Disabled at the three-run median. Raw, summary,
  context, plan, result and analysis are checked into this change's
  `benchmarks/cache-v77-real4-*` attachments; IC-503 and both guides require a
  representative larger corpus before any performance claim or policy retune.

### V7.7 strict Standalone LF fixture correction GREEN

- The preceding parallel-All attempt scheduled 37 shards and every UE
  Automation shard passed; Standalone alone failed `5/19` because Windows
  `core.autocrlf=true` rewrote strict frozen JSON/JSONL wire fixtures to CRLF.
  That result remains at `Saved/Tests/
  cache-v56-schema4-all-parallel1_20260811_230523`.
- A narrow plugin `.gitattributes` now forces LF only for the offline-contract
  JSON/JSONL fixtures. Byte inspection reports zero CRLF, and both symbols files
  remain 991 bytes with their manifest-declared SHA-256.
- Official `Tools\RunTestSuite.ps1 -Suite Standalone` is GREEN `19/19`, process/
  final `0/0`, at `Saved/StandaloneTests/
  cache-v77-standalone-lf-green1_01_Standalone/
  20260812_012428_389_852180ab`. All five previously failing CTests now pass.

### V7.7 fresh post-writer-policy Shipping matrix GREEN

- Official command `Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration
  Shipping -Label cache-v77-parallel-shipping1 -TimeoutMs 3600000` rebuilt 41
  Shipping actions and completed Cook/Stage/Archive plus loose-layout
  validation at `Saved/CachePackage/cache-v77-parallel-shipping1-Shipping/
  20260812_012557_854_9584ba9c`.
- `Summary.json` records Passed, exit 0, `7/7` phases and `226078 ms`. Cold and
  unchanged warm retain source/Generation `52e56a1b...af0de` /
  `1a067aca...d8061`; body edit publishes `622c68f4...efc8c` /
  `c3e47218...6d3516`. Invalid source exits 3 in `3141 ms`, times out false and
  retains the body generation. Restored baseline returns to the exact original
  Generation. Structural cold/warm retain `9139e552...24661` /
  `dbb0ff56...6e30d`.
- Every successful launch wrote and correlated schema-4 report/dump evidence.
  This revalidates the normal bounded-parallel writer and current settings in a
  genuinely rebuilt Shipping binary rather than inheriting V7.6 evidence.

### V7.7 final complete Cache regression GREEN

- Official command `Tools\RunTests.ps1 -TestPrefix
  Angelscript.TestModule.Cache -Label cache-v77-final-complete-cache1
  -ExecutionSlot 1 -TimeoutMs 3600000` completed with wrapper exit `0` at
  `Saved/Tests/cache-v77-final-complete-cache1/
  20260812_012618_824_19ba7032`.
- `Summary.json` records `536/536` passed, failed/skipped `0/0`. This is the
  current complete Cache prefix after the bounded-parallel writer, writer-policy
  settings, package/benchmark helper and LF fixture corrections. Final closure
  still requires the independent official four-slot parallel `All` result.

### V7.7 first final-All attempt and Debugger parallel-port correction

- `cache-v77-final-all-parallel1` scheduled all 37 tasks with CoarseDynamic four-
  slot execution. It completed in `1089506 ms`: Standalone passed `19/19`, Cache
  passed `536/536`, and 35 of 36 UE shards were green. Aggregate result was
  `2969/2970`, with the sole failure in Debugger `BreakFiltersRoundtrip` after an
  occupied test port was falsely reported as listening. The immutable evidence
  is `Saved/Tests/cache-v77-final-all-parallel1_20260812_014126/
  ParallelSuiteSummary.json`.
- IC-504 records the TDD and correction. Final build passed at `Saved/Build/
  cache-v77-debugger-port-final-build1/20260812_020443_761_ba77f60e`;
  occupied-port regression passed `1/1` at `Saved/Tests/
  cache-v77-debugger-port-final-focused1/20260812_020501_182_e7d7928f`, and the
  complete Debugger prefix passed `39/39` at `Saved/Tests/
  cache-v77-debugger-port-complete-green1/20260812_020539_162_80ecede7`.
- Final closure still requires a fresh four-slot parallel `All` on the corrected
  binaries; the failed aggregate is retained as discovery evidence, not counted
  as acceptance.

### V7.7 second final-All attempt and shared AssetRegistry writer correction

- `cache-v77-final-all-parallel2` exercised the IC-504 retry under real pressure:
  Debugger logged two failed listener candidates, recovered, and passed `39/39`.
  Cache passed `536/536` and Standalone `19/19`. The 37-task aggregate completed
  in `963532 ms` with `2970/2971`; the sole Compiler failure was an unrelated UE
  `LogFileManager` error moving the shared `Intermediate/CachedAssetRegistry/
  CachedAssetRegistry_0.ref.tmp`, not an AS compile assertion. Evidence is
  `Saved/Tests/cache-v77-final-all-parallel2_20260812_020813/
  ParallelSuiteSummary.json` and IC-505.
- The parallel runner now passes UE's supported `-NoAssetRegistryCacheWrite` to
  every UnrealAutomation shard, retaining cache reads while removing the shared
  writer. Its new dry-run assertion first failed and then all three runner self-
  tests passed. Complete Compiler with the exact flag passed `81/81` at
  `Saved/Tests/cache-v77-asset-registry-compiler-green1/
  20260812_022610_572_0c09cec9`.
- This remains correction evidence rather than final acceptance; only a fresh
  parallel aggregate can prove the multi-process race is absent.

### V7.7 authoritative four-slot parallel All GREEN

- Official command `Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy
  CoarseDynamic -TestModuleWorkers 4 -MaxParallelLight 4 -MaxParallelHeavy 4
  -LabelPrefix cache-v77-final-all-parallel3 -TimeoutMs 3600000
  -ContinueOnFail` completed successfully at `Saved/Tests/
  cache-v77-final-all-parallel3_20260812_022730`.
- `ParallelSuiteSummary.json` records all `37/37` tasks, failed shards `0`,
  `2971/2971` tests passed and duration `943955 ms`. The same aggregate includes
  Cache `536/536`, Debugger `39/39`, Compiler `81/81`, HotReload `122/122`,
  StaticJIT `30/30`, AngelScriptSDK `691/691` and Standalone `19/19`.
- Process command lines confirm every UnrealAutomation shard received
  `-NoAssetRegistryCacheWrite`; aggregate log inspection found zero shared
  `CachedAssetRegistry` move errors. IC-504 listener readiness/retry and IC-505
  parallel AssetRegistry read-only policy are therefore closed under the actual
  four-process pressure that discovered them.
- Parent and plugin `git diff --check` both returned `0`. Only the existing local
  `core.autocrlf` conversion warnings were printed; there are no whitespace
  errors. V7.7 and the full OpenSpec task ledger are `54/54` complete. The
  benchmark limitation remains binding: this acceptance proves correctness,
  integrity and regression safety, not a measured startup speedup.

### OpenSpec closure and archive

- `openspec status --change refactor-as-incremental-function-cache` reported all
  `4/4` artifacts complete and `openspec validate
  refactor-as-incremental-function-cache --strict` passed before archival.
- `openspec archive refactor-as-incremental-function-cache --yes` synchronized
  48 deltas (`+48`, `~1`, `-1`) into `as-cooked-packaging-runtime`, the new
  `as-incremental-script-cache`, and the new `as-script-artifact-identity`, then
  archived this change as `2026-08-11-refactor-as-incremental-function-cache`.
- Each of those three resulting main specifications passes independent strict
  validation. Repository-wide strict validation reports `127` valid items and
  one unrelated pre-existing invalid change,
  `docs-as-mutable-global-feasibility`; this closure does not modify or claim
  that sibling change. No process is listening on the temporary Zen port 8558.

### Post-archive merged-main integration verification GREEN

- Parent `main` merge `1af9064` and plugin `main` merge/follow-up `c52af6c` /
  `02d05ab` build successfully through the official wrapper at `Saved/Build/
  build/20260812_031610_789_a9fb19ad`.
- The first official merged-main four-slot run used `Tools\RunTestSuiteParallel.ps1
  -Suite All -Strategy CoarseDynamic -TestModuleWorkers 4 -MaxParallelLight 4
  -MaxParallelHeavy 4 -LabelPrefix cache-v2-merged-main-all -TimeoutMs 3600000
  -ContinueOnFail`. It completed all 37 shards at `Saved/Tests/
  cache-v2-merged-main-all_20260812_031708/ParallelSuiteSummary.json` with
  `3047/3058`; Cache itself remained GREEN `536/536`. The eleven failures are
  retained as integration RED and classified in IC-507 through IC-509 rather
  than being hidden by the historical feature-branch `2971/2971` result.
- The unified repair build passed `116/116` actions at `Saved/Build/
  cache-v2-merged-main-repair-build1/20260812_034354_530_7f55048e`.
  Focused complete prefixes passed Engine `130/130`, Bindings `281/281` and Dump
  `13/13`. Exact corrections passed FunctionLibraries `1/1`, Functional `1/1`
  with permanent result-code log `1`, GAS `1/1` and GameplayTags `1/1`; their
  immutable paths are recorded in IC-507/IC-508.
- The final compiled fixture correction passed the official build at
  `Saved/Build/cache-v2-merged-main-repair-build3/
  20260812_035852_178_05cdb786` with four actions and wrapper/process exit `0`.
- Dedicated `Tools\RunStaticJITTests.ps1 -LabelPrefix
  cache-v2-repair-staticjit` passed its baseline build, generation commandlet,
  generated build and complete StaticJIT prefix. The test result is `32/32` at
  `Saved/Tests/cache-v2-repair-staticjit_04_tests/
  20260812_040043_325_26d3a9dc`; IC-509 records every stage root.
- The authoritative merged-main acceptance command was
  `Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy CoarseDynamic
  -TestModuleWorkers 4 -MaxParallelLight 4 -MaxParallelHeavy 4 -LabelPrefix
  cache-v2-merged-main-all-final -TimeoutMs 3600000 -ContinueOnFail`. It passed
  all `37/37` shards, failed shards `0`, and `3090/3090` tests in `1094880 ms` at
  `Saved/Tests/cache-v2-merged-main-all-final_20260812_040301/
  ParallelSuiteSummary.json`.
- The final aggregate includes Cache `536/536`, StaticJIT `32/32`, Standalone
  `19/19`, AngelScriptSDK `691/691`, GAS `252/252`, GameplayTags `15/15`, Engine
  `130/130`, Functional `128/128`, FunctionLibraries `56/56`, Bindings
  `281/281`, HotReload `122/122`, Debugger `39/39`, Compiler `81/81` and zero
  failures in every remaining shard. Every UE command uses
  `-NoAssetRegistryCacheWrite`. This result supersedes the merged-main RED while
  retaining that RED as the integration discovery record.
- The exact tested follow-up revisions are Angelscript plugin `974e281`, GAS
  `095f407` and GameplayTags `6485ca3`. The parent follow-up commit advances all
  three gitlinks together with IC-507 through IC-510 and this verification
  record; no remote push is part of this local integration.
