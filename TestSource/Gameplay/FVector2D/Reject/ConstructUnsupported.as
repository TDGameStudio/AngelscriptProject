/**
 * The single-value constructor and the One, UnitX and UnitY aliases are not bound, so
 * this program is rejected. C++ compiles it as the module
 * ASCovFVector2DExpr_ConstructUnsupported and expects diagnostics naming each of them.
 *
 * @Theme Gameplay.FVector2D
 * @Subject FVector2D.ConstructUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.FVector2D.ConstructUnsupported
 * @Provenance Theme: Gameplay.FVector2D. Isolated compile-fail: single-value ctor and aliases.
 * @Provenance C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DConstruction
 * @Provenance CompileAndExpectFailure diagnostics: No matching signatures to
 * @Provenance 'FVector2D(const float)'; 'FVector2D::One' is not declared;
 * @Provenance 'FVector2D::UnitX' is not declared; 'FVector2D::UnitY' is not declared.
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not add extra declarations.
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
