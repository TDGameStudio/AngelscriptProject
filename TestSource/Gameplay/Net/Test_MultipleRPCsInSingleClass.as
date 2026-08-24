// Theme: Gameplay.Net. WorldStory multiple RPCs plus WithValidation companions in one class.
// C++: AngelscriptCoverageNetworkingTests.cpp::MultipleRPCsInSingleClass
// Oracle: class compiles; Server/Client/NetMulticast flags; Validate callbacks are non-Net.
// Extra: both Validate helpers return true. FixtureIsolated.

UCLASS()
class ACoverageNetworkingMultiRPCActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server)
	void ServerAction1()
	{
	}

	UFUNCTION(Server)
	void ServerAction2()
	{
	}

	UFUNCTION(Client)
	void ClientNotify1()
	{
	}

	UFUNCTION(Client)
	void ClientNotify2()
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastEvent1()
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastEvent2()
	{
	}

	UFUNCTION(Server, WithValidation)
	void ServerValidated1()
	{
	}

	UFUNCTION()
	bool ServerValidated1_Validate()
	{
		return true;
	}

	UFUNCTION(Server, WithValidation)
	void ServerValidated2()
	{
	}

	UFUNCTION()
	bool ServerValidated2_Validate()
	{
		return true;
	}
}

bool Observe_MultiRPC_ValidateTrue(ACoverageNetworkingMultiRPCActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MultipleRPCsInSingleClass setup: required Actor is null");
	}
	return Actor.ServerValidated1_Validate() == true
		&& Actor.ServerValidated2_Validate() == true;
}
