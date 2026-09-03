/**
 * A compile-event payload module whose registered listener receives value-style
 * events: the listener path does not disturb the module's results, so Entry
 * returns its constant.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.RegisteredListenerReceivesValueStyleCompileEvents
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.RegisteredListenerReceivesValueStyleCompileEvents
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerEventsTests.cpp::RegisteredListenerReceivesValueStyleCompileEvents
 * @Provenance sha256=82721f24863ef39d151bc5fb579a10048fffa649d5426d5249305d54349bc68b; lines 262-267.
 * @Provenance Oracle: Entry() returns 11. Extra: repeating Entry stays 11. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Returns the module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 11
	 */
	int Entry()
	{
		return 11;
	}

	/**
	 * Observe the entry value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool RegisteredListenerCompileNominal()
	{
		return Entry() == 11;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 11
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool RegisteredListenerCompileRepeatCall()
	{
		int First = Entry();

		if (First != 11)
		{
			return false;
		}

		return Entry() == 11;
	}
}
