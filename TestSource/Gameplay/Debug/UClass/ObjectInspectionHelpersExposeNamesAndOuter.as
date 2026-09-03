/**
 * The object inspection helpers read the actor's name, class, full name and outer, and
 * record that inspection completed. C++ verifies the flag and the three name strings
 * by path, so the UPROPERTY names are part of the contract and are kept verbatim.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ObjectInspectionHelpersExposeNamesAndOuter
 * @Harness UClass
 * @Tag Gameplay.Debug.ObjectInspectionHelpersExposeNamesAndOuter
 * @Provenance Theme: Gameplay.Debug. WorldStory object inspection names and outer.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::ObjectInspectionHelpersExposeNamesAndOuter
 * @Provenance Oracle VerifyByPath bInspectionComplete true after BeginPlay; ObjectName non-empty;
 * @Provenance ClassName contains ObjectInspectionCoverageActor; FullObjectName contains both.
 * @Provenance Extra: defaults empty strings / false. FixtureIsolated. Keep UPROPERTY names.
 */

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

	/**
	 * WorldStory: BeginPlay reads every inspection helper onto UPROPERTYs and records
	 * whether the whole set resolved.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.ObjectInspectionHelpersExposeNamesAndOuter
	 * @Inputs none
	 * @Return bInspectionComplete true once all four names resolve
	 */
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

	/**
	 * Observe that a locally constructed actor has inspected nothing.
	 *
	 * @Kind Observe
	 * @Covers Debug.ObjectInspectionHelpersExposeNamesAndOuter
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four strings are empty and the flag is clear
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ObjectName.Len() != 0)
		{
			return false;
		}
		if (ClassName.Len() != 0)
		{
			return false;
		}
		if (FullObjectName.Len() != 0)
		{
			return false;
		}
		if (OuterName.Len() != 0)
		{
			return false;
		}
		return !bInspectionComplete;
	}
}
