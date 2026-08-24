// Theme: Definitions.UFunction. NegativeDiagnostic: duplicate UFUNCTION specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 6 AssertFailsToCompile.
// sha256=d5d17a3675ec82c0ea61fd10fff52df19af9b8fb11091383d33da22957fb867a; lines 254-260.
// C++ currently wraps this AssertFailsToCompile in #if 0
// (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
// Expected diagnostic: "Duplicate specifier should fail".
// DiagnosticOnly.

class AUFuncDupSpecActor : AActor
{
	UFUNCTION(BlueprintCallable, BlueprintCallable)
	void Foo()
	{
	}
}
