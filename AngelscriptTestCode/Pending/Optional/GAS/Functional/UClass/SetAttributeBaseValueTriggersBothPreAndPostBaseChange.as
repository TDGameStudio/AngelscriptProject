/**
 * @version v1
 * @summary A script attribute set exposing Wisdom, whose base-value write must trigger both PreAttributeBaseChange and PostAttributeBaseChange. The observers cover the null handle, the empty attribute data and handle independence.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set exposing Wisdom, whose base-value write must trigger both PreAttributeBaseChange and PostAttributeBaseChange. The observers cover the null handle, the empty attribute data and handle independence.
 * @topic Baseline
 */
UCLASS()
class UTestBothBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Wisdom;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueTriggersBothPreAndPost
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestBothBaseAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueTriggersBothPreAndPost
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
	 * @Covers GAS.SetAttributeBaseValueTriggersBothPreAndPost
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestBothBaseAttributes First, UTestBothBaseAttributes Second)
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
 * @Covers GAS.SetAttributeBaseValueTriggersBothPreAndPost
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestBothBaseAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
