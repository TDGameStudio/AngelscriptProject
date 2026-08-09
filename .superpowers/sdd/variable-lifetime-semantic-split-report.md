# Variable lifetime semantic-owner split report

Status: `DONE`

## Result

Ordinary variable exit/nesting lifetime behavior and counted-reference
assignment ownership transitions now have separate physical CQTest owners.
Both registered method bodies, products, cases, generated AngelScript,
bytecode and metadata observations, lifecycle callbacks, runtime oracles,
cleanup, recovery, and save/load behavior remain unchanged.

Frozen aggregate:

- `Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp`
- 1,551 lines / 58,194 bytes / LF
- SHA-256:
  `48F449F71E546FF47CAE578F7A9278E8D036A83FF78487E8BD02ACB5BBB205A0`
- 1 class / 2 methods / 2 products
- 107 cases
- 87 physical and unique assertion hashes
- 2 direct source-print sites
- 2 raw-engine Create/Destroy pairs

Post-split owners:

| Owner | Class | Method | Product | Cases | Assertions | Print sites | Lines |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| `Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp` | `FVariableLifetimeTests` | `OwnersByExitAndNesting` | `LANG-VAR-LIFETIME` | 100 | 46 | 1 | 945 |
| `Language/Variables/AngelscriptNativeCountedReferenceAssignmentTests.cpp` | `FCountedReferenceAssignmentTests` | `CountedReferenceAssignmentsBalanceAcrossOwnershipTransitions` | `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT` | 7 | 41 | 1 | 791 |

Both classes retain:

`Angelscript.TestModule.AngelScriptSDK.Language.Variables.Lifetime`

The class names are unique across the native SDK source tree.

## Hash preservation

Complete post-split file hashes:

- retained ordinary-lifetime owner, 32,778 bytes:
  `B18D5FA3136D9668D02B8A6DC1C352470C3E6C1BC24770B06854F0FF7F787030`
- counted-reference owner, 30,545 bytes:
  `1E25823602E8C36DC015367B6C2C9878ABDA8BEDB22E077599AE7E80219086AA`

Inclusive-brace registered-method hashes match the frozen source exactly:

| Method | Bytes | SHA-256 |
| --- | ---: | --- |
| `OwnersByExitAndNesting` | 2,903 | `F462718EF15E0CE9E4617BEE0B5CF9F4EE9E93A6ADC0249C2224E8BD9683CE83` |
| `CountedReferenceAssignmentsBalanceAcrossOwnershipTransitions` | 17,144 | `3FEB71438FBB0C798ACBB715D024370B7CDA87C629C3DBD9B481B46A3C59F476` |

No brief-to-current-source mismatch was found.

## Shared boundary

No header was added or enlarged.

Only these three stateless, assertion-free class-private helpers are present in
both unique classes:

- `DescribeBytecode`;
- `ContainsBytecodeOpcode`;
- `DescribeNativeReferenceRegistration`.

The copies preserve unqualified helper calls in both frozen method bodies.
They add no assertion site and expose no shared interface. Ordinary owner,
nesting, exit, construction-order, verification, and execution helpers remain
only in the retained owner. Scenario, object-move, function-layout,
automatic-object metadata, and save/load responsibilities remain only in the
counted-reference owner.

## Ordinary-lifetime protocol

The retained owner preserves:

- 4 owner kinds × 5 exit paths × 5 nesting forms;
- exact exit → nesting → owner order;
- 100 unique IDs and 100 complete generated-source reports;
- one raw engine with immediate RAII destruction;
- native value and counted-reference registration;
- per-cell lifecycle reset and isolated module compilation;
- exact entry and recovery lookup;
- one context per cell;
- finished or exception results with return or exception location metadata;
- unprepare before lifecycle verification;
- exact construction, copy, assignment, destruction, identity, destruction
  order, AddRef, Release, and zero-live observations;
- same-context recovery returning 89 without hidden lifecycle events;
- context release, exact module discard/null lookup, and final zero-live
  observation.

The inactive
`ELifetimeExpectation::CurrentForkRawClassRetention` helper branch remains
present.

## Counted-reference protocol

The new owner preserves all seven scenarios in their original order:

- factory local;
- overwrite;
- null assignment;
- parameter/return;
- exception frame;
- save/load;
- parameter/return save/load.

It retains:

