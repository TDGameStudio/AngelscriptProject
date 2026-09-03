/**
 * RecordReproSteps and GitBisect are workflow practices rather than script callables,
 * so this program is rejected. C++ compiles it as the module
 * ASCoverageDebug_InvestigationWorkflowUnsupported and expects the diagnostic to name
 * RecordReproSteps.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.InvestigationWorkflowUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.InvestigationWorkflowUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: RecordReproSteps/GitBisect are workflow-only.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
 * @Provenance Expected diagnostic: RecordReproSteps (repro recording and git bisect are not AS callable APIs).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop RecordReproSteps.
 */

/**
 * The isolated failing program: RecordReproSteps and GitBisect have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers Debug.InvestigationWorkflowUnsupported
 * @Inputs none
 * @Return does not compile; repro recording and git bisect are workflow practices
 */
void TryInvestigationWorkflowTools()
{
	RecordReproSteps("Coverage repro");
	GitBisect("bad", "good");
}
