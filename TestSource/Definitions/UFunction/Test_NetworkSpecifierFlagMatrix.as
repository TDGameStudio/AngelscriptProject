// Theme: Definitions.UFunction. WorldStory: Server/Client/NetMulticast reliability and WithValidation.
// C++: AngelscriptCoverageUFunctionTests.cpp::NetworkSpecifierFlagMatrix
// Compile + inspect FUNC_Net flags. Runtime oracle lives on ServerValidatedReliable_Validate.
// Extra: Validate(0) is true; Validate(-1) is false. RPC bodies are empty and leave no state.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionNetworkActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server)
	void ServerReliableDefault()
	{
	}

	UFUNCTION(Server, Unreliable)
	void ServerUnreliableExplicit()
	{
	}

	UFUNCTION(Client)
	void ClientReliableDefault()
	{
	}

	UFUNCTION(Client, Unreliable)
	void ClientUnreliableExplicit()
	{
	}

	UFUNCTION(NetMulticast)
	void MulticastReliableExplicit()
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliableExplicit()
	{
	}

	UFUNCTION(Server, WithValidation)
	void ServerValidatedReliable(int Value)
	{
	}

	UFUNCTION()
	bool ServerValidatedReliable_Validate(int Value)
	{
		return Value >= 0;
	}
}

bool Observe_NetworkFlags_ValidateNonNegative(ACoverageUFunctionNetworkActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkSpecifierFlagMatrix setup: required Actor is null");
	}
	return Actor.ServerValidatedReliable_Validate(0);
}

bool Observe_NetworkFlags_ValidateNegativeBoundary(ACoverageUFunctionNetworkActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkSpecifierFlagMatrix setup: required Actor is null");
	}
	return !Actor.ServerValidatedReliable_Validate(-1);
}

bool Observe_NetworkFlags_ValidatePositive(ACoverageUFunctionNetworkActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkSpecifierFlagMatrix setup: required Actor is null");
	}
	return Actor.ServerValidatedReliable_Validate(7);
}
