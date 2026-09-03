/**
 * Replicated lifetime metadata: plain Net, RepNotify Health, OwnerOnly ammo and
 * SkipReplay frame. C++ compiles the class and checks CPF_Net plus the conditions, so
 * the UPROPERTY names are part of the contract and are kept verbatim. The observers
 * cover the declared defaults and a zeroed boundary.
 *
 * @Theme Gameplay.Net
 * @Subject Net.ReplicatedPropertiesAndLifetimeList
 * @Harness UClass
 * @Tag Gameplay.Net.ReplicatedPropertiesAndLifetimeList
 * @Provenance Theme: Gameplay.Net. WorldStory replicated lifetime metadata actor.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::ReplicatedPropertiesAndLifetimeList
 * @Provenance Oracle: class compiles; ReplicatedScore/Health/OwnerOnlyAmmo/SkipReplayFrame carry CPF_Net;
 * @Provenance Health RepNotify OnRep_Health; OwnerOnly / SkipReplay conditions.
 * @Provenance Extra: defaults 0 / 100.0 / 30 / 7. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageNetworkingReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int ReplicatedScore = 0;

	UPROPERTY(ReplicatedUsing=OnRep_Health)
	float Health = 100.0;

	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int OwnerOnlyAmmo = 30;

	UPROPERTY(Replicated, ReplicationCondition=SkipReplay)
	int SkipReplayFrame = 7;

	/**
	 * RepNotify for Health; C++ only requires the function to exist.
	 *
	 * @Kind Observe
	 * @Covers Net.ReplicatedPropertiesAndLifetimeList
	 * @Inputs none
	 * @Return nothing; the notify is the contract
	 */
	UFUNCTION()
	void OnRep_Health()
	{
	}

	/**
	 * Observe that an untouched actor keeps the declared replicated defaults.
	 *
	 * @Kind Observe
	 * @Covers Net.ReplicatedPropertiesAndLifetimeList
	 * @Inputs none
	 * @Return true when score is 0, Health is 100.0, ammo is 30 and frame is 7
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
		if (OwnerOnlyAmmo != 30)
		{
			return false;
		}
		return SkipReplayFrame == 7;
	}

	/**
	 * Observe that zeroing every replicated field and running the notify lands at zero.
	 *
	 * @Kind Observe
	 * @Covers Net.ReplicatedPropertiesAndLifetimeList
	 * @Inputs none
	 * @Return true when score, Health, ammo and frame all read 0
	 * @Boundary zero overwrite
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		ReplicatedScore = 0;
		Health = 0.0;
		OwnerOnlyAmmo = 0;
		SkipReplayFrame = 0;
		OnRep_Health();

		if (ReplicatedScore != 0)
		{
			return false;
		}
		if (Health != 0.0)
		{
			return false;
		}
		if (OwnerOnlyAmmo != 0)
		{
			return false;
		}
		return SkipReplayFrame == 0;
	}
}
