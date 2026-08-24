// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=fdde368f9f57bed4005598462fa968c50df816cb872c477b7fe720efbbf9854e; lines 490-492.
// Expected compile failure: "Assignment to const".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	const int X = 5;
	X = 10;
}
