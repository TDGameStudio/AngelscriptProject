// Theme: Language.Syntax.EdgeCases. WorldStory replicated bool properties.
// C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolReplicatedProperties
// sha256=0f5eeda111a0418a9797e1d70626b6043c060bcff83dee8deca9fb331bc0b613; lines 432-449.
// Oracle: bReplicatedFlag default true; bReady default false; OnRep_Ready exists.
// Extra: local construct keeps those defaults; writing bReady is independent
// of bReplicatedFlag. FixtureIsolated.

UCLASS()
class ACoverageBoolReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	bool bReplicatedFlag = true;

	UPROPERTY(ReplicatedUsing=OnRep_Ready)
	bool bReady = false;

	UFUNCTION()
	void OnRep_Ready()
	{
	}
}

bool Observe_BoolReplication_NominalDefaults(ACoverageBoolReplicationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BoolReplicatedProperties setup: required Actor is null");
	}
	return Actor.bReplicatedFlag == true && Actor.bReady == false;
}

bool Observe_BoolReplication_WriteIndependence(ACoverageBoolReplicationActor First, ACoverageBoolReplicationActor Second)
{
	if (First is null)
	{
		throw("Test_BoolReplicatedProperties setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BoolReplicatedProperties setup: required Second is null");
	}
	First.bReady = true;
	First.OnRep_Ready();
	return First.bReady == true && First.bReplicatedFlag == true && Second.bReady == false && Second.bReplicatedFlag == true;
}
