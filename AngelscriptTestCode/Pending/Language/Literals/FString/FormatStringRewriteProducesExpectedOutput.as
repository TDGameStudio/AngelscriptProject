/**
 * @version v1
 * @summary The f-string rewrite lowers every specifier branch to an independent comparison, and ScoreAllBranches() weights each branch distinctly so the total identifies exactly which branches fired.
 * @topic Language
 */
/**
 * @version root
 * @summary The f-string rewrite lowers every specifier branch to an independent comparison, and ScoreAllBranches() weights each branch distinctly so the total identifies exactly which branches fired.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Scores every f-string specifier branch with a distinct weight.
	 *
	 * @Covers Literals.FString
	 * @Inputs escaped braces, expression, self-documenting, hex, precision, and combined specifiers
	 * @Return the sum of the weights of the branches that matched
	 */
	int ScoreAllBranches()
	{
		float Value = 12.34f;
		int Score = 0;

		if (f"{{Alpha}}" == "{Alpha}")
		{
			Score += 1000;
		}

		if (f"{20 + 1}" == "21")
		{
			Score += 100;
		}

		if (f"{21 =}" == "21 = 21")
		{
			Score += 10;
		}

		if (f"{255 :#06x}" == "0x00ff")
		{
			Score += 4;
		}

		if (f"{Value :.1f}" == "12.3")
		{
			Score += 2;
		}

		if (f"{Value =:.1f}" == "Value = 12.3")
		{
			Score += 1;
		}

		return Score;
	}

	/**
	 * Observe that the full f-string rewrite reaches the combined score.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ScoreAllBranches()
	 * @Return true when the score is 1117
	 */
	UFUNCTION()
	bool FormatStringRewriteProducesExpectedOutput()
	{
		return ScoreAllBranches() == 1117;
	}

	/**
	 * Observe that escaped braces render literally, in isolation.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs f"{{Alpha}}"
	 * @Return 1000 when escaped braces render literally
	 * @Boundary escaped delimiters
	 */
	UFUNCTION()
	int FormatStringEscapedBraceOnly()
	{
		int Score = 0;
		if (f"{{Alpha}}" == "{Alpha}")
		{
			Score += 1000;
		}
		return Score;
	}

	/**
	 * Observe that the rewrite is repeatable across two invocations.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs two ScoreAllBranches() invocations
	 * @Return 1117 when both runs agree, otherwise 0
	 * @Boundary repeated evaluation
	 */
	UFUNCTION()
	int FormatStringRepeatBoundary()
	{
		int First = ScoreAllBranches();
		int Second = ScoreAllBranches();

		if (First != 1117)
		{
			return 0;
		}

		if (Second != 1117)
		{
			return 0;
		}

		return 1117;
	}
}
/** @end */
