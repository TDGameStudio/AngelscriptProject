/**
 * @version v1
 * @summary Static replication surface with ReplicatedUsing and conditions. Defaults are UnconditionalValue 1 through CustomValue 8. OnRep_TrackedValue is a no-op.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Static replication surface with ReplicatedUsing and conditions. Defaults are UnconditionalValue 1 through CustomValue 8. OnRep_TrackedValue is a no-op.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingStaticReplicationActor : AActor
{
	default SetReplicates(true);
	default SetReplicateMovement(true);

	UPROPERTY(Replicated)
	int UnconditionalValue = 1;

	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue)
	int TrackedValue = 2;

	UPROPERTY(Replicated, ReplicationCondition=InitialOnly)
	int InitialOnlyValue = 3;

	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int OwnerOnlyValue = 4;

	UPROPERTY(Replicated, ReplicationCondition=SkipOwner)
	int SkipOwnerValue = 5;

	UPROPERTY(Replicated, ReplicationCondition=AutonomousOnly)
	int AutonomousOnlyValue = 6;

	UPROPERTY(Replicated, ReplicationCondition=ReplayOrOwner)
	int ReplayOrOwnerValue = 7;

	UPROPERTY(Replicated, ReplicationCondition=Custom)
	int CustomValue = 8;

	/**
	 * The ReplicatedUsing callback; a no-op that still has to exist for the specifier.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationMetadataStaticSurface
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_TrackedValue()
	{
	}

	/**
	 * Observe the UnconditionalValue default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationMetadataStaticSurface
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int UnconditionalDefault()
	{
		return UnconditionalValue;
	}

	/**
	 * Observe the TrackedValue default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationMetadataStaticSurface
	 * @Inputs none
	 * @Return 2
	 */
	UFUNCTION()
	int TrackedValueDefault()
	{
		return TrackedValue;
	}

	/**
	 * Observe the CustomValue default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationMetadataStaticSurface
	 * @Inputs none
	 * @Return 8
	 */
	UFUNCTION()
	int CustomValueDefault()
	{
		return CustomValue;
	}

	/**
	 * Observe that writing zero TrackedValue then calling OnRep is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationMetadataStaticSurface
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero TrackedValue
	 */
	UFUNCTION()
	int ZeroTrackedBoundary()
	{
		TrackedValue = 0;
		OnRep_TrackedValue();
		return TrackedValue;
	}

	/**
	 * Observe that writing this instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReplicationMetadataStaticSurface
	 * @Inputs a second actor
	 * @Return true when this reads 9 and the other still reads 2
	 * @Param Second the other actor, expected to keep TrackedValue 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageNetworkingStaticReplicationActor Second)
	{
		if (Second is null)
		{
			throw("ReplicationMetadataStaticSurface setup: required Second is null");
		}
		TrackedValue = 9;
		Second.TrackedValue = 2;
		if (TrackedValue != 9)
		{
			return false;
		}
		return Second.TrackedValue == 2;
	}
}
/** @end */
