/**
 * Positive for-loop syntax forms: ascending, descending, all-clause-omitted,
 * nested, and compound step. The observers confirm each total plus the
 * never-entered boundary.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForPositiveSyntaxForms
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ForPositiveSyntaxForms
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::For_Positive ExpectGlobalInts
 * @Provenance sha256=8afd93a8a158de22433f2bb2762dfc17cc57e83a68488307d89245bbeda083f9; lines 139-145.
 * @Provenance Oracle: BasicFor 10; Decrement 6; Empty 3; Nested 6; CompoundStep 4.
 * @Provenance Extra: for I<0 yields 0; CompoundStep is the step-boundary vector.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Sums an ascending count.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 10
	 */
	int BasicFor()
	{
		int S = 0;
		for (int I = 0; I < 5; ++I)
		{
			S += I;
		}
		return S;
	}

	/**
	 * Sums a descending count.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 6
	 */
	int Decrement()
	{
		int S = 0;
		for (int I = 3; I > 0; --I)
		{
			S += I;
		}
		return S;
	}

	/**
	 * Counts with all for clauses omitted.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 3
	 */
	int Empty()
	{
		int I = 0;
		for (;;)
		{
			if (I >= 3)
			{
				break;
			}
			++I;
		}
		return I;
	}

	/**
	 * Counts iterations of a doubly nested loop.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 6
	 */
	int Nested()
	{
		int S = 0;
		for (int I = 0; I < 3; ++I)
		{
			for (int J = 0; J < 2; ++J)
			{
				++S;
			}
		}
		return S;
	}

	/**
	 * Counts iterations stepped by a compound assignment.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 4
	 */
	int CompoundStep()
	{
		int S = 0;
		for (int I = 0; I < 100; I += 25)
		{
			++S;
		}
		return S;
	}

	/**
	 * Observe that all five forms produce their totals.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all five helpers
	 * @Return true when all five totals match
	 */
	UFUNCTION()
	bool ForPositiveNominal()
	{
		if (BasicFor() != 10)
		{
			return false;
		}

		if (Decrement() != 6)
		{
			return false;
		}

		if (Empty() != 3)
		{
			return false;
		}

		if (Nested() != 6)
		{
			return false;
		}

		return CompoundStep() == 4;
	}

	/**
	 * Observe that a loop whose condition is false at entry sums nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a loop bounded by I < 0
	 * @Return 0
	 * @Boundary never-entered loop
	 */
	UFUNCTION()
	int ForPositiveEmptyBound()
	{
		int S = 0;
		for (int I = 0; I < 0; ++I)
		{
			S += I;
		}
		return S;
	}
}
