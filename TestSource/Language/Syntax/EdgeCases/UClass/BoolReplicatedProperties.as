/**
 * Replicated boolean properties: one plain Replicated flag defaulting to true and
 * one ReplicatedUsing flag that invokes an OnRep handler. The observers confirm
 * the defaults and that writing one actor leaves another untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolReplicatedProperties
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.BoolReplicatedProperties
 * @Provenance C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolReplicatedProperties
 * @Provenance sha256=0f5eeda111a0418a9797e1d70626b6043c060bcff83dee8deca9fb331bc0b613; lines 432-449.
 * @Provenance Oracle: bReplicatedFlag default true; bReady default false; OnRep_Ready exists.
 * @Provenance Extra: local construct keeps those defaults; writing bReady is independent
 * @Provenance of bReplicatedFlag. FixtureIsolated.
 */

UCLASS()
class ACoverageBoolReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	bool bReplicatedFlag = true;

	UPROPERTY(ReplicatedUsing=OnRep_Ready)
	bool bReady = false;

	/**
	 * The replication callback wired to bReady.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_Ready()
	{
	}

	/**
	 * Observe that both replicated flags hold their defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when bReplicatedFlag is true and bReady is false
	 * @Boundary default values
	 */
	UFUNCTION()
	bool ReplicatedBoolsHoldDeclaredDefaults()
	{
		if (bReplicatedFlag != true)
		{
			return false;
		}

		return bReady == false;
	}

	/**
	 * Observe that writing one actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds the write and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool ReplicatedBoolsAreIndependentAcrossInstances()
	{
		ACoverageBoolReplicationActor Other =
			Cast<ACoverageBoolReplicationActor>(
				NewObject(GetTransientPackage(), ACoverageBoolReplicationActor::StaticClass(), n"CoverageBoolReplicationActorOther"));
		if (Other == nullptr)
		{
			throw("Test_BoolReplicatedProperties setup: NewObject returned null");
		}

		bReady = true;
		OnRep_Ready();

		if (bReady != true)
		{
			return false;
		}

		if (bReplicatedFlag != true)
		{
			return false;
		}

		if (Other.bReady != false)
		{
			return false;
		}

		return Other.bReplicatedFlag == true;
	}
}
