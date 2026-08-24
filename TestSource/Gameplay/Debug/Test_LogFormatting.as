// Theme: Gameplay.Debug. WorldStory Print formatting (int/float/bool/vector/rotator/color).
// C++: AngelscriptCoverageLoggingTests.cpp::LogFormatting
// Oracle: ALogFormattingTestActor compiles and spawns; BeginPlay concatenates values.
// Extra: Level 0 / HasKey false / empty Message. FixtureIsolated.

UCLASS()
class ALogFormattingTestActor : AActor
{
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
}

bool Observe_LogFormatting_EmptyDefault()
{
	FString Message = "";
	int Level = 0;
	bool HasKey = false;
	Print(Message);
	Print("Player level: " + Level);
	Print("Has key: " + HasKey);
	return Message.Len() == 0 && Level == 0 && HasKey == false;
}
