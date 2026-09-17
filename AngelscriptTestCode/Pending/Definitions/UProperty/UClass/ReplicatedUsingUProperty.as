/**
 * @version v1
 * @summary ReplicatedUsing = OnRep_Health compiles with an empty notify. The empty sibling carries Health 0; OnRep_Health remains a no-op.
 * @topic Definitions
 */
/**
 * @version root
 * @summary ReplicatedUsing = OnRep_Health compiles with an empty notify. The empty sibling carries Health 0; OnRep_Health remains a no-op.
 * @topic Baseline
 */
class AUPropRepUsingActor : AActor
{
	UPROPERTY(ReplicatedUsing = OnRep_Health)
	int Health = 100;

	/**
	 * Empty replication notify required by ReplicatedUsing.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ReplicatedUsingUProperty
	 * @Inputs none
	 * @Return void; no-op
	 */
	UFUNCTION()
	void OnRep_Health()
	{
	}

	/**
	 * Observe the default Health of 100.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ReplicatedUsingUProperty
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	int DefaultHealth()
	{
		return 100;
	}

	/**
	 * Observe that empty Health 0 is independent of the 100 default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ReplicatedUsingUProperty
	 * @Inputs local Health 100 and EmptyHealth 0
	 * @Return 0 when the empty value differs, otherwise -1
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyHealthIndependent()
	{
		int Health = 100;
		int EmptyHealth = 0;
		return EmptyHealth != Health ? EmptyHealth : -1;
	}
}

/**
 * The sibling that keeps Health 0.
 *
 * @Covers UProperty.ReplicatedUsingUProperty
 * @Inputs none
 * @Return an actor with Health 0
 * @Boundary empty sibling
 */
class AUPropRepUsingActorEmpty : AActor
{
	UPROPERTY(ReplicatedUsing = OnRep_Health)
	int Health = 0;

	/**
	 * Empty replication notify required by ReplicatedUsing.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ReplicatedUsingUProperty
	 * @Inputs none
	 * @Return void; no-op
	 */
	UFUNCTION()
	void OnRep_Health()
	{
	}
}
/** @end */
