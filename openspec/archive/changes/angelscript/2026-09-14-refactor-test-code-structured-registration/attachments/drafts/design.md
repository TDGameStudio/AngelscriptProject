# Build-time parsing and structured generated registration

Source identity: local brainstorming topic `angelscript/test-framework-completion`, scoped design `generated-structured-registration`, accepted by the user on 2026-09-14. This is a faithful English export of the approved Chinese design; it is not a transcript.

## 1. Objective

An authored `.as` file is the single source of truth. Its checked-in `.generated.cpp` is a deterministic, readable and reviewable build projection. Unreal module activation must no longer interpret the complete `.as` container as an opaque byte blob. Python parses file metadata, the complete version tree, clean source, annotations and authored-origin mappings before rendering C++.

This does not remove `FAngelscriptTestSourceParser`. The C++ parser remains an independent implementation of the same v1 authoring protocol for handwritten or dynamic containers and conformance tests. Generated translation units do not include or invoke it.

```text
AngelscriptTestCode/Language/Counter.as
└─ Python: discover → normalize → parse container → parse annotations → validate tree
   └─ immutable ParsedFile IR
      └─ deterministic C++ renderer
         └─ TestCode/Generated/Language/Counter.generated.cpp
            └─ static registration + captureless lambda
               └─ Builder.AddRoot/AddVersion → Build
                  └─ central ActivateRegistrations → database

Handwritten or dynamic container bytes
└─ FAngelscriptTestSourceParser::Parse
   └─ equivalent metadata/source semantics → Builder → database

Consumers
├─ Get(FileTag, VersionTag)       // exact immutable Case
├─ FindFiles/FindCases by Topics  // selection only
└─ compile / reload / LSP / debug // outside this storage layer
```

## 2. Authoring protocol

### 2.1 Paths and identity

- `AngelscriptTestCode/` is the single author root.
- The complete `CodeGenTool/` subtree is excluded from material discovery.
- FileTag is the root-relative path with `/` separators and only the terminal `.as` removed. `Language/Counter.as` becomes `Language/Counter`.
- Moving or renaming the file changes its identity. There is no handwritten SourceId or numeric resource ID.
- One `.as` maps to one mirrored `.generated.cpp`. A file may contain any number of complete source versions.

### 2.2 File and version metadata

The file header uses a UE/Doxygen-style block:

```angelscript
/**
 * @version v1
 * @summary Counter source variants.
 * @topic Language
 * @topic Reload
 */
```

File-level `@version v1` is the fixture format version and maps to `FAngelscriptTestFileMeta.Version`; it is not a source-node tag. FileTag is path-derived and is not repeated in the header. File Summary is required, non-empty and English. Topics are repeatable and optional. Unknown v1 directives are fixture-protocol errors so spelling mistakes are not silently ignored.

Each source version has its own header and explicit terminator:

```angelscript
/**
 * @version unresolved-name
 * @parent root
 * @summary Reference an undeclared name in the initializer.
 * @topic Negative
 * @topic Diagnostics
 */
class Counter
{
    int Value = Missing;
}
/** @end */
```

Every version, including `root`, contains complete source rather than a diff. Root has an explicit header, its own Summary and Topics, no Parent, and an explicit `/** @end */`. Every non-root version declares Parent. Parent describes an enumerable and validated tree; it does not materialize bytes. Version Summary is required, non-empty and English. Topics belong only to that version and are not inherited from the file or parent.

### 2.3 Negative language source

Negative metadata classifies a version; it is not an execution oracle. `Negative`, `Diagnostics` and more specific Topics let tests select Cases. The consuming test still declares the stage, expected diagnostics, counts and locations.

Intentionally invalid AngelScript syntax or semantics with a valid fixture container must generate and register normally. Invalid metadata, version topology, annotations or UTF-8 fixture protocol fail code generation. Fixtures that intentionally test an invalid container live under Python test fixtures or C++ parser tests and never enter the production inventory.

### 2.4 Generic source annotations

Version bodies support:

