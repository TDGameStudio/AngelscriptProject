// Theme: Gameplay.Debug. Isolated compile-fail: native SCOPE_CYCLE_COUNTER macro.
// C++: AngelscriptCoverageDebugTests.cpp::ConsoleProfilerAndDebuggerControlsFailToCompile
// Expected diagnostic: STAT_CoverageDebugAndLogging (macro is not AS-facing).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SCOPE_CYCLE_COUNTER.

void TryNativeProfilerMacro()
{
	SCOPE_CYCLE_COUNTER(STAT_CoverageDebugAndLogging);
}
