// Theme: Optional.GAS. WorldStory default spec ActiveCount is 0.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::ActiveCountDefault
// ExpectGlobalInt AbilitySpec_ActiveCount == 0.
// Extra: second default spec also 0; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_ActiveCount()
{
	FGameplayAbilitySpec Spec;
	return int(Spec.ActiveCount);
}

int Observe_AbilitySpec_ActiveCount_Nominal()
{
	return AbilitySpec_ActiveCount();
}

int Observe_AbilitySpec_ActiveCount_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	return int(First.ActiveCount) + int(Second.ActiveCount);
}

int Observe_AbilitySpec_ActiveCount_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
