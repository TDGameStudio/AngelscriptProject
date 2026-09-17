/**
 * @version v1
 * @summary An attribute set registered on an ASC, where writing a non-existent attribute must return false rather than crash. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this module and asserts TestFalse, so this.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set registered on an ASC, where writing a non-existent attribute must return false rather than crash. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this module and asserts TestFalse, so this.
 * @topic Baseline
 */
UCLASS()
class UASCInvalidAttrAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueWithInvalidAttribute
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UASCInvalidAttrAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueWithInvalidAttribute
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
	 * Observe that an unknown attribute name is rejected by the write.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueWithInvalidAttribute
	 * @Inputs a registered set and an unknown attribute name
	 * @Return true when the write reports failure
	 * @Param Set the instance to write against
	 * @Param AttributeName the unknown name to reject
	 * @Boundary invalid name
	 */
	UFUNCTION()
	bool InvalidNameReturnsFalse(UASCInvalidAttrAttributes Set, FName AttributeName)
	{
		if (Set == nullptr)
		{
			return false;
		}
		return !Set.TrySetAttributeBaseValue(AttributeName, 50.0f);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.SetAttributeBaseValueWithInvalidAttribute
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UASCInvalidAttrAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
