/**
 * @version v1
 * @summary The inequality operator on FString, the complement of the equality operator. Differing strings report unequal, identical strings do not, and a default-constructed string is unequal to any non-empty literal.
 * @topic Language
 */
/**
 * @version root
 * @summary The inequality operator on FString, the complement of the equality operator. Differing strings report unequal, identical strings do not, and a default-constructed string is unequal to any non-empty literal.
 * @topic Baseline
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
/** @end */
