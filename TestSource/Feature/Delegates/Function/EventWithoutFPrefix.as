/**
 * AngelScript does not enforce an F prefix on event type names. C++
 * compile-fail is DISABLED (#as-engine-behavior); this program compiles.
 * OnChanged starts unbound; Broadcast(0) is the zero boundary; two locals
 * stay independent.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.EventWithoutFPrefix
 * @Harness Function
 * @Tag Feature.Delegates.EventWithoutFPrefix
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. C++ compile-fail is DISABLED (#as-engine-behavior):
 * @Provenance AngelScript does not enforce an F prefix on event type names.
 * @Provenance CSV NegativeDiagnostic is wrong; AssertFailsToCompile is #if 0 so this compiles.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_EventWithoutFPrefix
 * @Provenance sha256=f31575eee44e832bf44c6338a4903e3d955f73287849db6ffedb77dee7b80db6; lines 185-187.
 * @Provenance Extra: default unbound; Broadcast(0) is the zero boundary. Follow C++ method.
 */

/**
 * A multicast event whose type name has no F prefix.
 *
 * @Covers Delegates.Declaration
 * @Inputs int X
 * @Return nothing when broadcast
 */
event void OnChanged(int X);

namespace DelegatesTest
{
	/**
	 * Observe that a default-constructed OnChanged is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local OnChanged
	 * @Return true when the local is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool EventWithoutFPrefixDefaultUnbound()
	{
		OnChanged Notify;
		return !Notify.IsBound();
	}

	/**
	 * Observe that Broadcast(0) on an unbound event is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs Broadcast(0)
	 * @Return nothing; the event stays unbound
	 * @Boundary zero broadcast
	 */
	UFUNCTION()
	void EventWithoutFPrefixZeroBroadcastNoOp()
	{
		OnChanged Notify;
		Notify.Broadcast(0);
	}

	/**
	 * Observe that broadcasting on one local leaves the other unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs Broadcast(1) on First
	 * @Return true when both stay unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool EventWithoutFPrefixTwoLocalsIndependent()
	{
		OnChanged First;
		OnChanged Second;
		First.Broadcast(1);
		if (First.IsBound())
		{
			return false;
		}
		return !Second.IsBound();
	}
}
