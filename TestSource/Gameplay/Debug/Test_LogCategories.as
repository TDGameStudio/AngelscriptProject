// Theme: Gameplay.Debug. WorldStory prefixed Print categories.
// C++: AngelscriptCoverageLoggingTests.cpp::LogCategories
// Oracle: ALogCategoryTestActor compiles and spawns; BeginPlay prints prefixed lines.
// Extra: empty Category prefix. FixtureIsolated.

UCLASS()
class ALogCategoryTestActor : AActor
{
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
}

bool Observe_LogCategory_EmptyDefault()
{
	FString Category = "";
	Print("[" + Category + "] Custom category message");
	return Category.Len() == 0;
}