```angelscript
/** @point cursor */
/** @breakpoint before-add */
/** @range-begin delta */.../** @range-end delta */
```

Markers are removed from final Source bytes. Offsets use clean UTF-8 byte coordinates, not Unicode code points, UTF-16 columns or authored offsets. Ranges are half-open `[Begin, End)`. Ranges may nest but may not cross. Names are unique within one kind; Point, Breakpoint and Range may reuse a name because their query APIs are distinct.

`/** @@point cursor */` and corresponding escaped forms emit literal `/** @point cursor */` text without creating an annotation. This explicit escape is the v1 rule; the fixture parser must not depend on lexing possibly invalid AngelScript. A breakpoint is only a requested test location. It neither installs a breakpoint nor guarantees an executable instruction. Diagnostic expectations remain a separate future protocol.

## 3. Python package boundaries

The stable `codegen.py` entry remains thin. Parsing is modular rather than accumulating in the CLI or renderer:

```text
AngelscriptTestCode/CodeGenTool/
├─ codegen.py                         // stable CLI handoff
├─ angelscript_test_codegen/
│  ├─ cli.py                          // generate/check and exit behavior
│  ├─ paths.py                        // roots and path normalization
│  ├─ discovery.py                    // enumeration, exclusions, collisions
│  ├─ model.py                        // immutable IR and diagnostics
│  ├─ text_normalization.py           // UTF-8/BOM/newline coordinates
│  ├─ container_parser.py             // file/version headers and @end
│  ├─ annotation_parser.py            // typed markers and clean bytes
│  ├─ validation.py                   // metadata/tree/range/symbol invariants
│  ├─ cpp_renderer.py                 // pure IR → deterministic C++
│  └─ sync.py                         // shared check/generate plan
└─ tests/
   ├─ fixtures/
   └─ test_*.py
```

Dependencies stay one-way:

```text
cli
└─ sync
   ├─ discovery → paths + model
   ├─ container_parser → normalization + annotation_parser + validation + model
   └─ cpp_renderer → model

model + text_normalization
// Never depend back on filesystem, CLI, sync or renderer.
```

Module names may be combined during planning if evidence shows a module would be trivial, but these responsibility boundaries remain. The renderer does not read files or parse text. Discovery does not write output. `check` and `generate` share the exact discovery, parse, validate, render and SyncPlan path.

## 4. Immutable Python IR

Conceptual data shape:

```text
ParsedFile
├─ source_path: "Language/Counter.as"
├─ source_length: 420
├─ source_sha256: "28d6..."
├─ file_meta: {version, tag, summary, topics}
└─ versions: ParsedVersion[]
   ├─ version_meta: {tag, parent, summary, topics}
   ├─ clean_source: bytes
   ├─ authored_body_line: int
   ├─ annotations
   │  ├─ points: {name → clean byte offset}
   │  ├─ breakpoints: {name → clean byte offset}
   │  └─ ranges: {name → [begin, end)}
   ├─ origin_spans: [{clean_begin, authored_begin, length}]
   └─ authored_end: original byte offset for clean_source.Num()
```

Source is represented as bytes in the IR. Decoded text may identify ASCII protocol syntax, but annotation and origin arithmetic is performed in normalized UTF-8 byte coordinates so a Unicode prefix cannot shift offsets.

Origin data is not emitted as one `int32` per byte. A contiguous span maps:

```text
OriginalOffset = AuthoredBegin + (CleanOffset - CleanBegin)
```

Marker removal, CRLF-to-LF conversion and any other discontinuity split spans. Spans are strictly ordered, positive length, gap-free and overlap-free in clean coordinates and cover every clean byte. `AuthoredEnd` separately maps `CleanOffset == clean_source.Num()`. It cannot always be inferred from the last span: if a terminal annotation marker is removed, clean EOF maps after that marker. Authored positions use the unmodified authored `.as` byte coordinate system. The first C++ implementation may expand spans plus the end anchor into the existing `Num()+1` offset array; a later internal representation may store spans natively without changing generated semantics.

## 5. Parse and validation phases

