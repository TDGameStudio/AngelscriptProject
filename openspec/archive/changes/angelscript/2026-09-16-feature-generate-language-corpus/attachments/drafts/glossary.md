> Latest export correction: BuildDumpSource returns all cases in one formatted inspection file per generator. Earlier per-case-file/product-folder/index.json descriptions are superseded; actual execution still uses ListCases and canonical source APIs.

> Current naming/export amendment: canonical entries now use Entry plus PascalCaseId; each generator has one GeneratesAndExportsAllCases test that exports one complete readable source dump beside its current log. Current design/tasks own the exact amended contract.

> Current contract amendment: the case-enumeration replan adds ListCases and BuildCaseSource to every product. The current Change design and tasks own the amended interface; the original source-generation scope and int32 observation limits remain in force.

# Vocabulary and naming

Provenance: Q39-Q49 (first ControlFlow interfaces), Q53-Q96 (theme names), Q99 (short namespace/class names), Q100-Q102 (dispositions and int32 observations), and explicit full-corpus authorization on 2026-09-15. Existing convention: Framework/Generate/AngelscriptTestForLoopGenerator.h and FrameworkTests/Generate/ForLoopGeneratorTests.cpp.

- Namespace: AngelscriptTest::Generate; empty base: FCodeGenerator.
- Class and typed single-case method names: exact rows in the thirteen product catalogs.
- Parameter types: each catalog's F*Params. Per-product enum names use E + the product stem + axis name; PascalCase values derive from the listed axis tokens. A pre-existing specific name from the accepted first-batch vocabulary takes precedence.
- Header/source: AngelscriptTest + class name without leading F + .h/.cpp, following AngelscriptTestForLoopGenerator.h.
- New test class: class name without leading F; prefix Angelscript.UnitTest.Framework.Generate. Existing ForLoop retains its Framework.ForLoopGenerator identity.
- Every product exposes GetProductId() const, BuildAllSource(int32&) const, its named typed single-case builder, and GetExpected(FStringView) const. Reject-bearing products additionally expose BuildRejectSource(FStringView) const and ListRejectCaseIds() const.
- CaseId: accepted product ID followed by ordered uppercase axis tokens, hyphens between axes and underscores inside multiword values. Entry name: Entry plus the PascalCase conversion of the complete CaseId.
- Corpus acceptance test class: LanguageGeneratorCorpus, under Angelscript.UnitTest.Framework.Generate, derived from the existing Framework test naming convention.
- Product counts include normal returns, compile rejects and runtime-fault cells. BuildAllSource counts only non-reject entries. A rejection-only product still implements source generation through its reject API.

## Case-enumeration naming amendment

User request: repair the missing execution-consumer enumeration contract. Names derived from the existing F/E and AngelscriptTest header conventions: `FGeneratedCaseInfo`, `EGeneratedCaseOutcome`, `EGeneratedCaseExecution`, `AngelscriptTestGeneratedCase.h`; product methods `ListCases() const` and `BuildCaseSource(FStringView) const`. Fields and enum values are fixed in the current design, owned by task 1.1. There is no new registry or base-class method.

## Export naming amendment

User-selected entry style: PascalCase without underscores, for example EntryLangCfLoopDepthWhileZeroBreak. Test method GeneratesAndExportsAllCases; final acceptance method VerifiesCompleteCorpus. Test-only `AngelscriptTest::FGeneratedCaseExport` in FrameworkTests/Generate/GeneratedCaseExport.h/.cpp owns ResolveOutputFile and WriteDump, as specified in the current design. Runtime file GeneratedCases/<ClassWithoutF>.as; all cases in that one file, no JSON sidecar.

## Single-file dump amendment

New product method `FString BuildDumpSource() const` follows the existing Build*Source convention and is added to all 122 products. Each product test writes GeneratedCases/<ClassWithoutF>.as. Test-only export helper methods are ResolveOutputFile and WriteDump. No index.json or individual case files are produced.
