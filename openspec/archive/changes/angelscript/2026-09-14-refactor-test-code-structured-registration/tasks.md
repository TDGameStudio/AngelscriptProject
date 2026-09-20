---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": []
    "3.1": ["1.2", "2.1"]
    "3.2": ["3.1"]
    "4.1": ["1.2"]
    "4.2": ["3.2", "4.1"]
---

# Generate structured AngelScript test-code registrations

## Goal

Replace activation-time parsing of opaque generated test containers with Python-parsed, readable, structured registrations while retaining an independent conforming C++ parser.

## Architecture

The root CodeGenTool parses the v1 fixture protocol into immutable clean-byte IR before rendering one mirrored v2 generated translation unit per `.as`. The `Plugins/Angelscript` framework admits typed `FAngelscriptTestSourceDescriptor` data through Builder overloads and publishes immutable Cases through the existing registration/database activation path. See [design.md](design.md) and [the accepted handoff](attachments/drafts/handoff.md).

## Global constraints

- Before any product task starts, `angelscript/refactor-testing-unified-framework` must be updated/replanned through its own lifecycle so source-history/diff, byte-shard, aggregate release and overlapping TestCode files no longer claim this scope. Derived Ready state does not waive this prerequisite.
- Preserve unrelated workspace changes. Root Python/authored fixture edits belong to the parent repository; C++ framework/generated edits land in the `Plugins/Angelscript` submodule before a later parent gitlink update.
- Python validates only fixture protocol. Intentionally invalid AngelScript remains admissible, and no generation/registration result is execution evidence.
- Generated production code never invokes `FAngelscriptTestSourceParser`, emits per-byte source/origin arrays, restores Windows resources, or runs Python from ordinary UBT.
- New public C++ names come from `attachments/drafts/glossary.md`; new package-internal Python names follow the same design vocabulary and are listed in their producing task.
- C++ RED/GREEN uses a fresh Harness Editor build before the focused Automation selector. Python tasks use the repository interpreter and standard-library unittest only.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement or acceptance condition | Tasks |
|---|---|
| Checked material construction rejects invalid descriptors without partial Cases and accepts invalid AngelScript bodies | 1.1, 2.1, 4.2 |
| Checked-in structured projection parses before mutation and emits readable real metadata/source/annotations/origin | 1.1, 1.2, 3.1, 3.2 |
| Explicit check/generate, one mirrored projection, safe v1-to-v2 sync and no ordinary-UBT Python | 3.2 |
| Independent Python/C++ v1 protocol semantics and stable negative codes | 4.1 |
| Central activation, one FileMeta truth, exact queries and handwritten cross-module provider compatibility | 4.2 |
| Public names, byte/origin model and forbidden architecture from the accepted handoff | 2.1, 3.1, 4.2 |

Self-review 2026-09-14: coverage complete; placeholders none; symbols consistent with `design.md` and `attachments/drafts/glossary.md`. Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Parse v1 file metadata and complete version topology into immutable IR

Add a byte-coordinate Python fixture parser over the existing `SourceInput`. It recognizes the file header, complete version headers/bodies and explicit `/** @end */` boundaries, normalizes transport bytes, accumulates independently reliable protocol diagnostics and leaves AngelScript bodies uninterpreted.

**Outcome**

`parse_source_file` returns immutable `ParsedFile`/`ParsedVersion` values with real FileMeta, complete body bytes, authored body coordinates and validated root/parent topology. UTF-8/BOM/newline and metadata/topology failures carry stable structured diagnostics. Excluded: annotation marker removal, C++ rendering and AngelScript language parsing.

**Interfaces**

Consumes (existing, `AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/model.py:14`, `discovery.py:25`):

```python
@dataclass(frozen=True)
class SourceInput:
    full_path: Path
    relative_path: str
    file_tag: str
    output_relative_path: str
    content: bytes
    content_sha256: str
    symbol_suffix: str

def discover_sources(author_root: Path) -> tuple[SourceInput, ...]: ...
```

Produces (package-internal names derived from the accepted design vocabulary):

```python
@dataclass(frozen=True)
class CodegenDiagnostic:
    code: str
    source_path: str
    line: int
    byte_offset: int
    version_tag: str | None
    message: str

@dataclass(frozen=True)
class ParsedVersion:
    tag: str
    parent: str | None
    summary: str
    topics: tuple[str, ...]
    body: bytes
    authored_body_line: int
    authored_body_offset: int

@dataclass(frozen=True)
class ParsedFile:
    source: SourceInput
    format_version: str
    summary: str
    topics: tuple[str, ...]
    versions: tuple[ParsedVersion, ...]

def parse_source_file(source: SourceInput) -> ParsedFile: ...
```

