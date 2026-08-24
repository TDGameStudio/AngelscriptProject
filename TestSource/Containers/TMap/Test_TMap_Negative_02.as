// Theme: Containers.TMap. NegativeDiagnostic: TMap with only one template parameter.
// C++ AssertFailsToCompile ASSyntaxCon_MapOneParam.
// Expected diagnostic: "TMap with only one template param should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TMap<int> Map;
}
