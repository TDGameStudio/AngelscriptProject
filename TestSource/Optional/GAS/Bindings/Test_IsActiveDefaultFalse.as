// Theme: Optional.GAS. WorldStory default spec is not active.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::IsActiveDefaultFalse
// ExpectGlobalInt AbilitySpec_IsActive == 1 (IsActive is false).
// Extra: second default spec also inactive; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_IsActive()
{
	FGameplayAbilitySpec Spec;
	return Spec.IsActive() ? 0 : 1;
}

int Observe_AbilitySpec_IsActive_Nominal()
{
	return AbilitySpec_IsActive();
}

int Observe_AbilitySpec_IsActive_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	if (First.IsActive())
	{
		return 0;
	}
	if (Second.IsActive())
	{
		return 0;
	}
	return 1;
}

int Observe_AbilitySpec_IsActive_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
