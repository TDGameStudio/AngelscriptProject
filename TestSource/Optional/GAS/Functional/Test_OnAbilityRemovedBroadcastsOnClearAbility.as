// Theme: Optional.GAS. WorldStory: UTestDelegateRemoveAbility is given then cleared.
// C++: AngelscriptGASASCDelegateTests.cpp::OnAbilityRemovedBroadcastsOnClearAbility
// Oracle: OnAbilityRemoved fires (Capture->bFired) after ClearAbility.
// Extra: nullptr handle; empty sibling ability; two instances stay distinct.
// Isolation=none. Optional GAS plugin fixture. Runner owns GiveAbility and ClearAbility.

UCLASS()
class UTestDelegateRemoveAbility : UAngelscriptGASAbility
{
}

UCLASS()
class UTestDelegateRemoveAbilityEmpty : UAngelscriptGASAbility
{
}

bool Observe_UTestDelegateRemoveAbility_NullDefault()
{
	UTestDelegateRemoveAbility Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestDelegateRemoveAbility_EmptySiblingNull()
{
	UTestDelegateRemoveAbilityEmpty Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestDelegateRemoveAbility_TwoHandlesIndependent(UTestDelegateRemoveAbility First, UTestDelegateRemoveAbility Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
