/**
 * @version v1
 * @summary A script attribute set exposing Attack and Defense, whose change events must fire in the order C++ drives them. The observers cover the null handle, the empty attribute data and handle independence.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set exposing Attack and Defense, whose change events must fire in the order C++ drives them. The observers cover the null handle, the empty attribute data and handle independence.
 * @topic Baseline
 */
UCLASS()
class UTestMultiChangeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Attack;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Defense;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributeChangesInOrder
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestMultiChangeAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributeChangesInOrder
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
	 * Observe that two runner-supplied handles refer to different objects.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributeChangesInOrder
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestMultiChangeAttributes First, UTestMultiChangeAttributes Second)
	{
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.MultipleAttributeChangesInOrder
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestMultiChangeAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
