/**
 * USTRUCT(NoExport) is not a script-side specifier, so this program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.NoExportSpecifierRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.NoExportSpecifierRejected
 * @Kind CompileReject
 * @Covers UStruct.NoExportSpecifierRejected
 * @Inputs USTRUCT(NoExport) on FNoExportStruct
 * @Return does not compile; diagnostic "Unknown class specifier NoExport"
 * @Provenance Theme: Definitions.UStruct. Isolated compile-fail: USTRUCT(NoExport) is unsupported.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedSpecifiers CompileAndExpectFailure
 * @Provenance lines 3451-3458;
 * @Provenance sha256=1012298ff8cc2ecccfdceee59b097bcef7e2a5417560736d6c760a5bae3b332a.
 * @Provenance Expected diagnostic: Unknown class specifier NoExport.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

USTRUCT(NoExport)
struct FNoExportStruct
{
	UPROPERTY()
	int Value = 1;
}
