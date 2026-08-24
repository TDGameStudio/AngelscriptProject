// Theme: Optional.GameplayTags. C++ functions return 1. CSV NegativeDiagnostic is
// a heuristic; C++ ExpectGlobalInt value oracles after compile.
// C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagExactQueryCompat
// Runner supplies TagName. Extra: empty container does not match MatchTag;
// RequestGameplayTag(None) equals EmptyTag.
// FixtureIsolated.

int GPTagExact_GetTagName(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	return (ValidTag.GetTagName() == TagName) ? 1 : 0;
}

int GPTagExact_ToString(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	return (ValidTag.ToString() == TagName.ToString()) ? 1 : 0;
}

int GPTagExact_MatchTagQuery(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	return Tags.MatchesQuery(MatchTag) ? 1 : 0;
}

int GPTagExact_EmptyNotMatchQuery(FName TagName)
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
	FGameplayTagContainer EmptyTags;
	return EmptyTags.MatchesQuery(MatchTag) ? 0 : 1;
}

int GPTagExact_RequestNoneEqualsEmpty()
{
	FGameplayTag RequestedInvalid = FGameplayTag::RequestGameplayTag(NAME_None, false);
	return (RequestedInvalid == FGameplayTag::EmptyTag) ? 1 : 0;
}

bool Observe_GameplayTagExactQuery_Nominal(FName TagName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0005 setup: required TagName is None");
	}
	return GPTagExact_GetTagName(TagName) == 1
		&& GPTagExact_ToString(TagName) == 1
		&& GPTagExact_MatchTagQuery(TagName) == 1
		&& GPTagExact_EmptyNotMatchQuery(TagName) == 1
		&& GPTagExact_RequestNoneEqualsEmpty() == 1;
}

bool Observe_GameplayTagExactQuery_Empty()
{
	return GPTagExact_RequestNoneEqualsEmpty() == 1;
}
