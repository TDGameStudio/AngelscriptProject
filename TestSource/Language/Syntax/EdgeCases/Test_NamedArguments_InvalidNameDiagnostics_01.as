// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: duplicate named argument.
// C++: AngelscriptFunctionTests.cpp::NamedArguments_InvalidNameDiagnostics
// sha256=7b58f79627af51154fd6aa89b0ffb34ac49738dc530e318833e573a62fe2915c; lines 142-152.
// Expected diagnostic: "Duplicate named argument".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

int Mix(int A, int B, int C)
{
	return 0;
}

int Run()
{
	return Mix(A: 1, A: 2, C: 3);
}