```text
raw bytes
→ validate UTF-8 / remove optional BOM / normalize CRLF and CR
→ parse exactly one file header
→ parse repeated version-header + body + explicit @end
→ remove and record annotations per version
→ validate required fields, duplicate names and byte bounds
→ validate exactly one root, parents, duplicate tags and cycles
→ build ParsedFile IR
```

The tool discovers and parses every input, renders every expected output and validates path and symbol collisions before any disk mutation. It reports multiple independently reliable errors when possible and suppresses cascades whose identity became ambiguous. Any protocol error leaves the complete output set unchanged.

Diagnostics include a stable code, authored relative path, line/column or byte offset, version when known, and an English message. Python and C++ require equivalent stable codes and semantics. Message prose and independent-error ordering may differ.

## 6. Generated C++ contract

### 6.1 File and symbol identity

- The header records generator `format=v2`, authored relative path, raw byte length and SHA-256. Generator format v2 and authored fixture `@version v1` are separate version domains.
- Output contains no absolute path, timestamp, Python `hash()` or content-dependent C++ symbol.
- Generated code does not use an anonymous namespace.
- A namespace-scope `static` registration lives under `AngelscriptTest::Generated`.
- FileTag derives the readable name: `Language/Counter → GRegistration_Language_Counter`.
- Ordinary alphanumeric paths remain readable. Other identifier bytes use deterministic reversible escaping. The complete rendered symbol set is collision-checked before mutation. No random or silent suffix is added.
- SHA remains in the provenance header, not the C++ symbol.

### 6.2 Registration shape

One file contains one direct registration and captureless lambda, without an extra named build function:

```cpp
// @generated by AngelscriptTestCode/CodeGenTool format=v2
// source=Language/Counter.as length=420 sha256=28d6fc3c...

namespace AngelscriptTest::Generated
{
static FAngelscriptTestCodeRegistration GRegistration_Language_Counter(
    {
        .Version = TEXT("v1"),
        .Tag = TEXT("Language/Counter"),
        .Summary = TEXT("Counter source variants."),
        .Topics = {TEXT("Language"), TEXT("Reload")},
    },
    +[](const FAngelscriptTestFileMeta& FileMeta)
    {
        FAngelscriptTestCodeBuilder Builder(FileMeta);

        Builder.AddRoot(
            {
                .Tag = TEXT("root"),
                .Summary = TEXT("Define the initial counter."),
                .Topics = {TEXT("Baseline")},
            },
            AS_TEST_SOURCE(R"(
                class Counter
                {
                    int Value = 0;
                }

                )"),
            FAngelscriptTestSourceDescriptor{
                .AuthoredPath = TEXT("Language/Counter.as"),
                .AuthoredLine = 12,
                .AuthoredEnd = 217,
                .OriginSpans = {
                    {.CleanBegin = 0, .AuthoredBegin = 180, .Length = 37},
                },
            });

        return Builder.Build();
    },
    UE_MODULE_NAME,
    "AngelscriptTestCode/Language/Counter.as",
    1);
}
```

The three-argument Builder overload and `FAngelscriptTestSourceDescriptor` are accepted public names. The generated path does not include or invoke `FAngelscriptTestSourceParser`.

### 6.3 `AS_TEST_SOURCE` byte parity

The renderer must prove:

```text
ParsedVersion.clean_source
== AS_TEST_SOURCE(generated literal).GetBytes()
```

`AS_TEST_SOURCE` removes the literal envelope, common indentation and delimiter margin. The renderer uses a fixed envelope and common prefix. If clean source ends with LF, an extra physical blank line before the delimiter margin preserves the source LF after macro normalization. The raw delimiter is selected to avoid content collision.

Layout-exact handwritten tests may continue to use `AS_TEST_SOURCE_EXACT` or an explicit byte factory for significant common leading whitespace, CRLF, NUL or invalid UTF-8. Generated v1 fixtures default to `AS_TEST_SOURCE`. Python golden tests and at least one compiled C++ fixture prove the equality; a duplicated unverified normalization implementation is insufficient.

### 6.4 Annotation projection

