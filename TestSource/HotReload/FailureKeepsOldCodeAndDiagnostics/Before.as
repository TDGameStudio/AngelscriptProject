// Theme: HotReload VersionPair Before. Last-good body before a failed reload.
// C++: AngelscriptHotReloadFunctionTests.cpp::FailureKeepsOldCodeAndDiagnostics
// Retained after the broken After compile: UHotReloadFailureKeepsOldCode / GetValue returns 5.
// Replaced: nothing; After is diagnostic-only and must not take effect.
// FixtureIsolated. C++ oracle is 5 before and after the failed SoftReloadOnly.

UCLASS()
class UHotReloadFailureKeepsOldCode : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 5;
	}
}
