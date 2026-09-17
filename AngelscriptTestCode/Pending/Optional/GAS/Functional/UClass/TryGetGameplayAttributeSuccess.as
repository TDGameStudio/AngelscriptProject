/**
 * @version v1
 * @summary An attribute set exposing Mana, whose static lookup returns a valid attribute. The observers cover the null handle, the Mana lookup and the named lookup with its NAME_None rejection.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set exposing Mana, whose static lookup returns a valid attribute. The observers cover the null handle, the Mana lookup and the named lookup with its NAME_None rejection.
 * @topic Baseline
 */
UCLASS()
class UTestTryGetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetGameplayAttributeSuccess
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestTryGetAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that the Mana lookup returns a valid attribute.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetGameplayAttributeSuccess
	 * @Inputs the static lookup under the Mana name
	 * @Return true when the lookup reports a valid attribute
	 */
	UFUNCTION()
	bool ManaIsValid()
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetAttributes, n"Mana", OutAttr);

		if (!bFound)
		{
			return false;
		}

		return OutAttr.IsValid();
	}

	/**
	 * Observe that the static lookup follows the supplied name.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetGameplayAttributeSuccess
	 * @Inputs an attribute name to look up
	 * @Return true when a real name resolves and NAME_None does not
	 * @Param AttributeName the attribute to look up
	 */
	UFUNCTION()
	bool Named(FName AttributeName)
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetAttributes, AttributeName, OutAttr);

		if (AttributeName.IsNone())
		{
			if (bFound)
			{
				return false;
			}
			return !OutAttr.IsValid();
		}

		if (!bFound)
		{
			return false;
		}
		return OutAttr.IsValid();
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TryGetGameplayAttributeSuccess
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestTryGetAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
