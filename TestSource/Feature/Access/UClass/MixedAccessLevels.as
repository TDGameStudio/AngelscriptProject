/**
 * Mixed public, private, and protected members in one class. PubA starts at 0;
 * PubMethod assigns PrivB from ProtC without changing PubA. Two instances stay
 * independent after one of them is written.
 *
 * @Theme Feature.Access
 * @Subject Access.MixedAccessLevels
 * @Harness UClass
 * @Tag Feature.Access.MixedAccessLevels
 * @Provenance Theme: Feature.Access. WorldStory: mixed public/private/protected members in one class.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 6 AssertCompiles.
 * @Provenance Oracle: PubA default 0; PubMethod assigns PrivB from ProtC (2) without changing PubA.
 * @Provenance Extra: empty/default 0; copy independence of PubA.
 * @Provenance FixtureIsolated.
 */

class AActorMixedLevels : AActor
{
	int PubA = 0;
	private int PrivB = 1;
	protected int ProtC = 2;

	/**
	 * Assign the private field from the protected field without touching PubA.
	 *
	 * @Covers Access.MixedAccessLevels
	 * @Inputs none
	 * @Return nothing; PrivB receives ProtC
	 */
	void PubMethod()
	{
		PrivB = ProtC;
	}

	/**
	 * Observe that an untouched instance holds the public default of 0.
	 *
	 * @Kind Observe
	 * @Covers Access.MixedAccessLevels
	 * @Inputs none
	 * @Return 0, the default of PubA
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return PubA;
	}

	/**
	 * Observe that PubMethod leaves the public field unchanged.
	 *
	 * @Kind Observe
	 * @Covers Access.MixedAccessLevels
	 * @Inputs PubMethod()
	 * @Return 0 after the call
	 */
	UFUNCTION()
	int PubMethodLeavesPublic()
	{
		PubMethod();
		return PubA;
	}

	/**
	 * Observe that writing one instance leaves another instance at the default.
	 *
	 * @Kind Observe
	 * @Covers Access.MixedAccessLevels
	 * @Inputs a second actor
	 * @Return true when this instance reads 0 and the other reads 5
	 * @Param Second the other actor, written to 5 then driven through PubMethod
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AActorMixedLevels Second)
	{
		if (Second is null)
		{
			throw("MixedAccessLevels setup: required Second is null");
		}
		Second.PubA = 5;
		Second.PubMethod();
		if (PubA != 0)
		{
			return false;
		}
		return Second.PubA == 5;
	}
}
