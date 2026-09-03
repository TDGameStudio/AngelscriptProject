/**
 * A script attribute set supplying Speed and Armor for attribute comparison. The
 * observers cover the null handle, same-versus-different comparison and the two
 * default attributes that still compare equal.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CompareGameplayAttributes
 * @Harness UClass
 * @Tag Optional.GAS.CompareGameplayAttributesEqual
 * @Provenance Theme: Optional.GAS. WorldStory: UTestCompareAttributes Speed vs Armor compare.
 * @Provenance C++: AngelscriptGASAttributeSetUtilityTests.cpp::CompareGameplayAttributesEqual
 * @Provenance Oracle: CompareGameplayAttributes(Speed, Speed) true; (Speed, Armor) false.
 * @Provenance Extra: two default FGameplayAttribute compare; FName AttributeName None is invalid.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Static lookup; runner supplies names.
 */

UCLASS()
class UTestCompareAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Speed;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Armor;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.CompareGameplayAttributes
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestCompareAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the same-attribute and different-attribute comparisons.
	 *
	 * @Kind Observe
	 * @Covers GAS.CompareGameplayAttributes
	 * @Inputs the Speed and Armor attributes resolved by name
	 * @Return true when Speed equals Speed but not Armor
	 */
	UFUNCTION()
	bool SameAndDifferent()
	{
		FGameplayAttribute SpeedA;
		FGameplayAttribute SpeedB;
		FGameplayAttribute ArmorAttr;

		if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestCompareAttributes, n"Speed", SpeedA))
		{
			return false;
		}
		if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestCompareAttributes, n"Speed", SpeedB))
		{
			return false;
		}
		if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestCompareAttributes, n"Armor", ArmorAttr))
		{
			return false;
		}
		if (!UAngelscriptAttributeSet::CompareGameplayAttributes(SpeedA, SpeedB))
		{
			return false;
		}
		return !UAngelscriptAttributeSet::CompareGameplayAttributes(SpeedA, ArmorAttr);
	}

	/**
	 * Observe that two default attributes still compare equal.
	 *
	 * @Kind Observe
	 * @Covers GAS.CompareGameplayAttributes
	 * @Inputs two default-constructed attributes
	 * @Return true when both are invalid and compare equal
	 * @Boundary default attributes
	 */
	UFUNCTION()
	bool EmptyDefaults()
	{
		FGameplayAttribute First;
		FGameplayAttribute Second;

		if (First.IsValid())
		{
			return false;
		}
		if (Second.IsValid())
		{
			return false;
		}
		return UAngelscriptAttributeSet::CompareGameplayAttributes(First, Second);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.CompareGameplayAttributes
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestCompareAttributesEmpty : UAngelscriptAttributeSet
{
}
