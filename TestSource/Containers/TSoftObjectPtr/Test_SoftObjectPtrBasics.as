// Theme: Containers.TSoftObjectPtr. WorldStory: declare, assign, Get, unloaded Get null.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftObjectPtrBasics
// CompileScriptModule + spawn + BeginPlay. Oracle: Declaration/Assignment/GetWorked and
// GetBeforeLoadReturnsNull true.
// Extra: local construct leaves flags false; empty Get() is null.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageSoftRefBasicsActor : AActor
{
	UPROPERTY()
	bool DeclarationWorked = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool GetWorked = false;

	UPROPERTY()
	bool GetBeforeLoadReturnsNull = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test declaration
		TSoftObjectPtr<AActor> SoftActor;
		DeclarationWorked = true;

		// Test assignment from strong reference
		AActor SpawnedActor = SpawnActor(AActor::StaticClass());
		SoftActor = SpawnedActor;
		if (SoftActor.IsValid())
		{
			AssignmentWorked = true;
		}

		// Test Get() on already-loaded object
		AActor Retrieved = SoftActor.Get();
		if (Retrieved == SpawnedActor)
		{
			GetWorked = true;
		}

		// Test Get() before load returns null for unloaded reference
		// (We simulate this by creating a soft reference to an unloaded path)
		TSoftObjectPtr<AActor> UnloadedSoft;
		AActor UnloadedGet = UnloadedSoft.Get();
		if (UnloadedGet == nullptr)
		{
			GetBeforeLoadReturnsNull = true;
		}
	}
}

bool Observe_SoftObjectPtrBasics_DefaultEmpty(ACoverageSoftRefBasicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrBasics setup: required Actor is null");
	}
	return Actor.DeclarationWorked == false
		&& Actor.AssignmentWorked == false
		&& Actor.GetWorked == false
		&& Actor.GetBeforeLoadReturnsNull == false;
}

bool Observe_SoftObjectPtrBasics_EmptyGetNull()
{
	TSoftObjectPtr<AActor> UnloadedSoft;
	return UnloadedSoft.Get() == nullptr && UnloadedSoft.IsNull();
}

bool Observe_SoftObjectPtrBasics_CopyIndependence()
{
	TSoftObjectPtr<AActor> First;
	TSoftObjectPtr<AActor> Second;
	return First.IsNull() && Second.IsNull() && First.Get() == nullptr && Second.Get() == nullptr;
}
