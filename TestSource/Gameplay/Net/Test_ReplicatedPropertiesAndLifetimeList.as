// Theme: Gameplay.Net. WorldStory replicated lifetime metadata actor.
// C++: AngelscriptCoverageNetworkingTests.cpp::ReplicatedPropertiesAndLifetimeList
// Oracle: class compiles; ReplicatedScore/Health/OwnerOnlyAmmo/SkipReplayFrame carry CPF_Net;
// Health RepNotify OnRep_Health; OwnerOnly / SkipReplay conditions.
// Extra: defaults 0 / 100.0 / 30 / 7. FixtureIsolated. Keep UPROPERTY names.

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

	UFUNCTION()
	void OnRep_Health()
	{
	}
}

bool Observe_ReplicationActor_Defaults(ACoverageNetworkingReplicationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReplicatedPropertiesAndLifetimeList setup: required Actor is null");
	}
	return Actor.ReplicatedScore == 0
		&& Actor.Health == 100.0
		&& Actor.OwnerOnlyAmmo == 30
		&& Actor.SkipReplayFrame == 7;
}

bool Observe_ReplicationActor_ZeroBoundary(ACoverageNetworkingReplicationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReplicatedPropertiesAndLifetimeList setup: required Actor is null");
	}
	Actor.ReplicatedScore = 0;
	Actor.Health = 0.0;
	Actor.OwnerOnlyAmmo = 0;
	Actor.SkipReplayFrame = 0;
	Actor.OnRep_Health();
	return Actor.ReplicatedScore == 0
		&& Actor.Health == 0.0
		&& Actor.OwnerOnlyAmmo == 0
		&& Actor.SkipReplayFrame == 0;
}
