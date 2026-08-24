// Theme: Gameplay.Debug. Isolated compile-fail: Watch/EvaluateImmediate are client-only.
// C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
// Expected diagnostic: Watch (watch and immediate-window evaluation are not AS callable APIs).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop Watch.

void TryWatchAndImmediate()
{
	Watch("Value");
	EvaluateImmediate("Value + 1");
}
