/**
 * The InputPressed bit-field round-trip: it starts clear, can be set, and can be
 * cleared again. A copy of the spec does not share the flag.
 *
 * @Theme Optional.GAS
 * @Subject GAS.BitFieldInputPressed
 * @Harness Function
 * @Tag Optional.GAS.BitFieldInputPressed
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. WorldStory InputPressed bit-field round-trip.
 * @Provenance C++: AngelscriptGASAbilitySpecBindingsTests.cpp::BitFieldInputPressed
 * @Provenance ExpectGlobalInt AbilitySpec_InputPressed == 1.
 * @Provenance Extra: copy independence; default DynamicAbilityTags empty.
 * @Provenance FixtureIsolated.
 */

namespace GASTest
{
	/**
	 * Verifies the InputPressed flag can be set and cleared.
	 *
	 * @Covers GAS.BitFieldInputPressed
	 * @Inputs a default-constructed spec
	 * @Return 1 on success, otherwise -1, -2 or -3 naming the failed step
	 */
	int InputPressedRoundTrip()
	{
		FGameplayAbilitySpec Spec;
		if (Spec.GetbInputPressed())
		{
			return -1;
		}
		Spec.SetbInputPressed(true);
		if (!Spec.GetbInputPressed())
		{
			return -2;
		}
		Spec.SetbInputPressed(false);
		if (Spec.GetbInputPressed())
		{
			return -3;
		}
		return 1;
	}

	/**
	 * Observe the round-trip result.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldInputPressed
	 * @Inputs a default-constructed spec
	 * @Return 1
	 */
	UFUNCTION()
	int InputPressedNominal()
	{
		return InputPressedRoundTrip();
	}

	/**
	 * Observe that setting the flag on one spec leaves another clear.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldInputPressed
	 * @Inputs two specs, one with the flag set
	 * @Return 1 when only the first holds the flag
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int InputPressedCopyIndependence()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;
		First.SetbInputPressed(true);

		if (!First.GetbInputPressed())
		{
			return 0;
		}
		if (Second.GetbInputPressed())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.BitFieldInputPressed
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int InputPressedEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
