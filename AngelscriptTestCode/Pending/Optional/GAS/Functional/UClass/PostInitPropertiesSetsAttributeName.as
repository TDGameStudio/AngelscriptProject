/**
 * @version v1
 * @summary A script attribute set exposing Charisma, whose AttributeName must be filled in during PostInitProperties. The observers cover the null handle, the resolved field name and the empty attribute data.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set exposing Charisma, whose AttributeName must be filled in during PostInitProperties. The observers cover the null handle, the resolved field name and the empty attribute data.
 * @topic Baseline
 */
UCLASS()
class UTestPostInitAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Charisma;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.PostInitPropertiesSetsAttributeName
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestPostInitAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the field name resolved during PostInitProperties.
	 *
	 * @Kind Observe
	 * @Covers GAS.PostInitPropertiesSetsAttributeName
	 * @Inputs a registered attribute set instance
	 * @Return true when Charisma reports its own name
	 * @Param Set the instance whose field name is checked
	 */
	UFUNCTION()
	bool CharismaName(UTestPostInitAttributes Set)
	{
		return Set.Charisma.AttributeName == n"Charisma";
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.PostInitPropertiesSetsAttributeName
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
 * @Covers GAS.PostInitPropertiesSetsAttributeName
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestPostInitAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
