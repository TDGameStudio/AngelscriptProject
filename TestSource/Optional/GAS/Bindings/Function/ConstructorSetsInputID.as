/**
 * The default ability spec's InputID is -1, and a second default spec is the
 * same. The dynamic ability tags start empty.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ConstructorSetsInputID
 * @Harness Function
 * @Tag Optional.GAS.ConstructorSetsInputID
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory default FGameplayAbilitySpec.InputID.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::ConstructorSetsInputID
 * @Provenance ExpectGlobalInt AbilitySpec_CtorInputID == -1.
 * @Provenance Extra: second default spec also InputID -1; empty DynamicAbilityTags.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Reads the input ID of a default ability spec.
	 *
	 * @Covers GAS.ConstructorSetsInputID
	 * @Inputs a default-constructed spec
	 * @Return the InputID, -1 by default
	 */
	int DefaultSpecInputID()
	{
		FGameplayAbilitySpec Spec;
		return Spec.InputID;
	}

	/**
	 * Observe the input ID of a default spec.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorSetsInputID
	 * @Inputs a default-constructed spec
	 * @Return -1
	 * @Boundary default value
	 */
	UFUNCTION()
	int ConstructorInputIDNominal()
	{
		return DefaultSpecInputID();
	}

	/**
	 * Observe that a second default spec carries the same input ID.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorSetsInputID
	 * @Inputs two default-constructed specs
	 * @Return 1 when both report -1
	 * @Boundary second instance
	 */
	UFUNCTION()
	int ConstructorInputIDSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;

		if (First.InputID != -1)
		{
			return 0;
		}
		if (Second.InputID != -1)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorSetsInputID
	 * @Inputs a default tag and a default spec
	 * @Return 0, or -1 if the empty tag reports valid
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int ConstructorInputIDEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		FGameplayTag EmptyTag;
		if (EmptyTag.IsValid())
		{
			return -1;
		}
		return Spec.DynamicAbilityTags.Num();
	}
}
