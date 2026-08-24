// Theme: Feature.Access. NegativeDiagnostic: invalid access specifier keyword.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 6 AssertFailsToCompile.
// Expected compile failure: "Invalid access specifier keyword internal".
// Isolate the failing program. DiagnosticOnly.

class AActorBadKeyword : AActor
{
	internal int X = 0;
}
