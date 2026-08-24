// Theme: Feature.Asset. Value oracle for incremental += in an asset block.
// C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetIncrementalInitialization ExpectGlobalInt 60.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
// Oracle: GetIncrementalCounter()==60.
// Extra: empty Counter==0; copy independence after mutating a carrier.
// FixtureIsolated.

UCLASS()
class UIncrementalAssetCarrier : UObject
{
	UPROPERTY()
	int Counter = 0;
}

asset MyIncrementalAsset of UIncrementalAssetCarrier
{
	Counter += 10;
	Counter += 20;
	Counter += 30;
}

int GetIncrementalCounter()
{
	UIncrementalAssetCarrier Asset = GetMyIncrementalAsset();
	return Asset != null ? Asset.Counter : -1;
}

int Observe_IncrementalAsset_EmptyDefault(UIncrementalAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetIncrementalInitialization setup: required Empty is null");
	}
	return Empty.Counter;
}

bool Observe_IncrementalAsset_CopyIndependence(UIncrementalAssetCarrier Original, UIncrementalAssetCarrier Copy)
{
	if (Original is null)
	{
		throw("Test_AssetIncrementalInitialization setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_AssetIncrementalInitialization setup: required Copy is null");
	}
	Copy.Counter += 4;
	return Original.Counter == 0 && Copy.Counter == 4;
}
