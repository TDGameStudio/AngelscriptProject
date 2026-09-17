/**
 * @version v1
 * @summary A switch on a UENUM that counts Red, Green, and Blue, with Yellow falling through to default. C++ reads RedCount, GreenCount, BlueCount, and DefaultCount by path after BeginPlay, so those names are kept.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A switch on a UENUM that counts Red, Green, and Blue, with Yellow falling through to default. C++ reads RedCount, GreenCount, BlueCount, and DefaultCount by path after BeginPlay, so those names are kept.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: process Red, Green, Blue twice, and Yellow so the default case
	 * records Yellow.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumSwitch
	 * @Inputs none
	 * @Return RedCount 1, GreenCount 1, BlueCount 2, DefaultCount 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ProcessColor(EColorEnum::Red);
		ProcessColor(EColorEnum::Green);
		ProcessColor(EColorEnum::Blue);
		ProcessColor(EColorEnum::Blue);
		ProcessColor(EColorEnum::Yellow);
	}

	/**
	 * Count one enumerator through a switch, sending unmatched colors to default.
	 *
	 * @Kind Action
	 * @Covers UEnum.UEnumSwitch
	 * @Inputs the color to count
	 * @Return nothing; the matching counter grows by one
	 * @Param Color the enumerator to switch on
	 */
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

	/**
	 * Observe that all four counters start at 0 before play.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumSwitch
	 * @Inputs a locally constructed actor
	 * @Return true when every counter is 0
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultsBeforePlay()
	{
		if (RedCount != 0)
		{
			return false;
		}
		if (GreenCount != 0)
		{
			return false;
		}
		if (BlueCount != 0)
		{
			return false;
		}
		return DefaultCount == 0;
	}

	/**
	 * Observe the BeginPlay oracle for the four color counters.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumSwitch
	 * @Inputs this actor after BeginPlay
	 * @Return true when Red=1, Green=1, Blue=2, Default=1
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (RedCount != 1)
		{
			return false;
		}
		if (GreenCount != 1)
		{
			return false;
		}
		if (BlueCount != 2)
		{
			return false;
		}
		return DefaultCount == 1;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumSwitch
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumSwitchActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that Yellow alone selects the default case.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumSwitch
	 * @Inputs Yellow
	 * @Return 1 when Yellow falls through to default
	 * @Boundary Yellow default case
	 */
	UFUNCTION()
	int YellowBoundaryAlone()
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
}
/** @end */
