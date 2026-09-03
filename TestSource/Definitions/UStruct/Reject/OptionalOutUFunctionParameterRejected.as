/**
 * An out TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this
 * program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalOutUFunctionParameterRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalOutUFunctionParameterRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalOutUFunctionParameterRejected
 * @Inputs TOptional<FOptionalOutParameterStruct>&out Payload
 * @Return does not compile; diagnostic "Unknown or invalid parameter type for parameter Payload"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> out UFUNCTION parameter.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
 * @Provenance Isolate the failing program. DiagnosticOnly.
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
