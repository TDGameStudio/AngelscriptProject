/**
 * @version v1
 * @summary A default statement on a Replicated bool. The CDO value is true after `default bReplicates = true`, even though the inline initializer is false. Instances stay independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement on a Replicated bool. The CDO value is true after `default bReplicates = true`, even though the inline initializer is false. Instances stay independent.
 * @topic Baseline
 */
class AAttrRepActor : AActor
{
	UPROPERTY(Replicated)
	bool bReplicates = false;

	default bReplicates = true;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.ReplicatedProperty
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrRepActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that the default statement sets the replicated flag.
	 *
	 * @Kind Observe
	 * @Covers Default.ReplicatedProperty
	 * @Inputs a freshly constructed actor
	 * @Return true when bReplicates is true
	 */
	UFUNCTION()
	bool DefaultTrue()
	{
		return bReplicates;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.ReplicatedProperty
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when the other still holds true
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(AAttrRepActor Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultReplicatedProperty setup: required Second is null");
		}
		bReplicates = false;
		return Second.bReplicates;
	}
}
/** @end */
