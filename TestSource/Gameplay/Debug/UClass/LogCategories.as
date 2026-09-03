/**
 * Bracketed category prefixes applied to printed lines. C++ verifies the actor
 * compiles, spawns and prints. The observer covers the empty prefix.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.LogCategories
 * @Harness UClass
 * @Tag Gameplay.Debug.LogCategories
 * @Provenance Theme: Gameplay.Debug. WorldStory prefixed Print categories.
 * @Provenance C++: AngelscriptCoverageLoggingTests.cpp::LogCategories
 * @Provenance Oracle: ALogCategoryTestActor compiles and spawns; BeginPlay prints prefixed lines.
 * @Provenance Extra: empty Category prefix. FixtureIsolated.
 */

UCLASS()
class ALogCategoryTestActor : AActor
{
	/**
	 * WorldStory: BeginPlay prints both hardcoded and assembled category prefixes.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.LogCategories
	 * @Inputs none
	 * @Return each prefixed line printed
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("Temporary log message");

		Print("[Script] BeginPlay called");
		Print("[Actor] Initialization complete");
		Print("[Network] Connection established");

		FString Category = "GameLogic";
		Print("[" + Category + "] Custom category message");
	}

	/**
	 * Observe that printing an empty category prefix leaves it empty.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogCategories
	 * @Inputs an empty category string
	 * @Return true when the string is still empty
	 * @Boundary empty prefix
	 */
	UFUNCTION()
	bool EmptyDefault()
	{
		FString Category = "";
		Print("[" + Category + "] Custom category message");
		return Category.Len() == 0;
	}
}
