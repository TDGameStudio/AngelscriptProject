/**
 * Container hierarchy filters: Filter against a parent container, FilterExact
 * excluding children, leaf-tag addition, expanded parents and bulk removal. The
 * runner supplies a child, its parent and an unrelated tag.
 *
 * @Theme Optional.GameplayTags
 * @Subject GameplayTags.ContainerHierarchyFilters
 * @Harness Function
 * @Tag Optional.GameplayTags.GameplayTagContainerHierarchyFilters
 * @Namespace GameplayTagsTest
 * @Provenance Theme: Optional.GameplayTags. WorldStory container filter/leaf/parents.
 * @Provenance C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagContainerHierarchyFilters
 * @Provenance ExpectGlobalInt each GPTagFilter_* == 1. Runner supplies ChildName, ParentName,
 * @Provenance UnrelatedName. Extra: Filter against empty container is empty.
 * @Provenance FixtureIsolated.
 */

namespace GameplayTagsTest
{
	/**
	 * Checks that AddTagFast stores the tag so exact query finds it.
	 *
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child and an unrelated tag
	 * @Return 1 when the exact query finds the unrelated tag
	 * @Param ChildName the child tag
	 * @Param UnrelatedName the unrelated tag added with AddTagFast
	 */
	int AddTagFastThenQuery(FName ChildName, FName UnrelatedName)
	{
		FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
		FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(UnrelatedName, true);
		FGameplayTagContainer ContainerA;
		ContainerA.AddTag(ChildTag);
		ContainerA.AddTagFast(UnrelatedTag);
		return ContainerA.HasTagExact(UnrelatedTag) ? 1 : 0;
	}

	/**
	 * Checks that Filter keeps both the child and the unrelated tag.
	 *
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child, its parent and an unrelated tag
	 * @Return 1 when the filtered container holds both tags
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 * @Param UnrelatedName the unrelated tag
	 */
	int FilterIncludesMatchingTags(FName ChildName, FName ParentName, FName UnrelatedName)
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

	/**
	 * Checks that FilterExact drops the child and keeps only the exact match.
	 *
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child, its parent and an unrelated tag
	 * @Return 1 when only the unrelated tag survives
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 * @Param UnrelatedName the unrelated tag
	 */
	int FilterExactExcludesChild(FName ChildName, FName ParentName, FName UnrelatedName)
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

	/**
	 * Checks that AddLeafTag replaces the parent with the child.
	 *
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child, its parent and an unrelated tag
	 * @Return 1 when the leaf replaced the parent but hierarchy query still matches
	 * @Param ChildName the leaf tag
	 * @Param ParentName the parent tag
	 * @Param UnrelatedName the unrelated tag
	 */
	int AddLeafTag(FName ChildName, FName ParentName, FName UnrelatedName)
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

	/**
	 * Checks that FilterExact against a leaf container keeps both tags.
	 *
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child, its parent and an unrelated tag
	 * @Return 1 when both tags survive the leaf filter
	 * @Param ChildName the leaf tag
	 * @Param ParentName the parent tag
	 * @Param UnrelatedName the unrelated tag
	 */
	int LeafFilterExact(FName ChildName, FName ParentName, FName UnrelatedName)
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

	/**
	 * Checks that expanding parents yields child, parent and unrelated tags.
	 *
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child, its parent and an unrelated tag
	 * @Return 1 when all three appear in the expanded set
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 * @Param UnrelatedName the unrelated tag
	 */
	int ExpandedParents(FName ChildName, FName ParentName, FName UnrelatedName)
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

	/**
	 * Checks that RemoveTags drops only the listed tag.
	 *
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child and an unrelated tag
	 * @Return 1 when only the unrelated tag remains
	 * @Param ChildName the tag to remove
	 * @Param UnrelatedName the tag that must survive
	 */
	int RemoveTags(FName ChildName, FName UnrelatedName)
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

	/**
	 * Observe every filter vector.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a child, its parent and an unrelated tag
	 * @Return true when all seven report 1
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 * @Param UnrelatedName the unrelated tag
	 */
	UFUNCTION()
	bool HierarchyFilterNominal(FName ChildName, FName ParentName, FName UnrelatedName)
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

		if (AddTagFastThenQuery(ChildName, UnrelatedName) != 1)
		{
			return false;
		}

		if (FilterIncludesMatchingTags(ChildName, ParentName, UnrelatedName) != 1)
		{
			return false;
		}

		if (FilterExactExcludesChild(ChildName, ParentName, UnrelatedName) != 1)
		{
			return false;
		}

		if (AddLeafTag(ChildName, ParentName, UnrelatedName) != 1)
		{
			return false;
		}

		if (LeafFilterExact(ChildName, ParentName, UnrelatedName) != 1)
		{
			return false;
		}

		if (ExpandedParents(ChildName, ParentName, UnrelatedName) != 1)
		{
			return false;
		}

		return RemoveTags(ChildName, UnrelatedName) == 1;
	}

	/**
	 * Observe that filtering against an empty container yields nothing.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerHierarchyFilters
	 * @Inputs a populated container filtered against an empty one
	 * @Return 1 when the result is empty
	 * @Boundary empty filter
	 * @Param ChildName the child tag
	 * @Param UnrelatedName the unrelated tag
	 */
	UFUNCTION()
	int FilterAgainstEmptyContainer(FName ChildName, FName UnrelatedName)
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
}
