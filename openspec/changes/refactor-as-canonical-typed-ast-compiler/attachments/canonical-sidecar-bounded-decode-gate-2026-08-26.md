# Gate card: sidecar bounded decode + exact profile（2026-08-26）

- **OpenSpec task(s):** `6.1`, `6.2`, `13.11` (thirteenth-pass F2/F8 hardening; do not treat historical 6.1/6.2 checkboxes as production-complete from this card)
- **Source fixture:** independently sealed empty translation-unit DTO plus adversarial `CAST` payloads with `UINT_MAX` / `UINT_MAX-1` owner lengths, truncated owner bytes, nested `UINT_MAX` source count, and nested `UINT_MAX` string length. Encoded profile `Win64`.
- **Canonical fact:** `ReadBytes`/`ReadU32`/`ReadU64` use subtraction remaining checks (`offset <= length && n <= length - offset`); full `asCASTDecodeSidecar` rejects empty expected profile as `PROFILE_MISMATCH`; only `asCASTReadSidecarHeader` inspects without expected identity; Runtime encode/decode wrappers use the same exact-profile contract and do not treat `Sidecar.Profile == ""` as a wildcard.
- **AST test:** `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheASTBodySidecarTests.cpp`
  - `AdversarialSidecarLengthFieldsFailClosedWithoutHugeAlloc`
  - `FullDecodeRejectsEmptyExpectedProfileWhenPayloadProfileIsPresent`
  - `RuntimeWrapperRejectsInvalidPayloadAndPreservesVerifiedCurrentDto`
- **AST-red:** `Saved/Tests/cta-f2-sidecar/20260826_214426_806_e069f8f5` — 16 total, 15 PASS, 1 FAIL `RuntimeWrapperRejectsInvalidPayloadAndPreservesVerifiedCurrentDto` (`verified current-schema sidecar encodes`) after F8 required a non-empty expected profile. Encode wrapper decoded with empty `Sidecar.Profile`.
- **AST-green:** `D:\as-cta\Saved\Tests\cta-f2-sidecar-green\20260826_215413_765_ae455867` **16/16 PASS**. Runtime wrapper now requires exact `Win64` profile; empty `Sidecar.Profile` / empty expected profile return `ProfileMismatch`; adversarial `UINT_MAX` owner/nested count/string lengths fail closed without publishing a graph. Scratch copy: `{SCRATCH}/wave-s/cta-f2-sidecar-green-Summary.json`.
- **CodeGen/provenance:** N/A — Cache DTO admission, no executable lowering.
- **Lifecycle:** Cache V2 remains default-disabled. Production ExactStartup already passed a non-empty profile; this card closes the public full-decode API and Runtime wrapper so new consumers cannot skip that guard.
- **Focused regression:** same ASTBodySidecar prefix.
- **Remaining boundary:** unique bounded cursor/reader across every DTO field is still a follow-up hardening (F2 architectural preference). Matching Generate Provider (F1/F5), catalog (F6), module generation transaction (F4/F3), and raw getter (F7) are not this card. S1 `__CreateLiteralAsset` ranking is not this card.
