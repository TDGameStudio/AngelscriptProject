# Generated C++ Test Source Carrier

Source identity: faithful English export of the approved `angelscript/test-framework-completion` scoped design `generated-cpp-carrier`, approved by the user on 2026-09-14. The local brainstorming original remains the provenance record.

## Goal

Keep `.as` files as the only authored source without running directory discovery or Windows resource generation during every UBT invocation. Authors explicitly run Python `generate` and commit deterministic C++ projections; ordinary builds only compile those projections. A read-only `check` mode detects forgotten synchronization.

## Existing foundation

- `FAngelscriptTestCodeRegistration` accepts ordinary function pointers and captureless lambdas and has cross-DLL coverage in `AngelscriptTestJIT`.
- `FAngelscriptTestSourceParser::Parse(FileTag, Bytes)` constructs metadata, annotations, origin maps, and a build result from raw container bytes.
- The database activates ordinary registration records as independent admission batches.
- Source, Builder, Parser, Case, Result, query, and activation behavior do not depend on the byte carrier and remain unchanged.

## Data flow

```text
AngelscriptTestCode/**/*.as
└─ Python generate: deterministic discovery, raw-byte read, one projection per file
   └─ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/**/<name>.generated.cpp
      ├─ static constexpr uint8[]
      ├─ FileTag, authored source path, byte length, and SHA-256
      └─ FAngelscriptTestCodeRegistration
         └─ activation calls FAngelscriptTestSourceParser::Parse(Tag, Bytes)
            └─ existing Builder, admission, and query center

handwritten C++ provider
└─ FAngelscriptTestCodeRegistration + AS_TEST_SOURCE
   └─ the same activation snapshot and query center
```

## Python boundary

Python shall:

- recursively discover lower-case `.as` files under the single author root;
- reserve and entirely exclude `AngelscriptTestCode/CodeGenTool/` from authored fixture discovery;
- derive forward-slash author-relative paths and extensionless FileTags;
- sort sources by ordinal normalized path;
- read bytes unchanged and emit an unambiguous C++ `uint8` array;
- emit the generator format signature, relative source path, byte length, and SHA-256;
- produce deterministic UTF-8/LF output;
- discover, validate, and render all expected outputs before the first mutation;
- atomically replace changed files and avoid rewriting equal files;
- provide a read-only `check` that returns non-zero for missing, changed, or stale projections.

Python shall not:

- compile AngelScript;
- interpret version bodies as diffs;
- reproduce annotation clean-offset or origin-map rules;
- generate per-version Builder calls as the carrier protocol;
- run implicitly from ordinary UBT;
- import history, recipe, oracle, or diagnostics semantics from `TestSource-old`.

## Directory and projection shape

One `.as` maps to one mirrored `.generated.cpp`:

```text
AngelscriptTestCode/                       Plugins/Angelscript/Source/AngelscriptTest/
├─ Language/Counter.as              ───►  TestCode/Generated/
├─ Diagnostics/MissingCall.as       ───►  ├─ Language/Counter.generated.cpp
└─ Reload/Actor.as                  ───►  ├─ Diagnostics/MissingCall.generated.cpp
                                            └─ Reload/Actor.generated.cpp
```

Removing the generated root and `.generated.cpp` suffix reconstructs the authored relative path after restoring `.as`. The FileTag is the authored relative path without `.as`, for example `Language/Counter`.

- Author root: repository-root `AngelscriptTestCode/`.
- Tool root: `AngelscriptTestCode/CodeGenTool/`; never a FileTag namespace.
- Generated root: `Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/`.

The generated root is inside the `AngelscriptTest` module and its `.cpp` files link into that DLL. The generator creates absent directories; ordinary builds never generate projections.

## Modular tool

```text
AngelscriptTestCode/
├─ CodeGenTool/
│  ├─ codegen.py
│  ├─ angelscript_test_codegen/
│  │  ├─ __init__.py
│  │  ├─ cli.py
│  │  ├─ model.py
│  │  ├─ paths.py
│  │  ├─ discovery.py
│  │  ├─ cpp_renderer.py
│  │  └─ sync.py
│  └─ tests/
│     ├─ test_cli.py
│     ├─ test_paths.py
│     ├─ test_discovery.py
│     ├─ test_cpp_renderer.py
│     ├─ test_sync.py
│     └─ fixtures/
└─ Language/Counter.as
```

Dependencies remain one-way:

```text
codegen.py
└─ angelscript_test_codegen.cli
   ├─ paths
   └─ sync
      ├─ discovery -> paths + model
      ├─ cpp_renderer -> model
      ├─ paths
      └─ model
```

