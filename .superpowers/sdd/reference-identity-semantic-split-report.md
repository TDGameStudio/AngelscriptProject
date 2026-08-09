# Reference identity semantic-owner split report

Status: `DONE` by the required static gates.

## Result

The 288-cell source/operation/qualifier owner remains in
`Language/References/AngelscriptNativeReferenceIdentityTests.cpp`. The single
current-fork derived-to-base input-reference rejection now lives in
`Language/References/AngelscriptNativeReferenceDerivedInputRejectionTests.cpp`.

Both classes retain the exact Automation directory:

`Angelscript.TestModule.AngelScriptSDK.Language.References.Identity`

No product ID, case ID, generated AngelScript, diagnostic, runtime oracle,
cleanup, recovery behavior, or registered method body changed.

| Owner | Class | Method | Product | Cases | Assertions | Print sites |
| --- | --- | --- | --- | ---: | ---: | ---: |
| `Language/References/AngelscriptNativeReferenceIdentityTests.cpp` | `FReferenceIdentityTests` | `SourcesByOperationAndQualifier` | `LANG-REF-SOURCE-OP` | 288 | 38 | 1 |
| `Language/References/AngelscriptNativeReferenceDerivedInputRejectionTests.cpp` | `FReferenceDerivedInputRejectionTests` | `CurrentForkRejectsDerivedToBaseInputReferenceConversion` | `LANG-REF-FORK-DERIVED-INREF` | 1 | 18 | 1 |

## Frozen hashes

The pre-edit owner matched the brief exactly:

- 1,178 lines / 30,982 bytes;
- SHA-256
  `C45D418DFD45D7F2C36C0A79383588BAB4E4B0E827009792764CCE35B370A353`.

Post-edit complete-file hashes:

- retained owner: 1,081 lines / 28,187 bytes,
  `59CBBE9FE5BA877AA934211FD00AD6A0E0731E21362CC49F2BDD3F89E4D80978`;
- rejection owner: 268 lines / 7,754 bytes,
  `696ADFE0104D285E4DD946C34A47A90E3D612B55603E190CF64A6027DAFFB18C`.

Inclusive-brace method hashes remained byte-exact:

- `SourcesByOperationAndQualifier`:
  `52DECD7FBF6EE2768733B0CC97F015D3542813246D3487661E897BAD2AB9BC3C`;
- `CurrentForkRejectsDerivedToBaseInputReferenceConversion`:
  `A6B2697F5C25EAB12E099751E22382120E61E7DAEA89D7AB79DACD30FAEB30B3`.

## Behavioral preservation

Canonical expansion remains 288 + 1 = 289 unique IDs.

The retained owner still has:

- 88 compile-rejection cells and 200 successful compilations;
- 7 located null exceptions and 193 successful semantic sentinels;
- 288 isolated engines and context lifecycles;
- 376 dynamic source reports and 376 module discards;
- exact operation → qualifier → source order;
- same-context legal recovery and same-engine/same-name failed-build recovery;
- per-cell native identity, retain/release, and destruction reconciliation.

The rejection owner still requires:

- `FRefDerived` passed to `const FRefRoot&in`;
- a negative build result;
- `No matching signatures`;
- `Parameter 'First' expected const FRefRoot&, but got FRefDerived&`;
- failed-shell discard;
- same-engine/same-module recovery returning `913`;
- balanced native reference state before the RAII engine destroy.

Each physical owner has one engine Create/Destroy call-site pair, one direct
`PrintGeneratedAsSource` site, one body gate, and zero CQTest lifecycle hooks.
The rejection owner contains no positive tables or `RunCell`; the retained
owner contains no fork product or rejection fixture.

No new header was created.
`AngelscriptNativeReferenceTestSupport.h` was not edited or enlarged. The new
class copies only the three required aliases and the five dependency-complete
private helpers, so its unique class name keeps the copies unity/ODR safe.

## Assertion multiplicity

The two owners contain 56 physical sites and 43 unique assertion hashes:

- retained owner: 38;
- rejection owner: 18;
- the moved method's 5 hashes occur once;
- exactly 13 copied helper hashes occur twice;
- every other hash occurs once.

The exact multiplicity-two set is:

```text
badde741d593e6d50e2d48cd39e31a803609096ad54f4255aaf47aa167a8f2a6
92db60e83374cb21a9f4f971322eabdd3eef747e4bd477bc9b0a63d03a7775b0
209afcc0863d4226759c351566b799f1826e45c206cf18846dabfc85801ba7f1
09981bef50815b989ab50a58ba2eb30aea8ba906b4d1e239b4b265a71dc859ed
db991bb9dd3eee88cdd05b3d3a22bb0a489686c0bef3a5b34e5d93c00967ce49
598bf37ade0256c066253fe7fbbd309c8f403b78b34530f9aa363365f671cb7c
082820bbdca6b1aaba1218de2e50805973995276568457de93f40bc91e5cb4a4
18d64eae721f49cf39dd27cdbb7553986a4f9e28a6fdfe5b303776ea84af3eb9
e38724b641a3600ed560444b63e7086a6189f8fa1f33b8201311e5aff4a4d323
43b4c964b442b36c820f33c1b3e275ecc0d877270b342d9bfab92af9bfa9f9dc
7f40b2df22446e60507f9c7aefea1934ce5b7e5d14967632aaa8364a5dd90be9
d22f96bbd3850cd6cc36049e9b7798d631128f6bdeaadf3a6766d6968a8f3626
5ad40584ea417d31fc11ff4387360d0fc20a9083e303648fc792d66bb08db9d2
```

