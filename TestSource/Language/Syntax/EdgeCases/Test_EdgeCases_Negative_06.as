// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: top-level assignment.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 6 AssertFailsToCompile.
// sha256=0c5d977d44891a00296ff2c0aa39788ae2ca62e6bbdf530281ce90822d7697a4; lines 310-313.
// Expected diagnostic: assignment statement X = 10 is not valid at module scope.
// DiagnosticOnly. Do not move the assignment into a function.

int X = 5;
X = 10;
