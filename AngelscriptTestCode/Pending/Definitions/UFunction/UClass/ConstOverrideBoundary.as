/**
 * @version v1
 * @summary A non-const AngelScript BlueprintOverride of a const BlueprintEvent is accepted as a fork boundary. The child keeps FUNC_Const. Base ReadConstEvent(5) is 5; child (5) is 6. ReadConstEvent(0) is 0 on the base and 1 on the.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A non-const AngelScript BlueprintOverride of a const BlueprintEvent is accepted as a fork boundary. The child keeps FUNC_Const. Base ReadConstEvent(5) is 5; child (5) is 6. ReadConstEvent(0) is 0 on the base and 1 on the.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionConstBoundaryBaseActor : AActor
{
	/**
	 * Const BlueprintPure event that returns Value unchanged.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Value returned unchanged
	 * @Inputs Value
	 * @Return Value
	 */
	UFUNCTION(BlueprintPure, BlueprintEvent)
	int ReadConstEvent(int Value) const
	{
		return Value;
	}

	/**
	 * Observe the base event with Value 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ReadConstEvent(5)
	 * @Return 5
	 */
	UFUNCTION()
	int BaseFive()
	{
		return ReadConstEvent(5);
	}

	/**
	 * Observe the base event at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ReadConstEvent(0)
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int BaseZero()
	{
		return ReadConstEvent(0);
	}
}

UCLASS()
class ACoverageUFunctionConstBoundaryChildActor : ACoverageUFunctionConstBoundaryBaseActor
{
	/**
	 * Non-const BlueprintOverride that returns Value + 1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Value incremented by one
	 * @Inputs Value
	 * @Return Value + 1
	 */
	UFUNCTION(BlueprintOverride)
	int ReadConstEvent(int Value)
	{
		return Value + 1;
	}

	/**
	 * Observe the child override with Value 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ReadConstEvent(5)
	 * @Return 6
	 */
	UFUNCTION()
	int ChildFive()
	{
		return ReadConstEvent(5);
	}

	/**
	 * Observe the child override at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ReadConstEvent(0)
	 * @Return 1
	 * @Boundary zero
	 */
	UFUNCTION()
	int ChildZero()
	{
		return ReadConstEvent(0);
	}
}
/** @end */
