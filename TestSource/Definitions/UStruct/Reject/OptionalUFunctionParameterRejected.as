/**
 * TOptional of a USTRUCT is not a valid UFUNCTION parameter, so this program
 * is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalUFunctionParameterRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalUFunctionParameterRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalUFunctionParameterRejected
 * @Inputs TOptional<FOptionalParameterStruct> Payload on AcceptOptional
 * @Return does not compile; diagnostic "Unknown or invalid parameter type for parameter Payload"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> UFUNCTION parameter.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
 * @Provenance Isolate the failing program. Do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
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
