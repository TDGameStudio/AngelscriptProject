/**
 * @version v1
 * @summary A Server RPC declaration on a replicating actor. C++ compiles the class and checks that ServerDoAction carries FUNC_Net, FUNC_NetServer and FUNC_NetReliable, so those names are part of the contract and are kept verbatim.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A Server RPC declaration on a replicating actor. C++ compiles the class and checks that ServerDoAction carries FUNC_Net, FUNC_NetServer and FUNC_NetReliable, so those names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
UCLASS()
class AServerRPCTestActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server RPC entrypoint whose FUNC_Net / FUNC_NetServer / FUNC_NetReliable flags
	 * C++ inspects.
	 *
	 * @Kind Observe
	 * @Covers Net.ServerDeclarationCompiles
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server)
	void ServerDoAction()
	{
	}

	/**
	 * Observe that a default-constructed actor is non-null.
	 *
	 * @Kind Observe
	 * @Covers Net.ServerDeclarationCompiles
	 * @Inputs a locally constructed actor
	 * @Return true when the constructed actor is non-null
	 * @Boundary default-constructed actor
	 */
	UFUNCTION()
	bool DefaultConstructed()
	{
		AServerRPCTestActor Actor;
		return Actor != nullptr;
	}
}
/** @end */