`CodegenError` remains the pipeline exception and owns one or more `CodegenDiagnostic` values for parser failure.

**Cases**

1. **Counter metadata and branch** — new RED
   Given the current `Language/Counter.as` bytes When parsed Then FileTag is path-derived `Language/Counter`, format is `v1`, real Summary/Topics are retained, `root` has no Parent, `add-step` has Parent `root`, and both bodies are complete LF bytes ending at their explicit `@end`.
2. **Invalid AngelScript remains material** — new RED
   Given valid fixture headers around `int Value = Missing;` When parsed Then parsing succeeds with those exact body bytes and no language diagnostic.
3. **Transport normalization** — new RED
   Given an optional UTF-8 BOM, CRLF file metadata, a CR version header and Unicode body text When parsed Then directives and line locations are correct and the stored body uses canonical UTF-8/LF bytes.
4. **Independent metadata failures accumulate** — new RED
   Given one version with empty Summary and a separately duplicated Version Tag When parsed Then both stable reasons are reported and no `ParsedFile` is returned; a dependent parent-cycle cascade is not fabricated from the ambiguous tag.
5. **Topology is checked as a complete set** — new RED · sequence
   1. A child that names a later declared Parent → success after whole-file validation.
   2. A child that names no declared Parent → `MissingParent` failure.
   3. Two versions that form a cycle → `VersionCycle` failure.
   4. Missing or multiple roots → root-structure failure with no partial IR.
6. **Discovery identity remains path-owned** — existing control
   Given `Language/Counter.as` under the author root When discovery runs Then output remains `Language/Counter.generated.cpp` and no header Tag is required.

**Files**

```diff
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/model.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/text_normalization.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/container_parser.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/validation.py
+AngelscriptTestCode/CodeGenTool/tests/test_source_parser.py
+AngelscriptTestCode/CodeGenTool/tests/fixtures/source_parser/
```

The fixture directory is under the already excluded CodeGenTool subtree and cannot create public FileTags.

**Verification**

Run from the workspace root. All six named groups execute; the new parser cases are observed RED before implementation and GREEN afterwards, while the discovery control remains GREEN.

```powershell
python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_source_parser.py"
```

**Evidence**

Command: `python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_source_parser.py"`. RED: 5 new cases failed on empty stub IR / missing `CodegenError`; discovery control stayed GREEN. GREEN: 6/6 discovered and passed in 0.004s. Adjacent CodeGenTool suite: 19/19 passed.

## [x] 1.2 Strip typed annotations and build compact authored-origin projections

Extend parsed versions with clean bytes, separate Point/Breakpoint/Range tables, contiguous authored-origin spans and an explicit clean-end mapping. Annotation parsing operates on fixture bytes without requiring a valid AngelScript token stream.

**Outcome**

Every valid version carries clean UTF-8 bytes, typed unique annotations, gap-free clean-coordinate origin spans and `AuthoredEnd`. Marker syntax and topology errors are structured protocol failures. Excluded: LSP position conversion, debugger binding and diagnostic expectations.

**Interfaces**

Consumes (produced by 1.1):

```python
class ParsedVersion: ...
class CodegenDiagnostic: ...
```

Produces (package-internal names derived from the accepted design vocabulary):

```python
@dataclass(frozen=True)
class ParsedPoint: name: str; offset: int
@dataclass(frozen=True)
class ParsedBreakpoint: name: str; offset: int
@dataclass(frozen=True)
class ParsedRange: name: str; begin: int; end: int
@dataclass(frozen=True)
class OriginSpan: clean_begin: int; authored_begin: int; length: int
@dataclass(frozen=True)
class ParsedAnnotations:
    points: tuple[ParsedPoint, ...]
    breakpoints: tuple[ParsedBreakpoint, ...]
    ranges: tuple[ParsedRange, ...]

class ParsedVersion:
    clean_source: bytes
    annotations: ParsedAnnotations
    origin_spans: tuple[OriginSpan, ...]
    authored_end: int

def parse_annotations(version: ParsedVersion) -> ParsedVersion: ...
```

**Cases**

1. **Typed clean-byte coordinates** — new RED
   Given UTF-8 source containing `/** @point initial-value */`, `/** @breakpoint before-add */` and `/** @range-begin delta */1/** @range-end delta */` When annotations are stripped Then clean bytes contain no markers and coordinates are Point `32`, Breakpoint `66`, Range `[75,76)`.
