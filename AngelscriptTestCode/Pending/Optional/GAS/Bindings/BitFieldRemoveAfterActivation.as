/**
 * @version v1
 * @summary The RemoveAfterActivation bit-field round-trip: it starts clear and can be set. A copy of the spec does not share the flag.
 * @topic Optional
 */
/**
 * @version root
 * @summary The RemoveAfterActivation bit-field round-trip: it starts clear and can be set. A copy of the spec does not share the flag.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Verifies the RemoveAfterActivation flag starts clear and can be set.
	 *
	 * @Covers GAS.BitFieldRemoveAfterActivation
	 * @Inputs a default-constructed spec
	 * @Return 1 on success, otherwise -1 or -2 naming the failed step
	 */
	int RemoveAfterActivationRoundTrip()
	{
		FGameplayAbilitySpec Spec;
		if (Spec.GetbRemoveAfterActivation())
		{
			return -1;
		}
		Spec.SetbRemoveAfterActivation(true);
		if (!Spec.GetbRemoveAfterActivation())
		{
			return -2;
		}
		return 1;
	}

	/**
	 * Observe the round-trip result.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldRemoveAfterActivation
	 * @Inputs a default-constructed spec
	 * @Return 1
	 */
	UFUNCTION()
	int RemoveAfterActivationNominal()
	{
		return RemoveAfterActivationRoundTrip();
	}

	/**
	 * Observe that setting the flag on one spec leaves another clear.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldRemoveAfterActivation
	 * @Inputs two specs, one with the flag set
	 * @Return 1 when only the first holds the flag
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int RemoveAfterActivationCopyIndependence()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;
		First.SetbRemoveAfterActivation(true);

		if (!First.GetbRemoveAfterActivation())
		{
			return 0;
		}
		if (Second.GetbRemoveAfterActivation())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldRemoveAfterActivation
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int RemoveAfterActivationEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
/** @end */
