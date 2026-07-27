# TypeSystem and Embedding Assertion-Depth Repair Review

## Scope and method

This is the independent post-implementation review for all eighteen
TypeSystem/Embedding products marked `ChangeRequired` in the original
assertion-depth review. Each row was checked against its current owner,
product-part owners, current catalog evidence, explicit postconditions, and
the accepted parent-prefix execution evidence.

The row-level conclusions are in
`assertion-depth-typesystem-embedding-repair-review.csv`.

## Result

- TypeSystem: all 9 prior gaps are Complete. Together with the 8 original
  Complete products, the domain is now 17 Complete, 0 ChangeRequired, and
  0 Deferred.
- Embedding: all 9 prior gaps are Complete. The domain is now 9 Complete,
  0 ChangeRequired, and 0 Deferred.
- Combined: 18/18 repaired products are Complete.

Evidence was narrowed where the public/raw owner cannot expose the originally
claimed behavior:

- `TYPE-DATATYPE-HANDLE-CONTRACT` is metadata-only; object ownership belongs to
  dedicated release products.
- `TYPE-ENGINE-PRIMITIVE-TYPEID-ROUNDTRIP` no longer claims cleanup for
  primitive descriptors without an owner.
- `EMBED-GENERIC-OBJECT-RETURN` no longer claims lifecycle counters that the
  generic interface cannot observe.
- `EMBED-NATIVE-CALL-ABI-SHAPES` no longer claims lifecycle; its nine shapes
  retain compile/runtime/metadata/cleanup/isolation evidence.

No generated case or runtime behavior was removed by these corrections.

## Accepted runtime evidence

- TypeSystem:
  `Saved/Tests/as-native-sdk-assertion-depth-typesystem-final/20260727_102513_413_f8f7511a/`
  — 45/45 PASS, normal shutdown, no crash.
- Embedding:
  `Saved/Tests/as-native-sdk-embedding-depth-final/20260727_103735_501_e5ed6d1d/`
  — 27/27 PASS, zero failed/skipped, process/wrapper exit 0,
  `TimedOut=false`, normal shutdown, no crash.
- The shared coherent assertion-depth builds are listed in `verification.md`;
  every source-owning generated case remains printed.

The enum cleanup row remains Complete as an enabled negative lifecycle
contract: exact stored sentinel identities are proven and the confirmed
zero-callback fork defect remains open as `AS-FORK-DEFECT-001`.
