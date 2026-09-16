# Hand-authored Language fixture corpus

## Accepted source and outcome

English consolidation of angelscript/test-code-language-corpus / designs/language-fixture-corpus. Q10 selected a source-database delivery, Q106 accepted the 47-container inventory, Q108 separated generators from handwritten fixtures, Q110 selected this Change ID, and the current user explicitly requested creating this second Change. The accepted 47-file list supersedes the older 80-120 estimate. Const is housed in Syntax/Const, giving six physical themes.

Deliver every one of the 47 FileTags in the attached inventory under AngelscriptTestCode/Language. Rewrite relevant legacy language material into complete-version v1 author containers, project it through the existing Python tool, and make every file/version queryable in the existing central code database. Retire the production Counter fixture after a real StructFields fixture replaces its integration-test role.

## Ownership and boundaries

Author files and CodeGenTool tests/docs belong to the parent repository. Their checked-in projections and Framework integration tests belong to the Plugins/Angelscript submodule. The generator sibling Change owns Framework/Generate and its generated-case test exports; this Change does not add generator classes or depend on their completion. The prior ordering preference is delivery order, not a technical task dependency.

```text
TestSource-old/Language                     // Read-only scenario and provenance evidence.
  -> AngelscriptTestCode/Language/*.as      // Forty-seven human-authored complete-version containers.
  -> explicit codegen.py generate          // Structured C++ projections under the plugin TestCode/Generated.
  -> deferred database registration        // Existing central admission, no second registry.
  -> Get / FindFiles / FindCases            // Source and metadata queries, without AS execution.
```

Do not move or delete the 624-file legacy tree. Exclude UClass material, FString/UE object and geometric APIs, CVar/console/compilation-event observers and import/module graphs. Do not copy UFUNCTION, @Kind Observe or legacy metadata wrappers into the new public containers. Preserve language declarations and meaningful expressions, including negative programs. Removed syntax may occur deliberately in a Negative version, never masquerading as supported positive syntax.

## Container contract

- The file path without .as is the FileTag. File metadata uses @version v1, a nonempty English @summary and @topic Language plus its exact theme. Node metadata has a nonempty summary, one parentless root and complete independent source bodies terminated by /** @end */.
- root is the representative source for the concern. Additional accepted source shapes use stable valid-<legacy-scenario-kebab-name> versions parented to root; compile-rejection variants use invalid-<legacy-scenario-kebab-name>, parent root and topic Negative. Version count is not fixed at 47: 47 is the file count. Merge duplicated observation wrappers, but record every retained source's destination and every exclusion's reason.
- Each task inspects its listed source anchors and the owning theme's legacy inventory, records inline ordinary comment provenance for retained/adapted scenarios, and updates that theme's migration record. Every legacy file must receive a documented retained/merged/adapted/excluded disposition by completion; a filename anchor is an investigation entry, not a claim that its entire file is suitable.
- Keep metadata valid even when the AS program is intentionally invalid. Negative is a selection topic, not an execution instruction or proof of compilation failure. SourceOnly identifies lexical-only material when compilation requires excluded host types. A SourceOnly root does not count as a proven compilable positive.
- Use readable Allman braces, tabs for source indentation, one statement per line and LF text. Do not change intended lexical edge-case bytes (comments, strings or malformed tokens) for cosmetic normalization. Such exceptions carry a short rationale in the version summary/provenance.
- Foreach rewrites the range/iteration shape using script-defined opForBegin/opForNext/opForValue/opForEnd evidence where applicable, preserving the language protocol without TArray/TMap registration. The dormant native Foreach protocol source is supplementary evidence, not a runtime dependency or a reason to wait for the generator Change.
- DirectiveInString preserves directive-looking literal/comment tokens as SourceOnly lexical material without FString host declarations or equality APIs. Its source is admitted as material; this Change does not claim that a string literal can compile without the future consumer's language environment. IfElifElse uses explicit source-local condition arrangements and excludes Editor configuration and import graph dependencies.

## StructFields replacement contract

Choose Language/Syntax/StructFields as the production integration fixture, rather than allowing each implementer to pick a different first file. Use root (basic integer/float fields), add-field (same complete struct plus another integer field), and invalid-duplicate-field (complete program with a repeated member). Use a script struct named FStructFields, integer X initialized to 0, float Y initialized to 0.0f, and added integer Z initialized to 1. All child nodes name root.

Retain annotation coverage by placing point initial-value at the root's 0, breakpoint before-add before the child Z declaration, and range delta around its 1. The existing GeneratedSources tests must use independent literal clean-source expectations and independently calculated offsets for this exact new authored file; never reuse Counter byte offsets or compare runtime output with itself. Set file topics Language/Syntax; root topic Baseline; child topic Fields; negative topic Negative. This is source material, not a reload execution protocol.

## Counter migration and tool baseline

GeneratedSourcesTests.cpp and AdoptionTests.cpp query the global production Counter and must move to StructFields. GeneratedSources also asserts source bytes, annotations, origin offsets, metadata, structured format=v2 registration and absence of runtime source-parser calls; retain all these checks with the new fixture. Python test_source_parser.py reads production Counter at two sites: preserve its annotated bytes in a dedicated tests/fixtures/parser/Language/Counter.as and redirect those reads before deleting production Counter. Existing renderer fixtures and synthetic Counter strings in Parser/Builder/Database tests remain private test inputs.

Delete only AngelscriptTestCode/Language/Counter.as and its signed TestCode/Generated/Language/Counter.generated.cpp through normal author-source deletion plus codegen generate. Keep unrelated generated providers and fixtures. The observed current codegen check passes. Python now parses author metadata/annotations and renders structured format=v2 C++; the Skill paragraph saying Python does not parse and runtime activation calls the source parser is stale and must be updated to the inspected implementation, with no runtime/tool refactor.

## Verification

Each container's exact proving command uses the attached read-only fixture verifier: discover the intended FileTag, parse v1 structure, verify root/topic/negative rules, and compare its checked-in projection byte-for-byte with the current renderer. Missing sources or projections fail; a globally synchronized but incomplete tree is not sufficient. Implementers explicitly run codegen generate for owned source changes and inspect writes to avoid absorbing unrelated work.

The final Framework.LanguageFixtureCorpus test queries every accepted FileTag/root and all declared versions, checks no registration errors, topic selection and absence of production Counter. This proves database admission, not AS compilation/execution. The focused existing GeneratedSources and Adoption prefixes prove the replacement integration behavior. No new NativeEngine language tests, Builder/VM execution, generator export tests, full UE suite, commit or publication belongs to creation.
