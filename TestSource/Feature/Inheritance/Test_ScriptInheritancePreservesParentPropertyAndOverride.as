// Theme: Feature.Inheritance. WorldStory parent UPROPERTY flows to child; GetValue override dispatches.
// C++: AngelscriptScriptClassShapeTests.cpp::ScriptInheritancePreservesParentPropertyAndOverride
// Oracle: child CDO/instance ParentValue==21; parent GetValue()==21; child GetValue()==217.
// Extra: empty handle null; ParentValue 0 mutation is copy-independent. FixtureIsolated.
// Keep ParentValue.

UCLASS()
class ATestScriptInheritanceParent : AActor
{
	UPROPERTY()
	int ParentValue = 21;

	UFUNCTION(BlueprintEvent)
	int GetValue()
	{
		return ParentValue;
	}
}

UCLASS()
class ATestScriptInheritanceChild : ATestScriptInheritanceParent
{
	UFUNCTION(BlueprintOverride)
	int GetValue()
	{
		return ParentValue * 10 + 7;
	}
}

bool Observe_ScriptInherit_EmptyHandleIsNull()
{
	ATestScriptInheritanceChild Actor;
	return Actor == nullptr;
}

int Observe_ScriptInherit_ParentValue(ATestScriptInheritanceChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0249 setup: required ATestScriptInheritanceChild is null");
	}
	return Actor.ParentValue;
}

int Observe_ScriptInherit_ParentGetValue(ATestScriptInheritanceParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0249 setup: required ATestScriptInheritanceParent is null");
	}
	return Actor.GetValue();
}

int Observe_ScriptInherit_ChildGetValue(ATestScriptInheritanceChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0249 setup: required ATestScriptInheritanceChild is null");
	}
	return Actor.GetValue();
}

bool Observe_ScriptInherit_CopyIndependence(
	ATestScriptInheritanceChild First,
	ATestScriptInheritanceChild Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0249 setup: required actors are null");
	}
	First.ParentValue = 0;
	return Second.ParentValue == 21 && First.GetValue() == 7;
}
