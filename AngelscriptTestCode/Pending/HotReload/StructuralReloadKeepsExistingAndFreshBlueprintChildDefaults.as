/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Structural parent NotEditable Value=10, GetValue=10.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Structural parent NotEditable Value=10, GetValue=10.
 * @topic Baseline
 */
// Retained later: existing Blueprint child Value default 10 once Bonus is added.
// Replaced later: add Bonus; then EditAnywhere Value=20 Bonus=7 (parent UClass replaced each full reload).
// Oracle: GetValue==10 before first structural reload; CPF_Edit clear on Value.
// FixtureIsolated. Load Version_01..03 in recorded order.

UCLASS()
class AHotReloadBlueprintChildStructuralParent : AActor
{
	UPROPERTY(NotEditable)
	int Value = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value;
	}
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Adds Bonus=5; GetValue = Value + Bonus.
 * @topic HotReload
 */
UCLASS()
class AHotReloadBlueprintChildStructuralParent : AActor
{
	UPROPERTY(NotEditable)
	int Value = 10;

	UPROPERTY()
	int Bonus = 5;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + Bonus;
	}
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. EditAnywhere Value=20, Bonus=7.
 * @topic HotReload
 */
// Retained on existing Blueprint child: prior Value=10 and Bonus=5 (GetValue 15).
// Replaced: parent UClass again; Value CPF_Edit; script defaults 20/7.
// Oracle: existing child GetValue==15; fresh parent/Blueprint GetValue==27.
// FixtureIsolated.

UCLASS()
class AHotReloadBlueprintChildStructuralParent : AActor
{
	UPROPERTY(EditAnywhere)
	int Value = 20;

	UPROPERTY()
	int Bonus = 7;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + Bonus;
	}
}
/** @end */
