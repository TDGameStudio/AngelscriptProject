// Theme: Optional.GAS. WorldStory ActivateOnce bit-field round-trip.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::BitFieldActivateOnce
// ExpectGlobalInt AbilitySpec_ActivateOnce == 1.
// Extra: copy independence; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_ActivateOnce()
{
	FGameplayAbilitySpec Spec;
	if (Spec.GetbActivateOnce())
	{
		return -1;
	}
	Spec.SetbActivateOnce(true);
	if (!Spec.GetbActivateOnce())
	{
		return -2;
	}
	return 1;
}

int Observe_AbilitySpec_ActivateOnce_Nominal()
{
	return AbilitySpec_ActivateOnce();
}

int Observe_AbilitySpec_ActivateOnce_CopyIndependence()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	First.SetbActivateOnce(true);
	if (!First.GetbActivateOnce())
	{
		return 0;
	}
	if (Second.GetbActivateOnce())
	{
		return 0;
	}
	return 1;
}

int Observe_AbilitySpec_ActivateOnce_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
