// Theme: World.Component. WorldStory: component EndPlay receives EEndPlayReason::Destroyed.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::EndPlayReceivesDestroyedReason
// spawn + BeginPlay + DestroyAndDrain, then VerifyByPath EndPlayCount=1 and
// LastReason=EEndPlayReason::Destroyed. Keep those UPROPERTY names.
// sha256=603c11a7b0923206938eb70f71c00e15c4db890bb10f7463a077573bb482b80d; lines 245-269.
// Extra: local construct leaves EndPlayCount=0 and LastReason=Quit; copy writes stay independent.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class UTestComponentLifecycleEndPlayProbe : UActorComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	EEndPlayReason LastReason = EEndPlayReason::Quit;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
		LastReason = Reason;
	}
}

UCLASS()
class ATestComponentLifecycleEndPlayReason : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleEndPlayProbe Probe;
}

bool Observe_EndPlayReason_DefaultEmpty(UTestComponentLifecycleEndPlayProbe Probe)
{
	if (Probe is null)
	{
		throw("Test_EndPlayReceivesDestroyedReason setup: required Probe is null");
	}
	return Probe.EndPlayCount == 0 && Probe.LastReason == EEndPlayReason::Quit;
}

bool Observe_EndPlayReason_CopyIndependence(UTestComponentLifecycleEndPlayProbe First, UTestComponentLifecycleEndPlayProbe Second)
{
	if (First is null)
	{
		throw("Test_EndPlayReceivesDestroyedReason setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_EndPlayReceivesDestroyedReason setup: required Second is null");
	}
	First.EndPlayCount = 1;
	First.LastReason = EEndPlayReason::Destroyed;
	return First.EndPlayCount == 1
		&& First.LastReason == EEndPlayReason::Destroyed
		&& Second.EndPlayCount == 0
		&& Second.LastReason == EEndPlayReason::Quit;
}
