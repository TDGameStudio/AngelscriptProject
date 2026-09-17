/**
 * @version v1
 * @summary Recompile pair BEFORE class switch. GenerationValue defaults to 1. Keep GenerationValue; the after file replaces the default with 2.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Recompile pair BEFORE class switch. GenerationValue defaults to 1. Keep GenerationValue; the after file replaces the default with 2.
 * @topic Baseline
 */
UCLASS()
class ATestScriptClassRecompileDoesNotCrashClassSwitch : AActor
{
	UPROPERTY()
	int GenerationValue = 1;

	/**
	 * Observe the initial GenerationValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Recompile
	 * @Inputs a freshly constructed actor
	 * @Return true when GenerationValue is 1
	 */
	UFUNCTION()
	bool GenerationValueDefault()
	{
		return GenerationValue == 1;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Recompile
	 * @Inputs ATestScriptClassRecompileDoesNotCrashClassSwitch Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestScriptClassRecompileDoesNotCrashClassSwitch Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Recompile
	 * @Param Second Other actor expected to stay at 1
	 * @Inputs this.GenerationValue set to 99
	 * @Return true when Second.GenerationValue is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassRecompileDoesNotCrashClassSwitch Second)
	{
		if (Second is null)
		{
			throw("RecompileClassSwitchInitial setup: required Second is null");
		}
		GenerationValue = 99;
		return Second.GenerationValue == 1;
	}
}
/** @end */
