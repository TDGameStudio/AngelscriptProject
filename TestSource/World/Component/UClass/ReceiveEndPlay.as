/**
 * A component whose EndPlay sets bCleanedUp. C++ begins play, destroys the host
 * and ticks the world, then verifies bCleanedUp through its path. The observers
 * cover the local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.ReceiveEndPlay
 * @Harness UClass
 * @Tag World.Component.ReceiveEndPlay
 * @Provenance Theme: World.Component. WorldStory: TestCase component EndPlay sets bCleanedUp.
 * @Provenance C++: AngelscriptComponentTests.cpp::ReceiveEndPlay
 * @Provenance BeginPlay + Destroy host + TickWorld, then VerifyByPath bCleanedUp true. Keep bCleanedUp.
 * @Provenance sha256=6210078ff15fed236b3298aa18cfebd0602a2bc5c94335e1bd75f53be98cb93d; lines 217-230.
 * @Provenance Extra: local construct leaves bCleanedUp false; writing one instance leaves the other false.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class UTestComponentReceiveEndPlay : UActorComponent
{
	UPROPERTY()
	bool bCleanedUp = false;

	/**
	 * WorldStory: EndPlay flips bCleanedUp to true.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ReceiveEndPlay
	 * @Inputs the end play reason supplied by the engine
	 * @Return bCleanedUp == true once EndPlay has run
	 * @Param Reason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		bCleanedUp = true;
	}

	/**
	 * Observe that a locally constructed component has not cleaned up.
	 *
	 * @Kind Observe
	 * @Covers Component.ReceiveEndPlay
	 * @Inputs a component that has not ended play
	 * @Return true when bCleanedUp is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return bCleanedUp == false;
	}

	/**
	 * Observe that writing this component leaves another component untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.ReceiveEndPlay
	 * @Inputs this component plus a second component
	 * @Return true when this is cleaned up and the other is not
	 * @Param Second the other component, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentReceiveEndPlay Second)
	{
		if (Second is null)
		{
			throw("ReceiveEndPlay setup: required Second is null");
		}
		bCleanedUp = true;

		if (!bCleanedUp)
		{
			return false;
		}
		return Second.bCleanedUp == false;
	}
}
