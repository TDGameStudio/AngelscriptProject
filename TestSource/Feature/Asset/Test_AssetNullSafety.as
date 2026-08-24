// Theme: Feature.Asset. Value oracle: a compiled asset getter is not null.
// C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetNullSafety ExpectGlobalInt 1.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
// Oracle: TestAssetNullCheck()==1 (non-null, Value==777).
// Extra: empty Value==777 class default; explicit null boundary.
// FixtureIsolated.

UCLASS()
class UNullSafeAssetCarrier : UObject
{
	UPROPERTY()
	int Value = 777;
}

asset MyNullSafeAsset of UNullSafeAssetCarrier
{
}

int TestAssetNullCheck()
{
	UNullSafeAssetCarrier Asset = GetMyNullSafeAsset();

	if (Asset == null)
	{
		return 0;
	}

	if (Asset.Value != 777)
	{
		return 0;
	}

	return 1;
}

int Observe_NullSafeAsset_EmptyDefault(UNullSafeAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetNullSafety setup: required Empty is null");
	}
	return Empty.Value;
}

bool Observe_NullSafeAsset_NullBoundary()
{
	UNullSafeAssetCarrier Asset = nullptr;
	return Asset == nullptr;
}

bool Observe_NullSafeAsset_CopyIndependence(UNullSafeAssetCarrier Original, UNullSafeAssetCarrier Copy)
{
	if (Original is null)
	{
		throw("Test_AssetNullSafety setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_AssetNullSafety setup: required Copy is null");
	}
	Copy.Value = 0;
	return Original.Value == 777 && Copy.Value == 0;
}
