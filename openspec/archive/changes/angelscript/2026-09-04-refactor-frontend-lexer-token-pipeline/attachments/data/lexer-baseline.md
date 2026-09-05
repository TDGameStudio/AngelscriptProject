# Frontend lexer baseline

## Scope and provenance

- Corpus: checked-in `MakeRepresentativeLexerCorpus()` in `LexerTests.cpp`, version marker `v1`.
- Corpus construction: 256 repetitions of an ordinary ASCII AngelScript namespace/class/function fragment containing reflection spelling, identifiers, keywords, punctuation, numeric literals, control flow, and whitespace.
- Source bytes: 34,304 immutable UTF-8 bytes.
- Non-EOF tokens per pass: 9,728.
- Harness build: `d5d303db4568426395d702726bab78d1` (`frontend-lexer-measurement-build`).
- Harness test: `bc2097f7758d456eb34c5835016b5d9f` (`frontend-lexer-measurement`, Fast).
- Report: `Saved/Harness/Unreal/Runs/bc2097f7758d456eb34c5835016b5d9f/AutomationReport/index.json`.
- Result: 12/12 passed, zero warnings, errors, skips, or timeouts.
- Environment: Unreal Engine 5.8 installed build, `AngelscriptProjectEditor` Win64 Development, Windows 11 Pro 10.0.26200, Intel Core Ultra 9 285K (24 cores / 24 logical processors).

## Measurement definition

The cold pass starts with an empty session-local `asCIdentifierTable`. The warm pass reconstructs the source manager, diagnostics engine, and tokenizer over the same immutable snapshot while reusing the populated identifier table. Both passes call only the pull `Lex(Token&)` path and retain no token array or spelling projection.

The correctness gate is allocation-structural rather than temporal: the cold pass must allocate fewer unique identifier entries than produced tokens, the warm pass must allocate zero additional identifier entries, and both passes must terminate with the same nonzero token count. Process memory and elapsed time are observations only.

## Observed values

| Metric | Cold | Warm |
|---|---:|---:|
| Elapsed | 3,707.901 us | 3,740.598 us |
| Throughput | 8.823 MiB/s | 8.746 MiB/s |
| Token rate | 2.624 million tokens/s | 2.601 million tokens/s |
| New identifier-entry allocations | 12 | 0 |
| Unique identifiers after pass | 12 | 12 |
| Owned identifier spelling bytes after pass | 62 | 62 |
| Used physical before | 3,092,598,784 bytes | 3,092,598,784 bytes |
| Used physical after | 3,092,598,784 bytes | 3,092,598,784 bytes |
| Process peak used physical observed after pass | 3,250,397,184 bytes | 3,250,397,184 bytes |

Raw log marker:

```text
AS_FRONTEND_LEXER_BASELINE corpus=v1 bytes=34304 tokens=9728 cold_new_identifier_allocations=12 warm_new_identifier_allocations=0 unique_identifiers=12 owned_spelling_bytes=62 cold_used_physical_before=3092598784 cold_used_physical_after=3092598784 cold_peak_used_physical=3250397184 warm_used_physical_before=3092598784 warm_used_physical_after=3092598784 warm_peak_used_physical=3250397184 cold_elapsed_us=3707.901 warm_elapsed_us=3740.598
```

## Interpretation boundaries

- Zero warm identifier allocations proves repeated common identifiers do not allocate per token in the session-owned table; it does not claim the surrounding UE process performs no allocations.
- The physical-memory samples are process-wide and the peak is cumulative since process start, so they provide context rather than tokenizer-exclusive attribution.
- One machine and one UE process cannot establish a portable performance threshold. The recorded elapsed time and derived throughput are comparison evidence only and MUST NOT fail future correctness runs.
