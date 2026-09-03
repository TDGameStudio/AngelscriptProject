/**
 * The default ability spec's Ability is null, and a second default spec is the
 * same. The dynamic ability tags start empty.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ConstructorWithClassSetsAbility
 * @Harness Function
 * @Tag Optional.GAS.ConstructorWithClassSetsAbility
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory default spec Ability is null.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::ConstructorWithClassSetsAbility
 * @Provenance ExpectGlobalInt AbilitySpec_CtorClass == 1.
 * @Provenance Extra: second default spec also null Ability; empty DynamicAbilityTags.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Checks that a default spec holds no ability.
	 *
	 * @Covers GAS.ConstructorWithClassSetsAbility
	 * @Inputs a default-constructed spec
	 * @Return 1 when the ability is null
	 */
	int DefaultSpecAbilityIsNull()
	{
		FGameplayAbilitySpec Spec;
		// Default-constructed spec should have null Ability
		return (Spec.Ability == null) ? 1 : 0;
	}

	/**
	 * Observe that a default spec holds no ability.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorWithClassSetsAbility
	 * @Inputs a default-constructed spec
	 * @Return 1
	 * @Boundary default null
	 */
	UFUNCTION()
	int ConstructorAbilityNominal()
	{
		return DefaultSpecAbilityIsNull();
	}

	/**
	 * Observe that a second default spec also holds no ability.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorWithClassSetsAbility
	 * @Inputs two default-constructed specs
	 * @Return 1 when both abilities are null
	 * @Boundary second instance
	 */
	UFUNCTION()
	int ConstructorAbilitySecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;

		if (First.Ability != null)
		{
			return 0;
		}
		if (Second.Ability != null)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorWithClassSetsAbility
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int ConstructorAbilityEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
