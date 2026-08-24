// Theme: World.Component. WorldStory: component BeginPlay/EndPlay order vs actor BeginPlay.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentLifecycleOrdering
// Oracle: bSawOwnerDuringBeginPlay true; BeginPlayOrder and EndPlayOrder > 0.
// Extra: orders 0 and bSawOwnerDuringBeginPlay false until lifecycle. Do not spawn from script.
// FixtureIsolated.

UCLASS()
class UCoverageLifecycleOrderComponent : UActorComponent
{
	UPROPERTY()
	int NextOrder = 0;

	UPROPERTY()
	int BeginPlayOrder = 0;

	UPROPERTY()
	int EndPlayOrder = 0;

	UPROPERTY()
	bool bSawOwnerDuringBeginPlay = false;

	int ClaimOrder()
	{
		NextOrder++;
		return NextOrder;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayOrder = ClaimOrder();
		bSawOwnerDuringBeginPlay = GetOwner() != nullptr;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayOrder = ClaimOrder();
	}
}

UCLASS()
class ACoverageComponentLifecycleOrderingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent)
	UCoverageLifecycleOrderComponent Probe;

	UPROPERTY()
	int ActorBeginPlayOrder = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorBeginPlayOrder = 1;
		Tags.Add(n"ActorBeginPlayRan");
	}
}
