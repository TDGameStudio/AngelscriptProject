/**
 * TOptional of a USTRUCT is not a valid multicast event parameter, so this
 * program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalEventParameterRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalEventParameterRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalEventParameterRejected
 * @Inputs event void FOptionalStructEvent(TOptional<FOptionalEventParameterStruct> Payload)
 * @Return does not compile; diagnostic "Unknown or invalid parameter type for parameter Payload to delegate FOptionalStructEvent"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> multicast event parameter.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload to delegate FOptionalStructEvent".
 * @Provenance Isolate the failing program. DiagnosticOnly.
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
