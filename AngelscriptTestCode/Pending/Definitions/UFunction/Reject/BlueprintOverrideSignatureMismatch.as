/**
 * @version v1
 * @summary A BlueprintOverride must match the parent event signature. The child ComputeValue takes FString while the parent event takes int. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A BlueprintOverride must match the parent event signature. The child ComputeValue takes FString while the parent event takes int. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionMismatchBaseActor : AActor
{
	/**
	 * Parent BlueprintEvent with an int parameter.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return Value + 1
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeValue(int Value)
	{
		return Value + 1;
	}
}

UCLASS()
class ACoverageUFunctionMismatchChildActor : ACoverageUFunctionMismatchBaseActor
{
	/**
	 * Illegal BlueprintOverride whose parameter type does not match the parent event.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs FString Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	int ComputeValue(FString Value)
	{
		return Value.Len();
	}
}
/** @end */
