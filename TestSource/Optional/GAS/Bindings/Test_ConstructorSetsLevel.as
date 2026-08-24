// Theme: Optional.GAS. WorldStory default FGameplayAbilitySpec.Level.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::ConstructorSetsLevel
// ExpectGlobalInt AbilitySpec_CtorLevel == 1.
// Extra: second default spec also Level 1; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_CtorLevel()
{
	FGameplayAbilitySpec Spec;
	return Spec.Level;
}

int Observe_AbilitySpec_CtorLevel_Nominal()
{
	return AbilitySpec_CtorLevel();
}

int Observe_AbilitySpec_CtorLevel_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	return (First.Level == 1 && Second.Level == 1) ? 1 : 0;
}

int Observe_AbilitySpec_CtorLevel_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
