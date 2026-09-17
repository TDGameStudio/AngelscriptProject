/**
 * @version v1
 * @summary OnComponentBeginOverlap and OnComponentEndOverlap bound on a sphere component. C++ spawns an overlapping actor and verifies the counts and the recorded name by path. The observers cover the local-construct default and.
 * @topic World
 */
/**
 * @version root
 * @summary OnComponentBeginOverlap and OnComponentEndOverlap bound on a sphere component. C++ spawns an overlapping actor and verifies the counts and the recorded name by path. The observers cover the local-construct default and.
 * @topic Baseline
 */
UCLASS()
class ACoveragePrimitiveCollisionEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	int BeginOverlapCount = 0;

	UPROPERTY()
	int EndOverlapCount = 0;

	UPROPERTY()
	FString OverlappedActorName;

	/**
	 * WorldStory: BeginPlay configures the sphere for overlaps and binds both
	 * overlap delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs a default-attached USphereComponent
	 * @Return both delegates bound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		SphereComp.SetCollisionProfileName(n"OverlapAll");
		SphereComp.SetGenerateOverlapEvents(true);
		SphereComp.SetSphereRadius(100.0f);

		SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"HandleBeginOverlap");
		SphereComp.OnComponentEndOverlap.AddUFunction(this, n"HandleEndOverlap");
	}

	/**
	 * Count a begin overlap and record the name of the other actor.
	 *
	 * @Kind EventHandler
	 * @Covers Component.PrimitiveCollisionEvents
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
	 * @Covers Component.PrimitiveCollisionEvents
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
	 * Observe that a locally constructed actor holds no counts, no name and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both counts are 0, the name is empty and SphereComp is null
	 * @Boundary null default component
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
		if (OverlappedActorName.Len() != 0)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the overlapped state and the other stays empty
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionEventsActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionEvents setup: required Second is null");
		}
		BeginOverlapCount = 1;
		OverlappedActorName = "Other";

		if (BeginOverlapCount != 1)
		{
			return false;
		}
		if (OverlappedActorName.Len() <= 0)
		{
			return false;
		}
		if (Second.BeginOverlapCount != 0)
		{
			return false;
		}
		return Second.OverlappedActorName.Len() == 0;
	}
}
/** @end */
