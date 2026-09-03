/**
 * The equality operator on FString compares by value. Two separately built
 * strings containing the same text compare equal, and a default-constructed
 * string compares equal to the empty literal.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringEqualityOperator
 * @Harness Function
 * @Tag Language.Literals.StringEqualityOperator
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Methods_Positive block 4 AssertCompiles.
 * @Provenance sha256=51f1de98fc7add75a71dc0d69c38a4d49e7bd91bab8dfb4f820c156829d3922b; lines 230-232.
 * @Provenance Oracle: "abc" == "abc" is true.
 * @Provenance Extra: "abc" compared with "def" is false; two empty strings compare equal; equality is by value.
 * @Provenance DefaultSafe.
 */

namespace LiteralsTest
{
	/**
	 * Observe that two equal strings compare equal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "abc" and "abc"
	 * @Return true
	 */
	UFUNCTION()
	bool CompareEqualityNominal()
	{
		FString A = "abc";
		FString B = "abc";
		return A == B;
	}

	/**
	 * Observe that differing strings are not equal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "abc" and "def"
	 * @Return true, since the comparison must fail
	 * @Boundary differing text
	 */
	UFUNCTION()
	bool CompareEqualityDifferentBoundary()
	{
		FString A = "abc";
		FString B = "def";
		return !(A == B);
	}

	/**
	 * Observe that a default-constructed string equals the empty literal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "" and a default-constructed FString
	 * @Return true when they compare equal
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool CompareEqualityEmptyDefault()
	{
		FString A = "";
		FString B;
		return A == B;
	}
}
