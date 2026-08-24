// Theme: Containers.TSet. NegativeDiagnostic: TSet of a non-existent type.
// C++: AngelscriptSyntaxContainerTests.cpp::TSet_Negative AssertFailsToCompile ASSyntaxCon_SetBadType.
// Expected diagnostic: "TSet with non-existent type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSet<NonExistent> S;
}
