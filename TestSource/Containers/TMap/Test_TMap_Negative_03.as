// Theme: Containers.TMap. NegativeDiagnostic: Add with wrong key type.
// C++ AssertFailsToCompile ASSyntaxCon_MapWrongKey.
// Expected diagnostic: "Adding wrong key type to TMap should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TMap<FString, int> Map;
	Map.Add(42, 1);
}
