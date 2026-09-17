/**
 * @version v1
 * @summary Server, Client and NetMulticast specifiers are exclusive flags. Validate(0) is true and Validate(-1) is false.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Server, Client and NetMulticast specifiers are exclusive flags. Validate(0) is true and Validate(-1) is false.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingRPCSpecifierActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server RPC with validation whose payload must be non-negative.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs the payload
	 * @Return nothing
	 * @Param Payload the replicated payload
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidatedReliable(int Payload)
	{
	}

	/**
	 * Companion validate: Payload must be non-negative.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs the payload
	 * @Return true when Payload >= 0
	 * @Param Payload the replicated payload
	 */
	UFUNCTION()
	bool ServerValidatedReliable_Validate(int Payload)
	{
		return Payload >= 0;
	}

	/**
	 * Unreliable Server RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(Server, Unreliable)
	void ServerUnreliableAction()
	{
	}

	/**
	 * Reliable Client RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(Client)
	void ClientReliableAction()
	{
	}

	/**
	 * Unreliable NetMulticast RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliableAction()
	{
	}

	/**
	 * Observe that Validate(0) is true.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs none
	 * @Return true
	 * @Boundary zero
	 */
	UFUNCTION()
	bool ValidateZero()
	{
		return ServerValidatedReliable_Validate(0);
	}

	/**
	 * Observe that Validate(-1) is false.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs none
	 * @Return false
	 * @Boundary negative
	 */
	UFUNCTION()
	bool ValidateNegativeBoundary()
	{
		return ServerValidatedReliable_Validate(-1);
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCSpecifierFlagsAreExclusiveStaticMetadata
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageNetworkingRPCSpecifierActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
