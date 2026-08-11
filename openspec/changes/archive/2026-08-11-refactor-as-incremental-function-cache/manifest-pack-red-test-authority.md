# Task 2.7 Manifest/Pack RED Test Authority

Date: 2026-08-08

Status: repaired declaration-first RED candidate; fresh independent rereview is
pending. This attachment records the intended evidence in
`Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheManifestPackTests.cpp`.
It does not claim a Runtime implementation, a GREEN build, or Automation pass.
`manifest-pack-wire-v1.md` remains normative whenever this test record is
incomplete or ambiguous.

## Test boundary

- The suite is pure C++ and constructs no `FAngelscriptEngine`, UObject, World,
  filesystem root, file handle, store pointer, or publication slot.
- The first include is intentionally
  `Cache/AngelscriptCacheManifestPack.h`. That production declaration is absent
  at this RED gate; no substitute header or test-owned production DTO exists.
- Pack reads publish only `FAngelscriptDecodedCacheRecordHandle` through the sole
  common decoded-record factory boundary. The test contains no semantic decoder.
- The injected storage-codec stub only reports one-short/one-over produced byte
  counts through the production codec interface. It cannot publish a semantic
  record, allocate beyond the caller-owned RawSize view, or bypass the common
  factory.
- `BytesFromHex`, fixed-offset unsigned-LE readers/writers, and the bounded
  MaxGenerationPacks fixture writer are test-data construction/minimal scanning
  only. They never accept a production value as an expected decode oracle.
- The guarded `ValidateAngelscriptCacheGenerationReachabilityForTests` shape is a
  projection into the same production reachability validator. It receives the
  SourceIndex-root offset explicitly and may expose caller-owned fixed nodes,
  exact manifest byte offsets, canonical visited IDs, and a fixed-capacity
  per-root graph-call probe under
  `WITH_ANGELSCRIPT_UNITTESTS`, but it must not implement a second traversal,
  decode payloads, bypass validation, publish a record, or exist in Shipping.

## Frozen independent byte vectors

The full byte arrays are literals in the test source. Their hashes were derived
independently from the normative streams using BLAKE3-256 and standard canonical
zlib level-9/window-15 bytes, not by asking the future manifest/pack encoder for
an expected result.

| Vector | Bytes | Frozen physical ID |
| --- | ---: | --- |
| empty-payload None pack | 128 | `cab3a361e1034a5790e3f2d7cfa6b50803f4c7e026a83b95a657e777f48d4e8e` |
| zero-module minimum manifest | 307 | `e4536599616fa82b552de4283e858da39c31d245ac33b829f0b3b9d175269fc4` |
| mixed None/Zlib two-record pack | 236 | `3def100ec98858d1a8601261f5363445c5c5b8905b7659cbcfce8c2570f5c98e` |
| one-record Zlib function pack | 140 | `fe843139ae082b72468153bc5bd5837c4a891978c9e4a234a9f94518983f121b` |
| two-module/two-pack manifest | 803 | `fb429c7cf8288d81489069702c9251c469b3cdd5085ec20cfc4eed23351437cd` |

Additional frozen coordinates:

- empty direct RawChecksum:
  `af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262`;
- 64 ASCII `A` direct RawChecksum:
  `e028424e46205e56b2ed1ce1bf7087054072e6c4e41f843bed1e749db635792c`;
- the same payload's FunctionBody semantic RecordId content hash:
  `1fdf4b6b71329edf74ab7b78039c44e418033b324ddfddcbc3e47142a3e63280`;
- canonical zlib bytes for that payload: `78da7374a40c0000107e1041`;
- ForceNone versus Auto-Zlib function PackIds:
  `31eb4dd4802a35f8742c46f45dc781f091037841f982b9225d1d8cc0d8a22390`
  versus
  `fe843139ae082b72468153bc5bd5837c4a891978c9e4a234a9f94518983f121b`;
- manifests selecting those two physical representations have GenerationIds
  `d05690f3b10dd3f862f1181a8c47f9fa5e22533fd2526f3dff1056d142b252f7`
  and
  `0d65eec00e6a474f1ad17eb26ae4cbb3c243d0be2027c3aa63bc060c41aa799a`.

PackId and GenerationId are asserted against the complete final file and are
also asserted absent from their own serialized bytes.

## Mechanical coverage map

