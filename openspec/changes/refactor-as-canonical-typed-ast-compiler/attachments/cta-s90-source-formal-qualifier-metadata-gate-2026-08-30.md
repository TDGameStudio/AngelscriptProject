# CTA-S90 source-formal qualifier metadata gate — 2026-08-30

## Outcome

CTA-S90 identified a non-invertible Runtime ABI projection and closed the
direct function/current-module, prepared Builder, direct import, and synthetic
constructor-factory production paths. A source by-value value object `T` and an explicitly
authored `const T&inout` both become the maintained Runtime shell ABI
`const T&inout`. Canonical Sema therefore cannot recover exact source identity
from `parameterTypes` plus `inOutFlags` alone.

The Runtime function shell now carries a generation-local, nonserialized
`canonicalASTSourceParameterQualifiers` vector. Each element is the exact
Canonical `asCQualType::quals` for one authored formal ordinal; hidden lambda or
factory captures are excluded. The stable declaration key and this vector are
one semantic identity and must be published only after the complete formal
relation validates.

## Implemented in this slice

- direct Canonical CodeGen captures exact source qualifiers while materializing
  the Runtime signature;
- `asCRuntimeTypeBridge::FromScriptFunctionParameterABI` consumes the producer
  metadata, authenticates it against either the direct Canonical ABI or the
  maintained normalized script ABI, and fails closed for keyed shells with
  missing/inconsistent metadata;
- prepared Builder publication now collects qualifiers through one central,
  transactional formal-order helper and publishes them atomically with the
  declaration key;
- Runtime destruction clears the generation-local vector;
- current-module Sema projection uses the function-aware bridge rather than the
  lossy ABI-only inverse.

## TDD evidence

The first attempted fixture used the public TypeId qualifier mask and was not a
valid semantic reproduction. It was corrected and is excluded from product
evidence:

- invalid fixture run:
  `Saved/Tests/cta-s90-source-formal-metadata-red/20260830_121436_028_f5c9e4c4`

The genuine current-module defect was then reproduced and repaired:

- valid RED build:
  `Saved/Build/cta-s90-source-formal-metadata-semantic-red-build/20260830_121526_935_e76c2547`
- valid RED test:
  `Saved/Tests/cta-s90-source-formal-metadata-semantic-red/20260830_121550_571_7566fc75`
  — exact qualifier result was `0x0`, expected `0x39`;
- GREEN build:
  `Saved/Build/cta-s90-source-formal-metadata-green-build/20260830_122404_101_dedc3187`;
- current-module GREEN:
  `Saved/Tests/cta-s90-source-formal-metadata-direct-green/20260830_124132_593_099ed234`
  — **1/1 PASS**.

The independently reachable prepared Builder path proved that key publication
did not yet publish qualifier identity:

- RED test build:
  `Saved/Build/cta-s90-prepared-builder-source-formal-red-build/20260830_124335_380_bddb24ee`;
- prepared Builder RED:
  `Saved/Tests/cta-s90-prepared-builder-source-formal-red/20260830_124503_960_aa9eda22`
  — **0/1**, exact missing producer metadata assertion;
- GREEN build:
  `Saved/Build/cta-s90-prepared-builder-source-formal-green-build/20260830_124704_848_4dc29dd3`
  — UBT succeeded;
- prepared Builder GREEN:
  `Saved/Tests/cta-s90-prepared-builder-source-formal-green/20260830_124903_248_e85af229`
  — **1/1 PASS**.

The direct import and synthetic constructor-factory copy routes were then
tested together. The first test-only edit passed an `std::string` directly to a
helper that requires `const char*`; that build did not reach the product
assertions and is excluded from semantic evidence:

- invalid fixture-only build:
  `Saved/Build/cta-s90-direct-import-factory-source-formal-red-build/20260830_125329_470_566689e5`.

After correcting only the fixture conversion, both production defects were
reproduced:

- valid semantic RED build:
  `Saved/Build/cta-s90-direct-import-factory-source-formal-semantic-red-build/20260830_125353_115_d13be0eb`;
- valid grouped RED:
  `Saved/Tests/cta-s90-direct-import-factory-source-formal-red/20260830_125408_822_1578b392`
  — **0/2**; the direct import had no exact Canonical declaration identity,
  and the factory did not copy the constructor's exact source qualifier
  vector;
