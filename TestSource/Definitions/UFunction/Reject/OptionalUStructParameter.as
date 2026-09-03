/**
 * A TOptional USTRUCT UFUNCTION parameter is unsupported. AcceptOptional takes
 * TOptional of a script struct, which is not a valid parameter type. This
 * file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.OptionalUStructParameter
 * @Harness CompileReject
 * @Tag Definitions.UFunction.OptionalUStructParameter
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void AcceptOptional(TOptional<FUFunctionOptionalParameterPayload> Value)
 * @Return does not compile; diagnostic "Unknown or invalid parameter type for parameter Value"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: TOptional USTRUCT UFUNCTION parameter is unsupported.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case optional parameter.
 * @Provenance Expected compile failure: "Unknown or invalid parameter type for parameter Value"
 */

USTRUCT(BlueprintType)
struct FUFunctionOptionalParameterPayload
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageUFunctionOptionalParameterActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter is TOptional of a USTRUCT.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs TOptional<FUFunctionOptionalParameterPayload> Value
	 * @Return does not compile
	 */
	UFUNCTION()
	void AcceptOptional(TOptional<FUFunctionOptionalParameterPayload> Value)
	{
	}
}
