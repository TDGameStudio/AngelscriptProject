// Theme: Definitions.UProperty. Isolated compile-fail: trailing garbage after UPROPERTY.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_TrailingGarbage; lines 310-315;
// sha256=d1cd452484a41895aea1caa4081ee27daa456e69342446f30ac1260a021c6ee8.
// Expected diagnostic: Trailing garbage after UPROPERTY should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropGarbageActor : AActor
{
	UPROPERTY() garbage int X = 0;
}
