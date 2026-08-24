// Theme: Definitions.UStruct. Different-name struct; GUID must not collide with FStableGuidStruct.
// C++: AngelscriptScriptStructHotReloadTests.cpp::CustomGuidStableAcrossSameNameReload block 3
// Oracle: FDifferentGuidStruct publishes a valid GUID unequal to the stable struct GUID.
// Extra: default Value==7; zero; copy independence.
// DefaultSafe.

USTRUCT()
struct FDifferentGuidStruct
{
	UPROPERTY()
	int Value = 7;
};

int Observe_DifferentGuid_DefaultValue()
{
	FDifferentGuidStruct Other;
	return Other.Value;
}

int Observe_DifferentGuid_ZeroBoundary()
{
	FDifferentGuidStruct Other;
	Other.Value = 0;
	return Other.Value;
}

bool Observe_DifferentGuid_CopyIndependence()
{
	FDifferentGuidStruct Original;
	FDifferentGuidStruct Copy = Original;
	Copy.Value = 0;
	return Original.Value == 7 && Copy.Value == 0;
}
