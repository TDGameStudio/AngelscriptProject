// Theme: Optional.GAS. WorldStory: UTestMultiGiveAbilityA and UTestMultiGiveAbilityB
// are both given on one ASC.
// C++: AngelscriptGASASCDelegateTests.cpp::MultipleGiveAbilityFiresOnAbilityGivenEachTime
// Oracle: OnAbilityGiven FireCount == 2.
// Extra: nullptr handles; empty sibling ability; A and B remain distinct types.
// Isolation=none. Optional GAS plugin fixture. Runner owns two GiveAbility calls.

UCLASS()
class UTestMultiGiveAbilityA : UAngelscriptGASAbility
{
}

UCLASS()
class UTestMultiGiveAbilityB : UAngelscriptGASAbility
{
}

UCLASS()
class UTestMultiGiveAbilityEmpty : UAngelscriptGASAbility
{
}

bool Observe_UTestMultiGiveAbilityA_NullDefault()
{
	UTestMultiGiveAbilityA Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestMultiGiveAbilityB_NullDefault()
{
	UTestMultiGiveAbilityB Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestMultiGiveAbility_EmptySiblingNull()
{
	UTestMultiGiveAbilityEmpty Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestMultiGiveAbility_TwoClassesIndependent(UTestMultiGiveAbilityA First, UTestMultiGiveAbilityB Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
