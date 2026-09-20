# Proposed class and API contracts

This attachment specifies future implementation landing points for the accepted design. **None of the declarations in this document is an available
API yet.** The present delivery writes Change documents only. It does not implement C++, Python, generated resources, tests, or Skill changes.

`design.md` owns architectural decisions. This document makes its interfaces, ownership, error behavior, class placement, and calling conventions
concrete. Declarations omit mechanical includes and private function bodies. They are an implementation contract, not a header to paste unchanged into
the repository.

## 1. Files, namespaces, and dependencies

All paths in the following table are relative to `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/`.

| Planned files | Owning types and responsibilities |
|---|---|
| `Framework/Source/AngelscriptTestSourceTypes.h` and `.cpp` | Source/item identities, origin, errors, checked status, coordinate types |
| `Framework/Source/AngelscriptTestSource.h` and `.cpp` | Immutable source value, exact/normalized construction, owned copies, macro forwarding |
| `Framework/Source/AngelscriptTestSourceBundle.h` and `.cpp` | Case-local identity assignment, logical-file slots, immutable bundle snapshot |
| `Framework/History/AngelscriptTestSourceHistory.h` and `.cpp` | Immutable version descriptors and local history builder |
| `Framework/History/Private/AngelscriptTestSourceDiff.h` and `.cpp` | Internal external-history diff validation/materialization; no second public history API |
| `Framework/Catalog/AngelscriptTestCode.h` and `.cpp` | Sole public source facade, pinned source release, resolve/history/query/sample/export |
| `Framework/Catalog/Private/AngelscriptTestSourceStore.h` and `.cpp` | Internal source tables, aliases, immutable materialization cache |
| `Framework/Catalog/AngelscriptTestCaseCatalog.h` and `.cpp` | Case/row descriptors, stable selection, capability decisions, duplicate detection |
| `Framework/Catalog/AngelscriptTestRows.h` and `.cpp` | Typed row envelope and checked provider build context |
| `Framework/Catalog/Codecs/` | Small named codecs owned by their actual row schemas; no universal executable JSON interpreter |
| `Framework/Fixtures/AngelscriptDataCase.h` and `.cpp` | Per-item context, CQTest asserter, setup/teardown, reverse-order cleanup |
| `Framework/Automation/AngelscriptDataTest.h` and `.cpp` | Public UE Automation bridge base and row-selection command encoding |
| `Framework/Automation/AngelscriptDataTest.inl` | Typed adapter, provider binding, fixture factory, registration macro |
| `Framework/Reporting/AngelscriptTestRunResult.h` and `.cpp` | Run identity, capability/status/evidence records and diagnostic captures |
| `Framework/Reporting/AngelscriptTestReportWriter.h` and `.cpp` | Checked JSON and failure-artifact writing within the supplied managed run directory |
| `Framework/Frontend/AngelscriptTestFrontendFixture.h` and `.cpp` | Current frontend source snapshot, file mapping, identifiers and typed diagnostic capture |
| `TestCode/Generated/*.generated.cpp` | Checked-in structured registrations owned by `angelscript/refactor-test-code-structured-registration`; this Change must not add a shard/aggregate sibling |

Public author-facing types keep the global Unreal `FAngelscript...` spelling. Private implementation helpers use the named namespace
`AngelscriptTest::Private`. These APIs initially belong to the `AngelscriptTest` module; public here means public to test authors, not a new runtime
module ABI. No export from `AngelscriptRuntime`, engine pool, or host-project implementation is introduced. Any later cross-module export is an
explicit compatibility change.

Foundational source values/types sit below History and Catalog. SourceBundle is a composition layer despite its Source folder placement: it consumes
Source, History, and a pinned Catalog; the catalog store never depends on bundles. Reporting uses source identity and real frontend diagnostics.
Fixtures consume these contracts; Automation consumes Fixtures, Catalog, CQTest, and UE Automation. Frontend support consumes bundles plus current
frontend interfaces. Source values, History, and Catalog never depend on Automation, mutable engines, UObject materialization, World, JIT, or runtime
reload.

Registration translation units use `WITH_ANGELSCRIPT_TESTS` and the appropriate UE Automation gate, with explicit includes. They remain outside
ignored Legacy trees. No legacy force include or `ASTEST_*` macro is restored. Framework self-tests land in `FrameworkTests/Source`, `History`,
`Catalog`, `Automation`, `Reporting`, and `Frontend`, and use `Angelscript.UnitTest.Framework.*` names.

## 2. Common identity, error, and checked-result contract

Do not invent an undefined generic `TResult<T>` or use an empty source to signal failure. The public status and source result are concrete types.

```cpp
struct FAngelscriptTestSourceRef
{
    FString SourceId;
    FString VersionTag = TEXT("root");
    bool IsValid() const;
    bool operator==(const FAngelscriptTestSourceRef& Other) const;
};
enum class EAngelscriptTestErrorCode : uint8
{
    InvalidIdentity, DuplicateIdentity, UnknownSource, UnknownVersion, AmbiguousAlias,
    InvalidLogicalPath, DuplicateLogicalPath, LocalPublicIdentityCollision,
    MissingRoot, DuplicateVersion, UnknownParent, HistoryCycle, RedundantVersion,
    InvalidDiff, HashMismatch, InvalidSchema, UnknownAdapter, InvalidRow, EmptyProvider,
    StaleSelection, UnknownSelection, MissingCapability, InvalidLifecycle, ArtifactWriteFailed,
};
struct FAngelscriptTestError
{
    EAngelscriptTestErrorCode Code;
    TOptional<FAngelscriptTestSourceRef> Source;
    FString CaseId;
    FString RowId;
    FString Context;
    FString DataPath;        // JSON pointer or logical field path, when relevant.
    FString AuthoringFile;   // Diagnostic location; never an identity input.
    int32 AuthoringLine = 0; // Zero means no precise line is available.
    FString Message;
};
class FAngelscriptTestStatus
{
public:
    static FAngelscriptTestStatus Success();
    static FAngelscriptTestStatus Failure(FAngelscriptTestError Error);
    [[nodiscard]] bool IsSuccess() const;
    const FAngelscriptTestError* GetError() const;
private:
    TOptional<FAngelscriptTestError> Error;
};
class FAngelscriptTestSourceResult
{
public:
    static FAngelscriptTestSourceResult Success(FAngelscriptTestSource Source);
    static FAngelscriptTestSourceResult Failure(FAngelscriptTestError Error);
    [[nodiscard]] bool IsSuccess() const;
    const FAngelscriptTestSource* GetSource() const &;
    const FAngelscriptTestSource* GetSource() const && = delete;
    const FAngelscriptTestError* GetError() const;
private:
    TOptional<FAngelscriptTestSource> Source;
    TOptional<FAngelscriptTestError> Error;
};
```

