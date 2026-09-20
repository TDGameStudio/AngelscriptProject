# Structured registration glossary

Source identity: accepted scoped glossary from `angelscript/test-framework-completion/designs/generated-structured-registration`, translated to English on 2026-09-14.

| Term | Chosen | Rejected | Reason |
|---|---|---|---|
| Change ID | `angelscript/refactor-test-code-structured-registration` | Reopening the archived carrier Change | This is a narrow structural successor to the existing checked-in carrier. |
| Author root | `AngelscriptTestCode/` | Per-module author roots | One path-derived FileTag namespace remains authoritative. |
| Tool root | `AngelscriptTestCode/CodeGenTool/` | Tool files in the public fixture inventory | The whole subtree is reserved and excluded from discovery. |
| Generated root | `Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/` | Windows resources or a separate aggregate root | Files compile into the owning test module and mirror authored paths. |
| Projection mapping | `<relative>.as → <relative>.generated.cpp` | Single aggregate or hash shards | One authored file, Git diff, translation unit and registration batch align. |
| File identity | root-relative extensionless `FileTag`, e.g. `Language/Counter` | handwritten SourceId or numeric ID | The authored path is the sole identity authority. |
| Fixture format | `Version` / file `@version v1` | `Format` | Version is the accepted metadata field and is distinct from a node tag. |
| Version identity | version header `@version root` or another Version Tag | implicit current/latest version | Every complete source version is directly addressable. |
| Source literal | `AS_TEST_SOURCE` | generated default `AS_TEST_SOURCE_EXACT` | Readable normalized source is the accepted generated appearance; exact remains a special handwritten escape hatch. |
| Registration | `FAngelscriptTestCodeRegistration` | generated aggregate or second registry | Generated and handwritten cross-module providers share the existing deferred registry. |
| Code builder | `FAngelscriptTestCodeBuilder` | History builder | It constructs a file's immutable Cases and validates its version tree; it does not execute reload history. |
| Source construction input | `FAngelscriptTestSourceDescriptor` | `FAngelscriptTestSourceData`, `FAngelscriptTestGeneratedSourceData`, Source-owned factory | Descriptor clearly names a temporary declaration consumed by Builder without coupling the API to Python generation. |
| Descriptor nested records | `FPoint`, `FBreakpoint`, `FRange`, `FOriginSpan`, `FAnnotations` under `FAngelscriptTestSourceDescriptor` | Five additional top-level framework names | Nesting keeps the public namespace focused while generated aggregate initialization remains readable. |
| Builder overloads | `AddRoot(VersionMeta, Source, Descriptor)` and `AddVersion(VersionMeta, Source, Descriptor)` | `FAngelscriptTestSource::FromGeneratedData` | Terminal `Build()` can accumulate descriptor and tree errors without a second Result bridge. |
| C++ container parser | `FAngelscriptTestSourceParser` | Removal or generated-path invocation | It remains an independent protocol capability but leaves the generated default path. |
| Annotation store | `FAngelscriptTestAnnotations` | One untyped Kind table | Existing Point, Breakpoint and Range queries remain distinct. |
| Origin compression | descriptor `FOriginSpan` plus `AuthoredEnd` | one generated `int32` per clean byte | Spans preserve readability; the separate endpoint preserves the existing `Num()+1` map contract. |
| Registration symbol | `GRegistration_<encoded FileTag>`, e.g. `GRegistration_Language_Counter` | anonymous namespace only or opaque hash suffix | Namespace-scope `static` and deterministic collision-checked encoding are Unity-safe and readable. |
| Generated carrier version | header `format=v2` | reusing authored `@version v1` | Generator format and fixture protocol are independent version domains. |
| Python parsed model | `ParsedFile`, `ParsedVersion`, `ParsedAnnotations`, `ParsedPoint`, `ParsedBreakpoint`, `ParsedRange`, `OriginSpan`, `CodegenDiagnostic` | renderer-owned loose dictionaries | Immutable typed IR prevents rendering and parsing responsibilities from mixing. |
| Python parse entry | `parse_source_file(SourceInput) -> ParsedFile` | parsing inside `render_projection` or `sync` | One explicit parser boundary is reusable by sync and conformance tests. |

Do not introduce `AS_ROOT`, a `Private` namespace, runtime current version, numeric resource IDs, a generated aggregate or a diagnostic expectation DSL in this Change.
