/**
 * A unicast delegate with an int and an AActor parameter, stored on an actor.
 * The member starts unbound, and two actor instances do not share that state.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithParams
 * @Harness Function
 * @Tag Feature.Delegates.DelegateWithParams
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. WorldStory unicast delegate with int and AActor params.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_DelegateWithParams
 * @Provenance sha256=a3319100b72c08022070e903f127b0332de5fca23646ed82bc30ac7d834c9dd5; lines 68-76.
 * @Provenance Oracle: AssertCompiles DelDeclParams. Extra: default unbound; two locals independent.
 * @Provenance FixtureIsolated.
 */

/**
 * A unicast that reports damage amount and instigator.
 *
 * @Covers Delegates.Declaration
 * @Inputs Amount and Instigator
 * @Return nothing when executed
 */
delegate void FOnDamage(int Amount, AActor Instigator);

class ADelDeclParamActor : AActor
{
	UPROPERTY()
	FOnDamage OnDamage;
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's OnDamage is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param Actor the actor that holds OnDamage, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when OnDamage is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DelegateWithParamsDefaultUnbound(ADelDeclParamActor Actor)
	{
		if (Actor is null)
		{
			throw("DelegateWithParams setup: required Actor is null");
		}
		return !Actor.OnDamage.IsBound();
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
	bool DelegateWithParamsTwoLocalsIndependent(ADelDeclParamActor First, ADelDeclParamActor Second)
	{
		if (First is null)
		{
			throw("DelegateWithParams setup: required First is null");
		}
		if (Second is null)
		{
			throw("DelegateWithParams setup: required Second is null");
		}
		if (First.OnDamage.IsBound())
		{
			return false;
		}
		if (Second.OnDamage.IsBound())
		{
			return false;
		}
		return First != Second;
	}
}
