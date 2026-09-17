/**
 * @version v1
 * @summary A child BlueprintCallable may not change the parent signature. ComputeValue takes int on the base and FString on the child. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A child BlueprintCallable may not change the parent signature. ComputeValue takes int on the base and FString on the child. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionCallableMismatchBaseActor : AActor
{
	/**
	 * Parent BlueprintCallable with an int parameter.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return Value
	 */
	UFUNCTION(BlueprintCallable)
	int ComputeValue(int Value)
	{
		return Value;
	}
}

UCLASS()
class ACoverageUFunctionCallableMismatchChildActor : ACoverageUFunctionCallableMismatchBaseActor
{
	/**
	 * Illegal child BlueprintCallable whose parameter type does not match the parent.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs FString Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable)
	int ComputeValue(FString Value)
	{
		return Value.Len();
	}
}
/** @end */
