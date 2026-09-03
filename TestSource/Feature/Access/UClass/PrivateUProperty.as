/**
 * A UPROPERTY may be declared private. Health stays private at 100;
 * construction succeeds without exposing Health. Two instances stay
 * independent objects.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateUProperty
 * @Harness UClass
 * @Tag Feature.Access.PrivateUProperty
 * @Provenance Theme: Feature.Access. WorldStory: UPROPERTY may be declared private.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 7 AssertCompiles.
 * @Provenance Oracle: Health stays private at 100; construction succeeds without exposing Health.
 * @Provenance Extra: empty construct; two instances are independent objects.
 * @Provenance FixtureIsolated. Keep UPROPERTY name Health.
 */

class AActorUPropPriv : AActor
{
	UPROPERTY()
	private int Health = 100;

	/**
	 * Observe that a constructed instance is a live object.
	 *
	 * @Kind Observe
	 * @Covers Access.PrivateUProperty
	 * @Inputs this instance
	 * @Return true when the handle is not null
	 * @Boundary empty construct
	 */
	UFUNCTION()
	bool EmptyConstruct()
	{
		return this != nullptr;
	}

	/**
	 * Observe that this instance and another instance are distinct objects.
	 *
	 * @Kind Observe
	 * @Covers Access.PrivateUProperty
	 * @Inputs a second actor
	 * @Return true when the two handles are different objects
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AActorUPropPriv Second)
	{
		if (Second is null)
		{
			throw("PrivateUProperty setup: required Second is null");
		}
		return this != Second;
	}
}
