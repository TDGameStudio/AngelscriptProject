// Theme: Feature.Asset. Positive preprocessor provenance for asset + subsystem.
// C++: AngelscriptPreprocessorGeneratedSourceProvenanceTests.cpp::LiteralAssetAndSubsystemGeneratedRangesRetainHonestAnchors.
// Oracle: generated LiteralAsset and SubsystemAccessor ranges keep honest TCHAR/UTF-8 anchors.
// Extra: empty subsystem class; null asset boundary.
// DefaultSafe. Keep the non-ASCII prefix comment from C++.

// 非 ASCII 前缀验证 TCHAR/UTF-8 offset 不会混用。
UCLASS()
class USourceProvenanceSubsystem : UEngineSubsystem
{
}

asset SourceProvenanceAsset of UObject
{
}

UObject Observe_SourceProvenanceAsset_NullBoundary()
{
	UObject Empty = nullptr;
	return Empty;
}

bool Observe_SourceProvenanceAsset_GetterPresent()
{
	UObject Asset = GetSourceProvenanceAsset();
	return Asset != nullptr;
}
