/**
 * BlueprintEvent dispatch through TriggerEvent. BeginPlay calls TriggerEvent(21)
 * so EventCallCount is 1 and EventValue is 42. CalculateValue(0) is 0.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.BlueprintEventMetadataAndDispatch
 * @Harness UClass
 * @Tag Definitions.Meta.BlueprintEventMetadataAndDispatch
 * @Provenance Theme: Definitions.Meta. WorldStory: BlueprintEvent dispatch through TriggerEvent.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::BlueprintEventMetadataAndDispatch
 * @Provenance Oracle after BeginPlay TriggerEvent(21): EventCallCount == 1, EventValue == 42.
 * @Provenance Extra: CalculateValue(0) == 0; TriggerEvent(0) writes EventValue 0. FixtureIsolated.
 */

UCLASS()
class ACoveragesMacrosBlueprintEventActor : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int EventValue = 0;

	/**
	 * BlueprintEvent that records the call and stores Value.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs the event value
	 * @Return nothing; EventCallCount increments and EventValue is written
	 * @Param Value the stored event value
	 */
	UFUNCTION(BlueprintEvent, Category="Events")
	void OnCustomEvent(int Value)
	{
		EventCallCount++;
		EventValue = Value;
	}

	/**
	 * BlueprintEvent that doubles the input.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs an input
	 * @Return Input * 2
	 * @Param Input the value to double
	 */
	UFUNCTION(BlueprintEvent, Category="Events")
	int CalculateValue(int Input)
	{
		return Input * 2;
	}

	/**
	 * BlueprintEvent that records IntParam and VectorParam.X.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs an int, a string and a vector
	 * @Return nothing; EventCallCount gains IntParam and EventValue is VectorParam.X
	 * @Param IntParam added to EventCallCount
	 * @Param StringParam unused payload
	 * @Param VectorParam X is stored as EventValue
	 */
	UFUNCTION(BlueprintEvent, Category="Events")
	void OnComplexEvent(int IntParam, FString StringParam, FVector VectorParam)
	{
		EventCallCount += IntParam;
		EventValue = int(VectorParam.X);
	}

	/**
	 * Dispatch OnCustomEvent with CalculateValue of the supplied Value.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs the value to dispatch
	 * @Return nothing; OnCustomEvent(CalculateValue(Value)) runs
	 * @Param Value the value passed through CalculateValue
	 */
	UFUNCTION(BlueprintCallable, Category="Testing")
	void TriggerEvent(int Value)
	{
		OnCustomEvent(CalculateValue(Value));
	}

	/**
	 * WorldStory: BeginPlay dispatches TriggerEvent(21).
	 *
	 * @Kind WorldStory
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs none
	 * @Return EventCallCount 1 and EventValue 42 after play
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TriggerEvent(21);
	}

	/**
	 * Observe EventCallCount after play.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs none
	 * @Return EventCallCount
	 */
	UFUNCTION()
	int EventCallCountValue()
	{
		return EventCallCount;
	}

	/**
	 * Observe EventValue after play.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs none
	 * @Return EventValue
	 */
	UFUNCTION()
	int EventValueStored()
	{
		return EventValue;
	}

	/**
	 * Observe that CalculateValue(0) is 0.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero input
	 */
	UFUNCTION()
	int CalculateZeroBoundary()
	{
		return CalculateValue(0);
	}

	/**
	 * Observe that TriggerEvent(0) writes EventValue 0.
	 *
	 * @Kind Observe
	 * @Covers Meta.BlueprintEventMetadataAndDispatch
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero trigger
	 */
	UFUNCTION()
	int TriggerZero()
	{
		EventCallCount = 0;
		TriggerEvent(0);
		return EventValue;
	}
}
