/**
 * @version v1
 * @summary Inherited Replicated and ReplicatedUsing properties. C++ verifies parent/child compile, ParentReplicatedValue COND_None, ParentTrackedValue RepNotify OnRep_ParentTrackedValue, and child OwnerOnly/SkipOwner RepNotify.
 * @topic Feature
 */
/**
 * @version root
 * @summary Inherited Replicated and ReplicatedUsing properties. C++ verifies parent/child compile, ParentReplicatedValue COND_None, ParentTrackedValue RepNotify OnRep_ParentTrackedValue, and child OwnerOnly/SkipOwner RepNotify.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingReplicationParent : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int ParentReplicatedValue = 11;

	UPROPERTY(ReplicatedUsing=OnRep_ParentTrackedValue)
	int ParentTrackedValue = 12;

	/**
	 * RepNotify for ParentTrackedValue.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritedReplicationLifetimeList
	 * @Inputs none
	 * @Return none; generated RepNotify for ParentTrackedValue
	 */
	UFUNCTION()
	void OnRep_ParentTrackedValue()
	{
	}

	/**
	 * Observe parent replicated defaults packed as ParentReplicatedValue*100 + ParentTrackedValue.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritedReplicationLifetimeList
	 * @Inputs a freshly constructed parent
	 * @Return 1112
	 */
	UFUNCTION()
	int ParentDefault()
	{
		return ParentReplicatedValue * 100 + ParentTrackedValue;
	}
}

UCLASS()
class ACoverageNetworkingReplicationChild : ACoverageNetworkingReplicationParent
{
	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int ChildOwnerOnlyValue = 21;

	UPROPERTY(ReplicatedUsing=OnRep_ChildTrackedValue, ReplicationCondition=SkipOwner)
	int ChildTrackedValue = 22;

	/**
	 * RepNotify for ChildTrackedValue.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritedReplicationLifetimeList
	 * @Inputs none
	 * @Return none; generated RepNotify for ChildTrackedValue
	 */
	UFUNCTION()
	void OnRep_ChildTrackedValue()
	{
	}

	/**
	 * Observe child defaults packed as Parent*1000 + OwnerOnly*10 + Tracked.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritedReplicationLifetimeList
	 * @Inputs a freshly constructed child
	 * @Return 11232
	 */
	UFUNCTION()
	int ChildDefaults()
	{
		return ParentReplicatedValue * 1000 + ChildOwnerOnlyValue * 10 + ChildTrackedValue;
	}

	/**
	 * Observe zeroing the replicated values on this child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritedReplicationLifetimeList
	 * @Inputs ParentReplicatedValue, ChildOwnerOnlyValue and ChildTrackedValue set to 0
	 * @Return the sum of those three values, expected to be 0
	 * @Boundary zero assign
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		ParentReplicatedValue = 0;
		ChildOwnerOnlyValue = 0;
		ChildTrackedValue = 0;
		return ParentReplicatedValue + ChildOwnerOnlyValue + ChildTrackedValue;
	}

	/**
	 * Observe that writing ParentReplicatedValue on this child leaves another child untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritedReplicationLifetimeList
	 * @Inputs this child plus a second child
	 * @Return true when this is 0 and the other stays 11
	 * @Param Second the other child, expected to stay at ParentReplicatedValue 11
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageNetworkingReplicationChild Second)
	{
		if (Second == nullptr)
		{
			throw("InheritedReplicationLifetimeList setup: required Second is null");
		}
		ParentReplicatedValue = 0;
		if (ParentReplicatedValue != 0)
		{
			return false;
		}
		return Second.ParentReplicatedValue == 11;
	}
}
/** @end */
