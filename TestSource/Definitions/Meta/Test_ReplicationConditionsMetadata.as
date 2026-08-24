// Theme: Definitions.Meta. WorldStory: ReplicationCondition names on Replicated properties.
// C++: AngelscriptCoverageNetworkingTests.cpp::ReplicationConditionsMetadata compiles (CSV NegativeDiagnostic is wrong).
// Oracle defaults 1..13 for InitialOnlyValue through SkipReplayValue.
// Extra: write 0 on CustomValue. FixtureIsolated. Keep C++ property names.

UCLASS()
class ACoverageNetworkingConditionsActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated, ReplicationCondition=InitialOnly)
	int InitialOnlyValue = 1;

	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int OwnerOnlyValue = 2;

	UPROPERTY(Replicated, ReplicationCondition=SkipOwner)
	int SkipOwnerValue = 3;

	UPROPERTY(Replicated, ReplicationCondition=SimulatedOnly)
	int SimulatedOnlyValue = 4;

	UPROPERTY(Replicated, ReplicationCondition=AutonomousOnly)
	int AutonomousOnlyValue = 5;

	UPROPERTY(Replicated, ReplicationCondition=SimulatedOrPhysics)
	int SimulatedOrPhysicsValue = 6;

	UPROPERTY(Replicated, ReplicationCondition=InitialOrOwner)
	int InitialOrOwnerValue = 7;

	UPROPERTY(Replicated, ReplicationCondition=Custom)
	int CustomValue = 8;

	UPROPERTY(Replicated, ReplicationCondition=ReplayOrOwner)
	int ReplayOrOwnerValue = 9;

	UPROPERTY(Replicated, ReplicationCondition=ReplayOnly)
	int ReplayOnlyValue = 10;

	UPROPERTY(Replicated, ReplicationCondition=SimulatedOnlyNoReplay)
	int SimulatedOnlyNoReplayValue = 11;

	UPROPERTY(Replicated, ReplicationCondition=SimulatedOrPhysicsNoReplay)
	int SimulatedOrPhysicsNoReplayValue = 12;

	UPROPERTY(Replicated, ReplicationCondition=SkipReplay)
	int SkipReplayValue = 13;
	// NOTE: ReplicationCondition=Never is intentionally omitted. COND_Never is an
	// internal sentinel meaning "never replicate" and is rejected by the AngelScript
	// UPROPERTY parser ("Unknown ReplicationCondition Never"); it is contradictory with
	// the Replicated specifier, so it is not part of the AS-facing condition surface.
}

int Observe_ReplicationConditions_InitialOnlyDefault(ACoverageNetworkingConditionsActor Actor)
{
	return Actor.InitialOnlyValue;
}

int Observe_ReplicationConditions_SkipReplayDefault(ACoverageNetworkingConditionsActor Actor)
{
	return Actor.SkipReplayValue;
}

int Observe_ReplicationConditions_SumDefaults(ACoverageNetworkingConditionsActor Actor)
{
	return Actor.InitialOnlyValue + Actor.OwnerOnlyValue + Actor.SkipOwnerValue
		+ Actor.SimulatedOnlyValue + Actor.AutonomousOnlyValue + Actor.SimulatedOrPhysicsValue
		+ Actor.InitialOrOwnerValue + Actor.CustomValue + Actor.ReplayOrOwnerValue
		+ Actor.ReplayOnlyValue + Actor.SimulatedOnlyNoReplayValue
		+ Actor.SimulatedOrPhysicsNoReplayValue + Actor.SkipReplayValue;
}

int Observe_ReplicationConditions_ZeroCustomBoundary(ACoverageNetworkingConditionsActor Actor)
{
	Actor.CustomValue = 0;
	return Actor.CustomValue;
}

bool Observe_ReplicationConditions_CopyIndependence(ACoverageNetworkingConditionsActor First, ACoverageNetworkingConditionsActor Second)
{
	First.InitialOnlyValue = 0;
	Second.InitialOnlyValue = 1;
	return First.InitialOnlyValue == 0 && Second.InitialOnlyValue == 1;
}
