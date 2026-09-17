/**
 * @version v1
 * @summary TOptional of a USTRUCT is not a valid delegate parameter, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TOptional of a USTRUCT is not a valid delegate parameter, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalDelegateParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

/**
 * The isolated failing delegate: TOptional struct parameters are invalid.
 *
 * @Kind CompileReject
 * @Covers UStruct.OptionalDelegateParameterRejected
 * @Inputs TOptional<FOptionalDelegateParameterStruct> Payload
 * @Return does not compile; unknown or invalid parameter type for Payload
 * @Param Payload the optional struct that must not be a delegate parameter
 */
delegate void FOptionalStructSignal(TOptional<FOptionalDelegateParameterStruct> Payload);

UCLASS()
class ACoverageStructOptionalDelegateParameterActor : AActor
{
	UPROPERTY()
	FOptionalStructSignal Signal;
}
/** @end */
