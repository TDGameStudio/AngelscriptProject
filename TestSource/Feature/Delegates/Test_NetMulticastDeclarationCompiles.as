// Theme: Feature.Delegates. WorldStory NetMulticast RPC declaration.
// C++: AngelscriptNetworkRPCTests.cpp::NetMulticastDeclarationCompiles
// sha256=dc5b6537fea88d110d4bf2ad530cbbc30616363ddb6a0b1182fb43f2c8630985; lines 163-174.
// Oracle: class compiles; MulticastBroadcastEvent carries FUNC_Net|FUNC_NetMulticast|FUNC_NetReliable.
// Extra: local construct; empty multicast body is a no-op. FixtureIsolated.

UCLASS()
class AMulticastRPCTestActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(NetMulticast)
	void MulticastBroadcastEvent()
	{
	}
}

void Observe_NetMulticast_LocalConstruct()
{
	AMulticastRPCTestActor Actor;
}

void Observe_NetMulticast_EmptyCallIsNoOp(AMulticastRPCTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetMulticastDeclarationCompiles setup: required Actor is null");
	}
	Actor.MulticastBroadcastEvent();
}

bool Observe_NetMulticast_TwoLocalsIndependent(AMulticastRPCTestActor First)
{
	if (First is null)
	{
		throw("Test_NetMulticastDeclarationCompiles setup: required First is null");
	}
	AMulticastRPCTestActor Second;
	First.MulticastBroadcastEvent();
	return First != nullptr && Second != nullptr && First != Second;
}
