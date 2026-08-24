// Theme: World.Component. WorldStory: component HasBegunPlay before/inside
// BeginPlay override.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::HasBegunPlayTransitionsInWorld
// sha256=10a76a98e40f4535e18f0db271d93f75b245ce5fd788730f9be2ff165899b7d0; lines 74-102.
// Oracle Probe HasBegunPlay false before actor BeginPlay, true after;
// bSawBeginPlay true; bHadNotBegunPlayInsideOverride true; OwnerAtBeginPlay
// is the actor. Extra: local construct flags false, OwnerAtBeginPlay null,
// Probe null. FixtureIsolated.

UCLASS()
class UTestComponentLifecycleBeginPlayProbe : UActorComponent
{
	UPROPERTY()
	bool bSawBeginPlay = false;

	UPROPERTY()
	bool bHadNotBegunPlayInsideOverride = false;

	UPROPERTY()
	AActor OwnerAtBeginPlay;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bSawBeginPlay = true;
		bHadNotBegunPlayInsideOverride = !HasBegunPlay();
		OwnerAtBeginPlay = GetOwner();
	}
}

UCLASS()
class ATestComponentLifecycleHasBegunPlay : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleBeginPlayProbe Probe;
}

bool Observe_HasBegunPlay_DefaultFalse(ATestComponentLifecycleHasBegunPlay Actor)
{
	if (Actor is null)
	{
		throw("Test_HasBegunPlayTransitionsInWorld setup: required Actor is null");
	}
	return Actor.Probe == nullptr;
}

bool Observe_HasBegunPlay_ProbeDefaultNull(UTestComponentLifecycleBeginPlayProbe Probe)
{
	if (Probe is null)
	{
		throw("Test_HasBegunPlayTransitionsInWorld setup: required Probe is null");
	}
	return !Probe.bSawBeginPlay
		&& !Probe.bHadNotBegunPlayInsideOverride
		&& Probe.OwnerAtBeginPlay == nullptr;
}
