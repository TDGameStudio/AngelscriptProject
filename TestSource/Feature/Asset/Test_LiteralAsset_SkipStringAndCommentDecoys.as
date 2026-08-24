// Theme: Feature.Asset. Positive preprocessor: string/comment `asset` decoys are skipped.
// C++: AngelscriptPreprocessorLiteralTests.cpp::LiteralAsset_SkipStringAndCommentDecoys.
// Oracle: Entry()==BuildAssetText().Len(); only RealAsset expands (GetRealAsset).
// Extra: empty FString Len==0; decoy text is preserved.
// DefaultSafe. Keep the C++ decoy source: asset RealAsset of UObject has no brace block.

asset RealAsset of UObject

FString BuildAssetText()
{
	return "asset FakeAsset of UObject";
}

// asset CommentAsset of UObject
int Entry()
{
	return BuildAssetText().Len();
}

int Observe_LiteralAssetDecoyEntry()
{
	return Entry();
}

FString Observe_BuildAssetText_Exact()
{
	return BuildAssetText();
}

int Observe_EmptyStringLenDefault()
{
	FString Empty;
	return Empty.Len();
}
