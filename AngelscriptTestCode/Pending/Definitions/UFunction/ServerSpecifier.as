/**
 * @version v1
 * @summary Server on an actor method. ServerDoAction is a valid Server UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Server on an actor method. ServerDoAction is a valid Server UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Baseline
 */
class AUFuncServerActor : AActor
{
	/**
	 * Server UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Server)
	void ServerDoAction()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that ServerDoAction can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose ServerDoAction is invoked, runner-owned when non-null
	 * @Inputs Actor.ServerDoAction()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int ServerDoActionCallCompletes(AUFuncServerActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.ServerDoAction();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncServerActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncServerActor Unset;
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
		AUFuncServerActor First;
		AUFuncServerActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
