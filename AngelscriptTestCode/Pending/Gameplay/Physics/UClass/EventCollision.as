/**
 * @version v1
 * @summary Overlap and hit handlers bound on a sphere component. C++ compiles and spawns the class, then checks BeginOverlapCount after a begin-overlap broadcast, so those UPROPERTY names are part of the contract and are kept.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Overlap and hit handlers bound on a sphere component. C++ compiles and spawns the class, then checks BeginOverlapCount after a begin-overlap broadcast, so those UPROPERTY names are part of the contract and are kept.
 * @topic Baseline
 */
UCLASS()
class ACoverageEventCollisionActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	int BeginOverlapCount = 0;

	UPROPERTY()
	int EndOverlapCount = 0;

	UPROPERTY()
	int HitCount = 0;

	UPROPERTY()
	FString OverlappedActorName;

	/**
	 * WorldStory: BeginPlay configures the sphere for overlaps and binds begin, end
	 * and hit delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.EventCollision
	 * @Inputs a default-attached USphereComponent
	 * @Return all three delegates bound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Setup collision
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		SphereComp.SetCollisionProfileName(n"OverlapAll");
		SphereComp.SetGenerateOverlapEvents(true);
		SphereComp.SetSphereRadius(100.0f);

		// Bind collision events
		SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"HandleBeginOverlap");
		SphereComp.OnComponentEndOverlap.AddUFunction(this, n"HandleEndOverlap");
		SphereComp.OnComponentHit.AddUFunction(this, n"HandleHit");
	}

	/**
	 * Count a begin overlap and record the name of the other actor.
	 *
	 * @Kind EventHandler
	 * @Covers Physics.EventCollision
	 * @Inputs both components, the other actor, the body index, the sweep flag and the sweep result
	 * @Return BeginOverlapCount incremented and OverlappedActorName set from the other actor
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 * @Param bFromSweep whether the overlap came from a sweep
	 * @Param SweepResult the sweep result
	 */
	UFUNCTION()
	void HandleBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
		UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		BeginOverlapCount++;
		if (OtherActor != nullptr)
		{
			OverlappedActorName = OtherActor.GetName().ToString();
		}
	}

	/**
	 * Count an end overlap.
	 *
	 * @Kind EventHandler
	 * @Covers Physics.EventCollision
	 * @Inputs both components, the other actor and the body index
	 * @Return EndOverlapCount incremented
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 */
	UFUNCTION()
	void HandleEndOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
		UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
	{
		EndOverlapCount++;
	}

	/**
	 * Count a hit.
	 *
	 * @Kind EventHandler
	 * @Covers Physics.EventCollision
	 * @Inputs both components, the other actor, the impulse and the hit result
	 * @Return HitCount incremented
	 * @Param HitComponent the component that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param OtherComp the other component in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void HandleHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp,
		FVector NormalImpulse, const FHitResult&in Hit)
	{
		HitCount++;
	}

	/**
	 * Observe that a locally constructed actor holds counts 0 and an empty name.
	 *
	 * @Kind Observe
	 * @Covers Physics.EventCollision
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when BeginOverlapCount, EndOverlapCount and HitCount are 0 and
	 * OverlappedActorName is empty
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (BeginOverlapCount != 0)
		{
			return false;
		}
		if (EndOverlapCount != 0)
		{
			return false;
		}
		if (HitCount != 0)
		{
			return false;
		}
		return OverlappedActorName.IsEmpty();
	}

	/**
	 * Observe that a begin-overlap with a null OtherActor increments the count and
	 * leaves the name empty.
	 *
	 * @Kind Observe
	 * @Covers Physics.EventCollision
	 * @Inputs a default-constructed sweep result plus null actor and component arguments
	 * @Return true when BeginOverlapCount is 1 and OverlappedActorName is empty
	 * @Boundary null OtherActor
	 */
	UFUNCTION()
	bool NullOverlapBoundary()
	{
		FHitResult SweepResult;
		HandleBeginOverlap(nullptr, nullptr, nullptr, 0, false, SweepResult);

		if (BeginOverlapCount != 1)
		{
			return false;
		}
		return OverlappedActorName.IsEmpty();
	}
}
/** @end */
