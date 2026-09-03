/**
 * A sphere component whose hit and overlap delegates are bound in BeginPlay, with
 * each handler recording a count and whether the payload matched the values C++
 * broadcast. The observers cover the local-construct default and copy
 * independence.
 *
 * @Theme World.Component
 * @Subject Component.CollisionEventDispatch
 * @Harness UClass
 * @Tag World.Component.ComponentCollisionEventDispatch
 * @Provenance Theme: World.Component. WorldStory: OnComponentHit/BeginOverlap/EndOverlap
 * @Provenance payload matching.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::ComponentCollisionEventDispatch
 * @Provenance sha256=e84c3fae200952deb5b7b595b3ee2dcfbd90e835b69d465c2c9022da3592c996; lines 1415-1496.
 * @Provenance Oracle: C++ broadcasts once; counts 1 and payload match flags true.
 * @Provenance Extra: local construct counts 0, flags false, Sphere null. FixtureIsolated.
 */

UCLASS()
class ACoveragePhysicsComponentCollisionEventActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	int ComponentHitCount = 0;

	UPROPERTY()
	int ComponentBeginOverlapCount = 0;

	UPROPERTY()
	int ComponentEndOverlapCount = 0;

	UPROPERTY()
	bool ComponentDelegatesBound = false;

	UPROPERTY()
	bool HitPayloadMatched = false;

	UPROPERTY()
	bool BeginOverlapPayloadMatched = false;

	UPROPERTY()
	bool EndOverlapPayloadMatched = false;

	/**
	 * WorldStory: enable collision and bind all three delegates on the sphere.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs a default-attached USphereComponent
	 * @Return ComponentDelegatesBound true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		Sphere.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
		Sphere.SetGenerateOverlapEvents(true);
		Sphere.SetNotifyRigidBodyCollision(true);

		Sphere.OnComponentHit.AddUFunction(this, n"OnComponentHitEvent");
		Sphere.OnComponentBeginOverlap.AddUFunction(this, n"OnComponentBeginOverlapEvent");
		Sphere.OnComponentEndOverlap.AddUFunction(this, n"OnComponentEndOverlapEvent");
		ComponentDelegatesBound = true;
	}

	/**
	 * Record a hit and whether every payload field matched what C++ broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs the hit delegate payload
	 * @Return ComponentHitCount incremented; HitPayloadMatched set from the payload
	 * @Param HitComponent the component that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param OtherComp the other component in the hit
	 * @Param NormalImpulse the impulse, expected to be (0, 2, 0)
	 * @Param Hit the hit result, expected to be blocking at (10, 20, 30)
	 */
	UFUNCTION()
	void OnComponentHitEvent(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ComponentHitCount += 1;
		HitPayloadMatched =
			HitComponent == Sphere
			&& OtherActor != nullptr
			&& OtherComp != nullptr
			&& Hit.GetbBlockingHit()
			&& NormalImpulse.Equals(FVector(0.0f, 2.0f, 0.0f), 0.01f)
			&& Hit.ImpactPoint.Equals(FVector(10.0f, 20.0f, 30.0f), 0.01f)
			&& Hit.BoneName == n"CoverageComponentHitBone";
	}

	/**
	 * Record a begin overlap and whether every payload field matched.
	 *
	 * @Kind EventHandler
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs the begin overlap delegate payload
	 * @Return ComponentBeginOverlapCount incremented; BeginOverlapPayloadMatched set from the payload
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index, expected to be 17
	 * @Param bFromSweep whether the overlap came from a sweep, expected true
	 * @Param SweepResult the sweep result, expected blocking at (4, 5, 6)
	 */
	UFUNCTION()
	void OnComponentBeginOverlapEvent(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		ComponentBeginOverlapCount += 1;
		BeginOverlapPayloadMatched =
			OverlappedComponent == Sphere
			&& OtherActor != nullptr
			&& OtherComp != nullptr
			&& OtherBodyIndex == 17
			&& bFromSweep
			&& SweepResult.GetbBlockingHit()
			&& SweepResult.Location.Equals(FVector(4.0f, 5.0f, 6.0f), 0.01f);
	}

	/**
	 * Record an end overlap and whether every payload field matched.
	 *
	 * @Kind EventHandler
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs the end overlap delegate payload
	 * @Return ComponentEndOverlapCount incremented; EndOverlapPayloadMatched set from the payload
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index, expected to be 19
	 */
	UFUNCTION()
	void OnComponentEndOverlapEvent(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
	{
		ComponentEndOverlapCount += 1;
		EndOverlapPayloadMatched =
			OverlappedComponent == Sphere
			&& OtherActor != nullptr
			&& OtherComp != nullptr
			&& OtherBodyIndex == 19;
	}

	/**
	 * Observe that a locally constructed actor holds no counts and no matches.
	 *
	 * @Kind Observe
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all counts are 0, all flags clear and Sphere is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ComponentHitCount != 0)
		{
			return false;
		}
		if (ComponentBeginOverlapCount != 0)
		{
			return false;
		}
		if (ComponentEndOverlapCount != 0)
		{
			return false;
		}
		if (ComponentDelegatesBound)
		{
			return false;
		}
		if (HitPayloadMatched)
		{
			return false;
		}
		if (BeginOverlapPayloadMatched)
		{
			return false;
		}
		if (EndOverlapPayloadMatched)
		{
			return false;
		}
		return Sphere == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds one matched hit and the other holds none
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePhysicsComponentCollisionEventActor Second)
	{
		if (Second is null)
		{
			throw("ComponentCollisionEventDispatch setup: required Second is null");
		}
		ComponentHitCount = 1;
		HitPayloadMatched = true;

		if (ComponentHitCount != 1)
		{
			return false;
		}
		if (!HitPayloadMatched)
		{
			return false;
		}
		if (Second.ComponentHitCount != 0)
		{
			return false;
		}
		return !Second.HitPayloadMatched;
	}
}
