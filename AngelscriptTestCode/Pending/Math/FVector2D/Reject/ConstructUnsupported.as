/**
 * @version v1
 * @summary The single-value constructor and the One, UnitX and UnitY aliases are not bound, so this program is rejected. C++ compiles it as the module ASCovFVector2DExpr_ConstructUnsupported and expects diagnostics naming each of.
 * @topic Math
 */
/**
 * @version root
 * @summary The single-value constructor and the One, UnitX and UnitY aliases are not bound, so this program is rejected. C++ compiles it as the module ASCovFVector2DExpr_ConstructUnsupported and expects diagnostics naming each of.
 * @topic Negative
 */
/**
 * The isolated failing program: the single-value constructor and the unbound constants
 * have no script-facing signatures.
 *
 * @Kind CompileReject
 * @Covers FVector2D.ConstructUnsupported
 * @Inputs none
 * @Return does not compile; FVector2D(float), One, UnitX and UnitY are not bound
 */
void TryUnsupportedVector2DConstruction()
{
	FVector2D Single = FVector2D(5.0);
	FVector2D One = FVector2D::One;
	FVector2D UnitX = FVector2D::UnitX;
	FVector2D UnitY = FVector2D::UnitY;
}
/** @end */
