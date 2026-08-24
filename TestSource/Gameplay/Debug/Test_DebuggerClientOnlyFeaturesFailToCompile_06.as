// Theme: Gameplay.Debug. Isolated compile-fail: RecordReproSteps/GitBisect are workflow-only.
// C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
// Expected diagnostic: RecordReproSteps (repro recording and git bisect are not AS callable APIs).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop RecordReproSteps.

void TryInvestigationWorkflowTools()
{
	RecordReproSteps("Coverage repro");
	GitBisect("bad", "good");
}
