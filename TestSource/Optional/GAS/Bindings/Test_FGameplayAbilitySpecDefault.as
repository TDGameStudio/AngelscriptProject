// Theme: Optional.GAS. WorldStory default FGameplayAbilitySpec.Level is 1 (UE 5.7).
// C++: AngelscriptGASExtendedBindingsTests.cpp::FGameplayAbilitySpecDefault
// ExpectGlobalInt AbilitySpec_DefaultLevel == 1.
// Extra: second default also 1; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_DefaultLevel()
{
	FGameplayAbilitySpec Spec;
	return Spec.Level;
}

int Observe_AbilitySpec_DefaultLevel_Nominal()
{
	return AbilitySpec_DefaultLevel();
}

int Observe_AbilitySpec_DefaultLevel_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	return (First.Level == 1 && Second.Level == 1) ? 1 : 0;
}

int Observe_AbilitySpec_DefaultLevel_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
