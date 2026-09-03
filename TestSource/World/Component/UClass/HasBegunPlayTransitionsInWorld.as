/**
 * A component HasBegunPlay transition observed from inside its own BeginPlay
 * override. C++ spawns the actor and reads the recorded flags and owner by path.
 * The observers cover the local-construct defaults.
 *
 * @Theme World.Component
 * @Subject Component.HasBegunPlayTransitionsInWorld
 * @Harness UClass
 * @Tag World.Component.HasBegunPlayTransitionsInWorld
 * @Provenance Theme: World.Component. WorldStory: component HasBegunPlay before/inside
 * @Provenance BeginPlay override.
 * @Provenance C++: AngelscriptComponentLifecycleExtendedTests.cpp::HasBegunPlayTransitionsInWorld
 * @Provenance sha256=10a76a98e40f4535e18f0db271d93f75b245ce5fd788730f9be2ff165899b7d0; lines 74-102.
 * @Provenance Oracle Probe HasBegunPlay false before actor BeginPlay, true after;
 * @Provenance bSawBeginPlay true; bHadNotBegunPlayInsideOverride true; OwnerAtBeginPlay
 * @Provenance is the actor. Extra: local construct flags false, OwnerAtBeginPlay null,
 * @Provenance Probe null. FixtureIsolated.
 */

UCLASS()
class UTestComponentLifecycleBeginPlayProbe : UActorComponent
{
	UPROPERTY()
	bool bSawBeginPlay = false;

	UPROPERTY()
	bool bHadNotBegunPlayInsideOverride = false;

	UPROPERTY()
	AActor OwnerAtBeginPlay;

	/**
	 * WorldStory: BeginPlay records that HasBegunPlay is still false while the
	 * override is running, and captures the owner.
	 *
	 * @Kind WorldStory
	 * @Covers Component.HasBegunPlayTransitionsInWorld
	 * @Inputs none
	 * @Return bSawBeginPlay true, bHadNotBegunPlayInsideOverride true, OwnerAtBeginPlay the owning actor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bSawBeginPlay = true;
		bHadNotBegunPlayInsideOverride = !HasBegunPlay();
		OwnerAtBeginPlay = GetOwner();
	}

	/**
	 * Observe that a locally constructed probe has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Component.HasBegunPlayTransitionsInWorld
	 * @Inputs a probe that has not begun play
	 * @Return true when both flags are clear and the owner is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool ProbeDefaultNull()
	{
		if (bSawBeginPlay)
		{
			return false;
		}
		if (bHadNotBegunPlayInsideOverride)
		{
			return false;
		}
		return OwnerAtBeginPlay == nullptr;
	}
}

UCLASS()
class ATestComponentLifecycleHasBegunPlay : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleBeginPlayProbe Probe;

	/**
	 * Observe that a locally constructed actor has no probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.HasBegunPlayTransitionsInWorld
	 * @Inputs an actor that has not been spawned
	 * @Return true when Probe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return Probe == nullptr;
	}
}
