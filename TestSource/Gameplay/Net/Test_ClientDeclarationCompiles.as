// Theme: Gameplay.Net. WorldStory Client RPC declaration compiles.
// C++: AngelscriptNetworkRPCTests.cpp::ClientDeclarationCompiles
// Oracle: compiles; ClientReceiveUpdate carries FUNC_Net and FUNC_NetClient.
// Extra: default-constructed actor. FixtureIsolated.

UCLASS()
class AClientRPCTestActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Client)
	void ClientReceiveUpdate()
	{
	}
}

bool Observe_ClientRPC_DefaultConstructed()
{
	AClientRPCTestActor Actor;
	return Actor != nullptr;
}
