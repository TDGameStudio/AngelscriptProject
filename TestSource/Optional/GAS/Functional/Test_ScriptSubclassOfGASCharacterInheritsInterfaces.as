// Theme: Optional.GAS. WorldStory: ATestGASCharacterSub subclasses AAngelscriptGASCharacter.
// C++: AngelscriptGASCharacterTagTests.cpp::ScriptSubclassOfGASCharacterInheritsInterfaces
// Oracle: ImplementsInterface(UAbilitySystemInterface) and IGameplayTagAssetInterface.
// Extra: nullptr handle; empty sibling character; FName TagName empty/request vector.
// Isolation=none. Optional GAS + GameplayTags plugin fixtures. Do not spawn from script.

UCLASS()
class ATestGASCharacterSub : AAngelscriptGASCharacter
{
}

UCLASS()
class ATestGASCharacterSubEmpty : AAngelscriptGASCharacter
{
}

bool Observe_ATestGASCharacterSub_NullDefault()
{
	ATestGASCharacterSub Character = nullptr;
	return Character == nullptr;
}

bool Observe_ATestGASCharacterSub_EmptySiblingNull()
{
	ATestGASCharacterSubEmpty Character = nullptr;
	return Character == nullptr;
}

bool Observe_ATestGASCharacterSub_EmptyTag()
{
	FGameplayTag EmptyDefault;
	return !EmptyDefault.IsValid() && EmptyDefault.GetTagName().IsNone();
}

bool Observe_ATestGASCharacterSub_RequestTag(FName TagName)
{
	if (TagName.IsNone())
	{
		FGameplayTag NoneTag = FGameplayTag::RequestGameplayTag(TagName, false);
		return !NoneTag.IsValid();
	}
	FGameplayTag Tag = FGameplayTag::RequestGameplayTag(TagName, false);
	return Tag.IsValid();
}
