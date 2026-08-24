// Theme: Feature.Asset. Value oracle: two assets of the same class coexist.
// C++: AngelscriptLiteralAssetPostInitTests.cpp::MultipleAssetsInSameClassCoexist.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; C++ bCompiled true.
// Oracle: FirstAsset.Marker==10; SecondAsset.Marker==20; FirstAsset != SecondAsset.
// Extra: empty Marker==0; copy independence of a fresh owner.
// FixtureIsolated. Keep UPROPERTY name Marker.

UCLASS()
class UMultiAssetOwner : UObject
{
	UPROPERTY()
	int Marker = 0;
}

asset FirstAsset of UMultiAssetOwner
{
	Marker = 10;
}

asset SecondAsset of UMultiAssetOwner
{
	Marker = 20;
}

int Observe_FirstAssetMarker()
{
	UMultiAssetOwner Asset = GetFirstAsset();
	return Asset != nullptr ? Asset.Marker : -1;
}

int Observe_SecondAssetMarker()
{
	UMultiAssetOwner Asset = GetSecondAsset();
	return Asset != nullptr ? Asset.Marker : -1;
}

bool Observe_AssetsIndependent()
{
	UMultiAssetOwner First = GetFirstAsset();
	UMultiAssetOwner Second = GetSecondAsset();
	return First != nullptr && Second != nullptr && First != Second;
}

int Observe_MultiAsset_EmptyDefault(UMultiAssetOwner Empty)
{
	if (Empty is null)
	{
		throw("Test_MultipleAssetsInSameClassCoexist setup: required Empty is null");
	}
	return Empty.Marker;
}

bool Observe_MultiAsset_CopyIndependence(UMultiAssetOwner Original, UMultiAssetOwner Copy)
{
	if (Original is null)
	{
		throw("Test_MultipleAssetsInSameClassCoexist setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_MultipleAssetsInSameClassCoexist setup: required Copy is null");
	}
	Copy.Marker = 3;
	return Original.Marker == 0 && Copy.Marker == 3;
}
