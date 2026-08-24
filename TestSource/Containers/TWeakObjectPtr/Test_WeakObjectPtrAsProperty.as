// Theme: Containers.TWeakObjectPtr. WorldStory: TWeakObjectPtr UPROPERTY specifiers.
// C++: AngelscriptCoverageWeakReferenceTests.cpp::WeakObjectPtrAsProperty
// CompileScriptModule + spawn + BeginPlay. Oracle: PropertiesAssigned true; WeakTarget
// EditAnywhere, WeakPawn BlueprintReadWrite.
// Extra: local construct leaves PropertiesAssigned false and both weak refs null.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageWeakRefPropertyActor : AActor
{
	UPROPERTY(EditAnywhere)
	TWeakObjectPtr<AActor> WeakTarget;

	UPROPERTY(BlueprintReadWrite)
	TWeakObjectPtr<APawn> WeakPawn;

	UPROPERTY()
	bool PropertiesAssigned = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		WeakTarget = this;
		WeakPawn = Cast<APawn>(SpawnActor(APawn::StaticClass()));

		if (WeakTarget.IsValid() && WeakPawn.IsValid())
		{
			PropertiesAssigned = true;
		}
	}
}

bool Observe_WeakRefProperty_DefaultEmpty(ACoverageWeakRefPropertyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WeakObjectPtrAsProperty setup: required Actor is null");
	}
	return Actor.PropertiesAssigned == false
		&& Actor.WeakTarget == nullptr
		&& Actor.WeakTarget.Get() == nullptr
		&& Actor.WeakPawn == nullptr
		&& Actor.WeakPawn.IsValid() == false;
}

bool Observe_WeakRefProperty_CopyIndependence(ACoverageWeakRefPropertyActor First, ACoverageWeakRefPropertyActor Second)
{
	if (First is null)
	{
		throw("Test_WeakObjectPtrAsProperty setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_WeakObjectPtrAsProperty setup: required Second is null");
	}
	First.PropertiesAssigned = true;
	return First.PropertiesAssigned == true
		&& Second.PropertiesAssigned == false
		&& Second.WeakTarget == nullptr
		&& Second.WeakPawn == nullptr;
}
