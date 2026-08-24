// Theme: Gameplay.Debug. Isolated compile-fail: SetConditionalBreakpoint is client-only.
// C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
// Expected diagnostic: SetConditionalBreakpoint (debugger-client, not an AS callable API).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SetConditionalBreakpoint.

void TryConditionalBreakpoint()
{
	SetConditionalBreakpoint("Coverage_DebugAndLogging.as", 15, "Value > 10");
}
