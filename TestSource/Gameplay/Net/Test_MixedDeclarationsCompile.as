// Theme: Gameplay.Net. WorldStory mixed RPC + replication declarations compile.
// C++: AngelscriptNetworkRPCTests.cpp::MixedDeclarationsCompile
// Oracle: compiles; ReplicatedScore 0; Health 100.0; ServerApplyDamage Health -= 10.0;
// ServerValidatedAttack_Validate returns true.
// Extra: default Health 100.0; after ServerApplyDamage 90.0. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class AMixedRPCTestActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int ReplicatedScore = 0;

	UPROPERTY(ReplicatedUsing=OnRep_Health)
	float Health = 100.0;

	UFUNCTION()
	void OnRep_Health()
	{
	}

	UFUNCTION(Server)
	void ServerApplyDamage()
	{
		Health -= 10.0;
	}

	UFUNCTION(Client)
	void ClientNotifyHit()
	{
	}

	UFUNCTION(NetMulticast, Unreliable)
	void MulticastPlayEffect()
	{
	}

	UFUNCTION(Server, WithValidation)
	void ServerValidatedAttack()
	{
	}

	UFUNCTION()
	bool ServerValidatedAttack_Validate()
	{
		return true;
	}
}

bool Observe_MixedRPC_Defaults(AMixedRPCTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedDeclarationsCompile setup: required Actor is null");
	}
	return Actor.ReplicatedScore == 0
		&& Actor.Health == 100.0
		&& Actor.ServerValidatedAttack_Validate() == true;
}

bool Observe_MixedRPC_ApplyDamage(AMixedRPCTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedDeclarationsCompile setup: required Actor is null");
	}
	Actor.ServerApplyDamage();
	return Actor.Health == 90.0;
}
