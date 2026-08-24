// Theme: Optional.GameplayTags. WorldStory container filter/leaf/parents.
// C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagContainerHierarchyFilters
// ExpectGlobalInt each GPTagFilter_* == 1. Runner supplies ChildName, ParentName,
// UnrelatedName. Extra: Filter against empty container is empty.
// FixtureIsolated.

int GPTagFilter_AddTagFast(FName ChildName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	return ContainerA.HasTagExact(UnrelatedTag) ? 1 : 0;
}

int GPTagFilter_FilterIncludesMatchingTags(FName ChildName, FName ParentName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	ParentContainer.AddTagFast(UnrelatedTag);
	FGameplayTagContainer Filtered = ContainerA.Filter(ParentContainer);
	if (!Filtered.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (!Filtered.HasTagExact(UnrelatedTag))
	{
		return 0;
	}
	return (Filtered.Num() == 2) ? 1 : 0;
}

int GPTagFilter_FilterExactExcludesChild(FName ChildName, FName ParentName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	ParentContainer.AddTagFast(UnrelatedTag);
	FGameplayTagContainer FilteredExact = ContainerA.FilterExact(ParentContainer);
	if (FilteredExact.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (!FilteredExact.HasTagExact(UnrelatedTag))
	{
		return 0;
	}
	return (FilteredExact.Num() == 1) ? 1 : 0;
}

int GPTagFilter_AddLeafTag(FName ChildName, FName ParentName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	ParentContainer.AddTagFast(UnrelatedTag);
	FGameplayTagContainer LeafContainer = ParentContainer;
	if (!LeafContainer.AddLeafTag(ChildTag))
	{
		return 0;
	}
	if (!LeafContainer.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (LeafContainer.HasTagExact(ParentTag))
	{
		return 0;
	}
	if (!LeafContainer.HasTag(ParentTag))
	{
		return 0;
	}
	return (LeafContainer.Num() == 2) ? 1 : 0;
}

int GPTagFilter_LeafFilterExact(FName ChildName, FName ParentName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	ParentContainer.AddTagFast(UnrelatedTag);
	FGameplayTagContainer LeafContainer = ParentContainer;
	LeafContainer.AddLeafTag(ChildTag);
	FGameplayTagContainer LeafFilteredExact = ContainerA.FilterExact(LeafContainer);
	if (!LeafFilteredExact.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (!LeafFilteredExact.HasTagExact(UnrelatedTag))
	{
		return 0;
	}
	return (LeafFilteredExact.Num() == 2) ? 1 : 0;
}

int GPTagFilter_ExpandedParents(FName ChildName, FName ParentName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	FGameplayTagContainer ExpandedParents = ContainerA.GetGameplayTagParents();
	if (!ExpandedParents.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (!ExpandedParents.HasTagExact(ParentTag))
	{
		return 0;
	}
	if (!ExpandedParents.HasTagExact(UnrelatedTag))
	{
		return 0;
	}
	return 1;
}

int GPTagFilter_RemoveTags(FName ChildName, FName UnrelatedName)
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	FGameplayTagContainer RemoveContainer;
	RemoveContainer.AddTag(ChildTag);
	ContainerA.RemoveTags(RemoveContainer);
	if (ContainerA.HasTagExact(ChildTag))
	{
		return 0;
	}
	if (!ContainerA.HasTagExact(UnrelatedTag))
	{
		return 0;
	}
	return (ContainerA.Num() == 1) ? 1 : 0;
}

bool Observe_GameplayTagFilter_Nominal(FName ChildName, FName ParentName, FName UnrelatedName)
{
	if (ChildName.IsNone())
	{
		throw("TS-OPT-0008 setup: required ChildName is None");
	}
	if (ParentName.IsNone())
	{
		throw("TS-OPT-0008 setup: required ParentName is None");
	}
	if (UnrelatedName.IsNone())
	{
		throw("TS-OPT-0008 setup: required UnrelatedName is None");
	}
	return GPTagFilter_AddTagFast(ChildName, UnrelatedName) == 1
		&& GPTagFilter_FilterIncludesMatchingTags(ChildName, ParentName, UnrelatedName) == 1
		&& GPTagFilter_FilterExactExcludesChild(ChildName, ParentName, UnrelatedName) == 1
		&& GPTagFilter_AddLeafTag(ChildName, ParentName, UnrelatedName) == 1
		&& GPTagFilter_LeafFilterExact(ChildName, ParentName, UnrelatedName) == 1
		&& GPTagFilter_ExpandedParents(ChildName, ParentName, UnrelatedName) == 1
		&& GPTagFilter_RemoveTags(ChildName, UnrelatedName) == 1;
}

int Observe_GameplayTagFilter_EmptyContainer(FName ChildName, FName UnrelatedName)
{
	if (ChildName.IsNone())
	{
		throw("TS-OPT-0008 setup: required ChildName is None");
	}
	if (UnrelatedName.IsNone())
	{
		throw("TS-OPT-0008 setup: required UnrelatedName is None");
	}
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	FGameplayTagContainer EmptyContainer;
	FGameplayTagContainer Filtered = ContainerA.Filter(EmptyContainer);
	return Filtered.IsEmpty() ? 1 : 0;
}
