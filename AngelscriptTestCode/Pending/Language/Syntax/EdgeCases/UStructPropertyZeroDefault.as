/**
 * @version v1
 * @summary A USTRUCT whose single UPROPERTY carries an explicit zero initializer.
 * @topic Language
 */
/**
 * @version root
 * @summary A USTRUCT whose single UPROPERTY carries an explicit zero initializer.
 * @topic Baseline
 */
/**
 * The USTRUCT under test.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared USTRUCT with one zeroed UPROPERTY
 */
USTRUCT()
struct FStructUSTRUCT
{
	/**
	 * The struct's single property.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; a plain UPROPERTY named X
	 */
	UPROPERTY()
	int X = 0;
}

namespace SyntaxTest
{
	/**
	 * Observe the property's default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int UStructPropertyDefaultX()
	{
		FStructUSTRUCT S;
		return S.X;
	}

	/**
	 * Observe the property's write boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a struct whose X was set to 1
	 * @Return 1
	 * @Boundary written value
	 */
	UFUNCTION()
	int UStructPropertyWriteBoundary()
	{
		FStructUSTRUCT S;
		S.X = 1;
		return S.X;
	}

	/**
	 * Observe that a copy's write leaves the original untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copied struct whose copy was zeroed
	 * @Return 4
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int UStructPropertyCopyIndependentX()
	{
		FStructUSTRUCT A;
		A.X = 4;
		FStructUSTRUCT B = A;
		B.X = 0;
		return A.X;
	}
}
/** @end */
