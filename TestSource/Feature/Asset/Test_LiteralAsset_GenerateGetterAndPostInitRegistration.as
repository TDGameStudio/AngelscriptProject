// Theme: Feature.Asset. Positive preprocessor: asset expands to getter + PostInit.
// C++: AngelscriptPreprocessorLiteralTests.cpp::LiteralAsset_GenerateGetterAndPostInitRegistration.
// Oracle: Entry()==7; original `asset PreviewAsset of UObject` is stripped after preprocess.
// Extra: empty asset block; Entry is independent of the asset instance.
// DefaultSafe.

asset PreviewAsset of UObject
{
}

int Entry()
{
	return 7;
}

int Observe_LiteralAssetEntry()
{
	return Entry();
}

UObject Observe_PreviewAsset_NullBoundary()
{
	UObject Empty = nullptr;
	return Empty;
}

bool Observe_PreviewAsset_GetterPresent()
{
	UObject Asset = GetPreviewAsset();
	return Asset != nullptr;
}
