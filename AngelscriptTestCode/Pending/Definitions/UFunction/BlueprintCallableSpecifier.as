/**
 * @version v1
 * @summary BlueprintCallable on an actor method. DoWork is a valid callable UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintCallable on an actor method. DoWork is a valid callable UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Baseline
 */
class AUFuncBPCallActor : AActor
{
	/**
	 * BlueprintCallable UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void DoWork()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that DoWork can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose DoWork is invoked, runner-owned when non-null
	 * @Inputs Actor.DoWork()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int DoWorkCallCompletes(AUFuncBPCallActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.DoWork();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPCallActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncBPCallActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases the same object.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two default handles; First = Second
	 * @Return true when First is Second
	 */
	UFUNCTION()
	bool AssignAliasesHandle()
	{
		AUFuncBPCallActor First;
		AUFuncBPCallActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
