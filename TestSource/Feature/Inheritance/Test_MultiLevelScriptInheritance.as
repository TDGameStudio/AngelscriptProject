// Theme: Feature.Inheritance. WorldStory multi-level script inheritance + BP child CDO.
// C++: AngelscriptBlueprintChildTests.cpp::MultiLevelScriptInheritance
// Oracle: GrandParentValue==100; GetGrandParentValue()==100; GetParentValue()==200;
// child BeginPlay writes BeginPlayChain==10 (no Super).
// Extra: empty handle null; default BeginPlayChain 0. FixtureIsolated.
// Keep GrandParentValue/BeginPlayChain/ParentValue.

UCLASS()
class ATestBPMultiLevelGrandParent : AActor
{
	UPROPERTY()
	int GrandParentValue = 100;

	UPROPERTY()
	int BeginPlayChain = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayChain += 1;
	}

	UFUNCTION()
	int GetGrandParentValue()
	{
		return GrandParentValue;
	}
}

UCLASS()
class ATestBPMultiLevelParent : ATestBPMultiLevelGrandParent
{
	UPROPERTY()
	int ParentValue = 200;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayChain += 10;
	}

	UFUNCTION()
	int GetParentValue()
	{
		return ParentValue;
	}
}

bool Observe_MultiLevel_EmptyHandleIsNull()
{
	ATestBPMultiLevelParent Actor;
	return Actor == nullptr;
}

int Observe_MultiLevel_GrandParentDefault(ATestBPMultiLevelParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0181 setup: required ATestBPMultiLevelParent is null");
	}
	return Actor.GetGrandParentValue();
}

int Observe_MultiLevel_ParentDefault(ATestBPMultiLevelParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0181 setup: required ATestBPMultiLevelParent is null");
	}
	return Actor.GetParentValue();
}

int Observe_MultiLevel_BeginPlayChainBefore(ATestBPMultiLevelParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0181 setup: required ATestBPMultiLevelParent is null");
	}
	return Actor.BeginPlayChain;
}

int Observe_MultiLevel_BeginPlayChainAfter(ATestBPMultiLevelParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0181 setup: required ATestBPMultiLevelParent is null");
	}
	return Actor.BeginPlayChain;
}

bool Observe_MultiLevel_CopyIndependence(
	ATestBPMultiLevelParent First,
	ATestBPMultiLevelParent Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0181 setup: required actors are null");
	}
	First.GrandParentValue = 0;
	First.ParentValue = 0;
	return Second.GrandParentValue == 100 && Second.ParentValue == 200;
}
