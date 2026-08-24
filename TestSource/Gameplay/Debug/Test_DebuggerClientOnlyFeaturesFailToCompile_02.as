// Theme: Gameplay.Debug. Isolated compile-fail: SetLogBreakpoint is client-only.
// C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
// Expected diagnostic: SetLogBreakpoint (debugger-client, not an AS callable API).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SetLogBreakpoint.

void TryLogBreakpoint()
{
	SetLogBreakpoint("Coverage_DebugAndLogging.as", 16, "Value={Value}");
}
