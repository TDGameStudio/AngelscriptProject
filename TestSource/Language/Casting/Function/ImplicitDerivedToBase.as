/**
 * A derived handle converts to its base implicitly, both when passed to a
 * function that takes the base type and when assigned to a base-typed local.
 * The conversion keeps the same object, so the base handle compares equal to
 * the derived one, and a null derived handle stays null.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitDerivedToBase
 * @Harness Function
 * @Tag Language.Casting.ImplicitDerivedToBase
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Accepts a base-typed handle, used to show a derived handle is passed
	 * without conversion syntax.
	 *
	 * @Covers Casting.ImplicitConversion
	 * @Param A Base-typed actor handle
	 * @Inputs Any actor handle
	 * @Return void
	 */
	void TakeActor(AActor A)
	{
	}

	/**
	 * Observe that a derived handle is accepted where the base is expected, and
	 * that assigning it to a base local keeps the same object.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Param P Derived pawn handle, runner-owned when non-null
	 * @Inputs Pass P to TakeActor, then assign it to an AActor local
	 * @Return the base handle, which compares equal to the source pawn
	 */
	UFUNCTION()
	AActor DerivedToBaseKeepsIdentity(APawn P)
	{
		TakeActor(P);
		AActor A = P;
		return A;
	}

	/**
	 * Observe the null default: a null derived handle converts to a null base
	 * handle.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Pass nullptr to TakeActor, then assign it to an AActor local
	 * @Return true when the base handle is nullptr
	 * @Boundary null source
	 */
	UFUNCTION()
	bool DerivedToBaseNullDefault()
	{
		APawn P = nullptr;
		TakeActor(P);
		AActor A = P;
		return A == nullptr;
	}
}
