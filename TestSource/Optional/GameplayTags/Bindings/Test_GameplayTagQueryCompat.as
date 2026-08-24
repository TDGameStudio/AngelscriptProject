// Theme: Optional.GameplayTags. WorldStory FGameplayTagQuery factories and matching.
// C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagQueryCompat
// ExpectGlobalInt each GPTagQuery_* == 1. Runner supplies TagName.
// Extra: empty default query; empty container does not match MatchTag.
// FixtureIsolated.

int GPTagQuery_EmptyDefault()
{
	FGameplayTagQuery EmptyDefault;
	if (!EmptyDefault.IsEmpty())
	{
		return 0;
	}
	return (EmptyDefault == FGameplayTagQuery::EmptyQuery) ? 1 : 0;
}

int GPTagQuery_MatchAnyNotEmpty(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
	return MatchAny.IsEmpty() ? 0 : 1;
}

int GPTagQuery_MatchAllNotEmpty(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagQuery MatchAll = FGameplayTagQuery::MakeQuery_MatchAllTags(Tags);
	return MatchAll.IsEmpty() ? 0 : 1;
}

int GPTagQuery_MatchNoneNotEmpty(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagQuery MatchNone = FGameplayTagQuery::MakeQuery_MatchNoTags(Tags);
	return MatchNone.IsEmpty() ? 0 : 1;
}

int GPTagQuery_MatchTagNotEmpty(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
	return MatchTag.IsEmpty() ? 0 : 1;
}

int GPTagQuery_DifferentQueriesNotEqual(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
	FGameplayTagQuery MatchAll = FGameplayTagQuery::MakeQuery_MatchAllTags(Tags);
	return (MatchAny == MatchAll) ? 0 : 1;
}

int GPTagQuery_CopyEquality(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
	FGameplayTagQuery Copy = MatchAny;
	return (Copy == MatchAny) ? 1 : 0;
}

int GPTagQuery_ExactMatchFactories(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagQuery MatchAnyExact = FGameplayTagQuery::MakeQuery_ExactMatchAnyTags(Tags);
	FGameplayTagQuery MatchAllExact = FGameplayTagQuery::MakeQuery_ExactMatchAllTags(Tags);
	if (MatchAnyExact.IsEmpty())
	{
		return 0;
	}
	if (MatchAllExact.IsEmpty())
	{
		return 0;
	}
	return 1;
}

int GPTagQuery_MatchesQuery(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
	FGameplayTagQuery MatchAll = FGameplayTagQuery::MakeQuery_MatchAllTags(Tags);
	FGameplayTagQuery MatchAnyExact = FGameplayTagQuery::MakeQuery_ExactMatchAnyTags(Tags);
	FGameplayTagQuery MatchAllExact = FGameplayTagQuery::MakeQuery_ExactMatchAllTags(Tags);
	FGameplayTagQuery MatchNone = FGameplayTagQuery::MakeQuery_MatchNoTags(Tags);
	if (!Tags.MatchesQuery(MatchAny))
	{
		return 0;
	}
	if (!Tags.MatchesQuery(MatchAll))
	{
		return 0;
	}
	if (!Tags.MatchesQuery(MatchAnyExact))
	{
		return 0;
	}
	if (!Tags.MatchesQuery(MatchAllExact))
	{
		return 0;
	}
	if (Tags.MatchesQuery(MatchNone))
	{
		return 0;
	}
	return 1;
}

bool Observe_GameplayTagQuery_Nominal(FName TagName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0004 setup: required TagName is None");
	}
	return GPTagQuery_EmptyDefault() == 1
		&& GPTagQuery_MatchAnyNotEmpty(TagName) == 1
		&& GPTagQuery_MatchAllNotEmpty(TagName) == 1
		&& GPTagQuery_MatchNoneNotEmpty(TagName) == 1
		&& GPTagQuery_MatchTagNotEmpty(TagName) == 1
		&& GPTagQuery_DifferentQueriesNotEqual(TagName) == 1
		&& GPTagQuery_CopyEquality(TagName) == 1
		&& GPTagQuery_ExactMatchFactories(TagName) == 1
		&& GPTagQuery_MatchesQuery(TagName) == 1;
}

int Observe_GameplayTagQuery_EmptyContainerDoesNotMatchTag(FName TagName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0004 setup: required TagName is None");
	}
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
	FGameplayTagContainer EmptyTags;
	return EmptyTags.MatchesQuery(MatchTag) ? 0 : 1;
}
