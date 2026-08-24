// Theme: Gameplay.Debug. WorldStory Print/PrintWarning/PrintError surface.
// C++: AngelscriptCoverageLoggingTests.cpp::PrintFunctions
// Oracle: APrintTestActor compiles, spawns, and BeginPlay executes the Print family.
// Extra: Print of empty string and Value 0. FixtureIsolated.

UCLASS()
class APrintTestActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("Basic print message");

		int Value = 42;
		Print("Value is: " + Value);

		Print("Colored message on screen", 5.0f, FLinearColor::Red);

		PrintFromObject(this, "Print from object context", 0.01f, FLinearColor::Green);
		PrintToScreen("Print to screen only", 0.01f, FLinearColor::Yellow);
		PrintDirectToScreen("Print direct to screen", 0.01f, FLinearColor::Blue);

		PrintWarning("This is a warning message");

		PrintError("This is an error message");

		FString Name = "Test";
		Print("Actor name: " + Name);

		float Health = 100.5f;
		Print("Health: " + Health);

		bool IsActive = true;
		Print("Is active: " + IsActive);
	}
}

bool Observe_PrintValue_EmptyZero()
{
	int Value = 0;
	Print("Value is: " + Value);
	return Value == 0;
}

bool Observe_Print_EmptyString()
{
	FString Empty = "";
	Print(Empty);
	return Empty.Len() == 0;
}
