# Counter projection before and after structured generation

Source identity: focused finding `generated-before-after-counter-example.md` from brainstorming topic `angelscript/test-framework-completion`, translated and scoped for this Change on 2026-09-14.

## Authored input facts

`AngelscriptTestCode/Language/Counter.as` is 420 bytes with SHA-256 `28d6fc3cba07a13cf12c6ced5146377bf7d85bcbef71ff1a55d9fb0762f465d9`.

Its FileMeta is format `v1`, Tag `Language/Counter`, Summary `Counter source variants.` and Topics `Language`, `Reload`. It contains two complete versions:

- `root`: body begins at authored line 12 and raw byte offset 180; clean length 37.
- `add-step`: body begins at authored line 24 and raw byte offset 353; clean length 55.

## Current output

The Python tool currently reads raw bytes and calculates a hash. The renderer expands all 420 bytes into `constexpr uint8[]`, writes a placeholder registration Summary and invokes `FAngelscriptTestSourceParser::Parse` during activation. The parser reconstructs FileMeta from the raw container, so activation records and final Cases initially have separate metadata facts.

## Target Python IR

```text
ParsedFile
├─ format_version: "v1"
├─ file_tag: "Language/Counter"
├─ summary: "Counter source variants."
├─ topics: ["Language", "Reload"]
├─ authored_path: "Language/Counter.as"
├─ authored_sha256: "28d6fc3c..."
└─ versions
   ├─ root
   │  ├─ parent: none
   │  ├─ summary: "Define the initial counter."
   │  ├─ topics: ["Baseline"]
   │  ├─ clean_source: "class Counter\n{\n    int Value = 0;\n}\n"
   │  ├─ annotations: empty
   │  ├─ origin_spans: [{clean: 0, authored: 180, length: 37}]
   │  └─ authored_end: 217
   └─ add-step
      ├─ parent: "root"
      ├─ summary: "Add a configurable counter step."
      ├─ topics: ["Fields", "Reload"]
      ├─ clean_source: "class Counter\n{\n    int Value = 0;\n    int Step = 1;\n}\n"
      ├─ annotations: empty
      ├─ origin_spans: [{clean: 0, authored: 353, length: 55}]
      └─ authored_end: 408
```

## Target C++ appearance

The generated file exposes real FileMeta and VersionMeta, readable `AS_TEST_SOURCE` bodies and one direct captureless factory. It uses no named build helper, anonymous namespace or parser invocation.

```cpp
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
    });
}
```

Activation and query identities do not change: `Get("Language/Counter", "root")` and `Get("Language/Counter", "add-step")` return the same complete version Cases. Parsing time and generated representation change.

## Annotation example

If a body contains point, breakpoint and range markers, Python strips them and emits typed clean-byte coordinates:

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

The matching origin projection splits at removed markers and retains `AuthoredEnd`. Runtime code does not scan the marker spelling.

## Symbol identity

The old `GRegistration_427f18f4cff8` suffix is the first twelve SHA-256 hex digits of `Language/Counter`. It is only an internal C++ disambiguator. The accepted generated name is `GRegistration_Language_Counter` under `AngelscriptTest::Generated`, declared namespace-scope `static`.

Anonymous namespaces alone are insufficient under Unreal Unity Build because merged source files share the same anonymous namespace in the combined translation unit. Deterministic FileTag encoding plus a full generated-symbol collision check provides readability and safety. The authored SHA remains in the generated header for provenance and stale detection.
