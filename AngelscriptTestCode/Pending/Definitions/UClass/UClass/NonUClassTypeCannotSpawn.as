/**
 * @version v1
 * @summary A UObject script class compiles but is not actor-derived. NewObject succeeds and world SpawnActor returns null. Keep Value.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UObject script class compiles but is not actor-derived. NewObject succeeds and world SpawnActor returns null. Keep Value.
 * @topic Baseline
 */
UCLASS()
class UTestScriptClassNonUClassTypeCannotSpawn : UObject
{
	UPROPERTY()
	int Value = 5;

	/**
	 * Observe the Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.NonActor
	 * @Inputs a freshly constructed object
	 * @Return true when Value is 5
	 */
	UFUNCTION()
	bool ValueDefault()
	{
		return Value == 5;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.NonActor
	 * @Inputs UTestScriptClassNonUClassTypeCannotSpawn Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestScriptClassNonUClassTypeCannotSpawn Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that writing this object leaves another at 5.
	 *
	 * @Kind Observe
	 * @Covers UClass.NonActor
	 * @Param Second Other object expected to stay at 5
	 * @Inputs this.Value set to 0
	 * @Return true when Second.Value is 5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestScriptClassNonUClassTypeCannotSpawn Second)
	{
		if (Second is null)
		{
			throw("NonUClassTypeCannotSpawn setup: required Second is null");
		}
		Value = 0;
		return Second.Value == 5;
	}
}
/** @end */
