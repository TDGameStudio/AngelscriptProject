---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
    "3.1": ["1.3", "2.2"]
    "3.2": ["3.1"]
    "4.1": ["3.2"]
    "4.2": ["4.1"]
---

# Shared AngelScript test code database

## Goal

Provide two input carriers, immutable versioned materials and checked shared retrieval without script execution.

## Architecture

Static factories and Windows raw resources feed one Builder/admission pipeline and Case index. A startup coordinator publishes the provider snapshot; consumers query immutable values. See [design](design.md).

## Global constraints

- The user explicitly authorized implementation of this exact Change after its creation. A checkbox still changes only after its task proof succeeds.
- Read attachments/INDEX.md and attachments/data/scope-ownership.md first; old unified-framework overlapping tasks must not run concurrently and their disposition requires an authorized old-record update.
- Keep WITH_ANGELSCRIPT_UNITTESTS disabled; framework/fixtures use WITH_ANGELSCRIPT_TESTS and tests also use WITH_DEV_AUTOMATION_TESTS.
- Preserve unrelated dirty files; implementation belongs in Plugins/Angelscript, author fixtures in AngelscriptTestCode, and Source/AngelscriptProject stays outside scope.
- Names and exact shapes come from the glossary/design. Labelled planning assumptions are not fabricated questionnaire approvals.
- Before each C++ behavioral proof use Harness ue.build for a fresh AngelscriptProjectEditor Win64 Development binary after RED-test edits and again after implementation edits. Stale binaries are not proof. Run imports/context in the current PowerShell process.
- All generated fixtures and scripts named below are future task outputs, not existing verified tools. No direct editor launches, root Tools wrappers, loose-disk fallback or engine-source patches.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement / acceptance | Tasks |
|---|---|
| Owned source materials | 1.1, 1.2 |
| Path identity and complete versions | 1.2, 1.3, 2.1 |
| Checked material construction | 1.2, 1.3 |
| Version-aware positional data | 1.1, 1.3 |
| Deferred cross-module activation | 2.2, 4.1 |
| Atomic and deterministic batch admission | 2.1, 2.2 |
| Reliable exact and filtered queries | 2.1, 4.1 |
| Embedded original file delivery and incremental proof | 3.1, 3.2 |
| Verified guidance and scoped closure | 4.2 |

Self-review 2026-09-13: coverage mapped; no placeholder phrases; symbols mapped to producing tasks and glossary. Record: attachments/data/planning-validation.md.

## [x] 1.1 Provide owned normalized and exact source values

Implement immutable Source, error/status carriers and origin storage without registration or AS engine dependencies.

**Outcome**

Implement immutable Source, error/status carriers and origin storage without registration or AS engine dependencies.

**Interfaces**

Consumes UE Core TSharedRef/TConstArrayView and replacement CQTest wiring in AngelscriptTest.Build.cs:80. Produces glossary-owned names: Names and public file spellings follow attachments/drafts/glossary.md.

```text
FAngelscriptTestSource::FromBytes(TConstArrayView<uint8>);
FAngelscriptTestSource::GetBytes()/GetAnnotations()/GetOriginMap() const &;
AS_TEST_SOURCE(Literal); AS_TEST_SOURCE_EXACT(Literal);
FAngelscriptTestSourceOriginMap; FAngelscriptTestError; FAngelscriptTestStatus;
```

**Cases**

1. **ExactBytesOutliveInput** — new RED
   Given temporary bytes 61 00 FF, when Source owns them and input storage is destroyed, then its length is 3 and bytes are unchanged.

2. **EnvelopeAndIndent** — new RED
   Given one literal envelope, an extra intentional blank line and four common spaces, then normalization removes exactly one envelope/common prefix and preserves the intentional blank; compare hand-written bytes and author locations.

3. **NoImplicitRegistration** — new RED
   Given an empty literal, when constructed, then Source is valid and no registration callback runs; this unit does not require the future global database.

4. **MixedIndent** — new RED
   Given lines prefixed by tabs and spaces, then only their exact shared prefix is removed, not a guessed visual indentation width.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSource.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSource.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceTypes.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceOriginMap.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestAnnotations.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/SourceTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. Each named case is registered in the Source class under the following exact prefix. Fresh build requirements are in Global constraints.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Source'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