2. **Nested ranges and cross-kind names** — new RED
   Given properly nested outer/inner ranges plus a Point and Breakpoint that reuse `site` When parsed Then both half-open ranges and both cross-kind `site` entries are retained independently.
3. **Escaped marker remains source** — new RED
   Given `/** @@point cursor */` When parsed Then clean bytes contain literal `/** @point cursor */` and no Point named `cursor` exists.
4. **Malformed annotation set fails structurally** — new RED · sequence
   1. Duplicate Point name → `DuplicatePoint`.
   2. Range end without begin → `MissingRangeBegin`.
   3. Unclosed begin → `MissingRangeEnd`.
   4. Crossing named ranges → `CrossingRange`.
5. **Terminal removed marker preserves EOF** — new RED
   Given body `ab/** @point eof */` ending at authored offset `40` When stripped Then clean source is `ab`, Point `eof` is `2`, spans map bytes `a` and `b`, and `AuthoredEnd` maps clean offset `2` to authored offset `40` rather than inferring `2` from the last span.
6. **Newline discontinuities retain original bytes** — boundary
   Given BOM and CRLF around a Unicode body and annotations When parsed Then clean coordinates count UTF-8 bytes, authored span coordinates refer to raw pre-normalization bytes, and every clean offset including `Num()` maps in bounds.

**Files**

```diff
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/model.py
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/text_normalization.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/annotation_parser.py
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/container_parser.py
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/validation.py
+AngelscriptTestCode/CodeGenTool/tests/test_annotations.py
+AngelscriptTestCode/CodeGenTool/tests/fixtures/annotations/
```

**Verification**

Run from the workspace root. Cases 1-5 are observed RED together and GREEN together; the boundary case proves byte/origin invariants for every coordinate.

```powershell
python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_annotations.py"
```

**Evidence**

Command: `python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_annotations.py"`. RED: 6/6 new cases failed on empty `clean_source` / missing `CodegenError`. GREEN: 6/6 discovered and passed. Task 1.1 parser tests remain 6/6 GREEN. Naming assumed: `authored_offsets` — body-local raw file offsets including EOF, required to compress origin spans after marker removal.

## [x] 2.1 Admit `FAngelscriptTestSourceDescriptor` through Builder overloads

Add the accepted public construction descriptor and overload the existing Builder methods without weakening immutable Source internals or changing existing two-argument callers. Builder validates descriptor data and folds every reliable error into terminal `Build()`.

**Outcome**

Valid descriptors produce Sources with exact clean bytes, typed annotation queries and complete `Num()+1` origin mapping that outlive temporary descriptor storage. Invalid offsets, ranges, spans or end anchors reject the complete Build result without a partial Case. Existing exact/normalized Source and invalid-language controls remain successful.

**Interfaces**

Consumes (existing, `AngelscriptTestSource.h:13,34`, `AngelscriptTestAnnotations.h:17`, `AngelscriptTestSourceOriginMap.h:8`, `AngelscriptTestCodeBuilder.h:11,19-20`):

```cpp
class FAngelscriptTestSource;
class FAngelscriptTestAnnotations;
class FAngelscriptTestSourceOriginMap;
void FAngelscriptTestCodeBuilder::AddRoot(FAngelscriptTestVersionMeta, FAngelscriptTestSource);
void FAngelscriptTestCodeBuilder::AddVersion(FAngelscriptTestVersionMeta, FAngelscriptTestSource);
FAngelscriptTestCodeBuildResult FAngelscriptTestCodeBuilder::Build();
```

Produces (public names from `attachments/drafts/glossary.md`):

```cpp
struct ANGELSCRIPTTEST_API FAngelscriptTestSourceDescriptor
{
    struct FPoint { FString Name; int32 Offset = 0; };
    struct FBreakpoint { FString Name; int32 Offset = 0; };
    struct FRange { FString Name; int32 Begin = 0; int32 End = 0; };
    struct FOriginSpan { int32 CleanBegin = 0; int32 AuthoredBegin = 0; int32 Length = 0; };
    struct FAnnotations
    {
        TArray<FPoint> Points;
        TArray<FBreakpoint> Breakpoints;
        TArray<FRange> Ranges;
    };

    FString AuthoredPath;
    int32 AuthoredLine = 0;
    int32 AuthoredEnd = 0;
    FAnnotations Annotations;
    TArray<FOriginSpan> OriginSpans;
};

void FAngelscriptTestCodeBuilder::AddRoot(
    FAngelscriptTestVersionMeta, FAngelscriptTestSource, FAngelscriptTestSourceDescriptor);
void FAngelscriptTestCodeBuilder::AddVersion(
    FAngelscriptTestVersionMeta, FAngelscriptTestSource, FAngelscriptTestSourceDescriptor);
```

