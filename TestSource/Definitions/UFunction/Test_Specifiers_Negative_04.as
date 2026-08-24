// Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION on a property.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 4 AssertFailsToCompile.
// sha256=e880cbd81a548f16e71fffac7ce45797473bf9f1fd014c5d79e033c3c96dc688; lines 232-238.
// Expected diagnostic: "UFUNCTION on property should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncOnPropActor : AActor
{
	UFUNCTION()
	int X = 0;
}
