// Theme: Definitions.UProperty. Isolated compile-fail: ReplicatedUsing without a function.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_RepUsingNoFunc; lines 344-350;
// sha256=f926ed5a12203f55186c266192ae2c4bb0ad19ff9cd738c4c902589ce847caf1.
// Expected diagnostic: No function specified for ReplicatedUsing.
// DiagnosticOnly. Isolated failing program.

class AUPropRepNoFuncActor : AActor
{
	UPROPERTY(ReplicatedUsing)
	int X = 0;
}
