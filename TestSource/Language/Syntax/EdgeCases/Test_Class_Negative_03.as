// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: duplicate class name.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 3 AssertFailsToCompile.
// sha256=2c5730f54de076f867af1ffa0fa18b61162d2e3bc256ac70d94852012ba17ccb; lines 145-148.
// Expected diagnostic: ADupActor is declared twice.
// DiagnosticOnly. Do not rename the second class.

class ADupActor : AActor
{
}

class ADupActor : AActor
{
}
