# Task 2.17 source provenance implementation and verification

Date: 2026-08-17

## Contract closed by this task

Typed Semantic HIR now keeps the compiler's processed UTF-8 source span as
the mandatory coordinate. Authored coordinates and generated-code origins are
separate optional records: neither can be inferred from, nor substituted by,
the processed offset. Diagnostic selection is therefore deterministic:

1. use an exact authored origin when one exists;
2. otherwise use a generated origin's exact authored anchor when present;
3. otherwise retain the processed source span.

Generated origin kinds cover LiteralAsset, SubsystemAccessor, ClassHelper,
StaticClassHelper, DelegateHelper and RangeBasedFor. A generated origin also
owns its generator display name and may own an authored anchor. Missing or
malformed optional tuples fail closed without damaging the mandatory
processed span.

## Implemented data path

- `FAngelscriptPreprocessor` records processed-code-unit ranges for generated
  blocks and remaps existing ranges through range-for and literal-asset edits.
  Literal asset and subsystem generation freeze the exact authored anchor
  before source rewriting.
- `FAngelscriptEngine` converts UE `TCHAR` processed coordinates to UTF-8 byte
  coordinates before calling the fork-private
  `asCModule::AddScriptSectionWithSourceProvenance`. The public AngelScript ABI
  is unchanged.
- `asCScriptCode` owns, validates and applies sorted, non-overlapping ranges
  only to compiler spans that are fully contained by a range.
- `asSTypedSemanticSourceSpan` owns mandatory processed coordinates plus
  explicit optional authored/generated records. The verifier rejects partial
  tuples and the dump renders `processed=`, `authored=`, `generated=`,
  `generator=` and `anchor=` separately.
- Typed AOT call diagnostics preserve ProcessedSource and populate
  AuthoredSource/GeneratedSource only from the corresponding explicit HIR
  record. They never relabel processed offsets as authored offsets.
- The developer HIR dump normalizer now accepts both ResolvedCall and
  CallRewrite identity fields and replaces the exact local `functionId` token
  with a stable target. Because normalized HIR now contains provenance and the
  stable-target spelling changed, its schema revision is 2.

## Problems found and resolved

### UE declaration fan-out

Putting source-provenance value types directly into a high-fan-out Engine
header initially exposed incomplete-type/include-order failures. The final
layout keeps UE-owned declarations in the Engine model and translates to
fork-owned POD-like records at the module handoff. No public AngelScript ABI
was enlarged.

### TCHAR and UTF-8 are different coordinate systems

Preprocessor edits are naturally expressed in UE `TCHAR` code units, while
AngelScript parser nodes use UTF-8 byte offsets. Treating those numbers as
interchangeable would silently shift every span following non-ASCII text.
Tests therefore include a Chinese source comment, freeze authored UTF-8
anchors, and perform the processed-range conversion only at the Engine/module
boundary.

### Test-fixture coordinate corrections

The inline fixture helper contributes a leading newline and an early draft of
the capture test compared processed and authored coordinates as if they were
the same space. Both expectations were corrected: processed positions are
asserted against the actual compiler section, while authored positions are
asserted only against the explicit authored tuple. One transient PowerShell
CLR failure occurred while driving a test run; rerunning the unchanged
official command succeeded, so it was recorded as runner noise rather than a
product failure.

### HIR dump normalizer assumed the old dump layout

The first true source-graph integration run failed before serialization with
`HIR normalized text did not contain its resolved-call identity token`.
Normalization searched for the old adjacent spelling
`functionId=<id> operands=`. Call rewrite and provenance fields legitimately
appear between those fields. The fix normalizes the exact whitespace-delimited
`functionId=<id>` token for both ResolvedCall and CallRewrite, skips negative
IDs and still rejects an absent token. It does not leak Engine-local IDs or
pointers.

### LiteralAsset existed in preprocessing but was absent from normalized HIR

The first post-normalizer integration result contained
`generated=SubsystemAccessor` but no `generated=LiteralAsset`. A focused
failure excerpt proved:

- the generated `GetGeneratedProvenanceAsset()` function was present in the
  complete graph but had `CaptureState=Missing`, which is expected for its
  currently unsupported managed UObject-handle body;
