/**
 * @version v1
 * @summary A missing semicolon, which must stay a deterministic compile-failure boundary. C++ compiles this as the module ASCoverageErrorHandling_SyntaxBoundary and expects the diagnostic to report the expected token.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A missing semicolon, which must stay a deterministic compile-failure boundary. C++ compiles this as the module ASCoverageErrorHandling_SyntaxBoundary and expects the diagnostic to report the expected token.
 * @topic Negative
 */
/**
 * The isolated failing program: the declaration is missing its terminating semicolon.
 *
 * @Kind CompileReject
 * @Covers Debug.SyntaxBoundary
 * @Inputs none
 * @Return does not compile; "Expected ',' or ';'"
 */
int TriggerSyntaxCompileFailure()
{
	int Value = 12
	return Value;
}
/** @end */
