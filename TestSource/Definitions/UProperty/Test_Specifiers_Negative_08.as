// Theme: Definitions.UProperty. Isolated compile-fail: UPROPERTY on a function.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_OnFunction; lines 273-279;
// sha256=45f8ac844b91ae7caea1b2085016c6cb7643d4893553ac373e383057f6b78751.
// Expected diagnostic: UPROPERTY on function should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropOnFuncActor : AActor
{
	UPROPERTY()
	void Foo()
	{
	}
}