- GREEN build:
  `Saved/Build/cta-s90-direct-import-factory-source-formal-green-build/20260830_125501_595_6e63b24a`
  — UBT succeeded;
- grouped GREEN:
  `Saved/Tests/cta-s90-direct-import-factory-source-formal-green/20260830_125515_121_b84c4b65`
  — **2/2 PASS**:
  `CanonicalSourceQualifierMetadataDirectImportPublishesExactFormalIdentity`
  and
  `CanonicalSourceQualifierMetadataConstructorFactoryCopiesExactFormalIdentity`.

The direct import now validates and publishes the stable declaration key plus
the complete qualifier vector as one payload. The synthetic constructor
factory copies that already-authenticated source qualifier vector together
with the constructor identity; neither change alters the normalized Runtime
calling ABI.

## CTA-S98 derived-funcdef closure

CTA-S98 closes the derived-funcdef producer/reuse/consumer bullets that were
open when this attachment was first written. `FindMatchingFuncdef` now requires
both Runtime signature equality and exact source-formal metadata compatibility,
copies the vector into newly derived funcdefs, and does not trust the fork's
historical shared `asCScriptFunction::funcdefType` field as a per-function
cache. Explicit lambda viability, omitted lambda inference and indirect
funcdef call planning use the function-aware Runtime bridge. A by-value value
object and explicit `const T&inout` adversarial fixture is **1/1 PASS** after a
valid **0/1 semantic RED**; complete SemaAuthority is **458/458 PASS** and the
complete native SDK Compiler prefix is **798/798 PASS**. Cache is **585/585**,
TypedASTJIT **56/56**, native SDK Module **65/65**, and the final Compiler
CanonicalAST + ProjectGeneration Engine + TypedASTJIT + NativeBridge matrix is
**780/780 PASS**. Full evidence and
non-claims are recorded in
`attachments/cta-s98-derived-funcdef-source-formal-relation-gate-2026-08-30.md`.

## Remaining producer/copy/restore matrix after CTA-S98

CTA-S90 is not family-complete. The following routes still require independent
RED/GREEN evidence or an explicit retained-boundary disposition before the
umbrella task can close:

- generated runtime identity/factory matching, with no metadata leakage from
  temporary candidate trials;
- template funcdef copies when a future source-owned donor becomes reachable;
  current host/native donors intentionally keep the vector empty;
- retained-AST Cache restore atomic key-plus-qualifier publication;
- no-retained-AST Cache V2 semantic records. AST Sidecar already serializes
  `asCQualType::quals`, but the no-AST record needs a dedicated source qualifier
  field, validation, hashing and diff participation;
- Canonical-only binder and reference-update comparisons. General Runtime ABI
  signature equality must remain unchanged;

Public CANONICAL `CompileFunction` attached and detached functions are not a
separate producer blocker: both route through `GenerateFunction` and the same
direct `FillFunctionSignature` producer already covered above. A public API
fixture remains useful regression coverage, but it is expected to be GREEN
rather than a new product RED.

Authored script `funcdef` remains rejected at the fork tokenizer boundary.
`asCBuilder::CompleteFuncDef` is therefore a retained internal/future path and
must not be used as a reason to re-enable source `funcdef` syntax in this
change. If that syntax is restored later, stable identity and source qualifier
publication must be closed before it becomes production-reachable.

Native/system functions, list factories and Runtime delegates without their
own Canonical source declaration must keep the vector empty. A delegate
consumer that needs source identity must inspect its authoritative
`funcForDelegate`; it must not synthesize qualifiers from the normalized shell.

## Progress effect

No `tasks.md` umbrella row is checked by CTA-S90 or CTA-S98 alone. The formal
OpenSpec count remains **102/136 = 75.0%**. After the later CTA-S91 through
CTA-S98 slices, architecture-weighted non-Standalone implementation is
approximately **98%**, default-cutover readiness approximately **92%**, and the
conservative overall project estimate remains **93%**. The remaining work is
dominated by unsupported-family breadth, production-entry/default-cutover
scans and final verification rather than the now-closed derived-funcdef
relation, so raw changed-line volume is not an appropriate completion measure.
