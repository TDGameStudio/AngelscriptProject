/**
 * @version v1
 * @summary BindUFunction binds a named handler onto a unicast delegate. The delegate starts unbound, becomes bound after Setup, and binding on one actor leaves another unbound.
 * @topic Feature
 */
/**
 * @version root
 * @summary BindUFunction binds a named handler onto a unicast delegate. The delegate starts unbound, becomes bound after Setup, and binding on one actor leaves another unbound.
 * @topic Baseline
 */
/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.Binding
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FOnActionBind();

class ADelBindActor : AActor
{
	UPROPERTY()
	FOnActionBind OnAction;

	/**
	 * The named handler bound by BindUFunction.
	 *
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return nothing
	 */
	void HandleAction()
	{
	}

	/**
	 * Binds HandleAction onto OnAction.
	 *
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return nothing; OnAction becomes bound
	 */
	void Setup()
	{
		OnAction.BindUFunction(this, n"HandleAction");
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
	bool BindUFunctionDefaultUnbound(ADelBindActor Actor)
	{
		if (Actor is null)
		{
			throw("BindUFunction setup: required Actor is null");
		}
		return !Actor.OnAction.IsBound();
	}

	/**
	 * Observe that Setup binds the handler.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param Actor the actor that holds OnAction, runner-owned when non-null
	 * @Inputs Setup()
	 * @Return true when OnAction is bound
	 */
	UFUNCTION()
	bool BindUFunctionBoundAfterSetup(ADelBindActor Actor)
	{
		if (Actor is null)
		{
			throw("BindUFunction setup: required Actor is null");
		}
		Actor.Setup();
		return Actor.OnAction.IsBound();
	}

	/**
	 * Observe that binding on one actor leaves the other unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param First the actor that is set up, runner-owned when non-null
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs Setup on First
	 * @Return true when First is bound and Second is not
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BindUFunctionCopyIndependence(ADelBindActor First, ADelBindActor Second)
	{
		if (First is null)
		{
			throw("BindUFunction setup: required First is null");
		}
		if (Second is null)
		{
			throw("BindUFunction setup: required Second is null");
		}
		First.Setup();
		if (!First.OnAction.IsBound())
		{
			return false;
		}
		return !Second.OnAction.IsBound();
	}
}
/** @end */
