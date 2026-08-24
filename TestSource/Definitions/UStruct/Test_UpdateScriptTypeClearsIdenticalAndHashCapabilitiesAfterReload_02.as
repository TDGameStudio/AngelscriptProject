// Theme: Definitions.UStruct. HotReload After: drop opEquals/Hash, keep ToString only.
// C++: AngelscriptScriptStructHotReloadTests.cpp::UpdateScriptTypeClearsIdenticalAndHashCapabilitiesAfterReload block 2
// Retained: ToString binding. Replaced: Value==2, AddedValue==9, ToString "ToStringOnly".
// Extra: defaults; zeros; copy independence.
// DefaultSafe.

USTRUCT()
struct FReloadableCapabilityStruct
{
	UPROPERTY()
	int Value = 2;

	UPROPERTY()
	int AddedValue = 9;

	FString ToString() const
	{
		return "ToStringOnly";
	}
};

bool Observe_CapabilityV2_Nominal()
{
	FReloadableCapabilityStruct Reloaded;
	return Reloaded.Value == 2 && Reloaded.AddedValue == 9
		&& Reloaded.ToString() == "ToStringOnly";
}

bool Observe_CapabilityV2_ZeroBoundary()
{
	FReloadableCapabilityStruct Reloaded;
	Reloaded.Value = 0;
	Reloaded.AddedValue = 0;
	return Reloaded.Value == 0 && Reloaded.AddedValue == 0
		&& Reloaded.ToString() == "ToStringOnly";
}

bool Observe_CapabilityV2_CopyIndependence()
{
	FReloadableCapabilityStruct Original;
	FReloadableCapabilityStruct Copy = Original;
	Copy.Value = 0;
	Copy.AddedValue = 0;
	return Original.Value == 2 && Original.AddedValue == 9
		&& Copy.Value == 0 && Copy.AddedValue == 0;
}
