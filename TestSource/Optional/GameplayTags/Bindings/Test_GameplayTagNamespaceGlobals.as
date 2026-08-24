// Theme: Optional.GameplayTags. WorldStory GameplayTags:: namespace globals.
// C++ printf-injects GameplayTags::SanitizedIdentifier; TestSource uses TagName
// and ParentName runner parameters because identifiers cannot be parameterized.
// C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagNamespaceGlobals
// ExpectGlobalInt each GPTagNS_* == 1. Extra: empty default tag is invalid.
// FixtureIsolated.

int GPTagNS_NamespaceTagValid(FName TagName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	return NamespaceTag.IsValid() ? 1 : 0;
}

int GPTagNS_NamespaceTagEqualsRequested(FName TagName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTag RequestedTag = FGameplayTag::RequestGameplayTag(TagName, true);
	return (NamespaceTag == RequestedTag) ? 1 : 0;
}

int GPTagNS_NamespaceTagNameMatches(FName TagName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTag RequestedTag = FGameplayTag::RequestGameplayTag(TagName, true);
	return (NamespaceTag.GetTagName() == RequestedTag.GetTagName()) ? 1 : 0;
}

int GPTagNS_NamespaceTagToStringMatches(FName TagName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTag RequestedTag = FGameplayTag::RequestGameplayTag(TagName, true);
	return (NamespaceTag.ToString() == RequestedTag.ToString()) ? 1 : 0;
}

int GPTagNS_ParentTagValid(FName ParentName)
{
	FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return NamespaceParentTag.IsValid() ? 1 : 0;
}

int GPTagNS_ParentTagEqualsRequested(FName ParentName)
{
	FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTag RequestedParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return (NamespaceParentTag == RequestedParentTag) ? 1 : 0;
}

int GPTagNS_DirectParentMatches(FName TagName, FName ParentName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return (NamespaceTag.RequestDirectParent() == NamespaceParentTag) ? 1 : 0;
}

int GPTagNS_ParentChainContainsParent(FName TagName, FName ParentName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	FGameplayTagContainer ParentChain = NamespaceTag.GetGameplayTagParents();
	return ParentChain.HasTagExact(NamespaceParentTag) ? 1 : 0;
}

int GPTagNS_MatchesParent(FName TagName, FName ParentName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return NamespaceTag.MatchesTag(NamespaceParentTag) ? 1 : 0;
}

int GPTagNS_NotMatchesExactParent(FName TagName, FName ParentName)
{
	FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
	FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
	return NamespaceTag.MatchesTagExact(NamespaceParentTag) ? 0 : 1;
}

bool Observe_GameplayTagNamespace_Nominal(FName TagName, FName ParentName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0006 setup: required TagName is None");
	}
	if (ParentName.IsNone())
	{
		throw("TS-OPT-0006 setup: required ParentName is None");
	}
	return GPTagNS_NamespaceTagValid(TagName) == 1
		&& GPTagNS_NamespaceTagEqualsRequested(TagName) == 1
		&& GPTagNS_NamespaceTagNameMatches(TagName) == 1
		&& GPTagNS_NamespaceTagToStringMatches(TagName) == 1
		&& GPTagNS_ParentTagValid(ParentName) == 1
		&& GPTagNS_ParentTagEqualsRequested(ParentName) == 1
		&& GPTagNS_DirectParentMatches(TagName, ParentName) == 1
		&& GPTagNS_ParentChainContainsParent(TagName, ParentName) == 1
		&& GPTagNS_MatchesParent(TagName, ParentName) == 1
		&& GPTagNS_NotMatchesExactParent(TagName, ParentName) == 1;
}

int Observe_GameplayTagNamespace_EmptyTag()
{
	FGameplayTag EmptyDefault;
	return EmptyDefault.IsValid() ? 0 : 1;
}
