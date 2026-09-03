/**
 * A unicast delegate that returns bool from an action id, stored on an actor.
 * The member starts unbound, and two actor instances do not share that state.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithReturn
 * @Harness Function
 * @Tag Feature.Delegates.DelegateWithReturn
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. WorldStory unicast delegate with bool return.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_DelegateWithReturn
 * @Provenance sha256=8e64ca15464e2c3a50a474f7560006c9b41ab2066b78cce4edb0cf379c723b79; lines 86-94.
 * @Provenance Oracle: AssertCompiles DelDeclReturn. Extra: default unbound; two locals independent.
 * @Provenance FixtureIsolated.
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
