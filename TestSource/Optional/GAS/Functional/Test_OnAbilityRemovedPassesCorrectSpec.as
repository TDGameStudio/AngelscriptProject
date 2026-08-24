// Theme: Optional.GAS. WorldStory: UTestRemoveSpecAbility is given at Level 3 InputID 4 then cleared.
// C++: AngelscriptGASASCDelegateTests.cpp::OnAbilityRemovedPassesCorrectSpec
// Oracle: OnAbilityRemoved CapturedAbilityLevel == 3.
// Extra: nullptr handle; empty sibling ability; two instances stay distinct.
// Isolation=none. Optional GAS plugin fixture. Runner owns GiveAbility then ClearAbility.

UCLASS()
class UTestRemoveSpecAbility : UAngelscriptGASAbility
{
}

UCLASS()
class UTestRemoveSpecAbilityEmpty : UAngelscriptGASAbility
{
}

bool Observe_UTestRemoveSpecAbility_NullDefault()
{
	UTestRemoveSpecAbility Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestRemoveSpecAbility_EmptySiblingNull()
{
	UTestRemoveSpecAbilityEmpty Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestRemoveSpecAbility_TwoHandlesIndependent(UTestRemoveSpecAbility First, UTestRemoveSpecAbility Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
