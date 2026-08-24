// Theme: Gameplay.Net. WorldStory Server/Client/NetMulticast reliable vs Unreliable RPCs.
// C++: AngelscriptCoverageNetworkingTests.cpp::RPCReliabilityVariations
// Oracle: class compiles; six RPC entry points exist.
// Extra: default-constructed actor. FixtureIsolated.

UCLASS()
class ACoverageNetworkingRPCReliabilityActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server)
	void ServerReliableExplicit()
	{
	}

	UFUNCTION(Server, Unreliable)
	void ServerUnreliable()
	{
	}

	UFUNCTION(Client)
	void ClientReliableExplicit()
	{
	}

	UFUNCTION(Client, Unreliable)
	void ClientUnreliable()
	{
	}

	UFUNCTION(NetMulticast)
	void MulticastReliableExplicit()
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliable()
	{
	}
}

bool Observe_RPCReliability_DefaultConstructed()
{
	ACoverageNetworkingRPCReliabilityActor Actor;
	return Actor != nullptr;
}
