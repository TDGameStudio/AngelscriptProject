/**
 * A compile with no listener attached: the compile-event pipeline stays silent
 * and the module's result is unaffected, so Entry still returns its constant.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.NoListenerCompileIsSilentAndPreservesResult
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.NoListenerCompileIsSilentAndPreservesResult
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerEventsTests.cpp::NoListenerCompileIsSilentAndPreservesResult
 * @Provenance sha256=81eed953d9af0b5100bd07ff60186d5cd6d15a3d3cf5f49f90b6a9b7ee288fef; lines 206-211.
 * @Provenance Oracle: Entry() returns 7. Extra: repeating Entry stays 7. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Returns the module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 7
	 */
	int Entry()
	{
		return 7;
	}

	/**
	 * Observe the entry value without any listener.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool NoListenerCompileNominal()
	{
		return Entry() == 7;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 7
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool NoListenerCompileRepeatCall()
	{
		int First = Entry();

		if (First != 7)
		{
			return false;
		}

		return Entry() == 7;
	}
}
