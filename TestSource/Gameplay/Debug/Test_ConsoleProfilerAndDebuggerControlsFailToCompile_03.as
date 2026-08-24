// Theme: Gameplay.Debug. Isolated compile-fail: SetBreakpoint is debugger-client only.
// C++: AngelscriptCoverageDebugTests.cpp::ConsoleProfilerAndDebuggerControlsFailToCompile
// Expected diagnostic: SetBreakpoint (IDE breakpoint management is not an AS callable API).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SetBreakpoint.

void TryIdeDebuggerControls()
{
	SetBreakpoint("Coverage_DebugAndLogging.as", 12);
}
