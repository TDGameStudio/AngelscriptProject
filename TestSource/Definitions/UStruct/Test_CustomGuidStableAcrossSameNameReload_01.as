// Theme: Definitions.UStruct. HotReload Before: stable custom GUID baseline.
// C++: AngelscriptScriptStructHotReloadTests.cpp::CustomGuidStableAcrossSameNameReload block 1
// Oracle: compile publishes FStableGuidStruct with a valid custom GUID (C++ side).
// Retained across same-name reload: custom GUID. Extra: default Value==1; zero; copy independence.
// DefaultSafe.

USTRUCT()
struct FStableGuidStruct
{
	UPROPERTY()
	int Value = 1;
};

int Observe_StableGuidV1_DefaultValue()
{
	FStableGuidStruct Stable;
	return Stable.Value;
}

int Observe_StableGuidV1_ZeroBoundary()
{
	FStableGuidStruct Stable;
	Stable.Value = 0;
	return Stable.Value;
}

bool Observe_StableGuidV1_CopyIndependence()
{
	FStableGuidStruct Original;
	FStableGuidStruct Copy = Original;
	Copy.Value = 0;
	return Original.Value == 1 && Copy.Value == 0;
}
