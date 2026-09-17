/**
 * @version v1
 * @summary The ActivateOnce bit-field round-trip: it starts clear, can be set, and a copy of the spec does not share the flag.
 * @topic Optional
 */
/**
 * @version root
 * @summary The ActivateOnce bit-field round-trip: it starts clear, can be set, and a copy of the spec does not share the flag.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Verifies the ActivateOnce flag starts clear and can be set.
	 *
	 * @Covers GAS.BitFieldActivateOnce
	 * @Inputs a default-constructed spec
	 * @Return 1 on success, otherwise -1 or -2 naming the failed step
	 */
	int ActivateOnceRoundTrip()
	{
		FGameplayAbilitySpec Spec;
		if (Spec.GetbActivateOnce())
		{
			return -1;
		}
		Spec.SetbActivateOnce(true);
		if (!Spec.GetbActivateOnce())
		{
			return -2;
		}
		return 1;
	}

	/**
	 * Observe the round-trip result.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldActivateOnce
	 * @Inputs a default-constructed spec
	 * @Return 1
	 */
	UFUNCTION()
	int ActivateOnceNominal()
	{
		return ActivateOnceRoundTrip();
	}

	/**
	 * Observe that setting the flag on one spec leaves another clear.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldActivateOnce
	 * @Inputs two specs, one with the flag set
	 * @Return 1 when only the first holds the flag
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int ActivateOnceCopyIndependence()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;
		First.SetbActivateOnce(true);

		if (!First.GetbActivateOnce())
		{
			return 0;
		}
		if (Second.GetbActivateOnce())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldActivateOnce
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int ActivateOnceEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
/** @end */
