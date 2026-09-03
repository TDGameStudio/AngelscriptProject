/**
 * AngelScript does not enforce an F prefix on delegate type names. C++
 * compile-fail is DISABLED (#as-engine-behavior); this program compiles.
 * OnAction starts unbound, and two locals stay independent.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithoutFPrefix
 * @Harness Function
 * @Tag Feature.Delegates.DelegateWithoutFPrefix
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. C++ compile-fail is DISABLED (#as-engine-behavior):
 * @Provenance AngelScript does not enforce an F prefix on delegate type names.
 * @Provenance CSV NegativeDiagnostic is wrong; AssertFailsToCompile is #if 0 so this compiles.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_WithoutFPrefix
 * @Provenance sha256=8bc91aec26539952310dc719676276466411124e09227cad2bde6bc3a0f7ac76; lines 146-148.
 * @Provenance Extra: default unbound; two locals independent. CSV DiagnosticOnly is ignored
 * @Provenance in favor of the C++ method.
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
