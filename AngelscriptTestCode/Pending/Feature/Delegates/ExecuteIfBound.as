/**
 * @version v1
 * @summary ExecuteIfBound on an unbound unicast is a no-op. The delegate starts unbound; Fire does not throw; two instances stay independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary ExecuteIfBound on an unbound unicast is a no-op. The delegate starts unbound; Fire does not throw; two instances stay independent.
 * @topic Baseline
 */
/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.Binding
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FOnActionExec();

class ADelExecActor : AActor
{
	UPROPERTY()
	FOnActionExec OnAction;

	/**
	 * Calls ExecuteIfBound on OnAction.
	 *
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return nothing; an unbound ExecuteIfBound is a no-op
	 */
	void Fire()
	{
		OnAction.ExecuteIfBound();
	}
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's OnAction is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param Actor the actor that holds OnAction, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when OnAction is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool ExecuteIfBoundDefaultUnbound(ADelExecActor Actor)
	{
		if (Actor is null)
		{
			throw("ExecuteIfBound setup: required Actor is null");
		}
		return !Actor.OnAction.IsBound();
	}

	/**
	 * Observe that Fire on an unbound delegate is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param Actor the actor that holds OnAction, runner-owned when non-null
	 * @Inputs Fire()
	 * @Return nothing; the delegate stays unbound
	 * @Boundary unbound fire
	 */
	UFUNCTION()
	void ExecuteIfBoundUnboundFireIsNoOp(ADelExecActor Actor)
	{
		if (Actor is null)
		{
			throw("ExecuteIfBound setup: required Actor is null");
		}
		Actor.Fire();
	}

	/**
	 * Observe that Fire on one actor leaves the other unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param First the actor that fires, runner-owned when non-null
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs Fire on First
	 * @Return true when both stay unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ExecuteIfBoundTwoLocalsIndependent(ADelExecActor First, ADelExecActor Second)
	{
		if (First is null)
		{
			throw("ExecuteIfBound setup: required First is null");
		}
		if (Second is null)
		{
			throw("ExecuteIfBound setup: required Second is null");
		}
		First.Fire();
		if (First.OnAction.IsBound())
		{
			return false;
		}
		return !Second.OnAction.IsBound();
	}
}
/** @end */
