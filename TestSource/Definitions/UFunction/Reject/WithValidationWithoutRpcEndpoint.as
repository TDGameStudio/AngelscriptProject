/**
 * WithValidation requires Server or Client. ValidateOnly has the validation
 * flag without an RPC endpoint. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.WithValidationWithoutRpcEndpoint
 * @Harness CompileReject
 * @Tag Definitions.UFunction.WithValidationWithoutRpcEndpoint
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(WithValidation) void ValidateOnly()
 * @Return does not compile; diagnostic "UFUNCTION() ValidateOnly has the WithValidation property without the Server or Client property!"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: WithValidation requires Server or Client.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case validation without endpoint.
 * @Provenance Expected compile failure: "UFUNCTION() ValidateOnly has the WithValidation property without the Server or Client property!"
 */

UCLASS()
class ACoverageUFunctionValidationWithoutEndpointActor : AActor
{
	/**
	 * Illegal WithValidation UFUNCTION with no Server or Client specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(WithValidation)
	 * @Return does not compile
	 */
	UFUNCTION(WithValidation)
	void ValidateOnly()
	{
	}
}
