/**
 * Inherited plus child replicated UPROPERTY surface. C++ verifies ParentValue 7,
 * ChildValue 11, ChildNotifiedValue 29 and OnRep_ChildNotifiedValue exists.
 * Zeroing a copy is independent of a second instance.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
 * @Harness UClass
 * @Tag Feature.Inheritance.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
 * @Provenance Theme: Feature.Inheritance. WorldStory inherited + child replicated UPROPERTY surface.
 * @Provenance C++: AngelscriptASClassReplicationTests.cpp::LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
 * @Provenance Oracle: ParentValue default 7, ChildValue 11, ChildNotifiedValue 29; OnRep_ChildNotifiedValue exists.
 * @Provenance Extra: empty handle null; zeros on a mutated copy; OnRep is a no-op. FixtureIsolated.
 * @Provenance Keep ParentValue/ChildValue/ChildNotifiedValue.
 */

UCLASS()
class AReplicationParent : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int ParentValue = 7;

	/**
	 * Observe the parent replicated default.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
	 * @Inputs a freshly constructed parent
	 * @Return ParentValue, expected to be 7
	 */
	UFUNCTION()
	int ParentDefault()
	{
		return ParentValue;
	}
}

UCLASS()
class AReplicationChild : AReplicationParent
{
	UPROPERTY(Replicated)
	int ChildValue = 11;

	UPROPERTY(ReplicatedUsing=OnRep_ChildNotifiedValue)
	int ChildNotifiedValue = 29;

	/**
	 * RepNotify for ChildNotifiedValue.
	 *
	 * @Kind Action
	 * @Covers Inheritance.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
	 * @Inputs none
	 * @Return none; generated RepNotify for ChildNotifiedValue
	 */
	UFUNCTION()
	void OnRep_ChildNotifiedValue()
	{
	}

	/**
	 * Observe inherited and child replicated defaults.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
	 * @Inputs a freshly constructed child
	 * @Return true when ParentValue is 7, ChildValue is 11 and ChildNotifiedValue is 29
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (ParentValue != 7)
		{
			return false;
		}
		if (ChildValue != 11)
		{
			return false;
		}
		return ChildNotifiedValue == 29;
	}

	/**
	 * Observe that zeroing this child leaves another child at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties
	 * @Inputs this child plus a second child
	 * @Return true when the other stays 7/11/29
	 * @Param Second the other child, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AReplicationChild Second)
	{
		if (Second == nullptr)
		{
			throw("LifetimeScriptReplicationListIncludesInheritedReplicatedProperties setup: required Second is null");
		}
		ParentValue = 0;
		ChildValue = 0;
		ChildNotifiedValue = 0;
		OnRep_ChildNotifiedValue();
		if (Second.ParentValue != 7)
		{
			return false;
		}
		if (Second.ChildValue != 11)
		{
			return false;
		}
		return Second.ChildNotifiedValue == 29;
	}
}
