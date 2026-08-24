// Theme: Optional.GAS. WorldStory PendingRemove bit-field round-trip.
// C++: AngelscriptGASAbilitySpecBindingsTests.cpp::BitFieldPendingRemove
// ExpectGlobalInt AbilitySpec_PendingRemove == 1.
// Extra: copy independence; empty DynamicAbilityTags.
// FixtureIsolated.

int AbilitySpec_PendingRemove()
{
	FGameplayAbilitySpec Spec;
	if (Spec.GetbPendingRemove())
	{
		return -1;
	}
	Spec.SetbPendingRemove(true);
	if (!Spec.GetbPendingRemove())
	{
		return -2;
	}
	return 1;
}

int Observe_AbilitySpec_PendingRemove_Nominal()
{
	return AbilitySpec_PendingRemove();
}

int Observe_AbilitySpec_PendingRemove_CopyIndependence()
{
	FGameplayAbilitySpec First;
	FGameplayAbilitySpec Second;
	First.SetbPendingRemove(true);
	if (!First.GetbPendingRemove())
	{
		return 0;
	}
	if (Second.GetbPendingRemove())
	{
		return 0;
	}
	return 1;
}

int Observe_AbilitySpec_PendingRemove_EmptyTags()
{
	FGameplayAbilitySpec Spec;
	return Spec.DynamicAbilityTags.Num();
}