The source result has exactly one of Source and Error. A successful source may contain zero bytes. Failure carries a nonempty diagnostic code/context;
result getters return null for the inactive alternative. `GetSource()` borrows from the result. Copying the returned source creates another immutable
payload lease. Neither status nor result has an implicit success or source conversion.

Other checked operations use `FAngelscriptTestStatus` plus named output parameters, except the concrete history and bundle result classes specified
below. Output parameters remain unchanged on failure. Builder/provider error collections may contain several errors; a caller can report all of them
without losing the first meaningful cause. No recoverable authoring or lookup error uses an unconditional `check()` as its public error mechanism.

Source IDs and VersionTags are case-sensitive. `SourceId + VersionTag` resolves one exact value; no empty/default tag means latest. The source content
hash is a lowercase 64-character SHA-256 hexadecimal string over the exact materialized payload. Validation of the hash shape occurs when loading
generated tables. Human-readable origin, timings, and absolute machine paths are not hash inputs.

## 3. Source value, origin, and inline factories

```cpp
enum class EAngelscriptTestTextMode : uint8
{
    Normalized, Exact,
};
enum class EAngelscriptTestSourceOriginKind : uint8
{
    InlineCpp, ExternalFile, Generated, Imported,
};
struct FAngelscriptTestSourceOrigin
{
    EAngelscriptTestSourceOriginKind Kind;
    FString AuthoringPath;
    int32 CppAnchorLine = 0;
    FString RecipeId;
    FString RecipeVersion;
    TOptional<uint64> Seed;
    FString ImportedFrom;
};
struct FAngelscriptTestSourceCoordinate
{
    uint32 ByteOffset = 0;
    uint32 Line = 1;
    uint32 Utf8ByteColumn = 1;
};
struct FAngelscriptTestMappedLocation
{
    FAngelscriptTestSourceCoordinate Logical;
    TOptional<FAngelscriptTestSourceCoordinate> LiteralRelative;
    FAngelscriptTestSourceOrigin Origin;
};
class FAngelscriptTestSource
{
public:
    static FAngelscriptTestSource FromText(
        FStringView Text,
        EAngelscriptTestTextMode Mode,
        FAngelscriptTestSourceOrigin Origin);
    static FAngelscriptTestSource FromBytes(
        TConstArrayView<uint8> Bytes,
        FAngelscriptTestSourceOrigin Origin);
    bool IsAnonymous() const;
    const TOptional<FAngelscriptTestSourceRef>& GetReference() const;
    const FString& GetContentHash() const;
    const FAngelscriptTestSourceOrigin& GetOrigin() const;
    TConstArrayView<uint8> GetUtf8Bytes() const &;
    TConstArrayView<uint8> GetUtf8Bytes() const && = delete;
    TArray<uint8> CopyBytes() const;
    std::string CopyUtf8String() const;
    [[nodiscard]] FAngelscriptTestStatus CopyText(FString& OutText) const;
    [[nodiscard]] FAngelscriptTestStatus MapLocation(
        uint32 LogicalByteOffset,
        FAngelscriptTestMappedLocation& OutLocation) const;
private:
    struct FPayload;
    TSharedRef<const FPayload, ESPMode::ThreadSafe> Payload;
    TOptional<FAngelscriptTestSourceRef> Reference;
};
```

`FromText` consumes a valid Unicode text value and uses its explicit length, including embedded zero code units. It does not read beyond the supplied
view. `FromBytes` accepts arbitrary bytes, including malformed UTF-8 and embedded NUL; it never decodes or repairs them. Use bytes when malformed
encoding itself is an input. Both factories copy before returning and have no recoverable lookup step. Normal allocation failure retains UE's ordinary
process/allocation behavior; it is not disguised as an empty successful test input.

`CopyUtf8String()` is a length-preserving owning byte copy, not ANSI conversion; it can include NUL. `CopyText` is checked and rejects malformed
UTF-8. Exact text preserves the C++ text value, not the source file's original byte encoding. No implicit `FString` or `const char*` conversion is
supplied. SDK consumers keep the owning string alive, or consume a live source view with an explicit length.

Factories produce anonymous values. Identity assignment creates a new source value sharing the immutable payload; it never mutates an already shared
source. Only catalog admission, local bundle binding, and a validated history builder can bind identity. A public `SetSourceId` mutator is
deliberately absent.

The macros are forwarding conveniences in `AngelscriptTestSource.h`; the planned forwarding shape is:

```cpp
namespace AngelscriptTest::Private
{
    template <SIZE_T N>
    FAngelscriptTestSource MakeLiteralSource(
        const char (&Literal)[N], EAngelscriptTestTextMode Mode,
        const char* HostFile, int32 HostLine);
}
#define AS_TEST_SOURCE(Literal) \
    ::AngelscriptTest::Private::MakeLiteralSource( \
        (Literal), EAngelscriptTestTextMode::Normalized, __FILE__, __LINE__)
#define AS_TEST_SOURCE_EXACT(Literal) \
    ::AngelscriptTest::Private::MakeLiteralSource( \
        (Literal), EAngelscriptTestTextMode::Exact, __FILE__, __LINE__)
```

The first macro contract accepts UTF-8 narrow character arrays, retaining `N - 1` payload elements. Pointers and dynamic FString arguments do not
match the template; use the explicit-length factories for dynamic inputs. Do not add a const-char-pointer fallback that silently calls strlen.
The Unicode source test verifies the selected compiler's UTF-8 literal behavior. TCHAR text uses FromText; malformed bytes use FromBytes.

They pass the literal array and its compile-time element count, excluding only the final C++ terminator, to ordinary internal templates. Each argument
is evaluated once. They capture a C++ origin anchor and return an anonymous source. They do not obtain an engine, perform lookup, compile, register,
or publish. Legacy `ASTEST_AS` and `ASTEST_AS_ANSI` remain separate dormant APIs.

Normalized mode follows the five ordered transformations in `design.md`: UTF-8 encoding and LF normalization; at most one opening envelope LF; one
final delimiter-margin line; exact common spaces/tabs prefix; preservation of other whitespace. The payload owns the transform spans and logical line
map needed for `MapLocation`. Spans describe half-open byte intervals and explicit CRLF/CR or removed-margin transforms, not a guessed constant line
offset. Mapping permits the EOF byte offset and rejects offsets beyond it. It preserves UTF-8 byte columns; it does not substitute TCHAR or
display-cell columns.

