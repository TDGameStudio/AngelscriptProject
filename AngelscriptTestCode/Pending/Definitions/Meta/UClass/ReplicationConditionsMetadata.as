/**
 * @version v1
 * @summary ReplicationCondition names on Replicated properties. Defaults are 1 through 13 for InitialOnlyValue through SkipReplayValue. COND_Never is omitted because it is rejected by the parser.
 * @topic Definitions
 */
/**
 * @version root
 * @summary ReplicationCondition names on Replicated properties. Defaults are 1 through 13 for InitialOnlyValue through SkipReplayValue. COND_Never is omitted because it is rejected by the parser.
 * @topic Baseline
 */
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

	/**
	 * Observe the InitialOnlyValue default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationConditionsMetadata
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int InitialOnlyDefault()
	{
		return InitialOnlyValue;
	}

	/**
	 * Observe the SkipReplayValue default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationConditionsMetadata
	 * @Inputs none
	 * @Return 13
	 */
	UFUNCTION()
	int SkipReplayDefault()
	{
		return SkipReplayValue;
	}

	/**
	 * Observe the sum of every declared condition default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationConditionsMetadata
	 * @Inputs none
	 * @Return 91
	 */
	UFUNCTION()
	int SumDefaults()
	{
		return InitialOnlyValue + OwnerOnlyValue + SkipOwnerValue
			+ SimulatedOnlyValue + AutonomousOnlyValue + SimulatedOrPhysicsValue
			+ InitialOrOwnerValue + CustomValue + ReplayOrOwnerValue
			+ ReplayOnlyValue + SimulatedOnlyNoReplayValue
			+ SimulatedOrPhysicsNoReplayValue + SkipReplayValue;
	}

	/**
	 * Observe that writing zero to CustomValue is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationConditionsMetadata
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero CustomValue
	 */
	UFUNCTION()
	int ZeroCustomBoundary()
	{
		CustomValue = 0;
		return CustomValue;
	}

	/**
	 * Observe that writing this instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationConditionsMetadata
	 * @Inputs a second actor
	 * @Return true when this reads 0 and the other still reads 1
	 * @Param Second the other actor, expected to keep InitialOnlyValue 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageNetworkingConditionsActor Second)
	{
		if (Second is null)
		{
			throw("ReplicationConditionsMetadata setup: required Second is null");
		}
		InitialOnlyValue = 0;
		Second.InitialOnlyValue = 1;
		if (InitialOnlyValue != 0)
		{
			return false;
		}
		return Second.InitialOnlyValue == 1;
	}
}
/** @end */
