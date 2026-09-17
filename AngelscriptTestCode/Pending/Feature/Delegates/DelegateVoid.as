/**
 * @version v1
 * @summary A void unicast delegate declared at script scope and stored on an actor. The member starts unbound, and two actor instances do not share that state.
 * @topic Feature
 */
/**
 * @version root
 * @summary A void unicast delegate declared at script scope and stored on an actor. The member starts unbound, and two actor instances do not share that state.
 * @topic Baseline
 */
/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FOnActionBasic();

class ADelDeclBasicActor : AActor
{
	UPROPERTY()
	FOnActionBasic OnAction;
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's OnAction is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param Actor the actor that holds OnAction, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when OnAction is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DelegateVoidDefaultUnbound(ADelDeclBasicActor Actor)
	{
		if (Actor is null)
		{
			throw("DelegateVoid setup: required Actor is null");
		}
		return !Actor.OnAction.IsBound();
	}

	/**
	 * Observe that two actor instances each start unbound and are distinct.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param First the first actor, runner-owned when non-null
	 * @Param Second the second actor, runner-owned when non-null
	 * @Inputs two actor instances
	 * @Return true when both are unbound and the instances differ
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool DelegateVoidTwoLocalsIndependent(ADelDeclBasicActor First, ADelDeclBasicActor Second)
	{
		if (First is null)
		{
			throw("DelegateVoid setup: required First is null");
		}
		if (Second is null)
		{
			throw("DelegateVoid setup: required Second is null");
		}
		if (First.OnAction.IsBound())
		{
			return false;
		}
		if (Second.OnAction.IsBound())
		{
			return false;
		}
		return First != Second;
	}
}
/** @end */