- RED build run `570376859f024d0f9b846e21ab1b3766` succeeded with the deliberately empty Source skeleton. Focused test run `9137dc40e9cd4e3299273be2f1765b7e` then failed all 4/4 behavioral cases, proving the missing ownership/normalization behavior rather than a compilation or environment failure.
- Final fresh build run `8ddd1aa7803c46aaacab0059e30227ad` succeeded. Proving test run `c7a08dd8f88a41f197ceefa63d2ee8b5` succeeded with 4/4 tests, zero warnings and zero errors: ExactBytesOutliveInput, EnvelopeAndIndent, NoImplicitRegistration and MixedIndentUsesExactCommonPrefix.
- Exact-source coverage includes bytes `61 00 FF` surviving input destruction and `AS_TEST_SOURCE_EXACT` retaining its entire literal envelope. Normalized coverage checks hand-written original-byte offsets `5, 10, 11, 16, 20`, the C++ host line, an intentional empty line, and a mixed space/tab prefix.
- Naming assumed: `FAngelscriptTestSource::FromLiteral` is the public macro implementation hook; `FAngelscriptTestSourceOriginMap::GetHostFile`, `GetHostLine` and `MapToOriginalByteOffset` expose the planned origin storage; `FAngelscriptTestAnnotations::Num` provides the minimal empty-state query. Status factory/accessor names are `Success`, `Failure`, `IsSuccess` and `GetErrors` following the approved design shape.
- Omitted Quick, Performance, Integration, broader Framework and full plugin suites: task 1.1 changes only the new AS-independent Source value and its exact focused selector provides complete current coverage.

## [x] 1.2 Build complete versioned Cases with accumulated errors

Construct one file's version graph into immutable Cases and an owning BuildResult; add the separate single-case lookup Result. Failed builds have no partial admission payload.

**Outcome**

Construct one file's version graph into immutable Cases and an owning BuildResult; add the separate single-case lookup Result. Failed builds have no partial admission payload.

**Interfaces**

Consumes Source and error/status from 1.1. Produces glossary-owned names: Names and public file spellings follow attachments/drafts/glossary.md.

```text
FAngelscriptTestCodeBuilder(const FAngelscriptTestFileMeta&);
void AddRoot(FAngelscriptTestVersionMeta, FAngelscriptTestSource);
void AddVersion(FAngelscriptTestVersionMeta, FAngelscriptTestSource);
FAngelscriptTestCodeBuildResult Build();
FAngelscriptTestSourceCase::GetFileMeta()/GetVersionMeta()/GetSource();
FAngelscriptTestSourceResult::IsSuccess()/GetCase()/GetError();
```

**Cases**

1. **IndependentErrors** — new RED
   Given duplicate node x and a separate empty Summary, Build returns both reliable errors and no success payload.

2. **GraphAndForwardParent** — new RED
   Given complete root/left/right bodies 0/1/2 and right declared before root, Build succeeds and preserves each body; x->y->x instead fails.

3. **CaseLifetime** — new RED
   Given a copied Case and Source, when Builder, BuildResult, lookup Result and the original Case are released, then metadata/bytes remain consistent without retaining sibling Cases.

4. **BrokenASAndConsumedBuilder** — new RED
   Given int X=Missing; with valid metadata, first Build succeeds without AS compilation; a second Build fails as consumed.

5. **BorrowedAccessorBoundary** — new RED
   Compile-time requires checks reject borrowed accessors on rvalues; an lvalue Case remains copyable.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceCase.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceResult.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestCodeBuilder.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestCodeBuilder.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestCodeBuildResult.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceTypes.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/BuilderTests.cpp
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. Each named case is registered in the Builder class under the following exact prefix. Fresh build requirements are in Global constraints.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Builder'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

- RED build run `a09bf60949984504b05af33f34d0bbd2` succeeded with a checked but deliberately unimplemented Builder. Focused run `29aa3d5825564387a5682b4617f1db50` discovered 5 tests: the 4 structural behavior cases failed and the compile-time BorrowedAccessorBoundary passed.
- Final fresh build run `b3ae5b80f56d4b12ae7c27a7555afc66` succeeded. Proving run `b3b7e58b32ab4edba981ade348336c79` executed and passed all 5/5 exact Builder tests with zero warnings and zero errors.
- IndependentErrors returned exactly DuplicateVersionTag and EmptyVersionSummary with no success payload. GraphAndForwardParent retained complete bodies 0/1/2 despite declaration order and rejected x->y->x. BrokenASAndConsumedBuilder accepted `int X=Missing;` without AS compilation and rejected the second Build.
- SourceCase owns one immutable shared FData containing one file-meta reference, one version meta and one Source; it has no database, graph or sibling reference. CaseLifetime retained a copied Case through Builder/BuildResult/lookup-Result destruction, then retained Source bytes after Case destruction.
- A private friend test probe inspects the move-only admission payload; no public BuildResult query/database surface was added. SourceResult retains exactly one private Case/Error branch, and all borrowed Case/Result accessors reject rvalues at compile time.
- Naming assumed: error codes `UnsupportedFileVersion`, `InvalidFileTag`, `EmptyFileSummary`, `EmptyTopic`, `InvalidVersionTag`, `EmptyVersionSummary`, `RootTagRequired`, `RootParentForbidden`, `RootMustUseAddRoot`, `VersionParentRequired`, `InvalidParentTag`, `DuplicateVersionTag`, `MissingRoot`, `MultipleRoots`, `MissingParent`, `VersionCycle` and `BuilderConsumed` identify stable structural reasons. No additional public query name was introduced.
- Diagnostic compile run `2f8e7938dc0248a085292f72352ef632` proved TArray::Emplace cannot inherit Builder friendship; constructing the private Case in Builder before TArray::Add resolved that access-boundary issue without widening the constructor.
- Omitted Quick, Performance, Integration and broader Framework/full-plugin suites: this task changes only the new Builder/value layer and its five-case selector covers the bounded behavior.