| Contract group | RED evidence |
| --- | --- |
| Pure boundary | exact function-pointer signatures for pack build, completion-ordinal aggregation, physical pack validation, sole-handle record read, manifest encode, generation validate and guarded same-validator reachability projection; abstract produced-byte-reporting codec/pack source; one noncopyable cumulative Budget |
| Magic/schema/wire sizes | `UEASCV2P`/`UEASCV2M`, schema 1, 33/65/122 and 32/96, exact header/index/data offsets, exact EOF |
| Stages/errors/classes | stages 7/8/9, errors 65..71, static seven-row exhaustive classification with `OverlappingRange` as ArithmeticOrBudget and the other six as CodecOrIntegrity |
| Physical identities | semantic RecordId domain stream, direct raw payload BLAKE3, whole-file PackId/GenerationId, no self-stored IDs, location-to-index equality |
| Compression | None is valid, Auto chooses canonical Zlib only for smaller bytes, fixed `78da...` stream, trailing input rejection, successful under/over produced-size rejection, None/Zlib invalid size relations, exact/one-short MaxCanonical, and None/Zlib equal semantic ID but distinct physical IDs |
| Pack malformed | magic/schema/header/index size/count/reserved/codec, size limits, first/later gap, backwards overlap, index/EOF range, checked overflow, trailing data, empty half-open ranges, order, duplicate, PackId, every PackId/offset/stored/raw/codec/checksum location equality dimension, checksum and RecordId |
| Manifest malformed | magic/schema/flags/nonzero Compatibility/Context/Profile/SourceSnapshot/ModuleKey/RecordId/PackId, Profile derivation, SourceIndex and ModuleSnapshot root kinds, missing SourceIndex/root index occurrences, count feasibility, codec/EOF/GenerationId, root and record order, duplicate versus conflict, manifest/module/record limits |
| Reachability | zero-module success, pack historical extra accepted, manifest extra rejected, TypeSchema traversal, independent manifest/decoded SourceSnapshot, canonical visited==manifest, exactly one graph validation per keyed root, keyed root ownership, and all seven missing/wrong-kind/unreachable target kinds including DebugSidecar |
| Generation pack cap | exactly 4,097 distinct PackIds with default limit 4,096; writer emits no partial output and reader returns ManifestDecode/BudgetExceeded with pack-source lookup/open count exactly zero |
| Cumulative budgets | stored, decompressed, decoded, references/relocations and raw-buffer/candidate live ownership share one Budget; five exact/one-short counters plus preexisting-retained + temporary combined-live exact/one-short and zero temporary leakage |
| Determinism | forced-serial plus bounded forward/reverse/seeded completion permutations traverse the same production aggregation seam and produce byte-identical pack groups/indexes/bytes/PackIds, manifest bytes and GenerationIds |
| Publication atomicity | failed pack build, physical pack validation, record read, manifest encode, generation read and reachability clear caller-owned outputs; record/generation failure begins with a successful owned output, clears it on header failure, preserves Budget, and performs no new pack lookup/open; successful repeated reads perform one lookup/open per attempt |

## First review disposition and repaired exact freeze

The first independently reviewed source was SHA-256
`C87419AC3C11CCCB500E3010AE091FFD4EF1B25D905E108377F1DCC50EBB009`
(104,075 bytes / 2,264 LF / 24 methods / final LF). Its disposition was
**3 Critical / 4 Important / 0 Minor** and is not approval. IC-128 through
IC-134 record that review.

The repaired author candidate is frozen for fresh independent rereview as:

- test source SHA-256
  `E763DD3285BD257CBBC7F9E08EE9B3C33893F8C3FFC732DBACF984FD680EB92E`
  (129,043 bytes / 2,833 LF / 26 methods / final LF);
- normative wire SHA-256
  `E36722A99A05D2AE2C4452F01016E6FD6243A8EDCAD34C232A36F182C37E1779`
  (35,208 bytes / 814 LF / final LF).

Author-side mapping reports the seven review items repaired, but this is not an
independent `0C/0I` disposition, a complete-TU compile, a GREEN implementation,
or an Automation pass. Exact-SHA approval does not transfer from the rejected
candidate.

Repository-wrapper evidence for this exact source is
`Saved/Build/cache-manifest-pack-repaired-red-tu/20260808_234148_544_45e29957/`.
It ran one `[1/1] Compile` action with `-SingleFile=<absolute source>` and
`-NoHotReloadFromIDE`; ProcessExitCode was `6`, wrapper FinalExitCode was `1`,
and the log contains exactly one compiler error/fatal diagnostic: missing
`Cache/AngelscriptCacheManifestPack.h` at source `(1,1)`. No later C++
diagnostic is visible behind the intentional header frontier.

## RED acceptance rule

The required focused command is the repository wrapper with
`-SingleFile=<absolute AngelscriptCacheManifestPackTests.cpp>` and
`-NoHotReloadFromIDE`. At this gate the first and only fatal diagnostic must be
the missing production header on source line 1. Any earlier path/configuration
failure or any later C++ diagnostic is not this declaration RED proof.

This record is an author-side self-check only and is not independent approval.
