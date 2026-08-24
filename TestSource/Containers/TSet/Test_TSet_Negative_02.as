// Theme: Containers.TSet. NegativeDiagnostic: Add a string into TSet<int>.
// C++: AngelscriptSyntaxContainerTests.cpp::TSet_Negative AssertFailsToCompile ASSyntaxCon_SetWrongType.
// Expected diagnostic: "Adding wrong type to TSet should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSet<int> S;
	S.Add("hello");
}
