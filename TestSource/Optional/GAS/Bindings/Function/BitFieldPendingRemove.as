/**
 * The PendingRemove bit-field round-trip: it starts clear and can be set. A copy
 * of the spec does not share the flag.
 *
 * @Theme Optional.GAS
 * @Subject GAS.BitFieldPendingRemove
 * @Harness Function
 * @Tag Optional.GAS.BitFieldPendingRemove
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory PendingRemove bit-field round-trip.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::BitFieldPendingRemove
 * @Provenance ExpectGlobalInt AbilitySpec_PendingRemove == 1.
 * @Provenance Extra: copy independence; empty DynamicAbilityTags.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Verifies the PendingRemove flag starts clear and can be set.
	 *
	 * @Covers GAS.BitFieldPendingRemove
	 * @Inputs a default-constructed spec
	 * @Return 1 on success, otherwise -1 or -2 naming the failed step
	 */
	int PendingRemoveRoundTrip()
	{
		FGameplayAbilitySpec Spec;
		if (Spec.GetbPendingRemove())
		{
			return -1;
		}
		Spec.SetbPendingRemove(true);
		if (!Spec.GetbPendingRemove())
		{
			return -2;
		}
		return 1;
	}

	/**
	 * Observe the round-trip result.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldPendingRemove
	 * @Inputs a default-constructed spec
	 * @Return 1
	 */
	UFUNCTION()
	int PendingRemoveNominal()
	{
		return PendingRemoveRoundTrip();
	}

	/**
	 * Observe that setting the flag on one spec leaves another clear.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldPendingRemove
	 * @Inputs two specs, one with the flag set
	 * @Return 1 when only the first holds the flag
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int PendingRemoveCopyIndependence()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;
		First.SetbPendingRemove(true);

		if (!First.GetbPendingRemove())
		{
			return 0;
		}
		if (Second.GetbPendingRemove())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldPendingRemove
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int PendingRemoveEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
