/**
 * Comma-separated clauses in the for initializer and update: two variables
 * declared together and stepped in opposite directions. The observers confirm
 * the total plus the empty and single-trip boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForCommaClauses
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ForCommaClauses
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageSpecialControlFlowTests.cpp::ForCommaClausesCompileAndExecute
 * @Provenance sha256=49752852e6dde5b62a404379ff751ae82e9360be8abc43475a0c100f075de768; lines 146-156.
 * @Provenance Oracle: ForCommaClauses()==50.
 * @Provenance Extra: i<0 empty trip yields 0; i<1 single trip is 0+10=10.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Sums two comma-declared loop variables moving apart.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 50
	 */
	int ForCommaClauses()
	{
		int Sum = 0;
		for (int i = 0, j = 10; i < 5; i++, j--)
		{
			Sum += i + j;
		}
		return Sum;
	}

	/**
	 * Observe the nominal comma-clause total.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ForCommaClauses()
	 * @Return true when the total is 50
	 */
	UFUNCTION()
	bool ForCommaClausesNominal()
	{
		return ForCommaClauses() == 50;
	}

	/**
	 * Observe that a false-at-entry condition makes no trips.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a comma-clause loop bounded by i < 0
	 * @Return 0
	 * @Boundary empty trip
	 */
	UFUNCTION()
	int ForCommaClausesEmptyBound()
	{
		int Sum = 0;
		for (int i = 0, j = 10; i < 0; i++, j--)
		{
			Sum += i + j;
		}
		return Sum;
	}

	/**
	 * Observe that a single trip adds both starting values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a comma-clause loop bounded by i < 1
	 * @Return 10
	 * @Boundary single trip
	 */
	UFUNCTION()
	int ForCommaClausesSingleTrip()
	{
		int Sum = 0;
		for (int i = 0, j = 10; i < 1; i++, j--)
		{
			Sum += i + j;
		}
		return Sum;
	}
}
