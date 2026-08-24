// Theme: Language.Preprocessor. Isolated compile-fail: unknown UFUNCTION specifier.
// C++: AngelscriptPreprocessorFunctionMacroTests.cpp::InvalidSpecifiersReportDiagnostics
// AssertPreprocessFailed; lines 220-229;
// sha256=392ae0b20d7723c260111b67490638651cc9f8b8b5cc18704e408550a9fe1271.
// Expected diagnostic: "Unknown function specifier DefinitelyUnknownSpecifier on method UBadCarrier::Unknown."
// Do not replace DefinitelyUnknownSpecifier with a known specifier.
// DiagnosticOnly.

UCLASS()
class UBadCarrier : UObject
{
	UFUNCTION(DefinitelyUnknownSpecifier)
	void Unknown()
	{
	}
}
