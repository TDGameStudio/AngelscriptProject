/**
 * @version v1
 * @summary Compile-time materialization of a literal asset: after the module compiles, the named asset exists and its initialization block has already run. C++ finds MyMaterializedAsset and reads bInitialized, so that UPROPERTY.
 * @topic Feature
 */
/**
 * @version root
 * @summary Compile-time materialization of a literal asset: after the module compiles, the named asset exists and its initialization block has already run. C++ finds MyMaterializedAsset and reads bInitialized, so that UPROPERTY.
 * @topic Baseline
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
/** @end */
