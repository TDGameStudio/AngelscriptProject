/**
 * AddUFunction binds a named handler onto a multicast event. The event starts
 * unbound, becomes bound after Setup, and binding on one actor leaves another
 * unbound.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.AddUFunction
 * @Harness Function
 * @Tag Feature.Delegates.AddUFunction
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. WorldStory AddUFunction on a multicast event.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Positive_AddUFunction
 * @Provenance sha256 from theme-refs TS-FEAT-0344; lines 333-348.
 * @Provenance Oracle: AssertCompiles DelBindAddUFunc. Extra: unbound before Setup; bound after Setup.
 * @Provenance FixtureIsolated.
 */

/**
 * A multicast event that reports an integer change.
 *
 * @Covers Delegates.Binding
 * @Inputs Val
 * @Return nothing when broadcast
 */
event void FOnChangedBind(int Val);

class ADelBindAddActor : AActor
{
	UPROPERTY()
	FOnChangedBind OnChanged;

	/**
	 * The named handler bound by AddUFunction.
	 *
	 * @Covers Delegates.Binding
	 * @Param Val the broadcast payload
	 * @Inputs Val
	 * @Return nothing
	 */
	void HandleChanged(int Val)
	{
	}

	/**
	 * Binds HandleChanged onto OnChanged.
	 *
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return nothing; OnChanged becomes bound
	 */
	void Setup()
	{
		OnChanged.AddUFunction(this, n"HandleChanged");
	}
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's OnChanged is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param Actor the actor that holds OnChanged, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when OnChanged is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool AddUFunctionDefaultUnbound(ADelBindAddActor Actor)
	{
		if (Actor is null)
		{
			throw("AddUFunction setup: required Actor is null");
		}
		return !Actor.OnChanged.IsBound();
	}

	/**
	 * Observe that Setup binds the handler.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param Actor the actor that holds OnChanged, runner-owned when non-null
	 * @Inputs Setup()
	 * @Return true when OnChanged is bound
	 */
	UFUNCTION()
	bool AddUFunctionBoundAfterSetup(ADelBindAddActor Actor)
	{
		if (Actor is null)
		{
			throw("AddUFunction setup: required Actor is null");
		}
		Actor.Setup();
		return Actor.OnChanged.IsBound();
	}

	/**
	 * Observe that binding and broadcasting on one actor leaves the other unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param First the actor that is set up, runner-owned when non-null
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs Setup and Broadcast(0) on First
	 * @Return true when First is bound and Second is not
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AddUFunctionCopyIndependence(ADelBindAddActor First, ADelBindAddActor Second)
	{
		if (First is null)
		{
			throw("AddUFunction setup: required First is null");
		}
		if (Second is null)
		{
			throw("AddUFunction setup: required Second is null");
		}
		First.Setup();
		First.OnChanged.Broadcast(0);
		if (!First.OnChanged.IsBound())
		{
			return false;
		}
		return !Second.OnChanged.IsBound();
	}
}
