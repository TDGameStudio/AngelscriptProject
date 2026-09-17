/**
 * @version v1
 * @summary Multiple Server, Client, NetMulticast and WithValidation RPCs on one replicating actor. C++ compiles the class and checks the flags, so those names are part of the contract and are kept verbatim. The observer covers both.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Multiple Server, Client, NetMulticast and WithValidation RPCs on one replicating actor. C++ compiles the class and checks the flags, so those names are part of the contract and are kept verbatim. The observer covers both.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingMultiRPCActor : AActor
{
	default SetReplicates(true);

	/**
	 * First Server RPC entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server)
	void ServerAction1()
	{
	}

	/**
	 * Second Server RPC entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server)
	void ServerAction2()
	{
	}

	/**
	 * First Client RPC entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Client)
	void ClientNotify1()
	{
	}

	/**
	 * Second Client RPC entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Client)
	void ClientNotify2()
	{
	}

	/**
	 * First Unreliable NetMulticast entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastEvent1()
	{
	}

	/**
	 * Second Unreliable NetMulticast entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastEvent2()
	{
	}

	/**
	 * First Server WithValidation RPC entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidated1()
	{
	}

	/**
	 * Validation companion for ServerValidated1.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ServerValidated1_Validate()
	{
		return true;
	}

	/**
	 * Second Server WithValidation RPC entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidated2()
	{
	}

	/**
	 * Validation companion for ServerValidated2.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ServerValidated2_Validate()
	{
		return true;
	}

	/**
	 * Observe that both validation companions return true.
	 *
	 * @Kind Observe
	 * @Covers Net.MultipleRPCsInSingleClass
	 * @Inputs none
	 * @Return true when both Validate helpers return true
	 */
	UFUNCTION()
	bool ValidateTrue()
	{
		if (!ServerValidated1_Validate())
		{
			return false;
		}
		return ServerValidated2_Validate();
	}
}
/** @end */
