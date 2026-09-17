/**
 * @version v1
 * @summary An attribute set created with NewObject and never registered, so its base-value write must fail for want of an owning ASC. The observers cover the null handle, the unowned write and the NAME_None rejection.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set created with NewObject and never registered, so its base-value write must fail for want of an owning ASC. The observers cover the null handle, the unowned write and the NAME_None rejection.
 * @topic Baseline
 */
UCLASS()
class UTestNoASCAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Fortitude;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueFailsWithoutASC
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNoASCAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that an unregistered set rejects the base-value write.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueFailsWithoutASC
	 * @Inputs an unregistered set written to 10
	 * @Return true when the write reports failure
	 * @Param Set the unregistered instance to write against
	 * @Boundary unowned set
	 */
	UFUNCTION()
	bool UnownedSetFails(UTestNoASCAttributes Set)
	{
		if (Set == nullptr)
		{
			return false;
		}
		return !Set.TrySetAttributeBaseValue(n"Fortitude", 10.0f);
	}

	/**
	 * Observe that an unset attribute name is rejected by the write.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueFailsWithoutASC
	 * @Inputs an unregistered set and an unset attribute name
	 * @Return true when the write reports failure
	 * @Param Set the instance to write against
	 * @Param AttributeName the name to reject, expected to be NAME_None
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyNameReturnsFalse(UTestNoASCAttributes Set, FName AttributeName)
	{
		if (Set == nullptr)
		{
			return false;
		}
		return !Set.TrySetAttributeBaseValue(AttributeName, 0.0f);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TrySetBaseValueFailsWithoutASC
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNoASCAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
