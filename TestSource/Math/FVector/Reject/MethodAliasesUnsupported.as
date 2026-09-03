/**
 * The Length, SquaredLength, GetNormalized, Distance, Dot and Cross aliases are not
 * bound, so this program is rejected. C++ compiles it as the module
 * ASCovFVectorExpr_MethodAliasesUnsupported and expects diagnostics naming each of them.
 *
 * @Theme Math.FVector
 * @Subject FVector.MethodAliasesUnsupported
 * @Harness CompileReject
 * @Tag Math.FVector.MethodAliasesUnsupported
 * @Provenance Theme: Gameplay.FVector. Isolated compile-fail: Length/SquaredLength aliases.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorMethods
 * @Provenance CompileAndExpectFailure for Length(), SquaredLength(), GetNormalized(),
 * @Provenance FVector::Distance, Dot, Cross. CSV NegativeDiagnostic. DiagnosticOnly.
 * @Provenance Do not add extra declarations.
 */

/**
 * The isolated failing program: the method aliases have no script-facing signatures.
 *
 * @Kind CompileReject
 * @Covers FVector.MethodAliasesUnsupported
 * @Inputs none
 * @Return does not compile; Length, SquaredLength, GetNormalized, Distance, Dot and Cross are not bound
 */
void TryUnsupportedVectorMethodAliases()
{
	FVector A = FVector(3, 4, 0);
	FVector B = FVector(1, 0, 0);
	float Length = A.Length();
	float SquaredLength = A.SquaredLength();
	FVector Normal = A.GetNormalized();
	float Distance = FVector::Distance(A, B);
	float Dot = A.Dot(B);
	FVector Cross = A.Cross(B);
}
