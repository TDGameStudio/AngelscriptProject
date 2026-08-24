// Theme: Definitions.UProperty. Isolated compile-fail: auto as a UPROPERTY type.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_Auto; lines 485-491;
// sha256=8d2d31c4b078c54c85ba6f60f38c73339f46cacf485f25796c5197ae8177039b.
// Expected diagnostic: auto UPROPERTY type should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropAutoActor : AActor
{
	UPROPERTY()
	auto X = 5;
}
