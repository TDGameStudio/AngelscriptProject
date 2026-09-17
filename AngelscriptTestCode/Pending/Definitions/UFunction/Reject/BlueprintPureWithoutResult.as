/**
 * @version v1
 * @summary BlueprintPure must have a return value or an out parameter. PureWithoutResult is a void method with neither. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintPure must have a return value or an out parameter. PureWithoutResult is a void method with neither. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionPureWithoutResultActor : AActor
{
	/**
	 * Illegal BlueprintPure void method with no result.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintPure) void PureWithoutResult()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintPure)
	void PureWithoutResult()
	{
	}
}
/** @end */
