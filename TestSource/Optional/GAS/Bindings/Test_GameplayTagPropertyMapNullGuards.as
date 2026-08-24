// Theme: Optional.GAS. C++ compiles then expects runtime script exceptions.
// CSV NegativeDiagnostic is a heuristic; null Owner / null ASC are the null vectors.
// Diagnostic: "GameplayTagBlueprintPropertyMap.Initialize received a null Owner."
// Diagnostic: "GameplayTagBlueprintPropertyMap.Initialize received a null AbilitySystemComponent."
// C++: AngelscriptGASValueBindingsTests.cpp::GameplayTagPropertyMapNullGuards
// OutStep stays 1 when Initialize throws. Extra: empty tag/container.
// FixtureIsolated.

void TriggerNullOwnerAndASC(int& OutStep)
{
	OutStep = 1;
	FGameplayTagBlueprintPropertyMap Map;
	UObject NullOwner;
	UAbilitySystemComponent NullASC;
	Map.Initialize(NullOwner, NullASC);
	OutStep = 2;
	Map.ApplyCurrentTags();
	OutStep = 3;
}

void TriggerNullASC(UObject Owner, int& OutStep)
{
	OutStep = 1;
	FGameplayTagBlueprintPropertyMap Map;
	UAbilitySystemComponent NullASC;
	Map.Initialize(Owner, NullASC);
	OutStep = 2;
	Map.ApplyCurrentTags();
	OutStep = 3;
}

int Observe_GameplayTagPropertyMap_EmptyTagAndContainer()
{
	FGameplayTag EmptyTag;
	FGameplayTagContainer EmptyContainer;
	if (EmptyTag.IsValid())
	{
		return 0;
	}
	if (!EmptyContainer.IsEmpty())
	{
		return 0;
	}
	return 1;
}
