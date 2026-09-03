/**
 * A void unicast delegate declared at script scope and stored on an actor.
 * The member starts unbound, and two actor instances do not share that state.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateVoid
 * @Harness Function
 * @Tag Feature.Delegates.DelegateVoid
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. WorldStory void unicast delegate declaration.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_DelegateVoid
 * @Provenance sha256=93f7589ceb2b5174b102ae9eefcd53d96d8002002cc544f87641a3541e5a25ac; lines 50-58.
 * @Provenance Oracle: AssertCompiles DelDeclBasic. Extra: default unbound; two locals independent.
 * @Provenance FixtureIsolated.
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
