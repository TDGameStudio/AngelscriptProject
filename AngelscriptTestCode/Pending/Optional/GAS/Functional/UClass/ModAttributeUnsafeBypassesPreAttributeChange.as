/**
 * @version v1
 * @summary A script attribute set exposing Rage for the ModAttributeUnsafe override, which bypasses PreAttributeChange. The observers cover the null handle, the empty attribute data and attribute resolution by name.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set exposing Rage for the ModAttributeUnsafe override, which bypasses PreAttributeChange. The observers cover the null handle, the empty attribute data and attribute resolution by name.
 * @topic Baseline
 */
UCLASS()
class UTestModUnsafeBPAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Rage;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ModAttributeUnsafeOverride
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestModUnsafeBPAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ModAttributeUnsafeOverride
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
	 * @Covers GAS.ModAttributeUnsafeOverride
	 * @Inputs an attribute name to look up
	 * @Return true when a real name resolves and NAME_None does not
	 * @Param AttributeName the attribute to look up
	 */
	UFUNCTION()
	bool RageAttributeValid(FName AttributeName)
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestModUnsafeBPAttributes, AttributeName, OutAttr);

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
 * @Covers GAS.ModAttributeUnsafeOverride
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestModUnsafeBPAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
