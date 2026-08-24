// Theme: Optional.GameplayTags. C++ functions return 1 on success. CSV
// NegativeDiagnostic is a heuristic; empty-tag cases are false/null vectors,
// not compile failures. Runner supplies a valid tag name for RequestGameplayTag.
// Extra: empty default is the false vector (already in GPTag_Empty*).
// FixtureIsolated (tag registry).

int GPTag_RequestValid(FName TagName)
{
	FGameplayTag GlobalTag = FGameplayTag::RequestGameplayTag(TagName, true);
	return GlobalTag.IsValid() ? 1 : 0;
}

int GPTag_EmptyNotValid()
{
	FGameplayTag EmptyDefault;
	return EmptyDefault.IsValid() ? 0 : 1;
}

int GPTag_EmptyEqualsEmptyTag()
{
	FGameplayTag EmptyDefault;
	return (EmptyDefault == FGameplayTag::EmptyTag) ? 1 : 0;
}

int GPTag_EmptyNameIsNone()
{
	FGameplayTag EmptyDefault;
	return EmptyDefault.GetTagName().IsNone() ? 1 : 0;
}

int GPTag_EmptyToStringMatchesEmptyTag()
{
	FGameplayTag EmptyDefault;
	return (EmptyDefault.ToString() == FGameplayTag::EmptyTag.ToString()) ? 1 : 0;
}

int GPTag_RequestNoneInvalid()
{
	FGameplayTag RequestedInvalid = FGameplayTag::RequestGameplayTag(NAME_None, false);
	return (RequestedInvalid == FGameplayTag::EmptyTag) ? 1 : 0;
}

bool Observe_GameplayTagCompat_Nominal(FName TagName)
{
	if (TagName.IsNone())
	{
		throw("TS-OPT-0001 setup: required TagName is None");
	}
	return GPTag_RequestValid(TagName) == 1
		&& GPTag_EmptyNotValid() == 1
		&& GPTag_EmptyEqualsEmptyTag() == 1
		&& GPTag_EmptyNameIsNone() == 1
		&& GPTag_EmptyToStringMatchesEmptyTag() == 1
		&& GPTag_RequestNoneInvalid() == 1;
}

bool Observe_GameplayTagCompat_Empty()
{
	return GPTag_EmptyNotValid() == 1
		&& GPTag_EmptyEqualsEmptyTag() == 1
		&& GPTag_EmptyNameIsNone() == 1
		&& GPTag_EmptyToStringMatchesEmptyTag() == 1
		&& GPTag_RequestNoneInvalid() == 1;
}
