/**
 * @version v1
 * @summary AngelScript does not enforce an F prefix on delegate type names. C++ compile-fail is DISABLED (#as-engine-behavior); this program compiles. OnAction starts unbound, and two locals stay independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary AngelScript does not enforce an F prefix on delegate type names. C++ compile-fail is DISABLED (#as-engine-behavior); this program compiles. OnAction starts unbound, and two locals stay independent.
 * @topic Baseline
 */
/**
 * A void unicast whose type name has no F prefix.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return nothing when executed
 */
delegate void OnAction();

namespace DelegatesTest
{
	/**
	 * Observe that a default-constructed OnAction is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local OnAction
	 * @Return true when the local is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DelegateWithoutFPrefixDefaultUnbound()
	{
		OnAction Notify;
		return !Notify.IsBound();
	}

	/**
	 * Observe that two locals start unbound independently.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs two local OnAction values
	 * @Return true when both are unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool DelegateWithoutFPrefixTwoLocalsIndependent()
	{
		OnAction First;
		OnAction Second;
		if (First.IsBound())
		{
			return false;
		}
		return !Second.IsBound();
	}
}
/** @end */
