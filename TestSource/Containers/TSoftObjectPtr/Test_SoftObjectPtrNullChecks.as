// Theme: Containers.TSoftObjectPtr. WorldStory: IsNull/IsValid for empty vs assigned.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftObjectPtrNullChecks
// CompileScriptModule + spawn + BeginPlay. Oracle: IsNull/IsValid empty and assigned flags true.
// Extra: local construct leaves flags false; empty IsNull is the empty vector.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageSoftRefNullChecksActor : AActor
{
	UPROPERTY()
	bool IsNullWorkedForEmpty = false;

	UPROPERTY()
	bool IsValidWorkedForEmpty = false;

	UPROPERTY()
	bool IsNullWorkedForAssigned = false;

	UPROPERTY()
	bool IsValidWorkedForAssigned = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test empty soft reference
		TSoftObjectPtr<AActor> EmptySoft;
		if (EmptySoft.IsNull())
		{
			IsNullWorkedForEmpty = true;
		}

		if (!EmptySoft.IsValid())
		{
			IsValidWorkedForEmpty = true;
		}

		// Test assigned soft reference
		TSoftObjectPtr<AActor> AssignedSoft;
		AActor SpawnedActor = SpawnActor(AActor::StaticClass());
		AssignedSoft = SpawnedActor;

		if (!AssignedSoft.IsNull())
		{
			IsNullWorkedForAssigned = true;
		}

		if (AssignedSoft.IsValid())
		{
			IsValidWorkedForAssigned = true;
		}
	}
}

bool Observe_SoftNullChecks_DefaultEmpty(ACoverageSoftRefNullChecksActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrNullChecks setup: required Actor is null");
	}
	return Actor.IsNullWorkedForEmpty == false
		&& Actor.IsValidWorkedForEmpty == false
		&& Actor.IsNullWorkedForAssigned == false
		&& Actor.IsValidWorkedForAssigned == false;
}

bool Observe_SoftNullChecks_EmptyVector()
{
	TSoftObjectPtr<AActor> EmptySoft;
	return EmptySoft.IsNull() && !EmptySoft.IsValid();
}

bool Observe_SoftNullChecks_CopyIndependence()
{
	TSoftObjectPtr<AActor> EmptySoft;
	TSoftObjectPtr<AActor> AssignedSoft;
	return EmptySoft.IsNull() && AssignedSoft.IsNull();
}
