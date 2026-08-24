// Theme: World.Component. WorldStory: OnComponentBeginOverlap / EndOverlap.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveCollisionEvents
// sha256=a46e5b441a5897c4779d711cc6b86bd3cae8bef70bc7861b1b308a4eaa2e480d; lines 377-423.
// Oracle VerifyByPath BeginOverlapCount=1 after C++ overlap spawn; EndOverlap
// follows. Extra: local construct counts 0, empty OverlappedActorName,
// SphereComp null. FixtureIsolated.

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
}

bool Observe_PrimitiveCollisionEvents_DefaultEmpty(ACoveragePrimitiveCollisionEventsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveCollisionEvents setup: required Actor is null");
	}
	return Actor.BeginOverlapCount == 0
		&& Actor.EndOverlapCount == 0
		&& Actor.OverlappedActorName.Len() == 0
		&& Actor.SphereComp == nullptr;
}

bool Observe_PrimitiveCollisionEvents_CopyIndependence(ACoveragePrimitiveCollisionEventsActor First, ACoveragePrimitiveCollisionEventsActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveCollisionEvents setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveCollisionEvents setup: required Second is null");
	}
	First.BeginOverlapCount = 1;
	First.OverlappedActorName = "Other";
	return First.BeginOverlapCount == 1
		&& First.OverlappedActorName.Len() > 0
		&& Second.BeginOverlapCount == 0
		&& Second.OverlappedActorName.Len() == 0;
}
