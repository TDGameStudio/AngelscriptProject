/**
 * BlueprintEvent default implementations run from TestNativeEvents. After
 * BeginPlay, NativeEventResult is 15 and NativeEventString is "Test Test Test".
 * ProcessNativeEvent(0) is 0 and FormatNativeEvent("", 0) is empty.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.BlueprintEventDefaultImplementations
 * @Harness UClass
 * @Tag Definitions.Meta.BlueprintEventDefaultImplementations
 * @Provenance Theme: Definitions.Meta. WorldStory: BlueprintEvent default implementations run from TestNativeEvents.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::BlueprintEventDefaultImplementations
 * @Provenance Oracle after BeginPlay: NativeEventResult == 15; NativeEventString == "Test Test Test".
 * @Provenance Extra: ProcessNativeEvent(0) == 0; FormatNativeEvent("", 0) empty. FixtureIsolated.
 */

UCLASS()
class ACoverageMacrosBlueprintEventDefaultsActor : AActor
{
	UPROPERTY()
	int NativeEventResult = 0;

	UPROPERTY()
	FString NativeEventString;

	/**
	 * BlueprintEvent default that doubles the input.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs an input
	 * @Return Input * 2
	 * @Param Input the value to double
	 */
	UFUNCTION(BlueprintEvent, Category="Events")
	int ProcessNativeEvent(int Input)
	{
		return Input * 2;
	}

	/**
	 * BlueprintEvent default that repeats Input Count times, separated by spaces.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs a string and a repeat count
	 * @Return Input repeated Count times
	 * @Param Input the fragment to repeat
	 * @Param Count how many copies to join
	 */
	UFUNCTION(BlueprintEvent, Category="Events")
	FString FormatNativeEvent(const FString&in Input, int Count)
	{
		FString Result = Input;
		for (int i = 1; i < Count; i++)
		{
			Result = Result + " " + Input;
		}
		return Result;
	}

	/**
	 * BlueprintEvent default that stores Value times 3.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs a value
	 * @Return nothing; NativeEventResult is Value * 3
	 * @Param Value the value stored times 3
	 */
	UFUNCTION(BlueprintEvent, Category="Events")
	void ExecuteNativeEvent(int Value)
	{
		NativeEventResult = Value * 3;
	}

	/**
	 * Call the three native-event defaults in order.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs none
	 * @Return nothing; NativeEventResult and NativeEventString are written
	 */
	UFUNCTION(BlueprintCallable, Category="Testing")
	void TestNativeEvents()
	{
		int Result = ProcessNativeEvent(10);
		NativeEventResult = Result;

		NativeEventString = FormatNativeEvent("Test", 3);

		ExecuteNativeEvent(5);
	}

	/**
	 * WorldStory: BeginPlay runs TestNativeEvents.
	 *
	 * @Kind WorldStory
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs none
	 * @Return NativeEventResult 15 and NativeEventString "Test Test Test" after play
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestNativeEvents();
	}

	/**
	 * Observe NativeEventResult after play.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs none
	 * @Return NativeEventResult
	 */
	UFUNCTION()
	int NativeEventResultValue()
	{
		return NativeEventResult;
	}

	/**
	 * Observe NativeEventString after play.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs none
	 * @Return NativeEventString
	 */
	UFUNCTION()
	FString NativeEventStringValue()
	{
		return NativeEventString;
	}

	/**
	 * Observe that ProcessNativeEvent(0) is 0.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero input
	 */
	UFUNCTION()
	int ProcessZeroBoundary()
	{
		return ProcessNativeEvent(0);
	}

	/**
	 * Observe that FormatNativeEvent of an empty string with count 0 is empty.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventDefaultImplementations
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty input and zero count
	 */
	UFUNCTION()
	int FormatEmptyCount()
	{
		FString Empty;
		return FormatNativeEvent(Empty, 0).Len();
	}
}
