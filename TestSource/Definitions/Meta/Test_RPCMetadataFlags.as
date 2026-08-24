// Theme: Definitions.Meta. WorldStory: Server/Client/NetMulticast plus WithValidation metadata.
// C++: AngelscriptCoverageNetworkingTests.cpp::RPCMetadataFlags
// Oracle: ServerValidatedAction_Validate returns true; default SetReplicates(true).
// Extra: default handle is null. FixtureIsolated.

UCLASS()
class ACoverageNetworkingRPCActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server)
	void ServerReliableAction()
	{
	}

	UFUNCTION(Server, Unreliable)
	void ServerUnreliableAction()
	{
	}

	UFUNCTION(Client)
	void ClientReliableNotify()
	{
	}

	UFUNCTION(Client, Unreliable)
	void ClientUnreliableNotify()
	{
	}

	UFUNCTION(NetMulticast)
	void MulticastReliableEvent()
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliableEvent()
	{
	}

	UFUNCTION(Server, WithValidation)
	void ServerValidatedAction()
	{
	}

	UFUNCTION()
	bool ServerValidatedAction_Validate()
	{
		return true;
	}
}

bool Observe_RPCMetadata_ValidateTrue(ACoverageNetworkingRPCActor Actor)
{
	return Actor.ServerValidatedAction_Validate();
}

int Observe_RPCMetadata_EmptyDefaultIsNull()
{
	ACoverageNetworkingRPCActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
