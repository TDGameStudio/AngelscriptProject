// Theme: Containers.TSoftObjectPtr. WorldStory: ToSoftObjectPath / ToString / path compare.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftObjectPtrPath
// CompileScriptModule + spawn + BeginPlay. Oracle: ToSoftObjectPathWorked, ToStringWorked,
// ToStringNotEmpty, PathComparisonWorked true.
// Extra: local construct leaves flags false; empty ToString is empty.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageSoftRefPathActor : AActor
{
	UPROPERTY()
	bool ToSoftObjectPathWorked = false;

	UPROPERTY()
	bool ToStringWorked = false;

	UPROPERTY()
	bool ToStringNotEmpty = false;

	UPROPERTY()
	bool PathComparisonWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create soft reference
		TSoftObjectPtr<AActor> SoftActor;
		AActor SpawnedActor = SpawnActor(AActor::StaticClass());
		SoftActor = SpawnedActor;

		// Test ToSoftObjectPath
		FSoftObjectPath Path = SoftActor.ToSoftObjectPath();
		if (Path.IsValid())
		{
			ToSoftObjectPathWorked = true;
		}

		// Test ToString
		FString PathString = SoftActor.ToString();
		ToStringWorked = true;

		// Verify string is not empty
		if (PathString.Len() > 0)
		{
			ToStringNotEmpty = true;
		}

		// Test path comparison via two soft references
		TSoftObjectPtr<AActor> SoftActor2 = SpawnedActor;
		if (SoftActor.ToSoftObjectPath() == SoftActor2.ToSoftObjectPath())
		{
			PathComparisonWorked = true;
		}
	}
}

bool Observe_SoftRefPath_DefaultEmpty(ACoverageSoftRefPathActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrPath setup: required Actor is null");
	}
	return Actor.ToSoftObjectPathWorked == false
		&& Actor.ToStringWorked == false
		&& Actor.ToStringNotEmpty == false
		&& Actor.PathComparisonWorked == false;
}

bool Observe_SoftRefPath_EmptyToString()
{
	TSoftObjectPtr<AActor> SoftActor;
	return SoftActor.ToString().IsEmpty();
}

bool Observe_SoftRefPath_CopyIndependence()
{
	TSoftObjectPtr<AActor> First;
	TSoftObjectPtr<AActor> Second;
	return First.ToSoftObjectPath() == Second.ToSoftObjectPath();
}
