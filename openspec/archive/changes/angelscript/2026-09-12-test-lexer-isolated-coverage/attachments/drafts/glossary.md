# Glossary

Names below already exist in the repository or were settled in this draft. The first Change ID from this draft is lexer-only.

| Name | Status | Meaning |
|---|---|---|
| `TestSource` | existing | Parent authoring root of runner-neutral Bind observations, theme fixtures, and framework-owned Suite files |
| `Observe_*` | existing | Bind-file observation functions that return a host-readable result; they must not inherit `UAngelscriptTestSuite` |
| `UAngelscriptTestSuite` | existing | Native abstract base for reflected AS suites; lifecycle hooks only |
| `FAngelscriptTest` | existing | Fieldless AS facade for World/object spawn and latent commands on the active leaf |
| `FAngelscriptScriptTestRegistry` | existing | Immutable generation-tagged descriptors of marked suite methods |
| `FAngelscriptScriptTestRunner` | existing | Executes one discovered leaf against an Automation result sink |
| `FAngelscriptTestCode` | planned / historical | Planned sole public AS source center; historical worktree prototype registered inline C++ CaseKeys |
| TestCode two paths (Q20 A) | chosen | Handwritten `AS_TEST_SOURCE` and TestSource→generated `.cpp` share one owned source type; helpers live under `TestFramework/` |
| `TestFramework/Macro/` | chosen | Singular folder for test macros only (Q22) |
| `AngelscriptTestMacro.h` | chosen | Umbrella that includes the other macro headers; no logic |
| `AngelscriptTestSourceMacro.h` | chosen | `AS_TEST_SOURCE` / `AS_TEST_SOURCE_EXACT` only |
| `SourceId + VersionTag` | planned | Planned source reference; not implemented on main |
| `script-corpus` | historical workspace | `D:/Workspace/AngelscriptProject.worktree/script-corpus` — DataDriven + TestCode + ScriptCorpus prototypes |
| `AngelscriptTest` | existing | C++ test module under `Plugins/Angelscript/Source/AngelscriptTest`; the subject of this draft |
| `NewVersion` | rejected as future home | Active replacement test tree today; user does not want it as the later home |
| `TestFramework/` | settled (helpers only) | Shared harness/helpers for `AngelscriptTest`; not the home of product-area tests |
| `TestFramework/NativeEngine/` | settled | Shared NativeEngine helpers only |
| `NativeEngine/` (tests) | settled | NativeEngine SDK tests live in their own directory, not under TestFramework |
| Fixture / Fixtures | rejected | Not a layer, folder, or public type suffix; CQTest already uses fixture for TEST_CLASS instances |
| `*TestHelper.h` | chosen | Shared helper headers for other units: `LexTestHelper.h`, … (Q7). Exception below. |
| Lex, PP, AST, Sema, Identity, Builder, Lowering, SourceExec, VM, Surface | chosen | NativeEngine test unit names (Q6 A minus Image; Identity added Q15) |
| Identity helper themes | dropped as six headers | Themes still name the files; Q19 A: do not create six headers |
| CQTest private space | chosen (Q18 A) | Non-generic code lives in that `TEST_CLASS` `private:`; restore `public:` before hooks/methods; default no file-level namespace |
| anonymous namespace in AS tests | rejected | User: 不准使用匿名命名空间 |
| named test namespace | held for TEST_CLASS TUs | Q18: do not wrap `TEST_CLASS` in a namespace. Helper headers each get their own namespace (Q31). |
| per-helper namespace | chosen (Q31, Q33 A, Q35 A) | `{Unit}Test` uses the public TestDir token: `LexerTest` not `LexTest`; PP → `PreprocessorTest`. Header stems may stay `LexTestHelper.h` until renamed. |
| `LexerTest` | chosen (derived) | Namespace in the Lexer helper header. |
| `PreprocessorTest` | chosen (derived) | Namespace for the PP helper; also the intended public PP TestDir token. |
| `ASTTest` | chosen (derived) | Owns `FTestAST`. |
| `SemaTest` | chosen (derived) | Sema helper namespace. |
| `LanguageSurfaceTest` | chosen (derived) | Follows today’s public TestDir `LanguageSurface`, not inventory `Surface`. |
| `ModuleDefinitionSetTest` | chosen (derived) | Namespace for `ModuleDefinitionSetHelper.h` / `FModuleDefinitionSetHelper`. |
| Bindings helper namespaces | chosen (Q36 A) | Same `{Unit}Test` rule. Generic units take a prefix: `BindingsEngineTest`, `BindingsTypesTest`. Others stay short (`RecordTest`, `CallsTest`, …). |
| CQTest using | chosen (Q32 B) | Inside `TEST_CLASS` `private:`: `using ASTTest::FTestAST;`. Not file-scope `using namespace`. Not `using namespace` in the class (illegal). |
| `FTestAST` | chosen (Q29 A) | Clang-shaped parse-session helper for AST/Sema tests; construct-is-session. Not for Lex (Q30 A). Lives in `ASTTest`. Header still `ASTTestHelper.h`. |
| `FTestInputs` | name chosen (Q29 A); home held (Q34) | Clang-shaped source input name. Header/namespace wait for the later unified source framework. |
| `FTestLexer` | not named yet | Q30 A only settled the layer: Lex uses `FTestInputs` + a thin lex helper, not `FTestAST`. |
| `StableKeyTestHelper.h` | candidate only | Sole Identity helper if injecting `asSStableKey` is shared across files; not created yet |
| Image (test unit) | dropped | Product `asCMetadataImage` is BindInfo-only; not a NativeEngine test unit |
| ModuleDefinitionSet | chosen | Q6 slot that used to be Image; tracks `asCModuleDefinitionSet` (Q10; do not abbreviate to DefinitionSet) |
| `ModuleDefinitionSetHelper.h` | chosen | Shared helper header for that unit (Q10). Not `*TestHelper` and not `DefinitionSetTestHelper.h` |
| `FModuleDefinitionSetHelper` | chosen | Replaces `FDetachedDefinitionFixture` (Q11 A). Same stem as the header, UE `F` prefix |
| Recording, Types, Engine, Calls, Reflection, Containers, Values, Runtime, Coverage | chosen | Bindings test unit names (Q13 A); today's `RuntimeBindings.*` prefixes |
| `TestFramework/Bindings/{Unit}TestHelper.h` | chosen | Bindings shared headers (Q14 A): `RecordTestHelper.h`, `EngineTestHelper.h`, … |
| `Legacy` | existing quarantined | Old CQTest corpus behind `.ubtignore` and `WITH_ANGELSCRIPT_UNITTESTS=0` |
| `asCTokenizer` | existing | Pull lexer over a frozen snapshot range; `Lex(asCToken&)` |
| `asSLexOptions` | existing | Frozen Unicode + trivia policy; not read from `asCScriptEngine` |
| `asCIdentifierTable` | existing | Session intern; keyword kind + U* reflection spelling |
| `asEBuilderStage::Lexed` | existing | First Builder stage: pull-all tokens per file, RetainTrivia, AsciiOnly |
| NativeEngine TestDir nesting | chosen (Q23 A) | Public path `Angelscript.UnitTest.NativeEngine.<Unit>.*`; class = scenario group, like TypeOwnership. Not applied yet. |
| Lexer (public unit token) | chosen (Q24 A) | Automation segment `Angelscript.UnitTest.NativeEngine.Lexer`; not `Lex`. Applying it means renaming today's `TEST_CLASS Lexer`. |
| Lex kind matrix (“大部分”) | chosen (Q27 A) | Later: loop 107 non-empty `.def` spellings; keep 8 empty-spelling contract tests; extra maximal-munch pairs. Not implemented. |
| `angelscript/test-lexer-isolated-coverage` | chosen (Q37 A) | First Change from this draft. Isolated `asCTokenizer` tests + helper + kind matrix. Not TestCode. |
| `NativeEngine/Lexer/` | chosen (Q39 A) | Lexer test TUs at `AngelscriptTest/NativeEngine/Lexer/`, outside `NewVersion` and outside `TestFramework`. |
| `Contracts` | chosen (Q40 A) | `TEST_CLASS` for the existing 16 lexer contract methods. Public: `…NativeEngine.Lexer.Contracts.*`. |
| `SpelledKinds` | chosen (Q40 A) | `TEST_CLASS` for the 107-spelling matrix and maximal-munch pairs. Public: `…NativeEngine.Lexer.SpelledKinds.*`. |
| `CheckLex` | chosen (Q41 A) | Clang-shaped helper in `LexerTest`: source + expected kind sequence. |
| `FLexerSource` | chosen (Q41 A) | Snapshot wrapper moved into `LexerTest`; not renamed to `FTestLexer`. |
