// Theme: Containers.TSoftObjectPtr. WorldStory: TSoftClassPtr declare, assign, Get, spawn.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftClassPtrBasics
// CompileScriptModule + spawn + BeginPlay. Oracle: Declaration/Assignment/Get/SpawnFromSoftClass true.
// Extra: local construct leaves flags false; empty TSoftClassPtr is null.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageSoftClassBasicsActor : AActor
{
	UPROPERTY()
	bool DeclarationWorked = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool GetWorked = false;

	UPROPERTY()
	bool SpawnFromSoftClassWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test declaration
		TSoftClassPtr<AActor> SoftClass;
		DeclarationWorked = true;

		// Test assignment
		SoftClass = AActor::StaticClass();
		if (SoftClass.IsValid())
		{
			AssignmentWorked = true;
		}

		// Test Get
		TSubclassOf<AActor> GetClass = SoftClass.Get();
		if (GetClass.IsValid() && GetClass.IsChildOf(AActor::StaticClass()))
		{
			GetWorked = true;
		}

		// Test spawning with loaded class
		if (GetClass.IsValid())
		{
			AActor SpawnedActor = SpawnActor(GetClass);
			if (SpawnedActor != nullptr)
			{
				SpawnFromSoftClassWorked = true;
			}
		}
	}
}

bool Observe_SoftClassBasics_DefaultEmpty(ACoverageSoftClassBasicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftClassPtrBasics setup: required Actor is null");
	}
	return Actor.DeclarationWorked == false
		&& Actor.AssignmentWorked == false
		&& Actor.GetWorked == false
		&& Actor.SpawnFromSoftClassWorked == false;
}

bool Observe_SoftClassBasics_EmptyNull()
{
	TSoftClassPtr<AActor> SoftClass;
	return SoftClass.IsNull() && !SoftClass.IsValid();
}

bool Observe_SoftClassBasics_CopyIndependence()
{
	TSoftClassPtr<AActor> First = AActor::StaticClass();
	TSoftClassPtr<AActor> Second;
	return First.IsValid() && Second.IsNull();
}
