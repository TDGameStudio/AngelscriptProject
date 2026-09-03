/**
 * The inequality operator on FString, the complement of the equality operator.
 * Differing strings report unequal, identical strings do not, and a
 * default-constructed string is unequal to any non-empty literal.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringInequalityOperator
 * @Harness Function
 * @Tag Language.Literals.StringInequalityOperator
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Methods_Positive block 5 AssertCompiles.
 * @Provenance sha256=ebcc6082fdff3352afdb6107085080064eaceabddbf46f72b10ef9405a04693b; lines 236-238.
 * @Provenance Oracle: "abc" != "def" is true.
 * @Provenance Extra: "abc" != "abc" is false; empty != "def" is true.
 * @Provenance DefaultSafe.
 */

namespace LiteralsTest
{
	/**
	 * Observe that two differing strings report unequal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "abc" and "def"
	 * @Return true
	 */
	UFUNCTION()
	bool CompareInequalityNominal()
	{
		FString A = "abc";
		FString B = "def";
		return A != B;
	}

	/**
	 * Observe that identical strings do not report unequal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "abc" and "abc"
	 * @Return true, since the comparison must fail
	 * @Boundary identical text
	 */
	UFUNCTION()
	bool CompareInequalitySameBoundary()
	{
		FString A = "abc";
		FString B = "abc";
		return !(A != B);
	}

	/**
	 * Observe that a default-constructed string is unequal to a literal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs a default-constructed FString and "def"
	 * @Return true when they report unequal
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool CompareInequalityEmptyDefault()
	{
		FString A;
		FString B = "def";
		return A != B;
	}
}
