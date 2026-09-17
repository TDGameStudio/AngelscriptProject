/**
 * @version v1
 * @summary BlueprintCallable with parameters. SetHealth(int, bool) is a valid parameterized UFUNCTION, SetHealth(0, false) is the zero/false boundary, and a default handle is null.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintCallable with parameters. SetHealth(int, bool) is a valid parameterized UFUNCTION, SetHealth(0, false) is the zero/false boundary, and a default handle is null.
 * @topic Baseline
 */
class AUFuncParamsActor : AActor
{
	/**
	 * BlueprintCallable UFUNCTION with int and bool parameters.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param NewHealth Health value to set
	 * @Param bNotify Whether to notify listeners
	 * @Inputs NewHealth and bNotify
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void SetHealth(int NewHealth, bool bNotify)
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that SetHealth can be invoked with a live value pair.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose SetHealth is invoked, runner-owned when non-null
	 * @Inputs Actor.SetHealth(100, true)
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int SetHealthCallCompletes(AUFuncParamsActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.SetHealth(100, true);
		return 0;
	}

	/**
	 * Observe the zero/false boundary of SetHealth.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose SetHealth is invoked, runner-owned when non-null
	 * @Inputs Actor.SetHealth(0, false)
	 * @Return 0 when the call completes; -1 when Actor is null
	 * @Boundary zero health and false notify
	 */
	UFUNCTION()
	int SetHealthZeroFalseBoundary(AUFuncParamsActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.SetHealth(0, false);
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncParamsActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncParamsActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
