// Theme: Containers.TMap. NegativeDiagnostic: bracket access with wrong key type.
// C++ AssertFailsToCompile ASSyntaxCon_MapBracketWrong.
// Expected diagnostic: "TMap bracket access with wrong key type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TMap<FString, int> Map;
	int X = Map[42];
}
