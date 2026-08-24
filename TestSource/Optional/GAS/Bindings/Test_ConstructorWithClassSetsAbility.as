// Theme: Optional.GAS. WorldStory default spec Ability is null.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::ConstructorWithClassSetsAbility
// ExpectGlobalInt AbilitySpec_CtorClass == 1.
// Extra: second default spec also null Ability; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_CtorClass()
{
	FGameplayAbilitySpec Spec;
	// Default-constructed spec should have null Ability
	return (Spec.Ability == null) ? 1 : 0;
}

int Observe_AbilitySpec_CtorClass_Nominal()
{
	return AbilitySpec_CtorClass();
}

int Observe_AbilitySpec_CtorClass_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	if (First.Ability != null)
	{
		return 0;
	}
	if (Second.Ability != null)
	{
		return 0;
	}
	return 1;
}

int Observe_AbilitySpec_CtorClass_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
