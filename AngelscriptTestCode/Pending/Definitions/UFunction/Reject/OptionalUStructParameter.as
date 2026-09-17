/**
 * @version v1
 * @summary A TOptional USTRUCT UFUNCTION parameter is unsupported. AcceptOptional takes TOptional of a script struct, which is not a valid parameter type. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A TOptional USTRUCT UFUNCTION parameter is unsupported. AcceptOptional takes TOptional of a script struct, which is not a valid parameter type. This file is the illegal program itself.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FUFunctionOptionalParameterPayload
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageUFunctionOptionalParameterActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter is TOptional of a USTRUCT.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs TOptional<FUFunctionOptionalParameterPayload> Value
	 * @Return does not compile
	 */
	UFUNCTION()
	void AcceptOptional(TOptional<FUFunctionOptionalParameterPayload> Value)
	{
	}
}
/** @end */
