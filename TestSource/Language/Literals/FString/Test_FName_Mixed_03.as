// Theme: Language.Literals.FString. Compile-fail: n without a string literal.
// CSV SourceShape is Positive / DefaultSafe; C++ uses AssertFailsToCompile.
// C++: AngelscriptSyntaxFStringTests.cpp::FName_Mixed block 3.
// sha256=99539fd3c85fd32d23fc315e7704423ba7a21998f2a495e43e09270984f64cf1; lines 268-270.
// Expected diagnostic: FName literal without string.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FName N = n;
}
