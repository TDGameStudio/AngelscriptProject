// Theme: Optional.GAS. WorldStory default DynamicAbilityTags is empty.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::DynamicAbilityTagsDefaultEmpty
// ExpectGlobalInt AbilitySpec_DynTags == 0.
// Extra: empty FGameplayTag is invalid; second spec also empty.
// FixtureIsolated.

int AbilitySpec_DynTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}

int Observe_AbilitySpec_DynTags_Nominal()
{
	return AbilitySpec_DynTags();
}

int Observe_AbilitySpec_DynTags_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	return First.DynamicAbilityTags.Num() + Second.DynamicAbilityTags.Num();
}

int Observe_AbilitySpec_DynTags_EmptyTag()
{
	FGameplayTag EmptyTag;
	FGameplayAbilitySpec Spec;
	if (EmptyTag.IsValid())
	{
		return -1;
	}
	return Spec.DynamicAbilityTags.Num();
}
