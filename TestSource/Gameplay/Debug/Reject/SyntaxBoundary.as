/**
 * A missing semicolon, which must stay a deterministic compile-failure boundary. C++
 * compiles this as the module ASCoverageErrorHandling_SyntaxBoundary and expects the
 * diagnostic to report the expected token.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.SyntaxBoundary
 * @Harness CompileReject
 * @Tag Gameplay.Debug.SyntaxBoundary
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: missing semicolon.
 * @Provenance C++: AngelscriptCoverageErrorHandlingTests.cpp::NegativeCompileBoundaries
 * @Provenance Expected diagnostic: Expected ',' or ';' / Instead found.
 * @Provenance DiagnosticOnly. Do not insert the missing semicolon.
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
