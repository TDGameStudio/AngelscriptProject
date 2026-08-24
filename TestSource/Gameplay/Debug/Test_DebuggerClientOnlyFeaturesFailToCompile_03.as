// Theme: Gameplay.Debug. Isolated compile-fail: StepOver/StepInto/StepOut are client-only.
// C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
// Expected diagnostic: StepOver (stepping is driven by debugger clients).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop StepOver.

void TryStepControls()
{
	StepOver();
	StepInto();
	StepOut();
}
