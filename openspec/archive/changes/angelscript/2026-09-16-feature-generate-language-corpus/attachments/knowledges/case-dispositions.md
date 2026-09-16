# Classify a generated cell before choosing an oracle

Disposition: candidate.

## Reusable Insight

Normal returns, compile rejects and runtime faults are different outcomes. The whole catalog counts all three; BuildAllSource only counts non-reject entries. Reject-only products are valid generator products.

## Evidence

TransferValidity has 3 normal and 5 reject cells. RegisteredFuncdef has 0 normal and 6 reject cells. Q101 lists five accepted engine fault messages.

## Boundaries

Generator tests check source/disposition contracts. Future runtime consumers must assert diagnostic or exception outcomes; a zero fallback from GetExpected cannot establish normal success.

## Application

Apply when authoring and verifying each product and the final catalog completeness test. This attachment is guidance; current requirements and tasks own acceptance.

## Sources

[Design](../drafts/design.md), [source check](../drafts/findings/design-check.md), and the product catalogs indexed in the attachment index.