The regenerated global assertion count is 8,154.

## Current records

The product owner and source registry now resolve the fork product to the new
file/class/method. The positive registry row remains unchanged, and both rows
declare `PrintSites=1`.

Authored living records updated:

- `catalogs/coverage-products.psd1`;
- `catalogs/generated-source-registry.csv`;
- `handoffs/fixture-and-large-file-quality-review.csv`;
- the living section of `handoffs/fixture-and-large-file-quality-review.md`;
- `handoffs/assertion-depth-language-conformance-review.csv`;
- tasks 4.7 and 5.8.

Official current outputs regenerated:

- expected cases and product cardinalities;
- current files, methods, assertions, and summary;
- implementation and method-product reconciliation;
- API use;
- predecessor baseline;
- internal-method dispositions and reconciliation;
- boundary, inline-source, and planning outputs.

Current summary:

```text
Files:            263
Methods:          688
Assertions:     8,154
Lines:        162,029
RawBlocks:        301
AnsiWrappers:     294
ActiveMethods:    674
DisabledMethods:   14
```

The living quality CSV has 263 unique rows matching all 263 physical SDK
source keys: 218 `NotLarge`, 43 retained cohesive owners, and 2 remaining
split-required owners. Tasks 4.7 and 5.8 both state two remaining splits.

## Static verification

- Product expansion: PASS, 317 products / 46,140 expected cases.
- Catalog validation: PASS, 46,140 unique IDs.
- Current inventory: PASS, exact 263 / 688 / 8,154 / 162,029 summary.
- Source reconciliation: PASS, 317 products, 316 enabled and 1 Disabled
  implementation, zero incomplete products, and zero unresolved methods.
- API-use audit: PASS, 365 rows, zero missing and zero incomplete.
- Predecessor reconciliation: PASS, all 222 terminal dispositions checked.
- Internal-method reconciliation: PASS, 1,002 final / 0 pending.
- Boundary audit: PASS, 0 violations.
- Inline-source audit: PASS, 301/301 conforming / 0 violations.
- Planning-record audit: PASS, 0 violations.
- Strict OpenSpec validation: PASS, 1/1 valid / 0 issues.
- Focused identity guard: PASS, both file hashes, both method hashes, 289
  unique IDs, 56/43 assertion counts, exact 13-hash multiplicity, two registry
  rows, source separation, lifecycle call sites, current owners, and quality
  totals.
- Scoped whitespace/EOF scan: PASS, no trailing whitespace and all authored
  source/record files have final newlines.

## Problems and constraints

The brief matched the frozen Identity owner; no source, method, product,
assertion, or lifecycle mismatch was found.

Two early PowerShell inspection commands used an invalid empty pipeline after
a `foreach` block. Both were rejected and rerun with collected output arrays.

The first internal-method reconciliation invocation omitted the finalized
dispositions input and therefore reported 1,002 unresolved rows. The rejected
output was not used as evidence. The command was corrected with the explicit
`internal-method-dispositions.csv` input and then reported 1,002 final / 0
pending.

The first focused guard interpreted the review's 45 classified
over-threshold owners as a fresh physical line-count total. Two unrelated,
already-modified files currently exceed 1,000 lines while their existing
review rows remain `NotLarge`:

- `Compiler/AngelscriptNativeBuilderBytecodeTests.cpp`;
- `Runtime/AngelscriptNativeGarbageCollectorTests.cpp`.

Those unrelated rows were not reclassified. The corrected scoped guard checks
the brief-required 263-key physical-tree parity, exact Identity rows, and
218/43/2 living dispositions. The rejected aggregate assumption was not used
as evidence.

No build was run. No UE Automation test was run. No commit was created. No
unrelated source, shared header, historical checkpoint, or record was edited.

## Independent review and focused record repair

Independent two-stage review reproduced both full-file hashes, both method
hashes, all 289 unique IDs, the 56 physical / 43 unique / exact 13 duplicated
assertion-hash contract, both lifecycle paths, and current catalog/audit
ownership. Source and code quality passed, but the first current records had
two groups of living-evidence defects:

- both Language assertion-depth rows cited only their method ranges while
  claiming evidence from directly invoked class-private helpers;
- the living quality Markdown retained post-Direction counts and still listed
  Identity as split-required instead of a cohesive retained owner.

The assertion-depth evidence now covers the real complete owner closures:
rejection `8-265` and positive `8-1078`. The quality Markdown now agrees with
the physical source and 263-row CSV: 223 case-owned, 218 not-large, 43 retained,
two split-required, and zero missing/stale/lifecycle-red rows; Identity appears
only in the retained current list.

Focused re-review resolves every path, class, method, range, count, and list
membership and preserves historical checkpoints. Final verdict:
specification PASS and code-quality PASS with no remaining findings.
