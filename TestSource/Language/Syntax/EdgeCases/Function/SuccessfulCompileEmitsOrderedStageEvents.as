/**
 * A compile-stage payload module: a successful compile emits its ordered stage
 * events without disturbing the module's own results, so Entry returns its
 * constant and the stage type keeps its default semantics.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.SuccessfulCompileEmitsOrderedStageEvents
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.SuccessfulCompileEmitsOrderedStageEvents
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerEventsTests.cpp::SuccessfulCompileEmitsOrderedStageEvents
 * @Provenance sha256=91af3870fea0438c187814f79df7de716865fcfb3cc28f7fcff14051e106f8a9; lines 399-409.
 * @Provenance Oracle: Entry() returns 17. Extra: FCompilationEventsStagesType.Value default
 * @Provenance is 0; a copy does not alias the original. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * The stage type carried by the compile events.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the type's Value member
	 * @Return a declared type with one int member
	 */
	class FCompilationEventsStagesType
	{
		int Value;
	}

	/**
	 * Returns the module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 17
	 */
	int Entry()
	{
		return 17;
	}

	/**
	 * Observe the entry value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 17
	 */
	UFUNCTION()
	bool StageEventsNominal()
	{
		return Entry() == 17;
	}

	/**
	 * Observe the stage type's default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed stage type
	 * @Return true when Value is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool StageEventsTypeDefaultEmpty()
	{
		FCompilationEventsStagesType Stages;
		return Stages.Value == 0;
	}

	/**
	 * Observe that a stage-type copy does not alias the original.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copied stage type whose copy was zeroed
	 * @Return true when the original keeps 17 and the copy holds 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool StageEventsCopyIndependence()
	{
		FCompilationEventsStagesType Original;
		Original.Value = 17;
		FCompilationEventsStagesType Copied = Original;
		Copied.Value = 0;

		if (Original.Value != 17)
		{
			return false;
		}

		return Copied.Value == 0;
	}
}
