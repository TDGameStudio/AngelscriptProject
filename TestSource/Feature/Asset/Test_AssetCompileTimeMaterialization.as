// Theme: Feature.Asset. Value oracle for compile-time literal asset materialization.
// C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetCompileTimeMaterialization.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles.
// Oracle: FindObject MyMaterializedAsset; bInitialized==true after the asset block.
// Extra: class default bInitialized==false; getter null boundary returns false.
// FixtureIsolated. Keep UPROPERTY name bInitialized.

UCLASS()
class UMaterializedAssetCarrier : UObject
{
	UPROPERTY()
	bool bInitialized = false;
}

asset MyMaterializedAsset of UMaterializedAssetCarrier
{
	bInitialized = true;
}

bool Observe_MaterializedAsset_Initialized()
{
	UMaterializedAssetCarrier Asset = GetMyMaterializedAsset();
	return Asset != nullptr && Asset.bInitialized;
}

bool Observe_MaterializedAsset_EmptyDefaultFalse(UMaterializedAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetCompileTimeMaterialization setup: required Empty is null");
	}
	return Empty.bInitialized == false;
}

bool Observe_MaterializedAsset_NullBoundary()
{
	UMaterializedAssetCarrier Asset = nullptr;
	return Asset == nullptr;
}
