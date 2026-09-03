/**
 * AddUFunction binds a component begin-overlap handler. After BeginPlay and a
 * broadcast, BeginOverlapCount is 1 and LastOtherActor is the other actor.
 * Defaults are count 0 / LastOtherActor null, and a direct handler with a
 * null other is the empty other boundary.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ComponentBeginOverlapAddUFunction
 * @Harness UClass
 * @Tag Definitions.UFunction.ComponentBeginOverlapAddUFunction
 * @Provenance Theme: Definitions.UFunction. WorldStory: AddUFunction binds component begin-overlap.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::ComponentBeginOverlapAddUFunction
 * @Provenance Spawn owner/other, BeginPlay, Broadcast OnComponentBeginOverlap.
 * @Provenance Oracle: VerifyByPath BeginOverlapCount == 1; LastOtherActor is the other actor.
 * @Provenance Extra: default count 0 / LastOtherActor null; direct handler with null other.
 * @Provenance FixtureIsolated. Keep UPROPERTY names the C++ path uses. n"" FName.
 */

UCLASS()
class UTestComponentBeginOverlapReceiver : USphereComponent
{
	UPROPERTY()
	int BeginOverlapCount = 0;

	UPROPERTY()
	AActor LastOtherActor = nullptr;

	/**
	 * Bind HandleComponentBeginOverlap onto OnComponentBeginOverlap.
	 *
	 * @Kind WorldStory
	 * @Covers UFunction.Specifier
	 * @Inputs OnComponentBeginOverlap.AddUFunction(this, n"HandleComponentBeginOverlap")
	 * @Return void
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnComponentBeginOverlap.AddUFunction(this, n"HandleComponentBeginOverlap");
	}

	/**
	 * Record the other actor and increment BeginOverlapCount.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param OverlappedComponent This component
	 * @Param OtherActor Other actor
	 * @Param OtherComponent Other component
	 * @Param OtherBodyIndex Body index
	 * @Param bFromSweep Sweep flag
	 * @Param Hit Hit result received as const FHitResult&in
	 * @Inputs overlap arguments
	 * @Return void; LastOtherActor and BeginOverlapCount update
	 */
	UFUNCTION()
	void HandleComponentBeginOverlap(
		UPrimitiveComponent OverlappedComponent,
		AActor OtherActor,
		UPrimitiveComponent OtherComponent,
		int OtherBodyIndex,
		bool bFromSweep,
		const FHitResult&in Hit)
	{
		LastOtherActor = OtherActor;
		BeginOverlapCount += 1;
	}

	/**
	 * Observe the default BeginOverlapCount of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed receiver
	 * @Return 0
	 * @Boundary default count
	 */
	UFUNCTION()
	int DefaultBeginOverlapCount()
	{
		return BeginOverlapCount;
	}

	/**
	 * Observe the default LastOtherActor of null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed receiver
	 * @Return true when LastOtherActor is null
	 * @Boundary default other
	 */
	UFUNCTION()
	bool DefaultLastOtherActorIsNull()
	{
		return LastOtherActor == nullptr;
	}

	/**
	 * Observe a direct HandleComponentBeginOverlap with a live other actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param OtherActor Other actor recorded
	 * @Inputs HandleComponentBeginOverlap with OtherActor
	 * @Return true when BeginOverlapCount is 1 and LastOtherActor is OtherActor
	 */
	UFUNCTION()
	bool DirectHandleRecordsOther(AActor OtherActor)
	{
		FHitResult Hit;
		HandleComponentBeginOverlap(nullptr, OtherActor, nullptr, 0, false, Hit);
		if (BeginOverlapCount != 1)
		{
			return false;
		}
		return LastOtherActor is OtherActor;
	}

	/**
	 * Observe a direct handler with a null other actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs HandleComponentBeginOverlap with nullptr OtherActor
	 * @Return true when BeginOverlapCount is 1 and LastOtherActor is null
	 * @Boundary null other
	 */
	UFUNCTION()
	bool DirectHandleNullOtherBoundary()
	{
		FHitResult Hit;
		HandleComponentBeginOverlap(nullptr, nullptr, nullptr, 0, false, Hit);
		if (BeginOverlapCount != 1)
		{
			return false;
		}
		return LastOtherActor == nullptr;
	}
}

UCLASS()
class ATestComponentBeginOverlapOwner : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestComponentBeginOverlapReceiver Trigger;
}

UCLASS()
class ATestComponentBeginOverlapOther : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Trigger;
}
