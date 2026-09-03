/**
 * TOptional of a USTRUCT is not a valid delegate parameter, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalDelegateParameterRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalDelegateParameterRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalDelegateParameterRejected
 * @Inputs delegate void FOptionalStructSignal(TOptional<FOptionalDelegateParameterStruct> Payload)
 * @Return does not compile; diagnostic "Unknown or invalid parameter type for parameter Payload to delegate FOptionalStructSignal"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> delegate parameter.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload to delegate FOptionalStructSignal".
 * @Provenance Isolate the failing program. DiagnosticOnly.
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
