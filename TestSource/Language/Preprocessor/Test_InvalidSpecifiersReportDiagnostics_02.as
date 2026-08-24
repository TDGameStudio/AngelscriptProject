// Theme: Language.Preprocessor. Isolated compile-fail: BlueprintEvent+Override.
// C++: AngelscriptPreprocessorFunctionMacroTests.cpp::InvalidSpecifiersReportDiagnostics
// AssertPreprocessFailed; lines 203-213;
// sha256=d58c3b5243442b4f77f0501abc011e2568f5f3f7d35f825800198f339e181822.
// Expected diagnostic: "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
// Do not drop either specifier.
// DiagnosticOnly.

UCLASS()
class UBadCarrier : UObject
{
	UFUNCTION(BlueprintEvent, BlueprintOverride)
	int Conflict()
	{
		return 1;
	}
}
