// Theme: HotReload VersionPair After. Isolated compile-fail broken full reload.
// C++: AngelscriptHotReloadPropertyTests.cpp::FailedReloadKeepsOldClassAndProperties BrokenReloadSource
// Expected diagnostic: unknown type MissingType on GetMissingValue (and local Value).
// Retained last-good (Before): UClass identity; Value default 7; PollutedValue unpublished.
// Replaced shape (not published): Value=99; PollutedValue; GetMissingValue.
// Oracle: FullReload compile false; error reload result. Do not add declarations that would compile.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadFailureTarget : UObject
{
	UPROPERTY()
	int Value;

	UPROPERTY()
	int PollutedValue;

	default Value = 99;
	default PollutedValue = 13;

	UFUNCTION()
	MissingType GetMissingValue()
	{
		MissingType Value;
		return Value;
	}
}
