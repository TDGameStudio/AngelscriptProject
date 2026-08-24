// Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION at global scope.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 2 AssertFailsToCompile.
// sha256=9b8c187c821bb2f8849931ff846d300aff4402e7cc0369e80c4a960c026686a0; lines 211-213.
// C++ currently wraps this AssertFailsToCompile in #if 0
// (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
// Expected diagnostic: UFUNCTION at global scope should fail.
// DiagnosticOnly. PlannedSymbols empty.

UFUNCTION()
void GlobalFunc()
{
}
