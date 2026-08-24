// Theme: Containers.TWeakObjectPtr. WorldStory: declare, default invalid, assign, Get, null.
// C++: AngelscriptCoverageWeakReferenceTests.cpp::WeakObjectPtrBasics
// CompileScriptModule + spawn + BeginPlay. Oracle: Declaration/Assignment/IsValid/Get/NullAssignment true.
// Extra: local construct leaves flags false; empty TWeakObjectPtr is not valid.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageWeakRefBasicsActor : AActor
{
	UPROPERTY()
	bool DeclarationWorked = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool IsValidWorked = false;

	UPROPERTY()
	bool GetWorked = false;

	UPROPERTY()
	bool NullAssignmentWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test declaration
		TWeakObjectPtr<AActor> WeakActor;
		DeclarationWorked = true;

		// Test null by default
		if (!WeakActor.IsValid())
		{
			IsValidWorked = true;
		}

		// Test assignment from strong reference
		WeakActor = this;
		if (WeakActor.IsValid())
		{
			AssignmentWorked = true;
		}

		// Test Get() method
		AActor Retrieved = WeakActor.Get();
		if (Retrieved == this)
		{
			GetWorked = true;
		}

		// Test assignment to null
		WeakActor = nullptr;
		if (!WeakActor.IsValid())
		{
			NullAssignmentWorked = true;
		}
	}
}

bool Observe_WeakRefBasics_DefaultEmpty(ACoverageWeakRefBasicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WeakObjectPtrBasics setup: required Actor is null");
	}
	return Actor.DeclarationWorked == false
		&& Actor.AssignmentWorked == false
		&& Actor.IsValidWorked == false
		&& Actor.GetWorked == false
		&& Actor.NullAssignmentWorked == false;
}

bool Observe_WeakRefBasics_EmptyNull()
{
	TWeakObjectPtr<AActor> WeakActor;
	return WeakActor.IsValid() == false && WeakActor.Get() == nullptr && WeakActor == nullptr;
}

bool Observe_WeakRefBasics_CopyIndependence()
{
	TWeakObjectPtr<AActor> First;
	TWeakObjectPtr<AActor> Second;
	First = nullptr;
	return First.IsValid() == false && Second.IsValid() == false && Second.Get() == nullptr;
}
