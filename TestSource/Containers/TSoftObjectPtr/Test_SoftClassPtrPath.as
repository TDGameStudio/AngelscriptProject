// Theme: Containers.TSoftObjectPtr. WorldStory: TSoftClassPtr ToString / ToSoftObjectPath.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftClassPtrPath
// CompileScriptModule + spawn + BeginPlay. Oracle: ToStringWorked, ToStringNotEmpty,
// ToSoftObjectPathWorked true.
// Extra: local construct leaves flags false; empty ToString is empty.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageSoftClassPathActor : AActor
{
	UPROPERTY()
	bool ToStringWorked = false;

	UPROPERTY()
	bool ToStringNotEmpty = false;

	UPROPERTY()
	bool ToSoftObjectPathWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create soft class reference
		TSoftClassPtr<AActor> SoftClass = AActor::StaticClass();

		// Test ToString
		FString PathString = SoftClass.ToString();
		ToStringWorked = true;

		// Verify string is not empty
		if (PathString.Len() > 0)
		{
			ToStringNotEmpty = true;
		}

		// Test ToSoftObjectPath
		FSoftObjectPath Path = SoftClass.ToSoftObjectPath();
		if (Path.IsValid())
		{
			ToSoftObjectPathWorked = true;
		}
	}
}

bool Observe_SoftClassPath_DefaultEmpty(ACoverageSoftClassPathActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftClassPtrPath setup: required Actor is null");
	}
	return Actor.ToStringWorked == false
		&& Actor.ToStringNotEmpty == false
		&& Actor.ToSoftObjectPathWorked == false;
}

bool Observe_SoftClassPath_EmptyToString()
{
	TSoftClassPtr<AActor> SoftClass;
	return SoftClass.ToString().IsEmpty();
}

bool Observe_SoftClassPath_CopyIndependence()
{
	TSoftClassPtr<AActor> First = AActor::StaticClass();
	TSoftClassPtr<AActor> Second;
	return First.ToString().Len() > 0 && Second.ToString().IsEmpty();
}
