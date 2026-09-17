/**
 * @version v1
 * @summary Recompile pair AFTER class switch. GenerationValue is 2 and AddedAfterRecompile is 17. Keep those UPROPERTY names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Recompile pair AFTER class switch. GenerationValue is 2 and AddedAfterRecompile is 17. Keep those UPROPERTY names.
 * @topic Baseline
 */
UCLASS()
class ATestScriptClassRecompileDoesNotCrashClassSwitch : AActor
{
	UPROPERTY()
	int GenerationValue = 2;

	UPROPERTY()
	int AddedAfterRecompile = 17;

	/**
	 * Observe the recompiled defaults.
	 *
	 * @Kind Observe
	 * @Covers UClass.Recompile
	 * @Inputs GenerationValue and AddedAfterRecompile
	 * @Return true when they are 2 and 17
	 */
	UFUNCTION()
	bool RecompiledDefaults()
	{
		if (GenerationValue != 2)
		{
			return false;
		}
		return AddedAfterRecompile == 17;
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
	 * Observe that writing this actor leaves another at 2 and 17.
	 *
	 * @Kind Observe
	 * @Covers UClass.Recompile
	 * @Param Second Other actor expected to keep recompiled defaults
	 * @Inputs this written to 0/0
	 * @Return true when Second still holds 2 and 17
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassRecompileDoesNotCrashClassSwitch Second)
	{
		if (Second is null)
		{
			throw("RecompileClassSwitchReloaded setup: required Second is null");
		}
		GenerationValue = 0;
		AddedAfterRecompile = 0;
		if (Second.GenerationValue != 2)
		{
			return false;
		}
		return Second.AddedAfterRecompile == 17;
	}
}
/** @end */
