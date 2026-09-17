/**
 * @version v1
 * @summary WithValidation requires Server or Client. ValidateOnly has the validation flag without an RPC endpoint. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary WithValidation requires Server or Client. ValidateOnly has the validation flag without an RPC endpoint. This file is the illegal program itself.
 * @topic Negative
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
/** @end */
