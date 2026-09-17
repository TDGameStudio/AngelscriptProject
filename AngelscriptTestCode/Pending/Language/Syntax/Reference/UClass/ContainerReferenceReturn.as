/**
 * @version v1
 * @summary A member TArray returned by reference. Writing through the returned reference must reach the member itself, which BeginPlay verifies by adding through the reference and then reading the member's size and first element.
 * @topic Language
 */
/**
 * @version root
 * @summary A member TArray returned by reference. Writing through the returned reference must reach the member itself, which BeginPlay verifies by adding through the reference and then reading the member's size and first element.
 * @topic Baseline
 */
UCLASS()
class ACoverageContainerReferenceReturnActor : AActor
{
	UPROPERTY()
	TArray<int> Values;

	UPROPERTY()
	int RefSize = 0;

	UPROPERTY()
	int FirstValue = 0;

	/**
	 * Returns the member array by reference so callers can mutate it.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs the member TArray Values
	 * @Return a mutable reference to Values
	 */
	TArray<int>& GetValuesRef()
	{
		return Values;
	}

	/**
	 * Populates the array, then adds once more through the returned reference.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs none
	 * @Return nothing; RefSize and FirstValue record the result
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Values.Add(10);
		Values.Add(20);

		TArray<int>& Ref = GetValuesRef();
		Ref.Add(30);

		RefSize = Values.Num();
		FirstValue = Ref[0];
	}

	/**
	 * Observe the state of a locally constructed actor before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs a locally constructed actor
	 * @Return true when the array is empty and both counters are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool ContainerReferenceDefaultsToEmpty()
	{
		if (RefSize != 0)
		{
			return false;
		}

		if (FirstValue != 0)
		{
			return false;
		}

		return Values.Num() == 0;
	}
}
/** @end */
