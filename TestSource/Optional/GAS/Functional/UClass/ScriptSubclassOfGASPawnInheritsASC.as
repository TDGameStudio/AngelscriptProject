/**
 * A pawn subclassing AAngelscriptGASPawn, which must inherit the ability system
 * interface. The observers cover both null handles, the empty tag and tag request
 * behaviour.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ScriptSubclassOfGASPawnInheritsASC
 * @Harness UClass
 * @Tag Optional.GAS.ScriptSubclassOfGASPawnInheritsASC
 * @Provenance Theme: Optional.GAS. WorldStory: ATestGASPawnSub subclasses AAngelscriptGASPawn.
 * @Provenance C++: AngelscriptGASCharacterTagTests.cpp::ScriptSubclassOfGASPawnInheritsASC
 * @Provenance Oracle: ImplementsInterface(UAbilitySystemInterface).
 * @Provenance Extra: nullptr handle; empty sibling pawn; FName TagName empty/request vector.
 * @Provenance Isolation=none. Optional GAS + GameplayTags plugin fixtures. Do not spawn from script.
 */

UCLASS()
class ATestGASPawnSub : AAngelscriptGASPawn
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassOfGASPawnInheritsASC
	 * @Inputs an unset pawn handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestGASPawnSub Pawn = nullptr;
		return Pawn == nullptr;
	}

	/**
	 * Observe that a default tag is invalid and carries no name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassOfGASPawnInheritsASC
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
	 * @Covers GAS.ScriptSubclassOfGASPawnInheritsASC
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
 * The empty sibling pawn that C++ also compiles alongside the subclass.
 *
 * @Covers GAS.ScriptSubclassOfGASPawnInheritsASC
 * @Inputs none
 * @Return a declared but empty pawn subclass
 */
UCLASS()
class ATestGASPawnSubEmpty : AAngelscriptGASPawn
{
	/**
	 * Observe that an unset handle of the empty sibling is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassOfGASPawnInheritsASC
	 * @Inputs an unset empty-sibling handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool EmptySiblingNull()
	{
		ATestGASPawnSubEmpty Pawn = nullptr;
		return Pawn == nullptr;
	}
}
