/**
 * @version v1
 * @summary A Server WithValidation RPC and its Validate companion. C++ compiles the class and checks FUNC_NetValidate on ServerValidatedAction, so those names are part of the contract and are kept verbatim. The observer covers.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A Server WithValidation RPC and its Validate companion. C++ compiles the class and checks FUNC_NetValidate on ServerValidatedAction, so those names are part of the contract and are kept verbatim. The observer covers.
 * @topic Baseline
 */
UCLASS()
class AValidationRPCTestActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server WithValidation RPC entrypoint whose FUNC_NetValidate flag C++ inspects.
	 *
	 * @Kind Observe
	 * @Covers Net.WithValidationDeclarationCompiles
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidatedAction()
	{
	}

	/**
	 * Validation companion for ServerValidatedAction.
	 *
	 * @Kind Observe
	 * @Covers Net.WithValidationDeclarationCompiles
	 * @Inputs none
	 * @Return true, the C++ companion contract
	 */
	UFUNCTION()
	bool ServerValidatedAction_Validate()
	{
		return true;
	}

	/**
	 * Observe that the validation companion returns true.
	 *
	 * @Kind Observe
	 * @Covers Net.WithValidationDeclarationCompiles
	 * @Inputs none
	 * @Return true when ServerValidatedAction_Validate returns true
	 */
	UFUNCTION()
	bool ValidateTrue()
	{
		return ServerValidatedAction_Validate();
	}
}
/** @end */
