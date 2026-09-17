/**
 * @version v1
 * @summary A call to a symbol that is never declared, which must stay a deterministic compile-failure boundary. C++ compiles this as the module ASCoverageErrorHandling_MissingSymbolBoundary and expects the diagnostic to name.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A call to a symbol that is never declared, which must stay a deterministic compile-failure boundary. C++ compiles this as the module ASCoverageErrorHandling_MissingSymbolBoundary and expects the diagnostic to name.
 * @topic Negative
 */
/**
 * The isolated failing program: the missing symbol has no declaration to bind to.
 *
 * @Kind CompileReject
 * @Covers Debug.MissingSymbolBoundary
 * @Inputs none
 * @Return does not compile; MissingCoverageBoundarySymbol is never declared
 */
int TriggerMissingSymbolCompileFailure()
{
	return MissingCoverageBoundarySymbol();
}
/** @end */
