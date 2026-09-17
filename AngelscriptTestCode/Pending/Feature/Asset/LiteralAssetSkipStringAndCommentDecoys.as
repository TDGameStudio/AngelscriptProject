/**
 * @version v1
 * @summary Positive preprocessor: `asset` inside a string or a comment is not expanded, while the real top-level declaration is. C++ keeps BuildAssetText and Entry, and the no-brace `asset RealAsset of UObject` form, so those names.
 * @topic Feature
 */
/**
 * @version root
 * @summary Positive preprocessor: `asset` inside a string or a comment is not expanded, while the real top-level declaration is. C++ keeps BuildAssetText and Entry, and the no-brace `asset RealAsset of UObject` form, so those names.
 * @topic Baseline
 */
namespace AssetTest
{
	/**
	 * Return a string that contains an asset declaration decoy.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetSkipStringAndCommentDecoys
	 * @Inputs none
	 * @Return the decoy text "asset FakeAsset of UObject"
	 */
	UFUNCTION()
	FString BuildAssetText()
	{
		return "asset FakeAsset of UObject";
	}

	// asset CommentAsset of UObject
	/**
	 * Return the length of the decoy string, which is the preprocessor oracle.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetSkipStringAndCommentDecoys
	 * @Inputs none
	 * @Return BuildAssetText().Len()
	 */
	UFUNCTION()
	int Entry()
	{
		return BuildAssetText().Len();
	}

	/**
	 * Observe the exact decoy string preserved by the preprocessor.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetSkipStringAndCommentDecoys
	 * @Inputs none
	 * @Return the decoy text "asset FakeAsset of UObject"
	 */
	UFUNCTION()
	FString BuildAssetTextExact()
	{
		return BuildAssetText();
	}

	/**
	 * Observe that a default FString has length 0.
	 *
	 * @Kind Observe
	 * @Covers Asset.LiteralAssetSkipStringAndCommentDecoys
	 * @Inputs a default-constructed FString
	 * @Return 0
	 * @Boundary empty string
	 */
	UFUNCTION()
	int EmptyStringLenDefault()
	{
		FString Empty;
		return Empty.Len();
	}
}

asset RealAsset of UObject
/** @end */
