/**
 * @version v1
 * @summary HotReload VersionPair Before. Last-good class before broken full reload.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Last-good class before broken full reload.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Isolated compile-fail broken full reload.
 * @topic HotReload
 */
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

	/** Returns the missing value. */
	UFUNCTION()
	MissingType GetMissingValue()
	{
		MissingType Value;
		return Value;
	}
}
/** @end */
