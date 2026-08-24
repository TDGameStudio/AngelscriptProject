// Theme: Definitions.UFunction. NegativeDiagnostic: trailing garbage after UFUNCTION().
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 9 AssertFailsToCompile.
// sha256=293b845769e1e0c5d4c638400932a12e06bac3a95e2348f5a23b099b426c645f; lines 292-297.
// Expected diagnostic: "Trailing garbage after UFUNCTION should fail".
// Keep the garbage token so the program stays failing. DiagnosticOnly.

class AUFuncGarbageActor : AActor
{
	UFUNCTION() garbage void Foo() { }
}
