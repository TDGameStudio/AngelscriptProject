/**
 * @version v1
 * @summary Hit and overlap event bindings on a sphere component. C++ verifies HitEventBound and OverlapEventBound by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. The observers cover.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Hit and overlap event bindings on a sphere component. C++ verifies HitEventBound and OverlapEventBound by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. The observers cover.
 * @topic Baseline
 */
UCLASS()
class ACoveragePhysicsCollisionEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool HitEventBound = false;

	UPROPERTY()
	bool OverlapEventBound = false;

	UPROPERTY()
	int HitCount = 0;

	UPROPERTY()
	int OverlapBeginCount = 0;

	UPROPERTY()
	int OverlapEndCount = 0;

	/**
	 * WorldStory: BeginPlay binds hit and overlap delegates and enables collision events.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.CollisionEvents
	 * @Inputs a default-attached USphereComponent
	 * @Return HitEventBound and OverlapEventBound true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Bind hit event
		Sphere.OnComponentHit.AddUFunction(this, n"OnHit");
		HitEventBound = true;

		// Bind overlap events
		Sphere.OnComponentBeginOverlap.AddUFunction(this, n"OnBeginOverlap");
		Sphere.OnComponentEndOverlap.AddUFunction(this, n"OnEndOverlap");
		OverlapEventBound = true;

		// Enable collision events
		Sphere.SetNotifyRigidBodyCollision(true);
		Sphere.SetGenerateOverlapEvents(true);
	}

	/**
	 * Count a hit.
	 *
	 * @Kind EventHandler
	 * @Covers Physics.CollisionEvents
	 * @Inputs both components, the other actor, the impulse and the hit result
	 * @Return HitCount incremented
	 * @Param HitComp the component that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param OtherComp the other component in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void OnHit(UPrimitiveComponent HitComp, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, FHitResult&inout Hit)
	{
		HitCount++;
	}

	/**
	 * Count a begin overlap.
	 *
	 * @Kind EventHandler
	 * @Covers Physics.CollisionEvents
	 * @Inputs both components, the other actor, the body index, the sweep flag and the sweep result
	 * @Return OverlapBeginCount incremented
	 * @Param OverlappedComp the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 * @Param bFromSweep whether the overlap came from a sweep
	 * @Param SweepResult the sweep result
	 */
	UFUNCTION()
	void OnBeginOverlap(UPrimitiveComponent OverlappedComp, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, FHitResult&inout SweepResult)
	{
		OverlapBeginCount++;
	}

	/**
	 * Count an end overlap.
	 *
	 * @Kind EventHandler
	 * @Covers Physics.CollisionEvents
	 * @Inputs both components, the other actor and the body index
	 * @Return OverlapEndCount incremented
	 * @Param OverlappedComp the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 */
	UFUNCTION()
	void OnEndOverlap(UPrimitiveComponent OverlappedComp, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
	{
		OverlapEndCount++;
	}

	/**
	 * Observe that a locally constructed actor holds both flags false and all counts 0.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when HitEventBound and OverlapEventBound are false and HitCount,
	 * OverlapBeginCount and OverlapEndCount are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (HitEventBound)
		{
			return false;
		}
		if (OverlapEventBound)
		{
			return false;
		}
		if (HitCount != 0)
		{
			return false;
		}
		if (OverlapBeginCount != 0)
		{
			return false;
		}
		return OverlapEndCount == 0;
	}

	/**
	 * Observe that calling OnHit with null actors and components still increments HitCount.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionEvents
	 * @Inputs a default-constructed hit result plus null actor and component arguments
	 * @Return true when HitCount is 1
	 * @Boundary null hit arguments
	 */
	UFUNCTION()
	bool NullHitBoundary()
	{
		FHitResult Hit;
		OnHit(nullptr, nullptr, nullptr, FVector::ZeroVector, Hit);
		return HitCount == 1;
	}
}
/** @end */
