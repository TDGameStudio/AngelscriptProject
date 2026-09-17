/**
 * @version v1
 * @summary Print, PrintWarning and PrintError stand in for UE_LOG. BeginPlay emits the formatted Print line with Count 10, PlayerName Hero, Score 1500.75 and Winner true.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Print, PrintWarning and PrintError stand in for UE_LOG. BeginPlay emits the formatted Print line with Count 10, PlayerName Hero, Score 1500.75 and Winner true.
 * @topic Baseline
 */
UCLASS()
class AUELogTestActor : AActor
{
	/**
	 * WorldStory: BeginPlay walks Print, PrintWarning, PrintError and formatted values.
	 *
	 * @Kind WorldStory
	 * @Covers Meta.UELogMacros
	 * @Inputs none
	 * @Return every print call made without error
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("Regular log message");

		PrintWarning("Warning level message");

		PrintError("Error level message");

		int Count = 10;
		Print("Item count: " + Count);

		FString PlayerName = "Hero";
		float Score = 1500.75f;
		bool IsWinner = true;
		Print("Player: " + PlayerName + ", Score: " + Score + ", Winner: " + IsWinner);
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.UELogMacros
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		AUELogTestActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe the formatted count string at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Meta.UELogMacros
	 * @Inputs none
	 * @Return "Item count: 0"
	 * @Boundary zero count
	 */
	UFUNCTION()
	FString FormattedCountBoundary()
	{
		int Count = 0;
		return "Item count: " + Count;
	}
}
/** @end */
