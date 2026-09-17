/**
 * @version v1
 * @summary Client on an actor method. ClientReceiveData is a valid Client UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Client on an actor method. ClientReceiveData is a valid Client UFUNCTION, a default handle is null, and assigning one handle to another aliases the same object.
 * @topic Baseline
 */
class AUFuncClientActor : AActor
{
	/**
	 * Client UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Client)
	void ClientReceiveData()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that ClientReceiveData can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose ClientReceiveData is invoked, runner-owned when non-null
	 * @Inputs Actor.ClientReceiveData()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int ClientReceiveDataCallCompletes(AUFuncClientActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.ClientReceiveData();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncClientActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncClientActor Unset;
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
		AUFuncClientActor First;
		AUFuncClientActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
