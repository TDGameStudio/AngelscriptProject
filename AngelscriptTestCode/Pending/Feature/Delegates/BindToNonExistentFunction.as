/**
 * @version v1
 * @summary BindUFunction is a runtime dynamic bind and does not validate the function name at compile time. C++ compile-fail is DISABLED (#as-engine-behavior); this program compiles. Setup is kept as declared and is not invoked.
 * @topic Feature
 */
/**
 * @version root
 * @summary BindUFunction is a runtime dynamic bind and does not validate the function name at compile time. C++ compile-fail is DISABLED (#as-engine-behavior); this program compiles. Setup is kept as declared and is not invoked.
 * @topic Baseline
 */
/**
 * A parameterless void unicast bound to a missing handler name.
 *
 * @Covers Delegates.Binding
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FOnActionBadFunc();

class ADelBadFuncActor : AActor
{
	UPROPERTY()
	FOnActionBadFunc OnAction;

	/**
	 * Binds a function name that does not exist. Not invoked from the observers.
	 *
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return nothing; the bind is runtime-owned
	 */
	void Setup()
	{
		OnAction.BindUFunction(this, n"NonExistentHandler");
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
	bool BindToNonExistentFunctionDefaultUnbound(ADelBadFuncActor Actor)
	{
		if (Actor is null)
		{
			throw("BindToNonExistentFunction setup: required Actor is null");
		}
		return !Actor.OnAction.IsBound();
	}

	/**
	 * Observe that two actor instances each start unbound and are distinct.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param First the first actor, runner-owned when non-null
	 * @Param Second the second actor, runner-owned when non-null
	 * @Inputs two actor instances
	 * @Return true when both are unbound and the instances differ
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BindToNonExistentFunctionTwoLocalsIndependent(ADelBadFuncActor First, ADelBadFuncActor Second)
	{
		if (First is null)
		{
			throw("BindToNonExistentFunction setup: required First is null");
		}
		if (Second is null)
		{
			throw("BindToNonExistentFunction setup: required Second is null");
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
