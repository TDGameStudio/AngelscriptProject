/**
 * @version v1
 * @summary The n"Name" literal is rewritten into a static name reference. Two literals naming the same text share one index and compare equal, while a third naming different text does not.
 * @topic Language
 */
/**
 * @version root
 * @summary The n"Name" literal is rewritten into a static name reference. Two literals naming the same text share one index and compare equal, while a third naming different text does not.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * Compares two matching name literals against a differing one.
	 *
	 * @Covers Preprocessor.Literals
	 * @Inputs n"Alpha", n"Alpha" and n"Beta"
	 * @Return 42 when the pair matches and the third differs, else 0
	 */
	int Entry()
	{
		FName A = n"Alpha";
		FName B = n"Alpha";
		FName C = n"Beta";

		if (A != B)
		{
			return 0;
		}

		if (A == C)
		{
			return 0;
		}

		return 42;
	}

	/**
	 * Observe that the duplicate literal compares equal and reports 42.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Literals
	 * @Inputs the three name literals
	 * @Return true when Entry reports 42
	 */
	UFUNCTION()
	bool NameLiteralRoundTripProducesExpectedValues()
	{
		return Entry() == 42;
	}

	/**
	 * Observe that a default name matches neither literal.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Literals
	 * @Inputs a default-constructed FName
	 * @Return true when it differs from both literals
	 * @Boundary default FName
	 */
	UFUNCTION()
	bool NameLiteralEmptyDefault()
	{
		FName Empty;

		if (Empty == n"Alpha")
		{
			return false;
		}

		return Empty != n"Beta";
	}

	/**
	 * Observe that copying a literal keeps the value and leaves Entry stable.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Literals
	 * @Inputs a copy of n"Alpha", compared against n"Beta" and Entry
	 * @Return true when the copy matches, differs from Beta, and Entry is 42
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool NameLiteralCopyIndependence()
	{
		FName First = n"Alpha";
		FName Second = First;

		if (First != Second)
		{
			return false;
		}

		if (First == n"Beta")
		{
			return false;
		}

		return Entry() == 42;
	}
}
/** @end */
