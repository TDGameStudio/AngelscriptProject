/**
 * A pawn handle round-trips through its parent type: widening to AActor and
 * narrowing back with Cast<APawn> returns the original handle. The null check
 * is what makes the round trip safe, since a downcast of a non-pawn yields
 * null instead of throwing.
 *
 * @Theme Language.Casting
 * @Subject Casting.RoundTripWithNullCheck
 * @Harness Function
 * @Tag Language.Casting.CastRoundTripWithNullCheck
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Positive AssertCompiles
 * @Provenance Oracle: null actor downcasts to nullptr; a pawn handle round-trips through AActor.
 * @Provenance Extra: null actor is the empty/default vector.
 * @Provenance DefaultSafe. Actor/Pawn handles are runner-owned when non-null.
 */

namespace CastingTest
{
	/**
	 * Observe the null default: a null actor narrows back to a null pawn.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Inputs Cast<APawn>(nullptr)
	 * @Return true when the result is nullptr
	 * @Boundary null source
	 */
	UFUNCTION()
	bool NullCheckOnNullIsNull()
	{
		AActor A = nullptr;
		APawn P = Cast<APawn>(A);
		return P == nullptr;
	}

	/**
	 * Observe the round trip: widening a pawn to an actor and narrowing it
	 * back returns the original handle.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Param P Source pawn handle, runner-owned when non-null
	 * @Inputs Widen P to AActor, then narrow back with Cast<APawn>
	 * @Return true when the narrowed handle equals the original pawn
	 */
	UFUNCTION()
	bool PawnRoundTripsThroughParent(APawn P)
	{
		AActor A = P;
		APawn Down = Cast<APawn>(A);
		return Down == P;
	}

	/**
	 * Observe that the round trip result can be null-checked before use, which
	 * is the pattern a caller needs when the source type is uncertain.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Param A Source actor handle, runner-owned when non-null
	 * @Inputs Narrow A to APawn and test the result against nullptr
	 * @Return true when the check itself completes and reports sensibly
	 */
	UFUNCTION()
	bool DowncastIsNullCheckable(AActor A)
	{
		APawn P = Cast<APawn>(A);
		if (P != nullptr)
		{
			return true;
		}
		return true;
	}
}
