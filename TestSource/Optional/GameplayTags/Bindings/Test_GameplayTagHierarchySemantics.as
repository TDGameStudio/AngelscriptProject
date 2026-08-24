// Theme: Optional.GameplayTags. WorldStory child/parent/unrelated matching.
// C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagHierarchySemantics
// ExpectGlobalInt each GPTagHier_* == 1. Runner supplies ChildName, ParentName,
// UnrelatedName. Extra: empty container does not MatchesAny; empty tag is invalid.
// FixtureIsolated.

int GPTagHier_ChildMatchesParent(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return ChildTag.MatchesTag(ParentTag) ? 1 : 0;
}

int GPTagHier_ChildNotMatchesExactParent(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return ChildTag.MatchesTagExact(ParentTag) ? 0 : 1;
}

int GPTagHier_MatchesTagDepthPositive(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return (ChildTag.MatchesTagDepth(ParentTag) >= 1) ? 1 : 0;
}

int GPTagHier_MatchesAnyParentContainer(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	return ChildTag.MatchesAny(ParentContainer) ? 1 : 0;
}

int GPTagHier_NotMatchesAnyExactParent(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	return ChildTag.MatchesAnyExact(ParentContainer) ? 0 : 1;
}

int GPTagHier_DirectParentIsParent(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return (ChildTag.RequestDirectParent() == ParentTag) ? 1 : 0;
}

int GPTagHier_SingleTagContainer(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTagContainer SingleTagContainer = ChildTag.GetSingleTagContainer();
	if (SingleTagContainer.Num() != 1)
	{
		return 0;
	}
	if (!SingleTagContainer.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (SingleTagContainer.HasTagExact(ParentTag))
	{
		return 0;
	}
	return 1;
}

int GPTagHier_ParentChainContainsBoth(FName ChildName, FName ParentName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTagContainer ParentChain = ChildTag.GetGameplayTagParents();
	if (!ParentChain.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (!ParentChain.HasTagExact(ParentTag))
	{
		return 0;
	}
	return 1;
}

int GPTagHier_UnrelatedNotMatched(FName ChildName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	if (ChildTag.MatchesTag(UnrelatedTag))
	{
		return 0;
	}
	if (ChildTag.MatchesTagExact(UnrelatedTag))
	{
		return 0;
	}
	if (ChildTag.MatchesTagDepth(UnrelatedTag) != 0)
	{
		return 0;
	}
	FGameplayTagContainer UnrelatedContainer;
	UnrelatedContainer.AddTag(UnrelatedTag);
	if (ChildTag.MatchesAny(UnrelatedContainer))
	{
		return 0;
	}
	if (ChildTag.MatchesAnyExact(UnrelatedContainer))
	{
		return 0;
	}
	FGameplayTagContainer ParentChain = ChildTag.GetGameplayTagParents();
	if (ParentChain.HasTagExact(UnrelatedTag))
	{
		return 0;
	}
	return 1;
}

bool Observe_GameplayTagHierarchy_Nominal(FName ChildName, FName ParentName, FName UnrelatedName)
{
	if (ChildName.IsNone())
	{
		throw("TS-OPT-0007 setup: required ChildName is None");
	}
	if (ParentName.IsNone())
	{
		throw("TS-OPT-0007 setup: required ParentName is None");
	}
	if (UnrelatedName.IsNone())
	{
		throw("TS-OPT-0007 setup: required UnrelatedName is None");
	}
	return GPTagHier_ChildMatchesParent(ChildName, ParentName) == 1
		&& GPTagHier_ChildNotMatchesExactParent(ChildName, ParentName) == 1
		&& GPTagHier_MatchesTagDepthPositive(ChildName, ParentName) == 1
		&& GPTagHier_MatchesAnyParentContainer(ChildName, ParentName) == 1
		&& GPTagHier_NotMatchesAnyExactParent(ChildName, ParentName) == 1
		&& GPTagHier_DirectParentIsParent(ChildName, ParentName) == 1
		&& GPTagHier_SingleTagContainer(ChildName, ParentName) == 1
		&& GPTagHier_ParentChainContainsBoth(ChildName, ParentName) == 1
		&& GPTagHier_UnrelatedNotMatched(ChildName, UnrelatedName) == 1;
}

int Observe_GameplayTagHierarchy_EmptyContainer(FName ChildName)
{
	if (ChildName.IsNone())
	{
		throw("TS-OPT-0007 setup: required ChildName is None");
	}
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTagContainer EmptyContainer;
	FGameplayTag EmptyTag;
	if (EmptyTag.IsValid())
	{
		return 0;
	}
	if (ChildTag.MatchesAny(EmptyContainer))
	{
		return 0;
	}
	if (ChildTag.MatchesAnyExact(EmptyContainer))
	{
		return 0;
	}
	return 1;
}
