/**
 * The Print family exercised from a spawned actor's BeginPlay, covering plain prints,
 * coloured on-screen prints, the object-context variant and the warning and error
 * channels. C++ verifies the actor compiles, spawns and runs. The observers cover the
 * empty-value vectors.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.PrintFunctions
 * @Harness UClass
 * @Tag Gameplay.Debug.PrintFunctions
 * @Provenance Theme: Gameplay.Debug. WorldStory Print/PrintWarning/PrintError surface.
 * @Provenance C++: AngelscriptCoverageLoggingTests.cpp::PrintFunctions
 * @Provenance Oracle: APrintTestActor compiles, spawns, and BeginPlay executes the Print family.
 * @Provenance Extra: Print of empty string and Value 0. FixtureIsolated.
 */

UCLASS()
class APrintTestActor : AActor
{
	/**
	 * WorldStory: BeginPlay walks the whole Print family so each channel is exercised
	 * at least once.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.PrintFunctions
	 * @Inputs none
	 * @Return every print call made without error
	 */
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

	/**
	 * Observe that printing a zero value leaves the value untouched.
	 *
	 * @Kind Observe
	 * @Covers Debug.PrintFunctions
	 * @Inputs a zero integer
	 * @Return true when the value is still 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool PrintValueEmptyZero()
	{
		int Value = 0;
		Print("Value is: " + Value);
		return Value == 0;
	}

	/**
	 * Observe that printing an empty string leaves it empty.
	 *
	 * @Kind Observe
	 * @Covers Debug.PrintFunctions
	 * @Inputs an empty string
	 * @Return true when the string is still empty
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool PrintEmptyString()
	{
		FString Empty = "";
		Print(Empty);
		return Empty.Len() == 0;
	}
}
