// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: default type mismatch.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultTypeMismatchFails
// sha256=b26a725297146cec421040201292c2d463d469dd00d4a6d1c4928e5f0c3b0ba4; lines 552-561.
// Expected diagnostic: type mismatch default should fail to compile.
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class UDefaultTypeMismatchCarrier : UObject
{
	UPROPERTY()
	int MyInt;

	default MyInt = "not an int";
}
