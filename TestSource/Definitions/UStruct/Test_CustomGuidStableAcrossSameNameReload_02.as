// Theme: Definitions.UStruct. HotReload After: same FStableGuidStruct name, added member.
// C++: AngelscriptScriptStructHotReloadTests.cpp::CustomGuidStableAcrossSameNameReload block 2
// Retained: Value and custom GUID. Replaced layout: AddedValue==2.
// Extra: defaults 1/2; zeros; copy independence.
// DefaultSafe.

USTRUCT()
struct FStableGuidStruct
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
};

bool Observe_StableGuidV2_Defaults()
{
	FStableGuidStruct Stable;
	return Stable.Value == 1 && Stable.AddedValue == 2;
}

bool Observe_StableGuidV2_ZeroBoundary()
{
	FStableGuidStruct Stable;
	Stable.Value = 0;
	Stable.AddedValue = 0;
	return Stable.Value == 0 && Stable.AddedValue == 0;
}

bool Observe_StableGuidV2_CopyIndependence()
{
	FStableGuidStruct Original;
	FStableGuidStruct Copy = Original;
	Copy.Value = 0;
	Copy.AddedValue = 0;
	return Original.Value == 1 && Original.AddedValue == 2
		&& Copy.Value == 0 && Copy.AddedValue == 0;
}
