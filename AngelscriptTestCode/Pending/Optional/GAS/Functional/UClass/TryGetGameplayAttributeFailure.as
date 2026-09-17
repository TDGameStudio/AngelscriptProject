/**
 * @version v1
 * @summary An attribute set whose static lookup returns false for a name that does not exist. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this module and asserts TestFalse, so this is a value oracle rather than a.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set whose static lookup returns false for a name that does not exist. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this module and asserts TestFalse, so this is a value oracle rather than a.
 * @topic Baseline
 */
UCLASS()
class UTestTryGetFailAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetGameplayAttributeFailure
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestTryGetFailAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that a non-existent attribute name is not found.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetGameplayAttributeFailure
	 * @Inputs the static lookup under a non-existent name
	 * @Return true when the lookup reports no valid attribute
	 * @Boundary invalid name
	 */
	UFUNCTION()
	bool NonExistentReturnsFalse()
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetFailAttributes, n"NonExistentAttribute", OutAttr);

		if (bFound)
		{
			return false;
		}

		return !OutAttr.IsValid();
	}

	/**
	 * Observe that an unset attribute name is not found.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetGameplayAttributeFailure
	 * @Inputs the static lookup under the supplied name
	 * @Return true when the lookup reports no valid attribute
	 * @Param AttributeName the name to reject
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyName(FName AttributeName)
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetFailAttributes, AttributeName, OutAttr);

		if (bFound)
		{
			return false;
		}

		return !OutAttr.IsValid();
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TryGetGameplayAttributeFailure
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestTryGetFailAttributesEmpty : UAngelscriptAttributeSet
{
}
/** @end */
