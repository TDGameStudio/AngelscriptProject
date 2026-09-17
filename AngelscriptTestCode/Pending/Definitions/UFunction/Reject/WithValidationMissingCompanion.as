/**
 * @version v1
 * @summary WithValidation requires a matching _Validate companion UFUNCTION. Server ServerMissingValidate has no ServerMissingValidate_Validate. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary WithValidation requires a matching _Validate companion UFUNCTION. Server ServerMissingValidate has no ServerMissingValidate_Validate. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionMissingValidateActor : AActor
{
	default SetReplicates(true);

	/**
	 * Illegal Server WithValidation UFUNCTION with no _Validate companion.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, WithValidation) void ServerMissingValidate(int Value)
	 * @Return does not compile
	 */
	UFUNCTION(Server, WithValidation)
	void ServerMissingValidate(int Value)
	{
	}
}
/** @end */
