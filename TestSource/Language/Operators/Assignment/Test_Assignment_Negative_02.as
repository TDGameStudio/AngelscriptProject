// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=284c0492775dd042de82674d7f8cea2cbe22e9f329987501770f7405ab7d231a; lines 497-499.
// Expected compile failure: "Assignment to literal".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	5 = 10;
}
