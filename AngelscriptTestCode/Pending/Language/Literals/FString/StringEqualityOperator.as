/**
 * @version v1
 * @summary The equality operator on FString compares by value. Two separately built strings containing the same text compare equal, and a default-constructed string compares equal to the empty literal.
 * @topic Language
 */
/**
 * @version root
 * @summary The equality operator on FString compares by value. Two separately built strings containing the same text compare equal, and a default-constructed string compares equal to the empty literal.
 * @topic Baseline
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
/** @end */
