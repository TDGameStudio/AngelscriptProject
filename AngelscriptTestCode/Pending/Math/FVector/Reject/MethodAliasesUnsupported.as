/**
 * @version v1
 * @summary The Length, SquaredLength, GetNormalized, Distance, Dot and Cross aliases are not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorExpr_MethodAliasesUnsupported and expects diagnostics naming.
 * @topic Math
 */
/**
 * @version root
 * @summary The Length, SquaredLength, GetNormalized, Distance, Dot and Cross aliases are not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorExpr_MethodAliasesUnsupported and expects diagnostics naming.
 * @topic Negative
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
/** @end */
