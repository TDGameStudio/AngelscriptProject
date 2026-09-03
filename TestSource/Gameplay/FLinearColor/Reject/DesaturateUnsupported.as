/**
 * FLinearColor.Desaturate is not bound, so this program is rejected. C++ compiles it as
 * LinearColorUnsupportedMethods and expects a diagnostic naming Desaturate.
 *
 * @Theme Gameplay.FLinearColor
 * @Subject FLinearColor.DesaturateUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.FLinearColor.DesaturateUnsupported
 * @Provenance Theme: Gameplay.FLinearColor. Isolated compile-fail: Desaturate is unbound.
 * @Provenance C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorUnsupportedMethods
 * @Provenance CompileAndExpectFailure fragment: No matching signatures to 'FLinearColor::Desaturate
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not drop TryDesaturate.
 */

/**
 * The isolated failing program: Desaturate has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers FLinearColor.DesaturateUnsupported
 * @Inputs none
 * @Return does not compile; Desaturate is not bound
 */
FLinearColor TryDesaturate()
{
	FLinearColor Color = FLinearColor::Red;
	return Color.Desaturate(0.5);
}
