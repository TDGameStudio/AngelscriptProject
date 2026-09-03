/**
 * BlueprintEvent defaults and a mutable ref. EventWithDefaults() is 23 and
 * LastLabel DefaultLabel. EventWithMutableRef(20) writes 25 and returns 26.
 * DispatchDefaultEvents is 74. EventWithDefaults(0,"") is 0. Default
 * EventCallCount is 0 and LastMutable is 0.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintEventDefaultArgumentsAndRefParameterMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.BlueprintEventDefaultArgumentsAndRefParameterMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintEvent defaults and mutable ref.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintEventDefaultArgumentsAndRefParameterMatrix
 * @Provenance Oracle: EventWithDefaults() == 23 LastLabel DefaultLabel; EventWithMutableRef(20) writes 25
 * @Provenance returns 26; DispatchDefaultEvents == 74; EventCallCount 4 after defaults+mutable+dispatch.
 * @Provenance Extra: EventWithDefaults(0,"") == 0; default EventCallCount 0 LastMutable 0.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionEventDefaultRefActor : AActor
{
	UPROPERTY()
	int LastMutable = 0;

	UPROPERTY()
	FString LastLabel;

	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * BlueprintEvent with default Value 11 and Label DefaultLabel.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Optional value, default 11
	 * @Param Label Optional label received as const FString&in, default DefaultLabel
	 * @Inputs Value and Label
	 * @Return Value + Label.Len() after writing LastLabel
	 */
	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventDefaults", meta=(AutoCreateRefTerm="Label"))
	int EventWithDefaults(int Value = 11, const FString&in Label = "DefaultLabel")
	{
		EventCallCount += 1;
		LastLabel = Label;
		return Value + Label.Len();
	}

	/**
	 * BlueprintEvent that mutates an inout integer by Bonus, default 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param MutableValue Integer received as int&inout
	 * @Param Bonus Optional addend, default 5
	 * @Inputs MutableValue and Bonus
	 * @Return MutableValue + 1 after writing LastMutable
	 */
	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventDefaults", meta=(DisplayName="Mutable Ref Event"))
	int EventWithMutableRef(int&inout MutableValue, int Bonus = 5)
	{
		EventCallCount += 1;
		MutableValue += Bonus;
		LastMutable = MutableValue;
		return MutableValue + 1;
	}

	/**
	 * Dispatch EventWithDefaults() then EventWithMutableRef(20).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs EventWithDefaults() then EventWithMutableRef(20)
	 * @Return the summed score plus the mutated value
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|EventDefaults")
	int DispatchDefaultEvents()
	{
		int Score = EventWithDefaults();
		int Mutable = 20;
		Score += EventWithMutableRef(Mutable);
		return Score + Mutable;
	}

	/**
	 * Observe EventWithDefaults with omitted arguments.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs EventWithDefaults()
	 * @Return 23
	 * @Boundary omitted defaults
	 */
	UFUNCTION()
	int OmittedArgs()
	{
		return EventWithDefaults();
	}

	/**
	 * Observe EventWithMutableRef of 20 writing 25 and returning 26.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs EventWithMutableRef(20)
	 * @Return 26, or -1 if Mutable or LastMutable is not 25
	 */
	UFUNCTION()
	int MutableRefTwenty()
	{
		int Mutable = 20;
		int Result = EventWithMutableRef(Mutable);
		if (Mutable != 25 || LastMutable != 25)
		{
			return -1;
		}
		return Result;
	}

	/**
	 * Observe DispatchDefaultEvents.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs DispatchDefaultEvents()
	 * @Return 74
	 */
	UFUNCTION()
	int DispatchScore()
	{
		return DispatchDefaultEvents();
	}

	/**
	 * Observe EventCallCount, LastMutable, and LastLabel after dispatch.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs DispatchDefaultEvents()
	 * @Return true when EventCallCount is 2, LastMutable is 25, and LastLabel is DefaultLabel
	 */
	UFUNCTION()
	bool DispatchState()
	{
		DispatchDefaultEvents();
		if (EventCallCount != 2)
		{
			return false;
		}
		if (LastMutable != 25)
		{
			return false;
		}
		return LastLabel == "DefaultLabel";
	}

	/**
	 * Observe EventWithDefaults(0, "").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs EventWithDefaults(0, "")
	 * @Return 0
	 * @Boundary zero and empty label
	 */
	UFUNCTION()
	int EmptyZeroBoundary()
	{
		return EventWithDefaults(0, "");
	}

	/**
	 * Observe the default EventCallCount of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default count
	 */
	UFUNCTION()
	int DefaultCallCount()
	{
		return EventCallCount;
	}
}
