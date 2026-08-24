// Theme: Definitions.Meta. WorldStory: Print / PrintWarning / PrintError stand in for UE_LOG.
// C++: AngelscriptCoverageLoggingTests.cpp::UELogMacros compiles and spawns AUELogTestActor.
// Oracle: BeginPlay emits the formatted Print line with Count 10, PlayerName Hero, Score 1500.75, Winner true.
// Extra: default handle is null. FixtureIsolated.

// Actor that tests UE_LOG macro equivalents (if available in AS)
UCLASS()
class AUELogTestActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Note: AngelScript may not support UE_LOG directly
		// This tests if the API is exposed or has AS equivalents

		// Regular log message
		Print("Regular log message");

		// Warning level
		PrintWarning("Warning level message");

		// Error level
		PrintError("Error level message");

		// Log with formatting
		int Count = 10;
		Print("Item count: " + Count);

		// Multiple variable types
		FString PlayerName = "Hero";
		float Score = 1500.75f;
		bool IsWinner = true;
		Print("Player: " + PlayerName + ", Score: " + Score + ", Winner: " + IsWinner);
	}
}

int Observe_UELog_EmptyDefaultIsNull()
{
	AUELogTestActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

FString Observe_UELog_FormattedCountBoundary()
{
	int Count = 0;
	return "Item count: " + Count;
}
