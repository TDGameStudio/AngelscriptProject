// Theme: Definitions.UStruct. Isolated compile-fail: USTRUCT(Immutable) is unsupported.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedSpecifiers CompileAndExpectFailure
// lines 3434-3441;
// sha256=9688106c7cc3ec695e2caff2c316b719f2a6734c0ad7e9dd24a78e2476009fd9.
// Expected diagnostic: Unknown class specifier Immutable.
// DiagnosticOnly. Isolated failing program.

USTRUCT(Immutable)
struct FImmutableStruct
{
	UPROPERTY()
	int Value = 1;
}
