/**
 * @version v1
 * @summary A WithValidation companion must return bool. ServerBadValidateReturn_Validate returns int. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A WithValidation companion must return bool. ServerBadValidateReturn_Validate returns int. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionBadValidateReturnActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server WithValidation UFUNCTION whose companion returns a non-bool.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION(Server, WithValidation)
	void ServerBadValidateReturn(int Value)
	{
	}

	/**
	 * Illegal _Validate companion that returns int instead of bool.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION()
	int ServerBadValidateReturn_Validate(int Value)
	{
		return Value;
	}
}
/** @end */