For bytes there is no literal-relative text coordinate. A valid logical byte offset remains reportable even if decoding fails. For normalized text,
literal-relative coordinates refer to the captured literal value; C++ file/line is an anchor. `__LINE__` on a multiline macro can refer to its closing
line. No runtime reading of the C++ file or invented exact C++ body position is allowed.

Source values and payload views are safe for concurrent reads. Construction and normalization occur before publication. An immutable payload may
lazily publish an equivalent line map using internal synchronization, without changing identity.

## 4. TestCode facade and its internal immutable store

```cpp
struct FAngelscriptTestSourceDescriptor
{
    FAngelscriptTestSourceRef Reference;
    FString ContentHash;
    FString DefaultLogicalPath;
    TArray<FString> Tags;
    FAngelscriptTestSourceOrigin Origin;
};
struct FAngelscriptTestSourceQuery
{
    FString SourceIdPrefix;
    TArray<FString> RequiredTags;
    TOptional<FString> VersionTag;
};
class FAngelscriptTestCodeSnapshot
{
public:
    const FString& GetReleaseDigest() const;
    const FString& GetSchemaVersion() const;
    TConstArrayView<FAngelscriptTestSourceDescriptor> GetSources() const &;
    FAngelscriptTestSourceResult Resolve(const FAngelscriptTestSourceRef& Ref) const;
    FAngelscriptTestSourceHistoryResult GetHistory(FStringView SourceId) const;
private:
    TSharedRef<const AngelscriptTest::Private::FAngelscriptTestSourceStore,
        ESPMode::ThreadSafe> Store;
};
class FAngelscriptTestCode
{
public:
    static TSharedRef<const FAngelscriptTestCodeSnapshot, ESPMode::ThreadSafe>
        GetSnapshot();
    static FAngelscriptTestSourceResult Resolve(const FAngelscriptTestSourceRef& Ref);
    static FAngelscriptTestSourceResult Resolve(
        const FAngelscriptTestSourceRef& Ref,
        const FAngelscriptTestCodeSnapshot& Snapshot);
    static FAngelscriptTestSourceHistoryResult GetHistory(FStringView SourceId);
    static TArray<FAngelscriptTestSourceDescriptor> Query(
        const FAngelscriptTestSourceQuery& Query,
        const FAngelscriptTestCodeSnapshot& Snapshot);
    static FAngelscriptTestStatus Sample(
        const FAngelscriptTestSourceQuery& Query,
        const FAngelscriptTestCodeSnapshot& Snapshot,
        uint64 Seed,
        int32 Count,
        TArray<FAngelscriptTestSourceDescriptor>& OutSources);
    static FAngelscriptTestStatus ExportSource(
        const FAngelscriptTestSource& Source,
        const FString& OutputFile);
};
```

The public facade absorbs source lookup/history/query/sample/export from the old TestCode/ScriptCorpus/Snippet surfaces. It does not absorb execution
helpers. The internal store is not returned to authors. It owns validated descriptor tables, source aliases, payload leases, history diff tables, and
the release digest. It contains no UClass, UFunction, mutable engine, executable AS pointer, test result, or expected-value callback.

Central activation admits structured `FAngelscriptTestCodeRegistration` batches
and publishes one immutable store. Publication swaps one immutable snapshot only
after validation succeeds. Failure keeps the previous valid snapshot, records
catalog errors, and does not present the failed batch as active. Initial absence
of a valid release is an empty unavailable source snapshot with diagnostics, not
successful resolution. This Change does not add a generated shard aggregate.

`GetSnapshot` pins a release. Convenience `Resolve(Ref)` takes the currently published snapshot once; a fixture resolving multiple inputs uses the
explicit snapshot overload. A later publication cannot change already pinned source or case data. Unknown IDs/tags and ambiguous legacy aliases return
structured errors. Aliases are accepted only if the admitted release explicitly declares them.

Query sorts by ordinal SourceId then VersionTag and returns copied descriptors. An empty query result is legitimate inspection, not executed coverage.
Sample is without replacement over that stable query order, uses the adopted SplitMix64-v1 recipe, and requires nonnegative Count no larger than the
candidate count. Invalid count is an error; it does not silently repeat or truncate candidates. Export writes exact payload bytes to the explicit
caller-supplied destination. Artifact/run path ownership is supplied by the caller; Export never derives a write target from an untrusted SourceId.

Root/diff materialization caches are keyed by release digest, SourceId, and tag. Cache entries are immutable sources, internally synchronized, and
bounded by the snapshot lifetime. They never use current runtime state as a patch base.

Example of checked public source resolution:

```cpp
TEST_METHOD(UsesTheSharedLiteralSource)
{
    const auto Snapshot = FAngelscriptTestCode::GetSnapshot();
    const FAngelscriptTestSourceRef Ref{
        TEXT("Frontend.Lexer.Literal"), TEXT("root")};
    const FAngelscriptTestSourceResult Resolved =
        FAngelscriptTestCode::Resolve(Ref, *Snapshot);
    if (!Resolved.IsSuccess())
    {
        TestRunner->AddError(Resolved.GetError()->Message);
        return;
    }
    const FAngelscriptTestSource ScriptSource = *Resolved.GetSource();
    ASSERT_THAT(IsTrue(ScriptSource.GetUtf8Bytes().Num() > 0));
    // Construct the frontend input and assert the actual token result here.
}
```

The example copies an immutable source lease before the result goes out of scope. It does not turn resolution success into a compilation or execution
claim.

## 5. Immutable tagged history and local builder

