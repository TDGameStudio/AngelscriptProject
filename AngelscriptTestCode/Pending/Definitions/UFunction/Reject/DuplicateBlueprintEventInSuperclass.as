/**
 * @version v1
 * @summary A BlueprintEvent already specified in an AngelScript superclass cannot be redeclared on the child. ComputeParentEvent is final on the parent. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A BlueprintEvent already specified in an AngelScript superclass cannot be redeclared on the child. ComputeParentEvent is final on the parent. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionParentEventBaseActor : AActor
{
	/**
	 * Parent BlueprintEvent that the child illegally redeclares.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return Value + 1
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeParentEvent(int Value)
	{
		return Value + 1;
	}
}

UCLASS()
class ACoverageUFunctionParentEventChildActor : ACoverageUFunctionParentEventBaseActor
{
	/**
	 * Illegal child BlueprintEvent that redeclares the parent event.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeParentEvent(int Value)
	{
		return Value + 2;
	}
}
/** @end */
