/**
 * @version v1
 * @summary The `|` and `^` vector operators and the static DotProduct and CrossProduct helpers are not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorExpr_StaticAndOperatorProductsUnsupported and.
 * @topic Math
 */
/**
 * @version root
 * @summary The `|` and `^` vector operators and the static DotProduct and CrossProduct helpers are not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorExpr_StaticAndOperatorProductsUnsupported and.
 * @topic Negative
 */
/**
 * The isolated failing program: the product operators and static product helpers have no
 * script-facing signatures.
 *
 * @Kind CompileReject
 * @Covers FVector.StaticAndOperatorProductsUnsupported
 * @Inputs none
 * @Return does not compile; no operator takes two FVectors, and the static products are not bound
 */
void TryUnsupportedVectorProducts()
{
	FVector A = FVector(1, 0, 0);
	FVector B = FVector(0, 1, 0);
	float Dot = A | B;
	FVector Cross = A ^ B;
	float StaticDot = FVector::DotProduct(A, B);
	FVector StaticCross = FVector::CrossProduct(A, B);
}
/** @end */