- one raw engine with immediate RAII destruction;
- one counted-reference registration;
- exact reference flags, absent type user data, and AddRef/Release behaviours;
- per-scenario recorder reset and complete generated-source report;
- exact entry lookup and bytecode/automatic-object metadata logging;
- parameter/return object-move offsets, ABI metadata, and call layout;
- reference-copy opcode and object-type operand-size checks;
- typed save/load, unframed legacy rejection, and no-overread observation;
- source discard, restored module load, and exact restored metadata/layout;
- one context per scenario with normal or exception identity behavior;
- unprepare, exact construction/AddRef/Release/destruction counts, and zero
  live objects;
- same-context recovery returning 89, second unprepare, context release, and
  module discard.

No class-owned engine/recorder or CQTest lifecycle hook was introduced.

## Assertion and source preservation

Official current assertion inventory and the focused guard report:

- retained owner: 39 helper + 7 method = 46;
- counted-reference owner: 41 method assertions;
- combined physical assertions: 87;
- unique assertion hashes: 87;
- maximum hash multiplicity: 1;
- global current assertions: 8,154.

Each owner contains one direct `PrintGeneratedAsSource` call. Dynamic reports
remain 100 + 7 = 107.

Expected expansion remains:

- `LANG-VAR-LIFETIME`: 100;
- `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT`: 7;
- combined: 107 rows / 107 unique IDs;
- global: 317 products / 46,140 unique IDs.

## Current records

Updated authored current records:

- `catalogs/coverage-products.psd1`;
- `catalogs/generated-source-registry.csv`;
- `coverage/variables.md`;
- `handoffs/assertion-depth-language-conformance-review.csv`;
- `handoffs/fixture-and-large-file-quality-review.csv`;
- the living section of
  `handoffs/fixture-and-large-file-quality-review.md`;
- tasks 4.7 and 5.8 in `tasks.md`.

The counted product owner now resolves to the new file/class/method. Both
generated-source rows have `PrintSites=1`. The Variables record now includes
the already implemented seven counted-reference cases and reports 1,940 cases
without changing the executable catalog.

Assertion-depth evidence resolves through:

- ordinary owner `15-943`;
- counted-reference owner `15-789`.

The living quality inventory now reports:

- 264 rows / 264 unique physical source keys;
- 224 `CompliantCaseOwned`;
- 220 `NotLarge`;
- 43 retained cohesive owners;
- 1 split-required owner.

Tasks 4.7 and 5.8 state one remaining split. Module API Contract is the only
remaining physical owner split.

Historical checkpoints and old build/test evidence were not rewritten.

An independent living-record rescan found three additional stale values in the
quality Markdown after the first record update: the top lifecycle table still
reported 223 case-owned owners, the split-candidate heading still reported
two, and its narrative still referred to both candidates. The CSV and bottom
summary already held the current values. The three Markdown occurrences were
corrected to 224 and one remaining candidate. Fresh top/bottom/CSV parity,
planning, strict OpenSpec, whitespace, and EOF checks pass at
264 / 224 / 220 / 43 / 1.

A final independent wording review found one minor grammar defect in that
quality narrative (`candidate have`). It was corrected to `candidate has`.
No source, ownership, assertion, lifecycle, or protocol finding remained.

## Official regenerated outputs

The official scripts regenerated:

- expected coverage and product cardinalities;
- current files, methods, assertions, and summary;
- implementation and method-product reconciliation;
- API use;
- predecessor baseline;
- internal-method dispositions and reconciliation;
- boundary findings;
- inline-source baseline;
- planning-record findings.

Current summary is:

- 264 files;
- 688 methods;
- 8,154 assertions;
- 162,214 lines;
- 301 raw blocks;
- 294 ANSI wrappers;
- 674 active methods;
- 14 Disabled methods.

## Static verification

- `ExpandCoverageProducts.ps1`: PASS, 317 products / 46,140 expected cases.
- `ValidateCoverageCatalogs.ps1`: PASS, 317 products / 46,140 cases /
  46,140 unique IDs.
- `ExportCurrentNativeSdkInventory.ps1`: PASS, exact 264 / 688 / 8,154 /
  162,214 / 301 / 294 / 674 / 14 summary.
- `ReconcileNativeSdkSource.ps1 -RequireComplete`: PASS, 317 products /
  316 enabled implementations / 1 Disabled implementation / 0 incomplete /
  688 methods / 0 unresolved.
