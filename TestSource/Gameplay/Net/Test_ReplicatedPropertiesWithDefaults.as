// Theme: Gameplay.Net. WorldStory replicated CDO defaults.
// C++: AngelscriptCoverageNetworkingTests.cpp::ReplicatedPropertiesWithDefaults
// Oracle: class compiles; Health 100, Speed 600.0f, bIsAlive true, PlayerName DefaultPlayer, Score 0.
// Extra: Score 0 empty; bIsAlive false boundary. FixtureIsolated. Keep UPROPERTY names.

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

	UFUNCTION()
	void OnRep_Score()
	{
	}
}

bool Observe_ReplicatedDefaults_CDO(ACoverageNetworkingDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReplicatedPropertiesWithDefaults setup: required Actor is null");
	}
	return Actor.Health == 100
		&& Actor.Speed == 600.0f
		&& Actor.bIsAlive == true
		&& Actor.PlayerName == "DefaultPlayer"
		&& Actor.Score == 0;
}

bool Observe_ReplicatedDefaults_FalseAliveBoundary(ACoverageNetworkingDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReplicatedPropertiesWithDefaults setup: required Actor is null");
	}
	Actor.bIsAlive = false;
	Actor.Score = 0;
	Actor.OnRep_Score();
	return Actor.bIsAlive == false && Actor.Score == 0;
}
