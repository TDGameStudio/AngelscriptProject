# Generated source byte and origin projection

## Reusable Insight

When a generator emits readable source through a normalizing C++ literal helper, annotation coordinates are correct only if the generator proves exact equality between its clean bytes and the helper's runtime bytes. Authored-origin compression also needs a separate clean-EOF anchor; positive-length spans alone cannot represent a terminal removed marker.

## Evidence

`AS_TEST_SOURCE` removes an opening envelope, common indentation and a closing delimiter margin. Python annotations are calculated in clean UTF-8 byte coordinates, so any different normalization shifts every later Point, Breakpoint and Range.

The current C++ origin map stores one original offset for every clean byte and a final entry for `CleanOffset == Num()`. Contiguous spans map actual bytes efficiently:

```text
OriginalOffset = AuthoredBegin + (CleanOffset - CleanBegin)
```

However, if a marker at authored EOF is removed, the final clean offset maps after the marker and cannot be inferred from the last visible-byte span. `AuthoredEnd` preserves that mapping.

```text
Generated origin projection
├─ FOriginSpan[]  // all clean bytes, split only at discontinuities
└─ AuthoredEnd    // clean Num() mapping
```

## Boundaries

- Coordinates are bytes in normalized clean UTF-8 Source, while authored offsets refer to the unmodified authored-file bytes.
- CRLF/CR normalization, BOM removal and marker deletion create discontinuities.
- Ranges are half-open and may end at clean `Num()`.
- This model does not convert to LSP UTF-16 positions; a consumer adapter performs protocol-specific conversion later.
- Special exact-byte inputs may bypass normalized readable literals, but that is not the generated default.

## Application

- Render a canonical literal envelope and prove `PythonCleanBytes == AS_TEST_SOURCE(...).GetBytes()` with a Python golden and a compiled C++ fixture.
- Emit contiguous spans, not a generated per-byte integer array.
- Validate span order, positive lengths, gap/overlap absence, authored bounds and the independent end anchor before publishing Source.
- The runtime may initially expand spans plus `AuthoredEnd` into its existing array and later store spans natively without changing the generated contract.

## Sources

- [Counter before and after](../drafts/findings/generated-before-after-counter-example.md)
- [Build-time parser evidence](../drafts/findings/generated-build-time-parser.md)
- [Accepted design](../drafts/design.md)
- Local source evidence: `FAngelscriptTestAnnotations::Parse` appends the clean-end original offset after marker removal.
