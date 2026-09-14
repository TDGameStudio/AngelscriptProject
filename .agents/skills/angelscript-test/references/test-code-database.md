# AngelScript test code database

Use the test code database when several tests or modules need the same versioned AngelScript source material. The database owns source bytes and metadata; it does not compile scripts, run a reload, interpret diagnostics, or assign execution meaning to annotations.

The public types are in namespace `AngelscriptTest`. Include the focused headers under `NewVersion/Framework/Source/` and `NewVersion/Framework/Catalog/` rather than a legacy test umbrella.

## Choose a provider

| Provider | Best fit | Registration behavior | Current platform boundary |
| --- | --- | --- | --- |
| Authored `.as` container | Shared, reviewable fixtures with several complete versions | An explicit Python command generates one checked-in C++ translation unit per source; each unit records a normal deferred `FAngelscriptTestCodeRegistration` | The carrier is ordinary C++; the current generated output is compiled by `AngelscriptTest` and has no loose-file runtime fallback |
| Static C++ factory | A fixture owned by another C++ module, or a small source literal close to its native test | A static `FAngelscriptTestCodeRegistration` records a non-capturing factory; central activation invokes the startup snapshot once | Portable apart from the behavior under test |

Both providers feed the same Parser or Builder, admission rules, singleton and query API. Do not create a second database per module or a generated runtime index.

## Author a complete-version `.as` container

Author shared fixtures below the repository `AngelscriptTestCode/` root. The relative path determines the public file Tag: `AngelscriptTestCode/Language/Counter.as` becomes `Language/Counter`. The extension and generated C++ symbol suffix are not part of the public identity.

Use Doxygen-style metadata comments. The first block describes the file; every following block describes one source version and is followed by that version's complete body and `/** @end */`.

```angelscript
/**
 * @version v1
 * @summary Counter source variants.
 * @topic Language
 * @topic Reload
 */
/**
 * @version root
 * @summary Define the initial counter.
 * @topic Baseline
 */
class Counter
{
    int Value = 0;
}
/** @end */
/**
 * @version add-step
 * @parent root
 * @summary Add a configurable counter step.
 * @topic Fields
 * @topic Reload
 */
class Counter
{
    int Value = 0;
    int Step = 1;
}
/** @end */
```

The file-level `@version v1` names the metadata grammar. It is not a source node and is not passed to `Get`. Node `@version` values are the per-file `VersionTag`s. Exactly one node has no `@parent`; every other node names its parent. Declaration order is irrelevant, siblings remain independent, and every body is complete source rather than a patch against its parent.

`@summary` is required at file and node level. Repeat `@topic` to attach zero or more filter labels. Topics are metadata for selection; `Reload`, `Negative`, or any other spelling does not schedule a reload or change admission behavior.

After editing authored sources, explicitly synchronize and check the committed C++ projections:

```powershell
python AngelscriptTestCode/CodeGenTool/codegen.py generate
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

`generate` is the only writer. `check` performs the same discovery and rendering in memory and returns non-zero for missing, changed, signed stale, or unsafe extra output without changing the filesystem. The tool finds repository roots from its own location rather than the caller's current directory.

The generator sorts normalized slash-separated `.as` paths, excludes all of `AngelscriptTestCode/CodeGenTool/`, and validates case-fold collisions before writing. Each author path maps reversibly beneath `Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/`: `Language/Counter.as` becomes `Language/Counter.generated.cpp`. Output contains the original bytes, byte length and SHA-256, then registers a factory that calls the existing C++ parser during central activation. Python does not interpret metadata, annotations, version trees or source diffs.

Ordinary UBT never invokes Python or scans `AngelscriptTestCode/`; it only compiles the checked-in `.generated.cpp` files. Adding, deleting or renaming an author source therefore requires running `generate` and committing the matching source-set change. Equal output is not rewritten. Stale cleanup is restricted to signed `.generated.cpp` files under the dedicated generated root; unsigned or unrelated files are preserved and reported.

## Add positional annotations

Annotations are removed from the selected version's clean source. Their coordinates are zero-based UTF-8 byte offsets in those clean bytes, not character indexes:

```angelscript
void Run()
{
    Counter Value;
    Value./** @point member */Step = 2;
    /** @breakpoint before-call */
    /** @range-begin call */Value.Tick()/** @range-end call */;
}
```

- `@point <name>` stores one byte position.
- `@breakpoint <name>` stores a separately named byte position for debugger-oriented consumers.
- `@range-begin <name>` and `@range-end <name>` store a half-open `[Begin, End)` byte range.
- `@@` escapes a directive. For example, `/** @@point example */` emits the literal text `/** @point example */` and creates no annotation.

Marker names must be unique in their category. Missing endpoints, crossing ranges, duplicate names, unknown directives, malformed metadata, and invalid metadata UTF-8 make parsing fail without a successful Source. The Source retains an origin map so a clean byte offset can be related to the authored C++ literal or `.as` file. Annotation names remain generic: a future LSP, debugger, reload harness, or diagnostic adapter chooses how to consume them.

## Register a fixture from another C++ module

Place a static registration in the provider module. The callback type is a function pointer, so a non-capturing lambda may be passed directly; captures and registration-time Builder execution are intentionally unsupported.

```cpp
#include "NewVersion/Framework/Catalog/AngelscriptTestCodeRegistration.h"
#include "NewVersion/Framework/Source/AngelscriptTestCodeBuilder.h"

