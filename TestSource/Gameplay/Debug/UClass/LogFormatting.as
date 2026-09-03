/**
 * Print formatting across ints, floats, bools, vectors, rotators and colours, plus
 * names pulled off the actor itself. C++ verifies the actor compiles, spawns and
 * prints. The observer covers the empty message, the zero level and the clear flag.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.LogFormatting
 * @Harness UClass
 * @Tag Gameplay.Debug.LogFormatting
 * @Provenance Theme: Gameplay.Debug. WorldStory Print formatting (int/float/bool/vector/rotator/color).
 * @Provenance C++: AngelscriptCoverageLoggingTests.cpp::LogFormatting
 * @Provenance Oracle: ALogFormattingTestActor compiles and spawns; BeginPlay concatenates values.
 * @Provenance Extra: Level 0 / HasKey false / empty Message. FixtureIsolated.
 */

UCLASS()
class ALogFormattingTestActor : AActor
{
	/**
	 * WorldStory: BeginPlay concatenates values of every formatted type and prints a
	 * status block.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.LogFormatting
	 * @Inputs none
	 * @Return every formatted line printed
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FString Message = "Hello" + " " + "World";
		Print(Message);

		int Level = 5;
		Print("Player level: " + Level);

		float Distance = 123.456f;
		Print("Distance: " + Distance + " units");

		bool HasKey = false;
		Print("Has key: " + HasKey);

		FVector Location = FVector(100.0f, 200.0f, 300.0f);
		Print("Location: " + Location.ToString());

		FRotator Rotation = FRotator(45.0f, 90.0f, 0.0f);
		Print("Rotation: " + Rotation.ToString());

		FLinearColor Color = FLinearColor::Red;
		Print("Color: " + Color.ToString());

		Print("Actor name: " + GetName());
		Print("Class name: " + GetClass().GetName());

		Print("=== Actor Status ===");
		Print("Name: " + GetName());
		Print("Location: " + GetActorLocation().ToString());
		Print("Rotation: " + GetActorRotation().ToString());
		Print("==================");
	}

	/**
	 * Observe that printing the empty and zero values leaves them untouched.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogFormatting
	 * @Inputs an empty message, a zero level and a clear flag
	 * @Return true when the message is empty, the level is 0 and the flag is clear
	 * @Boundary empty values
	 */
	UFUNCTION()
	bool EmptyDefault()
	{
		FString Message = "";
		int Level = 0;
		bool HasKey = false;
		Print(Message);
		Print("Player level: " + Level);
		Print("Has key: " + HasKey);

		if (Message.Len() != 0)
		{
			return false;
		}
		if (Level != 0)
		{
			return false;
		}
		return !HasKey;
	}
}
