/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Soft sequence baseline ComputeBonus=0, GetValue=10.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Soft sequence baseline ComputeBonus=0, GetValue=10.
 * @topic Baseline
 */
// Retained across later versions: class identity, Value=10, BeginPlayCount not replayed (stays 1).
// Replaced later: ComputeBonus body 0 -> 1 -> BeginPlayCount+20 -> 30 (GetValue 10, 11, 31, 40).
// Oracle: GetValue==10; BeginPlayCount==1 after first BeginPlay.
// FixtureIsolated. Load Version_01..04 in recorded order.

UCLASS()
class AHotReloadBlueprintChildSoftSequenceParent : AActor
{
	UPROPERTY()
	int Value = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/** Computes the bonus and returns the result. */
	int ComputeBonus()
	{
		return 0;
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. ComputeBonus helper body returns 1.
 * @topic HotReload
 */
UCLASS()
class AHotReloadBlueprintChildSoftSequenceParent : AActor
{
	UPROPERTY()
	int Value = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/** Computes the bonus and returns the result. */
	int ComputeBonus()
	{
		return 1;
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. ComputeBonus reads live BeginPlayCount + 20.
 * @topic HotReload
 */
UCLASS()
class AHotReloadBlueprintChildSoftSequenceParent : AActor
{
	UPROPERTY()
	int Value = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/** Computes the bonus and returns the result. */
	int ComputeBonus()
	{
		return BeginPlayCount + 20;
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
/** @end */
/**
 * @version version-04
 * @parent root
 * @summary HotReload VersionPair Version_04. ComputeBonus helper body returns 30.
 * @topic HotReload
 */
UCLASS()
class AHotReloadBlueprintChildSoftSequenceParent : AActor
{
	UPROPERTY()
	int Value = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/** Computes the bonus and returns the result. */
	int ComputeBonus()
	{
		return 30;
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
/** @end */
