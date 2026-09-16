# Preserve full context around limited observations

Disposition: candidate.

## Reusable Insight

An int32 return may encode a type marker, direction or trace, rather than the complete language value. Host ABI and lifecycle observations can require context beyond one emitted function.

## Evidence

NumericBinary retains type markers for 64-bit/floating operations. ConvAbi has 101/202/1 script observations plus independent native ExpectedBits. PropRebuild emits second-version variants.

## Boundaries

Keep these boundaries in product documentation and acceptance evidence. Do not silently widen the accepted public result type or replace host semantics with script counters.

## Application

Apply when authoring and verifying each product and the final catalog completeness test. This attachment is guidance; current requirements and tasks own acceptance.

## Sources

[Design](../drafts/design.md), [source check](../drafts/findings/design-check.md), and the product catalogs indexed in the attachment index.
