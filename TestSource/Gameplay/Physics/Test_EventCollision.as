// Theme: Gameplay.Physics. WorldStory overlap/hit handlers on a sphere component.
// C++: AngelscriptCoverageEventTests.cpp::EventCollision
// Oracle: compile/spawn; after BeginOverlap broadcast BeginOverlapCount == 1.
// Extra: defaults 0 / empty name; null OtherActor leaves name empty. FixtureIsolated.
// Keep UPROPERTY names.

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

	UFUNCTION()
	void HandleEndOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
		UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
	{
		EndOverlapCount++;
	}

	UFUNCTION()
	void HandleHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp,
		FVector NormalImpulse, const FHitResult&in Hit)
	{
		HitCount++;
	}
}

bool Observe_EventCollision_Defaults(ACoverageEventCollisionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventCollision setup: required Actor is null");
	}
	return Actor.BeginOverlapCount == 0
		&& Actor.EndOverlapCount == 0
		&& Actor.HitCount == 0
		&& Actor.OverlappedActorName.IsEmpty();
}

bool Observe_EventCollision_NullOverlapBoundary(ACoverageEventCollisionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventCollision setup: required Actor is null");
	}
	FHitResult SweepResult;
	Actor.HandleBeginOverlap(nullptr, nullptr, nullptr, 0, false, SweepResult);
	return Actor.BeginOverlapCount == 1 && Actor.OverlappedActorName.IsEmpty();
}
