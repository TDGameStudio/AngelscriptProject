/**
 * @version v1
 * @summary An attribute set whose current-value read returns false for a name that does not exist. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this module and asserts TestFalse, so this is a value oracle rather.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set whose current-value read returns false for a name that does not exist. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this module and asserts TestFalse, so this is a value oracle rather.
 * @topic Baseline
 */
UCLASS()
class UTestInvalidGetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Valid;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetCurrentValueWithInvalidName
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestInvalidGetAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that a non-existent attribute name is rejected by the read.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetCurrentValueWithInvalidName
	 * @Inputs a registered set read under a non-existent name
	 * @Return true when the read reports failure
	 * @Param Set the instance to read against
	 * @Boundary invalid name
	 */
	UFUNCTION()
	bool NonExistentReturnsFalse(UTestInvalidGetAttributes Set)
	{
		if (Set == nullptr)
		{
			return false;
		}
		float OutValue = 0.0f;
		return !Set.TryGetAttributeCurrentValue(n"NonExistent", OutValue);
	}

	/**
	 * Observe that an unset attribute name is rejected by the read.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetCurrentValueWithInvalidName
	 * @Inputs a registered set and an unset attribute name
	 * @Return true when the read reports failure
	 * @Param Set the instance to read against
	 * @Param AttributeName the name to reject
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyNameReturnsFalse(UTestInvalidGetAttributes Set, FName AttributeName)
	{
		if (Set == nullptr)
		{
			return false;
		}
		float OutValue = 0.0f;
		return !Set.TryGetAttributeCurrentValue(AttributeName, OutValue);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TryGetCurrentValueWithInvalidName
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestInvalidGetAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
