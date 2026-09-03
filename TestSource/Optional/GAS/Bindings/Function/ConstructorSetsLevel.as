/**
 * The default ability spec's Level is 1, and a second default spec is the same.
 * The dynamic ability tags start empty.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ConstructorSetsLevel
 * @Harness Function
 * @Tag Optional.GAS.ConstructorSetsLevel
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory default FGameplayAbilitySpec.Level.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::ConstructorSetsLevel
 * @Provenance ExpectGlobalInt AbilitySpec_CtorLevel == 1.
 * @Provenance Extra: second default spec also Level 1; empty DynamicAbilityTags.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Reads the level of a default ability spec.
	 *
	 * @Covers GAS.ConstructorSetsLevel
	 * @Inputs a default-constructed spec
	 * @Return the Level, 1 by default
	 */
	int DefaultSpecLevel()
	{
		FGameplayAbilitySpec Spec;
		return Spec.Level;
	}

	/**
	 * Observe the level of a default spec.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorSetsLevel
	 * @Inputs a default-constructed spec
	 * @Return 1
	 * @Boundary default value
	 */
	UFUNCTION()
	int ConstructorLevelNominal()
	{
		return DefaultSpecLevel();
	}

	/**
	 * Observe that a second default spec carries the same level.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorSetsLevel
	 * @Inputs two default-constructed specs
	 * @Return 1 when both report 1
	 * @Boundary second instance
	 */
	UFUNCTION()
	int ConstructorLevelSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;

		if (First.Level != 1)
		{
			return 0;
		}
		if (Second.Level != 1)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.ConstructorSetsLevel
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int ConstructorLevelEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
