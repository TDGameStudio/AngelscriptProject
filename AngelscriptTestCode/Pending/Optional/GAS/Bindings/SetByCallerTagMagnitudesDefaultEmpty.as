/**
 * @version v1
 * @summary The default ability spec's SetByCallerTagMagnitudes is empty, and a second default spec is the same. A default tag is invalid and the magnitudes stay empty.
 * @topic Optional
 */
/**
 * @version root
 * @summary The default ability spec's SetByCallerTagMagnitudes is empty, and a second default spec is the same. A default tag is invalid and the magnitudes stay empty.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Counts the set-by-caller magnitudes of a default spec.
	 *
	 * @Covers GAS.SetByCallerTagMagnitudesDefaultEmpty
	 * @Inputs a default-constructed spec
	 * @Return the magnitude count, 0 by default
	 */
	int DefaultSpecSetByCallerCount()
	{
		FGameplayAbilitySpec Spec;
		return Spec.SetByCallerTagMagnitudes.Num();
	}

	/**
	 * Observe the magnitude count of a default spec.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetByCallerTagMagnitudesDefaultEmpty
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int SetByCallerNominal()
	{
		return DefaultSpecSetByCallerCount();
	}

	/**
	 * Observe the combined magnitude count of two default specs.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetByCallerTagMagnitudesDefaultEmpty
	 * @Inputs two default-constructed specs
	 * @Return 0
	 * @Boundary second instance
	 */
	UFUNCTION()
	int SetByCallerSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;
		return First.SetByCallerTagMagnitudes.Num() + Second.SetByCallerTagMagnitudes.Num();
	}

	/**
	 * Observe that a default tag is invalid while both containers stay empty.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetByCallerTagMagnitudesDefaultEmpty
	 * @Inputs a default tag and a default spec
	 * @Return 0, or -1 if the empty tag reports valid
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int SetByCallerEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		FGameplayTag EmptyTag;
		if (EmptyTag.IsValid())
		{
			return -1;
		}
		return Spec.DynamicAbilityTags.Num() + Spec.SetByCallerTagMagnitudes.Num();
	}
}
/** @end */
