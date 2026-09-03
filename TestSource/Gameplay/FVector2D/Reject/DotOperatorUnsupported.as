/**
 * The FVector2D `|` operator is not bound, so this program is rejected. C++ compiles it
 * as the module ASCovFVector2DExpr_DotOperatorUnsupported and expects a diagnostic that
 * no matching operator takes two FVector2Ds. The CSV Positive label is wrong; C++ does
 * not compile this.
 *
 * @Theme Gameplay.FVector2D
 * @Subject FVector2D.DotOperatorUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.FVector2D.DotOperatorUnsupported
 * @Provenance Theme: Gameplay.FVector2D. Isolated compile-fail: FVector2D | operator.
 * @Provenance C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DDotProduct
 * @Provenance CompileAndExpectFailure. CSV Positive; C++ does not compile. DiagnosticOnly.
 * @Provenance Do not add extra declarations that would compile this away.
 */

/**
 * The isolated failing program: the bitwise-or spelling of a 2D dot product is not bound.
 *
 * @Kind CompileReject
 * @Covers FVector2D.DotOperatorUnsupported
 * @Inputs none
 * @Return does not compile; FVector2D | FVector2D is not an operator
 */
float TryDotOperator()
{
	FVector2D A = FVector2D(1.0, 0.0);
	FVector2D B = FVector2D(0.0, 1.0);
	return A | B;
}
