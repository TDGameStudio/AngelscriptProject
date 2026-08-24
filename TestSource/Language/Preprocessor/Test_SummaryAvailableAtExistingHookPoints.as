// Theme: Language.Preprocessor. Positive UCLASS used as ProcessChunks/PostProcessCode summary fixture.
// C++: AngelscriptPreprocessorSummaryTests.cpp::SummaryAvailableAtExistingHookPoints
// sha256=1dda679aae68530497692511e162d5a0ccf26309411b75370c0f3e6768d6ab2b; lines 176-183.
// Oracle: one class, one UPROPERTY Value; ProcessChunks PropertyCount 1, PostProcessCode length > 0.
// Extra: default Value is 0; second instance is independent. DefaultSafe.

UCLASS()
class USummaryHookCarrier : UObject
{
	UPROPERTY()
	int Value;
}

bool Observe_Value_DefaultEmpty()
{
	USummaryHookCarrier Carrier =
		Cast<USummaryHookCarrier>(
			NewObject(GetTransientPackage(), USummaryHookCarrier::StaticClass(), n"SummaryHookCarrier"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0353 setup: NewObject returned null");
	}
	return Carrier.Value == 0;
}

bool Observe_Value_CopyIndependence()
{
	USummaryHookCarrier First =
		Cast<USummaryHookCarrier>(
			NewObject(GetTransientPackage(), USummaryHookCarrier::StaticClass(), n"SummaryHookCarrierFirst"));
	USummaryHookCarrier Second =
		Cast<USummaryHookCarrier>(
			NewObject(GetTransientPackage(), USummaryHookCarrier::StaticClass(), n"SummaryHookCarrierSecond"));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-LANG-0353 setup: NewObject returned null");
	}
	First.Value = 11;
	return First.Value == 11 && Second.Value == 0;
}