## [x] 1.3 Parse v1 containers and generic positional markers

Implement the complete author grammar and explicit inline annotation parsing with UTF-8 byte offsets and author mapping; no diagnostics expectations or AS compiler.

**Outcome**

Implement the complete author grammar and explicit inline annotation parsing with UTF-8 byte offsets and author mapping; no diagnostics expectations or AS compiler.

**Interfaces**

Consumes Source, metadata and Builder from 1.1-1.2. Produces glossary planning interfaces: Names and public file spellings follow attachments/drafts/glossary.md.

```text
FAngelscriptTestCodeBuildResult FAngelscriptTestSourceParser::Parse(
    FStringView FileTag, TConstArrayView<uint8> Bytes);
FAngelscriptTestSourceParseResult FAngelscriptTestAnnotations::Parse(
    FAngelscriptTestSource Source);
```

**Cases**

1. **FullContainer** — new RED
   Given design.md Counter with child before root, Parse(Language/Counter,bytes) yields both exact complete bodies and separate file/node metadata; v1 is not a node Tag.

2. **BytePositions** — new RED
   Given UTF-8 é/** @point p */x, p=2; given a/** @range-begin r */bc/** @range-end r */d, clean abcd has r=[1,3), with author origins preserved.

3. **EscapeAndMalformedMarkers** — new RED
   Given /** @@point p */, emit literal /** @point p */ without p; duplicate points, missing endpoints, crossing ranges and unknown directives each fail without Source success.

4. **EmptyAndLineEndings** — new RED
   Given an empty root and separately a CRLF/BOM container, empty succeeds and output LF retains correct origin lines; invalid metadata UTF-8 fails.

5. **InlineParity** — new RED
   Equivalent explicit inline annotation input and container body yield equal clean bytes/offsets but distinct truthful C++/.as author origins.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceParser.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceParser.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceParseResult.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestAnnotations.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestAnnotations.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceOriginMap.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/ParserTests.cpp
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. Each named case is registered in the Parser class under the following exact prefix. Fresh build requirements are in Global constraints.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Parser'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

- RED build run `d219cfdae3424abaabe7a4b1659e3699` succeeded with checked NotImplemented container/annotation results. Focused run `bcaa65eb9b1342909d16407429b4487d` discovered and behaviorally failed all 5/5 Parser cases.
- Final fresh build run `e8b82ead5029491c9cc1bbe9eae4fb71` succeeded. Proving run `a559a818b6c744ffbea49cbea77901d5` executed and passed all 5/5 exact Parser tests with zero warnings and zero errors.
- FullContainer parsed child-before-root into two complete independent bodies and kept file v1 metadata separate from node Tags. EmptyAndLineEndings accepted an empty root, removed one BOM, normalized CRLF to LF, preserved body line 9 and mapped the next clean byte across the two original CRLF bytes; invalid UTF-8 failed.
- BytePositions proved UTF-8 byte coordinates (`é` point = 2), breakpoint = 0 and half-open range [1,3). EscapeAndMalformedMarkers proved one-pass @@ unescaping and checked duplicate point, missing range end, crossing range and unknown directive failures with no successful Source.
- InlineParity produced identical bytes/point offsets through explicit C++ parsing and container parsing while retaining distinct truthful C++ and `Language/Parity.as` origins. Diagnostic run `009da3ab88b748b2a7c7d6dfd4e33bc1` had 4/5 passing and isolated a test anchor one line above the macro invocation; moving the invocation to the asserted line fixed the test without changing production behavior.
- Naming assumed: `FAngelscriptTestSourceRange`, `FAngelscriptTestAnnotations::GetPoint`, `GetBreakpoint`, `GetRange`, and `FAngelscriptTestSourceParseResult::GetSource`/`GetErrors` provide direct checked positional access. Parser/annotation errors use reason codes including InvalidUtf8, malformed/unknown/duplicate metadata or annotation directives, missing version/endpoints and CrossingRange.
- Omitted Quick, Performance, Integration and broader Framework/full-plugin suites: the pure parser has no AS engine dependency and the exact five-case selector covers both public parsing paths and their negative contracts.