**Cases**

1. **Valid descriptor becomes immutable Source** — new RED
   Given clean `aβb` bytes, one Point, one Breakpoint, one Range, discontinuous origin spans and explicit `AuthoredEnd` When added and built Then getters return exact clean UTF-8 byte offsets and `MapToOriginalByteOffset` returns the expected authored byte for every offset `0..Num()`.
2. **Temporary descriptor lifetime ends safely** — new RED
   Given descriptor strings and arrays destroyed after `AddRoot` When the built Case and Source are retained Then metadata, annotations and origin mappings remain valid and unchanged.
3. **Independent descriptor errors accumulate** — new RED
   Given a Point beyond clean `Num()` and a separately incomplete origin coverage When `Build()` finalizes Then both stable structural reasons are present and no Cases are admissible.
4. **Range and span boundaries reject ambiguity** — new RED · sequence
   1. Range Begin greater than End → failure.
   2. Range End beyond clean `Num()` → failure.
   3. Zero/negative, overlapping or gapped spans → failure.
   4. `AuthoredEnd` outside authored bounds or inconsistent with a continuous final mapping → failure.
5. **Existing Builder call remains valid** — existing control
   Given the current two-argument `AddRoot(..., AS_TEST_SOURCE_EXACT("ok"))` When built Then it succeeds with empty annotations and the existing literal host origin.
6. **Invalid AngelScript remains valid Source** — existing control
   Given `int X=Missing;` with a structurally valid descriptor When built Then construction succeeds without compiling AngelScript.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceDescriptor.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSource.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSource.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestAnnotations.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceOriginMap.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestCodeBuilder.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestCodeBuilder.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/BuilderTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/SourceTests.cpp
