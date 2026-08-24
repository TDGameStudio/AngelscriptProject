// Theme: Definitions.UProperty. Isolated compile-fail: reference type as a UPROPERTY.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_RefType; lines 566-572;
// sha256=2563b59a80ea7b0db842c14f339cd17abbd45df4309b5bbc893bbc16257fb81e.
// Expected diagnostic: Reference type as UPROPERTY should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropRefTypeActor : AActor
{
	UPROPERTY()
	int& RefProp;
}