## [x] 2.1 Admit immutable batches and provide reliable queries

Implement shared database storage and isolated self-test instances, atomic admission, deterministic conflicts and owned error retention. Production discovery follows in 2.2.

**Outcome**

Implement shared database storage and isolated self-test instances, atomic admission, deterministic conflicts and owned error retention. Production discovery follows in 2.2.

**Interfaces**

Consumes Case/BuildResult/Status from 1.2. Produces exported center and module-private detached admission seam: Names and public file spellings follow attachments/drafts/glossary.md.

```text
FAngelscriptTestCode::GetInstance();
FAngelscriptTestCode::Get(FileTag, VersionTag) const;
FAngelscriptTestCode::FindCases(FileTag, RequiredVersionTopics, OutCases) const;
FAngelscriptTestCode::FindFiles(RequiredFileTopics, OutFiles) const;
FAngelscriptTestCode::IsActivated() const;
FAngelscriptTestCode::GetRegistrationErrors() const;
```

**Cases**

1. **AtomicIsolation** — new RED
   Given A has two files with one invalid structure and B is valid, admit neither A file and permit exact B lookup.

2. **SymmetricConflict** — new RED
   Given A and B both claim Language/Counter and each has another file, reject both whole batches in either order; unrelated C succeeds.

3. **QueryCompleteness** — new RED
   Given an unreadable batch and admitted Language/Other, global FindFiles fails without overwriting output; exact Get and FindCases for Other succeed.

4. **TopicAndUnknown** — new RED
   Given file X has A/B and Y has A, AND(A,B) returns X; empty filter returns X/Y ordinally; Z returns successful empty; Get(X,missing) fails.

5. **DetachedOwners** — new RED
   After an isolated center is destroyed, copied Cases/Sources retain matching metadata and bytes without parent strong cycles.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/DatabaseTests.cpp
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. Each named case is registered in the Database class under the following exact prefix. Fresh build requirements are in Global constraints.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Database'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

- RED build run `c0edf57e6a204743b632bfb0da5e7dcc` succeeded with the detached-center/database skeleton. Focused run `02e72ebfafa04a74abcb4e1e50fcec39` discovered and behaviorally failed all 5/5 Database cases because no files were published.
- Final fresh build run `cba2688263d9441c9b65f0b1fe9664ad` succeeded. Proving run `47d0054d6afc431b8e579e2eed42a614` executed and passed all 5/5 exact Database tests with zero warnings and zero errors.
- AtomicIsolation rejected both files from invalid batch A while exact B lookup succeeded. SymmetricConflict rejected both whole conflicting batches in A/B and B/A order, including their nonconflicting companion files, while unrelated C remained available.
- QueryCompleteness retained an existing output array when an unreadable batch made global FindFiles fail; exact Get and AND-filtered FindCases for admitted Language/Other still succeeded. TopicAndUnknown proved AND filtering, empty-filter ordinal X/Y output, successful zero match and checked unknown-version failure.
- DetachedOwners retained matching file/version metadata and source bytes after lookup Result and isolated center destruction. Storage contains only per-file maps of lightweight Cases; Cases do not reference the center or Parent objects.
- The multi-file admission batch and detached construction remain private friend seams for registration/resource adapters and tests; the public API is exactly GetInstance/Get/FindCases/FindFiles/IsActivated/GetRegistrationErrors.
- Naming assumed: admission/query reason codes `AlreadyActivated`, `EmptyAdmissionFile`, `DuplicateFileTagInBatch`, `MixedFileBuildResult`, `FileTagConflict`, `NotActivated`, `UnknownFileTag` and `UnknownVersionTag`. No public admission method or alternate singleton name was introduced.
- Omitted Quick, Performance, Integration and broader Framework/full-plugin suites: task 2.1 is the isolated in-memory catalog layer; startup/static registration is separately owned by 2.2.

## [x] 2.2 Coordinate deferred factories after startup loading

Collect static metadata/function pointers, activate one global startup snapshot, retain status and reject reentry/late registration without starting the legacy engine.

**Outcome**

Collect static metadata/function pointers, activate one global startup snapshot, retain status and reject reentry/late registration without starting the legacy engine.

**Interfaces**

Consumes 2.1; current AngelscriptTestModule.cpp:23 StartupModule and Core/AngelscriptTestModule.h; UE evidence is in the indexed findings. Produces: Names and public file spellings follow attachments/drafts/glossary.md.

