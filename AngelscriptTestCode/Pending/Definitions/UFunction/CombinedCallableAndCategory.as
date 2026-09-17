/**
 * @version v1
 * @summary BlueprintCallable combined with Category. MoveForward is a valid multi-specifier UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintCallable combined with Category. MoveForward is a valid multi-specifier UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Baseline
 */
class AUFuncMultiSpecActor : AActor
{
	/**
	 * Combined BlueprintCallable and Category UFUNCTION.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category = "Movement")
	void MoveForward()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that MoveForward can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose MoveForward is invoked, runner-owned when non-null
	 * @Inputs Actor.MoveForward()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int MoveForwardCallCompletes(AUFuncMultiSpecActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.MoveForward();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncMultiSpecActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncMultiSpecActor Unset;
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
		AUFuncMultiSpecActor First;
		AUFuncMultiSpecActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
