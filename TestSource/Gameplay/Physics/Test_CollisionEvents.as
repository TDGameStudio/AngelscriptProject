// Theme: Gameplay.Physics. WorldStory hit/overlap event binding flags.
// C++: AngelscriptCoveragePhysicsTests.cpp::CollisionEvents
// Oracle VerifyByPath after BeginPlay: HitEventBound true, OverlapEventBound true.
// Extra: defaults false / counts 0. FixtureIsolated. Keep UPROPERTY names.

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

	UFUNCTION()
	void OnHit(UPrimitiveComponent HitComp, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, FHitResult& Hit)
	{
		HitCount++;
	}

	UFUNCTION()
	void OnBeginOverlap(UPrimitiveComponent OverlappedComp, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, FHitResult& SweepResult)
	{
		OverlapBeginCount++;
	}

	UFUNCTION()
	void OnEndOverlap(UPrimitiveComponent OverlappedComp, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
	{
		OverlapEndCount++;
	}
}

bool Observe_CollisionEvents_Defaults(ACoveragePhysicsCollisionEventsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CollisionEvents setup: required Actor is null");
	}
	return Actor.HitEventBound == false
		&& Actor.OverlapEventBound == false
		&& Actor.HitCount == 0
		&& Actor.OverlapBeginCount == 0
		&& Actor.OverlapEndCount == 0;
}

bool Observe_CollisionEvents_NullHitBoundary(ACoveragePhysicsCollisionEventsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CollisionEvents setup: required Actor is null");
	}
	FHitResult Hit;
	Actor.OnHit(nullptr, nullptr, nullptr, FVector::ZeroVector, Hit);
	return Actor.HitCount == 1;
}
