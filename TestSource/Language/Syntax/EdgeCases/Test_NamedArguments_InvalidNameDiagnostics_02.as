// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: unknown named argument.
// C++: AngelscriptFunctionTests.cpp::NamedArguments_InvalidNameDiagnostics
// sha256=fa112150e55d0f7d9d99c9a0c4152599e8c4d2c62d9ab73180b79df212ed7680; lines 159-169.
// Expected diagnostic: "Unknown parameter 'D'".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

int Mix(int A, int B, int C)
{
	return 0;
}

int Run()
{
	return Mix(A: 1, D: 2, C: 3);
}
