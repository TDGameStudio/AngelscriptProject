/**
 * ReplicationCondition OwnerOnly and SkipReplay round-trip on a carrier actor. C++
 * compiles the class, executes Entry() expecting 42, and checks OwnerOnlyValue 11 and
 * SkipReplayValue 31, so those names are part of the contract and are kept verbatim.
 * The observers cover the declared defaults and a zero overwrite.
 *
 * @Theme Gameplay.Net
 * @Subject Net.PropertyReplicationConditionRoundTrip
 * @Harness UClass
 * @Tag Gameplay.Net.PropertyReplicationConditionRoundTrip
 * @Provenance Theme: Gameplay.Net. WorldStory: ReplicationCondition OwnerOnly / SkipReplay round-trip.
 * @Provenance C++: AngelscriptCompilerPropertyReplicationConditionTests.cpp::PropertyReplicationConditionRoundTrip
 * @Provenance Oracle: Entry() == 42; OwnerOnlyValue 11; SkipReplayValue 31.
 * @Provenance Extra: default values 11/31 without mutation. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class APropertyReplicationConditionCarrier : AActor
{
	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int OwnerOnlyValue = 11;

	UPROPERTY(Replicated, ReplicationCondition=SkipReplay)
	int SkipReplayValue = 31;

	/**
	 * The entrypoint C++ executes, returning the compile-success sentinel.
	 *
	 * @Kind Observe
	 * @Covers Net.PropertyReplicationConditionRoundTrip
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Entry()
	{
		return 42;
	}

	/**
	 * Observe that the entrypoint returns 42.
	 *
	 * @Kind Observe
	 * @Covers Net.PropertyReplicationConditionRoundTrip
	 * @Inputs none
	 * @Return true when Entry is 42
	 */
	UFUNCTION()
	bool EntryValue()
	{
		return Entry() == 42;
	}

	/**
	 * Observe that an untouched carrier keeps the declared condition defaults.
	 *
	 * @Kind Observe
	 * @Covers Net.PropertyReplicationConditionRoundTrip
	 * @Inputs none
	 * @Return true when OwnerOnlyValue is 11 and SkipReplayValue is 31
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (OwnerOnlyValue != 11)
		{
			return false;
		}
		return SkipReplayValue == 31;
	}

	/**
	 * Observe that overwriting both fields with zero lands at zero.
	 *
	 * @Kind Observe
	 * @Covers Net.PropertyReplicationConditionRoundTrip
	 * @Inputs none
	 * @Return true when both values read 0
	 * @Boundary zero overwrite
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		OwnerOnlyValue = 0;
		SkipReplayValue = 0;

		if (OwnerOnlyValue != 0)
		{
			return false;
		}
		return SkipReplayValue == 0;
	}
}
