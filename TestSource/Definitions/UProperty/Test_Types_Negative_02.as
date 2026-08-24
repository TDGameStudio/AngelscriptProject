// Theme: Definitions.UProperty. Isolated compile-fail: void as a UPROPERTY type.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_Void; lines 474-480;
// sha256=a9968fc8bbda56a62ae600704f9b38adbb2e81417b53993d647ea98a7e344847.
// Expected diagnostic: void UPROPERTY type should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropVoidActor : AActor
{
	UPROPERTY()
	void X;
}
