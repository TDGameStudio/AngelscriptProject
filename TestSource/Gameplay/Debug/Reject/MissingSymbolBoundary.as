/**
 * A call to a symbol that is never declared, which must stay a deterministic
 * compile-failure boundary. C++ compiles this as the module
 * ASCoverageErrorHandling_MissingSymbolBoundary and expects the diagnostic to name
 * MissingCoverageBoundarySymbol.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.MissingSymbolBoundary
 * @Harness CompileReject
 * @Tag Gameplay.Debug.MissingSymbolBoundary
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: missing symbol.
 * @Provenance C++: AngelscriptCoverageErrorHandlingTests.cpp::NegativeCompileBoundaries
 * @Provenance Expected diagnostic: MissingCoverageBoundarySymbol.
 * @Provenance DiagnosticOnly. Do not define the missing symbol.
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
