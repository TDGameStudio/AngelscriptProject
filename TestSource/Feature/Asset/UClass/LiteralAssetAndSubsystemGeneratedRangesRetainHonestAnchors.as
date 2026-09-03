/**
 * Preprocessor provenance for a literal asset and a subsystem accessor: the
 * generated ranges keep honest TCHAR/UTF-8 authored anchors. C++ compiles the
 * empty USourceProvenanceSubsystem together with SourceProvenanceAsset, so those
 * names and the non-ASCII prefix comment are part of the contract and are kept
 * verbatim. The observers cover a null asset handle and the generated getter.
 *
 * @Theme Feature.Asset
 * @Subject Asset.LiteralAssetAndSubsystemGeneratedRangesRetainHonestAnchors
 * @Harness UClass
 * @Tag Feature.Asset.LiteralAssetAndSubsystemGeneratedRangesRetainHonestAnchors
 * @Provenance Theme: Feature.Asset. Positive preprocessor provenance for asset + subsystem.
 * @Provenance C++: AngelscriptPreprocessorGeneratedSourceProvenanceTests.cpp::LiteralAssetAndSubsystemGeneratedRangesRetainHonestAnchors.
 * @Provenance Oracle: generated LiteralAsset and SubsystemAccessor ranges keep honest TCHAR/UTF-8 anchors.
 * @Provenance Extra: empty subsystem class; null asset boundary.
 * @Provenance DefaultSafe. Keep the non-ASCII prefix comment from C++.
 */

// 非 ASCII 前缀验证 TCHAR/UTF-8 offset 不会混用。
UCLASS()
class USourceProvenanceSubsystem : UEngineSubsystem
{
	/**
	 * Observe that an explicit null object handle compares equal to null.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetAndSubsystemGeneratedRangesRetainHonestAnchors
	 * @Inputs a null UObject handle
	 * @Return the null handle
	 * @Boundary null handle
	 */
	UFUNCTION()
	UObject SourceProvenanceAssetNullBoundary()
	{
		UObject Empty = nullptr;
		return Empty;
	}

	/**
	 * Observe that the generated getter returns a materialized asset.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetAndSubsystemGeneratedRangesRetainHonestAnchors
	 * @Inputs the generated GetSourceProvenanceAsset getter
	 * @Return true when the asset is non-null
	 */
	UFUNCTION()
	bool SourceProvenanceAssetGetterPresent()
	{
		UObject Asset = GetSourceProvenanceAsset();
		return Asset != nullptr;
	}
}

asset SourceProvenanceAsset of UObject
{
}
