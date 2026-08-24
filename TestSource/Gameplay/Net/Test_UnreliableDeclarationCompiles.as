// Theme: Gameplay.Net. WorldStory Client Unreliable RPC compiles.
// C++: AngelscriptNetworkRPCTests.cpp::UnreliableDeclarationCompiles
// Oracle: compiles; ClientUnreliableUpdate carries FUNC_NetClient without FUNC_NetReliable.
// Extra: default-constructed actor. FixtureIsolated.

UCLASS()
class AUnreliableRPCTestActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Client, Unreliable)
	void ClientUnreliableUpdate()
	{
	}
}

bool Observe_UnreliableRPC_DefaultConstructed()
{
	AUnreliableRPCTestActor Actor;
	return Actor != nullptr;
}
