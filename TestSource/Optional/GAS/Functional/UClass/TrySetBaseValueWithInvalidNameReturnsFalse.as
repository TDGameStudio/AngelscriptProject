/**
 * An attribute set whose base-value write returns false for a name that does not
 * exist. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this module
 * and asserts TestFalse, so this is a value oracle rather than a compile failure.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TrySetBaseValueWithInvalidName
 * @Harness UClass
 * @Tag Optional.GAS.TrySetBaseValueWithInvalidNameReturnsFalse
 * @Provenance Theme: Optional.GAS. C++ compiles UTestInvalidSetAttributes then TrySet "NonExistent"
 * @Provenance returns false. CSV NegativeDiagnostic is a heuristic; CompileScriptModule + TestFalse
 * @Provenance is a value oracle, not a compile failure.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::TrySetBaseValueWithInvalidNameReturnsFalse
 * @Provenance Extra: nullptr handle; FName AttributeName None/invalid; empty sibling set.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.
 */

UCLASS()
class UTestInvalidSetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Valid;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueWithInvalidName
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestInvalidSetAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that a non-existent attribute name is rejected by the write.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueWithInvalidName
	 * @Inputs a registered set written under a non-existent name
	 * @Return true when the write reports failure
	 * @Param Set the instance to write against
	 * @Boundary invalid name
	 */
	UFUNCTION()
	bool NonExistentReturnsFalse(UTestInvalidSetAttributes Set)
	{
		if (Set == nullptr)
		{
			return false;
		}
		return !Set.TrySetAttributeBaseValue(n"NonExistent", 10.0f);
	}

	/**
	 * Observe that an unset attribute name is rejected by the write.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueWithInvalidName
	 * @Inputs a registered set and an unset attribute name
	 * @Return true when the write reports failure
	 * @Param Set the instance to write against
	 * @Param AttributeName the name to reject
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyNameReturnsFalse(UTestInvalidSetAttributes Set, FName AttributeName)
	{
		if (Set == nullptr)
		{
			return false;
		}
		return !Set.TrySetAttributeBaseValue(AttributeName, 10.0f);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TrySetBaseValueWithInvalidName
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestInvalidSetAttributesEmpty : UAngelscriptAttributeSet
{
}
