/**
 * @version v1
 * @summary FConsoleVariable reuses native CVar metadata when the name already exists, so a script default of 99 must not replace the native value. The runner owns the native CVar and supplies ExistingName.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FConsoleVariable reuses native CVar metadata when the name already exists, so a script default of 99 must not replace the native value. The runner owns the native CVar and supplies ExistingName.
 * @topic Baseline
 */
namespace MetaTest
{
	/**
	 * Bind an existing CVar with a script default that must not replace native metadata.
	 *
	 * @Kind Observe
	 * @Covers Meta.CVarExistingVariablePreservesNativeMetadata
	 * @Inputs the native CVar name
	 * @Return the native integer value
	 * @Param ExistingName the native CVar name supplied by the runner
	 */
	UFUNCTION()
	int ReadExistingWithDifferentDefaults(const FString&in ExistingName)
	{
		FConsoleVariable Var(ExistingName, 99, "Script default should not replace native CVar metadata");
		return Var.GetInt();
	}

	/**
	 * Bind the same existing CVar and write 21 through it.
	 *
	 * @Kind Observe
	 * @Covers Meta.CVarExistingVariablePreservesNativeMetadata
	 * @Inputs the native CVar name
	 * @Return 21 after SetInt
	 * @Param ExistingName the native CVar name supplied by the runner
	 */
	UFUNCTION()
	int UpdateExistingWithDifferentDefaults(const FString&in ExistingName)
	{
		FConsoleVariable Var(ExistingName, 99, "Script default should not replace native CVar metadata");
		Var.SetInt(21);
		return Var.GetInt();
	}

	/**
	 * Observe that reading through a different default still returns the native value.
	 *
	 * @Kind Observe
	 * @Covers Meta.CVarExistingVariablePreservesNativeMetadata
	 * @Inputs the native CVar name
	 * @Return the native integer value
	 * @Param ExistingName the native CVar name supplied by the runner
	 * @Boundary empty name is a setup failure
	 */
	UFUNCTION()
	int ReadNative(const FString&in ExistingName)
	{
		if (ExistingName.Len() == 0)
		{
			throw("TS-DEF-0056 setup: required ExistingName is empty");
		}
		return ReadExistingWithDifferentDefaults(ExistingName);
	}

	/**
	 * Observe that writing 21 through the existing CVar is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.CVarExistingVariablePreservesNativeMetadata
	 * @Inputs the native CVar name
	 * @Return 21
	 * @Param ExistingName the native CVar name supplied by the runner
	 * @Boundary empty name is a setup failure
	 */
	UFUNCTION()
	int UpdateNative(const FString&in ExistingName)
	{
		if (ExistingName.Len() == 0)
		{
			throw("TS-DEF-0056 setup: required ExistingName is empty");
		}
		return UpdateExistingWithDifferentDefaults(ExistingName);
	}

	/**
	 * Observe that the script default of 99 is not applied over native metadata.
	 *
	 * @Kind Observe
	 * @Covers Meta.CVarExistingVariablePreservesNativeMetadata
	 * @Inputs the native CVar name and the native baseline value
	 * @Return true when the read matches the baseline and is not 99
	 * @Param ExistingName the native CVar name supplied by the runner
	 * @Param BaselineExisting the native value the script default must not replace
	 * @Boundary script default 99
	 */
	UFUNCTION()
	bool ScriptDefaultNotApplied(const FString&in ExistingName, int BaselineExisting)
	{
		if (ExistingName.Len() == 0)
		{
			throw("TS-DEF-0056 setup: required ExistingName is empty");
		}
		if (ReadExistingWithDifferentDefaults(ExistingName) != BaselineExisting)
		{
			return false;
		}
		return ReadExistingWithDifferentDefaults(ExistingName) != 99;
	}
}
/** @end */
