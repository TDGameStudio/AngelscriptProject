// Theme: Optional.GAS. WorldStory RemoveAfterActivation bit-field round-trip.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::BitFieldRemoveAfterActivation
// ExpectGlobalInt AbilitySpec_RemoveAfterActivation == 1.
// Extra: copy independence; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_RemoveAfterActivation()
{
	FGameplayAbilitySpec Spec;
	if (Spec.GetbRemoveAfterActivation())
	{
		return -1;
	}
	Spec.SetbRemoveAfterActivation(true);
	if (!Spec.GetbRemoveAfterActivation())
	{
		return -2;
	}
	return 1;
}

int Observe_AbilitySpec_RemoveAfterActivation_Nominal()
{
	return AbilitySpec_RemoveAfterActivation();
}

int Observe_AbilitySpec_RemoveAfterActivation_CopyIndependence()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	First.SetbRemoveAfterActivation(true);
	if (!First.GetbRemoveAfterActivation())
	{
		return 0;
	}
	if (Second.GetbRemoveAfterActivation())
	{
		return 0;
	}
	return 1;
}

int Observe_AbilitySpec_RemoveAfterActivation_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
