/**
 * @version v1
 * @summary A unicast delegate that returns bool from an action id, stored on an actor. The member starts unbound, and two actor instances do not share that state.
 * @topic Feature
 */
/**
 * @version root
 * @summary A unicast delegate that returns bool from an action id, stored on an actor. The member starts unbound, and two actor instances do not share that state.
 * @topic Baseline
 */
/**
 * A unicast that validates an action id.
 *
 * @Covers Delegates.Declaration
 * @Inputs ActionId
 * @Return true when the bound handler accepts the id
 */
delegate bool FValidateAction(int ActionId);

class ADelDeclReturnActor : AActor
{
	UPROPERTY()
	FValidateAction Validator;
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's Validator is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param Actor the actor that holds Validator, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when Validator is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DelegateWithReturnDefaultUnbound(ADelDeclReturnActor Actor)
	{
		if (Actor is null)
		{
			throw("DelegateWithReturn setup: required Actor is null");
		}
		return !Actor.Validator.IsBound();
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
	bool DelegateWithReturnTwoLocalsIndependent(ADelDeclReturnActor First, ADelDeclReturnActor Second)
	{
		if (First is null)
		{
			throw("DelegateWithReturn setup: required First is null");
		}
		if (Second is null)
		{
			throw("DelegateWithReturn setup: required Second is null");
		}
		if (First.Validator.IsBound())
		{
			return false;
		}
		if (Second.Validator.IsBound())
		{
			return false;
		}
		return First != Second;
	}
}
/** @end */
