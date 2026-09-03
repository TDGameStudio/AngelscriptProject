/**
 * An invalid attribute's GetAttributeSetClass is the null vector rather than an
 * error, and a second default attribute is the same. A default tag is invalid.
 *
 * @Theme Optional.GAS
 * @Subject GAS.AttributeSetClassNullWhenInvalid
 * @Harness Function
 * @Tag Optional.GAS.FGameplayAttributeGetAttributeSetClassReturnsNullWhenInvalid
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. C++ ExecuteIntFunction InvalidAttributeSetClassIsNull == 1.
 * @Provenance CSV NegativeDiagnostic is a heuristic; default FGameplayAttribute class is null.
 * @Provenance C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::FGameplayAttributeGetAttributeSetClassReturnsNullWhenInvalid
 * @Provenance Extra: second default also null; empty tag.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Checks that an invalid attribute reports a null set class.
	 *
	 * @Covers GAS.AttributeSetClassNullWhenInvalid
	 * @Inputs a default-constructed attribute
	 * @Return 1 when the set class is null
	 */
	int InvalidAttributeSetClassIsNull()
	{
		FGameplayAttribute Attr;
		return Attr.GetAttributeSetClass() == null ? 1 : 0;
	}

	/**
	 * Observe that an invalid attribute reports a null set class.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeSetClassNullWhenInvalid
	 * @Inputs a default-constructed attribute
	 * @Return 1
	 * @Boundary default value
	 */
	UFUNCTION()
	int InvalidAttributeSetClassNominal()
	{
		return InvalidAttributeSetClassIsNull();
	}

	/**
	 * Observe that a second invalid attribute is also null.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeSetClassNullWhenInvalid
	 * @Inputs two default-constructed attributes
	 * @Return 1 when both report null
	 * @Boundary second instance
	 */
	UFUNCTION()
	int InvalidAttributeSetClassSecondDefault()
	{
		FGameplayAttribute First;
		FGameplayAttribute Second;

		if (First.GetAttributeSetClass() != null)
		{
			return 0;
		}
		if (Second.GetAttributeSetClass() != null)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeSetClassNullWhenInvalid
	 * @Inputs a default-constructed tag
	 * @Return 1
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int InvalidAttributeSetClassEmptyTag()
	{
		FGameplayTag EmptyTag;
		return EmptyTag.IsValid() ? 0 : 1;
	}
}
