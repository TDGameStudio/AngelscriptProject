// Theme: Containers.TArray. NegativeDiagnostic: assign TArray<FString> onto TArray<int>.
// C++: AngelscriptSyntaxContainerTests.cpp::TArray_Negative AssertFailsToCompile
// ASSyntaxCon_ArrAssignWrong. Expected diagnostic:
// "TArray assignment with wrong element type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TArray<int> A;
	TArray<FString> B;
	A = B;
}
