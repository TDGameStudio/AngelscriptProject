/**
 * A default ability spec is not active, and a second default spec is the same.
 * The dynamic ability tags start empty.
 *
 * @Theme Optional.GAS
 * @Subject GAS.IsActiveDefaultFalse
 * @Harness Function
 * @Tag Optional.GAS.IsActiveDefaultFalse
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory default spec is not active.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::IsActiveDefaultFalse
 * @Provenance ExpectGlobalInt AbilitySpec_IsActive == 1 (IsActive is false).
 * @Provenance Extra: second default spec also inactive; empty DynamicAbilityTags.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Checks that a default spec reports inactive.
	 *
	 * @Covers GAS.IsActiveDefaultFalse
	 * @Inputs a default-constructed spec
	 * @Return 1 when the spec is inactive
	 */
	int DefaultSpecIsInactive()
	{
		FGameplayAbilitySpec Spec;
		return Spec.IsActive() ? 0 : 1;
	}

	/**
	 * Observe that a default spec reports inactive.
	 *
	 * @Kind Observe
	 * @Covers GAS.IsActiveDefaultFalse
	 * @Inputs a default-constructed spec
	 * @Return 1
	 * @Boundary default value
	 */
	UFUNCTION()
	int IsActiveNominal()
	{
		return DefaultSpecIsInactive();
	}

	/**
	 * Observe that a second default spec is also inactive.
	 *
	 * @Kind Observe
	 * @Covers GAS.IsActiveDefaultFalse
	 * @Inputs two default-constructed specs
	 * @Return 1 when both report inactive
	 * @Boundary second instance
	 */
	UFUNCTION()
	int IsActiveSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;

		if (First.IsActive())
		{
			return 0;
		}
		if (Second.IsActive())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.IsActiveDefaultFalse
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int IsActiveEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
