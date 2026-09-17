/**
 * @version v1
 * @summary A script attribute set exposing Attack, Defense and Speed, whose field names must resolve after PostInit. The observers cover the null handle, the three field names and the empty attribute data.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set exposing Attack, Defense and Speed, whose field names must resolve after PostInit. The observers cover the null handle, the three field names and the empty attribute data.
 * @topic Baseline
 */
UCLASS()
class UTestMultiNameAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Attack;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Defense;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Speed;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributeFieldNames
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestMultiNameAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that all three field names match their declarations.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributeFieldNames
	 * @Inputs a registered attribute set instance
	 * @Return true when Attack, Defense and Speed all report their own names
	 * @Param Set the instance whose field names are checked
	 */
	UFUNCTION()
	bool FieldNames(UTestMultiNameAttributes Set)
	{
		if (Set.Attack.AttributeName != n"Attack")
		{
			return false;
		}
		if (Set.Defense.AttributeName != n"Defense")
		{
			return false;
		}
		return Set.Speed.AttributeName == n"Speed";
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributeFieldNames
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
 * @Covers GAS.MultipleAttributeFieldNames
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestMultiNameAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