- `__Init_GeneratedProvenanceAsset(UObject)` had Verified HIR;
- its parameter symbol used `MakeTypedSemanticSpan(script, in_func)`, so the
  recorded span was the whole function, crossing the generated signature and
  the authored `{ ... }` body;
- strict containment therefore correctly refused to label the cross-boundary
  span as generated.

The production fix does not loosen containment. The compiler now walks the
function AST's `snParameterList` and gives each parameter symbol its own
identifier token (or its type token when unnamed). This is the semantically
correct processed compiler span and it lies inside the LiteralAsset-generated
signature. A small compiler-level test locks offset, length, kind and generator
name independently of the HIR dump integration fixture.

The first attempt to attach the failure excerpt passed it as a second
`ASSERT_THAT` macro argument. CQTest messages belong to the matcher (`IsTrue`
in this case), so the diagnostic was corrected without changing the pass/fail
condition.

## RED evidence

- Typed AOT diagnostic helper RED build:
  `Saved/Build/typed-semantic-task217-diagnostic-e2e-red/
  20260817_024111_731_90bcecfb/` — expected missing-symbol link failure.
- First real HIR dump integration:
  `Saved/Tests/typed-semantic-task217-hir-provenance-e2e/
  20260817_024303_579_9f43e99e/` — old normalizer rejected valid call text.
- LiteralAsset integration RED after the normalizer fix:
  `Saved/Tests/typed-semantic-task217-hir-provenance-e2e-green1/
  20260817_024451_014_587e512c/` — `0/1`, only the LiteralAsset marker was
  absent.
- Evidence-bearing integration RED:
  `Saved/Tests/typed-semantic-task217-hir-provenance-diagnostic/
  20260817_025055_217_0985f006/` — proved Getter Missing and initializer
  parameter whole-function span.
- Exact parameter-token RED:
  `Saved/Tests/typed-semantic-task217-parameter-provenance-red/
  20260817_025404_915_e6f70b2a/` — `1/2`; expected parameter offset 26,
  observed whole-function offset 0.

## GREEN evidence

- Production/test build:
  `Saved/Build/typed-semantic-task217-parameter-provenance-green-build/
  20260817_025504_099_1557d656/` — PASS.
- Parameter capture group:
  `Saved/Tests/typed-semantic-task217-parameter-provenance-green/
  20260817_025519_219_4f9fc894/` — `2/2 PASS`.
- Real Asset + Subsystem source-graph integration:
  `Saved/Tests/typed-semantic-task217-hir-provenance-e2e-green2/
  20260817_025556_157_979141db/` — `1/1 PASS`.
- Complete compiler source-provenance group:
  `Saved/Tests/typed-semantic-task217-source-provenance-green/
  20260817_025640_834_cc129924/` — `5/5 PASS`.
- Real preprocessor ranges and UTF-8 anchors:
  `Saved/Tests/typed-semantic-task217-preprocessor-provenance-final/
  20260817_025731_275_2363ed9c/` — `1/1 PASS`.
- Typed AOT diagnostic selection:
  `Saved/Tests/typed-semantic-task217-aot-diagnostic-provenance-final/
  20260817_025811_145_97c917b2/` — `1/1 PASS`.
- HIR dump schema/normalization regression:
  `Saved/Tests/typed-semantic-task217-hir-dump-regression/
  20260817_025846_294_0860c7a2/` — `5/5 PASS`.
- Required complete Compiler prefix:
  `Saved/Tests/semantic-ir-capture/
  20260817_025953_549_4bcd2ccd/` — `184/184 PASS`, zero failed/skipped.
- Required Standalone suite:
  `Saved/StandaloneTests/semantic-ir-standalone_01_Standalone/
  20260817_030036_496_b5f2e697/` — `20/20 PASS`, zero failed. This is the
  current observed count; the new TypedSemanticIR CTest makes it one higher
  than the older 19-test documentation baseline.
- Parent and plugin `git diff --check`: PASS. Git only printed line-ending
  conversion warnings.

All official build/test commands were launched from `V:\` through
`Tools\RunBuild.ps1`, `Tools\RunTests.ps1` or `Tools\RunTestSuite.ps1` and
used the worktree's configured UE 5.8 EngineRoot.
