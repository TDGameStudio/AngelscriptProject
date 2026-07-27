# Engine Assertion-Depth Repair Review

## Scope

This review independently re-evaluates the eleven Engine products marked
`ChangeRequired` by the pre-repair 36-product review. It compares each current
owner against its current catalog evidence after implementation, rather than
promoting products merely because the Engine prefix is green.

The exact row evidence is stored in
`assertion-depth-engine-repair-review.csv`.

## Result

- 11/11 prior `ChangeRequired` products are now `Complete`.
- 23 products that were already `Complete` remain unchanged.
- Two products remain terminal, prerequisite-backed `Deferred`:
  - `ENG-OBJECT-SERVICE-DELEGATE-LIFECYCLE`;
  - `ENG-OBJECT-SERVICE-REFCAST-CONTRACT`.
- Engine's final assertion-depth disposition is therefore 34 `Complete`,
  0 `ChangeRequired`, and 2 `Deferred`.

The two evidence corrections are deliberate:

- `ENG-ATOMIC-OPERATIONS` no longer claims cleanup for a value-only atomic
  owner with no cleanup surface;
- `ENG-REGISTRATION-DEFAULT-ARRAY-TYPE` no longer claims cleanup while the
  current fork leaks a prior internal reference on repeated successful
  registration;
- `ENG-APP-EXCEPTION-TRANSLATE-REJECT` no longer claims isolation because
  `AS_NO_EXCEPTIONS` compiles out the callback state and exposes no public
  retention query.

These corrections narrow unsupported evidence labels without removing any
behavior cell. The other eight products gained the missing observable oracle.

## Runtime evidence

- Initial coherent build:
  `Saved/Build/as-native-sdk-engine-assertion-depth-batch/20260727_105656_084_9bf0aef8/RunMetadata.json`
  — PASS.
- Initial Engine run:
  `Saved/Tests/as-native-sdk-engine-assertion-depth-batch/20260727_105755_558_953b0cb9/`
  — 39/40, with the single module-inventory assertion exposing the current
  fork's discarded-module retention.
- Corrected discard-contract build and run:
  `Saved/Build/as-native-sdk-engine-discard-contract-fix/20260727_110042_094_efb2964f/RunMetadata.json`
  and
  `Saved/Tests/as-native-sdk-engine-discard-contract-fix/20260727_110155_385_015c7f20/`
  — build PASS and 40/40 PASS.
- Final complete Engine build and run:
  `Saved/Build/as-native-sdk-engine-assertion-depth-final/20260727_110729_584_ba0ce727/RunMetadata.json`
  and
  `Saved/Tests/as-native-sdk-engine-assertion-depth-final/20260727_110821_901_8768de0c/`
  — build PASS; 40/40 PASS; zero failed/skipped; process and wrapper exit 0;
  `TimedOut=false`; normal shutdown; no crash marker.

The final Engine log retains complete source printing for source-owning cases.
The preceding corrected run contains 428 source-begin records and 214 unique
printed IDs; the final report proves all eleven repaired owners are present in
the accepted binary.