- `AuditNativeSdkApiUse.ps1 -RequireComplete`: PASS, 365 rows / 357 observed /
  1 contract-covered / 7 deferred / 0 missing / 0 incomplete.
- `ReconcilePredecessorScenarios.ps1 -RequireFinalDisposition`: PASS,
  222 required scenarios checked against terminal dispositions; the generated
  baseline reports 24 direct present and 198 disposition-backed missing
  predecessor names.
- `FinalizeInternalMethodDispositions.ps1`: PASS, 1,002 rows:
  171 direct / 803 public-contract / 28 deferred.
- `ReconcileInternalMethods.ps1 -RequireComplete`: PASS, 1,002 final /
  0 pending.
- `AuditNativeSdkBoundaries.ps1 -RequireClean`: PASS, 0 violations.
- `AuditInlineAsFormatting.ps1 -RequireClean`: PASS, 301/301 conforming /
  0 violations.
- `ValidatePlanningRecords.ps1 -RequireClean`: PASS, 0 violations.
- `openspec validate test-as-native-sdk-comprehensive-coverage --strict
  --json`: PASS, 1/1 valid with no issues.
- Focused source guard: PASS, both exact file/method hashes; each file has
  1 class / 1 method / 1 product / 1 print / 1 engine Create/Destroy pair /
  1 context Create/Release call site.
- Focused assertion guard: PASS, 46 + 41 physical and unique assertions /
  maximum multiplicity 1.
- Focused case/registry guard: PASS, 100 + 7 unique IDs and two exact
  `PrintSites=1` rows.
- Focused quality/current-record guard: PASS, exact 264 / 224 / 220 / 43 / 1
  totals and exact current summary.
- Scoped whitespace/EOF guard: PASS, zero trailing whitespace and final
  newlines present.

## Problems and corrections

Four rejected invocations occurred and were corrected:

1. The first generated add-file patch used PowerShell `-split` with a negative
   count. It duplicated the in-memory patch text to 61,268 characters, and
   Windows rejected the process launch because its command line was too long.
   No target file was written. The input construction was corrected to
   `TrimEnd().Split()`, producing the intended 31,510-character patch and the
   exact 30,545-byte file.
2. The first combined current-record patch used an incorrect Markdown context
   line in the living summary. `apply_patch` rejected the complete patch, so
   none of that combined input was treated as applied. The records were split
   into exact, smaller patches and applied successfully.
3. The first focused guard requested a non-existent `CaseId` column from
   `expected-coverage.csv`. Hash and assertion checks before that lookup were
   successful, but the partial invocation was not accepted as the complete
   focused result. The guard was corrected to use the actual `Id` column and
   rerun; case, registry, quality, summary, record, whitespace, and EOF checks
   then passed.
4. The first final combined focused guard read authored UTF-8 text through the
   host's default GBK decoder and stopped on a non-ASCII Markdown byte. No
   source or record was changed. The guard was corrected to request UTF-8
   explicitly and rerun in full; file/method hashes, assertion uniqueness,
   current summary, quality top/bottom parity, whitespace/EOF, and authored
   terminology checks all passed.

No rejected or partial output was reinterpreted as final evidence.

## Execution boundary

No build was run. No UE Automation test was run. No commit was created. No
unrelated source, support header, historical checkpoint, or external record
was edited.

## Independent review

Independent two-stage review reproduced both complete file hashes, both frozen
method hashes, 100 + 7 unique case IDs, 46 + 41 physical and unique assertions,
both source-print sites, both engine/context/module protocols, counted-reference
bytecode/save-load restoration, Variables total 1,940, and every canonical
current owner.

Source and semantic review passed without findings. Code-quality review found
one living Markdown grammar defect after the remaining split count became
singular: `candidate have`. It was corrected to `candidate has` without
changing any source, count, or historical evidence.

Focused re-review confirms quality top/bottom/CSV parity at 264 source owners,
224 case-owned, 220 not-large, 43 retained, one split-required; both
assertion-depth ranges cover their complete owner/helper closures; tasks 4.7
and 5.8 name Module API Contract as the only remaining split; whitespace, EOF,
and current/history boundaries pass. Final verdict: specification PASS and
code-quality PASS with no remaining findings.
