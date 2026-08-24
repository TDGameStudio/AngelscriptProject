// Theme: World.Actor. WorldStory: OnActorHit / OnActorBeginOverlap / OnActorEndOverlap
// bound through AddUFunction.
// C++: AngelscriptCoveragePhysicsTests.cpp::ActorCollisionEvents
// Oracle: VerifyByPath ActorDelegatesBound true, ActorHitCount 1, ActorBeginOverlapCount 1,
// ActorEndOverlapCount 1 after C++ broadcasts.
// Extra: counts stay 0 and ActorDelegatesBound stays false until BeginPlay binds.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ACoveragePhysicsActorCollisionEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	int ActorHitCount = 0;

	UPROPERTY()
	int ActorBeginOverlapCount = 0;

	UPROPERTY()
	int ActorEndOverlapCount = 0;

	UPROPERTY()
	bool ActorDelegatesBound = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		Sphere.SetCollisionProfileName(n"OverlapAllDynamic");
		Sphere.SetNotifyRigidBodyCollision(true);
		Sphere.SetGenerateOverlapEvents(true);

		OnActorHit.AddUFunction(this, n"OnActorHitEvent");
		OnActorBeginOverlap.AddUFunction(this, n"OnActorBeginOverlapEvent");
		OnActorEndOverlap.AddUFunction(this, n"OnActorEndOverlapEvent");
		ActorDelegatesBound = true;
	}

	UFUNCTION()
	void OnActorHitEvent(AActor SelfActor, AActor OtherActor, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ActorHitCount += 1;
	}

	UFUNCTION()
	void OnActorBeginOverlapEvent(AActor OverlappedActor, AActor OtherActor)
	{
		ActorBeginOverlapCount += 1;
	}

	UFUNCTION()
	void OnActorEndOverlapEvent(AActor OverlappedActor, AActor OtherActor)
	{
		ActorEndOverlapCount += 1;
	}
}
