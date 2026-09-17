/**
 * @version v1
 * @summary HotReload VersionPair Before. Last-good GetValue 5.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Last-good GetValue 5.
 * @topic Baseline
 */
// Retained after failed After: UFailedReloadEventTarget, GetValue 5, generated class identity.
// Replaced in After: MissingType GetValue (does not compile).
// Oracle: ExecuteGetValue 5 before and after failed reload. FixtureIsolated.

UCLASS()
class UFailedReloadEventTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		int Result = 5;
		Log(n"HotReloadEventTests", "FailedReload V1 GetValue Result=" + Result);
		return Result;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Isolated failing program: unknown MissingType.
 * @topic HotReload
 */
// Retained last-good: Before GetValue 5, same UClass object, no post/class/full reload broadcasts.
// Replaced: GetValue return type and local Value as MissingType. Do not add declarations that would compile.
// FixtureIsolated.

UCLASS()
class UFailedReloadEventTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	MissingType GetValue()
	{
		MissingType Value;
		return Value;
	}
}
/** @end */
