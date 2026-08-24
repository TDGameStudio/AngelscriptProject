// Theme: Language.Preprocessor. Isolated compile-fail: namespace without '{'.
// C++: AngelscriptPreprocessorNamespaceTests.cpp::InvalidDeclarationReportsSyntax
// sha256=2e1a11b5838b41ca5a32544b7595aa9e5ad1c0432a2deef0c1247045398ff4d5; lines 57-68.
// Expected diagnostic: "Invalid namespace declaration, expected '{' after namespace name." (count 1).
// Chunks for UBrokenNamespaceCarrier and Entry remain, but no processed code is emitted.
// DiagnosticOnly. Do not add the missing '{' or extra declarations that would compile this away.

namespace Gameplay
UCLASS()
class UBrokenNamespaceCarrier : UObject
{
}

int Entry()
{
	return 7;
}
