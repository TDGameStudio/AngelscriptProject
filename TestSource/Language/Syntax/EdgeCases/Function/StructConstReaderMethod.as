/**
 * A struct carrying a const method. The method reads the member on a default
 * instance, a written instance, and through a copy whose write must not leak
 * back.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StructConstReaderMethod
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.StructConstReaderMethod
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 3 AssertCompiles.
 * @Provenance sha256=735ade4bb3c4cb689b68182ba65be1a1ae929bfd2a539b5b0201316b5b2d289a; lines 234-240.
 * @Provenance Oracle: GetX returns default X 0; after X=9 GetX returns 9.
 * @Provenance Extra: empty GetX is 0; copy then write leaves the original GetX.
 * @Provenance DefaultSafe. Source owns locals.
 */

/**
 * The struct with its const reader.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the struct's X
 * @Return the value of X
 */
struct FStructMethods
{
	int X = 0;

	/**
	 * Reads the member without writing it.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the struct's X
	 * @Return the value of X
	 */
	int GetX() const
	{
		return X;
	}
}

namespace SyntaxTest
{
	/**
	 * Observe the const method's default read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int StructMethodGetXDefault()
	{
		FStructMethods S;
		return S.GetX();
	}

	/**
	 * Observe the const method's read after a write.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a struct whose X was set to 9
	 * @Return 9
	 * @Boundary written value
	 */
	UFUNCTION()
	int StructMethodGetXAfterWrite()
	{
		FStructMethods S;
		S.X = 9;
		return S.GetX();
	}

	/**
	 * Observe that a copy's write leaves the original's read unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copied struct whose copy was written
	 * @Return 3
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int StructMethodCopyIndependentGetX()
	{
		FStructMethods A;
		A.X = 3;
		FStructMethods B = A;
		B.X = 4;
		return A.GetX();
	}
}
