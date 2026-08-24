// Theme: Gameplay.Debug. Isolated compile-fail: missing semicolon.
// C++: AngelscriptCoverageErrorHandlingTests.cpp::NegativeCompileBoundaries
// Expected diagnostic: Expected ',' or ';' / Instead found.
// DiagnosticOnly. Do not insert the missing semicolon.

int TriggerSyntaxCompileFailure()
{
	int Value = 12
	return Value;
}
