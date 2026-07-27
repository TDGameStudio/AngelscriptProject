# Inline AngelScript source migration record

## Purpose and decision

Native SDK tests must show the exact AngelScript source that is compiled, and
ordinary inline source must remain readable as AngelScript rather than as an
opaque C++ string literal. The audit is therefore a source-quality gate, not
a cosmetic count: it protects generated-source review, diagnostic review, and
future fork/SDK regression investigation.

The selected approach is a checked mechanical migration followed by one
coherent build/test repair batch:

1. ordinary raw sources become local `ASTEST_AS_ANSI(R"AS(... )AS")` values
   with indented content, Allman braces, one statement per line, and a blank
   line between declarations;
2. APIs that already accept `std::string` receive that value directly;
3. APIs constrained to `const char*` keep the local `std::string` alive and
   receive `Source.c_str()` (or `Source.c_str(), Source.length()`);
4. the one `FString::Printf` source stays wide and uses `ASTEST_AS`, because
   its `%s` format contract is `TCHAR` based;
5. exact tokenizer input is catalogued by file, line, classification, byte
   layout, and reason. It is not reclassified as an ordinary source-format
   exception.

Changing support-layer signatures only to avoid `.c_str()` is out of scope:
the documented local adaptation is type-safe, scoped, and keeps the raw SDK
test support interface stable.

## Audited baseline

`AuditInlineAsFormatting.ps1` initially found 213 records: 101 conforming and
112 actionable findings across 192 raw-source blocks plus 21 escaped-newline
inputs. The 112 rows divide by actual host API rather than by a superficial
text pattern:

| Host API or source category | Rows | Migration rule |
| --- | ---: | --- |
| `FScopedNativeModule` | 65 | pass local `ASTEST_AS_ANSI` `std::string` directly; the constructor has a matching overload |
| `BuildNativeModule` | 10 | pass local `ASTEST_AS_ANSI` `std::string` directly |
| `CompileSnippet` | 10 | retain a local narrow source and pass `.c_str()` |
| `CompileNativeModule` | 5 | retain a local narrow source and pass `.c_str()` |
| local `BuildScriptClassModule` | 2 | retain a local narrow source and pass `.c_str()` |
| local `BuildContextModule` | 2 | retain a local narrow source and pass `.c_str()` |
| `AddBuilderSectionWithLog` | 11 | retain a local narrow source and pass `.c_str()` |
| direct `AddScriptSection` | 4 | retain a local narrow source and pass `.c_str()` plus exact length |
| exact frontend inputs | 3 | retain byte/offset semantics through a narrow, specifically recorded path |

The first eight rows total 109 mechanical source migrations: 108 normal
narrow sources and one wide `FString::Printf` source. The remaining three are
not blanket exclusions.

## Exact frontend input decisions

| Source | Required observation | Implementation and audit disposition |
| --- | --- | --- |
| `Frontend/AngelscriptNativeScriptNodeCopyTests.cpp` | A copied declaration must retain a nonzero source offset, not merely match an original offset that could be zero. | Keep one explicit leading LF with `std::string(1, '\n')`, use a normal indented `ASTEST_AS_ANSI` body for the declaration, and assert original `tokenPos > 0` before comparing the copy. This is ordinary formatted source, not an exception. |
| `Frontend/AngelscriptNativeTokenizerCoreTests.cpp` | The trailing LF and byte length `9` of `// hello\n` are the test input. | Keep the exact token input and register `ExactTokenizerInput` with its fixed byte layout. |
| `Frontend/AngelscriptNativeTokenizerWhitespaceTests.cpp` | The trailing LF and byte length `3` of `//\n` are the test input. | Keep the exact token input and register `ExactTokenizerInput` with its fixed byte layout. |

There are no current affected sources that assert an exact diagnostic line or
column and require `ASTEST_AS_ANSI_PRESERVE_LINES`. A future such source may
use that wrapper only with a matching `ExactLayoutSource` registration that
names its exact observed layout behavior.

## File batches

The host rows are kept as explicit implementation batches so each source API
and lifetime rule remains reviewable.

1. Direct `std::string` modules: CompilerCore, InterfaceSemantics,
   CallFunction, Constructors, ControlFlow, Conversions, Expressions,
   Functions, Operators, References, ModuleImport, ContextControl,
   DefaultTrait, EnumType, GlobalProperty, PrimitiveType, and VariableScope.
   This contains 65 `FScopedNativeModule` and 10 `BuildNativeModule` sites.
2. `const char*` compile helpers: ParserDiagnostic, SemanticRejection,
   Constructors, Inheritance, and ContextRecovery. The wide format source is
   `Language/AngelscriptNativeSemanticRejectionTests.cpp`.
3. Builder/direct-section callers: BuilderEditorOnly, BuilderLayout,
   BuilderLifecycle, ModuleNamespace, and ModuleSection.
4. Frontend exact-input sources above and the audit/catalog semantics.

The precise baseline file/line inventory is retained in
`audits/inline-as-baseline.csv`; every post-edit audit must reduce that file
to zero ordinary violations and two registered exact tokenizer inputs.

## Audit contract

`inline-source-exceptions.csv` is a narrow allow-list, not a way to suppress
ordinary source cleanup. The audit must accept a registration only when all
of these are true:

- exact `File` and `Line` match;
- classification is one of `ExactTokenizerInput` or `ExactLayoutSource`;
- `Reason` and `ExpectedLayout` are nonempty;
- an exact tokenizer registration corresponds to an escaped token input;
- an exact-layout registration corresponds to a preserve-lines wrapper.

An unwrapped ordinary source, an unregistered preserve-lines source, a
mismatched classification, or a broad record without a precise layout reason
remains a failure. Audit output distinguishes `Conforming`,
`RegisteredExactInput`, and `MustReformatOrRegister` so review cannot mistake
a documented byte-sensitive input for an ordinary source style waiver.

## Verification sequence

After all ordinary source edits and the ScriptNodeCopy assertion are in place,
run one coherent `Tools/RunBuild.ps1` batch. Repair any compile error before
running the affected focused prefixes: Frontend, Compiler, Module, and the
specified Language/Runtime owners. Then update the two exact tokenizer
registrations and audit implementation, run `AuditInlineAsFormatting.ps1
-RequireClean`, and finally rerun catalog/reconciliation/API/boundary audits.

The records must retain the baseline count, classification decisions, source
host constraints, exact exception rows, build/test commands, and any source
or compiler issue found during the single repair cycle.
