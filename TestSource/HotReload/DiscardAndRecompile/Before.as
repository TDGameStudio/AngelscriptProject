// Theme: HotReload VersionPair Before. Discard then recompile same module name.
// C++: AngelscriptHotReloadFunctionTests.cpp::DiscardAndRecompile
// Retained until discard: UDiscardRecompileTarget / GetVersion / Version default 1.
// Replaced after discard+recompile: this class is gone; After publishes UDiscardRecompileTargetV2 with Version default 2.
// FixtureIsolated.

UCLASS()
class UDiscardRecompileTarget : UObject
{
	UPROPERTY()
	int Version;

	default Version = 1;

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}
