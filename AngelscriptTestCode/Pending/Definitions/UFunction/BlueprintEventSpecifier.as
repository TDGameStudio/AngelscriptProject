/**
 * @version v1
 * @summary BlueprintEvent on an actor method. OnDamageReceived is a valid event UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintEvent on an actor method. OnDamageReceived is a valid event UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Baseline
 */
class AUFuncBPEventActor : AActor
{
	/**
	 * BlueprintEvent UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintEvent)
	void OnDamageReceived()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that OnDamageReceived can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose OnDamageReceived is invoked, runner-owned when non-null
	 * @Inputs Actor.OnDamageReceived()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int OnDamageReceivedCallCompletes(AUFuncBPEventActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.OnDamageReceived();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPEventActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncBPEventActor Unset;
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
		AUFuncBPEventActor First;
		AUFuncBPEventActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
