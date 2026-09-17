/**
 * @version v1
 * @summary default SetReplicates/SetReplicateMovement. A spawned actor reports GetIsReplicated and IsReplicatingMovement true; ReplicatedValue is CPF_Net default 1.
 * @topic Definitions
 */
/**
 * @version root
 * @summary default SetReplicates/SetReplicateMovement. A spawned actor reports GetIsReplicated and IsReplicatingMovement true; ReplicatedValue is CPF_Net default 1.
 * @topic Baseline
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
/** @end */
