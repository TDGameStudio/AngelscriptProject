// Theme: Definitions.UFunction. NegativeDiagnostic: lowercase UFUNCTION specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 8 AssertFailsToCompile.
// sha256=a97ea455feeaac8b1444ac12725754d2d57a80e75b741839c793c26b7de92f07; lines 280-286.
// C++ currently wraps this AssertFailsToCompile in #if 0
// (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
// Expected diagnostic: "Lowercase specifier (case sensitivity) should fail".
// DiagnosticOnly.

class AUFuncCaseActor : AActor
{
	UFUNCTION(blueprintcallable)
	void Foo()
	{
	}
}
