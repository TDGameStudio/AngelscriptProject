/**
 * The default ability spec's DynamicAbilityTags is empty, and a second default
 * spec is the same. A default gameplay tag is invalid.
 *
 * @Theme Optional.GAS
 * @Subject GAS.DynamicAbilityTagsDefaultEmpty
 * @Harness Function
 * @Tag Optional.GAS.DynamicAbilityTagsDefaultEmpty
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory default DynamicAbilityTags is empty.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::DynamicAbilityTagsDefaultEmpty
 * @Provenance ExpectGlobalInt AbilitySpec_DynTags == 0.
 * @Provenance Extra: empty FGameplayTag is invalid; second spec also empty.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Counts the dynamic ability tags of a default spec.
	 *
	 * @Covers GAS.DynamicAbilityTagsDefaultEmpty
	 * @Inputs a default-constructed spec
	 * @Return the tag count, 0 by default
	 */
	int DefaultSpecTagCount()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}

	/**
	 * Observe the tag count of a default spec.
	 *
	 * @Kind Observe
	 * @Covers GAS.DynamicAbilityTagsDefaultEmpty
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int DynamicTagsNominal()
	{
		return DefaultSpecTagCount();
	}

	/**
	 * Observe the combined tag count of two default specs.
	 *
	 * @Kind Observe
	 * @Covers GAS.DynamicAbilityTagsDefaultEmpty
	 * @Inputs two default-constructed specs
	 * @Return 0
	 * @Boundary second instance
	 */
	UFUNCTION()
	int DynamicTagsSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;
		return First.DynamicAbilityTags.Num() + Second.DynamicAbilityTags.Num();
	}

	/**
	 * Observe that a default tag is invalid while the tag list stays empty.
	 *
	 * @Kind Observe
	 * @Covers GAS.DynamicAbilityTagsDefaultEmpty
	 * @Inputs a default tag and a default spec
	 * @Return 0, or -1 if the empty tag reports valid
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int DynamicTagsEmptyTag()
	{
		FGameplayTag EmptyTag;
		FGameplayAbilitySpec Spec;
		if (EmptyTag.IsValid())
		{
			return -1;
		}
		return Spec.DynamicAbilityTags.Num();
	}
}
