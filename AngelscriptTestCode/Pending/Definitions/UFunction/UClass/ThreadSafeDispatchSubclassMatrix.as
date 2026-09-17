/**
 * @version v1
 * @summary Function- and class-level BlueprintThreadSafe dispatch. FastReturn is 10, FunctionThreadSafeReturn is 20, ClassThreadSafeReturn is 30, and ClassThreadSafeOptOutReturn is 40. Repeat calls are stable, and.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Function- and class-level BlueprintThreadSafe dispatch. FastReturn is 10, FunctionThreadSafeReturn is 20, ClassThreadSafeReturn is 30, and ClassThreadSafeOptOutReturn is 40. Repeat calls are stable, and.
 * @topic Baseline
 */
UCLASS()
class UCoverageUFunctionThreadSafeObject : UObject
{
	/**
	 * Plain return of 10.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return 10
	 */
	UFUNCTION()
	int FastReturn()
	{
		return 10;
	}

	/**
	 * Function-level BlueprintThreadSafe return of 20.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return 20
	 */
	UFUNCTION(meta=(BlueprintThreadSafe))
	int FunctionThreadSafeReturn()
	{
		return 20;
	}

	/**
	 * Observe that FastReturn and FunctionThreadSafeReturn stay 10 and 20.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param ClassObject Class-level thread-safe object
	 * @Inputs FastReturn, FunctionThreadSafeReturn, ClassThreadSafeReturn, ClassThreadSafeOptOutReturn
	 * @Return true when the four constants match and FastReturn is stable
	 */
	UFUNCTION()
	bool RepeatCallsAreStable(UCoverageUFunctionThreadSafeClassObject ClassObject)
	{
		if (FastReturn() != 10)
		{
			return false;
		}
		if (FunctionThreadSafeReturn() != 20)
		{
			return false;
		}
		if (ClassObject.ClassThreadSafeReturn() != 30)
		{
			return false;
		}
		if (ClassObject.ClassThreadSafeOptOutReturn() != 40)
		{
			return false;
		}
		return FastReturn() == FastReturn();
	}
}

UCLASS(meta=(BlueprintThreadSafe))
class UCoverageUFunctionThreadSafeClassObject : UObject
{
	/**
	 * Class-level BlueprintThreadSafe return of 30.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return 30
	 */
	UFUNCTION()
	int ClassThreadSafeReturn()
	{
		return 30;
	}

	/**
	 * Class-level opt-out NotBlueprintThreadSafe return of 40.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return 40
	 */
	UFUNCTION(meta=(NotBlueprintThreadSafe))
	int ClassThreadSafeOptOutReturn()
	{
		return 40;
	}
}
/** @end */
