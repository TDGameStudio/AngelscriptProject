// Theme: Optional.GAS. WorldStory default SetByCallerTagMagnitudes is empty.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::SetByCallerTagMagnitudesDefaultEmpty
// ExpectGlobalInt AbilitySpec_SetByCaller == 0.
// Extra: empty DynamicAbilityTags; empty FGameplayTag is invalid.
// FixtureIsolated.

int AbilitySpec_SetByCaller()
{
	FGameplayAbilitySpec Spec;
	return Spec.SetByCallerTagMagnitudes.Num();
}

int Observe_AbilitySpec_SetByCaller_Nominal()
{
	return AbilitySpec_SetByCaller();
}

int Observe_AbilitySpec_SetByCaller_SecondDefault()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	return First.SetByCallerTagMagnitudes.Num() + Second.SetByCallerTagMagnitudes.Num();
}

int Observe_AbilitySpec_SetByCaller_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	FGameplayTag EmptyTag;
	if (EmptyTag.IsValid())
	{
		return -1;
	}
	return Spec.DynamicAbilityTags.Num() + Spec.SetByCallerTagMagnitudes.Num();
}
