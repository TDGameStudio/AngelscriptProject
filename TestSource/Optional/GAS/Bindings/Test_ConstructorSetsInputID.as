// Theme: Optional.GAS. WorldStory default FGameplayAbilitySpec.InputID.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::ConstructorSetsInputID
// ExpectGlobalInt AbilitySpec_CtorInputID == -1.
// Extra: second default spec also InputID -1; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_CtorInputID()
{
	FGameplayAbilitySpec Spec;
	return Spec.InputID;
}

int Observe_AbilitySpec_CtorInputID_Nominal()
{
	return AbilitySpec_CtorInputID();
}

int Observe_AbilitySpec_CtorInputID_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	return (First.InputID == -1 && Second.InputID == -1) ? 1 : 0;
}

int Observe_AbilitySpec_CtorInputID_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	FGameplayTag EmptyTag;
	if (EmptyTag.IsValid())
	{
		return -1;
	}
	return Spec.DynamicAbilityTags.Num();
}
