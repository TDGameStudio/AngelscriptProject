/**
 * @version v1
 * @summary The FVector2D `|` operator is not bound, so this program is rejected. C++ compiles it as the module ASCovFVector2DExpr_DotOperatorUnsupported and expects a diagnostic that no matching operator takes two FVector2Ds. The.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector2D `|` operator is not bound, so this program is rejected. C++ compiles it as the module ASCovFVector2DExpr_DotOperatorUnsupported and expects a diagnostic that no matching operator takes two FVector2Ds. The.
 * @topic Negative
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
/** @end */
