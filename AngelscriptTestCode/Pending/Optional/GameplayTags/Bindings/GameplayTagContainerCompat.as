/**
 * @version v1
 * @summary GameplayTagContainer compatibility: the empty-container vectors plus the add/query/append/remove/reset surface. The runner supplies a valid tag name.
 * @topic Optional
 */
/**
 * @version root
 * @summary GameplayTagContainer compatibility: the empty-container vectors plus the add/query/append/remove/reset surface. The runner supplies a valid tag name.
 * @topic Baseline
 */
namespace GameplayTagsTest
{
	/**
	 * Checks that a default container is empty.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs none
	 * @Return 1 when the container is empty
	 */
	int EmptyContainerIsEmpty()
	{
		FGameplayTagContainer EmptyDefault;
		return EmptyDefault.IsEmpty() ? 1 : 0;
	}

	/**
	 * Checks that a default container equals the empty container singleton.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs none
	 * @Return 1 when the two are equal
	 */
	int EmptyContainerEqualsSingleton()
	{
		FGameplayTagContainer EmptyDefault;
		return (EmptyDefault == FGameplayTagContainer::EmptyContainer) ? 1 : 0;
	}

	/**
	 * Checks that adding a tag makes the container valid.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the container is valid
	 * @Param TagName the tag to add
	 */
	int AddTagMakesValid(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		return Tags.IsValid() ? 1 : 0;
	}

	/**
	 * Checks the element count after one add.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the count is one
	 * @Param TagName the tag to add
	 */
	int NumAfterAdd(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		return (Tags.Num() == 1) ? 1 : 0;
	}

	/**
	 * Checks that a container reports having its own tag.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when HasTag reports true
	 * @Param TagName the tag to add and query
	 */
	int HasTagAfterAdd(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		return Tags.HasTag(ValidTag) ? 1 : 0;
	}

	/**
	 * Checks that a container reports an exact match for its own tag.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when HasTagExact reports true
	 * @Param TagName the tag to add and query
	 */
	int HasTagExactAfterAdd(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		return Tags.HasTagExact(ValidTag) ? 1 : 0;
	}

	/**
	 * Checks that the first element is the added tag.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when First matches the added tag
	 * @Param TagName the tag to add
	 */
	int FirstMatchesAddedTag(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		return (Tags.First() == ValidTag) ? 1 : 0;
	}

	/**
	 * Checks the four any/all query forms against an identical container.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when all four queries report true
	 * @Param TagName the tag shared by both containers
	 */
	int HasAnyAndAll(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagContainer Others;
		Others.AddTag(ValidTag);

		if (!Tags.HasAny(Others))
		{
			return 0;
		}
		if (!Tags.HasAnyExact(Others))
		{
			return 0;
		}
		if (!Tags.HasAll(Others))
		{
			return 0;
		}
		if (!Tags.HasAllExact(Others))
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Checks that appending one container into another carries its tags.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the target gained the tag
	 * @Param TagName the tag to append
	 */
	int AppendTags(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagContainer Combined;
		Combined.AppendTags(Tags);
		return Combined.HasTag(ValidTag) ? 1 : 0;
	}

	/**
	 * Checks that removing the only tag leaves the container empty.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when removal succeeded and the container is empty
	 * @Param TagName the tag to add and remove
	 */
	int RemoveTag(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Combined;
		Combined.AddTag(ValidTag);
		if (!Combined.RemoveTag(ValidTag))
		{
			return 0;
		}
		return Combined.IsEmpty() ? 1 : 0;
	}

	/**
	 * Checks that resetting a populated container empties it.
	 *
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the container is empty after reset
	 * @Param TagName the tag to add before resetting
	 */
	int ResetAfterAdd(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Combined;
		Combined.AddTag(ValidTag);
		Combined.Reset();
		return Combined.IsEmpty() ? 1 : 0;
	}

	/**
	 * Observe every container vector including the runner-supplied tag.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a valid tag name plus all container vectors
	 * @Return true when all eleven report 1
	 * @Param TagName the registered tag to use
	 */
	UFUNCTION()
	bool GameplayTagContainerNominal(FName TagName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0002 setup: required TagName is None");
		}

		if (EmptyContainerIsEmpty() != 1)
		{
			return false;
		}

		if (EmptyContainerEqualsSingleton() != 1)
		{
			return false;
		}

		if (AddTagMakesValid(TagName) != 1)
		{
			return false;
		}

		if (NumAfterAdd(TagName) != 1)
		{
			return false;
		}

		if (HasTagAfterAdd(TagName) != 1)
		{
			return false;
		}

		if (HasTagExactAfterAdd(TagName) != 1)
		{
			return false;
		}

		if (FirstMatchesAddedTag(TagName) != 1)
		{
			return false;
		}

		if (HasAnyAndAll(TagName) != 1)
		{
			return false;
		}

		if (AppendTags(TagName) != 1)
		{
			return false;
		}

		if (RemoveTag(TagName) != 1)
		{
			return false;
		}

		return ResetAfterAdd(TagName) == 1;
	}

	/**
	 * Observe the empty-container vectors without needing a registered tag.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs both empty-container vectors
	 * @Return true when both report 1
	 * @Boundary empty container
	 */
	UFUNCTION()
	bool GameplayTagContainerEmpty()
	{
		if (EmptyContainerIsEmpty() != 1)
		{
			return false;
		}

		return EmptyContainerEqualsSingleton() == 1;
	}

	/**
	 * Observe that any-query against an empty container is false.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerCompat
	 * @Inputs a populated container queried against an empty one
	 * @Return true when both any-queries report false
	 * @Boundary empty other
	 * @Param TagName the registered tag to add
	 */
	UFUNCTION()
	bool HasAnyAgainstEmptyIsFalse(FName TagName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0002 setup: required TagName is None");
		}
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagContainer EmptyOthers;

		if (Tags.HasAny(EmptyOthers))
		{
			return false;
		}

		return !Tags.HasAnyExact(EmptyOthers);
	}
}
/** @end */