The descriptor mirrors the current typed query surface:

```cpp
.Annotations = {
    .Points = {
        {.Name = TEXT("initial-value"), .Offset = 32},
    },
    .Breakpoints = {
        {.Name = TEXT("before-add"), .Offset = 66},
    },
    .Ranges = {
        {.Name = TEXT("delta"), .Begin = 75, .End = 76},
    },
},
```

Empty tables are omitted. Small tables remain inline with their version. Evidence of materially large tables may allow same-file `static constexpr` descriptor arrays without changing semantics. The renderer must not replace these with an untyped Kind table or expand origin data per byte.

## 7. C++ runtime responsibilities

### 7.1 Source descriptor admission

`FAngelscriptTestSource::FromParsedData` is private, as are the maps in `FAngelscriptTestAnnotations` and offsets in `FAngelscriptTestSourceOriginMap`. A generated provider needs a narrow validated API rather than mutable access.

`FAngelscriptTestSourceDescriptor` is a temporary construction argument, not another Source, Case, query Result or stored database layer. `AS_TEST_SOURCE` supplies clean bytes and only knows the generated `.cpp` host location. The descriptor supplies authored `.as` path/line, typed annotations, origin spans and `AuthoredEnd`.

```text
AS_TEST_SOURCE clean bytes + temporary Source descriptor
└─ Builder validates and copies/moves data
   └─ private FAngelscriptTestSource::FData
      └─ immutable FAngelscriptTestSourceCase

temporary descriptor
// Destroyed after AddRoot/AddVersion.
```

The confirmed seam is a public `FAngelscriptTestCodeBuilder` overload:

- `AddRoot/AddVersion(VersionMeta, Source, Descriptor)` accepts generated data.
- Descriptor offset, range, span and end-anchor errors accumulate with version-tree errors in terminal `Build()`.
- No second Source result or per-version forwarding boilerplate is required.
- Source maps remain non-mutable; Builder is a controlled construction friend.
- Other test modules can use the exported overload without a module-private bridge.

A Source-owned factory was rejected because failed validation requires an additional result/error bridge or an invalid Source state. A separate Source Builder was rejected because generated lambdas would operate two builders.

All descriptor data is copied or moved into Source-owned storage. Admission defensively validates bounds, duplicate names, ranges, span coverage, `AuthoredEnd` and authored path. A generator defect or hand-edited projection becomes a structured build/admission error, not a crash or partially published file.

### 7.2 Builder and database

Builder remains responsible for File/Version required fields, exactly one root, duplicate version tags, parent existence, cycles, immutable Case construction and all-or-nothing `FAngelscriptTestCodeBuildResult`. `AddRoot/AddVersion` remain declarative; terminal `Build()` returns accumulated local and collection errors. Builder does not compile AngelScript, run reload or scan annotations.

Registration FileMeta and Case FileMeta are one fact. The lambda passes the registration-owned FileMeta into Builder; no parser reconstructs another instance. One registration is one admission batch. A failed file is rejected as a whole without affecting unrelated registrations.

### 7.3 Static registration and modules

Generated materials in `AngelscriptTest` and handwritten providers in other modules use the existing exported `FAngelscriptTestCodeRegistration`. Other modules may keep direct captureless lambdas plus `AS_TEST_SOURCE`, or reuse the descriptor overload for their generated providers. There is no second database or module-private aggregate.

Static initialization records metadata and a function pointer. Builder/Source construction occurs at the single activation barrier. The framework-owning module invokes `ActivateRegistrations()` once after module loading completes; provider modules do not invoke it.

## 8. Retained C++ parser and conformance

`FAngelscriptTestSourceParser` retains its public API, implementation and focused tests for handwritten/dynamic containers, protocol-negative cases, cross-language conformance and a future demonstrated runtime-import need. Generated files do not include its header.

The durable authoring spec and fixture corpus are authoritative, not either implementation alone. Shared cases cover BOM, LF/CRLF/CR, Unicode, required and unknown fields, explicit `@end`, duplicate/missing parents, cycles, escaped annotations, nested/crossing ranges, trailing LF and intentionally invalid AngelScript.

