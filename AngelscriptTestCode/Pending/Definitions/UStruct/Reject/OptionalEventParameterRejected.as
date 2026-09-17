/**
 * @version v1
 * @summary TOptional of a USTRUCT is not a valid multicast event parameter, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TOptional of a USTRUCT is not a valid multicast event parameter, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalEventParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

/**
 * The isolated failing event: TOptional struct parameters are invalid.
 *
 * @Kind CompileReject
 * @Covers UStruct.OptionalEventParameterRejected
 * @Inputs TOptional<FOptionalEventParameterStruct> Payload
 * @Return does not compile; unknown or invalid parameter type for Payload
 * @Param Payload the optional struct that must not be an event parameter
 */
event void FOptionalStructEvent(TOptional<FOptionalEventParameterStruct> Payload);

UCLASS()
class ACoverageStructOptionalEventParameterActor : AActor
{
	UPROPERTY()
	FOptionalStructEvent Signal;
}
/** @end */
