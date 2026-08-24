// Theme: Optional.GameplayTags. WorldStory/container values for FGameplayTagContainer.
// C++ functions return 1. Runner supplies TagName. Extra: empty container is
// already GPTagContainer_Empty*; reset after add is the boundary.
// FixtureIsolated.

int GPTagContainer_EmptyIsEmpty()
{
	FGameplayTagContainer EmptyDefault;
	return EmptyDefault.IsEmpty() ? 1 : 0;
}

int GPTagContainer_EmptyEqualsEmptyContainer()
{
	FGameplayTagContainer EmptyDefault;
	return (EmptyDefault == FGameplayTagContainer::EmptyContainer) ? 1 : 0;
}

int GPTagContainer_AddTagMakesValid(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	return Tags.IsValid() ? 1 : 0;
}

int GPTagContainer_NumAfterAdd(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	return (Tags.Num() == 1) ? 1 : 0;
}

int GPTagContainer_HasTag(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	return Tags.HasTag(ValidTag) ? 1 : 0;
}

int GPTagContainer_HasTagExact(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	return Tags.HasTagExact(ValidTag) ? 1 : 0;
}

int GPTagContainer_First(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	return (Tags.First() == ValidTag) ? 1 : 0;
}

int GPTagContainer_HasAnyAndAll(FName TagName)
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

int GPTagContainer_AppendTags(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagContainer Combined;
	Combined.AppendTags(Tags);
	return Combined.HasTag(ValidTag) ? 1 : 0;
}

int GPTagContainer_RemoveTag(FName TagName)
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

int GPTagContainer_Reset(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Combined;
	Combined.AddTag(ValidTag);
	Combined.Reset();
	return Combined.IsEmpty() ? 1 : 0;
}

bool Observe_GameplayTagContainer_Nominal(FName TagName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0002 setup: required TagName is None");
	}
	return GPTagContainer_EmptyIsEmpty() == 1
		&& GPTagContainer_EmptyEqualsEmptyContainer() == 1
		&& GPTagContainer_AddTagMakesValid(TagName) == 1
		&& GPTagContainer_NumAfterAdd(TagName) == 1
		&& GPTagContainer_HasTag(TagName) == 1
		&& GPTagContainer_HasTagExact(TagName) == 1
		&& GPTagContainer_First(TagName) == 1
		&& GPTagContainer_HasAnyAndAll(TagName) == 1
		&& GPTagContainer_AppendTags(TagName) == 1
		&& GPTagContainer_RemoveTag(TagName) == 1
		&& GPTagContainer_Reset(TagName) == 1;
}

bool Observe_GameplayTagContainer_Empty()
{
	return GPTagContainer_EmptyIsEmpty() == 1
		&& GPTagContainer_EmptyEqualsEmptyContainer() == 1;
}

bool Observe_GameplayTagContainer_HasAnyEmpty(FName TagName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0002 setup: required TagName is None");
	}
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagContainer EmptyOthers;
	return !Tags.HasAny(EmptyOthers) && !Tags.HasAnyExact(EmptyOthers);
}