Positive parity compares FileMeta, VersionMeta, version order, clean bytes, Points, Breakpoints, Ranges and origin mapping. Negative parity compares stable error codes and primary source location. Message wording and independent-error ordering may differ.

## 9. Synchronization and determinism

`generate` is the only writer. `check` is read-only. Ordinary UBT does not run Python.

```text
all authored files
→ discover + parse + validate + render in memory
→ calculate expected generated path set
→ compare generated root
→ SyncPlan {missing, changed, stale, unchanged}
   ├─ check: report and fail, never mutate
   └─ generate: atomically replace changed/missing, then remove safe stale files
```

Equal content does not change timestamps. Stale deletion is limited to signed `.generated.cpp` files under the dedicated generated root and happens only after all writes succeed. Windows case collisions, output collisions, symbol collisions and raw-delimiter failures are preflight errors. Output is UTF-8/LF and paths sort ordinally after normalization.

Only structured results are embedded by default. The authored file plus relative path, length and SHA provide review provenance. A future requirement for runtime access to the complete authored container would be a separate optional payload design.

## 10. Verification strategy

Python groups cover normalization; file/version/`@end` parsing; annotations, escapes and byte offsets; root/parent/duplicate/cycle validation; readable renderer goldens; identifier encoding and collisions; read-only/no-op/edit/add/rename/delete sync; negative AngelScript acceptance; protocol failure with zero mutation.

C++ groups cover descriptor construction; invalid offset/name/range/span/end rejection; expansion into a `Num()+1` origin map; compiled `AS_TEST_SOURCE` parity; Counter root/child activation and queries; Registration/Case FileMeta identity; handwritten cross-module control; retained parser regression.

Conformance compares the two parsers. Start with Python package and focused C++ framework tests. Use Harness-selected UE build/test only for compiled shared framework or cross-module activation impact. Each future task owns one exact proving command and grouped RED/GREEN cases.

## 11. Migration and OpenSpec boundary

This is a successor delta, not a rewrite of archived `angelscript/refactor-test-code-generated-carrier` history.

1. Modify the durable code-database requirement from activation-time authored-byte parsing to Python-generated structured projection and activation-time construction/validation.
2. Preserve an independent C++ parser and conformance requirement.
3. Advance generated carrier format v1 to structured format v2. Existing signed v1 outputs are changed owned outputs, not foreign stale files.
4. Before product implementation, separately update/replan active planning-only `angelscript/refactor-testing-unified-framework` so its source-history, byte-array shard, aggregate-release and conflicting TestCode ownership no longer overlap this Change.
5. After implementation verification, synchronize only verified durable behavior, record terminal evidence and archive through the matching lifecycle.

## 12. Risks and controls

| Risk | Control |
|---|---|
| Python and C++ parsers drift | One authoring spec, shared fixtures, stable codes, semantic parity tests |
| Macro normalization shifts offsets | Byte-equivalence invariant, Python golden, compiled C++ fixture |
| Origin projection becomes numeric noise | Contiguous spans plus `AuthoredEnd`; no per-byte initializer |
| Unity Build creates symbol redefinitions | FileTag-derived identifiers, namespace-scope `static`, full collision check |
| Python rejects negative language tests | Validate fixture protocol only; never lex/parse/compile AngelScript language |
| Static initialization becomes heavy | Registration stores metadata/factory; construction waits for activation |
| Hand-edited generated data crashes or partially publishes | Defensive descriptor validation and atomic batch rejection |
| Multiple modules create independent centers | Reuse exported Registration and the single database/activation owner |
| Failed generation leaves mixed output | Full preflight, atomic replacement, stale removal last |

## 13. Settled names and boundary

The generated Source descriptor is admitted by `FAngelscriptTestCodeBuilder` overloads and is publicly named `FAngelscriptTestSourceDescriptor`. `FAngelscriptTestSource::FromGeneratedData` and a separate Source Builder are rejected alternatives. The Change identity is `angelscript/refactor-test-code-structured-registration`.
