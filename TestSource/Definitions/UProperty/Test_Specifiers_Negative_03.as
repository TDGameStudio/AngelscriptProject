// Theme: Definitions.UProperty. Isolated compile-fail: Replicated plus NotReplicated.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_ConflictRepNotRep; lines 218-224;
// sha256=db29ac0b5480be845c916ac3cfab07eaacad846bc8df15a5d38b0009da6286a7.
// Expected diagnostic: NotReplicated specifier is only allowed structs.
// DiagnosticOnly. Isolated failing program.

class AUPropConflictRepActor : AActor
{
	UPROPERTY(Replicated, NotReplicated)
	int X = 0;
}
