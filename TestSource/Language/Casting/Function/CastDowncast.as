/**
 * A downcast with Cast<APawn> narrows a parent handle back to the derived
 * type. The conversion yields the pawn when the source actually is one, and
 * yields null when it is not, so the result has to be checked before use. A
 * null source stays null rather than throwing.
 *
 * @Theme Language.Casting
 * @Subject Casting.Downcast
 * @Harness Function
 * @Tag Language.Casting.CastDowncast
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Positive AssertCompiles
 * @Provenance Oracle: Cast<APawn>(A) returns the pawn when A is a pawn; nullptr in, nullptr out.
 * @Provenance Extra: null actor is the empty/default vector.
 * @Provenance DefaultSafe. Actor handles are runner-owned when non-null.
 */

namespace CastingTest
{
	/**
	 * Observe that a downcast yields the derived handle.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Param A Source actor handle, runner-owned when non-null
	 * @Inputs Cast<APawn>(A) for an actor handle
	 * @Return the pawn handle when the source is a pawn, otherwise nullptr
	 */
	UFUNCTION()
	APawn DowncastResult(AActor A)
	{
		return Cast<APawn>(A);
	}

	/**
	 * Observe the null default: casting a null actor produces a null pawn.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Inputs Cast<APawn>(nullptr)
	 * @Return true when the result is nullptr
	 * @Boundary null source
	 */
	UFUNCTION()
	bool DowncastOfNullIsNull()
	{
		AActor A = nullptr;
		APawn P = Cast<APawn>(A);
		return P == nullptr;
	}
}
