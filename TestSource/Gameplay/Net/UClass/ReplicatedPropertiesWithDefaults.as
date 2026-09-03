/**
 * Replicated CDO defaults for health, speed, alive, player name and score. C++
 * compiles the class and checks those values, so the UPROPERTY names are part of the
 * contract and are kept verbatim. The observers cover the CDO and a false-alive
 * boundary.
 *
 * @Theme Gameplay.Net
 * @Subject Net.ReplicatedPropertiesWithDefaults
 * @Harness UClass
 * @Tag Gameplay.Net.ReplicatedPropertiesWithDefaults
 * @Provenance Theme: Gameplay.Net. WorldStory replicated CDO defaults.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::ReplicatedPropertiesWithDefaults
 * @Provenance Oracle: class compiles; Health 100, Speed 600.0f, bIsAlive true, PlayerName DefaultPlayer, Score 0.
 * @Provenance Extra: Score 0 empty; bIsAlive false boundary. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageNetworkingDefaultsActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int Health = 100;

	UPROPERTY(Replicated)
	float Speed = 600.0f;

	UPROPERTY(Replicated)
	bool bIsAlive = true;

	UPROPERTY(Replicated)
	FString PlayerName = "DefaultPlayer";

	UPROPERTY(ReplicatedUsing=OnRep_Score)
	int Score = 0;

	/**
	 * RepNotify for Score; C++ only requires the function to exist.
	 *
	 * @Kind Observe
	 * @Covers Net.ReplicatedPropertiesWithDefaults
	 * @Inputs none
	 * @Return nothing; the notify is the contract
	 */
	UFUNCTION()
	void OnRep_Score()
	{
	}

	/**
	 * Observe that an untouched actor keeps the replicated CDO defaults.
	 *
	 * @Kind Observe
	 * @Covers Net.ReplicatedPropertiesWithDefaults
	 * @Inputs none
	 * @Return true when Health is 100, Speed is 600, bIsAlive is true, PlayerName is DefaultPlayer and Score is 0
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool CDODefaults()
	{
		if (Health != 100)
		{
			return false;
		}
		if (Speed != 600.0f)
		{
			return false;
		}
		if (!bIsAlive)
		{
			return false;
		}
		if (PlayerName != "DefaultPlayer")
		{
			return false;
		}
		return Score == 0;
	}

	/**
	 * Observe that clearing alive and zeroing score through the notify lands at the
	 * false/empty boundary.
	 *
	 * @Kind Observe
	 * @Covers Net.ReplicatedPropertiesWithDefaults
	 * @Inputs none
	 * @Return true when bIsAlive is false and Score is 0
	 * @Boundary false alive
	 */
	UFUNCTION()
	bool FalseAliveBoundary()
	{
		bIsAlive = false;
		Score = 0;
		OnRep_Score();

		if (bIsAlive)
		{
			return false;
		}
		return Score == 0;
	}
}
