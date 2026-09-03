/**
 * An inout TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this
 * program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalInoutUFunctionParameterRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalInoutUFunctionParameterRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalInoutUFunctionParameterRejected
 * @Inputs TOptional<FOptionalInoutParameterStruct>&inout Payload
 * @Return does not compile; diagnostic "Unknown or invalid parameter type for parameter Payload"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> inout UFUNCTION parameter.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
 * @Provenance Isolate the failing program. DiagnosticOnly.
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
