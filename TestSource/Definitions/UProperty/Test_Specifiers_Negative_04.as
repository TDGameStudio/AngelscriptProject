// Theme: Definitions.UProperty. Isolated compile-fail: UPROPERTY on a local variable.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_LocalVar; lines 229-238;
// sha256=0c79adfe2dcaeaaf4757b00133843d55559c23fb564f516d6ef5fb545d49696a.
// Expected diagnostic: UPROPERTY on local variable should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropLocalVarActor : AActor
{
	void Foo()
	{
		UPROPERTY()
		int X = 0;
	}
}