```cpp
struct FAngelscriptTestSourceVersion
{
    FString VersionTag;
    TOptional<FString> ParentTag; // Missing only for root.
    FString ContentHash;
    FString ChangeNote;
};
class FAngelscriptTestSourceHistory
{
public:
    const FString& GetSourceId() const;
    TConstArrayView<FAngelscriptTestSourceVersion> GetVersions() const &;
    const FAngelscriptTestSourceVersion* FindVersion(FStringView VersionTag) const;
    FAngelscriptTestSourceResult Resolve(FStringView VersionTag) const;
private:
    struct FData;
    TSharedRef<const FData, ESPMode::ThreadSafe> Data;
};
class FAngelscriptTestSourceHistoryResult
{
public:
    [[nodiscard]] bool IsSuccess() const;
    const FAngelscriptTestSourceHistory* GetHistory() const &;
    const FAngelscriptTestSourceHistory* GetHistory() const && = delete;
    TConstArrayView<FAngelscriptTestError> GetErrors() const &;
private:
    TOptional<FAngelscriptTestSourceHistory> History;
    TArray<FAngelscriptTestError> Errors;
};
class FAngelscriptTestSourceHistoryBuilder
{
public:
    explicit FAngelscriptTestSourceHistoryBuilder(FString SourceId);
    [[nodiscard]] FAngelscriptTestStatus AddRoot(FAngelscriptTestSource Source);
    [[nodiscard]] FAngelscriptTestStatus AddVersion(
        FString VersionTag,
        FString ParentTag,
        FAngelscriptTestSource Source,
        FString ChangeNote = FString());
    [[nodiscard]] FAngelscriptTestSourceHistoryResult Build();
private:
    FString SourceId;
    TArray<FAngelscriptTestSourceVersion> Versions;
    TArray<FAngelscriptTestSource> FullSnapshots;
    TArray<FAngelscriptTestError> Errors;
    bool bBuilt = false;
};
```

Builder mutation is case-local and single-threaded. It accepts immutable source values and keeps leases. It assigns tree SourceId and the explicit tag
to copies of those values. Local history payloads remain full snapshots; the builder does not generate diffs at runtime. The returned history is safe
for concurrent reads.

`AddRoot` accepts one root only. `AddVersion` rejects empty/reserved/duplicate tags and a direct self-parent. Parent existence, root reachability,
cycles, content redundancy, and the complete tree are checked by Build, which permits parents to be declared after children. Any failed Add records a
sticky builder error as well as returning status; ignoring a failure cannot make Build succeed. Build publishes no partial history. A successful Build
seals the builder; later mutation or a second Build reports InvalidLifecycle.

History enumeration is root first followed by stable topological order, with ordinal tag ordering for available peers. An identical child is rejected;
unchanged execution uses the existing tag. Empty payload is a real source value, not deletion. Missing tags return UnknownVersion, never root/latest
fallback.

External histories use the same public History type. Their internal FData holds root bytes and verified parent-to-child diffs. Each diff stores
expected parent and child hashes plus explicit bounded byte operations. The Python emitter owns diff generation. It verifies forward and reverse
reconstruction against authored snapshots before emission. C++ rejects malformed ranges, incorrect parent hashes, and incorrect reconstructed hashes
before returning a source. The validator and emitter share one history algorithm; compatibility dispatchers do not fork it.

An authored child may contain invalid AS. History structure validation does not compile AS and does not decide whether that tag may become runtime
active.

## 6. Case-local input bundle and identity binding

```cpp
struct FAngelscriptTestItemId
{
    FString CaseId;
    FString RowId; // Empty for an ordinary CQTest scenario.
};
struct FAngelscriptTestSourceEntry
{
    FString LogicalPath;
    FAngelscriptTestSource Source;
};
class FAngelscriptTestSourceBundleSnapshot
{
public:
    const FAngelscriptTestItemId& GetOwner() const;
    TConstArrayView<FAngelscriptTestSourceEntry> GetEntries() const &;
    const FAngelscriptTestSourceEntry* Find(FStringView LogicalPath) const;
};
class FAngelscriptTestSourceBundleResult
{
public:
    [[nodiscard]] bool IsSuccess() const;
    TSharedPtr<const FAngelscriptTestSourceBundleSnapshot, ESPMode::ThreadSafe>
        GetBundle() const;
    TConstArrayView<FAngelscriptTestError> GetErrors() const &;
};
class FAngelscriptTestSourceBundle
{
public:
    FAngelscriptTestSourceBundle(
        FAngelscriptTestItemId Owner,
        TSharedRef<const FAngelscriptTestCodeSnapshot, ESPMode::ThreadSafe> Catalog);
    [[nodiscard]] FAngelscriptTestStatus MakeLocalSourceId(
        FStringView LogicalPath, FString& OutSourceId) const;
    [[nodiscard]] FAngelscriptTestStatus AddLocal(
        FString LogicalPath, FAngelscriptTestSource AnonymousSource);
    [[nodiscard]] FAngelscriptTestStatus AddReference(
        FString LogicalPath, FAngelscriptTestSourceRef Ref);
    [[nodiscard]] FAngelscriptTestStatus AddHistoryVersion(
        FString LogicalPath,
        const FAngelscriptTestSourceHistory& History,
        FStringView VersionTag);
    [[nodiscard]] FAngelscriptTestSourceBundleResult Freeze();
};
```

Logical paths use forward slashes, are case-sensitive, and cannot be empty, absolute, contain backtracking components, or collide within a bundle.
They are compiler-facing logical file slots, not output paths. Nested relative paths are permitted. Entries are presented in ordinal logical-path
order by default; tests of discovery order explicitly permute the frontend input view without changing source identities.

`AddLocal` requires an anonymous source. It binds `CaseId/RowId/LogicalPath`, omitting RowId for ordinary scenarios, and tag root. The bound value is
local to this bundle. It is not permanently added to TestCode. The public source catalog is checked for a conflicting ID; local input cannot silently
shadow it. The original anonymous variable remains anonymous.

`MakeLocalSourceId` applies the same validation and composition so a local history builder can name its tree before binding a selected tag.
`AddHistoryVersion` accepts that local identity or a history from the pinned public catalog; it rejects a different local scope. `AddReference`
resolves only in the pinned catalog and retains the materialized source lease. Any same-slot insertion, including a different version of the same
source, is DuplicateLogicalPath. An update/reload step builds another bundle; it does not modify a frozen one.

Freeze is one-way and publishes only a valid complete set. Failures are sticky and result in errors rather than a partial bundle. An empty bundle is
valid for AS-free C++ cases. Bundle construction is single-threaded; its frozen entries and source leases are read-only and shareable.

Ordinary CQTest example with the terse inline macro and an explicit local slot:

```cpp
TEST_METHOD(OwnsInlineInput)
{
    FAngelscriptTestSourceBundle Inputs(
        {TEXT("Angelscript.UnitTest.Framework.Source.OwnsInlineInput"), FString()},
        FAngelscriptTestCode::GetSnapshot());
    const FAngelscriptTestSource ScriptSource = AS_TEST_SOURCE(R"AS(
        int GetValue()
        {
            return 42;
        }
        )AS");
    const FAngelscriptTestStatus Added = Inputs.AddLocal(TEXT("Value.as"), ScriptSource);
    ASSERT_THAT(IsTrue(Added.IsSuccess()));
    const FAngelscriptTestSourceBundleResult Frozen = Inputs.Freeze();
    ASSERT_THAT(IsTrue(Frozen.IsSuccess()));
    const auto* Entry = Frozen.GetBundle()->Find(TEXT("Value.as"));
    ASSERT_THAT(IsNotNull(Entry));
    ASSERT_THAT(AreEqual(FString(TEXT("root")), Entry->Source.GetReference()->VersionTag));
    // Pass the frozen bundle to the actual frontend operation here.
}
```

