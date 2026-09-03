/**
 * The FVector::UnitX, UnitY and UnitZ aliases are not bound, so this program is
 * rejected. C++ compiles it as the module ASCovFVectorExpr_UnitFunctionsUnsupported and
 * expects a diagnostic naming each of the three. The CSV NegativeDiagnostic label is
 * correct here, unlike the cases where it masks a passing module.
 *
 * @Theme Math.FVector
 * @Subject FVector.UnitFunctionsUnsupported
 * @Harness CompileReject
 * @Tag Math.FVector.UnitFunctionsUnsupported
 * @Provenance Theme: Gameplay.FVector. Isolated compile-fail: UnitX/UnitY/UnitZ aliases.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorConstruction
 * @Provenance CompileAndExpectFailure diagnostics: No matching signatures to
 * @Provenance 'FVector::UnitX()', 'FVector::UnitY()', 'FVector::UnitZ()'.
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not add extra declarations.
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
