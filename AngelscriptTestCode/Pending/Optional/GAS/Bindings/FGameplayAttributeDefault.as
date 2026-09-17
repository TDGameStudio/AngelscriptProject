/**
 * @version v1
 * @summary A default FGameplayAttribute is the false/invalid vector rather than an error, and a second default attribute is the same. A default tag is also invalid.
 * @topic Optional
 */
/**
 * @version root
 * @summary A default FGameplayAttribute is the false/invalid vector rather than an error, and a second default attribute is the same. A default tag is also invalid.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Checks that a default attribute reports invalid.
	 *
	 * @Covers GAS.AttributeDefault
	 * @Inputs a default-constructed attribute
	 * @Return 1 when the attribute is invalid
	 */
	int DefaultAttributeIsInvalid()
	{
		FGameplayAttribute Attr;
		return Attr.IsValid() ? 0 : 1;
	}

	/**
	 * Observe that a default attribute reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeDefault
	 * @Inputs a default-constructed attribute
	 * @Return 1
	 * @Boundary default value
	 */
	UFUNCTION()
	int AttributeDefaultNominal()
	{
		return DefaultAttributeIsInvalid();
	}

	/**
	 * Observe that a second default attribute is also invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeDefault
	 * @Inputs two default-constructed attributes
	 * @Return 1 when both report invalid
	 * @Boundary second instance
	 */
	UFUNCTION()
	int AttributeDefaultSecondDefault()
	{
		FGameplayAttribute First;
		FGameplayAttribute Second;

		if (First.IsValid())
		{
			return 0;
		}
		if (Second.IsValid())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeDefault
	 * @Inputs a default-constructed tag
	 * @Return 1
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int AttributeDefaultEmptyTag()
	{
		FGameplayTag EmptyTag;
		return EmptyTag.IsValid() ? 0 : 1;
	}
}
/** @end */