Local multi-tag assembly uses the same history lookup contract as external AS:

```cpp
FString LocalSourceId;
const FAngelscriptTestStatus Named = Inputs.MakeLocalSourceId(TEXT("Actor.as"), LocalSourceId);
ASSERT_THAT(IsTrue(Named.IsSuccess()));
FAngelscriptTestSourceHistoryBuilder HistoryBuilder(LocalSourceId);
const auto RootAdded = HistoryBuilder.AddRoot(AS_TEST_SOURCE(R"AS(
    class Actor
    {
        int Health;
    }
    )AS"));
ASSERT_THAT(IsTrue(RootAdded.IsSuccess()));
const auto BrokenAdded = HistoryBuilder.AddVersion(
    TEXT("broken-type"), TEXT("root"), AS_TEST_SOURCE(R"AS(
        class Actor
        {
            Missing Health;
        }
        )AS"));
ASSERT_THAT(IsTrue(BrokenAdded.IsSuccess()));
const auto RepairAdded = HistoryBuilder.AddVersion(
    TEXT("repaired"), TEXT("broken-type"), AS_TEST_SOURCE(R"AS(
        class Actor
        {
            int Health;

            int Armor;
        }
        )AS"));
ASSERT_THAT(IsTrue(RepairAdded.IsSuccess()));
const FAngelscriptTestSourceHistoryResult Built = HistoryBuilder.Build();
ASSERT_THAT(IsTrue(Built.IsSuccess()));
const FAngelscriptTestSourceResult Candidate = Built.GetHistory()->Resolve(TEXT("repaired"));
ASSERT_THAT(IsTrue(Candidate.IsSuccess()));
// Tree assembly and lookup have happened; no runtime reload has happened.
```

## 7. Typed rows, codecs, and immutable case catalog

```cpp
struct FAngelscriptTestSourceBinding
{
    FString LogicalPath;
    FAngelscriptTestSourceRef Source;
};
struct FAngelscriptTestCapabilityRequirement
{
    FString CapabilityId;
    bool bRequired = true;
};
template <typename TData>
struct FAngelscriptTestRow
{
    FString RowId;
    TData Data;
    TArray<FAngelscriptTestSourceBinding> Sources;
    TArray<FAngelscriptTestCapabilityRequirement> Capabilities;
};
struct FAngelscriptTestRowDescriptor
{
    FString RowId;
    FString PublicTestPath;
    TArray<FAngelscriptTestSourceBinding> Sources;
    TArray<FAngelscriptTestCapabilityRequirement> Capabilities;
};
struct FAngelscriptTestCaseDescriptor
{
    FString CaseId;
    FString RegistrationToken;
    FString AdapterId;
    FString DataSchemaId;
    uint32 DataSchemaVersion = 0;
    EAutomationTestFlags Flags;
    FAngelscriptTestSourceOrigin AuthoringOrigin;
    TArray<FAngelscriptTestRowDescriptor> Rows;
};
struct FAngelscriptTestRowExclusion
{
    FAngelscriptTestItemId Item;
    FString CapabilityId, Reason;
};
class FAngelscriptTestRowBuildContext
{
public:
    const FAngelscriptTestCodeSnapshot& GetSources() const;
    [[nodiscard]] FAngelscriptTestStatus GetCaseData(
        FStringView DataId, TConstArrayView<uint8>& OutJsonBytes) const;
    void AddError(FAngelscriptTestError Error);
    bool HasErrors() const;
    TConstArrayView<FAngelscriptTestError> GetErrors() const &;
};
class FAngelscriptTestCaseCatalogSnapshot
{
public:
    const FString& GetDigest() const;
    uint64 GetGeneration() const;
    const FAngelscriptTestCodeSnapshot& GetSources() const;
    TConstArrayView<FAngelscriptTestCaseDescriptor> GetCases() const &;
    TConstArrayView<FAngelscriptTestRowExclusion> GetExcludedRows() const &;
    const FAngelscriptTestCaseDescriptor* FindCase(FStringView CaseId) const;
    const FAngelscriptTestRowDescriptor* FindRow(
        FStringView CaseId, FStringView RowId) const;
    TConstArrayView<FAngelscriptTestError> GetErrors() const &;
};
class FAngelscriptTestCaseCatalog
{
public:
    static TSharedRef<const FAngelscriptTestCaseCatalogSnapshot, ESPMode::ThreadSafe>
        GetSnapshot();
    static FAngelscriptTestStatus ValidateSelection(
        const FAngelscriptTestCaseCatalogSnapshot& Snapshot,
        FStringView CaseId,
        FStringView RowId,
        FStringView ExpectedCatalogDigest,
        const FAngelscriptTestRowDescriptor*& OutRow);
};
```

The typed provider signature is fixed:

```cpp
TArray<FAngelscriptTestRow<FCaseType::FRow>> ProvideRows(
    FAngelscriptTestRowBuildContext& Build);
```

The context exposes pinned read-only source/case input data and a diagnostic sink. Providers may append structured build errors; they cannot acquire
an engine, construct a World, modify run results, or depend on prior row execution. The context owns leases for byte views returned by GetCaseData
until discovery finishes. A provider or codec copying data out must produce owned typed fields. Rows must never retain views into temporary JSON
strings or local provider arrays.

A named codec owns one concrete row schema, for example:

```cpp
struct FLexerDiagnosticRowCodec
{
    static constexpr const TCHAR* SchemaId = TEXT("LexerDiagnosticRow");
    static constexpr uint32 SchemaVersion = 1;
    static FAngelscriptTestStatus Decode(
        TConstArrayView<uint8> JsonBytes,
        TArray<FAngelscriptTestRow<FLexerDiagnosticCase::FRow>>& OutRows);
};
```

Each file-backed codec has a named, versioned JSON Schema in the plugin TestCode tool's `schemas/cases/` directory. Admission binds AdapterId,
SchemaId, and SchemaVersion to that schema. Python validates against this explicit schema without loading a compiled C++ codec; schema/codec parity is
proved with shared valid and invalid fixture vectors. The C++ codec independently enforces the same data contract before typed row publication. Static
C++ providers need no JSON schema; their compiled row type and build identity provide the type boundary.

