# HIR-neutral source provenance extraction gate — 2026-08-27

## Outcome

This bounded retirement slice extracts the source-provenance records that must
survive TypedSemantic HIR deletion into a new neutral header:

`source/as_source_provenance.h`

`asCScriptCode`, `asCModule::AddScriptSectionWithSourceProvenance`, and the UE
module source-ingestion path now use:

- `asSSourceAnchor`;
- `asEGeneratedSourceKind`;
- `asSGeneratedSourceOrigin`;
- `asSSourceSpan`;
- `asSSourceProvenanceRange`.

`as_scriptcode.h` no longer includes `as_typed_semantic_ir.h`. The HIR header
temporarily aliases its old source vocabulary to the neutral types so existing
HIR consumers remain buildable while they are migrated/deleted. Those aliases
are owned by the HIR header and must disappear when that header is physically
removed; they are not a new public compatibility contract.

This slice removes a real HIR include/ownership dependency without removing
source provenance, native `asCScriptNode`, Parser, `asCBuilder`, `asCCompiler`,
or explicit LEGACY compilation.

## TDD evidence

### RED

A new real automation test first required the neutral header and typed
ScriptCode API. The build failed only because the header did not exist:

`Saved/Build/cta-hir-neutral-provenance-red/20260827_174326_587_7257578d/RunMetadata.json`

The relevant compiler diagnostic was:

```text
fatal error C1083: cannot open include file: source/as_source_provenance.h
```

### First GREEN attempt and repair

The first production build after extraction failed:

`Saved/Build/cta-hir-neutral-provenance-green-build/20260827_174458_857_1f86ab21/RunMetadata.json`

Root cause: `AngelscriptTypedASTJITBackend.h` still forward-declared
`struct asSTypedSemanticSourceSpan`. A typedef alias cannot coexist with that
different struct declaration. The backend testing seam now includes the
neutral header and accepts `asSSourceSpan` directly.

The same build exposed a test-design error: a preprocessor `#error` tried to
infer direct header dependencies from `AS_TYPED_SEMANTIC_IR_H`. UE unity builds
may combine a different test `.cpp` that already included HIR, so the macro is
translation-unit state rather than evidence about `as_scriptcode.h`. The
permanent test now proves the exact neutral member-function signatures and
behavior; an explicit source scan proves the direct-include boundary.

The repaired Runtime/Editor build passed:

`Saved/Build/cta-hir-neutral-provenance-green-build-fix1/20260827_174817_215_8a7f9913/RunMetadata.json`

### Focused automation

Neutral ownership plus the existing HIR capture/verifier compatibility matrix
is **7/7 PASS**:

`Saved/Tests/cta-hir-neutral-provenance-tests/20260827_174859_973_8a434af3/RunMetadata.json`

Canonical SourceManager diagnostics, remap, native Parser/Builder/Compiler
coordinates, and source-session behavior are **9/9 PASS**:

`Saved/Tests/cta-hir-neutral-provenance-source-manager/20260827_175000_776_a85162f1/RunMetadata.json`

Standalone independently compiled the maintained fork and completed **21/21
PASS**:

`Saved/StandaloneTests/cta-hir-neutral-provenance-standalone-final_01_Standalone/20260827_175536_501_24e19f9d/RunMetadata.json`

The Standalone count is the current discovered suite size; it is not added to
UE Automation counts.

## Source-boundary evidence

The final focused scan has zero direct HIR include or old HIR provenance type
matches in:

- `as_source_provenance.h`;
- `as_scriptcode.h/.cpp`;
- `as_module.h/.cpp`;
- the UE source-ingestion scope in `AngelscriptEngine.cpp`.

The UE ingestion path positively uses the new neutral range, anchor, and
generated-kind types. Positive scans also retain `asCScriptNode`,
`asCBuilder`, `asCCompiler`, and `asCOMPILER_PIPELINE_LEGACY`.

Across all active `Source` and `Standalone` inputs, the five old provenance
symbols moved from **203** matching lines before this slice to **173** after
it. The remaining matches are HIR, TypedASTJIT, and HIR-era test consumers;
they remain the next migration/deletion frontier rather than neutral source
ingestion dependencies.

## Problems encountered

### CTA-HIR-PROV-01 — HIR forward declaration conflicted with neutral alias

The first GREEN build found the stale TypedASTJIT backend forward declaration.
It was repaired at the public testing seam rather than reintroducing a second
struct or including the HIR model from the neutral header.

### CTA-HIR-PROV-02 — unity macro state cannot prove header isolation

The original permanent test used the HIR include guard as an isolation oracle.
Unity compilation invalidated that assumption. The replacement uses exact
typed API signatures and behavior; source scans provide direct dependency
evidence.

### CTA-HIR-PROV-03 — Windows shell quoting and wildcard paths

One source-scan command embedded a quoted include regex incorrectly in a
PowerShell string and failed with a parser error. Another passed
`as_scriptcode.*` / `as_module.*` wildcard path components directly to `rg`
and failed with Windows `os error 123`. Both commands produced no accepted
evidence. Corrected scans used a single-quoted regex plus explicit file paths
and returned zero forbidden neutral-ingestion matches.

### CTA-HIR-PROV-04 — new non-ASCII comment produced a Standalone warning

The neutral header initially used an em dash in its leading comment, adding a
new MSVC code-page C4819 warning. The comment was changed to ASCII. This was a
comment-only cleanup. The final independent Standalone rerun rebuilt the
maintained fork after that cleanup and passed 21/21; its metadata is the
Standalone evidence cited above.

### CTA-HIR-PROV-05 — final dependency scan repeated the quote failure

The post-validation dependency scan again embedded the quoted include pattern
as a regular expression through PowerShell and reached `rg` as an invalid
unclosed group. That failed command produced no accepted evidence. The rerun
used fixed-string `-e` patterns against the same explicit files and returned
`neutral-ingestion-forbidden-match-count=0`.

Existing C4100/C4191/C4819 and similar warnings in unrelated maintained-fork,
fixture, and generated sources remain baseline noise and receive no completion
credit.

## Non-claims

- TypedSemantic HIR is not yet physically deleted; Task 10.5 remains open.
- The temporary aliases and 173 remaining old provenance-name matches are not
  treated as completion.
- This does not migrate all TypedASTJIT HIR overloads or HIR-only tests.
- This does not change compiler default, enable `dual`, broaden fallback,
  remove native AST/Builder/Compiler, disable tests, commit, or archive.
