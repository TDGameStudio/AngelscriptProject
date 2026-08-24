// Theme: World.Component. WorldStory: AddUFunction on actor and sphere
// overlap/hit/click/release delegates.
// C++: AngelscriptCoverageEventTests.cpp::EventBuiltInActorAndComponentInstances
// sha256=62e3adb9ec250080a6f2b1f7f8e04094901a4ef27e7f1104d50a2d03770f90a5; lines 646-739.
// Oracle after C++ broadcasts: ActorBeginOverlapCount=1, ActorHitCount=1,
// and the other handler counts increment once. Extra: local construct all
// counts 0, SphereComp null. FixtureIsolated.

UCLASS()
class ACoverageEventBuiltInActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	int ActorBeginOverlapCount = 0;

	UPROPERTY()
	int ActorHitCount = 0;

	UPROPERTY()
	int ActorClickCount = 0;

	UPROPERTY()
	int ActorReleaseCount = 0;

	UPROPERTY()
	int ComponentHitCount = 0;

	UPROPERTY()
	int ComponentBeginOverlapCount = 0;

	UPROPERTY()
	int ComponentClickCount = 0;

	UPROPERTY()
	int ComponentReleaseCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnActorBeginOverlap.AddUFunction(this, n"HandleActorBeginOverlap");
		OnActorHit.AddUFunction(this, n"HandleActorHit");
		OnClicked.AddUFunction(this, n"HandleActorClicked");
		OnReleased.AddUFunction(this, n"HandleActorReleased");

		SphereComp.OnComponentHit.AddUFunction(this, n"HandleComponentHit");
		SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"HandleComponentBeginOverlap");
		SphereComp.OnClicked.AddUFunction(this, n"HandleComponentClicked");
		SphereComp.OnReleased.AddUFunction(this, n"HandleComponentReleased");
	}

	UFUNCTION()
	void HandleActorBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		ActorBeginOverlapCount += 1;
	}

	UFUNCTION()
	void HandleActorHit(AActor SelfActor, AActor OtherActor, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ActorHitCount += 1;
	}

	UFUNCTION()
	void HandleActorClicked(AActor TouchedActor, FKey ButtonPressed)
	{
		ActorClickCount += 1;
	}

	UFUNCTION()
	void HandleActorReleased(AActor TouchedActor, FKey ButtonReleased)
	{
		ActorReleaseCount += 1;
	}

	UFUNCTION()
	void HandleComponentHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ComponentHitCount += 1;
	}

	UFUNCTION()
	void HandleComponentBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		ComponentBeginOverlapCount += 1;
	}

	UFUNCTION()
	void HandleComponentClicked(UPrimitiveComponent TouchedComponent, FKey ButtonPressed)
	{
		ComponentClickCount += 1;
	}

	UFUNCTION()
	void HandleComponentReleased(UPrimitiveComponent TouchedComponent, FKey ButtonReleased)
	{
		ComponentReleaseCount += 1;
	}
}

bool Observe_BuiltInEvents_DefaultEmpty(ACoverageEventBuiltInActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventBuiltInActorAndComponentInstances setup: required Actor is null");
	}
	return Actor.ActorBeginOverlapCount == 0
		&& Actor.ActorHitCount == 0
		&& Actor.ActorClickCount == 0
		&& Actor.ActorReleaseCount == 0
		&& Actor.ComponentHitCount == 0
		&& Actor.ComponentBeginOverlapCount == 0
		&& Actor.ComponentClickCount == 0
		&& Actor.ComponentReleaseCount == 0
		&& Actor.SphereComp == nullptr;
}

bool Observe_BuiltInEvents_CopyIndependence(ACoverageEventBuiltInActor First, ACoverageEventBuiltInActor Second)
{
	if (First is null)
	{
		throw("Test_EventBuiltInActorAndComponentInstances setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_EventBuiltInActorAndComponentInstances setup: required Second is null");
	}
	First.ActorBeginOverlapCount = 1;
	First.ComponentHitCount = 1;
	return First.ActorBeginOverlapCount == 1
		&& First.ComponentHitCount == 1
		&& Second.ActorBeginOverlapCount == 0
		&& Second.ComponentHitCount == 0;
}