The provider checks Decode and appends its error to Build before returning. Invalid schema/version, integer overflow, unknown source field, and
malformed expected diagnostic are errors with field paths. Decode publishes no partial OutRows. The codec is defined beside its row schema, never in a
generic source store. File-backed case metadata names that adapter/schema; static C++ providers need no JSON. There is no string-based operation
dispatcher or generic equality over all possible values.

The adapter owns the typed `TArray<Row>` once per catalog generation. The common catalog owns only immutable descriptors and retains the source
snapshot; it does not erase typed data into a universal variant. A per-generation typed adapter lease holds rows alive for an active run even if a new
catalog is published. Case metadata includes one execution owner. Ordinary CQTest may be inspected by metadata, but its methods are not registered a
second time through this catalog.

Rows sort ordinally by RowId for discovery. PublicCasePath begins with `Angelscript.UnitTest.` and is the CaseId. Public rows are
`<CaseId>.Rows.<RowId>`. RowId is a nonempty dot/slash-free leaf; it contains named axes when relevant and never derives from an array index.
Duplicate cases, rows, registration tokens, and conflicting public paths are errors. Empty providers are errors even if a codec returned no
diagnostic.

Capabilities are evaluated against the executing adapter/product capabilities, not inferred from the presence of source text. Required absence blocks
execution with an error. Explicit optional exclusion is visible in the selection/result projection and is not converted into a passed Automation test.
A selection containing no executable items cannot yield success. Inspection is not execution.
Optional-unavailable rows appear in GetExcludedRows and the discovery report but are omitted from GetTests. Required-unavailable rows retain a failing
diagnostic branch. Explicit excluded tokens fail before fixture creation; native global excludelist or AddInfo/true is not a skip protocol. Zero
executed rows follow Harness's existing Incomplete handling. Exclusions are separate from provider/admission errors and do not invalidate valid rows.

## 8. Per-row fixture, assertions, and cleanup

```cpp
class FAngelscriptDataCaseContext
{
public:
    const FAngelscriptTestItemId& GetItemId() const;
    FAutomationTestBase& GetAutomationTest() const;
    const FAngelscriptTestCaseCatalogSnapshot& GetCatalog() const;
    FAngelscriptTestSourceBundle& GetSources();
    void AddCleanup(TUniqueFunction<void()> Cleanup);
    bool IsCancellationRequested() const;
    const FString& GetCancellationReason() const;
    void AddObservation(FAngelscriptTestPhaseObservation Observation);
    void AddDiagnosticCapture(FAngelscriptTestDiagnosticCapture Capture);
private:
    FAngelscriptDataCaseContext(FAngelscriptTestItemId ItemId, FAutomationTestBase& Automation,
        TSharedRef<const FAngelscriptTestCaseCatalogSnapshot, ESPMode::ThreadSafe> Catalog,
        FAngelscriptTestRunResult& Result);
    // Owned by one running adapter item; construction/finalization are adapter-only.
    FAngelscriptTestItemId ItemId;
    FAutomationTestBase& AutomationTest;
    TSharedRef<const FAngelscriptTestCaseCatalogSnapshot, ESPMode::ThreadSafe> Catalog;
    FAngelscriptTestSourceBundle Sources;
    TArray<TUniqueFunction<void()>> CleanupActions;
    FAngelscriptTestRunResult& RunResult;
};
class FAngelscriptDataCase
{
public:
    explicit FAngelscriptDataCase(FAngelscriptDataCaseContext& Context);
    virtual ~FAngelscriptDataCase() = default;
    virtual void Setup();
    virtual void TearDown();
protected:
    FAngelscriptDataCaseContext& GetContext() const;
    FNoDiscardAsserter Assert;
private:
    FAngelscriptDataCaseContext& Context;
};
```

CaseType publishes its `FRow`, an inherited/forwarding constructor, and `void Run(const FRow&)`. It has no template virtual Run in the base; the typed
adapter calls the concrete method. `Assert` is initialized with the current Automation result and remains alive as long as the case. Therefore the
real CQTest `ASSERT_THAT(...)` expansion through `this->Assert` works in member Run, Setup, and TearDown. It is not documented as a free-function
matcher DSL.

The adapter creates context and a fresh CaseType for each selected row. It preloads declared external source bindings into the context's open bundle
before Setup. Inline cases may AddLocal before Freeze. Setup and Run execute on the UE Automation thread. A setup error skips Run. Whether Setup or
Run succeeds or returns after an assertion, the adapter calls TearDown once, then executes all registered cleanup callbacks in reverse order, then
destroys the case/context. Callbacks are registered before the operation that requires cleanup and must not throw. Teardown errors do not suppress
remaining cleanup. Cleanup callbacks may refer to case members because case destruction occurs last.

The base owns no implicit engine or World. BEFORE_ALL/AFTER_ALL sharing is not added to data cases. Read-only catalog/payload reuse is allowed;
mutable fixtures are per row. Callers do not invoke TearDown manually or run another row inside Run. Nested comparisons still belong in the visible
method body.

Deadline/cancellation checks are cooperative between stages and through the context. The synchronous adapter does not pretend to interrupt arbitrary
C++ inside a blocked Run. Harness retains the process timeout boundary. Cleanup is attempted when control returns and the process survives; a crash or
terminated process is never reported as in-process cleanup success.

Complete AS-free typed data example:

```cpp
class IntegerAdditionCase : public FAngelscriptDataCase
{
public:
    using FAngelscriptDataCase::FAngelscriptDataCase;
    struct FRow
    {
        int32 Left;
        int32 Right;
        int32 Expected;
    };
    void Run(const FRow& Row)
    {
        const int32 Actual = Row.Left + Row.Right;
        ASSERT_THAT(AreEqual(Row.Expected, Actual));
    }
    static TArray<FAngelscriptTestRow<FRow>> Rows(FAngelscriptTestRowBuildContext& Build)
    {
        return {
            {TEXT("ZeroIdentity"), {0, 7, 7}},
            {TEXT("MixedSigns"), {-2, 5, 3}},
        };
    }
};
AS_REGISTER_DATA_TEST(
    IntegerAddition,
    "Angelscript.UnitTest.Framework.Examples.IntegerAddition",
    IntegerAdditionCase,
    IntegerAdditionCase::Rows,
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);
```

