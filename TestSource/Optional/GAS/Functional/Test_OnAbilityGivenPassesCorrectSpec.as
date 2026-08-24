// Theme: Optional.GAS. WorldStory: UTestSpecInfoAbility is given at Level 7 InputID 2.
// C++: AngelscriptGASASCDelegateTests.cpp::OnAbilityGivenPassesCorrectSpec
// Oracle: CapturedAbilityLevel == 7; CapturedAbilityInputID == 2.
// Extra: nullptr handle; empty sibling ability; two instances stay distinct.
// Isolation=none. Optional GAS plugin fixture. Runner owns BP_GiveAbility(class, 7, 2).

UCLASS()
class UTestSpecInfoAbility : UAngelscriptGASAbility
{
}

UCLASS()
class UTestSpecInfoAbilityEmpty : UAngelscriptGASAbility
{
}

bool Observe_UTestSpecInfoAbility_NullDefault()
{
	UTestSpecInfoAbility Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestSpecInfoAbility_EmptySiblingNull()
{
	UTestSpecInfoAbilityEmpty Ability = nullptr;
	return Ability == nullptr;
}

bool Observe_UTestSpecInfoAbility_TwoHandlesIndependent(UTestSpecInfoAbility First, UTestSpecInfoAbility Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
