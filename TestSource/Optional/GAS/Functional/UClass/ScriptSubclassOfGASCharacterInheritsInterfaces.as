/**
 * A character subclassing AAngelscriptGASCharacter, which must inherit both the
 * ability system interface and the gameplay tag asset interface. The observers
 * cover both null handles, the empty tag and tag request behaviour.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ScriptSubclassOfGASCharacterInheritsInterfaces
 * @Harness UClass
 * @Tag Optional.GAS.ScriptSubclassOfGASCharacterInheritsInterfaces
 * @Provenance Theme: Optional.GAS. WorldStory: ATestGASCharacterSub subclasses AAngelscriptGASCharacter.
 * @Provenance C++: AngelscriptGASCharacterTagTests.cpp::ScriptSubclassOfGASCharacterInheritsInterfaces
 * @Provenance Oracle: ImplementsInterface(UAbilitySystemInterface) and IGameplayTagAssetInterface.
 * @Provenance Extra: nullptr handle; empty sibling character; FName TagName empty/request vector.
 * @Provenance Isolation=none. Optional GAS + GameplayTags plugin fixtures. Do not spawn from script.
 */

UCLASS()
class ATestGASCharacterSub : AAngelscriptGASCharacter
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassOfGASCharacterInheritsInterfaces
	 * @Inputs an unset character handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestGASCharacterSub Character = nullptr;
		return Character == nullptr;
	}

	/**
	 * Observe that a default tag is invalid and carries no name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassOfGASCharacterInheritsInterfaces
	 * @Inputs a default-constructed tag
	 * @Return true when the tag is invalid and its name is none
	 * @Boundary empty tag
	 */
	UFUNCTION()
	bool EmptyTag()
	{
		FGameplayTag EmptyDefault;

		if (EmptyDefault.IsValid())
		{
			return false;
		}

		return EmptyDefault.GetTagName().IsNone();
	}

	/**
	 * Observe that tag request follows the supplied name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassOfGASCharacterInheritsInterfaces
	 * @Inputs a tag name to request
	 * @Return true when a real name resolves and NAME_None does not
	 * @Param TagName the tag to request
	 */
	UFUNCTION()
	bool RequestTag(FName TagName)
	{
		FGameplayTag Tag = FGameplayTag::RequestGameplayTag(TagName, false);

		if (TagName.IsNone())
		{
			return !Tag.IsValid();
		}

		return Tag.IsValid();
	}
}

/**
 * The empty sibling character that C++ also compiles alongside the subclass.
 *
 * @Covers GAS.ScriptSubclassOfGASCharacterInheritsInterfaces
 * @Inputs none
 * @Return a declared but empty character subclass
 */
UCLASS()
class ATestGASCharacterSubEmpty : AAngelscriptGASCharacter
{
	/**
	 * Observe that an unset handle of the empty sibling is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassOfGASCharacterInheritsInterfaces
	 * @Inputs an unset empty-sibling handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool EmptySiblingNull()
	{
		ATestGASCharacterSubEmpty Character = nullptr;
		return Character == nullptr;
	}
}