```text
FAngelscriptTestCodeRegistration(FileMeta, FCodeFactory,
    OwnerModule = UE_MODULE_NAME, SourceFile = __builtin_FILE(),
    SourceLine = __builtin_LINE());
FAngelscriptTestStatus FAngelscriptTestCode::ActivateRegistrations();
```

**Cases**

1. **StaticDeferred** — new RED
   Register a counter-incrementing factory in an isolated registry; count stays zero and Get fails before activation.

2. **OnceAndReentry** — new RED
   Activate two factories twice; each count equals one. Nested activation reports reentry and does not deadlock.

3. **BarrierBranches** — new RED
   Completion=false waits for notification; completion=true on installation activates immediately. Shutdown removes the handler in both cases.

4. **FailureAndLate** — new RED
   A failed batch and valid batch finish activation with retained errors and IsActivated=true; a later registration cannot mutate published data.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCodeRegistration.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCodeRegistration.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.cpp
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTestModule.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/RegistrationTests.cpp
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. Each named case is registered in the Registration class under the following exact prefix. Fresh build requirements are in Global constraints.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Registration'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

- RED build run `268bb8b4496a4285b4f1aa0b3c4e946e` succeeded with inert registry/activation/barrier behavior. Focused run `500a69c4c3bc47f4ac4279e799e0a852` discovered and behaviorally failed all 4/4 Registration cases while factory counts remained deferred at construction.
- Final fresh build run `4fd97f6627df46c895f584ccf71685c6` succeeded. Proving run `6f064434a3db4a70a8b3f1e87c9d16e8` executed and passed all 4/4 exact Registration tests with zero warnings and zero errors.
- StaticDeferred proved registration construction copies identity/callback without invocation and Get fails before activation. OnceAndReentry proved two factories execute once across repeated activation and nested activation returns ReentrantActivation without locking or deadlock.
- BarrierBranches exercised the production activation-barrier type with injected delegates: incomplete startup installed/removes a one-shot handler; already-complete startup invoked immediately without installing one; Shutdown left both delegates unbound. The Automation process log also recorded the actual replacement `AngelscriptTest` module startup.
- FailureAndLate published the valid batch beside a failed batch, retained owner/source errors with IsActivated=true, and rejected a post-snapshot registration without executing its factory or mutating published data. Repeated activation returned the retained failure.
- Registry locking covers only append/snapshot/bound-center state. Activation copies the record snapshot, releases the lock, then invokes function pointers and admits batches. Module Startup installs against IsEngineStartupModuleLoadingComplete/OnAllModuleLoadingPhasesComplete under WITH_ANGELSCRIPT_TESTS; legacy engine-pool startup remains under the disabled legacy gate.
- Naming assumed: `FAngelscriptTestCodeActivationBarrier` is the module/testable one-shot lifecycle helper; lifecycle reason codes are `ReentrantActivation`, `NullRegistrationFactory`, `LateRegistration` and `AlreadyActivated`. The public registration/activation names otherwise match the approved glossary.
- Diagnostic build run `765f4a65ae9349c199481165caf329e5` isolated a wrong `Misc/GuardValue.h` include; UE 5.8 defines TGuardValue in `Templates/UnrealTemplate.h`, and the corrected include built successfully.
- Omitted Quick, Performance, Integration and broader Framework/full-plugin suites: the exact selector covers registration state and the actual test process loads the modified module; resource and second-DLL adoption are downstream tasks 3.2/4.1.

## [x] 3.1 Embed raw resources with verified incremental builds

Implement deterministic index/RC generation and installed-engine integration. Prove actual edit and file-set RC/link updates. A private probe reads artifacts; the production database reader follows in 3.2.

**Outcome**

Implement deterministic index/RC generation and installed-engine integration. Prove actual edit and file-set RC/link updates. A private probe reads artifacts; the production database reader follows in 3.2.

**Interfaces**

Consumes UBT resource evidence and AngelscriptTest.Build.cs. Produces a Build.cs-private helper, a stable module-owned RC wrapper and staged-fixture proof driver; no new runtime public API: Names and public file spellings follow attachments/drafts/glossary.md.

```text
AngelscriptTest.Build.cs::TestCodeResourceGenerator: sorted relative path -> RC + UTF-8 index;
AngelscriptTestCode.rc: stable module resource input -> generated Intermediate RC entries;
AS_TEST_INDEX = { version: v1, files: [{ path, id }] };
TestCodeResourceIncremental.ps1 -WorkspaceRoot <root>;
```

**Cases**

1. **OriginalEmbeddedBytes** — new RED
   Build an Editor DLL with the Counter fixture; a private Resources probe reads AS_TEST_INDEX and raw owner-DLL bytes exactly equal the authored file.

2. **EditAddRenameDelete** — new RED
   In a unique staged author root, change Counter, add Added.as, rename it to Renamed.as and delete it across separate builds; each resource inventory and payload equals that authored state without stale entries.

