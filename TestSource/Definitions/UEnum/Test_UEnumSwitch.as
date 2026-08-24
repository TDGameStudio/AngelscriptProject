// Theme: Definitions.UEnum. WorldStory switch on UENUM with default case.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumSwitch
// Oracle after BeginPlay: RedCount=1, GreenCount=1, BlueCount=2, DefaultCount=1 (Yellow).
// Extra: counters start at 0; nullptr actor is the empty handle; Yellow is the default-case boundary.
// FixtureIsolated. Keep RedCount/GreenCount/BlueCount/DefaultCount names.

UENUM()
enum EColorEnum
{
	Red,
	Green,
	Blue,
	Yellow
}

UCLASS()
class ACoverageUEnumSwitchActor : AActor
{
	UPROPERTY()
	int RedCount = 0;

	UPROPERTY()
	int GreenCount = 0;

	UPROPERTY()
	int BlueCount = 0;

	UPROPERTY()
	int DefaultCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ProcessColor(EColorEnum::Red);
		ProcessColor(EColorEnum::Green);
		ProcessColor(EColorEnum::Blue);
		ProcessColor(EColorEnum::Blue);
		ProcessColor(EColorEnum::Yellow);
	}

	void ProcessColor(EColorEnum Color)
	{
		switch (Color)
		{
			case EColorEnum::Red:
				RedCount++;
				break;
			case EColorEnum::Green:
				GreenCount++;
				break;
			case EColorEnum::Blue:
				BlueCount++;
				break;
			default:
				DefaultCount++;
				break;
		}
	}
}

bool Observe_Switch_DefaultsBeforePlay(ACoverageUEnumSwitchActor Actor)
{
	return Actor.RedCount == 0 && Actor.GreenCount == 0 && Actor.BlueCount == 0 && Actor.DefaultCount == 0;
}

bool Observe_Switch_BeginPlayOracle(ACoverageUEnumSwitchActor Actor)
{
	Actor.BeginPlay();
	return Actor.RedCount == 1 && Actor.GreenCount == 1 && Actor.BlueCount == 2 && Actor.DefaultCount == 1;
}

bool Observe_Switch_NullDefault()
{
	ACoverageUEnumSwitchActor Actor = nullptr;
	return Actor == nullptr;
}

int Observe_Switch_YellowBoundaryAlone()
{
	int IsolatedDefault = 0;
	switch (EColorEnum::Yellow)
	{
		case EColorEnum::Red:
			IsolatedDefault = -1;
			break;
		case EColorEnum::Green:
			IsolatedDefault = -2;
			break;
		case EColorEnum::Blue:
			IsolatedDefault = -3;
			break;
		default:
			IsolatedDefault = 1;
			break;
	}
	return IsolatedDefault;
}
