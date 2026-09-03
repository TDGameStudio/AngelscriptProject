/**
 * The n"Name" literal is rewritten into a static name reference. Two literals
 * naming the same text share one index and compare equal, while a third naming
 * different text does not.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.NameLiteralRoundTrip
 * @Harness Function
 * @Tag Language.Preprocessor.NameLiteralRoundTrip
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorLiteralTests.cpp::NameLiteralRoundTrip
 * @Provenance sha256=42357bab2ece2ad66c429cfafd0a05b8a13146226409d2ff0b5badffb2ee88c3; lines 46-54.
 * @Provenance Oracle: Entry() == 42 because n"Alpha" == n"Alpha" and n"Alpha" != n"Beta"; duplicate Alpha shares index.
 * @Provenance Extra: default FName is not Alpha/Beta. DefaultSafe.
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
