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

## Aggregate source round-trip verification

The current user selected a full-library dump and comparison instead of many new unit tests. Add exactly one new UE Automation method, Framework.LanguageFixtureCorpus.DumpsAllAuthoredSources, for this corpus. The 47 migration cards remain source tasks using one shared read-only checker; they do not create 47 C++ tests. Existing GeneratedSources/Adoption/parser tests receive only the maintenance required by Counter replacement and retain their existing identities and assertions.

### Independent expected and actual branches

Expected source comes directly from parsing the migrated author containers with the existing Python container parser. Use each ParsedVersion.clean_source byte sequence, keyed by FileTag and VersionTag. Validate the independent accepted 47-tag inventory, all declared versions and the existing metadata contract. Do not read the C++ projection or runtime dump to construct expected source.

Actual source and header metadata come only from the compiled C++ central database: FindFiles with Language, FindCases for every discovered file with no version-topic filter, then retain each GetSource() value and read its GetBytes()/GetAnnotations() views. Include root, every positive variant, invalid-* and SourceOnly versions. Check activation, query status and registration errors. The dump path must not read author .as files, run the Python renderer, reconstruct the source from .generated.cpp text, or restrict enumeration to expected identities (which could hide unexpected registrations).

The migration baseline for byte equality is the migrated authored container's clean version source, not the 624 legacy files. Legacy-to-container rewriting still uses the source disposition records. Container metadata delimiters and inline annotation markers are intentionally removed by the existing parser. Ordinary source comments, literal content, whitespace, UTF-8 bytes and final-newline presence remain significant. Do not trim, reformat or normalize the actual dump to make it equal. The existing parser's defined authored-to-clean transformation is the only transformation on the expected side.

### Small, inspectable output

Write one Actual.as containing the whole library beside the actual run log, under HandwrittenCorpus/. The comparison tool writes Expected.as and Comparison.json in the same directory. Total: two aggregate .as files and one comparison report, not a file per version. C++ resolves the real absolute log filename (including ABSLOG) and writes raw bytes without BOM. The PowerShell driver uses the exact Harness run metadata/artifacts, never the latest directory or a guessed run ID.

Sort both aggregates by ordinal UTF-8 FileTag then VersionTag. Each section has a single-line JSON comment header naming both tags, parsed metadata/annotations and the decimal source byte length, followed by the exact source bytes and a fixed separator newline belonging to the dump framing. Implement the same documented framing independently in Python and C++; parse sections by byte length, not by searching for a sentinel that could occur inside source. Use the current grammar and JSON-escape header values; do not narrow valid tags to an invented ASCII identifier subset. These aggregates include independent and intentionally invalid programs and are inspection artifacts, not a single compilable AS module.

Comparison.json records the exact source snapshot fingerprints, Harness run identity and dump fingerprints; expected/actual file and version counts; missing, extra or duplicate identities; and per-difference FileTag, VersionTag, source byte offset, line and expected/actual byte lengths. Exact bytes are authoritative; hashes are supplementary. Retain both dumps on failure. Fail on missing/stale outputs, invalid framing, registration/query errors, count/set mismatch or any source-byte difference. Freeze writers during snapshot/build/run/comparison and reject a changed author/projection snapshot. Repeated runs use their own log directories and must not accept another run's dump.

### One acceptance operation

Task 7.3 owns a small repository-local current-process PowerShell driver and Python comparison helper. The driver captures the expected source snapshot, checks codegen synchronization, uses existing Harness ue.build for the selected workspace when needed, runs only the one dump method, resolves that run's artifacts and compares them. It imports Harness in the current process; it does not launch nested pwsh or call the UE executable directly. It fails unless the exact test actually executes and passes and the round-trip comparison succeeds. The expected snapshot is captured before execution and copied to the run's Expected.as afterwards; a failed launch leaves the expected snapshot and explicit failed evidence, never a passing report.

Use bounded negative controls while implementing the same aggregate proof: a missing version, an unexpected version and a changed source byte must each be rejected by the comparison helper; a missing actual dump must fail. These are temporary copied artifacts in an isolated verification directory, not new per-fixture Automation methods or edits to the real source corpus. Existing parser unit tests supply the clean-source parsing contract, including annotation stripping; the round-trip proves C++ projection/compilation/registration/source preservation, not parser correctness independent of that contract or AS language execution.

### Current tag and annotation compatibility

Use the current discovery, container_parser, annotation_parser and validation modules as the author grammar authority; do not implement a regex parser or legacy wrapper reader for round-trip expectations. FileTag comes from the author-root-relative path without .as, with normalized slash separators. The first Doxygen @version v1 is the container grammar version, not a source VersionTag. Later @version values name complete versions; @parent names their parent, @summary is required and repeated @topic lines describe file/version selection metadata. Preserve their exact identities and case; do not convert VersionTags to generator Entry names, uppercase them or replace punctuation. The C++ carrier's format=v2 is a separate structured projection version and must not replace author @version v1.

The same aggregate dump includes a single-line JSON comment header for each byte-length-framed source section. Encode header strings with JSON escaping (including Unicode and comment-sensitive characters), never an unescaped delimiter-joined key. Compare FileTag and VersionTag as a tuple, not one concatenated string. Parse headers as metadata and compare semantic fields, while comparing each source body by exact bytes. The dump framing is an inspection format, not a new v1 author-container grammar and must not be fed back through the container parser.

Compare file grammar version/summary/topics and version tag/parent/summary/topics within this same aggregate operation. Treat topics as ordinal sets; duplicates must follow the existing parser's validation, not be silently repaired by a second grammar. Preserve typed point, breakpoint and range annotations by name and clean-source UTF-8 byte coordinates, comparing the existing Python ParsedAnnotations with the C++ GetAnnotations view in the same header. No extra Automation methods are added. Existing adoption tests retain origin mapping coverage; do not invent path-independent authored origins in the dump.

Annotation handling follows /** @point name */, /** @breakpoint name */, /** @range-begin name */ and /** @range-end name */. Escaped /** @@point name */ emits literal /** @point name */ without a marker; do not remove it by searching for @ tokens. Use existing handling for escaped markers, nested ranges, Unicode and BOM/CRLF/CR normalization. Byte equality is against the parser's clean bytes, including its defined normalization, not unparsed raw author bytes. Preserve source bytes after that transformation with no second formatting pass. Keep the named source value alive before borrowing GetBytes/GetAnnotations views; the rvalue overloads are deliberately deleted.

Exercise metadata/annotation corruption as another temporary artifact control within the same comparison proof, alongside missing/extra versions and byte corruption. Current parser tests cover valid/invalid grammar and escapes; reuse them rather than adding a separate test for every fixture or tag spelling.
