/**
 * @version v1
 * @summary A custom ability task subclass compiled from script, carrying a CustomDuration of 2.0. The sibling class carries the same property defaulted to 0 so C++ can compare the two defaults. The observers cover both durations.
 * @topic Optional
 */
/**
 * @version root
 * @summary A custom ability task subclass compiled from script, carrying a CustomDuration of 2.0. The sibling class carries the same property defaulted to 0 so C++ can compare the two defaults. The observers cover both durations.
 * @topic Baseline
 */
UCLASS()
class UTestCustomAbilityTask : UAngelscriptAbilityTask
{
	UPROPERTY()
	float CustomDuration = 2.0f;

	/**
	 * Observe the duration declared on this task.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptAbilityTaskSubclassCompiles
	 * @Inputs a task instance
	 * @Return true when CustomDuration is 2
	 * @Param Task the task to inspect
	 */
	UFUNCTION()
	bool DurationNominal(UTestCustomAbilityTask Task)
	{
		return Task.CustomDuration == 2.0f;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptAbilityTaskSubclassCompiles
	 * @Inputs an unset task handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestCustomAbilityTask Task = nullptr;
		return Task == nullptr;
	}

	/**
	 * Observe that writing one task leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptAbilityTaskSubclassCompiles
	 * @Inputs two task handles, the first written to zero
	 * @Return true when the second keeps its declared duration
	 * @Param First the task to write
	 * @Param Second the task that must stay unchanged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(UTestCustomAbilityTask First, UTestCustomAbilityTask Second)
	{
		First.CustomDuration = 0.0f;
		return Second.CustomDuration == 2.0f;
	}
}

UCLASS()
class UTestCustomAbilityTaskEmpty : UAngelscriptAbilityTask
{
	UPROPERTY()
	float CustomDuration = 0.0f;

	/**
	 * Observe the zero duration declared on the sibling task.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptAbilityTaskSubclassCompiles
	 * @Inputs a sibling task instance
	 * @Return true when CustomDuration is 0
	 * @Param Task the sibling task to inspect
	 */
	UFUNCTION()
	bool EmptySibling(UTestCustomAbilityTaskEmpty Task)
	{
		return Task.CustomDuration == 0.0f;
	}
}
/** @end */
