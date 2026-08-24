// Theme: Optional.GAS. WorldStory default GetPrimaryInstance is null.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::GetPrimaryInstanceReturnsNullByDefault
// ExpectGlobalInt AbilitySpec_PrimaryInstance == 1.
// Extra: second default spec also null; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_PrimaryInstance()
{
	FGameplayAbilitySpec Spec;
	return (Spec.GetPrimaryInstance() == null) ? 1 : 0;
}

int Observe_AbilitySpec_PrimaryInstance_Nominal()
{
	return AbilitySpec_PrimaryInstance();
}

int Observe_AbilitySpec_PrimaryInstance_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	if (First.GetPrimaryInstance() != null)
	{
		return 0;
	}
	if (Second.GetPrimaryInstance() != null)
	{
		return 0;
	}
	return 1;
}

int Observe_AbilitySpec_PrimaryInstance_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
