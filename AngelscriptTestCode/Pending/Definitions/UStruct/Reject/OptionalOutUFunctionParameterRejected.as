/**
 * @version v1
 * @summary An out TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An out TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalOutParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalOutParameterActor : AActor
{
	/**
	 * The isolated failing UFUNCTION: out TOptional struct parameters are invalid.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.OptionalOutUFunctionParameterRejected
	 * @Inputs TOptional<FOptionalOutParameterStruct>&out Payload
	 * @Return does not compile; unknown or invalid parameter type for Payload
	 * @Param Payload the optional struct that must not be a UFUNCTION out parameter
	 */
	UFUNCTION(BlueprintCallable)
	void FillOptional(TOptional<FOptionalOutParameterStruct>&out Payload)
	{
	}
}
/** @end */
