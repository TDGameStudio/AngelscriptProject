/**
 * @version v1
 * @summary A script attribute set exposing Charisma, used to check that registering a callback for a function that does not exist does not crash. The observers cover the null handle, the empty attribute data and handle.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set exposing Charisma, used to check that registering a callback for a function that does not exist does not crash. The observers cover the null handle, the empty attribute data and handle.
 * @topic Baseline
 */
UCLASS()
class UTestValidParamsAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Charisma;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackWithValidParams
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestValidParamsAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackWithValidParams
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
	 * @Covers GAS.RegisterCallbackWithValidParams
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestValidParamsAttributes First, UTestValidParamsAttributes Second)
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
 * @Covers GAS.RegisterCallbackWithValidParams
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestValidParamsAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
