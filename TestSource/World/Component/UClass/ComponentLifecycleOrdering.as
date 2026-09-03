/**
 * Component BeginPlay and EndPlay each claim an incrementing order token, so C++
 * can compare them against the actor BeginPlay. C++ verifies that the owner was
 * visible during BeginPlay and that both orders are greater than zero.
 *
 * @Theme World.Component
 * @Subject Component.LifecycleOrdering
 * @Harness UClass
 * @Tag World.Component.ComponentLifecycleOrdering
 * @Provenance Theme: World.Component. WorldStory: component BeginPlay/EndPlay order vs actor BeginPlay.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentLifecycleOrdering
 * @Provenance Oracle: bSawOwnerDuringBeginPlay true; BeginPlayOrder and EndPlayOrder > 0.
 * @Provenance Extra: orders 0 and bSawOwnerDuringBeginPlay false until lifecycle. Do not spawn from script.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * Claim the next order token.
	 *
	 * @Kind Helper
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return the next order token, starting at 1
	 */
	int ClaimOrder()
	{
		NextOrder++;
		return NextOrder;
	}

	/**
	 * WorldStory: BeginPlay claims an order token and records that the owner was
	 * already available.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return BeginPlayOrder > 0 and bSawOwnerDuringBeginPlay true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayOrder = ClaimOrder();
		bSawOwnerDuringBeginPlay = GetOwner() != nullptr;
	}

	/**
	 * WorldStory: EndPlay claims the following order token.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayOrder > 0
	 * @Param EndPlayReason why the component is ending play
	 */
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

	/**
	 * WorldStory: the actor BeginPlay records its own position in the ordering.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return ActorBeginPlayOrder == 1 and the "ActorBeginPlayRan" tag appended
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorBeginPlayOrder = 1;
		Tags.Add(n"ActorBeginPlayRan");
	}
}
