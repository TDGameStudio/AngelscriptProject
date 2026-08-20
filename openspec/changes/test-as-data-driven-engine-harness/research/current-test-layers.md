# Current Angelscript test layers vs this harness

## Pain this change targets

Typical CQTest method (see `Template/Template_CQTest.cpp` and `AngelscriptTypedASTJITScriptFunctionCorpusTests.cpp`):

1. `BEFORE_ALL` → `ASTEST_CREATE_ENGINE()` (shared singleton + `ResetModules`)
2. `TEST_METHOD` inlines `ASTEST_AS(R"AS(... )AS")`
3. `FScopedAngelscriptModule` compiles that string
4. `ExpectGlobalInt` asserts one VM path

To also prove Cache V2, typed-ast generation, or Runtime JIT, authors copy the same string into another method and build a different engine. `AngelscriptTypedASTJITScriptFunctionCorpusTests.cpp` inlines AS **and** writes it to a fake `Script/` root because generation needs disk identity. After this change, Layer 1 is the AS corpus and Layer 2 is derived StaticJIT C++ (`research/static-jit-from-test-corpus.md`).

## Layers that stay

| Need | Keep using |
|---|---|
| Bind entry contract | CQTest `Bindings/` |
| World / Actor | CQTest + `FAngelscriptTestWorld` (MAY load TestCorpus by virtual path) |
| HotReload | Existing CQTest + sibling `test-as-hotreload-script-corpus` (pair files, `HotReload.Corpus` COMPLEX analyze leaves). Not a DataDriven engine profile. |
| Debugger DAP | `Debugger/` session helpers |
| Pure SDK | `AngelScriptSDK/` + native engine |
| Product-facing script tests with `Assert*` and optional World | `UAngelscriptTestSuite` under host `Script/Tests/` (`test-as-script-corpus-and-functional-coverage`) |

## Engine lifecycle already specified

`test-engine-lifecycle`:

- `GetSharedEngine()` long-lived Full engine
- `ResetModules()` discards modules, keeps binds
- `Create()` isolated engine

The harness does not change those APIs. It only lets a JSON case choose which one to call.

## Virtual paths already specified

`as-virtual-script-paths`:

- Project disk → `/Angelscript/Game/<logical>`
- Memory → `/Angelscript/Memory/<Provider>/`

v1 mounts:

- memory cases → `/Angelscript/Memory/TestCorpus/...`
- disk cases → isolated engine whose project dir is a temp or fixture-owned script root, so the host `Script/` tree is not compiled

Authored files are also a **Shared lookup database** (`FAngelscriptTestScriptCorpus`, Decision 16). Any CQTest / World test MAY `TryGetByVirtualPath("/Angelscript/Memory/TestCorpus/Syntax/OptionalEmpty.as")` and compile that source itself. Catalogs and the COMPLEX harness are consumers of that API, not the only door. Host `Script/` (`/Angelscript/Game/...`) stays the teaching / `UAngelscriptTestSuite` tree and is not served by this lookup.

Existing `FAngelscriptTestFixture` is an engine RAII helper, not this database. Debugger inline fixtures (`FAngelscriptDebuggerScriptFixture`) may move into `Fixtures/Debugger/` later.

## Sibling OpenSpec

`test-as-script-corpus-and-functional-coverage` expands host `Script/<Theme>/` examples and `Script/Tests/<Theme>/` reflected suites. It explicitly excluded StaticJIT/cache matrices. This harness is the missing configuration-matrix layer; it does not author that teaching corpus.

What else still has inline AS, and which of those deserve a later corpus/COMPLEX: `research/test-authoring-refactor-backlog.md`. Short version: **Syntax** and **Debugger** next; Functional World loads corpus without a new COMPLEX; Bindings/SDK/Compiler/Preprocessor/Dump/Editor tests stay.

Author routing (question first, folder second): `openspec/changes/docs-as-test-direction-map/`. This harness is direction `same-as-profile`. Syntax extraction is `surface-form`. HotReload pairs are `reload-generation`. Host `Script/` is `world-story`. Packager/Provider/factory CQTest is `host-machinery`.
