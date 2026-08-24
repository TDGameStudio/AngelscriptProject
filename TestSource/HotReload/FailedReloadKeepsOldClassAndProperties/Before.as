// Theme: HotReload VersionPair Before. Last-good class before broken full reload.
// C++: AngelscriptHotReloadPropertyTests.cpp::FailedReloadKeepsOldClassAndProperties ReloadV1Source
// Retained after failed After: UClass identity; Value default 7; no PollutedValue.
// Replaced in After (rejected): Value=99; PollutedValue=13; GetMissingValue.
// Oracle Before: Value==7; PollutedValue absent.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadFailureTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 7;
}
