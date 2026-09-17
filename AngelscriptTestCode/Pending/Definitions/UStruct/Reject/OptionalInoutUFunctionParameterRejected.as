/**
 * @version v1
 * @summary An inout TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An inout TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalInoutParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalInoutParameterActor : AActor
{
	/**
	 * The isolated failing UFUNCTION: inout TOptional struct parameters are invalid.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.OptionalInoutUFunctionParameterRejected
	 * @Inputs TOptional<FOptionalInoutParameterStruct>&inout Payload
	 * @Return does not compile; unknown or invalid parameter type for Payload
	 * @Param Payload the optional struct that must not be a UFUNCTION inout parameter
	 */
	UFUNCTION(BlueprintCallable)
	void MutateOptional(TOptional<FOptionalInoutParameterStruct>&inout Payload)
	{
	}
}
/** @end */
