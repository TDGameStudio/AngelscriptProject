// Theme: Definitions.Meta. WorldStory: Server/Client/NetMulticast specifiers are exclusive flags.
// C++: AngelscriptCoverageNetworkingTests.cpp::RPCSpecifierFlagsAreExclusiveStaticMetadata
// Oracle: ServerValidatedReliable_Validate(0) true; Validate(-1) false.
// Extra: empty default handle is null. FixtureIsolated.

UCLASS()
class ACoverageNetworkingRPCSpecifierActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server, WithValidation)
	void ServerValidatedReliable(int Payload)
	{
	}

	UFUNCTION()
	bool ServerValidatedReliable_Validate(int Payload)
	{
		return Payload >= 0;
	}

	UFUNCTION(Server, Unreliable)
	void ServerUnreliableAction()
	{
	}

	UFUNCTION(Client)
	void ClientReliableAction()
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliableAction()
	{
	}
}

bool Observe_RPCSpecifier_ValidateZero(ACoverageNetworkingRPCSpecifierActor Actor)
{
	return Actor.ServerValidatedReliable_Validate(0);
}

bool Observe_RPCSpecifier_ValidateNegativeBoundary(ACoverageNetworkingRPCSpecifierActor Actor)
{
	return Actor.ServerValidatedReliable_Validate(-1);
}

int Observe_RPCSpecifier_EmptyDefaultIsNull()
{
	ACoverageNetworkingRPCSpecifierActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
