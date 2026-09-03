/**
 * A USTRUCT whose single UPROPERTY carries an explicit zero initializer.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UStructPropertyZeroDefault
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.UStructPropertyZeroDefault
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 2 AssertCompiles.
 * @Provenance sha256=f880e24f4b3092175e4377e8fb6d4abca962ffb851734484f5bcb558877b53bc; lines 223-230.
 * @Provenance Oracle: UPROPERTY X defaults to 0.
 * @Provenance Extra: X=0 empty default; writing a copy does not rewrite the original.
 * @Provenance DefaultSafe. Keep UPROPERTY name X.
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
