/**
 * Casting a nullptr yields a null handle rather than throwing, as long as the
 * result is bound to a local and inspected. The bare-expression form, which
 * the compiler rejects, lives separately in ../Reject/CastNullptrAsRvalue.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrIsNull
 * @Harness Function
 * @Tag Language.Casting.CastNullptrIsNull
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure applies to the bare-expression form only.
 */

namespace CastingTest
{
	/**
	 * Observe that casting a nullptr produces a null handle.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Inputs Cast<APawn>(nullptr) bound to a local
	 * @Return true when the result is nullptr
	 * @Boundary nullptr source
	 */
	UFUNCTION()
	bool CastNullptrProducesNullHandle()
	{
		APawn X = Cast<APawn>(nullptr);
		return X == nullptr;
	}
}
