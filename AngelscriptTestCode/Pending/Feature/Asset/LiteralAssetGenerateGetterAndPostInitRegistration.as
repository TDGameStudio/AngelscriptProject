/**
 * @version v1
 * @summary Positive preprocessor expansion of `asset PreviewAsset of UObject`: the original declaration is stripped and a getter plus PostInit registration are generated. C++ keeps Entry as a surviving function, so that name is.
 * @topic Feature
 */
/**
 * @version root
 * @summary Positive preprocessor expansion of `asset PreviewAsset of UObject`: the original declaration is stripped and a getter plus PostInit registration are generated. C++ keeps Entry as a surviving function, so that name is.
 * @topic Baseline
 */
asset PreviewAsset of UObject
{
}

namespace AssetTest
{
	/**
	 * Return a constant that must survive preprocessor expansion.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetGenerateGetterAndPostInitRegistration
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int Entry()
	{
		return 7;
	}

	/**
	 * Observe that an explicit null object handle is null.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetGenerateGetterAndPostInitRegistration
	 * @Inputs a null UObject handle
	 * @Return the null handle
	 * @Boundary null handle
	 */
	UFUNCTION()
	UObject PreviewAssetNullBoundary()
	{
		UObject Empty = nullptr;
		return Empty;
	}

	/**
	 * Observe that the generated getter returns a materialized asset.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetGenerateGetterAndPostInitRegistration
	 * @Inputs the generated GetPreviewAsset getter
	 * @Return true when the asset is non-null
	 */
	UFUNCTION()
	bool PreviewAssetGetterPresent()
	{
		UObject Asset = GetPreviewAsset();
		return Asset != nullptr;
	}
}
/** @end */
