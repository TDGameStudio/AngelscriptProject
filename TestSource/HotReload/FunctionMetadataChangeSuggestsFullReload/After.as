// Theme: HotReload VersionPair After. GetValue DisplayName becomes Beta.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionMetadataChangeSuggestsFullReload
// Retained: class, GetValue body return 1.
// Replaced: function metadata DisplayName Alpha -> Beta. FullReloadSuggested.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationFunctionMetadataTarget : UObject
{
	UFUNCTION(meta=(DisplayName="Beta"))
	int GetValue()
	{
		return 1;
	}
}