```

Header-only aggregate records need no separate `.cpp`; validation and ownership remain in Source/Builder implementation.

**Verification**

Run from the workspace root after importing Harness. The Editor build must contain the new RED/GREEN tests; then the exact Builder class prefix passes all six cases.

```powershell
& {
    Import-Module ./.agents/skills/harness/scripts/Harness.psd1
    $context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
    Invoke-Harness -Command workspace.activate -Context $context | Out-Null
    $build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'structured-source-descriptor-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }
    if ($build.status -ne 'Succeeded') { throw 'Structured Source descriptor Editor build failed.' }
    $tests = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Builder'; Label = 'structured-source-descriptor-tests'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }
    if ($tests.status -ne 'Succeeded') { throw 'Structured Source descriptor tests failed.' }
    $tests
}
```

**Evidence**

Command: the task Verification block. RED run `609056bb737749dc85305f0775417814`: 4 new cases failed (`ValidDescriptorBecomesImmutableSource`, `TemporaryDescriptorLifetimeEndsSafely`, `IndependentDescriptorErrorsAccumulate`, `RangeAndSpanBoundariesRejectAmbiguity`); controls `ExistingTwoArgumentAddRootRemainsValid` and `InvalidAngelScriptRemainsValidSource` stayed GREEN. GREEN run `5065798c91454ae785e00061233fa53c`: Builder prefix 11/11 succeeded. Naming assumed: `InvalidAnnotationOffset`, `InvalidSourceRange`, `InvalidOriginSpan`, `IncompleteOriginCoverage`, `InvalidAuthoredEnd` — Builder-owned structural codes matching existing `Invalid*` / coverage style.

## [x] 3.1 Render readable structured v2 registration translation units

Replace raw-byte rendering with pure ParsedFile rendering. Emit one real FileMeta registration, one direct captureless Builder lambda, complete version metadata, normalized source literals, typed descriptors and deterministic human-readable symbols.

**Outcome**

`render_projection` produces UTF-8/LF structured format-v2 C++ with no raw container array, parser include/call, named build helper, anonymous namespace, opaque symbol hash, absolute path or timestamp. Its literal normalization model is byte-identical to `AS_TEST_SOURCE`, including terminal LF.

**Interfaces**

Consumes (existing `cpp_renderer.py:36`, produced by 1.1/1.2 and 2.1):

```python
def render_projection(source: SourceInput) -> bytes: ...
class ParsedFile: ...
class ParsedVersion: ...
```

```cpp
struct FAngelscriptTestSourceDescriptor;
void FAngelscriptTestCodeBuilder::AddRoot(VersionMeta, Source, Descriptor);
void FAngelscriptTestCodeBuilder::AddVersion(VersionMeta, Source, Descriptor);
```

Produces (existing function with changed internal input contract; generated symbol rule from the glossary):

```python
GENERATOR_SIGNATURE = "// @generated by AngelscriptTestCode/CodeGenTool format=v2"
def render_projection(source: ParsedFile) -> bytes: ...
```

Generated C++ symbol form:

```cpp
namespace AngelscriptTest::Generated
{
static FAngelscriptTestCodeRegistration GRegistration_Language_Counter(...);
}
```

**Cases**

1. **Counter readable golden** — new RED · golden
   Input: `tests/fixtures/renderer/Language/Counter.as`. Expected: `tests/fixtures/renderer/Language/Counter.generated.cpp`. Compare bytes exactly as UTF-8/LF. Regenerate the golden only when this task intentionally changes format v2.
2. **Annotations and origin are typed** — new RED
   Given Point `initial-value=32`, Breakpoint `before-add=66`, Range `delta=[75,76)`, two origin spans and `AuthoredEnd` When rendered Then all values appear under `FAngelscriptTestSourceDescriptor` aggregate fields beside their version and no per-byte origin array exists.
3. **Macro normalization preserves bytes** — new RED · example-table
   Template: Given clean bytes `<clean>` When rendered into the canonical literal and modeled through `AS_TEST_SOURCE` normalization Then the recovered bytes equal `<clean>` exactly.

   | clean | deciding boundary |
   |---|---|
   | `class A {}\n` | terminal LF survives delimiter-margin removal |
   | `\nclass A {}\n\n` | intentional leading/trailing blank lines survive |
   | `\tclass A {}\n` | common tab prefix is not converted to spaces |
   | `class Å { string S = " )\" text"; }\n` | UTF-8 and delimiter-like content remain exact |
4. **Readable symbols are deterministic and collision-checked** — new RED
   Given `Language/Counter`, `A/Same`, `B/Same` and paths whose punctuation would collide under simple underscore replacement When symbol names are planned Then ordinary names are readable, unusual bytes use reversible encoding, all names are stable, and an actual final collision fails before rendering output.
5. **Runtime parser path is absent** — new RED · absence
   Must not exist in the Counter golden: `constexpr uint8 GSource`, `FAngelscriptTestSourceParser`, `BuildCounter`, `namespace {`, `GRegistration_427f18f4cff8`. Oracle: exact golden plus explicit substring assertions.
6. **Provenance remains content-bound** — existing control
   Given the same ParsedFile rendered twice When outputs are compared Then bytes match and the header contains relative source, raw length and SHA-256 but no workspace path or timestamp.

**Files**

```diff
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/model.py
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/cpp_renderer.py
 AngelscriptTestCode/CodeGenTool/tests/test_cpp_renderer.py
+AngelscriptTestCode/CodeGenTool/tests/fixtures/renderer/Language/Counter.as
+AngelscriptTestCode/CodeGenTool/tests/fixtures/renderer/Language/Counter.generated.cpp
```

**Verification**

Run from the workspace root. The exact format-v2 golden, all byte-normalization rows, typed descriptors, symbol collisions and forbidden-string assertions pass.

```powershell
python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_cpp_renderer.py"
```

**Evidence**

Command: `python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_cpp_renderer.py"`. RED: golden compared against a placeholder and the table row `\tclass A {}\n` failed because `AS_TEST_SOURCE` strips a single content line's full leading whitespace, so a lone leading tab cannot be preserved; the other four cases already passed. The table row was corrected to `class A {\n\tvoid f();\n}\n` (tabs are not converted to spaces) rather than switching generated defaults to `AS_TEST_SOURCE_EXACT`. GREEN: 6/6 discovered and passed in 0.002s. Adjacent `test_source_parser.py` and `test_annotations.py` remain 6/6 GREEN.

## [x] 3.2 Integrate parsed projections into atomic check/generate synchronization

Route discovery through parsing before rendering and teach synchronization to own both signed v1 and v2 projections safely. Regenerate the repository Counter only after the complete expected set passes protocol, path, symbol and render validation.

**Outcome**

`build_sync_plan` produces no plan from any invalid authored fixture and performs no mutation. Valid generation replaces expected v1 files with v2, preserves unsigned extras, deletes only safely signed stale v1/v2 files after successful writes, and leaves unchanged output timestamps intact. Public CLI paths and ordinary-UBT behavior remain unchanged.

**Interfaces**

Consumes (existing `sync.py:31,118`, `cli.py:44`, produced by 1.1/1.2/3.1):

```python
def build_sync_plan(author_root: Path, generated_root: Path) -> SyncPlan: ...
def apply_sync_plan(plan: SyncPlan) -> None: ...
def parse_source_file(source: SourceInput) -> ParsedFile: ...
def render_projection(source: ParsedFile) -> bytes: ...
```

Produces no new public CLI names. `build_sync_plan` now owns full discovery → parse → validate → render preflight and recognizes both signed carrier formats during migration.

**Cases**

1. **Protocol failure leaves all projections untouched** — new RED
   Given two valid authored files, one invalid fixture, and existing generated bytes/mtimes When `build_sync_plan` runs Then it reports the invalid authored path and stable diagnostic, returns no applicable plan, and every existing output byte/mtime remains unchanged.
2. **Signed v1 becomes expected v2** — new RED
   Given a current-path signed format-v1 byte carrier When valid source is planned and generated Then the path is `changed`, its replacement is structured format v2, and the old parser/raw-array text is absent.
3. **Renamed signed v1 is stale-owned** — new RED
   Given a removed authored file and its signed v1 projection at the old mirrored path When generation succeeds Then that old file is classified stale and removed after all expected v2 writes.
4. **Unsigned extras remain protected** — existing control
   Given `Manual.generated.cpp` without a recognized signature and `Keep.txt` under generated root When check/generate runs Then both remain, are reported unsafe extras, and are never deleted.
5. **No-op keeps timestamps** — existing control
   Given synchronized v2 outputs When `generate` repeats without input changes Then the plan is clean and output mtimes are unchanged.
6. **Repository Counter synchronizes** — new RED · sequence
   1. Add the accepted Point/Breakpoint/Range markers to authored `Language/Counter.as` without changing its clean root/add-step bodies.
   2. Run `generate` → one readable `Language/Counter.generated.cpp` with real metadata and typed descriptors.
   3. Run `check` → success with no missing, changed, stale or unsafe generated state.

**Files**

```diff
 AngelscriptTestCode/Language/Counter.as
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/cli.py
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/discovery.py
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/model.py
 AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/sync.py
 AngelscriptTestCode/CodeGenTool/tests/test_cli.py
 AngelscriptTestCode/CodeGenTool/tests/test_sync.py
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Counter.generated.cpp
```

**Verification**

Run from the workspace root. The sync tests cover cases 1-5 and the checked-in repository projection proves case 6 through read-only `check`.

```powershell
& {
    python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_sync.py"
    if ($LASTEXITCODE -ne 0) { throw 'Structured projection sync tests failed.' }
    python AngelscriptTestCode/CodeGenTool/codegen.py check
    if ($LASTEXITCODE -ne 0) { throw 'Repository generated test code is not synchronized.' }
}
```

**Evidence**

Command: the task Verification block. RED: 5 new/updated sync cases failed with `AttributeError` because `build_sync_plan` still passed `SourceInput` to `render_projection(ParsedFile)`; `test_invalid_inputs_do_not_mutate_existing_projection` stayed GREEN. GREEN: `test_sync.py` 6/6 in 0.054s; `codegen.py check` reported synchronized. Adjacent `test_cli.py` 3/3 and the full CodeGenTool suite 31/31 passed. Case 6: authored `Language/Counter.as` is 524 bytes (SHA-256 `c6b8c5c44a9e950be4935b760a7420586417ae939f068b4509ea31af4871a820`) with unchanged clean root/add-step bodies; generated `Language/Counter.generated.cpp` is format v2 with Point `initial-value=32`, Breakpoint `before-add=39`, Range `delta=[50,51)`. Those clean-body coordinates replace the 1.2 synthetic one-body offsets `66`/`[75,76)` for later activation assertions. Naming assumed: `LEGACY_GENERATOR_SIGNATURE` — package-internal v1 header recognized alongside format v2 so signed stale/changed carriers remain owned during migration.

## [x] 4.1 Prove Python and C++ fixture-protocol conformance

Create a small shared disk fixture corpus used only by parser tests. Python parses each file directly; C++ focused Parser tests load the same bytes from the host project. Production database loading remains independent of author files.

**Outcome**

Both parsers produce equal positive metadata, clean bytes, typed annotations and every origin offset including `Num()`. Both reject negative protocol fixtures with the same primary stable code/location while retaining implementation-specific message prose and recovery ordering.

**Interfaces**

Consumes (existing `AngelscriptTestSourceParser.h:10`; produced by 1.1/1.2):

```cpp
class ANGELSCRIPTTEST_API FAngelscriptTestSourceParser;
```

```python
def parse_source_file(source: SourceInput) -> ParsedFile: ...
```

Produces no product API. Test-only fixtures live under excluded `CodeGenTool/tests/fixtures/conformance/` and C++ tests use explicit project-root test paths rather than a runtime fallback.

**Cases**

1. **Positive protocol matrix** — new RED · example-table
   Template: Given shared fixture `<fixture>` When both parsers consume the same bytes Then they match `<oracle>` exactly.

   | fixture | oracle |
   |---|---|
   | `bom-crlf.as` | FileMeta, root body LF bytes, raw authored offsets and EOF mapping |
   | `unicode.as` | UTF-8 clean byte positions before and after multi-byte text |
   | `annotations.as` | Point, Breakpoint, nested half-open Ranges and escaped literal marker |
   | `branch-trailing-lf.as` | root/forward-parent child order, complete bodies and terminal LF |
2. **Negative protocol matrix** — new RED · example-table
   Template: Given shared fixture `<fixture>` When both parsers reject it Then the primary code is `<code>` at the same authored directive/marker location.

   | fixture | code |
   |---|---|
   | `unknown-directive.as` | `UnknownMetadataDirective` |
   | `missing-summary.as` | `MissingSummary` |
   | `duplicate-version.as` | `DuplicateVersionTag` |
   | `missing-parent.as` | `MissingParent` |
   | `cycle.as` | `VersionCycle` |
   | `duplicate-point.as` | `DuplicatePoint` |
   | `missing-range-end.as` | `MissingRangeEnd` |
   | `crossing-range.as` | `CrossingRange` |
3. **Message prose is not the oracle** — boundary
   Given a negative fixture whose Python and C++ messages use different English wording When conformance runs Then equal stable code/location passes and a code/location mismatch fails.
4. **Existing inline parser controls remain valid** — existing control
   Given the current `FullContainer`, `BytePositions`, `EscapeAndMalformedMarkers`, `EmptyAndLineEndings` and `InlineParity` tests When the Parser prefix runs Then their existing products still pass.

**Files**

```diff
+AngelscriptTestCode/CodeGenTool/tests/fixtures/conformance/
+AngelscriptTestCode/CodeGenTool/tests/test_conformance.py
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/ParserTests.cpp
```

Test-only C++ disk access is limited to the shared conformance fixture directory and must not enter `FAngelscriptTestCode` or generated-provider code.

**Verification**

Run from the workspace root. Python conformance runs first, then a fresh Editor build and the exact C++ Parser class prefix. Both positive tables and the stable-code table must pass.

```powershell
& {
    python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_conformance.py"
    if ($LASTEXITCODE -ne 0) { throw 'Python fixture conformance tests failed.' }
    Import-Module ./.agents/skills/harness/scripts/Harness.psd1
    $context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
    Invoke-Harness -Command workspace.activate -Context $context | Out-Null
    $build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'fixture-parser-conformance-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }
    if ($build.status -ne 'Succeeded') { throw 'Fixture parser conformance Editor build failed.' }
    $tests = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Parser'; Label = 'fixture-parser-conformance-tests'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }
    if ($tests.status -ne 'Succeeded') { throw 'C++ fixture parser conformance tests failed.' }
    $tests
}
```

**Evidence**

Command: the task Verification block. Python `test_conformance.py` 3/3 GREEN in 0.003s (the shared corpus characterizes the existing Python parser; no new protocol behavior was required). Editor incremental build `fixture-parser-conformance-build` succeeded; Automation run `124477a0da5347778fae2be236e0bee4` executed Parser prefix 8/8: existing controls `FullContainer`, `BytePositions`, `EscapeAndMalformedMarkers`, `EmptyAndLineEndings`, `InlineParity` plus `ConformancePositive`, `ConformanceNegative`, `ConformanceMessageProseIsNotOracle`. Naming assumed: `MissingFileSummary` — table label `MissingSummary` maps to the existing file-header code already published by both parsers. C++ topology errors now receive the same authored body/file locations as Python (`DuplicateVersionTag`/`MissingParent` from the last same-tag body; `VersionCycle` at line 1 offset 0) so primary code/location match.

## [x] 4.2 Activate structured Counter data and retain cross-module registration controls

Complete the compiled end-to-end proof after the descriptor, renderer, synchronized Counter and conformance paths exist. Extend generated-source/adoption tests to assert real metadata, clean bytes, typed annotations, authored-origin mapping and the existing handwritten JIT provider through one database center.

**Outcome**

Central activation admits the structured Counter registration without calling the generated container parser, exact root/child queries expose one FileMeta truth and expected annotations/origins, and the handwritten `Fixture/Secondary` provider still observes the same singleton center. An invalid descriptor batch remains isolated and recorded as an infrastructure error.

**Interfaces**

Consumes (existing `AngelscriptTestCodeRegistration.h:64,67`, existing database/query APIs, outputs of 2.1 and 3.2):

```cpp
using FCodeFactory = FAngelscriptTestCodeBuildResult (*)(const FAngelscriptTestFileMeta&);
class FAngelscriptTestCodeRegistration;
class FAngelscriptTestCode;
class FAngelscriptTestSourceCase;
```

Produces no additional public names. It proves the generated symbol `GRegistration_Language_Counter`, the existing exact `Get(FileTag, VersionTag)` surface and the existing cross-module registration contract.

**Cases**

1. **Generated Counter root is exact** — new RED
   Given activated FileTag `Language/Counter` When `root` is requested Then FileMeta is exactly `v1`, `Language/Counter`, `Counter source variants.`, Topics `Language`/`Reload`; VersionMeta and clean bytes match the authored root; `initial-value` and its original offset are exact.
2. **Generated child remains directly addressable** — new RED
   Given `add-step` with Parent `root` When requested directly before or after root Then complete child bytes, Summary/Topics, `before-add`, `delta=[75,76)` and all mapped authored offsets are unchanged by query order.
3. **Registration and Case metadata have one truth** — new RED
   Given the generated registration factory receives its FileMeta When Builder publishes root and child Then every Case reports that same metadata content and no placeholder `Generated from ...` Summary appears.
4. **Generated activation has no parser dependency** — new RED · absence
   Must not exist in `Counter.generated.cpp`: an include of `AngelscriptTestSourceParser.h` or a `FAngelscriptTestSourceParser::Parse` call. Oracle: the checked-in generated source plus successful compiled activation.
5. **Handwritten JIT provider shares the center** — existing control
   Given `AngelscriptTestJIT` registers `Fixture/Secondary` with its handwritten captureless Builder factory When activation completes Then Counter and Secondary are both retrievable and the exported JIT center probe equals the framework singleton address.
6. **Bad descriptor batch is isolated** — new RED
   Given a test registration with an out-of-bounds Point and a valid unrelated registration When a controlled registry activates Then the bad batch publishes no Case and records a descriptor error while the valid batch remains retrievable.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/GeneratedSourcesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/RegistrationTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/AdoptionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTestJIT/NewVersion/TestCodeProviderRegistration.cpp
```

The JIT file is a compatibility control and changes only if compilation requires the new overload to coexist with its existing two-argument calls.

**Verification**

Run from the workspace root. A fresh Editor build is required because generated C++ and framework tests changed. The full Framework prefix is justified by the shared Source/Builder/Parser/registration/database contract; unrelated NativeEngine, World, VM, cache and full-project suites remain omitted unless failure evidence expands impact.

```powershell
& {
    Import-Module ./.agents/skills/harness/scripts/Harness.psd1
    $context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
    Invoke-Harness -Command workspace.activate -Context $context | Out-Null
    $build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'structured-test-code-final-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }
    if ($build.status -ne 'Succeeded') { throw 'Structured test-code final Editor build failed.' }
    $tests = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework'; Label = 'structured-test-code-framework-tests'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }
    if ($tests.status -ne 'Succeeded') { throw 'Structured test-code Framework tests failed.' }
    $tests
}
```

**Evidence**

Shared Editor binary from 4.1 incremental build `fixture-parser-conformance-build` (generated Counter v2 and Framework tests were already compiled; no C++ source changed after that build). Official Framework selector run `71775250f1554d40a6fa6e994334876a` (`structured-test-code-framework-tests`) succeeded 40/40. New/extended cases: `GeneratedSources.GeneratedFixture` (FileMeta `v1`/`Language/Counter`/`Counter source variants.`, Topics `Language`/`Reload`, Point `initial-value=32`, authored map 239), `GeneratedChildRemainsDirectlyAddressable` (Breakpoint `before-add=39`, Range `delta=[50,51)`), `RegistrationAndCaseMetadataHaveOneTruth`, `GeneratedActivationHasNoParserDependency`, `Registration.BadDescriptorBatchIsIsolated` (`InvalidAnnotationOffset` isolated). Existing control `Adoption.TwoModulesOneCenter` remained GREEN. First Framework execution of these assertions passed because 2.1/3.2 already shipped the product path; this card is the compiled activation proof rather than a second implementation cycle. Omitted NativeEngine, World, VM, cache and full-project suites: no failure evidence expanded impact beyond the Framework contract.
