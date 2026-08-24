// Theme: Language.Syntax.Keywords. NegativeDiagnostic: inherit from a final class.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 2 AssertFailsToCompile.
// sha256=429e23b9646de9f6fa589a625f500533d680b7d9269069b3f2c5d9da472bcccb; lines 186-189.
// Expected diagnostic: "Inheriting from final class should fail".
// C++ currently wraps this AssertFailsToCompile in #if 0 (structural-validation-absent).
// Isolate this failing program. DiagnosticOnly.

class AFinalActorInhN : AActor final
{
}

class AChildActorInhN : AFinalActorInhN
{
}
