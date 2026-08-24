// Theme: HotReload VersionPair After. Same module name, new generated class.
// C++: AngelscriptHotReloadFunctionTests.cpp::DiscardAndRecompile
// Retained: module name slot after DiscardModule succeeds, then this compile recreates the record.
// Replaced: UDiscardRecompileTarget / Version=1 -> UDiscardRecompileTargetV2 / GetVersion / Version default 2.
// FixtureIsolated. C++ oracle Version property value is 2.

UCLASS()
class UDiscardRecompileTargetV2 : UObject
{
	UPROPERTY()
	int Version;

	default Version = 2;

	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}
