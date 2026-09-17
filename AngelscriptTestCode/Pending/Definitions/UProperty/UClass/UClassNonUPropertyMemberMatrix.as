/**
 * @version v1
 * @summary Plain members are usable; UPROPERTY copies are the observable oracle. C++ verifies ReflectedCounter/Label/ArraySum/FunctionResult by path, so those names are kept. The observers cover empty RuntimeValues Num 0 and the.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Plain members are usable; UPROPERTY copies are the observable oracle. C++ verifies ReflectedCounter/Label/ArraySum/FunctionResult by path, so those names are kept. The observers cover empty RuntimeValues Num 0 and the.
 * @topic Baseline
 */
UCLASS()
class ACoverageUClassNonUPropertyMemberActor : AActor
{
	int RuntimeCounter = 7;
	FString RuntimeLabel = "Seed";
	TArray<int> RuntimeValues;

	UPROPERTY()
	int ReflectedCounter = 0;

	UPROPERTY()
	FString ReflectedLabel;

	UPROPERTY()
	int ReflectedArraySum = 0;

	UPROPERTY()
	int ReflectedFunctionResult = 0;

	/**
	 * WorldStory: copy runtime members into reflected UPROPERTY oracles.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.UClassNonUPropertyMemberMatrix
	 * @Inputs none
	 * @Return ReflectedCounter 42; ReflectedLabel Seed_Runtime; ReflectedArraySum 11
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeCounter += 35;
		RuntimeLabel += "_Runtime";
		RuntimeValues.Add(5);
		RuntimeValues.Add(6);
		ReflectedCounter = RuntimeCounter;
		ReflectedLabel = RuntimeLabel;
		ReflectedArraySum = RuntimeValues[0] + RuntimeValues[1];
		ReflectedFunctionResult = ReadRuntimeCounter();
	}

	/**
	 * Read the runtime counter through a UFUNCTION so C++ can observe it.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassNonUPropertyMemberMatrix
	 * @Inputs none
	 * @Return RuntimeCounter
	 */
	UFUNCTION()
	int ReadRuntimeCounter()
	{
		return RuntimeCounter;
	}

	/**
	 * Observe that an empty RuntimeValues array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassNonUPropertyMemberMatrix
	 * @Inputs a default-constructed TArray<int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int NonUPropertyEmptyRuntimeArrayNum()
	{
		TArray<int> RuntimeValues;
		return RuntimeValues.Num();
	}

	/**
	 * Observe the default RuntimeCounter before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassNonUPropertyMemberMatrix
	 * @Inputs a local RuntimeCounter 7
	 * @Return 7
	 * @Boundary empty default
	 */
	UFUNCTION()
	int NonUPropertyDefaultRuntimeCounter()
	{
		int RuntimeCounter = 7;
		return RuntimeCounter;
	}
}
/** @end */
