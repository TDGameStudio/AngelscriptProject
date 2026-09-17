/**
 * @version v1
 * @summary An OnComponentHit binding whose handler records the count and the hit normal. The C++ oracle in this method is HitCount == 0, because no hit is dispatched here. The observers cover the local-construct default and copy.
 * @topic World
 */
/**
 * @version root
 * @summary An OnComponentHit binding whose handler records the count and the hit normal. The C++ oracle in this method is HitCount == 0, because no hit is dispatched here. The observers cover the local-construct default and copy.
 * @topic Baseline
 */
UCLASS()
class ACoveragePrimitiveHitEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	int HitCount = 0;

	UPROPERTY()
	FVector HitNormal;

	/**
	 * WorldStory: BeginPlay enables collision and binds the hit delegate.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return the hit delegate bound; HitCount stays 0 because nothing is dispatched here
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		MeshComp.SetNotifyRigidBodyCollision(true);

		MeshComp.OnComponentHit.AddUFunction(this, n"HandleHit");
	}

	/**
	 * Count a hit and record the normal it arrived with.
	 *
	 * @Kind EventHandler
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs both components, the other actor, the impulse and the hit result
	 * @Return HitCount incremented and HitNormal set from the hit result
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
		HitNormal = Hit.Normal;
	}

	/**
	 * Observe that a locally constructed actor has no count, no normal and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the count is 0, the normal is zero and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (HitCount != 0)
		{
			return false;
		}
		if (HitNormal.X != 0.0f)
		{
			return false;
		}
		if (HitNormal.Y != 0.0f)
		{
			return false;
		}
		if (HitNormal.Z != 0.0f)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the recorded hit and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveHitEventsActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveHitEvents setup: required Second is null");
		}
		HitCount = 1;
		HitNormal = FVector(0.0f, 0.0f, 1.0f);

		if (HitCount != 1)
		{
			return false;
		}
		if (HitNormal.Z != 1.0f)
		{
			return false;
		}
		if (Second.HitCount != 0)
		{
			return false;
		}
		return Second.HitNormal.Z == 0.0f;
	}
}
/** @end */
