/**
 * @version v1
 * @summary The empty-vs-non-empty container contract mask: fourteen query results packed into a single integer so C++ can compare the whole contract at once. An invalid tag yields -1 rather than a mask.
 * @topic Optional
 */
/**
 * @version root
 * @summary The empty-vs-non-empty container contract mask: fourteen query results packed into a single integer so C++ can compare the whole contract at once. An invalid tag yields -1 rather than a mask.
 * @topic Baseline
 */
namespace GameplayTagsTest
{
	/**
	 * Packs fourteen empty/non-empty query results into one mask.
	 *
	 * @Covers GameplayTags.ContainerEmptyContracts
	 * @Inputs a registered tag name
	 * @Return the packed mask, or -1 when the tag is invalid
	 * @Param TagName the tag used to build the non-empty container
	 */
	int ComputeEmptyContractMask(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		if (!ValidTag.IsValid())
		{
			return -1;
		}

		FGameplayTagContainer NonEmptyContainer;
		NonEmptyContainer.AddTag(ValidTag);
		FGameplayTagContainer EmptyContainer;
		FGameplayTag EmptyTag;

		int ResultMask = 0;
		if (NonEmptyContainer.HasAll(EmptyContainer))
		{
			ResultMask |= (1 << 0);
		}
		if (NonEmptyContainer.HasAllExact(EmptyContainer))
		{
			ResultMask |= (1 << 1);
		}
		if (NonEmptyContainer.HasAny(EmptyContainer))
		{
			ResultMask |= (1 << 2);
		}
		if (NonEmptyContainer.HasAnyExact(EmptyContainer))
		{
			ResultMask |= (1 << 3);
		}
		if (EmptyContainer.HasAll(EmptyContainer))
		{
			ResultMask |= (1 << 4);
		}
		if (EmptyContainer.HasAllExact(EmptyContainer))
		{
			ResultMask |= (1 << 5);
		}
		if (EmptyContainer.HasAny(EmptyContainer))
		{
			ResultMask |= (1 << 6);
		}
		if (EmptyContainer.HasAnyExact(EmptyContainer))
		{
			ResultMask |= (1 << 7);
		}
		if (EmptyContainer.HasAll(NonEmptyContainer))
		{
			ResultMask |= (1 << 8);
		}
		if (EmptyContainer.HasAllExact(NonEmptyContainer))
		{
			ResultMask |= (1 << 9);
		}
		if (EmptyContainer.HasAny(NonEmptyContainer))
		{
			ResultMask |= (1 << 10);
		}
		if (EmptyContainer.HasAnyExact(NonEmptyContainer))
		{
			ResultMask |= (1 << 11);
		}
		if (NonEmptyContainer.HasTag(EmptyTag))
		{
			ResultMask |= (1 << 12);
		}
		if (NonEmptyContainer.HasTagExact(EmptyTag))
		{
			ResultMask |= (1 << 13);
		}

		return ResultMask;
	}

	/**
	 * Observe the mask produced for a runner-supplied tag.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerEmptyContracts
	 * @Inputs a valid tag name
	 * @Return the packed mask
	 * @Param TagName the registered tag to use
	 */
	UFUNCTION()
	int EmptyContractMaskNominal(FName TagName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0003 setup: required TagName is None");
		}
		return ComputeEmptyContractMask(TagName);
	}

	/**
	 * Observe that an empty tag and empty container start in their false state.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerEmptyContracts
	 * @Inputs a default tag and a default container
	 * @Return 1 when the tag is invalid and the container is empty
	 * @Boundary empty tag and container
	 */
	UFUNCTION()
	int EmptyTagAndContainerDefaultState()
	{
		FGameplayTag EmptyTag;
		FGameplayTagContainer EmptyContainer;
		if (EmptyTag.IsValid())
		{
			return 0;
		}
		if (!EmptyContainer.IsEmpty())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe the invalid-tag boundary of the mask.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ContainerEmptyContracts
	 * @Inputs a name that is not a registered tag
	 * @Return true when the mask reports -1
	 * @Boundary invalid tag
	 */
	UFUNCTION()
	bool EmptyContractMaskInvalidTagBoundary()
	{
		return ComputeEmptyContractMask(NAME_None) == -1;
	}
}
/** @end */
