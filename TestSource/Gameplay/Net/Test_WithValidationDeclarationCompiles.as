// Theme: Gameplay.Net. WorldStory Server WithValidation RPC compiles.
// C++: AngelscriptNetworkRPCTests.cpp::WithValidationDeclarationCompiles
// Oracle: compiles; ServerValidatedAction_Validate returns true.
// Extra: Validate true is the C++ companion contract. FixtureIsolated.

UCLASS()
class AValidationRPCTestActor : AActor
{
	default SetReplicates(true);

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

bool Observe_ValidationRPC_ValidateTrue(AValidationRPCTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WithValidationDeclarationCompiles setup: required Actor is null");
	}
	return Actor.ServerValidatedAction_Validate() == true;
}
