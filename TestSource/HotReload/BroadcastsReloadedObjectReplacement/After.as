// Theme: HotReload VersionPair After. Literal asset full-reload V2.
// C++: AngelscriptHotReloadLiteralAssetTests.cpp::BroadcastsReloadedObjectReplacement
// Retained: ReloadExampleAsset canonical name; live class is the new ULiteralReloadAsset.
// Replaced: ExtraValue=2 is added; old class is marked newer-version-exists; reload callback fires once with old/new objects.
// FixtureIsolated.

UCLASS()
class ULiteralReloadAsset : UObject
{
	UPROPERTY()
	int ExtraValue = 2;
}

asset ReloadExampleAsset of ULiteralReloadAsset
{
}
