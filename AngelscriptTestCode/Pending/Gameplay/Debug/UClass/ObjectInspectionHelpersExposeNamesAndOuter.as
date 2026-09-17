/**
 * @version v1
 * @summary The object inspection helpers read the actor's name, class, full name and outer, and record that inspection completed. C++ verifies the flag and the three name strings by path, so the UPROPERTY names are part of the.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The object inspection helpers read the actor's name, class, full name and outer, and record that inspection completed. C++ verifies the flag and the three name strings by path, so the UPROPERTY names are part of the.
 * @topic Baseline
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
/** @end */
