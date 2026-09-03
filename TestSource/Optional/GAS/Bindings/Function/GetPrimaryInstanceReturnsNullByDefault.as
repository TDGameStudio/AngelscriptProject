/**
 * A default ability spec's primary instance is the null vector rather than an
 * error, and a second default spec is the same. The dynamic ability tags start
 * empty.
 *
 * @Theme Optional.GAS
 * @Subject GAS.PrimaryInstanceNullByDefault
 * @Harness Function
 * @Tag Optional.GAS.GetPrimaryInstanceReturnsNullByDefault
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory default GetPrimaryInstance is null.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::GetPrimaryInstanceReturnsNullByDefault
 * @Provenance ExpectGlobalInt AbilitySpec_PrimaryInstance == 1.
 * @Provenance Extra: second default spec also null; empty DynamicAbilityTags.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Checks that a default spec has no primary instance.
	 *
	 * @Covers GAS.PrimaryInstanceNullByDefault
	 * @Inputs a default-constructed spec
	 * @Return 1 when the primary instance is null
	 */
	int DefaultSpecPrimaryInstanceIsNull()
	{
		FGameplayAbilitySpec Spec;
		return (Spec.GetPrimaryInstance() == null) ? 1 : 0;
	}

	/**
	 * Observe that a default spec has no primary instance.
	 *
	 * @Kind Observe
	 * @Covers GAS.PrimaryInstanceNullByDefault
	 * @Inputs a default-constructed spec
	 * @Return 1
	 * @Boundary default null
	 */
	UFUNCTION()
	int PrimaryInstanceNominal()
	{
		return DefaultSpecPrimaryInstanceIsNull();
	}

	/**
	 * Observe that a second default spec also has no primary instance.
	 *
	 * @Kind Observe
	 * @Covers GAS.PrimaryInstanceNullByDefault
	 * @Inputs two default-constructed specs
	 * @Return 1 when both report null
	 * @Boundary second instance
	 */
	UFUNCTION()
	int PrimaryInstanceSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;

		if (First.GetPrimaryInstance() != null)
		{
			return 0;
		}
		if (Second.GetPrimaryInstance() != null)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.PrimaryInstanceNullByDefault
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int PrimaryInstanceEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
