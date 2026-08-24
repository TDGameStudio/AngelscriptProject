// Theme: Containers.TMap. NegativeDiagnostic: TMap without template parameters.
// C++ AssertFailsToCompile ASSyntaxCon_MapNoTemplate.
// Expected diagnostic: "TMap without template parameters should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TMap Map;
}
