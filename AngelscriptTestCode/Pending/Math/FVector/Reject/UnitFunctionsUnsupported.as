/**
 * @version v1
 * @summary The FVector::UnitX, UnitY and UnitZ aliases are not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorExpr_UnitFunctionsUnsupported and expects a diagnostic naming each of the three. The CSV.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector::UnitX, UnitY and UnitZ aliases are not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorExpr_UnitFunctionsUnsupported and expects a diagnostic naming each of the three. The CSV.
 * @topic Negative
 */
/**
 * The isolated failing program: the three unit-axis aliases have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers FVector.UnitFunctionsUnsupported
 * @Inputs none
 * @Return does not compile; UnitX, UnitY and UnitZ are not bound
 */
void TryUnsupportedUnitFunctions()
{
	FVector UnitX = FVector::UnitX();
	FVector UnitY = FVector::UnitY();
	FVector UnitZ = FVector::UnitZ();
}
/** @end */
