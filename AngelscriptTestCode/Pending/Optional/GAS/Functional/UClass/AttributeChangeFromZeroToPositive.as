/**
 * @version v1
 * @summary An attribute set exposing Energy that C++ drives from zero up to a positive value. The observers cover the null handle, the empty attribute data and handle independence.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set exposing Energy that C++ drives from zero up to a positive value. The observers cover the null handle, the empty attribute data and handle independence.
 * @topic Baseline
 */
UCLASS()
class UTestZeroPosAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Energy;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeChangeFromZeroToPositive
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestZeroPosAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeChangeFromZeroToPositive
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
	 * @Covers GAS.AttributeChangeFromZeroToPositive
	 * @Inputs this handle and a second handle
	 * @Return true when both are non-null and differ
	 * @Param Second the other handle to compare against
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestZeroPosAttributes Second)
	{
		if (this == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return this != Second;
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.AttributeChangeFromZeroToPositive
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestZeroPosAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