3. **NoOpAndFailure** — new RED
   Two identical builds leave generated index/RC hashes and timestamps unchanged; path conflicts fail generation without replacing prior valid outputs.

4. **ResourceCoexistence** — new RED
   Source resources coexist with readable UE binary version resources and collision-free IDs.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Resources/AngelscriptTestCode.rc
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/ResourceProbeTests.cpp
+Plugins/Angelscript/Tests/Tools/TestCode/TestCodeResourceIncremental.ps1
+AngelscriptTestCode/Language/Counter.as
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. The driver must run and verify each staged transition and its exact Resources probe via Harness ue.build/ue.test, retain source/DLL hashes and throw on any failure. Invocation alone is not proof.

```powershell
& ./Plugins/Angelscript/Tests/Tools/TestCode/TestCodeResourceIncremental.ps1 -WorkspaceRoot (Get-Location).Path
```

**Notes**

The driver stages only uniquely owned fixture paths under a verified temporary root, restores its settings in finally and invokes Harness routes in the current PowerShell process. Implement and test the deterministic generator before wiring RC actions; then prove their real dependency behavior. If installed-engine UBT cannot satisfy discovery/invalidation with a supported hook, record the failed evidence and replan the carrier. A generator-only test cannot complete this task.

**Evidence**

- RED build run `fe13678b61854e239724496c214123dd` succeeded after adding the resource probe; focused run `eb83193fda4247909347a2740fa804c0` discovered the exact test and failed 1/1 because `AS_TEST_INDEX` did not exist.
- Local UE 5.8 evidence corrected two private integration assumptions before GREEN: `RulesAssembly` does not compile an arbitrary adjacent helper `.cs`, and `UEBuildBinary::CompileResourceFiles` omits the default resource whenever a module supplies a custom RC. The generator therefore lives in `AngelscriptTest.Build.cs`, generated entries explicitly include `Default.rc2`, and the stable wrapper's `FileItem` metadata cache is reset after changed generation so the same build observes the new timestamp.
- Exact driver `TestCodeResourceIncremental.ps1` completed successfully and retained evidence at `Saved/Harness/TestCodeResource/20260913-151314-d06acebe79954acfaadd77f989d089f9/Evidence.json`: 8 Harness builds and 7 exact Harness tests covered initial, edit, add, rename, delete, no-op, conflict failure and canonical restore.
- Positive build/test pairs were `6c6f489382454176b651613cb8deb99b`/`d696fe2c69f3443f960dadd97c6209af`, `aae8e5474a914f7585be6994aead13c4`/`3c95c6b45628436fbfe13147f6f88a4b`, `445bd426006d4aba96559ea08d3abda7`/`fe564562fb0443d78de7dc0143d59684`, `6183c6f24f8e4ee39468942718100ae6`/`518fcfcba1db4137896c814c14565169`, `d7d7b6af9eae449ea428612571a264b9`/`e57eab36b8564266939a2ea3b948a8bb`, and `97acfe2f4cc94f3f8eed55a99c62d25e`/`e145ab7c018c48629c0d60f9c86c5ac8`.
- The no-op snapshot retained identical index, RC-entry, wrapper and DLL hashes/timestamps. Deliberate duplicate ownership failed build `4a3c2925f69e4ec78546a7e831d16cb4` with exit 8 and preserved the same valid artifacts. Canonical restoration build/test `fd6d60e56d244d368eee1520b67cb6ec`/`21955438a04749509020a550a64709d6` passed 1/1 with zero warnings and zero errors.
- The private probe resolves its containing `AngelscriptTest` HMODULE, reads the named bootstrap and every indexed numeric RCDATA payload, compares exact bytes and the complete authored inventory, enforces unique private IDs at or above 1001, and confirms version resource ID 1 coexists. The public database exposes paths/Tags only.
- Omitted Quick, Performance, Integration and broader suites: the task's retained incremental matrix proves the Windows build/resource boundary exactly; runtime parsing/admission and cross-module behavior are downstream tasks 3.2 and 4.1.

## [x] 3.2 Load embedded providers through common admission

Copy index/payload bytes from the correct Windows owner, parse through the shared parser and submit atomic batches; no loose-file fallback or public handles.

**Outcome**

Copy index/payload bytes from the correct Windows owner, parse through the shared parser and submit atomic batches; no loose-file fallback or public handles.

**Interfaces**

Consumes 3.1 resources, 1.3 parser and 2.2 activation. Produces a module-private adapter and registry-private multi-file provider record while preserving all existing public types and signatures: Names and public file spellings follow attachments/drafts/glossary.md.

