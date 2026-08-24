// Theme: Optional.GAS. WorldStory: ATestGASPawnSub subclasses AAngelscriptGASPawn.
// C++: AngelscriptGASCharacterTagTests.cpp::ScriptSubclassOfGASPawnInheritsASC
// Oracle: ImplementsInterface(UAbilitySystemInterface).
// Extra: nullptr handle; empty sibling pawn; FName TagName empty/request vector.
// Isolation=none. Optional GAS + GameplayTags plugin fixtures. Do not spawn from script.

UCLASS()
class ATestGASPawnSub : AAngelscriptGASPawn
{
}

UCLASS()
class ATestGASPawnSubEmpty : AAngelscriptGASPawn
{
}

bool Observe_ATestGASPawnSub_NullDefault()
{
	ATestGASPawnSub Pawn = nullptr;
	return Pawn == nullptr;
}

bool Observe_ATestGASPawnSub_EmptySiblingNull()
{
	ATestGASPawnSubEmpty Pawn = nullptr;
	return Pawn == nullptr;
}

bool Observe_ATestGASPawnSub_EmptyTag()
{
	FGameplayTag EmptyDefault;
	return !EmptyDefault.IsValid() && EmptyDefault.GetTagName().IsNone();
}

bool Observe_ATestGASPawnSub_RequestTag(FName TagName)
{
	if (TagName.IsNone())
	{
		FGameplayTag NoneTag = FGameplayTag::RequestGameplayTag(TagName, false);
		return !NoneTag.IsValid();
	}
	FGameplayTag Tag = FGameplayTag::RequestGameplayTag(TagName, false);
	return Tag.IsValid();
}
