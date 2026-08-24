// Theme: Definitions.UStruct. Isolated compile-fail: USTRUCT(NoExport) is unsupported.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedSpecifiers CompileAndExpectFailure
// lines 3451-3458;
// sha256=1012298ff8cc2ecccfdceee59b097bcef7e2a5417560736d6c760a5bae3b332a.
// Expected diagnostic: Unknown class specifier NoExport.
// DiagnosticOnly. Isolated failing program.

USTRUCT(NoExport)
struct FNoExportStruct
{
	UPROPERTY()
	int Value = 1;
}
