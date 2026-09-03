/**
 * Mixed RPC and replication declarations on one replicating actor. C++ compiles the
 * class and checks ReplicatedScore, Health, ServerApplyDamage and the WithValidation
 * companion, so those names are part of the contract and are kept verbatim. The
 * observers cover the declared defaults and a 10-point damage application.
 *
 * @Theme Gameplay.Net
 * @Subject Net.MixedDeclarationsCompile
 * @Harness UClass
 * @Tag Gameplay.Net.MixedDeclarationsCompile
 * @Provenance Theme: Gameplay.Net. WorldStory mixed RPC + replication declarations compile.
 * @Provenance C++: AngelscriptNetworkRPCTests.cpp::MixedDeclarationsCompile
 * @Provenance Oracle: compiles; ReplicatedScore 0; Health 100.0; ServerApplyDamage Health -= 10.0;
 * @Provenance ServerValidatedAttack_Validate returns true.
 * @Provenance Extra: default Health 100.0; after ServerApplyDamage 90.0. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class AMixedRPCTestActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int ReplicatedScore = 0;

	UPROPERTY(ReplicatedUsing=OnRep_Health)
	float Health = 100.0;

	/**
	 * RepNotify for Health; C++ only requires the function to exist.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return nothing; the notify is the contract
	 */
	UFUNCTION()
	void OnRep_Health()
	{
	}

	/**
	 * Server RPC that subtracts 10 from Health.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return nothing; Health is reduced by 10
	 */
	UFUNCTION(Server)
	void ServerApplyDamage()
	{
		Health -= 10.0;
	}

	/**
	 * Client RPC notify entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Client)
	void ClientNotifyHit()
	{
	}

	/**
	 * Unreliable NetMulticast effect entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastPlayEffect()
	{
	}

	/**
	 * Server WithValidation RPC entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidatedAttack()
	{
	}

	/**
	 * Validation companion for ServerValidatedAttack.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ServerValidatedAttack_Validate()
	{
		return true;
	}

	/**
	 * Observe that the declared defaults and the validation companion hold.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return true when ReplicatedScore is 0, Health is 100.0 and Validate returns true
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (ReplicatedScore != 0)
		{
			return false;
		}
		if (Health != 100.0)
		{
			return false;
		}
		return ServerValidatedAttack_Validate();
	}

	/**
	 * Observe that ServerApplyDamage reduces Health from 100 to 90.
	 *
	 * @Kind Observe
	 * @Covers Net.MixedDeclarationsCompile
	 * @Inputs none
	 * @Return true when Health is 90.0 after the call
	 */
	UFUNCTION()
	bool ApplyDamage()
	{
		ServerApplyDamage();
		return Health == 90.0;
	}
}
