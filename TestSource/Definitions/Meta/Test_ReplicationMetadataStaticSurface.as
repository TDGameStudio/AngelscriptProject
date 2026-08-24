// Theme: Definitions.Meta. WorldStory: static replication surface with ReplicatedUsing and conditions.
// C++: AngelscriptCoverageNetworkingTests.cpp::ReplicationMetadataStaticSurface
// Oracle defaults: UnconditionalValue 1, TrackedValue 2, InitialOnlyValue 3, OwnerOnlyValue 4,
// SkipOwnerValue 5, AutonomousOnlyValue 6, ReplayOrOwnerValue 7, CustomValue 8.
// Extra: TrackedValue 0; OnRep_TrackedValue is a no-op. FixtureIsolated.

UCLASS()
class ACoverageNetworkingStaticReplicationActor : AActor
{
	default SetReplicates(true);
	default SetReplicateMovement(true);

	UPROPERTY(Replicated)
	int UnconditionalValue = 1;

	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue)
	int TrackedValue = 2;

	UPROPERTY(Replicated, ReplicationCondition=InitialOnly)
	int InitialOnlyValue = 3;

	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int OwnerOnlyValue = 4;

	UPROPERTY(Replicated, ReplicationCondition=SkipOwner)
	int SkipOwnerValue = 5;

	UPROPERTY(Replicated, ReplicationCondition=AutonomousOnly)
	int AutonomousOnlyValue = 6;

	UPROPERTY(Replicated, ReplicationCondition=ReplayOrOwner)
	int ReplayOrOwnerValue = 7;

	UPROPERTY(Replicated, ReplicationCondition=Custom)
	int CustomValue = 8;

	UFUNCTION()
	void OnRep_TrackedValue()
	{
	}
}

int Observe_StaticReplication_UnconditionalDefault(ACoverageNetworkingStaticReplicationActor Actor)
{
	return Actor.UnconditionalValue;
}

int Observe_StaticReplication_TrackedValueDefault(ACoverageNetworkingStaticReplicationActor Actor)
{
	return Actor.TrackedValue;
}

int Observe_StaticReplication_CustomValueDefault(ACoverageNetworkingStaticReplicationActor Actor)
{
	return Actor.CustomValue;
}

int Observe_StaticReplication_ZeroTrackedBoundary(ACoverageNetworkingStaticReplicationActor Actor)
{
	Actor.TrackedValue = 0;
	Actor.OnRep_TrackedValue();
	return Actor.TrackedValue;
}

bool Observe_StaticReplication_CopyIndependence(ACoverageNetworkingStaticReplicationActor First, ACoverageNetworkingStaticReplicationActor Second)
{
	First.TrackedValue = 9;
	Second.TrackedValue = 2;
	return First.TrackedValue == 9 && Second.TrackedValue == 2;
}
