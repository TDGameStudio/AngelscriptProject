// Theme: Containers.TWeakObjectPtr. WorldStory: default null, assign, reset, reassign.
// C++: AngelscriptCoverageWeakReferenceTests.cpp::WeakObjectPtrNullComparisonAndReassignment
// CompileScriptModule + spawn + BeginPlay. Oracle: DefaultEqualsNull / AssignedNotNull /
// ResetEqualsNull / ReassignedToNewObject all true.
// Extra: local construct leaves WeakTarget null and flags false; copies stay independent.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageWeakRefNullReassignActor : AActor
{
	UPROPERTY()
	TWeakObjectPtr<AActor> WeakTarget;

	UPROPERTY()
	bool DefaultEqualsNull = false;

	UPROPERTY()
	bool AssignedNotNull = false;

	UPROPERTY()
	bool ResetEqualsNull = false;

	UPROPERTY()
	bool ReassignedToNewObject = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DefaultEqualsNull = WeakTarget == nullptr;

		AActor FirstActor = SpawnActor(AActor::StaticClass());
		WeakTarget = FirstActor;
		AssignedNotNull = WeakTarget != nullptr && WeakTarget.Get() == FirstActor;

		WeakTarget = nullptr;
		ResetEqualsNull = WeakTarget == nullptr && WeakTarget.Get() == nullptr;

		AActor SecondActor = SpawnActor(AActor::StaticClass());
		WeakTarget = SecondActor;
		ReassignedToNewObject = WeakTarget.IsValid() && WeakTarget.Get() == SecondActor && WeakTarget.Get() != FirstActor;
	}
}

bool Observe_WeakRefNullReassign_DefaultEmpty(ACoverageWeakRefNullReassignActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WeakObjectPtrNullComparisonAndReassignment setup: required Actor is null");
	}
	return Actor.WeakTarget == nullptr
		&& Actor.WeakTarget.Get() == nullptr
		&& Actor.DefaultEqualsNull == false
		&& Actor.AssignedNotNull == false
		&& Actor.ResetEqualsNull == false
		&& Actor.ReassignedToNewObject == false;
}

bool Observe_WeakRefNullReassign_ResetBoundary()
{
	TWeakObjectPtr<AActor> WeakTarget;
	WeakTarget = nullptr;
	return WeakTarget == nullptr && WeakTarget.Get() == nullptr && WeakTarget.IsValid() == false;
}

bool Observe_WeakRefNullReassign_CopyIndependence(ACoverageWeakRefNullReassignActor First, ACoverageWeakRefNullReassignActor Second)
{
	if (First is null)
	{
		throw("Test_WeakObjectPtrNullComparisonAndReassignment setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_WeakObjectPtrNullComparisonAndReassignment setup: required Second is null");
	}
	First.DefaultEqualsNull = true;
	First.WeakTarget = nullptr;
	return First.DefaultEqualsNull == true
		&& Second.DefaultEqualsNull == false
		&& Second.WeakTarget == nullptr
		&& Second.ReassignedToNewObject == false;
}
