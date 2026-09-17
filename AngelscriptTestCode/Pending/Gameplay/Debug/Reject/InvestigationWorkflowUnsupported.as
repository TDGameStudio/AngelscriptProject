/**
 * @version v1
 * @summary RecordReproSteps and GitBisect are workflow practices rather than script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_InvestigationWorkflowUnsupported and expects the diagnostic.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary RecordReproSteps and GitBisect are workflow practices rather than script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_InvestigationWorkflowUnsupported and expects the diagnostic.
 * @topic Negative
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
/** @end */
