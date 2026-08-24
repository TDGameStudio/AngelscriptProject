// Theme: Feature.Inheritance. WorldStory inherited + child replicated UPROPERTY surface.
// C++: AngelscriptASClassReplicationTests.cpp::LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
// Oracle: ParentValue default 7, ChildValue 11, ChildNotifiedValue 29; OnRep_ChildNotifiedValue exists.
// Extra: empty handle null; zeros on a mutated copy; OnRep is a no-op. FixtureIsolated.
// Keep ParentValue/ChildValue/ChildNotifiedValue.

UCLASS()
class AReplicationParent : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int ParentValue = 7;
}

UCLASS()
class AReplicationChild : AReplicationParent
{
	UPROPERTY(Replicated)
	int ChildValue = 11;

	UPROPERTY(ReplicatedUsing=OnRep_ChildNotifiedValue)
	int ChildNotifiedValue = 29;

	UFUNCTION()
	void OnRep_ChildNotifiedValue()
	{
	}
}

bool Observe_ReplicationList_EmptyHandleIsNull()
{
	AReplicationChild Actor;
	return Actor == nullptr;
}

bool Observe_ReplicationList_Defaults(AReplicationChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0235 setup: required AReplicationChild is null");
	}
	return Actor.ParentValue == 7 && Actor.ChildValue == 11 && Actor.ChildNotifiedValue == 29;
}

int Observe_ReplicationList_ParentDefault(AReplicationParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0235 setup: required AReplicationParent is null");
	}
	return Actor.ParentValue;
}

bool Observe_ReplicationList_CopyIndependence(
	AReplicationChild First,
	AReplicationChild Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0235 setup: required actors are null");
	}
	First.ParentValue = 0;
	First.ChildValue = 0;
	First.ChildNotifiedValue = 0;
	First.OnRep_ChildNotifiedValue();
	return Second.ParentValue == 7 && Second.ChildValue == 11 && Second.ChildNotifiedValue == 29;
}
