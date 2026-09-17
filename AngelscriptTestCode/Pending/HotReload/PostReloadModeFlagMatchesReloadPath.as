/**
 * @version v1
 * @summary HotReload VersionPair Version_01. GetValue returns 1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. GetValue returns 1.
 * @topic Baseline
 */
UCLASS()
class UPostReloadModeTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		int Result = 1;
		Log(n"HotReloadEventTests", "PostReloadMode V1 GetValue Result=" + Result);
		return Result;
	}
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Soft body GetValue 2.
 * @topic HotReload
 */
UCLASS()
class UPostReloadModeTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		int Result = 2;
		Log(n"HotReloadEventTests", "PostReloadMode V2 GetValue Result=" + Result);
		return Result;
	}
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Structural Epoch property, GetValue returns Epoch.
 * @topic HotReload
 */
UCLASS()
class UPostReloadModeTarget : UObject
{
	UPROPERTY()
	int Epoch = 3;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		Log(n"HotReloadEventTests", "PostReloadMode V3 GetValue Epoch=" + Epoch);
		return Epoch;
	}
}
/** @end */
