// Theme: Optional.GameplayTags. WorldStory empty-vs-non-empty container mask.
// C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagContainerEmptyContracts
// ExpectGlobalInt is a native/script mask compare; ComputeMask is the value oracle.
// CSV WorldStory. Runner supplies TagName. Extra: empty tag and empty container
// vectors are already inside the mask; invalid tag returns -1.
// FixtureIsolated.

int GPTagEmptyContract_ComputeMask(FName TagName)
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

int Observe_GPTagEmptyContract_Nominal(FName TagName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0003 setup: required TagName is None");
	}
	return GPTagEmptyContract_ComputeMask(TagName);
}

int Observe_GPTagEmptyContract_EmptyTagAndContainer()
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
