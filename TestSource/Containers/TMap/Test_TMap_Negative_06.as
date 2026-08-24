// Theme: Containers.TMap. NegativeDiagnostic: TMap with void value type.
// C++ AssertFailsToCompile ASSyntaxCon_MapVoid.
// Expected diagnostic: "TMap with void value type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TMap<FString, void> Map;
}