This demonstrates the authoring/registration interface, not a proposed useful production coverage target. The implementation pilot must use a real
affected contract as its behavioral oracle. Class-only helpers belong privately in the class; public visibility is restored for FRow, construction,
hooks, Run, and the provider used by the adapter. No anonymous namespace is needed for this class.

## 9. Public Automation bridge and registration

```cpp
class FAngelscriptDataTestAdapter : public FAutomationTestBase
{
public:
    EAutomationTestFlags GetTestFlags() const override;
    FString GetBeautifiedTestName() const override;
    uint32 GetRequiredDeviceNum() const override;
    FString GetTestSourceFileName() const override;
    int32 GetTestSourceFileLine() const override;
protected:
    FAngelscriptDataTestAdapter(
        FString RegistrationToken,
        FString PublicCasePath,
        EAutomationTestFlags Flags,
        FAngelscriptTestSourceOrigin Origin);
    void GetTests(
        TArray<FString>& OutBeautifiedNames,
        TArray<FString>& OutTestCommands) const override;
    bool RunTest(const FString& SelectionCommand) override;
    virtual FAngelscriptTestStatus BuildTypedRows(
        FAngelscriptTestRowBuildContext& Build,
        TArray<FAngelscriptTestRowDescriptor>& OutDescriptors) = 0;
    virtual void ExecuteTypedRow(
        FStringView RowId, FAngelscriptDataCaseContext& Context) = 0;
};
template <typename TCase>
class TAngelscriptDataTestAdapter final : public FAngelscriptDataTestAdapter
{
public:
    using FRow = typename TCase::FRow;
    using FProvider = TArray<FAngelscriptTestRow<FRow>> (*)(FAngelscriptTestRowBuildContext&);
    TAngelscriptDataTestAdapter(
        FString RegistrationToken,
        FString PublicCasePath,
        FProvider Provider,
        EAutomationTestFlags Flags,
        FAngelscriptTestSourceOrigin Origin);
private:
    FProvider Provider;
    // Per-generation owned typed rows plus lookup by stable RowId.
};
AS_REGISTER_DATA_TEST(RegistrationToken, PublicCasePath, CaseType, Provider, Flags);
```

The template supplies the virtual typed-build/execute implementations and compile-time constraints: TCase derives from the base, exposes FRow, is
constructible from context, and has the required member Run signature. Provider must match FProvider exactly; passing an incompatible codec/provider
fails compilation, not late string dispatch. A static member provider is acceptable.

The macro creates one uniquely named adapter registration object per case family, captures the authoring anchor, and passes ordinary typed arguments
to its constructor. Static construction records registration metadata only. It does not evaluate providers, initialize the source store, or acquire
mutable fixtures. Replacement module startup publishes the generated release; catalog building then invokes providers once per generation and
validates all descriptors before normal discovery exposes their rows. No `_TEST_CLASS_IMPL` or modified CQTest engine source is used.

Selection commands encode only catalog generation/digest plus stable CaseId and RowId with a versioned length-delimited encoding. They never embed
source bytes, JSON rows, expected values, or pointers. RunTest checks the token against the pinned catalog, selects exactly one typed row, evaluates
capabilities, creates the fixture, executes it, and records its result. Unknown/stale commands fail before constructing the fixture. Provider order
does not alter selection.

The UE GetTests interface returns void. A provider/admission failure therefore cannot simply disappear into an empty test list. The adapter exposes
one reserved failing discovery leaf `<PublicCasePath>.Rows.CatalogError` for an invalid family; `CatalogError` cannot be an authored RowId. Running it
reports the structured catalog diagnostics and returns failure without constructing a case. Valid families expose only authored rows. Inspection also
retains catalog diagnostics. This fallback is not a placeholder success or a synthetic source coverage claim. Catalog-wide conflicts mark every
affected family invalid.

GetTests returns the relative beautified row name `Rows.<RowId>` because the adapter's beautified base is PublicCasePath. Verify complete Automation
names, not only those relative strings, in the registration self-test. Source navigation points to the case/provider anchor; source artifacts
separately identify each AS input. Existing ordinary CQTest names and ownership do not change.

## 10. Current frontend fixture boundary

```cpp
class FAngelscriptTestFrontendFixture
{
public:
    explicit FAngelscriptTestFrontendFixture(
        TSharedRef<const FAngelscriptTestSourceBundleSnapshot, ESPMode::ThreadSafe> Inputs);
    const frontend::asCSourceManager& GetSourceManager() const;
    frontend::asCIdentifierTable& GetIdentifiers();
    frontend::asCDiagnosticsEngine& GetDiagnostics();
    TSharedRef<frontend::asCSourceSnapshot, ESPMode::ThreadSafe> GetSnapshot() const;
    [[nodiscard]] FAngelscriptTestStatus FindFile(
        FStringView LogicalPath, frontend::asCSourceFileID& OutFileId) const;
    FAngelscriptTestDiagnosticCapture CaptureDiagnostics() const;
private:
    TSharedRef<const FAngelscriptTestSourceBundleSnapshot, ESPMode::ThreadSafe> Inputs;
    TSharedRef<frontend::asCSourceSnapshot, ESPMode::ThreadSafe> Snapshot;
    frontend::asCSourceManager SourceManager;
    frontend::asCIdentifierTable Identifiers;
    frontend::asCDiagnosticsEngine Diagnostics;
    TMap<FString, frontend::asCSourceFileID> Files;
};
```

Construction adds each logical file and its exact bytes to the native snapshot, then freezes it. It does not tokenize, parse, resolve declarations,
analyze bodies, execute script, or construct an AS engine. Snapshot mutability in the existing frontend pointer type does not grant permission to
mutate a frozen snapshot. The fixture retains both source bundle and native snapshot leases.

Tokenizer/preprocessor/compilation-session setup may be consolidated using the current public stage interfaces, but a stage is invoked explicitly by
the scenario and its return/diagnostics are observed there. Do not invent a generic CompileAndAssert result or anticipate unsettled Builder APIs in
this attachment. The coordinated Builder work owns those production interfaces. Small current snapshot/lexical fixtures can be implemented and tested
independently.

Identifiers and diagnostic submission are run-local. Parallel work is allowed only where the actual frontend API supports it; stable diagnostics are
collected through `frontend::asCCollectingDiagnosticConsumer`. CaptureDiagnostics retains source leases and copies the real
`frontend::asSDiagnosticRecord` values. It does not reduce them to text-only `FDiagnosticObservation` records.

## 11. Results, diagnostics, and artifact writer

