// Theme: Definitions.UClass. WorldStory default SetReplicates/SetReplicateMovement.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::DefaultKeywordMethods
// Oracle: spawned actor GetIsReplicated true, IsReplicatingMovement true; ReplicatedValue is CPF_Net default 1.
// Extra: unset handle is null; ReplicatedValue 0 is the false/zero boundary. FixtureIsolated.

UCLASS()
class ACoverageClassFeaturesDefaultMethodActor : AActor
{
	UPROPERTY(Replicated)
	int ReplicatedValue = 1;

	default SetReplicates(true);
	default SetReplicateMovement(true);
}

bool Observe_DefaultMethodActor_EmptyDefaultIsNull()
{
	ACoverageClassFeaturesDefaultMethodActor Actor;
	return Actor == nullptr;
}

int Observe_DefaultMethodActor_ReplicatedValueDefault(ACoverageClassFeaturesDefaultMethodActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0027 setup: required ACoverageClassFeaturesDefaultMethodActor is null");
	}
	return Actor.ReplicatedValue;
}

bool Observe_DefaultMethodActor_ReplicatedValueZeroBoundary(ACoverageClassFeaturesDefaultMethodActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0027 setup: required ACoverageClassFeaturesDefaultMethodActor is null");
	}
	Actor.ReplicatedValue = 0;
	return Actor.ReplicatedValue == 0;
}
