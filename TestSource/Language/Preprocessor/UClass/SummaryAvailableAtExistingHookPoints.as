/**
 * A minimal UCLASS used as a summary fixture: the preprocessor summary must
 * count exactly one class and one property, and the PostProcessCode hook must
 * receive non-empty code. The observers confirm the property default and that
 * two instances do not share state.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.SummaryAvailableAtExistingHookPoints
 * @Harness UClass
 * @Tag Language.Preprocessor.SummaryAvailableAtExistingHookPoints
 * @Provenance C++: AngelscriptPreprocessorSummaryTests.cpp::SummaryAvailableAtExistingHookPoints
 * @Provenance sha256=1dda679aae68530497692511e162d5a0ccf26309411b75370c0f3e6768d6ab2b; lines 176-183.
 * @Provenance Oracle: one class, one UPROPERTY Value; ProcessChunks PropertyCount 1, PostProcessCode length > 0.
 * @Provenance Extra: default Value is 0; second instance is independent. DefaultSafe.
 */

UCLASS()
class USummaryHookCarrier : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe that the property defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs a freshly constructed carrier
	 * @Return true when Value is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool SummaryValueDefaultsToZero()
	{
		return Value == 0;
	}

	/**
	 * Observe that writing this carrier leaves a sibling untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs this carrier written to, compared against a second carrier
	 * @Return true when this carrier holds the write and the other stays zero
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool SummaryValueIsIndependentAcrossInstances()
	{
		USummaryHookCarrier Other =
			Cast<USummaryHookCarrier>(
				NewObject(GetTransientPackage(), USummaryHookCarrier::StaticClass(), n"SummaryHookCarrierOther"));
		if (Other == nullptr)
		{
			throw("TS-LANG-0353 setup: NewObject returned null");
		}

		Value = 11;

		if (Value != 11)
		{
			return false;
		}

		return Other.Value == 0;
	}
}
