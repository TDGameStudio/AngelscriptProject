// Theme: World.Component. WorldStory: OnComponentHit/BeginOverlap/EndOverlap
// payload matching.
// C++: AngelscriptCoveragePhysicsTests.cpp::ComponentCollisionEventDispatch
// sha256=e84c3fae200952deb5b7b595b3ee2dcfbd90e835b69d465c2c9022da3592c996; lines 1415-1496.
// Oracle: C++ broadcasts once; counts 1 and payload match flags true.
// Extra: local construct counts 0, flags false, Sphere null. FixtureIsolated.

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
}

bool Observe_CollisionEventDispatch_DefaultEmpty(ACoveragePhysicsComponentCollisionEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentCollisionEventDispatch setup: required Actor is null");
	}
	return Actor.ComponentHitCount == 0
		&& Actor.ComponentBeginOverlapCount == 0
		&& Actor.ComponentEndOverlapCount == 0
		&& !Actor.ComponentDelegatesBound
		&& !Actor.HitPayloadMatched
		&& !Actor.BeginOverlapPayloadMatched
		&& !Actor.EndOverlapPayloadMatched
		&& Actor.Sphere == nullptr;
}

bool Observe_CollisionEventDispatch_CopyIndependence(ACoveragePhysicsComponentCollisionEventActor First, ACoveragePhysicsComponentCollisionEventActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentCollisionEventDispatch setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentCollisionEventDispatch setup: required Second is null");
	}
	First.ComponentHitCount = 1;
	First.HitPayloadMatched = true;
	return First.ComponentHitCount == 1
		&& First.HitPayloadMatched
		&& Second.ComponentHitCount == 0
		&& !Second.HitPayloadMatched;
}
