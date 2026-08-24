// Theme: Feature.Inheritance. WorldStory inherited Replicated / ReplicatedUsing properties.
// C++: AngelscriptCoverageNetworkingTests.cpp::InheritedReplicationLifetimeList
// sha256=745e7aa924ca31c0cfe4b981062c704e1860a5477f31f6056d5f33b4bcc510bd; lines 411-443.
// Oracle: parent/child compile; ParentReplicatedValue COND_None; ParentTrackedValue RepNotify
// OnRep_ParentTrackedValue; child OwnerOnly and SkipOwner RepNotify generated.
// Extra: defaults 11/12/21/22; zero assign; two locals independent. FixtureIsolated.

UCLASS()
class ACoverageNetworkingReplicationParent : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int ParentReplicatedValue = 11;

	UPROPERTY(ReplicatedUsing=OnRep_ParentTrackedValue)
	int ParentTrackedValue = 12;

	UFUNCTION()
	void OnRep_ParentTrackedValue()
	{
	}
}

UCLASS()
class ACoverageNetworkingReplicationChild : ACoverageNetworkingReplicationParent
{
	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int ChildOwnerOnlyValue = 21;

	UPROPERTY(ReplicatedUsing=OnRep_ChildTrackedValue, ReplicationCondition=SkipOwner)
	int ChildTrackedValue = 22;

	UFUNCTION()
	void OnRep_ChildTrackedValue()
	{
	}
}

int Observe_Replication_ParentDefault(ACoverageNetworkingReplicationParent Parent)
{
	if (Parent is null)
	{
		throw("Test_InheritedReplicationLifetimeList setup: required Parent is null");
	}
	return Parent.ParentReplicatedValue * 100 + Parent.ParentTrackedValue;
}

int Observe_Replication_ChildDefaults(ACoverageNetworkingReplicationChild Child)
{
	if (Child is null)
	{
		throw("Test_InheritedReplicationLifetimeList setup: required Child is null");
	}
	return Child.ParentReplicatedValue * 1000 + Child.ChildOwnerOnlyValue * 10 + Child.ChildTrackedValue;
}

int Observe_Replication_ZeroBoundary(ACoverageNetworkingReplicationChild Child)
{
	if (Child is null)
	{
		throw("Test_InheritedReplicationLifetimeList setup: required Child is null");
	}
	Child.ParentReplicatedValue = 0;
	Child.ChildOwnerOnlyValue = 0;
	Child.ChildTrackedValue = 0;
	return Child.ParentReplicatedValue + Child.ChildOwnerOnlyValue + Child.ChildTrackedValue;
}

bool Observe_Replication_TwoLocalsIndependent(ACoverageNetworkingReplicationChild First, ACoverageNetworkingReplicationChild Second)
{
	if (First is null)
	{
		throw("Test_InheritedReplicationLifetimeList setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_InheritedReplicationLifetimeList setup: required Second is null");
	}
	First.ParentReplicatedValue = 0;
	return First.ParentReplicatedValue == 0 && Second.ParentReplicatedValue == 11;
}
