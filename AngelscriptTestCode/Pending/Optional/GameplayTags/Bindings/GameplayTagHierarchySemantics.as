/**
 * @version v1
 * @summary Hierarchy semantics: a child matching its parent, exact matching excluding the parent, match depth, container queries, direct parent, single-tag container and the parent chain. An unrelated tag must match none of these.
 * @topic Optional
 */
/**
 * @version root
 * @summary Hierarchy semantics: a child matching its parent, exact matching excluding the parent, match depth, container queries, direct parent, single-tag container and the parent chain. An unrelated tag must match none of these.
 * @topic Baseline
 */
namespace GameplayTagsTest
{
	/**
	 * Checks that a child matches its parent.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when MatchesTag reports true
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int ChildMatchesParent(FName ChildName, FName ParentName)
	{
		FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
		FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return ChildTag.MatchesTag(ParentTag) ? 1 : 0;
	}

	/**
	 * Checks that a child does not exactly match its parent.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when MatchesTagExact reports false
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int ChildNotMatchesExactParent(FName ChildName, FName ParentName)
	{
		FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
		FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return ChildTag.MatchesTagExact(ParentTag) ? 0 : 1;
	}

	/**
	 * Checks that the child-to-parent match depth is at least one.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when the depth is positive
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int MatchesTagDepthPositive(FName ChildName, FName ParentName)
	{
		FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
		FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return (ChildTag.MatchesTagDepth(ParentTag) >= 1) ? 1 : 0;
	}

	/**
	 * Checks that a child matches a container holding its parent.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when MatchesAny reports true
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int MatchesAnyParentContainer(FName ChildName, FName ParentName)
	{
		FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
		FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		FGameplayTagContainer ParentContainer;
		ParentContainer.AddTag(ParentTag);
		return ChildTag.MatchesAny(ParentContainer) ? 1 : 0;
	}

	/**
	 * Checks that a child does not exactly match a parent container.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when MatchesAnyExact reports false
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int NotMatchesAnyExactParent(FName ChildName, FName ParentName)
	{
		FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
		FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		FGameplayTagContainer ParentContainer;
		ParentContainer.AddTag(ParentTag);
		return ChildTag.MatchesAnyExact(ParentContainer) ? 0 : 1;
	}

	/**
	 * Checks that a child's direct parent is the parent tag.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when RequestDirectParent returns the parent
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int DirectParentIsParent(FName ChildName, FName ParentName)
	{
		FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(ChildName, true);
		FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return (ChildTag.RequestDirectParent() == ParentTag) ? 1 : 0;
	}

	/**
	 * Checks that a single-tag container holds only the child.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when only the child is present
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int SingleTagContainer(FName ChildName, FName ParentName)
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

	/**
	 * Checks that a child's parent chain holds both child and parent.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and its parent
	 * @Return 1 when both appear in the chain
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 */
	int ParentChainContainsBoth(FName ChildName, FName ParentName)
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

	/**
	 * Checks that an unrelated tag matches none of the hierarchy queries.
	 *
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child and an unrelated tag
	 * @Return 1 when every query reports no match
	 * @Param ChildName the child tag
	 * @Param UnrelatedName the unrelated tag
	 */
	int UnrelatedNotMatched(FName ChildName, FName UnrelatedName)
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

	/**
	 * Observe every hierarchy vector.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child, its parent and an unrelated tag
	 * @Return true when all nine report 1
	 * @Param ChildName the child tag
	 * @Param ParentName the parent tag
	 * @Param UnrelatedName the unrelated tag
	 */
	UFUNCTION()
	bool HierarchyNominal(FName ChildName, FName ParentName, FName UnrelatedName)
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

		if (ChildMatchesParent(ChildName, ParentName) != 1)
		{
			return false;
		}

		if (ChildNotMatchesExactParent(ChildName, ParentName) != 1)
		{
			return false;
		}

		if (MatchesTagDepthPositive(ChildName, ParentName) != 1)
		{
			return false;
		}

		if (MatchesAnyParentContainer(ChildName, ParentName) != 1)
		{
			return false;
		}

		if (NotMatchesAnyExactParent(ChildName, ParentName) != 1)
		{
			return false;
		}

		if (DirectParentIsParent(ChildName, ParentName) != 1)
		{
			return false;
		}

		if (SingleTagContainer(ChildName, ParentName) != 1)
		{
			return false;
		}

		if (ParentChainContainsBoth(ChildName, ParentName) != 1)
		{
			return false;
		}

		return UnrelatedNotMatched(ChildName, UnrelatedName) == 1;
	}

	/**
	 * Observe that an empty tag and empty container match nothing.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.HierarchySemantics
	 * @Inputs a child queried against an empty container and an empty tag
	 * @Return 1 when the tag is invalid and both queries report no match
	 * @Boundary empty tag and container
	 * @Param ChildName the child tag
	 */
	UFUNCTION()
	int HierarchyEmptyContainer(FName ChildName)
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
}
/** @end */
