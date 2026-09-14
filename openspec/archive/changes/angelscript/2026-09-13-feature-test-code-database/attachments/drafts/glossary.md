# Names and provenance

## Explicitly discussed names

Namespace AngelscriptTest; FAngelscriptTestCode; FAngelscriptTestCodeRegistration; FAngelscriptTestCodeBuilder; FAngelscriptTestCodeBuildResult; FAngelscriptTestSource; FAngelscriptTestSourceCase; FAngelscriptTestSourceResult; FAngelscriptTestAnnotations; AS_TEST_SOURCE; ActivateRegistrations; Version = v1; path-derived Tag without .as.

Change ID angelscript/feature-test-code-database was explicitly confirmed.

## Planning names and exact signatures

The direct-creation instruction permits a concrete plan without another naming round; these are convention-derived planning assumptions, not separate historical approvals.

- FAngelscriptTestFileMeta, FAngelscriptTestVersionMeta, FAngelscriptTestError and FAngelscriptTestStatus: metadata and checked error carriers.
- FAngelscriptTestSourceParseResult: checked Source or errors for explicit annotation parsing.
- FAngelscriptTestSourceOriginMap: owned origin mapping data.
- FAngelscriptTestSourceParser::Parse(FStringView FileTag, TConstArrayView<uint8> Bytes): container input to CodeBuildResult.
- FAngelscriptTestAnnotations::Parse(FAngelscriptTestSource Source): explicit inline annotation parsing to SourceParseResult.
- AS_TEST_SOURCE_EXACT and FAngelscriptTestSource::FromBytes(TConstArrayView<uint8>): length-aware exact payload inputs.
- Builder AddRoot/AddVersion/Build; database GetInstance/Get/FindCases/FindFiles/IsActivated/GetRegistrationErrors; result IsSuccess/GetCase/GetError/GetErrors; case GetFileMeta/GetVersionMeta/GetSource; source GetBytes/GetAnnotations/GetOriginMap.
- Public declaration filenames mirror the owning FAngelscriptTest type with the leading F removed. Related metadata/error structs share AngelscriptTestSourceTypes.h.
- Test prefixes Angelscript.UnitTest.Framework.Source, Builder, Parser, Database, Registration, Resources and Adoption: TestDir Angelscript.UnitTest.Framework, the unprefixed class token names the group, and TEST_METHOD names the scenario.
- AngelscriptTest.Build.cs::TestCodeResourceGenerator and TestCodeResourceIncremental.ps1: plugin-owned private resource build helper and exact incremental proof driver, not a runtime dependency or alternative Harness.
- AngelscriptTestCode.rc: stable module-owned resource input that includes the generated Intermediate RC entries.
- AngelscriptTestEmbeddedSources.h/.cpp: module-private resource reader, batch carrier and test seam; these names are not exported runtime API.
- TestCodeProviderRegistration.cpp: gated secondary fixture in the existing AngelscriptTestJIT module, no new module identity.
- AS_TEST_INDEX: fixed bootstrap resource name; numeric payload IDs remain private.

All shapes are defined by the canonical design and producing tasks. No public Private namespace, History builder, new SourceId alias, or per-DLL inline singleton is introduced.
