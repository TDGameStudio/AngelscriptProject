// Theme: Containers.TArray. NegativeDiagnostic: string index on TArray<int>.
// C++: AngelscriptSyntaxContainerTests.cpp::TArray_Negative AssertFailsToCompile
// ASSyntaxCon_ArrIndexStr. Expected diagnostic: "TArray index with string should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TArray<int> Arr;
	Arr.Add(1);
	int X = Arr["key"];
}
