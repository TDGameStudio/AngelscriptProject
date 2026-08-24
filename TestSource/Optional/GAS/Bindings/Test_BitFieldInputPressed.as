// Theme: Optional.GAS. WorldStory InputPressed bit-field round-trip.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::BitFieldInputPressed
// ExpectGlobalInt AbilitySpec_InputPressed == 1.
// Extra: copy independence; default DynamicAbilityTags empty.
// FixtureIsolated.

int AbilitySpec_InputPressed()
{
	FGameplayAbilitySpec Spec;
	if (Spec.GetbInputPressed())
	{
		return -1;
	}
	Spec.SetbInputPressed(true);
	if (!Spec.GetbInputPressed())
	{
		return -2;
	}
	Spec.SetbInputPressed(false);
	if (Spec.GetbInputPressed())
	{
		return -3;
	}
	return 1;
}

int Observe_AbilitySpec_InputPressed_Nominal()
{
	return AbilitySpec_InputPressed();
}

int Observe_AbilitySpec_InputPressed_CopyIndependence()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	First.SetbInputPressed(true);
	if (!First.GetbInputPressed())
	{
		return 0;
	}
	if (Second.GetbInputPressed())
	{
		return 0;
	}
	return 1;
}

int Observe_AbilitySpec_InputPressed_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