```text
owner module -> owned index/payload bytes -> SourceParser::Parse
    -> one registry-private provider record -> detached batch
    -> the same FAngelscriptTestCode activation/admission snapshot as C++ factories;
Public Get/FindCases/FindFiles signatures do not change.
```

**Cases**

1. **ResourceOnlyLookup** — new RED
   With the author root unavailable to the reader, Get(Language/Counter,root) after activation equals the golden embedded body.

2. **BrokenIndex** — new RED
   An isolated missing index, absent payload ID or malformed path rejects its whole batch with known owner/path context and no fallback read.

3. **CopiedPayload** — new RED
   Release isolated resource-image storage after copying; retained Source is valid. This is not a claim of supported live UE module unload.

4. **CarrierParity** — new RED
   Equivalent C++ and resource inputs in isolated centers yield identical metadata, clean bytes and offsets with distinct author provenance.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestEmbeddedSources.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestEmbeddedSources.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCodeRegistration.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCodeRegistration.cpp
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/ResourcesTests.cpp
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. Each named case is registered in the Resources class under the following exact prefix. Fresh build requirements are in Global constraints.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Resources'; Fast = $true; TimeoutMs = 600000 }
```

**Evidence**

- RED build `a6757b08aa7545ed8b9fe97bf047c81e` succeeded with the explicit not-implemented adapter. Focused run `e7e110f7f7cb41c29026294a4a4ae36a` discovered and behaviorally failed all 4/4 Resources cases.
- Final fresh build `fd3f130dc3704792a20536738c210942` succeeded. Proving run `eda5b21426174dc688f8cdc1ef64269d` executed and passed all 4/4 exact Resources tests with zero warnings and zero errors.
- ResourceOnlyLookup retrieved `Language/Counter/root` from the activated production singleton and matched the embedded golden body. The production adapter resolves its containing HMODULE, copies the named index and numeric payload resources, and has no file-system include, author-root environment lookup or loose-file fallback.
- BrokenIndex covered empty index, absent payload ID and `../` path rejection through an isolated one-owner batch. Errors retained known owner/source context and admission published no partial file. CopiedPayload cleared all input index/payload arrays before admission and the resulting Source, annotation and origin storage remained valid.
- CarrierParity proved equivalent resource-container and hand-written Builder material has equal file/version metadata, exact clean bytes and marker offsets while retaining different author provenance.
- The registry now snapshots private multi-file provider records beside ordinary public C++ factory records, invokes all callbacks outside its lock and sends both through the existing deterministic detached-batch admission. The public registration constructor and Get/FindCases/FindFiles signatures did not change.
- Because the registry snapshot contract changed, adjacent proving run `5c26c278bc3a4d218b93d38dca2d61c8` reran and passed all 4/4 Registration tests with zero warnings and zero errors.
- Omitted Quick, Performance, Integration and broader suites: exact Resources plus the affected shared Registration contract cover this task; cross-DLL registration and replacement-gate integrity are task 4.1.

## [x] 4.1 Prove cross-module sharing and fixed integrity checks

Add a replacement-gated factory fixture to the existing AngelscriptTestJIT module and fixed CQTest integrity reporting independent of successful material enumeration.

**Outcome**

Add a replacement-gated factory fixture to the existing AngelscriptTestJIT module and fixed CQTest integrity reporting independent of successful material enumeration.

**Interfaces**

Consumes prior outputs; AngelscriptTestJIT.Build.cs:17 currently declares Core/CoreUObject/AngelscriptRuntime. Produces a gated dependency and fixture, not a new module: Names and public file spellings follow attachments/drafts/glossary.md.

```text
TestCodeProviderRegistration.cpp: static FAngelscriptTestCodeRegistration;
CQTest Adoption methods consume GetInstance/Get/IsActivated/GetRegistrationErrors.
```

**Cases**

1. **TwoModulesOneCenter** — new RED
   Embedded Counter and C++ Fixture/Secondary providers observe the same exported center address and both are queryable after the barrier.

2. **FixedIntegrity** — new RED
   An isolated all-failed activation still reports errors through the fixed checking body; the test is not generated from FindFiles. Do not poison the production registry.

3. **VersionReads** — new RED
   Secondary root/changed versions can be queried in either order with unchanged complete bodies alongside Counter.

4. **ReplacementOnly** — new RED
   Default gates load fixtures without legacy pool startup or legacy Automation registrations.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/AdoptionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJIT.Build.cs
+Plugins/Angelscript/Source/AngelscriptTestJIT/NewVersion/TestCodeProviderRegistration.cpp
```

**Verification**

