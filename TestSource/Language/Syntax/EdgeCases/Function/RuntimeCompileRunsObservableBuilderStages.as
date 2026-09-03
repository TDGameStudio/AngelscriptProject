/**
 * A builder integration module whose produced bytecode executes: Entry calls
 * through a helper so the compiled stages are observable at runtime.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.RuntimeCompileRunsObservableBuilderStages
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.RuntimeCompileRunsObservableBuilderStages
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerBuilderIntegrationTests.cpp::RuntimeCompileRunsObservableBuilderStages
 * @Provenance sha256=129f8e4130420656298b62bc057a0cd19a67ef30880912c8da2e1c9575428c00; lines 93-103.
 * @Provenance Oracle: Entry() == BuilderIntegrationAdd(2) == 42.
 * @Provenance Extra: Delta 0 returns 40. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Adds a delta to the builder base value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a delta
	 * @Return 40 plus the delta
	 * @Param Delta the amount to add
	 */
	int BuilderIntegrationAdd(int Delta)
	{
		return 40 + Delta;
	}

	/**
	 * Calls through the helper so the compiled stages run.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int Entry()
	{
		return BuilderIntegrationAdd(2);
	}

	/**
	 * Observe both the direct and indirect call results.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry() and BuilderIntegrationAdd(2)
	 * @Return true when both report 42
	 */
	UFUNCTION()
	bool EntryNominal()
	{
		if (Entry() != 42)
		{
			return false;
		}

		return BuilderIntegrationAdd(2) == 42;
	}

	/**
	 * Observe the zero-delta boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BuilderIntegrationAdd(0)
	 * @Return true when the result is 40
	 * @Boundary zero delta
	 */
	UFUNCTION()
	bool BuilderIntegrationAddZeroBoundary()
	{
		return BuilderIntegrationAdd(0) == 40;
	}

	/**
	 * Observe the negative-delta boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BuilderIntegrationAdd(-40)
	 * @Return true when the result is 0
	 * @Boundary negative delta
	 */
	UFUNCTION()
	bool BuilderIntegrationAddNegativeBoundary()
	{
		return BuilderIntegrationAdd(-40) == 0;
	}
}
