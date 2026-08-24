// Theme: Gameplay.Net. WorldStory Server RPC declaration compiles.
// C++: AngelscriptNetworkRPCTests.cpp::ServerDeclarationCompiles
// Oracle: compiles; ServerDoAction carries FUNC_Net, FUNC_NetServer, FUNC_NetReliable.
// Extra: default-constructed actor. FixtureIsolated.

UCLASS()
class AServerRPCTestActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server)
	void ServerDoAction()
	{
	}
}

bool Observe_ServerRPC_DefaultConstructed()
{
	AServerRPCTestActor Actor;
	return Actor != nullptr;
}