Run from the selected workspace with Harness imported and $context initialized. Each named case is registered in the Adoption class under the following exact prefix. Fresh build requirements are in Global constraints.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Adoption'; Fast = $true; TimeoutMs = 600000 }
```

**Notes**

Gate the additional AngelscriptTest dependency and fixture to replacement-test targets; check for an opposite dependency before adding it. Preserve unrelated JIT code. Fixed integrity presence does not guarantee arbitrary Automation selections include it; selection policy is outside scope.

**Evidence**

- RED build `24281f9c783d4355933adc13cd3e86a4` succeeded before JIT adoption. Focused run `b96aedb11e6b4608978453e080b484da` discovered all four fixed Adoption methods: FixedIntegrity passed against the already-proven isolated admission seam, while TwoModulesOneCenter, VersionReads and ReplacementOnly behaviorally failed because the secondary provider/export did not exist.
- The replacement-gated `AngelscriptTestJIT` dependency is one-way (`AngelscriptTestJIT` privately depends on `AngelscriptTest`); `AngelscriptTest` has no replacement dependency back to JIT. The new translation unit uses the public `FAngelscriptTestCodeRegistration` constructor and a no-context function factory.
- Final fresh build `4724f76953094e01969a1ec3bb4a519b` succeeded. Proving run `a530b8b6568849bc82f249eec38062b4` executed and passed all 4/4 exact Adoption tests with zero warnings and zero errors.
- TwoModulesOneCenter retrieved the embedded `Language/Counter` and JIT-owned `Fixture/Secondary` from the same production center, then resolved a test-only C export from the JIT DLL and compared the factory-observed singleton address equal to the caller's address.
- VersionReads retrieved `changed` before `root`, matched both complete bodies and the explicit parent, then independently retrieved Counter. FixedIntegrity is a fixed CQTest method that admits an all-error isolated batch and observes its retained error without enumerating successful materials or poisoning the production registry.
- ReplacementOnly observed `WITH_ANGELSCRIPT_TESTS=1`, `WITH_ANGELSCRIPT_UNITTESTS=0`, an activated database with zero registration errors and both providers. The run log records the dormant legacy runtime and the replacement module startup; no legacy engine-pool startup occurred.
- Omitted Quick, Performance, Integration and broader suites: the exact Adoption selector exercises both DLLs, the public center, fixed integrity and gate state. Previous exact Resources and Registration selectors cover their owning contracts.

## [x] 4.2 Publish verified guidance and synchronize the capability

Document only APIs/carrier behavior proven by preceding tasks and synchronize the new capability without altering old Change plans.

**Outcome**

Publish English examples for complete version containers, escaping, inline macros, both providers, lifetime and query failures. Record actual task proof, carrier limits and spec-sync disposition before archive; the old Change is not automatically archived.

**Files**

```diff
+.agents/skills/angelscript-test/references/test-code-database.md
 .agents/skills/angelscript-test/SKILL.md
 openspec/changes/angelscript/feature-test-code-database/attachments/data/planning-validation.md
 openspec/changes/angelscript/feature-test-code-database/attachments/INDEX.md
+openspec/specs/angelscript/testing/code-database/spec.md
+openspec/specs/angelscript/testing/code-database/spec.yaml
```

**Verification**

Run from the selected workspace with Harness imported. At synchronization, create any new spec identity only through the supported CLI and read its then-current target before merging. Retain the guide's focused content/link checks and the following strict record proof; no runtime capability is inferred from Markdown validity.

```powershell
& { $r = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-test-code-database','--type','change','--strict','--json'); if ($r.status -ne 'Succeeded') { throw 'Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/testing/code-database','--type','spec','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'Capability validation failed' } }
```

**Evidence**

- Created the previously absent current capability identity only through Harness `openspec.spec create`, run `702e9cb9ee49433bacd719d9098e00c5`; read-back run `8df0136c0d8d4c8083e725666910646e` confirmed the CLI-generated manifest before document synchronization.
- Semantically synchronized all eight complete ADDED Requirements into the new current spec. A focused audit found eight delta/current Requirement pairs and no delta-operation heading in the current target.
- Published the English test-code database guide and linked it from the AngelScript test Skill. The focused link/content audit passed ten anchors covering complete bodies, escaping, both inline macros, resource and static C++ providers, copied-value lifetime, query failure and the Windows carrier boundary.
- Exact task verification passed: strict Change validation run `54f8abc6de754ee08f7e01c65906286f` reported 1/1 valid with no issues; strict capability validation run `3ec1e947ad474da4a84808b0e31ec4ca` reported 1/1 valid with no issues.
- The first focused documentation check used the contiguous needle `FindFiles fails`, which did not match the correctly backtick-formatted API name. The corrected literal `` `FindFiles` fails `` passed without changing the documented contract.
- No Unreal build or Automation rerun was added for this documentation/spec-only task. Runtime evidence is retained by tasks 1.1 through 4.1 and summarized in `attachments/data/planning-validation.md`.
