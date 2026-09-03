/**
 * Server, Client and NetMulticast plus WithValidation metadata. The companion
 * validate returns true. default SetReplicates(true) is part of the surface.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.RPCMetadataFlags
 * @Harness UClass
 * @Tag Definitions.Meta.RPCMetadataFlags
 * @Provenance Theme: Definitions.Meta. WorldStory: Server/Client/NetMulticast plus WithValidation metadata.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::RPCMetadataFlags
 * @Provenance Oracle: ServerValidatedAction_Validate returns true; default SetReplicates(true).
 * @Provenance Extra: default handle is null. FixtureIsolated.
 */

UCLASS()
class ACoverageNetworkingRPCActor : AActor
{
	default SetReplicates(true);

	/**
	 * Reliable Server RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(Server)
	void ServerReliableAction()
	{
	}

	/**
	 * Unreliable Server RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
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
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(Client)
	void ClientReliableNotify()
	{
	}

	/**
	 * Unreliable Client RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(Client, Unreliable)
	void ClientUnreliableNotify()
	{
	}

	/**
	 * Reliable NetMulticast RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(NetMulticast)
	void MulticastReliableEvent()
	{
	}

	/**
	 * Unreliable NetMulticast RPC.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliableEvent()
	{
	}

	/**
	 * Server RPC with a companion validate function.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidatedAction()
	{
	}

	/**
	 * Companion validate that always succeeds.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ServerValidatedAction_Validate()
	{
		return true;
	}

	/**
	 * Observe that the companion validate returns true.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ValidateTrue()
	{
		return ServerValidatedAction_Validate();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCMetadataFlags
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageNetworkingRPCActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
