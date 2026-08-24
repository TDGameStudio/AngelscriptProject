// Theme: Containers.TSubclassOf. WorldStory: declare, null default, assign, Get, compare.
// C++: AngelscriptCoverageWeakReferenceTests.cpp::TSubclassOfBasics
// CompileScriptModule + spawn + BeginPlay. Oracle: Declaration/Assignment/Get/NullCheck/Comparison true.
// Extra: local construct leaves flags false; empty TSubclassOf is nullptr.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageSubclassOfBasicsActor : AActor
{
	UPROPERTY()
	bool DeclarationWorked = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool GetWorked = false;

	UPROPERTY()
	bool NullCheckWorked = false;

	UPROPERTY()
	bool ComparisonWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test declaration
		TSubclassOf<AActor> ActorClass;
		DeclarationWorked = true;

		// Test null by default
		if (ActorClass == nullptr)
		{
			NullCheckWorked = true;
		}

		// Test assignment
		ActorClass = AActor::StaticClass();
		if (ActorClass != nullptr)
		{
			AssignmentWorked = true;
		}

		// Test Get() method
		UClass ClassRef = ActorClass.Get();
		if (ClassRef != nullptr)
		{
			GetWorked = true;
		}

		// Test comparison
		TSubclassOf<AActor> SameClass = AActor::StaticClass();
		if (ActorClass == SameClass)
		{
			ComparisonWorked = true;
		}
	}
}

bool Observe_SubclassOfBasics_DefaultEmpty(ACoverageSubclassOfBasicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfBasics setup: required Actor is null");
	}
	return Actor.DeclarationWorked == false
		&& Actor.AssignmentWorked == false
		&& Actor.GetWorked == false
		&& Actor.NullCheckWorked == false
		&& Actor.ComparisonWorked == false;
}

bool Observe_SubclassOfBasics_EmptyNull()
{
	TSubclassOf<AActor> ActorClass;
	return ActorClass == nullptr;
}

bool Observe_SubclassOfBasics_CopyIndependence()
{
	TSubclassOf<AActor> First = AActor::StaticClass();
	TSubclassOf<AActor> Second;
	return First != nullptr && Second == nullptr && First.Get() != nullptr;
}
