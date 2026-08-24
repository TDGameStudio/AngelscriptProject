// Theme: Definitions.Meta. WorldStory: BlueprintEvent default implementations run from TestNativeEvents.
// C++: AngelscriptCoverageMacrosTests.cpp::BlueprintEventDefaultImplementations
// Oracle after BeginPlay: NativeEventResult == 15; NativeEventString == "Test Test Test".
// Extra: ProcessNativeEvent(0) == 0; FormatNativeEvent("", 0) empty. FixtureIsolated.

UCLASS()
class ACoverageMacrosBlueprintEventDefaultsActor : AActor
{
	UPROPERTY()
	int NativeEventResult = 0;

	UPROPERTY()
	FString NativeEventString;

	// BlueprintEvent with default implementation
	UFUNCTION(BlueprintEvent, Category="Events")
	int ProcessNativeEvent(int Input)
	{
		// Default implementation - can be overridden in Blueprint
		return Input * 2;
	}

	// BlueprintEvent with string processing
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

	// BlueprintEvent with void return
	UFUNCTION(BlueprintEvent, Category="Events")
	void ExecuteNativeEvent(int Value)
	{
		NativeEventResult = Value * 3;
	}

	// Function that calls native events
	UFUNCTION(BlueprintCallable, Category="Testing")
	void TestNativeEvents()
	{
		// Call native event with default implementation
		int Result = ProcessNativeEvent(10);
		NativeEventResult = Result;

		// Call string native event
		NativeEventString = FormatNativeEvent("Test", 3);

		// Call void native event
		ExecuteNativeEvent(5);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestNativeEvents();
	}
}

int Observe_BlueprintEventDefaults_NativeEventResult(ACoverageMacrosBlueprintEventDefaultsActor Actor)
{
	return Actor.NativeEventResult;
}

FString Observe_BlueprintEventDefaults_NativeEventString(ACoverageMacrosBlueprintEventDefaultsActor Actor)
{
	return Actor.NativeEventString;
}

int Observe_BlueprintEventDefaults_ProcessZeroBoundary(ACoverageMacrosBlueprintEventDefaultsActor Actor)
{
	return Actor.ProcessNativeEvent(0);
}

int Observe_BlueprintEventDefaults_FormatEmptyCount(ACoverageMacrosBlueprintEventDefaultsActor Actor)
{
	FString Empty;
	return Actor.FormatNativeEvent(Empty, 0).Len();
}
