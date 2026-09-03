/**
 * An attribute set exposing Temperature that C++ drives down to a negative
 * value. The CSV NegativeDiagnostic is a heuristic; the real check is a value
 * oracle. The observers cover the null handle, the empty attribute data and
 * handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.AttributeChangeToNegativeValue
 * @Harness UClass
 * @Tag Optional.GAS.AttributeChangeToNegativeValue
 * @Provenance Theme: Optional.GAS. C++ compiles UTestNegativeAttributes then sets Temperature -10.
 * @Provenance CSV NegativeDiagnostic is a heuristic; CompileScriptModule + TestEqual(-10) is a
 * @Provenance value oracle, not a compile failure.
 * @Provenance C++: AngelscriptGASAttributeSetBPEventTests.cpp::AttributeChangeToNegativeValue
 * @Provenance Oracle: GetAttributeCurrentValue Temperature == -10.f.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns TrySet negative value.
 */

UCLASS()
class UTestNegativeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Temperature;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeChangeToNegativeValue
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNegativeAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeChangeToNegativeValue
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
	 * @Covers GAS.AttributeChangeToNegativeValue
	 * @Inputs this handle and a second handle
	 * @Return true when both are non-null and differ
	 * @Param Second the other handle to compare against
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestNegativeAttributes Second)
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
 * @Covers GAS.AttributeChangeToNegativeValue
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNegativeAttributesEmpty : UAngelscriptAttributeSet
{
}
