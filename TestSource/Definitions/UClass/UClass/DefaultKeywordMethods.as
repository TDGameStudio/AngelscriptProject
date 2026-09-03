/**
 * default SetReplicates/SetReplicateMovement. A spawned actor reports
 * GetIsReplicated and IsReplicatingMovement true; ReplicatedValue is CPF_Net
 * default 1.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.DefaultKeywordMethods
 * @Harness UClass
 * @Tag Definitions.UClass.DefaultKeywordMethods
 * @Provenance Theme: Definitions.UClass. WorldStory default SetReplicates/SetReplicateMovement.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::DefaultKeywordMethods
 * @Provenance Oracle: spawned actor GetIsReplicated true, IsReplicatingMovement true; ReplicatedValue is CPF_Net default 1.
 * @Provenance Extra: unset handle is null; ReplicatedValue 0 is the false/zero boundary. FixtureIsolated.
 */

UCLASS()
class ACoverageClassFeaturesDefaultMethodActor : AActor
{
	UPROPERTY(Replicated)
	int ReplicatedValue = 1;

	default SetReplicates(true);
	default SetReplicateMovement(true);

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultKeyword
	 * @Inputs an unset ACoverageClassFeaturesDefaultMethodActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageClassFeaturesDefaultMethodActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the ReplicatedValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultKeyword
	 * @Inputs a freshly constructed actor
	 * @Return ReplicatedValue
	 */
	UFUNCTION()
	int ReplicatedValueDefault()
	{
		return ReplicatedValue;
	}

	/**
	 * Observe writing ReplicatedValue to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultKeyword
	 * @Inputs ReplicatedValue set to 0
	 * @Return true when ReplicatedValue is 0
	 * @Boundary zero
	 */
	UFUNCTION()
	bool ReplicatedValueZeroBoundary()
	{
		ReplicatedValue = 0;
		return ReplicatedValue == 0;
	}
}
