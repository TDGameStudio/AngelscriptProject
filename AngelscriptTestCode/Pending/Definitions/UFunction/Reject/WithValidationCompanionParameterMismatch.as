/**
 * @version v1
 * @summary A WithValidation companion must use the same parameters as the RPC. The validate method takes FString while the server method takes int. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A WithValidation companion must use the same parameters as the RPC. The validate method takes FString while the server method takes int. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionBadValidateParamsActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server WithValidation UFUNCTION whose companion parameters do not match.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION(Server, WithValidation)
	void ServerBadValidateParams(int Value)
	{
	}

	/**
	 * Illegal _Validate companion whose parameter type is FString instead of int.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs FString Value
	 * @Return does not compile
	 */
	UFUNCTION()
	bool ServerBadValidateParams_Validate(FString Value)
	{
		return !Value.IsEmpty();
	}
}
/** @end */