`model.py` and `paths.py` do not import higher layers. `cpp_renderer.py` is filesystem-free, `discovery.py` never mutates outputs, and `cli.py` contains no generation algorithm. `sync.build_sync_plan()` is the sole computation consumed by both `check` and `generate`.

The tool locates the repository from `__file__`, not the caller's current directory. Tests inject temporary author and generated roots. The standard test entry is:

```text
python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_*.py"
```

## Generated translation unit

Each file contains one fixture's raw bytes and one static registration. The conceptual shape is:

```cpp
// Generated. Edit AngelscriptTestCode/**/*.as and run the generator.
namespace AngelscriptTest::Generated
{
static constexpr uint8 GSource_0123[] = {0x2f, 0x2a, 0x2a, /* ... */};

static FAngelscriptTestCodeBuildResult BuildSource_0123(
    const FAngelscriptTestFileMeta& FileMeta)
{
    return FAngelscriptTestSourceParser::Parse(
        FileMeta.Tag, MakeArrayView(GSource_0123));
}

static FAngelscriptTestCodeRegistration GRegistration_0123(
    {.Tag = TEXT("Language/Counter")},
    &BuildSource_0123);
}
```

A generated translation unit does not split versions. A multi-node container still produces one projection; the existing C++ parser owns the version tree. Static initialization records a factory and does not parse source. The existing one-shot activation barrier later runs all factories, and each ordinary registration remains an independent admission batch.

No runtime aggregate or generated index is required. Static registration supplies runtime discovery; Python only computes the expected output set for synchronization.

All internal C++ identifiers carry a stable FileTag digest suffix so multiple generated files remain safe when UBT Unity Build combines translation units. The digest must be stable and never use Python `hash()`.

The registration retains the authored relative `.as` source identity. Parser-originated source lines and byte offsets must not be replaced by the generated C++ registration location.

## Layout decision

| Layout | Source-set behavior | Consequence | Decision |
|---|---|---|---|
| One aggregate file | Stable one-file set, but every edit recompiles all bytes | Poor one-to-one review and incremental scaling | Rejected |
| One file per `.as` | Mirrored and reversible; add/delete changes the C++ source set | Generator must manage stale outputs safely | Selected |
| Fixed hash shards | Stable shard set | Adds hash, count, balance, and migration policy without evidence | Deferred |

Per-source output keeps author input, Git diff, compiled projection, registration, and admission batch aligned. Reconsider fixed shards only when measured UBT or link cost proves the translation-unit count is material.

## Synchronization contract

```text
python AngelscriptTestCode/CodeGenTool/codegen.py generate
python AngelscriptTestCode/CodeGenTool/codegen.py check
Harness ue.build  // consumes checked-in generated C++; never invokes Python
Harness ue.test   // proves activation, query, and fixture-byte behavior
```

`generate` is the only writer. It computes the entire plan first, atomically replaces added or changed outputs, preserves equal-file timestamps, and deletes stale files only after writes succeed. A stale candidate is deletable only when it is beneath the exact generated root, has the `.generated.cpp` suffix, and contains this generator's format signature. Any other extra file is preserved and reported.

`check` uses the same plan and renderer, performs no writes or directory creation, and returns failure for drift. It belongs in fixed relevant Harness/CI verification, but not ordinary UBT and not an automatically installed Git hook.

Output contains no absolute workspace path, timestamp, locale-dependent serialization, or process-random value.

## Migration

- Remove the TestCode resource generator and sentinel logic from `AngelscriptTest.Build.cs`.
- Remove the RC input and resource-specific runtime provider.
- Add per-source generated registration translation units.
- Replace resource probes and incremental-resource tests with projection, no-op, stale, byte-parity, admission, and query coverage.
- Change the current durable Windows-resource requirement to checked-in generated C++ delivery.
- Update test-code author guidance to state that ordinary builds do not synchronize fixtures.
- Retain Source, Parser, Builder, Database, Registration, Adoption coverage, and `Counter.as`.

The RCDATA and generated carriers do not coexist. Handwritten registration and `AS_TEST_SOURCE` are retained because they are a distinct provider path.

## Verification direction

- Python `unittest`: sorting, `CodeGenTool` exclusion, arbitrary bytes, collisions, deterministic output, no-op timestamps, atomic replace, and missing/changed/stale state.
- Golden projection: identical bytes produce identical output; edit/add/rename/delete produce only the expected plan.
- Fresh Harness editor build and focused Framework tests: generated bytes pass through the C++ parser and preserve the authored fixture.
- Cross-module adoption: generated `AngelscriptTest` and handwritten `AngelscriptTestJIT` registrations share one database.
- Removal proof: current Build.cs no longer scans `AngelscriptTestCode` and the binary no longer requires `AS_TEST_INDEX` RCDATA.

