// Theme: Language.Literals.FString. NegativeDiagnostic: assigning nullptr to FString.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 8 AssertFailsToCompile.
// sha256=b7bc555ba82de443d02de902683f3461ab1df558a10e8106117bb114ce33b268; lines 180-182.
// Expected diagnostic: cannot convert nullptr to FString.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString S = nullptr;
}
