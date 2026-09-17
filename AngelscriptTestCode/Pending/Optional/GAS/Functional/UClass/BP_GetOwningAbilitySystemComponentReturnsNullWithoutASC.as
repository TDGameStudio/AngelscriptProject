/**
 * @version v1
 * @summary An attribute set created with NewObject and never registered, so it has no owning ASC. The observers cover the null handle, the null owning ASC and the empty attribute data.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set created with NewObject and never registered, so it has no owning ASC. The observers cover the null handle, the null owning ASC and the empty attribute data.
 * @topic Baseline
 */
UCLASS()
class UTestNoASCCompAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Temp;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningASCNull
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNoASCCompAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that an unregistered set reports no owning ASC.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningASCNull
	 * @Inputs this set's owning ASC accessor
	 * @Return true when the owning ASC is null
	 * @Boundary unowned set
	 */
	UFUNCTION()
	bool UnownedASCIsNull()
	{
		return BP_GetOwningAbilitySystemComponent() == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningASCNull
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
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.BPGetOwningASCNull
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNoASCCompAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
