/**
 * The first of two compile-context payloads. Each compile run gets its own
 * context, so this module's entry point is independent of the second one's.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FirstCompilationContextPayload
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FirstCompilationContextPayload
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerEventsTests.cpp::CompilationContextIsScopedPerCompileRun block 1
 * @Provenance sha256=bd4a73e4104949e6f1fbb294a011facdf330ef482b6a786722d93fa63b8b7e9f; lines 726-731.
 * @Provenance Oracle: FirstEntry() returns 23. Extra: repeating FirstEntry stays 23.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * The entry point of the first compile-context payload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 23
	 */
	int FirstEntry()
	{
		return 23;
	}

	/**
	 * Observe that the first context reports 23.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs FirstEntry()
	 * @Return true when the value is 23
	 */
	UFUNCTION()
	bool FirstContextReturnsTwentyThree()
	{
		return FirstEntry() == 23;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to FirstEntry()
	 * @Return true when both report 23
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool FirstContextRepeatsConsistently()
	{
		if (FirstEntry() != 23)
		{
			return false;
		}

		return FirstEntry() == 23;
	}
}
