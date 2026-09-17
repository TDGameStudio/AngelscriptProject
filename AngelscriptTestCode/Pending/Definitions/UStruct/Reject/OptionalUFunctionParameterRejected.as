/**
 * @version v1
 * @summary TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalParameterActor : AActor
{
	/**
	 * The isolated failing UFUNCTION: TOptional struct parameters are invalid.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.OptionalUFunctionParameterRejected
	 * @Inputs TOptional<FOptionalParameterStruct> Payload
	 * @Return does not compile; unknown or invalid parameter type for Payload
	 * @Param Payload the optional struct that must not be a UFUNCTION parameter
	 */
	UFUNCTION(BlueprintCallable)
	void AcceptOptional(TOptional<FOptionalParameterStruct> Payload)
	{
	}
}
/** @end */
