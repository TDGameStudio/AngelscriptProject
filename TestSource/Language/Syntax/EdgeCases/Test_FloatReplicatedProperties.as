// Theme: Language.Syntax.EdgeCases. WorldStory replicated float/double UPROPERTY flags.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatReplicatedProperties
// sha256=f7bd5b35fec5821d7f9ddef8fc26c0508b55cf2e45f6b436af2a649deb55436c; lines 698-726.
// Oracle: ReplicatedFloat/Double carry CPF_Net not CPF_RepNotify; RepNotifyFloat/PreciseValue
// carry both. Extra: default values 1.25, 2.5, 3.75, 4.5. FixtureIsolated.

UCLASS()
class ACoverageFloatReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	float ReplicatedFloat = 1.25f;

	UPROPERTY(Replicated)
	double ReplicatedDouble = 2.5;

	UPROPERTY(ReplicatedUsing=OnRep_RepNotifyFloat)
	float RepNotifyFloat = 3.75f;

	UPROPERTY(ReplicatedUsing=OnRep_PreciseValue)
	double PreciseValue = 4.5;

	UFUNCTION()
	void OnRep_RepNotifyFloat()
	{
	}

	UFUNCTION()
	void OnRep_PreciseValue()
	{
	}
}

bool Observe_FloatReplication_DefaultValues(ACoverageFloatReplicationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatReplicatedProperties setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.ReplicatedFloat, 1.25) && Math::IsNearlyEqual(Actor.ReplicatedDouble, 2.5) && Math::IsNearlyEqual(Actor.RepNotifyFloat, 3.75) && Math::IsNearlyEqual(Actor.PreciseValue, 4.5);
}

bool Observe_FloatReplication_ZeroAssignBoundary(ACoverageFloatReplicationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatReplicatedProperties setup: required Actor is null");
	}
	Actor.ReplicatedFloat = 0.0f;
	Actor.ReplicatedDouble = 0.0;
	return Math::IsNearlyEqual(Actor.ReplicatedFloat, 0.0) && Math::IsNearlyEqual(Actor.ReplicatedDouble, 0.0);
}
