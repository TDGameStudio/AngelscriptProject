// Theme: Optional.GAS. WorldStory: UTestDelegateGiveAbility is given on an ASC.
// C++: AngelscriptGASASCDelegateTests.cpp::OnAbilityGivenBroadcastsOnGiveAbility
// Oracle: OnAbilityGiven fires (Capture->bFired) after BP_GiveAbility.
// Extra: nullptr handle; empty sibling ability; two given instances stay distinct.
// Isolation=none. Optional GAS plugin fixture. Runner owns spawn, ASC, GiveAbility.

UCLASS()
class UTestDelegateGiveAbility : UAngelscriptGASAbility
{
}

UCLASS()
class UTestDelegateGiveAbilityEmpty : UAngelscriptGASAbility
{
}

bool Observe_UTestDelegateGiveAbility_NullDefault()
{
	UTestDelegateGiveAbility Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestDelegateGiveAbility_EmptySiblingNull()
{
	UTestDelegateGiveAbilityEmpty Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestDelegateGiveAbility_TwoHandlesIndependent(UTestDelegateGiveAbility First, UTestDelegateGiveAbility Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
