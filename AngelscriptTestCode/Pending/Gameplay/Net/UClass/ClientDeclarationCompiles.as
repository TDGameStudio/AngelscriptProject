/**
 * @version v1
 * @summary A Client RPC declaration on a replicating actor. C++ compiles the class and checks that ClientReceiveUpdate carries FUNC_Net and FUNC_NetClient, so those names are part of the contract and are kept verbatim. The observer.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A Client RPC declaration on a replicating actor. C++ compiles the class and checks that ClientReceiveUpdate carries FUNC_Net and FUNC_NetClient, so those names are part of the contract and are kept verbatim. The observer.
 * @topic Baseline
 */
UCLASS()
class AClientRPCTestActor : AActor
{
	default SetReplicates(true);

	/**
	 * Client RPC entrypoint whose FUNC_Net / FUNC_NetClient flags C++ inspects.
	 *
	 * @Kind Observe
	 * @Covers Net.ClientDeclarationCompiles
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Client)
	void ClientReceiveUpdate()
	{
	}

	/**
	 * Observe that a default-constructed actor is non-null.
	 *
	 * @Kind Observe
	 * @Covers Net.ClientDeclarationCompiles
	 * @Inputs a locally constructed actor
	 * @Return true when the constructed actor is non-null
	 * @Boundary default-constructed actor
	 */
	UFUNCTION()
	bool DefaultConstructed()
	{
		AClientRPCTestActor Actor;
		return Actor != nullptr;
	}
}
/** @end */
