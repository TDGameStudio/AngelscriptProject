/**
 * @version v1
 * @summary Server, Client and NetMulticast RPCs in both reliable and Unreliable forms. C++ compiles the class and checks the six entry points, so those names are part of the contract and are kept verbatim. The observer covers a.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Server, Client and NetMulticast RPCs in both reliable and Unreliable forms. C++ compiles the class and checks the six entry points, so those names are part of the contract and are kept verbatim. The observer covers a.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingRPCReliabilityActor : AActor
{
	default SetReplicates(true);

	/**
	 * Reliable Server RPC with no Unreliable specifier.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCReliabilityVariations
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server)
	void ServerReliableExplicit()
	{
	}

	/**
	 * Unreliable Server RPC.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCReliabilityVariations
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server, Unreliable)
	void ServerUnreliable()
	{
	}

	/**
	 * Reliable Client RPC with no Unreliable specifier.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCReliabilityVariations
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Client)
	void ClientReliableExplicit()
	{
	}

	/**
	 * Unreliable Client RPC.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCReliabilityVariations
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Client, Unreliable)
	void ClientUnreliable()
	{
	}

	/**
	 * Reliable NetMulticast RPC with no Unreliable specifier.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCReliabilityVariations
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(NetMulticast)
	void MulticastReliableExplicit()
	{
	}

	/**
	 * Unreliable NetMulticast RPC.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCReliabilityVariations
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliable()
	{
	}

	/**
	 * Observe that a default-constructed actor is non-null.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCReliabilityVariations
	 * @Inputs a locally constructed actor
	 * @Return true when the constructed actor is non-null
	 * @Boundary default-constructed actor
	 */
	UFUNCTION()
	bool DefaultConstructed()
	{
		ACoverageNetworkingRPCReliabilityActor Actor;
		return Actor != nullptr;
	}
}
/** @end */
