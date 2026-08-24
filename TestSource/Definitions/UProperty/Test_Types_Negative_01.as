// Theme: Definitions.UProperty. Isolated compile-fail: non-existent UPROPERTY type.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_NonExistent; lines 463-469;
// sha256=2f9ab47aedbafd7b26f0ab4b358e119936a90aed1d0fdb8514d8b92c44d445a9.
// Expected diagnostic: Non-existent UPROPERTY type should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropNonExistActor : AActor
{
	UPROPERTY()
	FNonExistentType X;
}
