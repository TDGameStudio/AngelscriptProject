// Theme: Gameplay.Debug. WorldStory object inspection names and outer.
// C++: AngelscriptCoverageDebugTests.cpp::ObjectInspectionHelpersExposeNamesAndOuter
// Oracle VerifyByPath bInspectionComplete true after BeginPlay; ObjectName non-empty;
// ClassName contains ObjectInspectionCoverageActor; FullObjectName contains both.
// Extra: defaults empty strings / false. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class AObjectInspectionCoverageActor : AActor
{
	UPROPERTY()
	FString ObjectName = "";

	UPROPERTY()
	FString ClassName = "";

	UPROPERTY()
	FString FullObjectName = "";

	UPROPERTY()
	FString OuterName = "";

	UPROPERTY()
	bool bInspectionComplete = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ObjectName = GetName().ToString();
		ClassName = GetClass().GetName().ToString();
		FullObjectName = GetFullName();

		UObject Outer = GetOuter();
		if (Outer != nullptr)
		{
			OuterName = Outer.GetName().ToString();
		}

		bInspectionComplete = ObjectName.Len() > 0
			&& ClassName.Contains("ObjectInspectionCoverageActor")
			&& FullObjectName.Contains(ObjectName)
			&& OuterName.Len() > 0;
	}
}

bool Observe_ObjectInspection_DefaultEmpty(AObjectInspectionCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ObjectInspectionHelpersExposeNamesAndOuter setup: required Actor is null");
	}
	return Actor.ObjectName.Len() == 0
		&& Actor.ClassName.Len() == 0
		&& Actor.FullObjectName.Len() == 0
		&& Actor.OuterName.Len() == 0
		&& Actor.bInspectionComplete == false;
}
