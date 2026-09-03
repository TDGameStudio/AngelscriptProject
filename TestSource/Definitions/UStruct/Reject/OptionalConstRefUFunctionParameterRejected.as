/**
 * A const-ref TOptional of a USTRUCT is not a valid UFUNCTION parameter, so
 * this program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalConstRefUFunctionParameterRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalConstRefUFunctionParameterRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalConstRefUFunctionParameterRejected
 * @Inputs const TOptional<FOptionalConstRefParameterStruct>&in Payload
 * @Return does not compile; diagnostic "Unknown or invalid parameter type for parameter Payload"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> const-ref UFUNCTION parameter.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalConstRefParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalConstRefParameterActor : AActor
{
	/**
	 * The isolated failing UFUNCTION: const-ref TOptional struct parameters are invalid.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.OptionalConstRefUFunctionParameterRejected
	 * @Inputs const TOptional<FOptionalConstRefParameterStruct>&in Payload
	 * @Return does not compile; unknown or invalid parameter type for Payload
	 * @Param Payload the optional struct that must not be a UFUNCTION parameter
	 */
	UFUNCTION(BlueprintCallable)
	void AcceptOptionalConstRef(const TOptional<FOptionalConstRefParameterStruct>&in Payload)
	{
	}
}
