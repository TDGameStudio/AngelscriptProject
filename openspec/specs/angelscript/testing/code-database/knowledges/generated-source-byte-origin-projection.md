# Generated source byte and origin projection

When a generator emits readable source through a normalizing C++ literal helper, annotation coordinates are correct only if the generator proves exact equality between its clean bytes and the helper's runtime bytes. Authored-origin compression also needs a separate clean-EOF anchor; positive-length spans alone cannot represent a terminal removed marker.

`AS_TEST_SOURCE` removes an opening envelope, common indentation and a closing delimiter margin. Annotation coordinates are clean UTF-8 bytes, so any different normalization shifts every later Point, Breakpoint and Range.

Contiguous spans map actual bytes:

```text
OriginalOffset = AuthoredBegin + (CleanOffset - CleanBegin)
```

If a marker at authored EOF is removed, the final clean offset maps after the marker and cannot be inferred from the last visible-byte span. `AuthoredEnd` preserves that mapping.

```text
Generated origin projection
├─ FOriginSpan[]  // all clean bytes, split only at discontinuities
└─ AuthoredEnd    // clean Num() mapping
```

- Coordinates are bytes in normalized clean UTF-8 Source; authored offsets refer to unmodified authored-file bytes.
- CRLF/CR normalization, BOM removal and marker deletion create discontinuities.
- Ranges are half-open and may end at clean `Num()`.
- This model does not convert to LSP UTF-16 positions.
- Special exact-byte inputs may bypass normalized readable literals, but that is not the generated default.
- Emit contiguous spans, not a generated per-byte integer array. Validate span order, positive lengths, gap/overlap absence, authored bounds and the independent end anchor before publishing Source.
