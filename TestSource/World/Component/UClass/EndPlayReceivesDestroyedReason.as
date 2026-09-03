/**
 * A component EndPlay override recording how many times it ran and the reason it
 * last received. C++ destroys the actor and verifies the count and reason by path.
 * The observers cover the local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.EndPlayReceivesDestroyedReason
 * @Harness UClass
 * @Tag World.Component.EndPlayReceivesDestroyedReason
 * @Provenance Theme: World.Component. WorldStory: component EndPlay receives EEndPlayReason::Destroyed.
 * @Provenance C++: AngelscriptComponentLifecycleExtendedTests.cpp::EndPlayReceivesDestroyedReason
 * @Provenance spawn + BeginPlay + DestroyAndDrain, then VerifyByPath EndPlayCount=1 and
 * @Provenance LastReason=EEndPlayReason::Destroyed. Keep those UPROPERTY names.
 * @Provenance sha256=603c11a7b0923206938eb70f71c00e15c4db890bb10f7463a077573bb482b80d; lines 245-269.
 * @Provenance Extra: local construct leaves EndPlayCount=0 and LastReason=Quit; copy writes stay independent.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class UTestComponentLifecycleEndPlayProbe : UActorComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	EEndPlayReason LastReason = EEndPlayReason::Quit;

	/**
	 * WorldStory: EndPlay records how many times it ran and the reason supplied.
	 *
	 * @Kind WorldStory
	 * @Covers Component.EndPlayReceivesDestroyedReason
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayCount incremented and LastReason set to the received reason
	 * @Param Reason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
		LastReason = Reason;
	}

	/**
	 * Observe that a locally constructed probe has not ended play.
	 *
	 * @Kind Observe
	 * @Covers Component.EndPlayReceivesDestroyedReason
	 * @Inputs a probe that has not ended play
	 * @Return true when the count is 0 and the reason is still Quit
	 * @Boundary declared default
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EndPlayCount != 0)
		{
			return false;
		}
		return LastReason == EEndPlayReason::Quit;
	}

	/**
	 * Observe that writing this probe leaves another probe untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.EndPlayReceivesDestroyedReason
	 * @Inputs this probe plus a second probe
	 * @Return true when this holds one Destroyed end play and the other keeps its defaults
	 * @Param Second the other probe, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentLifecycleEndPlayProbe Second)
	{
		if (Second is null)
		{
			throw("EndPlayReceivesDestroyedReason setup: required Second is null");
		}
		EndPlayCount = 1;
		LastReason = EEndPlayReason::Destroyed;

		if (EndPlayCount != 1)
		{
			return false;
		}
		if (LastReason != EEndPlayReason::Destroyed)
		{
			return false;
		}
		if (Second.EndPlayCount != 0)
		{
			return false;
		}
		return Second.LastReason == EEndPlayReason::Quit;
	}
}

/**
 * The actor that hosts the EndPlay probe as a default component.
 *
 * @Covers Component.EndPlayReceivesDestroyedReason
 * @Inputs none
 * @Return an actor carrying one UTestComponentLifecycleEndPlayProbe
 */
UCLASS()
class ATestComponentLifecycleEndPlayReason : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleEndPlayProbe Probe;
}
