/**
 * A parse-event payload module: the deterministic main-thread broadcast order
 * does not disturb the module's own results, so Entry returns its constant.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ParseEventsAreBroadcastFromMainThreadInDeterministicOrder
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ParseEventsAreBroadcastFromMainThreadInDeterministicOrder
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerEventsTests.cpp::ParseEventsAreBroadcastFromMainThreadInDeterministicOrder
 * @Provenance sha256=fc0a82cd3ac483e0459e3f94584455fbfc88663a6e50efc9073d17e7d1e14dd0; lines 650-655.
 * @Provenance Oracle: Entry() returns 19. Extra: repeating Entry stays 19. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Returns the module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 19
	 */
	int Entry()
	{
		return 19;
	}

	/**
	 * Observe the entry value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 19
	 */
	UFUNCTION()
	bool ParseEventsNominal()
	{
		return Entry() == 19;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 19
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ParseEventsRepeatCall()
	{
		int First = Entry();

		if (First != 19)
		{
			return false;
		}

		return Entry() == 19;
	}
}
