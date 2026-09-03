/**
 * An upcast with Cast<T> to a parent class succeeds and yields a handle to
 * the same object: casting an APawn to an AActor does not copy or wrap it, it
 * reinterprets the handle at the parent type. A null source stays null rather
 * than throwing, so nullptr in produces nullptr out.
 *
 * @Theme Language.Casting
 * @Subject Casting.ToParentClass
 * @Harness Function
 * @Tag Language.Casting.CastToParentClass
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Positive AssertCompiles
 * @Provenance Oracle: Cast<AActor>(P) identity-equals P; nullptr stays nullptr.
 * @Provenance Extra: null pawn is the empty/default vector.
 * @Provenance DefaultSafe. Pawn/Actor handles are runner-owned when non-null.
 */

namespace CastingTest
{
	/**
	 * Observe that an upcast yields a handle to the same object.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Param P Source pawn handle, runner-owned when non-null
	 * @Inputs Cast<AActor>(P) for a pawn handle
	 * @Return the parent handle, which compares equal to the source pawn
	 */
	UFUNCTION()
	AActor UpcastKeepsIdentity(APawn P)
	{
		return Cast<AActor>(P);
	}

	/**
	 * Observe the null default: casting a null pawn produces a null actor.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Inputs Cast<AActor>(nullptr)
	 * @Return true when the result is nullptr
	 * @Boundary null source
	 */
	UFUNCTION()
	bool UpcastOfNullIsNull()
	{
		APawn P = nullptr;
		AActor A = Cast<AActor>(P);
		return A == nullptr;
	}
}