```cpp
enum class EAngelscriptTestOutcome : uint8
{
    Passed, Failed, Skipped, Unavailable, Cancelled, TimedOut, Crashed,
};
enum class EAngelscriptTestEvidenceStage : uint8
{
    Inventoried, StructurallyValidated, Compiled, Executed, ExternallyObserved,
};
enum class EAngelscriptTestCleanupOutcome : uint8
{
    NotRequired, Pending, Succeeded, Failed, NotCompleted,
};
struct FAngelscriptTestUsedSource
{
    FAngelscriptTestSourceRef Reference;
    FString LogicalPath;
    FString ContentHash;
    FAngelscriptTestSource SourceLease;
};
struct FAngelscriptTestDiagnosticCapture
{
    TSharedRef<frontend::asCSourceSnapshot, ESPMode::ThreadSafe> Snapshot;
    TArray<frontend::asSDiagnosticRecord> Records;
    TArray<FAngelscriptTestUsedSource> Sources;
};
struct FAngelscriptTestPhaseObservation
{
    FString Phase;
    FString Operation;
    EAngelscriptTestEvidenceStage EvidenceStage;
    TArray<FString> Events;
    TArray<FAngelscriptTestDiagnosticCapture> Diagnostics;
};
struct FAngelscriptTestRunResult
{
    FAngelscriptTestItemId ItemId;
    FString AdapterId;
    FString DataSchemaId;
    uint32 DataSchemaVersion = 0;
    FString CatalogDigest;
    FString SourceReleaseDigest;
    FString GeneratorRecipe;
    FString GeneratorVersion;
    TOptional<uint64> Seed;
    TArray<FString> NamedAxes;
    FString BuildIdentity;
    TArray<FAngelscriptTestUsedSource> Sources;
    TArray<FAngelscriptTestCapabilityRequirement> RequestedCapabilities;
    TArray<FString> CapabilityDecisions;
    TArray<FAngelscriptTestPhaseObservation> Phases;
    TArray<FAngelscriptTestError> InfrastructureErrors;
    EAngelscriptTestOutcome Outcome;
    EAngelscriptTestCleanupOutcome Cleanup;
    double DurationSeconds = 0.0;
    FString HarnessCommand;
    FString HarnessRunId;
    FString AutomationReportPath;
    TArray<FString> ArtifactPaths;
};
class FAngelscriptTestReportWriter
{
public:
    static FAngelscriptTestStatus Write(
        const FAngelscriptTestRunResult& Result,
        const FString& ManagedArtifactDirectory,
        TArray<FString>& OutWrittenFiles);
};
```

The context/adapter owns the mutable run record while the item runs. The record is sealed after observations and cleanup; serialization receives a
const value. RunResult owns or leases every input needed after fixture destruction. Its data must not point into a destroyed AST/session/World.
Diagnostic records retain the snapshot needed to resolve ranges; serialized ranges name logical sources and byte intervals, not session-local numeric
IDs alone.

Typed expectations remain in FRow and C++ assertions. Phase Events contain explanatory evidence, not executable oracle strings or a universal value
system. Diagnostics preserve ID, severity, primary and related ranges, typed arguments, fix-its, and deterministic order. A rendered text comparison
is used only for an explicit renderer behavior test. A failed expected-negative compile can produce Outcome Passed with Compiled evidence, but never
Executed evidence by inference.

Passed requires the actual selected row to run its required proof, with no unexpected assertion/infrastructure error and successful required cleanup.
Required-unavailable and empty selections cannot pass. Optional skipped rows remain visibly skipped/excluded; the bridge must not translate AddInfo
plus return true into a skip. Process exit and Harness result remain independent success conditions above an individual row's assertions.

Some process facts cannot be known inside the dying process. Harness correlates build/run/report identity and marks timeout/crash/incomplete cleanup
when it collects process evidence. An in-process record leaves unavailable correlation fields explicitly absent/empty; it never fabricates RunId or
successful cleanup. The post-run projection may enrich those fields without editing source truth.

The adapter derives its report root from UE's existing `-ReportExportPath`, already passed by Harness `Operations.ps1:586` and `Suites.ps1:244`; it
does not invent an injected Harness run context. Per-item artifacts live below that root. Interactive execution without this option uses a clearly
uncorrelated unique local `Saved/AngelscriptTests/<InvocationId>/` directory. Managed items allocate unique paths below `ReportExportPath/Angelscript/`.
The writer records no fabricated Harness RunId; external Harness collection performs
run/report correlation. Write uses that explicit derived artifact directory. It validates resolved output paths remain within that directory, writes
exact materialized source bytes plus metadata/diagnostics/reproduction selection, and reports I/O failure. SourceId and logical path are metadata, not
unchecked filesystem paths. Writes stage complete item output before publishing its index. A failed write does not erase primary assertion evidence or
mark the run successful. The writer does not update authored manifests, admission stages, or source PASS fields.

## 12. End-to-end ownership and deferred runtime extension

The supported first-slice call sequence is:

1. Replacement module activates structured TestCode registrations and
   validates/publishes source and case input snapshots; static family
   registrations contain no engine and no generated shard aggregate.
2. A family adapter invokes its typed provider with read-only Build context;
   decoder/provider errors become catalog diagnostics before normal row exposure.
3. Automation selects a stable case/row token tied to the catalog digest.
4. RunTest pins that catalog generation, resolves declared source bindings,
   validates capability selection, and constructs one context and CaseType.
5. Setup runs; Run performs visible actions and assertions if setup succeeded.
   Inline AddLocal and explicit frontend phase calls happen inside that scope.
6. TearDown and reverse-order cleanup execute once where the process survives;
   captured source/diagnostic leases remain alive in the run result.
7. The result writer emits managed artifacts; Harness supplies final process and
   run correlation. No runtime evidence is inferred from generator/catalog success.

Future runtime reload fixtures may consume TestCode/History and extend per-step observations with attempted, active, and last-good source references.
They do not change Resolve or history ancestry. A failed source tag may parent a later repair without ever becoming the active runtime tag. Typed C++
steps own operation order, module slot preconditions, and observable expectations. Deletion is an explicit operation. Source text or an empty diff is
not an engine operation.

No concrete fake `FAngelscriptEngine`, World, VM/cache/JIT, or reload executor is defined here to make those future examples appear ready. The first
slice can prove source histories, row registration, local snapshots, diagnostics and cleanup using current product interfaces. Later adapter
acceptance must execute the real runtime behavior before its guide examples are promoted as available.

The owning tasks select exact proofs for these interfaces, including schema/codec fixture parity and row identity, lifetime, error, cleanup,
source-history, and artifact contracts. No unconditional full-suite gate is introduced.
