// Theme: Language.Literals.FString. NegativeDiagnostic: assigning int to FString.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 5 AssertFailsToCompile.
// sha256=a28288260e0f7eda6587da60230a3c50551baf949a63ba6b89ed9ff9cd32f180; lines 154-156.
// Expected diagnostic: cannot convert int to FString.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString S = 42;
}
