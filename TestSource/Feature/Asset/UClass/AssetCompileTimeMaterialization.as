/**
 * Compile-time materialization of a literal asset: after the module compiles, the
 * named asset exists and its initialization block has already run. C++ finds
 * MyMaterializedAsset and reads bInitialized, so that UPROPERTY name is part of
 * the contract and is kept verbatim. The observers cover the class default, a
 * null handle, and the generated getter.
 *
 * @Theme Feature.Asset
 * @Subject Asset.AssetCompileTimeMaterialization
 * @Harness UClass
 * @Tag Feature.Asset.AssetCompileTimeMaterialization
 * @Provenance Theme: Feature.Asset. Value oracle for compile-time literal asset materialization.
 * @Provenance C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetCompileTimeMaterialization.
 * @Provenance CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles.
 * @Provenance Oracle: FindObject MyMaterializedAsset; bInitialized==true after the asset block.
 * @Provenance Extra: class default bInitialized==false; getter null boundary returns false.
 * @Provenance FixtureIsolated. Keep UPROPERTY name bInitialized.
 */

UCLASS()
class UMaterializedAssetCarrier : UObject
{
	UPROPERTY()
	bool bInitialized = false;

	/**
	 * Observe that the generated getter returns the materialized asset with its
	 * initialization block already applied.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetCompileTimeMaterialization
	 * @Inputs the generated GetMyMaterializedAsset getter
	 * @Return true when the asset is non-null and bInitialized is true
	 */
	UFUNCTION()
	bool MaterializedAssetInitialized()
	{
		UMaterializedAssetCarrier Asset = GetMyMaterializedAsset();
		if (Asset == nullptr)
		{
			return false;
		}
		return Asset.bInitialized;
	}

	/**
	 * Observe that a fresh carrier keeps the class default, which is false.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetCompileTimeMaterialization
	 * @Inputs a freshly constructed carrier
	 * @Return true when bInitialized is false
	 * @Boundary class default
	 */
	UFUNCTION()
	bool EmptyDefaultFalse()
	{
		return bInitialized == false;
	}

	/**
	 * Observe that an explicit null handle compares equal to null.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetCompileTimeMaterialization
	 * @Inputs a null carrier handle
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullBoundary()
	{
		UMaterializedAssetCarrier Asset = nullptr;
		return Asset == nullptr;
	}
}

asset MyMaterializedAsset of UMaterializedAssetCarrier
{
	bInitialized = true;
}
