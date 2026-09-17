/**
 * @version v1
 * @summary Reload pair initial source: CompileAnnotatedModuleFromMemory publishes UClassGeneratorNameConflictRecovery with Value default 1.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Reload pair initial source: CompileAnnotatedModuleFromMemory publishes UClassGeneratorNameConflictRecovery with Value default 1.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorNameConflictRecovery : UObject
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Observe the initial Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed object
	 * @Return Value
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return Value;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs UClassGeneratorNameConflictRecovery Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UClassGeneratorNameConflictRecovery Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that writing this object leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other object expected to stay at 1
	 * @Inputs this.Value set to 0
	 * @Return true when Second.Value is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorNameConflictRecovery Second)
	{
		if (Second is null)
		{
			throw("FixingRejectedReloadInitial setup: required Second is null");
		}
		Value = 0;
		return Second.Value == 1;
	}
}
/** @end */
