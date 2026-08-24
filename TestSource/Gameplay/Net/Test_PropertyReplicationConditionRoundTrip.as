// Theme: Gameplay.Net. WorldStory: ReplicationCondition OwnerOnly / SkipReplay round-trip.
// C++: AngelscriptCompilerPropertyReplicationConditionTests.cpp::PropertyReplicationConditionRoundTrip
// Oracle: Entry() == 42; OwnerOnlyValue 11; SkipReplayValue 31.
// Extra: default values 11/31 without mutation. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class APropertyReplicationConditionCarrier : AActor
{
	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int OwnerOnlyValue = 11;

	UPROPERTY(Replicated, ReplicationCondition=SkipReplay)
	int SkipReplayValue = 31;
}

int Entry()
{
	return 42;
}

bool Observe_PropertyReplicationCondition_Entry()
{
	return Entry() == 42;
}

bool Observe_PropertyReplicationCondition_Defaults(APropertyReplicationConditionCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_PropertyReplicationConditionRoundTrip setup: required Carrier is null");
	}
	return Carrier.OwnerOnlyValue == 11 && Carrier.SkipReplayValue == 31;
}

bool Observe_PropertyReplicationCondition_ZeroBoundary(APropertyReplicationConditionCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_PropertyReplicationConditionRoundTrip setup: required Carrier is null");
	}
	Carrier.OwnerOnlyValue = 0;
	Carrier.SkipReplayValue = 0;
	return Carrier.OwnerOnlyValue == 0 && Carrier.SkipReplayValue == 0;
}
