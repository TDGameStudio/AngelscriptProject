/**
 * @version v1
 * @summary An attribute set exposing Rage for the additive ModAttributeUnsafe modifier. C++ owns the modifier application; the observers cover the null handle, the empty attribute data and attribute resolution by name.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set exposing Rage for the additive ModAttributeUnsafe modifier. C++ owns the modifier application; the observers cover the null handle, the empty attribute data and attribute resolution by name.
 * @topic Baseline
 */
UCLASS()
class UTestModUnsafeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Rage;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ASCModAttributeUnsafe
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestModUnsafeAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ASCModAttributeUnsafe
	 * @Inputs a default-constructed attribute data
	 * @Return true when the attribute name is none
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyAttributeData()
	{
		FAngelscriptGameplayAttributeData EmptyData;
		return EmptyData.AttributeName.IsNone();
	}

	/**
	 * Observe that attribute resolution follows the supplied name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ASCModAttributeUnsafe
	 * @Inputs an attribute name to resolve
	 * @Return true when a real name resolves and NAME_None does not
	 * @Param AttributeName the attribute to look up
	 */
	UFUNCTION()
	bool RageAttributeValid(FName AttributeName)
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestModUnsafeAttributes, AttributeName, OutAttr);

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
 * @Covers GAS.ASCModAttributeUnsafe
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestModUnsafeAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
