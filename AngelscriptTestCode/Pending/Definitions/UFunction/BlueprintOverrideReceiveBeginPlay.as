/**
 * @version v1
 * @summary BlueprintOverride of ReceiveBeginPlay on an actor. The class is an AActor subclass, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintOverride of ReceiveBeginPlay on an actor. The class is an AActor subclass, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Baseline
 */
class AUFuncBPOverrideActor : AActor
{
	/**
	 * BlueprintOverride of ReceiveBeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintOverride)
	void ReceiveBeginPlay()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that a constructed override actor is an AActor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPOverrideActor
	 * @Return 1 when the handle is an AActor, otherwise 0
	 */
	UFUNCTION()
	int OverrideActorIsAActorWhenSet()
	{
		AUFuncBPOverrideActor Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPOverrideActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncBPOverrideActor Unset;
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
		AUFuncBPOverrideActor First;
		AUFuncBPOverrideActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