#if WITH_ANGELSCRIPT_TESTS

namespace
{
AngelscriptTest::FAngelscriptTestCodeRegistration SecondarySource(
    {
        .Version = TEXT("v1"),
        .Tag = TEXT("Fixture/Secondary"),
        .Summary = TEXT("A secondary module fixture."),
        .Topics = {TEXT("Adoption"), TEXT("Reload")},
    },
    +[](const AngelscriptTest::FAngelscriptTestFileMeta& FileMeta)
    {
        AngelscriptTest::FAngelscriptTestCodeBuilder Builder(FileMeta);
        Builder.AddRoot({
            .Tag = TEXT("root"),
            .Summary = TEXT("Define the initial secondary fixture."),
            .Topics = {TEXT("Baseline")},
        }, AS_TEST_SOURCE_EXACT(
            "class Secondary { int Value = 1; }\n"));
        Builder.AddVersion({
            .Tag = TEXT("changed"),
            .Parent = TEXT("root"),
            .Summary = TEXT("Change the complete secondary fixture."),
            .Topics = {TEXT("Reload")},
        }, AS_TEST_SOURCE_EXACT(
            "class Secondary { int Value = 2; string Label = \"changed\"; }\n"));
        return Builder.Build();
    });
}

#endif
```

`AS_TEST_SOURCE_EXACT` preserves every literal byte. `AS_TEST_SOURCE` removes one raw-literal envelope and the exact common indentation prefix while preserving intentional blank lines. Neither macro registers material or parses markers by itself. For direct inline annotations, parse the owned literal explicitly:

```cpp
auto Parsed = AngelscriptTest::FAngelscriptTestAnnotations::Parse(
    AS_TEST_SOURCE(R"AS(
        auto Item = Values[/** @point index */0];
    )AS"));

if (!Parsed.IsSuccess())
{
    const TArray<AngelscriptTest::FAngelscriptTestError>& Errors = Parsed.GetErrors();
    // Report Errors through the owning test framework.
}
```

`FAngelscriptTestCodeBuilder` accumulates independently knowable structure errors until `Build()`. A failed build contains all established errors and no admissible partial payload. `Build()` consumes the Builder; a second call fails. Source text such as `int X=Missing;` is structurally valid here because AS compilation belongs to a later test layer.

The owning `AngelscriptTest` module installs the central startup barrier and activates the provider snapshot once. Ordinary provider modules only define registrations, and test consumers only query the singleton. They must not call `ActivateRegistrations()` from every module.

## Query checked results

Use the pair `(FileTag, VersionTag)` for exact lookup:

```cpp
auto& Code = AngelscriptTest::FAngelscriptTestCode::GetInstance();
auto Result = Code.Get(TEXT("Language/Counter"), TEXT("add-step"));
if (!Result.IsSuccess())
{
    const AngelscriptTest::FAngelscriptTestError* Error = Result.GetError();
    // Report the unknown identity or activation failure.
    return;
}

AngelscriptTest::FAngelscriptTestSourceCase Case = *Result.GetCase();
AngelscriptTest::FAngelscriptTestSource Source = Case.GetSource();
TConstArrayView<uint8> Bytes = Source.GetBytes();
```

Do not cache pointers or references returned by `GetCase()`, `GetError()`, metadata accessors, annotation accessors, or `GetBytes()` beyond their owner. Copy the `FAngelscriptTestSourceCase` or `FAngelscriptTestSource` when it must outlive the Result or database observation. Those value copies retain the selected version's metadata, bytes, annotations and origin map without retaining sibling Cases.

Topic queries use AND semantics and deterministic ordinal output:

```cpp
TArray<AngelscriptTest::FAngelscriptTestSourceCase> ReloadCases;
const TArray<FString> RequiredVersionTopics = {TEXT("Reload"), TEXT("Fields")};
const auto CaseStatus = Code.FindCases(
    TEXT("Language/Counter"), RequiredVersionTopics, ReloadCases);

TArray<AngelscriptTest::FAngelscriptTestFileMeta> LanguageFiles;
const TArray<FString> RequiredFileTopics = {TEXT("Language")};
const auto FileStatus = Code.FindFiles(RequiredFileTopics, LanguageFiles);
```

An empty filter returns every otherwise eligible item. In a healthy catalog, no matches is a successful empty result. An unknown exact file or version is an error. If any unreadable or conflicting batch makes a global inventory incomplete, `FindFiles` fails instead of presenting a partial list and does not replace the caller's output. Exact `Get` and within-file `FindCases` for an admitted unrelated file can still succeed.

Activation errors are retained rather than crashing editor startup. `IsActivated()` distinguishes completion of the barrier from a clean catalog; inspect `GetRegistrationErrors()` when startup integrity matters. Before activation, queries fail. Conflicting providers that claim the same file Tag are both rejected as whole batches, while unrelated valid batches remain queryable.

## Current boundaries

- This layer does not compile or execute AngelScript.
- It does not define expected-diagnostic syntax, reload sequences, LSP requests, debugger commands, or negative-test verdicts.
- Metadata topics may help a consumer select material, but they never turn a Case into an executable test plan.
- The generated `.as` carrier is compiled C++ and has no Win32 RCDATA dependency. A future carrier change must preserve file/version identities, Cases, annotations, original bytes and query contracts.
