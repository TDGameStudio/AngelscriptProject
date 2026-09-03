/**
 * Replicated float and double UPROPERTYs: two plain Replicated members and two
 * ReplicatedUsing members wired to OnRep handlers. The observers confirm the
 * initializers and the zero-assignment boundary.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatReplicatedProperties
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FloatReplicatedProperties
 * @Provenance C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatReplicatedProperties
 * @Provenance sha256=f7bd5b35fec5821d7f9ddef8fc26c0508b55cf2e45f6b436af2a649deb55436c; lines 698-726.
 * @Provenance Oracle: ReplicatedFloat/Double carry CPF_Net not CPF_RepNotify; RepNotifyFloat/PreciseValue
 * @Provenance carry both. Extra: default values 1.25, 2.5, 3.75, 4.5. FixtureIsolated.
 */

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

	/**
	 * The replication callback wired to RepNotifyFloat.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_RepNotifyFloat()
	{
	}

	/**
	 * The replication callback wired to PreciseValue.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_PreciseValue()
	{
	}

	/**
	 * Observe that all four replicated properties hold their initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are 1.25, 2.5, 3.75 and 4.5
	 * @Boundary default values
	 */
	UFUNCTION()
	bool FloatReplicationDefaultValues()
	{
		if (!Math::IsNearlyEqual(ReplicatedFloat, 1.25))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(ReplicatedDouble, 2.5))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(RepNotifyFloat, 3.75))
		{
			return false;
		}

		return Math::IsNearlyEqual(PreciseValue, 4.5);
	}

	/**
	 * Observe that a zero assignment overwrites the initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both plain replicated members set to zero
	 * @Return true when both read zero
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	bool FloatReplicationZeroAssignBoundary()
	{
		ReplicatedFloat = 0.0f;
		ReplicatedDouble = 0.0;

		if (!Math::IsNearlyEqual(ReplicatedFloat, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(ReplicatedDouble, 0.0);
	}
}
