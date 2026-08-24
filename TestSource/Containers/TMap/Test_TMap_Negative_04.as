// Theme: Containers.TMap. NegativeDiagnostic: Add with wrong value type.
// C++ AssertFailsToCompile ASSyntaxCon_MapWrongVal.
// Expected diagnostic: "Adding wrong value type to TMap should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TMap<FString, int> Map;
	Map.Add("key", "value");
}
