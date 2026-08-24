// Theme: Gameplay.Net. WorldStory RPCs with typed parameters and validation companion.
// C++: AngelscriptCoverageNetworkingTests.cpp::RPCWithParameters
// Oracle: class compiles; ServerActionWithInt 1 param; MultipleParams 3; Client string;
// Multicast location+rotation; Validate(Damage, Target) returns Damage >= 0 && Target != nullptr.
// Extra: Validate(-1, nullptr) false; Validate(0, nullptr) false. FixtureIsolated.

UCLASS()
class ACoverageNetworkingRPCParamsActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server)
	void ServerActionWithInt(int Value)
	{
	}

	UFUNCTION(Server)
	void ServerActionWithMultipleParams(int Value, float Rate, FVector Location)
	{
	}

	UFUNCTION(Client)
	void ClientNotifyWithString(FString Message)
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastEventWithLocation(FVector Location, FRotator Rotation)
	{
	}

	UFUNCTION(Server, WithValidation)
	void ServerValidatedWithParams(int Damage, AActor Target)
	{
	}

	UFUNCTION()
	bool ServerValidatedWithParams_Validate(int Damage, AActor Target)
	{
		return Damage >= 0 && Target != nullptr;
	}
}

bool Observe_RPCParams_ValidateNegativeDamage(ACoverageNetworkingRPCParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_RPCWithParameters setup: required Actor is null");
	}
	return Actor.ServerValidatedWithParams_Validate(-1, nullptr) == false;
}

bool Observe_RPCParams_ValidateNullTargetBoundary(ACoverageNetworkingRPCParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_RPCWithParameters setup: required Actor is null");
	}
	return Actor.ServerValidatedWithParams_Validate(0, nullptr) == false;
}

bool Observe_RPCParams_EmptyLocationDefault(ACoverageNetworkingRPCParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_RPCWithParameters setup: required Actor is null");
	}
	Actor.ServerActionWithMultipleParams(0, 0.0f, FVector::ZeroVector);
	Actor.ClientNotifyWithString("");
	return true;
}
