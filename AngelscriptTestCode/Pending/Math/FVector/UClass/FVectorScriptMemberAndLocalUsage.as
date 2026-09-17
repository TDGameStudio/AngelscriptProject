/**
 * @version v1
 * @summary FVectors held in every storage class script can reach: locals, const locals, a module const, a raw non-reflected member and a reflected UPROPERTY member. C++ calls both entrypoints expecting 0 and then verifies the.
 * @topic Math
 */
/**
 * @version root
 * @summary FVectors held in every storage class script can reach: locals, const locals, a module const, a raw non-reflected member and a reflected UPROPERTY member. C++ calls both entrypoints expecting 0 and then verifies the.
 * @topic Baseline
 */
const FVector GlobalForward = FVector::ForwardVector;

UCLASS()
class ACoverageFVectorScriptMemberActor : AActor
{
	FVector RawMember = FVector(4, 5, 6);

	UPROPERTY()
	FVector ReflectedMember = FVector::RightVector;

	/**
	 * Read every local and const flavour of vector, naming the first that does not match.
	 *
	 * @Kind Observe
	 * @Covers FVector.ScriptMemberAndLocalUsage
	 * @Inputs none
	 * @Return 0 when all four match; 1 through 4 naming the one that did not
	 */
	UFUNCTION()
	int ReadLocalAndConstVectors()
	{
		FVector DefaultLocal;
		FVector CustomLocal = FVector(1, 2, 3);
		const FVector ConstLocal = FVector::UpVector;

		if (DefaultLocal != FVector::ZeroVector)
			return 1;
		if (CustomLocal != FVector(1, 2, 3))
			return 2;
		if (ConstLocal != FVector(0, 0, 1))
			return 3;
		if (GlobalForward != FVector(1, 0, 0))
			return 4;
		return 0;
	}

	/**
	 * Read both members, then write them and read them again, naming the first mismatch.
	 *
	 * @Kind Observe
	 * @Covers FVector.ScriptMemberAndLocalUsage
	 * @Inputs none
	 * @Return 0 when all four checks pass; 10, 20, 30 or 40 naming the one that did not
	 */
	UFUNCTION()
	int ReadRawAndReflectedMembers()
	{
		if (RawMember != FVector(4, 5, 6))
			return 10;
		if (ReflectedMember != FVector::RightVector)
			return 20;
		RawMember = RawMember + FVector(1, 1, 1);
		ReflectedMember = FVector(7, 8, 9);
		if (RawMember != FVector(5, 6, 7))
			return 30;
		if (ReflectedMember != FVector(7, 8, 9))
			return 40;
		return 0;
	}

	/**
	 * Observe that the local and const entrypoint reports no mismatch.
	 *
	 * @Kind Observe
	 * @Covers FVector.ScriptMemberAndLocalUsage
	 * @Inputs none
	 * @Return true when the entrypoint returned 0
	 */
	UFUNCTION()
	bool ReadLocalAndConstVectorsNominal()
	{
		return ReadLocalAndConstVectors() == 0;
	}

	/**
	 * Observe that the member entrypoint reports no mismatch and lands the reflected
	 * member on the written value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ScriptMemberAndLocalUsage
	 * @Inputs none
	 * @Return true when the entrypoint returned 0 and the member reads (7, 8, 9)
	 */
	UFUNCTION()
	bool ReadRawAndReflectedMembersNominal()
	{
		if (ReadRawAndReflectedMembers() != 0)
		{
			return false;
		}
		if (ReflectedMember.X != 7.0)
		{
			return false;
		}
		if (ReflectedMember.Y != 8.0)
		{
			return false;
		}
		return ReflectedMember.Z == 9.0;
	}

	/**
	 * Observe that an untouched actor keeps both declared defaults.
	 *
	 * @Kind Observe
	 * @Covers FVector.ScriptMemberAndLocalUsage
	 * @Inputs none
	 * @Return true when the reflected member is the right vector and the raw member is (4, 5, 6)
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool ReflectedMemberDefaultEmptyRight()
	{
		if (ReflectedMember != FVector::RightVector)
		{
			return false;
		}
		return RawMember == FVector(4, 5, 6);
	}

	/**
	 * Observe that driving one instance leaves another instance's member untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.ScriptMemberAndLocalUsage
	 * @Inputs a second actor
	 * @Return true when this instance reads (7, 8, 9) and the other still reads the right vector
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFVectorScriptMemberActor Second)
	{
		if (Second is null)
		{
			throw("FVectorScriptMemberAndLocalUsage setup: required Second is null");
		}
		ReadRawAndReflectedMembers();

		if (ReflectedMember != FVector(7, 8, 9))
		{
			return false;
		}
		return Second.ReflectedMember == FVector::RightVector;
	}
}
/** @end */
