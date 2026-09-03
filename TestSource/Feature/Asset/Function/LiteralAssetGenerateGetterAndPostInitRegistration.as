/**
 * Positive preprocessor expansion of `asset PreviewAsset of UObject`: the
 * original declaration is stripped and a getter plus PostInit registration are
 * generated. C++ keeps Entry as a surviving function, so that name is part of
 * the contract and is kept verbatim. The observers cover a null object handle
 * and the generated getter.
 *
 * @Theme Feature.Asset
 * @Subject Asset.LiteralAssetGenerateGetterAndPostInitRegistration
 * @Harness Function
 * @Tag Feature.Asset.LiteralAssetGenerateGetterAndPostInitRegistration
 * @Namespace AssetTest
 * @Provenance Theme: Feature.Asset. Positive preprocessor: asset expands to getter + PostInit.
 * @Provenance C++: AngelscriptPreprocessorLiteralTests.cpp::LiteralAsset_GenerateGetterAndPostInitRegistration.
 * @Provenance Oracle: Entry()==7; original `asset PreviewAsset of UObject` is stripped after preprocess.
 * @Provenance Extra: empty asset block; Entry is independent of the asset instance.
 * @Provenance DefaultSafe.
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
