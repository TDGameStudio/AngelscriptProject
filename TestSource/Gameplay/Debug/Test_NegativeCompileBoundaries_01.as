// Theme: Gameplay.Debug. Isolated compile-fail: missing symbol.
// C++: AngelscriptCoverageErrorHandlingTests.cpp::NegativeCompileBoundaries
// Expected diagnostic: MissingCoverageBoundarySymbol.
// DiagnosticOnly. Do not define the missing symbol.

int TriggerMissingSymbolCompileFailure()
{
	return MissingCoverageBoundarySymbol();
}
